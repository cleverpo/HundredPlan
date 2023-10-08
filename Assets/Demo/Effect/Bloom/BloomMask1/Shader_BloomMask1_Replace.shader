Shader "Quik/Effect/Bloom/BloomMask1_Replace"
{
    SubShader
    {
        Tags { "RenderType" = "Bloom" }
        Pass
        {
            CGPROGRAM
			#include "UnityCG.cginc"
            #pragma vertex vert_img
            #pragma fragment frag
            fixed4 frag() : COLOR
            {
                return fixed4(0.0, 0.0, 0.0, 0.0);
            }
            ENDCG

        }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
			#include "UnityCG.cginc"
            #pragma vertex vert_img
            #pragma fragment frag
            fixed4 frag() : COLOR
            {
                return fixed4(1.0, 1.0, 1.0, 1.0);
            }
            ENDCG

        }
    }
}
