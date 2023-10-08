Shader "Quik/AO/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;

        sampler2D _CameraDepthNormalsTexture;
        
        v2f_img vert(appdata_img input)
        {
            v2f_img o;
            o.pos = UnityObjectToClipPos(input.vertex);
            o.uv = input.texcoord;
            #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0.0)
                {
                    o.uv.y = 1.0 - o.uv.y;
                }
            #endif
            
            return o;
        };

        fixed4 frag(v2f_img input) : SV_TARGET {
            float4 depthNormal = tex2D(_CameraDepthNormalsTexture, input.uv);
            float depth;
            float3 normal;
            
            DecodeDepthNormal(depthNormal, depth, normal);

            return fixed4(depth, depth, depth, 1.0);
        };
        
        ENDCG

        Pass { 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
