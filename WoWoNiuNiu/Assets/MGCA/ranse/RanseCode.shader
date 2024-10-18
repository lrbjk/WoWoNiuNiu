Shader "Unlit/RanseCode"
{
    Properties
    {
        _MainTex("Main",2D) = "white"{}
        _baseColor("Color",Color) = (1,1,1,1)
        _woniu_position("woniu position",Vector) = (1,1,1)
        _startPoint("Start point",Vector) = (0,0,0)
        _NoiseMap("Noise",2D) = "black"{}
        _NoiseScale("Noise UV Scale",Float) = 1
        _shiStep("shi的范围",Float) = 1
        
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" "RenderType" = "Opaque"}
        
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
        
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                    
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _baseColor;
            float4 _NoiseMap_ST;
        CBUFFER_END
        ENDHLSL


        Pass
        {
            Name"Main"
            Tags{ "LightMode" = "UniversalForward"}
            Cull Off
            HLSLPROGRAM
            
            
            #pragma vertex vert
            #pragma fragment frag
            
            

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Varings
            {
                float4 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 temp : TEXCOORD4;
                
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

            float3 _woniu_position;
            float3 _startPoint;
            half _NoiseScale;
            half _shiStep;
            
            
            Varings vert (Attributes IN)
            {
                Varings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.worldPosition = positionInputs.positionWS;
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;

                VertexNormalInputs vertex_normal_inputs = GetVertexNormalInputs(IN.normal);
                OUT.normalWS = vertex_normal_inputs.normalWS;

                OUT.uv.xy = TRANSFORM_TEX(IN.uv,_MainTex);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv,_NoiseMap);

                
                
                return OUT;
            }

            half4 frag (Varings IN) : SV_Target
            {
                half tempx = lerp(distance(IN.worldPosition,_woniu_position),distance(IN.worldPosition,float3(IN.worldPosition.x,_woniu_position.yz)),step(IN.worldPosition.x,_woniu_position.x) * step(_startPoint.x,IN.worldPosition.x));
                half2 temp1 = (IN.worldPosition - mul(unity_ObjectToWorld,half3(0,0,0)).xyz).xz * _NoiseScale;
                half NoiseColor = SAMPLE_TEXTURE2D(_NoiseMap,sampler_NoiseMap,temp1).r;
                half final1 = step(tempx - NoiseColor,_shiStep ) * clamp(IN.normalWS.y,0,1);
                
                return final1 * _baseColor;
            }
            ENDHLSL
        }
    }
            FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
