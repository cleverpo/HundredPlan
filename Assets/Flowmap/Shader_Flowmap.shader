Shader "Quik/Flowmap/Shader_Flowmap"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white" {}
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)   //漫反射

        _Flowmap("Flow Map", 2D) = "white" {}   //flow map
        _FlowSpeed("Flow speed", Range(0, 2.0)) = 1.0
        _TimeSpeed("Time speed", Range(0, 10.0)) = 1.0
        [Toggle]_reverse_flow("Flow Reverse", Int) = 0

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
                #pragma shader_feature _REVERSE_FLOW_ON

                #include "Lighting.cginc"

                sampler2D _MainTex; float4 _MainTex_ST;
                float4 _Diffuse;
                
                sampler2D _Flowmap; float4 _Flowmap_ST;
                float _FlowSpeed;
                float _TimeSpeed;

                struct a2v {
                    float4 vertex: POSITION;
                    float4 texCoord0: TEXCOORD0;
                    float3 normal: NORMAL;
                };

                struct v2f {
                    float4 pos: SV_POSITION;
                    float2 uv0: TEXCOORD0;
                    float3 worldNormal: TEXCOORD1;
                    float3 worldPos: TEXCOORD2;
                };
                
                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv0 = v.texCoord0.xy;
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = UnityObjectToWorldDir(v.vertex);
                    return o;
                }

                float4 frag(v2f i): SV_Target {
                    float3 color = float3(1.0, 1.0, 1.0);
                    
                    float3 finalNormal = normalize(i.worldNormal);
                    float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    float2 finalUV = i.uv0;

                    float2 uvOffset = tex2D(_Flowmap, TRANSFORM_TEX(finalUV, _Flowmap)).xy * 2.0 - 1.0;
                    uvOffset *= _FlowSpeed;
                    #ifdef _REVERSE_FLOW_ON
                        uvOffset *= -1;
                    #endif

                    float time = _Time.x * _TimeSpeed;

                    //构造2个相差半个周期的函数
                    float phase0 = frac(time);
                    float phase1 = frac(time + 0.5);

                    //贴图
                    finalUV = TRANSFORM_TEX(finalUV, _MainTex);
                    float3 tex1 = tex2D(_MainTex, finalUV + uvOffset.xy * phase0).rgb;
                    float3 tex2 = tex2D(_MainTex, finalUV + uvOffset.xy * phase1).rgb;
                    float texLerp = abs(0.5 - phase0) / 0.5;

                    //贴图
                    float3 albedo = lerp(tex1, tex2, texLerp);
                    
                    //nDotL
                    float nDotL = saturate(dot(finalNormal, worldLightDir));
                    //环境光
                    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                    //漫反射
                    float3 diffuse = lerp(ambient * _Diffuse.rgb * albedo.rgb, _Diffuse.rgb * _LightColor0.rgb * albedo.rgb, nDotL);

                    color = ambient + diffuse;

                    return float4(color, 1.0);
                }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
