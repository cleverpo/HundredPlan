// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Quik/Shadow/Shader_ForwardRendering"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0 )
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0 )
        _Gloss("Gloss", Range(8.0, 255)) = 10.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos: TEXCOORD1;
                float3 worldNormal: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 halfDir = normalize(lightDir + viewDir);
                float nDotL = saturate(dot(worldNormal, lightDir));
                float nDotH = saturate(dot(worldNormal, halfDir));

                // sample the texture
                fixed4 albedo = tex2D(_MainTex, i.uv);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb * albedo.rgb * nDotL;
                fixed3 specular = _LightColor0.xyz * _Specular.rgb * pow(nDotH, _Gloss);

                fixed atten = 1.0;

                return fixed4(ambient + (diffuse + specular)*atten, 1.0);
            }
            ENDCG
        }
        
        Pass {
            Tags {"LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdadd

                #include "UnityCG.cginc"
                #include "Lighting.cginc"
                #include "AutoLight.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float3 normal: NORMAL;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float4 worldPos: TEXCOORD1;
                    float3 worldNormal: TEXCOORD2;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                
                float4 _Diffuse;
                float4 _Specular;
                float _Gloss;

                v2f vert (appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    return o;
                }

                fixed4 frag (v2f i) : SV_Target
                {
                    fixed3 worldNormal = normalize(i.worldNormal);
                    fixed3 worldPos = i.worldPos;
                    #ifdef USING_DIRECTIONAL_LIGHT
                        fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    #else
                        fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos.xyz);
                    #endif
                    fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
                    fixed3 halfDir = normalize(lightDir + viewDir);
                    float nDotL = saturate(dot(worldNormal, lightDir));
                    float nDotH = saturate(dot(worldNormal, halfDir));

                    fixed4 albedo = tex2D(_MainTex, i.uv);
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                    fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb * albedo.rgb * nDotL;
                    fixed3 specular = _LightColor0.xyz * _Specular.rgb * pow(nDotH, _Gloss);

                    #ifdef USING_DIRECTIONAL_LIGHT
                        fixed atten = 1.0;
                    #else
                        float3 lightCoord = mul(unity_WorldToLight, float4(worldPos, 1.0)).xyz;
                        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #endif

                    return fixed4(ambient + (diffuse + specular)*atten, 1.0);
                }
            ENDCG
        }
    }

    Fallback "Specular"
}
