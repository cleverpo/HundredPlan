Shader "Quik/Shader_NDCSpace"
{
    Properties
    {
        [Toggle]_UseScreenSpace ("Use Screen Space", int) = 1
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

            bool _UseScreenSpace;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 posSS : TEXCOORD1;
                float4 posNDC : TEXCOORD2;
            };

            float4 ComputeNDCPos(float4 posCS)
            {
                float4 posNDC;
                posNDC = float4(posCS.x, posCS.y * _ProjectionParams.x, posCS.z, posCS.w) / posCS.w;
                return posNDC;
            };

            float4 ComputeNDCPosWithSSPos(float4 posSS)
            {
                float4 posNDC;
                posNDC.xy = (posSS.xy / posSS.w) * 2.0 - 1.0;
                posNDC.z = posSS.z / posSS.w;
                posNDC.w = 1.0;
                return posNDC;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                if (_UseScreenSpace)
                {
                    o.posSS = ComputeScreenPos(o.pos);
                }
                else
                {
                    o.posNDC = ComputeNDCPos(o.pos);
                }
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                if (_UseScreenSpace)
                {
                    i.posNDC = ComputeNDCPosWithSSPos(i.posSS);
                }
                return i.posNDC;
            }
            ENDCG

        }
    }
}
