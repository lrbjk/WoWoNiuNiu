Shader "Custom/DrawTexCode"
{
    Properties
    {
        _SourceUV("SouceUV",Vector) = (1,1,1,1)
        _SourceTex("SourceTex",2D) = "white"{}
        _MainTex("MainTex",2D) = "white"{}
        _Noise("Noise",2D) = "white"{}
        _Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"

       Pass
       {
           Tags{"LightingMode" = "UniversalForward"}
           
           
           HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
       
           #pragma vertex vert
           #pragma fragment frag
           #pragma target 4.0

            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_SourceTex);
            SAMPLER(sampler_SourceTex);

            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);

            float4 _SourceUV;
            half3 _Color;
       
           

           struct Attribute
           {
               float4 pos : POSITION;
               float2 uv : TEXCOORD0;
           };

            struct Varyings
            {
                float4 posCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 posWS : TEXCOORD1;
            };

            Varyings vert (Attribute IN)
            {
                Varyings OUT = (Varyings)0;
                
                float2 uv = IN.uv;
                OUT.uv.xy = uv;
                OUT.uv.zw = _SourceUV.zw * uv + _SourceUV.xy;
                
                
                
                VertexPositionInputs vpi = GetVertexPositionInputs(IN.pos);
                OUT.posCS = vpi.positionCS;
                OUT.posWS = vpi.positionWS;
                

                return OUT;
                
            }

            float4 frag(Varyings IN) : SV_Target
            {
                half main = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex ,IN.uv.xy).r * smoothstep(0,0.5,pow((1-distance(IN.uv,float2(0.5,0.5)))* 0.8,3));

                half noise = (SAMPLE_TEXTURE2D(_Noise,sampler_Noise,IN.posWS * 0.01) + 0.1) * 0.5;

                main = step(noise,main);
                
                half final = max(main,SAMPLE_TEXTURE2D(_SourceTex,sampler_SourceTex,IN.uv.zw).r) * _Color;
                
                return float4(final.xxx,1);
            }

           




           
           ENDHLSL
       }
    }
    FallBack "Diffuse"
}
