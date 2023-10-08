Shader "Quik/Effect/BloomMask1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _BloomTex ("Bloom Texture", 2D) = "black" { }
        _MaskTex("Mask Texture", 2D) = "white" {}

        _LuminanceThreshold ("Luminance Threshold", Float) = 0.5

        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex; float4 _MainTex_ST;
        half4 _MainTex_TexelSize;
        
        sampler2D _BloomTex; float4 _BloomTex_ST;
        sampler2D _MaskTex; float4 _MaskTex_ST;

        float _LuminanceThreshold;
        float _BlurSize;

        struct v2f_extractBright
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };
        
        struct v2f_combine
        {
            float4 pos : SV_POSITION;
            float4 uv : TEXCOORD0;
        };

        fixed luminance(fixed4 color)
        {
            return color.r * 0.2125 + color.g * 0.7154 + color.b * 0.0721;
        };

        v2f_extractBright vertExtractBright(appdata_img v)
        {
            v2f_extractBright o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            
            return o;
        };

        fixed4 fragExtractBright(v2f_extractBright i) : SV_TARGET
        {
            fixed4 color = tex2D(_MainTex, i.uv);
            fixed value = clamp(luminance(color) - _LuminanceThreshold, 0.0, 1.0);

            return color * value;
        };

        fixed4 maskColor(fixed4 src1, fixed4 src2, fixed4 mask){
            return lerp(src1, src2, 1.0 - mask.a);
        };

        v2f_combine vertCombine(appdata_img v)
        {
            v2f_combine o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = TRANSFORM_TEX(v.vertex, _MainTex);
            o.uv.zw = TRANSFORM_TEX(v.vertex, _BloomTex);

            #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0.0)
                    o.uv.w = 1.0 - o.uv.w;
            #endif
            return o;
        };

        fixed4 fragCombine(v2f_combine i) : SV_TARGET
        {
            fixed4 color = tex2D(_MainTex, i.uv.xy);
            fixed4 bloomColor = tex2D(_BloomTex, i.uv.zw);
            fixed4 mask = tex2D(_MaskTex, i.uv.xy);
            fixed4 result = color + bloomColor;
            return maskColor(color, result, mask);
            // return result;
        };


        ENDCG

        Pass
        {
            CGPROGRAM

            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG

        }

        UsePass "Quik/Effect/Blur/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"

        UsePass "Quik/Effect/Blur/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

        Pass
        {
            CGPROGRAM

            #pragma vertex vertCombine
            #pragma fragment fragCombine
            ENDCG

        }
    }
}
