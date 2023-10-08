Shader "Quik/Shader_ClipSpace"
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
                float4 posCS  : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.posCS = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.posCS;
            }
            ENDCG
        }
    }
}
