Shader "Quik/StencilTest/Mask"
{
    Properties
    {
        _MaskID("Mask Id", Int) = 0
    }
    SubShader
    {
        Tags{
            "RenderType"="Opaque"
            "Queue"="Geometry+2"
        }
        Stencil {
            Ref [_MaskID]
            Comp Always
            Pass Replace
        }
        ZWrite off
        Pass{
            ColorMask 0
			// CGINCLUDE
            //     struct appdata {
            //         float4 vertex : POSITION;
            //     };
            //     struct v2f {
            //         float4 pos : SV_POSITION;
            //     };

            
            //     v2f vert(appdata v) {
            //         v2f o;
            //         o.pos = UnityObjectToClipPos(v.vertex);
            //         return o;
            //     }
            //     half4 frag(v2f i) : SV_Target{
            //         return half4(1,1,1,1);
            //     }
            // ENDCG
        }
    }
}
