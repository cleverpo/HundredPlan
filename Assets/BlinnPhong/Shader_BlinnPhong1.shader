Shader "Quik/Shader_BlinnPhong1"
{
    Properties {
        _MainTex("MainTex", 2D) = "white" {}
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("Gloss", Range(1.0, 255)) = 8.0
        
        _NormalTex("NormalTex", 2D) = "white" {}        //法线贴图
		_LocalNormalSlid("LocalNormal",Range(0,1)) = 0  //控制法线贴图的作用

        _EnvCubeMap("EnvCubeMap", Cube) = "" {}         //环境贴图
        _EnvMipScale("EnvMipScale", Range(0,10)) = 0    //环境贴图mip
		_EnvScale("EnvScale",Range(0,1)) = 1            //环境贴图的作用
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

                sampler2D _MainTex; float4 _MainTex_ST;

                sampler2D _NormalTex; float4 _NormalTex_ST;
                fixed _LocalNormalSlid;

                samplerCUBE _EnvCubeMap;
                float _EnvMipScale;
                float _EnvScale;

                struct a2v {
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                    float4 tangent: TANGENT;
                    float2 texCoord0: TEXCOORD0;
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float2 uv0: TEXCOORD0;            //纹理uv

                    float3 worldNormal: NORMAL;      //世界空间 法线

                    float3 worldPos: TEXCOORD1;         //世界空间 顶点位置
                    float3 worldTangent: TEXCOORD2;      //世界空间 切线
                    float3 worldBiTangent: TEXCOORD3;    //世界空间 副切线
                };

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv0 = v.texCoord0;

                    o.worldNormal = UnityObjectToWorldNormal(v.normal);

                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.worldTangent = mul(unity_ObjectToWorld, v.tangent).xyz;
                    o.worldBiTangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;

                    return o;
                };

                fixed4 frag(v2f i): SV_Target {
                    fixed3 color = fixed3(0.0, 0.0, 0.0);
                    fixed4 mainTex = tex2D(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex));

                    //法线归一化
                    fixed3 worldNormal = normalize(i.worldNormal);
                    //光方向归一化
                    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    //视角方向
                    fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                    //切线空间转换矩阵
                    float3x3 tangentTransform = float3x3(i.worldTangent, i.worldBiTangent, i.worldNormal);
                    //获取法线贴图, UnpackNormal是解压缩
                    float3 localNormal = UnpackNormal(tex2D(_NormalTex, TRANSFORM_TEX(i.uv0, _NormalTex)));
                    //转换到世界空间，这里左乘是因为需要从切线到世界，就是用切线转换矩阵的逆矩阵（即转置矩阵
                    fixed3 worldLocalNormal = normalize(mul(localNormal.rgb, tangentTransform));

                    //最终的法线
                    fixed3 finalNormal = lerp(worldNormal, worldLocalNormal, _LocalNormalSlid);

                    //法线*光线
                    fixed3 nDotL = saturate(dot(finalNormal, worldLightDir));

                    //环境光
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.rgb * mainTex.rgb;

                    //漫反射 trick: 兰伯特因为暗部是黑色，过渡不自然，所以通过一个插值得到最终的diffuse，前半段为暗部颜色，后半段为亮部颜色
                    // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * mainTex.rgb * nDotL;
                    fixed3 diffuse = lerp(ambient.rgb * _Diffuse.rgb  * mainTex.rgb, _LightColor0.rgb * _Diffuse.rgb * mainTex.rgb, nDotL);

                    //高光反射
				    //================Phong模型================
                    // fixed3 reflectDir = normalize(reflect(-worldLightDir, finalNormal));
                    // fixed3 rDotV = saturate(dot(reflectDir, worldViewDir));
                    // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(rDotV, _Gloss);
                    
				    //================Blinn-Phong模型================
                    fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                    fixed3 hDotN = saturate(dot(halfDir, finalNormal));
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(hDotN, _Gloss);
                    //trick: 高光时候，只有4%机率受漫反射影响
				    // specular = lerp(diffuse * specular, specular, _Gloss / 255);
                    color = ambient + diffuse + specular;

                    //环境贴图
                    // fixed3 worldRef = normalize(reflect(-worldViewDir, finalNormal));
                    // fixed4 reflcol = texCUBElod(_EnvCubeMap, float4(worldRef, (255 - _Gloss)/255 * 8)) *_EnvScale;

                    // color = reflcol.rgb + diffuse + specular;

                    return fixed4(color, 1.0);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
