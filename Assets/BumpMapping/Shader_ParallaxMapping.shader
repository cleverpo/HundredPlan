Shader "Quik/BumpMapping/Shader_ParallaxMapping"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex("Main Tex", 2D) = "white" {}

        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0) //高光
        _Gloss("Gloss", Range(1.0, 255)) = 8.0              //光泽度

        _NormalMap("Normal Map", 2D) = "white"{}            //法线贴图
        _NormalMapScale("Normal Map Scale", Range(0.0, 1)) = 1 //法线贴图的强度

        _DepthMap("Depth Map", 2D) = "black"{}            //深度图
        _DepthMapScale("Depth Map Scale", Range(0, 0.1)) = 0.05       //深度图的强度

        [Toggle]_isSteep("Steep Parallax Map",int) = 0   //是否陡峭视差映射
        [Toggle]_isOcclusion("Parallax Occlusion Map", int) = 0 //是否视差遮蔽映射
        [Toggle]_isRelief("Reliet Parallax Map", int) = 0        //浮雕贴图

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
                sampler _DepthMap; float4 _DepthMap_ST;

                float4 _Diffuse;

                float4 _Specular;
                float _Gloss;

                float _NormalMapScale;
                float _DepthMapScale;

                bool _isSteep;
                bool _isOcclusion;
                bool _isRelief;

                struct a2v {
                    float4 vertex: POSITION;
                    float4 texCoord0: TEXCOORD0;
                    float3 normal: NORMAL;          //法线
                    float4 tangent: TANGENT;        //切线
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float2 uv0: TEXCOORD0;

                    float3 worldPos: TEXCOORD1;
                    float3 worldNormal: TEXCOORD2;

                    float3 worldTangent: TEXCOORD3;
                    float3 worldBiTangent: TEXCOORD4;
                };
                

                inline float2 ParallaxMapping(float2 texCoord, float3 viewDir){
                    float depth = tex2D(_DepthMap, TRANSFORM_TEX(texCoord, _DepthMap)).r;
                    return texCoord - viewDir.xy / viewDir.z * (depth * _DepthMapScale);
                }

                inline float2 SteepParallaxMapping(float2 texCoord, float3 viewDir){
                    // float numLayers = 20.0;  //层数 
                    //优化，垂直看应该比有角度看时候需要的样本数少
                    float numLayers = lerp(8.0, 32.0, abs(dot(float3(0.0, 0.0, 1.0), viewDir)));

                    float layersDepth = 1 / numLayers;
                    float2 curTexCoord = texCoord;
                    float curLayerDepth = 0.0;
                    float curDepthMapValue = tex2D(_DepthMap, TRANSFORM_TEX(curTexCoord, _DepthMap)).r;
                    float2 texCoordDelta = viewDir.xy / viewDir.z * _DepthMapScale;
                    texCoordDelta /= numLayers;

                    [unroll(32)]
                    for(int i = 0; i < numLayers; i++){
                        if(curLayerDepth > curDepthMapValue){
                            return curTexCoord;
                        }
                        curLayerDepth += layersDepth;
                        curTexCoord -= texCoordDelta;
                        curDepthMapValue = tex2D(_DepthMap, TRANSFORM_TEX(curTexCoord, _DepthMap)).r;
                    }

                    return texCoord;
                }

                inline float2 ParallaxOcclusionMapping(float2 texCoord, float3 viewDir){
                    float numLayers = lerp(8.0, 32.0, abs(dot(float3(0.0, 0.0, 1.0), viewDir)));

                    float layersDepth = 1 / numLayers;
                    float2 curTexCoord = texCoord;
                    float curLayerDepth = 0.0;
                    float curDepthMapValue = tex2D(_DepthMap, TRANSFORM_TEX(curTexCoord, _DepthMap)).r;
                    float2 texCoordDelta = viewDir.xy / viewDir.z * _DepthMapScale;
                    texCoordDelta /= numLayers;

                    [unroll(32)]
                    for(int i = 0; i < numLayers; i++){
                        if(curLayerDepth > curDepthMapValue){
                            break;
                        }
                        curLayerDepth += layersDepth;
                        curTexCoord -= texCoordDelta;
                        curDepthMapValue = tex2D(_DepthMap, TRANSFORM_TEX(curTexCoord, _DepthMap)).r;
                    }

                    //在陡峭视差中结果里，取上次采样值与当前采样值做插值
                    float2 preTexCoord = curTexCoord + texCoordDelta;
                    
                    float afterDepth = curDepthMapValue - curLayerDepth;
                    float preDepth = tex2D(_DepthMap, TRANSFORM_TEX(preTexCoord, _DepthMap)).r - curLayerDepth + layersDepth;
                    float weight = afterDepth / (afterDepth - preDepth);

                    return lerp(preTexCoord, curTexCoord, weight);
                }

                inline float2 ReliefParallaxMapping(float2 texCoord, float3 viewDir){
                    float numLayers = lerp(8.0, 32.0, abs(dot(float3(0.0, 0.0, 1.0), viewDir)));
                    float layerDepth = 1 / numLayers;
                    float2 texCoordDelta = viewDir.xy / viewDir.z * _DepthMapScale;
                    texCoordDelta /= numLayers;

                    float2 curTexCoord = texCoord;
                    float curLayerDepth = 0.0;
                    float curDepthMapValue = tex2D(_DepthMap, TRANSFORM_TEX(curTexCoord, _DepthMap)).r;

                    [unroll(32)]
                    for(int i = 0; i < numLayers; i++){
                        if(curLayerDepth > curDepthMapValue){
                            break;
                        }

                        curTexCoord -= texCoordDelta;
                        curDepthMapValue = tex2D(_DepthMap, TRANSFORM_TEX(curTexCoord, _DepthMap)).r;
                        curLayerDepth += layerDepth;
                    }

                    //二分查找
                    float2 halfDeltaUV = texCoordDelta / 2;
                    float halfLayerDepth = layerDepth / 2;

                    curTexCoord += halfDeltaUV;
                    curLayerDepth += halfLayerDepth;

                    int numSearches = 5;
                    [unroll(5)]
                    for(int i = 0; i < numSearches; i++)
                    {
                        halfDeltaUV  = halfDeltaUV / 2;
                        halfLayerDepth = halfLayerDepth / 2;

                        curDepthMapValue = tex2D(_DepthMap, TRANSFORM_TEX(curTexCoord, _DepthMap)).r;

                        if(curDepthMapValue > curLayerDepth)
                        {
                            curTexCoord -= halfDeltaUV;
                            curLayerDepth += halfLayerDepth;
                        }
                        else
                        {
                            curTexCoord += halfDeltaUV;
                            curLayerDepth -= halfLayerDepth;
                        }
                    }

                    return curTexCoord;
                }

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv0.xy = v.texCoord0.xy;

                    o.worldPos = UnityObjectToWorldDir(v.vertex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);

                    o.worldTangent = UnityObjectToWorldDir(v.tangent).xyz;
                    o.worldBiTangent = cross(o.worldTangent, o.worldNormal) * v.tangent.w;
                    return o;
                }

                float4 frag(v2f i): SV_Target {
                    float3 color = float3(1.0, 1.0, 1.0);
                    float2 finalUV = i.uv0.xy;
                    
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
                    //parallax mapping
                    float3 tangentViewDir = normalize(mul(worldViewDir, tangentTransform));
                    if(_isSteep){
                        finalUV = SteepParallaxMapping(finalUV, tangentViewDir);
                    }else if(_isOcclusion){
                        finalUV = ParallaxOcclusionMapping(finalUV, tangentViewDir);
                    }else if(_isRelief){
                        finalUV = ReliefParallaxMapping(finalUV, tangentViewDir);
                    }else{
                        finalUV = ParallaxMapping(finalUV, tangentViewDir);
                    }

                    //法线贴图
                    float3 normalMap = UnpackNormal(tex2D(_NormalMap, TRANSFORM_TEX(finalUV, _NormalMap))).rgb;

                    //转到世界空间
                    float3 localNormal = normalize(mul(normalMap, tangentTransform));
                    //final normal
                    float3 finalNormal = lerp(worldNormal, localNormal, _NormalMapScale);

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
