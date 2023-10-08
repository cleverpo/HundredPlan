Shader "Quik/BumpMapping/Shader_NormalMapping"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white" {}

        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)   //漫反射

        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0) //高光
        _Gloss("Gloss", Range(1.0, 255)) = 8.0              //光泽度

        _NormalMap("Normal Map", 2D) = "white"{}            //法线贴图
        _NormalMapScale("Normal Map Scale", Range(0.0, 1)) = 1 //法线贴图的强度
    }
    SubShader
    {
        Pass{
            Tags {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"

                sampler _MainTex; float4 _MainTex_ST;
                sampler _NormalMap; float4 _NormalMap_ST;

                float4 _Diffuse;

                float4 _Specular;
                float _Gloss;

                float _NormalMapScale;

                struct a2v {
                    float4 vertex: POSITION;
                    float4 texCoord0: TEXCOORD0;
                    float3 normal: NORMAL;          //法线
                    float4 tangent: TANGENT;        //切线
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float4 uv0: TEXCOORD0;

                    float3 worldPos: TEXCOORD1;
                    float3 worldNormal: TEXCOORD2;

                    float3 worldTangent: TEXCOORD3;
                    float3 worldBiTangent: TEXCOORD4;
                };
                
                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv0.xy = v.texCoord0.xy;
				    o.uv0.zw = v.texCoord0.xy;

                    o.worldPos = UnityObjectToWorldDir(v.vertex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);

                    o.worldTangent = UnityObjectToWorldDir(v.tangent).xyz;
                    o.worldBiTangent = cross(o.worldTangent, o.worldNormal) * v.tangent.w;
                    return o;
                }

                float4 frag(v2f i): SV_Target {
                    float3 color = float3(1.0, 1.0, 1.0);
                    
                    //normal
                    float3 worldNormal = normalize(i.worldNormal);
                    //world pos
                    float3 worldPos = i.worldPos;
                    //light dir
                    float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos)).xyz;
                    //view dir
                    float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos)).xyz;
                    //tangent
                    float3 worldTangent = normalize(i.worldTangent);
                    //bitangent
                    float3 worldBiTangent = normalize(i.worldBiTangent);
                    //切线空间矩阵
                    float3x3 tangentTransform = float3x3(worldTangent, worldBiTangent, worldNormal);

                    //法线贴图
                    float3 normalMap = UnpackNormal(tex2D(_NormalMap, TRANSFORM_TEX(i.uv0.zw, _NormalMap))).rgb;

                    //转到世界空间
                    float3 localNormal = normalize(mul(normalMap, tangentTransform));
                    //final normal
                    float3 finalNormal = lerp(worldNormal, localNormal, _NormalMapScale);

                    float2 finalUV = i.uv0.xy;

                    //parallax mapping
                    // float3 tangentViewDir = normalize(mul(worldViewDir, tangentTransform));
                    // finalUV = parallaxMapping(i.uv0, tangentViewDir);

                    //贴图
                    float3 albedo = tex2D(_MainTex, TRANSFORM_TEX(finalUV, _MainTex)).rgb;
                    

                    //nDotL
                    float nDotL = saturate(dot(finalNormal, worldLightDir));
                    //half reflect
                    float3 halfRefl = normalize(worldLightDir + worldViewDir);
                    //hDotN
                    float hDotN = saturate(dot(finalNormal, halfRefl));

                    //环境光
                    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                    //漫反射
                    float3 diffuse = lerp(ambient * _Diffuse.rgb * albedo.rgb, _Diffuse.rgb * _LightColor0.rgb * albedo.rgb, nDotL);

                    //高光
                    float3 specular = _LightColor0.rgb * _Specular.rgb * pow(hDotN, _Gloss);

                    color = ambient + diffuse + specular;

                    return float4(color, 1.0);
                }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
