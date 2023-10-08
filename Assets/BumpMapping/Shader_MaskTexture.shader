Shader "Quik/BumpMapping/Shader_MaskTexture"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _NormalMap("NormalMap", 2D) = "bump" {}
        _NormalScale("Normal Scale", Float) = 1.0
        _Diffuse("Diffuse", Color) = (1,1,1,1)

        _SpecularMaskTex("MaskTex", 2D) = "white"{}
        _SpecularMaskScale("SpecularMaskScale", Float) = 1.0
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
                
                sampler2D _MainTex; float4 _MainTex_ST;
                sampler2D _NormalMap; float4 _NormalMap_ST;
                
                float _NormalScale;
                
                float4 _Diffuse;

                sampler2D _SpecularMaskTex; float4 _SpecularMaskTex_ST;
                float _SpecularMaskScale;
                float4 _Specular;
                float _Gloss;
                
                struct a2v{
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                    float4 tangent: TANGENT;
                    float4 texCoord: TEXCOORD0;
                };

                struct v2f{
                    float4 pos: SV_POSITION;
                    float2 uv: TEXCOORD0;
                    float3 worldNormal: TEXCOORD1;
                    float3 worldPos: TEXCOORD2;
                    float3 worldTangent: TEXCOORD3;
                    float3 worldBiTangent: TEXCOORD4;
                };

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.texCoord.xy;
                    o.worldPos = UnityObjectToWorldDir(v.vertex).xyz;
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldTangent = UnityObjectToWorldDir(v.tangent).xyz;
                    o.worldBiTangent = cross(o.worldTangent, o.worldNormal) * v.tangent.w;

                    return o;
                };

                float4 frag(v2f i): SV_Target{
                    float3 color;

                    float3 worldNormal = normalize(i.worldNormal);
                    float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                    float3 worldTangent = normalize(i.worldTangent);
                    float3 worldBiTangent = normalize(i.worldBiTangent);
                    float3x3 tangentTranform = float3x3(worldTangent, worldBiTangent, worldNormal);
                    float3 localNormal = UnpackNormal(tex2D(_NormalMap, TRANSFORM_TEX(i.uv, _NormalMap)));
                    localNormal = normalize(mul(localNormal, tangentTranform));

                    float3 finalNormal = lerp(worldNormal, localNormal, _NormalScale);

                    float3 albedo = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex)).rgb;

                    float nDotL = saturate(dot(finalNormal, worldLightDir));
                    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo.rgb;

                    float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * albedo * nDotL;

                    float3 halfDir = normalize(worldLightDir + worldViewDir);
                    float specularMask = tex2D(_SpecularMaskTex, TRANSFORM_TEX(i.uv, _SpecularMaskTex)).r * _SpecularMaskScale;
                    float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(finalNormal, halfDir)), _Gloss) * specularMask;

                    color = ambient + diffuse + specular;

                    return float4(color, 1.0);
                };

            ENDCG
        }
    }
    FallBack "Diffuse"
}
