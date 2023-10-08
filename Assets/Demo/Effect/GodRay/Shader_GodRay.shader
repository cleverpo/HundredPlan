Shader "Unlit/Shader_GodRay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex; float4 _MainTex_ST;
        sampler2D _BlurTex; float4 _BlurTex_ST;

        uniform float _LuminanceThreshold;
        uniform float _LightIntensity;
        uniform float4 _LightColor;

        struct v2f_ExtractBright
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };
        
        struct v2f_Combine
        {
            float4 pos : SV_POSITION;
            float4 uv : TEXCOORD0;
        };

        v2f_ExtractBright vertExtractBright(appdata_img input)
        {
            v2f_ExtractBright o;
            o.pos = UnityObjectToClipPos(input.vertex);
            o.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
            return o;
        };

        fixed4 fragExtractBright(v2f_ExtractBright input): SV_TARGET
        {
            fixed4 texColor = tex2D(_MainTex, input.uv);
            float value = clamp(LinearRgbToLuminance(texColor.rgb) - _LuminanceThreshold, 0.0, 1.0);

            return texColor * value;
        };

        v2f_Combine vertCombine(appdata_img input)
        {
            v2f_Combine o;
            o.pos = UnityObjectToClipPos(input.vertex);
            o.uv.xy = TRANSFORM_TEX(input.texcoord, _MainTex);
            o.uv.zw = TRANSFORM_TEX(input.texcoord, _BlurTex);
            return o;
        };

        fixed4 fragCombine(v2f_Combine input): SV_TARGET
        {
            fixed4 texColor = tex2D(_MainTex, input.uv.xy);
            fixed4 blurColor = tex2D(_BlurTex, input.uv.zw);

            return texColor + blurColor * _LightIntensity * _LightColor;
        };
        
        ENDCG

        Pass { 
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }

        UsePass "Quik/Effect/Blur/RadialBlur/RADIAL_BLUR"

        Pass {
            CGPROGRAM
            #pragma vertex vertCombine
            #pragma fragment fragCombine
            ENDCG
        }
    }
}
