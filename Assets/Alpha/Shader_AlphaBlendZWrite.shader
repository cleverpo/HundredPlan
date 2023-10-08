Shader "Quik/Alpha/AlphaBlendZWrite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale("Alpha", Range(0.0, 1)) = 0.5
    }
    SubShader
    {
        Tags{
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
        }
        //写入深度
        Pass
        {
            ZWrite on
            ColorMask 0
        }
        Pass
        {
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            sampler2D _MainTex; float4 _MainTex_ST;
            float _AlphaScale;

            struct a2v{
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 texCoord0: TEXCOORD0;
            };
            
            struct v2f{
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float3 worldNormal: TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texCoord0;
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            };

            float4 frag(v2f i): SV_Target{
                float3 color = float3(1.0, 1.0, 1.0);
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float NdotL = saturate(dot(worldNormal, worldLightDir));

                float4 texColor = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));
                float3 albedo =  texColor.rgb;

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                float3 diffuse = _LightColor0.rgb * albedo * NdotL;

                color = ambient + diffuse;

                return float4(color, texColor.a * _AlphaScale);
            };

            ENDCG
        }
    }
    Fallback "Diffuse"
}
