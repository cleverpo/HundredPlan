Shader "Quik/Shader_ViewSpace"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float4 posVS  : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posVS = mul(UNITY_MATRIX_MV, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.posVS;
            }
            ENDCG
        }
    }
}
