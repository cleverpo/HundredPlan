Shader "Unlit/Shader_Toon"
{
    Properties
    {
        [Header(Main)]
        _Tint ("Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" { }

        [Header(Ambient)]
        [HDR]_AmbientColor ("Ambient Color", Color) = (0.4, 0.4, 0.4, 1.0)
        
        [Header(Specular)]
        [HDR]_SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularGloss ("Specular Gloss", Range(1.0, 255)) = 8.0

        [Header(Rim)]
        [HDR]_RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimAmount ("Rim Amount", Range(0, 1)) = 0.716
        _RimThreshold ("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" "PassFlags" = "OnlyDirectional" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : NORMAL;
                float3 worldViewDir : TEXCOORD1;
            };

            fixed4 _Tint;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _AmbientColor;

            float4 _SpecularColor;
            float _SpecularGloss;

            float4 _RimColor;
            float _RimAmount;
            float _RimThreshold;

            v2f vert(VertexInput v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 albedo = tex2D(_MainTex, i.uv);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(i.worldViewDir);

                float nDotL = saturate(dot(worldNormal, worldLightDir));
                float rDotN = saturate(dot(normalize(worldViewDir + worldLightDir), worldNormal));
                float vDotN = dot(worldViewDir, worldNormal);

                fixed4 ambient = _AmbientColor;
                
                float lightIntensity = smoothstep(0, 0.01, nDotL);
                float4 diffuse = _LightColor0 * lightIntensity;

                float specularIntensity = pow(rDotN, pow(_SpecularGloss, 2)) * lightIntensity;
                float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
                float4 specular = _SpecularColor * specularIntensitySmooth;
                
                // float rimIntensity = (1.0 - vDotN) * nDotL;
                // float rimIntensitySmooth = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
                // float4 rim = rimIntensitySmooth * _RimColor;
                
                float rimDot = 1 - dot(worldViewDir, worldNormal);
                float rimIntensity = rimDot * pow(nDotL, _RimThreshold);
                rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
                float4 rim = rimIntensity * _RimColor;


                return _Tint * albedo * (ambient + diffuse + specular + rim);
            }
            ENDCG

        }
    }
}
