Shader "Quik/Forward"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }

        _Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(1.0, 255)) = 8.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Diffuse;

            float4 _Specular;
            float _Gloss;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldPos = i.worldPos;
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
                float3 halfDir = normalize(worldLightDir + viewDir);
                float nDotL = saturate(dot(worldNormal, worldLightDir));
                float hDotN = saturate(dot(worldNormal, halfDir));

                float atten = 1.0;
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * albedo.rgb * nDotL;

                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(hDotN, _Gloss);

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG

        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One

            CGPROGRAM

            #pragma multi_compile_fwdadd
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Diffuse;

            float4 _Specular;
            float _Gloss;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float3 worldNormal = normalize(i.worldNormal);
                float3 worldPos = i.worldPos;
                #ifdef USING_DIRECTIONAL_LIGHT
                    float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);
                #endif
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
                float3 halfDir = normalize(worldLightDir + viewDir);
                float nDotL = saturate(dot(worldNormal, worldLightDir));
                float hDotN = saturate(dot(worldNormal, halfDir));

                #ifdef USING_DIRECTIONAL_LIGHT
                    float atten = 1.0;
                #else
                    float3 lightColor = mul(unity_WorldToLight, float4(worldPos, 1.0)).xyz;
                    float atten = tex2D(_LightTexture0, dot(lightColor, lightColor).rr).UNITY_ATTEN_CHANNEL;
                #endif
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * albedo.rgb * nDotL;

                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(hDotN, _Gloss);

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG

        }
    }
}
