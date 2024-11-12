Shader "Unlit/RanseCode"
{
    Properties
    {
        
        _MainTex("地面贴图",2D) = "white"{}
        [HDR]_baseColor("地面混合颜色",Color) = (1,1,1,1)
        
        _SpecGlossMap("高光贴图",2D) = "white"{}
        [HDR]_SpecColor("高光颜色",Color) = (1,1,1,1)
        
        _NoiseMap("噪声贴图",2D) = "black"{}
        _NoiseScale("噪声Scale大小",Float) = 1
        _NoiseColor("噪声颜色",2D) = "white"{}
        
        _shiStep("shi的范围",Float) = 1
        _textureSize("可移动区域大小（得除2）",Vector) = (1,1,1)
        
        _bump("粘液法线贴图",2D) = "bump"{}
        _ifShadow("是否投影",Range(0,1)) = 1
        
        [hidden]_width("width",Vector) = (1,1,1)
        
        [Hidden]_woniu_position("woniu position",Vector) = (1,1,1)
        [Hidden]_startPoint("Start point",Vector) = (0,0,0)
        [Hidden]_cross("路径图",2D) = "black"{}
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" "RenderType" = "Opaque""UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel"="4.5"}
        
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
        
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _baseColor;
            float4 _NoiseMap_ST;
            float4 _cross_ST;
            float4 _bump_ST;
            float4 _SpecGlossMap_ST;
        CBUFFER_END
        ENDHLSL

        

        Pass
        {
            Name"Main"
            Tags{ "LightMode" = "UniversalForward"}
            Cull Off
            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS            //主光源投影接收
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE     //级联投影接收开关（关闭后最远距离无投影）
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS  //附加光源
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS//附加光源投影接收
            #pragma multi_compile_fragment _ _SHADOWS_SOFT//软阴影
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION//屏幕空间ao
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog//雾效
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            
            #pragma vertex vert
            #pragma fragment frag
            
            

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 lightmapUV : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 uv : TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                float4 positionCS : SV_POSITION;
                
                float3 viewDirWS : TEXCOORD2;
                float4 normal : TEXCOORD3;
                float3 temp : TEXCOORD4;
                //uv和sh搁着呢
                float3 posWS : TEXCOORD6;
                half4 fogFactorAndVertexLight   : TEXCOORD7;
                float4 tangent : TEXCOORD8;
                float4 bitangent : TEXCOORD9;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

            TEXTURE2D(_cross);
            SAMPLER(sampler_cross);

            TEXTURE2D(_NoiseColor);
            SAMPLER(sampler_NoiseColor);

            TEXTURE2D(_bump);
            SAMPLER(sampler_bump);

            TEXTURE2D(_SpecGlossMap);
            SAMPLER(sampler_SpecGlossMap);

            float3 _woniu_position;
            float3 _startPoint;
            half _NoiseScale;
            half _shiStep;
            half2 _textureSize;
            float4 _SpecColor;
            half _ifShadow;
            half4 _secColor;

            void InitializeInputData(Varyings input,half3 normalTS,out InputData inputData)
            {
                //inputdata 世界坐标
                inputData.positionWS = input.posWS;
                inputData.positionCS = input.positionCS;
                //世界空间视角向量： NTB的w分量
                half3 viewDirWS = half3(input.normal.w,input.tangent.w,input.bitangent.w);
                //转换切线空间法线
                inputData.tangentToWorld = half3x3 (input.tangent.xyz,input.bitangent.xyz,input.normal.xyz);
                inputData.normalWS = TransformTangentToWorld(normalTS,inputData.tangentToWorld);
                //单位化
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                //防止平方为零
                viewDirWS = SafeNormalize(viewDirWS);
                inputData.viewDirectionWS = viewDirWS;

                //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS  用这个，或者在varyings里算，不然就是0
                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                //half4 fogFactorAndVertexLight   : TEXCOORD7;这一步
                inputData.fogCoord = input.fogFactorAndVertexLight.x;
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                //计算物体之间光照交互：GI,根据是否使用lightmap从lightmap或SH中获取全局光照的颜色值
                //uv是unity生成的计算静态物体的间接光照，存在一张光照贴图中，自动生成（找到了）
                //SH是计算动态物体光照
                //lightmap——on就用uv，反之sh
                //里面是用的samplelightmap
                inputData.bakedGI = SAMPLE_GI(input.lightmapUV,input.vertexSH,inputData.normalWS);
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                //采样shadowMask贴图
                inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);
            }



            
            Varyings vert (Attributes IN)
            {
                Varyings OUT = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normalInput  = GetVertexNormalInputs(IN.normalOS);
                OUT.positionCS = positionInputs.positionCS;
                OUT.posWS = positionInputs.positionWS;
                // OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                half3 viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);
                half3 vertexLight = VertexLighting(positionInputs.positionWS,normalInput .normalWS);
                half fogFactor = ComputeFogFactor(positionInputs.positionCS.z);

                //viewDIRWS石块
                OUT.normal = half4(normalInput .normalWS,viewDirWS.x);
                OUT.tangent = half4(normalInput.tangentWS,viewDirWS.y);
                OUT.bitangent = half4(normalInput.bitangentWS,viewDirWS.z);

                //lightUV
                OUTPUT_LIGHTMAP_UV(IN.lightmapUV,unity_LightmapST,OUT.lightmapUV);
                //vertexSH 为啥要法线ws（计算？）
                OUTPUT_SH(OUT.normal.xyz,OUT.vertexSH);

                OUT.fogFactorAndVertexLight = half4(fogFactor,vertexLight);
                
                OUT.uv.xy = TRANSFORM_TEX(IN.uv.xy,_MainTex);
                OUT.uv.zw = TRANSFORM_TEX(float2((OUT.posWS.x  - _startPoint.x + _textureSize.x /2.0f)/_textureSize.x , (OUT.posWS.z - _startPoint.z + _textureSize.y/2.0f)/_textureSize.y) ,_cross);
                
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                half path = SAMPLE_TEXTURE2D(_cross,sampler_cross,IN.uv.zw ).r;
                half2 temp1 = (IN.posWS - mul(unity_ObjectToWorld,float3(0,0,0))).xz * _NoiseScale;
                half NoiseColor = clamp(SAMPLE_TEXTURE2D(_NoiseMap,sampler_NoiseMap,temp1).r + SAMPLE_TEXTURE2D(_NoiseMap,sampler_NoiseMap,IN.posWS.xz  * 0.1+ float2(_Time.y,0) * 0.01),0,1);
                half final1 =clamp((path - NoiseColor * 0.5)* _shiStep,0,1);
                
                
                half3 albedo = final1 * SAMPLE_TEXTURE2D(_NoiseColor,sampler_NoiseColor,IN.uv.xy * 0.3)* _baseColor + (1-final1) * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv.xy);
                half4 SpecularColor = _SpecColor;

                half3 normalTS = lerp(IN.normal,UnpackNormal(SAMPLE_TEXTURE2D(_bump,sampler_bump,IN.posWS.xz  * 0.1+ float2(_Time.y,0) * 0.01)) * final1 + (1-final1) * IN.normal,final1);
                half4 specular = SAMPLE_TEXTURE2D(_SpecGlossMap,sampler_SpecGlossMap,IN.uv.xy) * SpecularColor;
                
                half smoothness = specular.a  = exp2(10*specular.a + 1);

                InputData inputData;
                InitializeInputData(IN,normalTS,inputData);

                half4 shadowMask = inputData.shadowMask * _ifShadow;
                Light mainLight = GetMainLight(inputData.shadowCoord,inputData.positionWS,shadowMask);
                
                #if defined(_SCREEN_SPACE_OCCLUSION)
                    AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
                    mainLight.color *= aoFactor.directAmbientOcclusion;
                    inputData.bakedGI = aoFactor.indirectAmbientOcclusion;
                #endif
                
                MixRealtimeAndBakedGI(mainLight,inputData.normalWS,inputData.bakedGI);
                half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                half3 diffuseColor = inputData.bakedGI + LightingLambert(attenuatedLightColor,mainLight.direction,inputData.normalWS);
                half3 specularColor = LightingSpecular(attenuatedLightColor,mainLight.direction,inputData.normalWS,inputData.viewDirectionWS,specular,smoothness);

                //附加光源光照计算
                #ifdef _ADDITIONAL_LIGHTS
                    uint pixelLightCount = GetAdditionalLightsCount();
                    for(uint lightIndex =0u; lightIndex < pixelLightCount; ++lightIndex)
                    {
                        Light light = GetAdditionalLight(lightIndex,inputData.positionWS,shadowMask);
                        #if defined(_SCREEN_SPACE_OCCLUSION)
                            light.color *= aoFactor.directAmbientOcclusion;
                        #endif

                        half3 attentuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
                        diffuseColor += LightingLambert(attenuatedLightColor,light.direction,inputData.normalWS);
                        specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specular, smoothness);
                    }

                #endif
                
                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    diffuseColor += inputData.VertexLighting;
                #endif
                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    diffuseColor += inputData.vertexLighting;
                #endif
                
                half3 finalColor = diffuseColor * albedo;
                finalColor += specularColor;

                half4 color = half4(finalColor,1);
                
                color.rgb = MixFog(color.rgb,inputData.fogCoord);


                return color;



                
            }      
            ENDHLSL
        }
    }
            FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
