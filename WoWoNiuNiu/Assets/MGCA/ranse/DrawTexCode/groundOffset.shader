Shader "groundOffset"
{
    Properties
    {
        _MainTex("Main",2D) = "white"{}
        _width("width",Vector) = (1,1,1)
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
            
            float4 _SourceUV;
            float2 _width;
       
           

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
                OUT.posWS = vpi.positionWS;

                float offset = tex2Dlod(sampler_MainTex,float4(vpi.positionWS.xz + _width * 0.5f,0.0,0.0));

                OUT.posWS.y += offset;
                OUT.posCS = mul(unity_WorldToCamera,OUT.posWS);
                

                return OUT;
                
            }

            float4 frag(Varyings IN) : SV_Target
            {
                
                return float4(1,1,1,1);
            }

           




           
           ENDHLSL
       }
    }
    FallBack "Diffuse"
}
