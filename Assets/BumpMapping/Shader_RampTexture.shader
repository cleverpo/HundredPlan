Shader "Quik/BumpMapping/Shader_RampTexture"
{
    Properties
    {
        _RampTex("RampTex", 2D) = "white" {}
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass{
            Tags{
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"
                
                sampler2D _RampTex; float4 _RampTex_ST;
                float4 _Diffuse;
                float4 _Specular;
                float _Gloss;
                
                struct a2v{
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                    float4 texCoord: TEXCOORD0;
                };

                struct v2f{
                    float4 pos: SV_POSITION;
                    float3 worldNormal: TEXCOORD0;
                    float3 worldPos: TEXCOORD1;
                };

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.worldPos = UnityObjectToWorldDir(v.vertex).xyz;
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);

                    return o;
                };

                float4 frag(v2f i): SV_Target{
                    float3 color;

                    float3 worldNormal = normalize(i.worldNormal);
                    float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                    float halfLambert = 0.5 * dot(worldLightDir, worldNormal) + 0.5;
                    float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * tex2D(_RampTex, TRANSFORM_TEX(float2(halfLambert, halfLambert), _RampTex)).rgb;

                    float3 halfDir = normalize(worldLightDir + worldViewDir);
                    float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                    color = ambient + diffuse + specular;

                    return float4(color, 1.0);
                };

            ENDCG
        }
    }
    FallBack "Diffuse"
}
