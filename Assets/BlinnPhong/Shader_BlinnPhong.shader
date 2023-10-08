Shader "Quik/Shader_BlinnPhong"
{
    Properties {
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("Gloss", Range(1.0, 255)) = 8.0
    }
    SubShader {
        Pass {
            Tags {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"

                fixed4 _Diffuse;
                fixed4 _Specular;
                float _Gloss;

                struct a2v {
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float3 worldNormal: TEXCOORD0;      //世界空间 法线
                    float3 worldPos: TEXCOORD1;         //世界空间 顶点位置
                };

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    return o;
                };

                fixed4 frag(v2f i): SV_Target {
                    fixed3 color = fixed3(0.0, 0.0, 0.0);

                    //法线归一化
                    fixed3 worldNormal = normalize(i.worldNormal);
                    //光方向归一化
                    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    //视角方向
                    fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                    
                    //环境光
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                    //漫反射
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                    //高光反射

                    //phong模型
                    // fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                    // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, worldViewDir)), _Gloss);
                    
                    //blinn-phong模型
                    fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                    fixed hDotN = saturate(dot(worldNormal, halfDir));
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(hDotN, _Gloss);

                    color = ambient + diffuse + specular;

                    return fixed4(color, 1.0);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
