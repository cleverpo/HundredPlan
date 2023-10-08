Shader "Quik/HDR/Shader_HDR"
{
    Properties {
        _MainTex("MainTex", 2D) = "white" {}
        [HDR] _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
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

                sampler2D _MainTex; float4 _MainTex_ST;

                fixed4 _Diffuse;
                fixed4 _Specular;
                float _Gloss;

                struct a2v {
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                    float2 texCoord: TEXCOORD0;
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float2 uv: TEXCOORD0;
                    float3 worldNormal: TEXCOORD1;      //世界空间 法线
                    float3 worldPos: TEXCOORD2;         //世界空间 顶点位置
                };

                fixed3 gamma2Linear(fixed3 color){
                    return fixed3(pow(color.rgb, 2.2));
                };

                fixed3 linear2Gamma(fixed3 color){
                    return fixed3(pow(color.rgb, 1/2.2));
                };

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.texCoord;
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
                    
                    fixed3 albedo = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex)).rgb;
                    // albedo = gamma2Linear(albedo);
                    albedo = GammaToLinearSpace(albedo);
                    
                    //环境光
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                    //漫反射
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

                    //高光反射

                    //phong模型
                    // fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                    // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, worldViewDir)), _Gloss);
                    
                    //blinn-phong模型
                    fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                    fixed hDotN = saturate(dot(worldNormal, halfDir));
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(hDotN, _Gloss);

                    color = ambient + diffuse + specular;

                    // color = linear2Gamma(color);
                    color = LinearToGammaSpace(color);

                    return fixed4(color, 1.0);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
