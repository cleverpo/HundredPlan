Shader "Quik/Effect/Blur/RadialBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Cull Off
        Lighting Off

        Tags { "RenderType" = "Opaque" }

        CGINCLUDE

        #define BLUR_SAMPLE 6        
        #include "UnityCG.cginc"

        sampler2D _MainTex; float4 _MainTex_ST;

        uniform float2 _BlurCenter;
        uniform float _BlurFactor;

        struct v2f_radialBlur
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float2 blurDir: TEXCOORD1;
        };

        v2f_radialBlur vertRadialBlur(appdata_img input)
        {
            v2f_radialBlur o;
            o.pos = UnityObjectToClipPos(input.vertex);
            o.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
            o.blurDir = _BlurFactor * (_BlurCenter.xy - o.uv);
            return o;
        };

        fixed4 fragRadialBlur(v2f_radialBlur i) : SV_TARGET
        {
            float4 sum = tex2D(_MainTex, i.uv);
            for(int it = 1; it < BLUR_SAMPLE; it++){
                sum += tex2D(_MainTex, i.uv + i.blurDir * it);
            }
            
            sum /= BLUR_SAMPLE;

            return sum;
        };
        
        ENDCG

        Pass
        {
            NAME "RADIAL_BLUR"

            CGPROGRAM
            #pragma vertex vertRadialBlur
            #pragma fragment fragRadialBlur
            ENDCG
        }
    }
}
