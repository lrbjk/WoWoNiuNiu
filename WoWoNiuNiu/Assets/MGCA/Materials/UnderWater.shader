Shader"UnderWater"
{
    Properties
    {
        
        
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" "RenderType" = "Opaque" }
        
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
        
        Pass
        {
            
             Tags{"LightingMode" = "UniversalForward"}
             
             HLSLPROGRAM
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

             #pragma target 4.5
             #pragma vertex vert
             #pragma fragment frag

             float3 _Points[4];
             float _Depth;


             struct Attributes
             {
                 float4 vertex : POSITION;
                 float2 texcoord : TEXCOORD0; 
             };
             
             struct Varyings
             {
                 float4 pos : SV_POSITION;
                 float2 uv : TEXCOORD0;
             };

             Varyings vert(Attributes IN)
             {
                 Varyings OUT;
                 VertexPositionInputs vpi = GetVertexPositionInputs(IN.vertex);
                 OUT.pos = vpi.positionCS;

                 OUT.uv = IN.texcoord;
                 
                 return OUT;
             }

             half4 frag(Varyings IN) : SV_Target
             {
                 float3 worldPos = lerp(lerp(_Points[0],_Points[1],IN.uv.x),lerp(_Points[2],_Points[3],IN.uv.x),IN.uv.y);

                 float depth = worldPos.y - _Depth;

                 return depth.xxxx;
                 
             }
             
            
             ENDHLSL
        }
    }
    Fallback "Diffuse"
}