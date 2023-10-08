Shader "Unlit/Shader_Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                
                float3 v1 = float3(0.0, 0.1, 0.2);
                float3 v2 = float3(0.3, 0.4, 0.5);
                float3 v3 = float3(0.0, 0.0, 0.0);
                float3x3 m1 = float3x3(
                    v1.x, v1.y, v1.z,
                    v2.x, v2.y, v2.z,
                    v3.x, v3.y, v3.z
                );
                
                float3x3 m2 = float3x3(
                    v1,v2,v3
                );
                float3x3 m3 = transpose(m2);
                
                fixed4 col = fixed4(m3[0][1], 0.0, 0.0, 1.0);
                return col;
            }
            ENDCG

        }
    }
}
