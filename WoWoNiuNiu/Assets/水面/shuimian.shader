Shader "Custom/shuimian"
{
    Properties
    {
        _Color("Main Color",Color) = (1,1,1,1)
        _MainTex("MainTex",2D) = "white"{}
        
        _SeaBottomColor("Sea Bottom",Color) = (1,1,1,1)
        _SeaTopColor("Sea Top",Color) = (1,1,1,1)
        [HDR]_WaterBottomColor("WaveBottomColor",Color) = (1,1,1,1)
        [HDR]_WaterTopColor("WaveTopColor",Color) = (1,1,1,1)
        _GradientDir("_GradientDir",Vector) = (1,1,1)
        
        _bumpMap("Bump Map",2D) = "bump"{}
        _NormalScale ("NormalScale",Vector) = (1,1,1)
        _NormalUVSPeed("NormalUVSpeed",Vector) = (1,1,1,1)
        _NormalTiling("Normaltiling",Vector) = (1,1,1,1)
        
        _Gloss("Gloss",Float) = 0.5
        _SpecularThreshold("SpecularThreshold",Float) = 1
        _SpecularSmooth("SpecularSmooth",Float) = 1
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        
        _Fresnelpow("Fresnelpow",Float) = 1
        _FresnelStepMin("FresnelstepMin",Float) = 1
        _FresnelStepMax("FresnelstepMax",Float) = 2
        _Reflection("reflection",Cube) = "cube"{}
        _ReflectionColor("reflectionColor",Color) = (1,1,1,1)
        
        _ShallowFade("ShallowFade",Float) = 1
        _ShallowAlphaFactor("ShallowAlphaFactor",Float) = 1
        _ShallowColor("_ShallowColor",Color) = (1,1,1,1)
        
        _FoamTex("_FoamTex",2D) = "white"{}
        _FoamFade("_FoamFade",Float) = 1
        _FoamNoisePower("_FoamNoisePower",Float) = 1
        _FoamAlphaFactor("_FoamAlphaFactor",Float) = 1
        [hdr]_FoamColor("_FoamColor",Color) = (1,1,1,1)
        
        
        _WaveTex("_WaveTex",2D) = "white"{}
        _WaveScale("_WaveScale",Float) = 1
        _WaveColor("_WaveColor",Color) = (1,1,1,1)
        _WaveSpeed("_WaveSpeed",Float) = 1
        _WaveRange("_WaveRange",Float) = 1
        
        _CausticsTex("_CausticsTex",2D) = "white"{}
        _CausticsNoisePower("_CausticsNoisePower",Float) = 1
        _CausticsCol("_CausticsCol",Color) = (1,1,1,1)
        

        _GradientDir("GradientDir",Vector) = (1,1,1,1)
        
        _Noise("Noise",2D) = "white"{}
        
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" "RenderType" = "Opaque" }
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
        Pass
        {
            Name"Main"
            Tags{ "LightMode" = "UniversalForward"}
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag

            


            TEXTURE2D(_bumpMap);
            SAMPLER(sampler_bumpMap);

            TEXTURECUBE(_Reflection);
            SAMPLER(sampler_Reflection);

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_FoamTex);
            SAMPLER(sampler_FoamTex);

            TEXTURE2D(_WaveTex);
            SAMPLER(sampler_WaveTex);

            TEXTURE2D(_CausticsTex);
            SAMPLER(sampler_CausticsTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);

            
            float4 _BumpMap_ST;
            float2 _NormalScale;
            float4 _NormalUVSPeed;
            float4 _NormalTiling;

            half4 _WaterBottomColor;
            half4 _WaterTopColor;
            half4 _GradientDir;
            half4 _SeaBottomColor;
            half4 _SeaTopColor;
            half _Gloss;
            half _SpecularSmooth;
            half _SpecularThreshold;
            half4 _SpecularColor;
            half _Fresnelpow;
            half _FresnelStepMin;
            half _FresnelStepMax;
            half4 _ReflectionColor;
            half _ShallowFade;
            half4 _Color;
            half _ShallowAlphaFactor;
            half4 _ShallowColor;
            half _FoamFade;
            float4 _FoamTex_ST;
            float _FoamNoisePower;
            float _FoamAlphaFactor;
            half4 _FoamColor;
            float4 _WaveTex_ST;
            half _WaveScale;
            half _WaveSpeed;
            half _WaveRange;
            half4 _WaveColor;
            float4 _CausticsTex_ST;
            half _CausticsNoisePower;
            half4 _CausticsCol;

            
            struct Attribute
            {
                float2 uv : TEXCOORD0;
                float4 posOS : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
            };

            struct Varings
            {
                float4 posCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;

                float3 normalWS : TEXCOORD5;
                float4 posSS : TEXCOORD6;
                float3 posVS : TEXCOORD7;
            };


            half3 BlendNormals(half3 n1,half3 n2)
            {
                return normalize(half3(n1.xy + n2.xy,n1.z * n2.z));
            }
            
            
            
            Varings vert(Attribute IN)
            {
                Varings OUT = (Varings)0;
                VertexPositionInputs positionInput = GetVertexPositionInputs(IN.posOS.xyz);
                OUT.posCS = TransformObjectToHClip(IN.posOS);
                OUT.posWS = positionInput.positionWS;
                OUT.posVS = positionInput.positionVS;
                float3 viewDir = GetWorldSpaceViewDir(positionInput.positionWS);
                
                
                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normal,IN.tangent);
                float3 normal = normalInput.normalWS;
                float3 tangent = normalInput.tangentWS;
                float3 binormal = normalInput.bitangentWS;
                OUT.TtoW0 = float4(tangent.x,binormal.x,normal.x,viewDir.x);
                OUT.TtoW1 = float4(tangent.y,binormal.y,normal.y,viewDir.y);
                OUT.TtoW2 = float4(tangent.z,binormal.z,normal.z,viewDir.z);
                
                OUT.uv = IN.uv;

                OUT.normalWS = normal;
                OUT.posSS = ComputeScreenPos(OUT.posCS);
                

                return OUT;
                
            }

            half4 frag(Varings IN) : SV_Target
            {
                half3 viewDir = normalize(GetWorldSpaceViewDir(IN.posWS)) ;
                _GradientDir = normalize(_GradientDir);
                //用两个UV值采样水面增加层次感
                float2 normalUV1 = IN.posWS.xz;
                float3 CameraPos = GetCameraPositionWS();
                // float3 distance = length(CameraPos - IN.posWS);
                // normalUV1 *= 1/pow(2,distance * 0.01);
                
                float3 normalTex1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_bumpMap,sampler_bumpMap,normalUV1 * _NormalTiling.xy + _Time.x * _NormalUVSPeed.xy),_NormalScale);
                float3 normalTex2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_bumpMap,sampler_bumpMap,normalUV1 * _NormalTiling.zw + _Time.x * _NormalUVSPeed.zw),_NormalScale);
                //blendnormals
                half3 bump = BlendNormals(normalTex1,normalTex2);
                //切线空间转世界空间
                bump = normalize(half3(dot(bump,IN.TtoW0.xyz),dot(bump,IN.TtoW1.xyz),dot(bump,IN.TtoW2.xyz)));

                Light mainLight = GetMainLight();  
                half3 LightDir = normalize(mainLight.direction);
                half nDotL = dot(bump,LightDir);
                //half—lambert
                half halfDir = normalize(LightDir + viewDir)* 0.5 + 0.5;
                half nDotH = normalize(dot(bump,halfDir));
                half nDotV = normalize(dot(bump,viewDir));

                
                float3 diffuse = lerp(_WaterBottomColor.rgb * _WaterBottomColor.a, _WaterTopColor.rgb * _WaterTopColor.a,step(nDotL,0.9));
                //用一个向量和视角的均值控制渐变方向
                float iNDotV = saturate(dot(IN.normalWS,normalize(viewDir + _GradientDir)));
                
                diffuse = (iNDotV) * diffuse * 0.4 + diffuse * 0.6;
                
                float specRange = exp2(_Gloss * 10.0 + 1.0);
                float specTerm = pow(max(0,nDotH),specRange);
                specTerm = smoothstep(_SpecularThreshold - _SpecularSmooth,_SpecularThreshold + _SpecularSmooth,specTerm);

                float3 specular = _SpecularColor.rgb * _SpecularColor.a * specTerm;

                float fresnelTerm = pow(abs(1 - nDotV),_Fresnelpow);
                fresnelTerm = smoothstep(_FresnelStepMin,_FresnelStepMax,fresnelTerm);

                float3 relUVM = reflect(-viewDir,IN.normalWS);
                half4 rgbm = SAMPLE_TEXTURECUBE(_Reflection,sampler_Reflection,relUVM);
                
                half3 reflection = DecodeHDREnvironment(rgbm,unity_SpecCube0_HDR) * _ReflectionColor.rgb;
                half relfectionMask  = saturate(fresnelTerm * _ReflectionColor.a);
                half4 final;
                final.rgb = (diffuse + specular) * 0.8;
                final.rgb = lerp(final.rgb,reflection,relfectionMask);

                float sampleDepth = SampleSceneDepth(IN.posSS.xy/IN.posSS.w);
                float deltaDepth = LinearEyeDepth(sampleDepth,_ZBufferParams);
                float deltaDepthFoam = saturate((deltaDepth - IN.posCS.w)/_FoamFade);
                deltaDepth = saturate((deltaDepth - IN.posCS.w)/max(0.001,_ShallowFade));
                
                float depthMask = 1 - deltaDepth;
                
                final.rgb = lerp(final.rgb ,_ShallowColor,depthMask * bump.r) ;
                final.a = _Color.a * saturate(deltaDepth * _ShallowAlphaFactor);
                
                half foam = SAMPLE_TEXTURE2D(_FoamTex,sampler_FoamTex,IN.posWS.xz * _FoamTex_ST.xy + bump.xz * _FoamNoisePower).r;
                half foamMask = SAMPLE_TEXTURE2D(_FoamTex,sampler_FoamTex,IN.posWS.xz * _FoamTex_ST.zw + bump.xz * _FoamNoisePower).r;
                foamMask = saturate((1-saturate(foamMask * deltaDepthFoam * _FoamAlphaFactor))* foam * _FoamColor.a);
                half3 foamCol = _FoamColor.rgb;

                final.rgb = lerp(final.rgb,foamCol,foamMask);


                half waveNoise = SAMPLE_TEXTURE2D(_WaveTex,sampler_WaveTex,IN.posWS.xz * _WaveTex_ST.xy).r;
                half uvX = _WaveScale * deltaDepth + sin(_Time.y * _WaveSpeed) - _WaveRange * waveNoise;
                half wave = SAMPLE_TEXTURE2D(_WaveTex,sampler_WaveTex,float2(uvX,1)).r;
                half waveMask = saturate(waveNoise * wave * depthMask * _WaveColor.a);
                half3 waveCol = _WaveColor.rgb;

                final.rgb = lerp(final.rgb,waveCol,waveMask);

                float linearEyeDepth = LinearEyeDepth(sampleDepth,_ZBufferParams);
                float2 waterObjectVS = linearEyeDepth / (-IN.posVS.z) * IN.posVS.xy;
                float3 waterObjectWS = mul(UNITY_MATRIX_I_V,float4(waterObjectVS,-linearEyeDepth,1)).xyz;
                
                half3 caustics = SAMPLE_TEXTURE2D(_CausticsTex,sampler_CausticsTex,waterObjectWS.xz * _CausticsTex_ST.xy + bump.xz * _CausticsNoisePower);
                half3 causticsCol = caustics.rgb * _CausticsCol;
                final.rgb = lerp(final.rgb,_ShallowColor.rgb + causticsCol,depthMask);
                

                
                return final;
                // return float4(float2(floor(normalUV2.x * 10),floor(normalUV2.y * 10)).xxx,1);
                // return rotate1.xxxx;

                

                
            }
            
            
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
