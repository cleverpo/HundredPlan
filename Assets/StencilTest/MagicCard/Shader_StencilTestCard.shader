Shader "Quik/StencilTest/Card"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags{
            "RenderType"="Opaque"
            "Queue"="Geometry+1"
            "LightMode"="ForwardBase"
        }
        ZWrite off
        Pass{
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "Lighting.cginc"

                float4 _Diffuse;

                struct a2v{
                    float4 vertex: POSITION;
                    float3 normal: NORMAL;
                };

                struct v2f{
                    float4 pos: SV_POSITION;
                    float3 worldNormal: TEXCOORD0;
                    float3 worldPos: TEXCOORD1;
                };

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = UnityObjectToWorldDir(v.vertex);
                    return o;
                };

                float4 frag(v2f i): SV_Target{
                    float3 color = float3(1.0, 1.0, 1.0);
                    float3 worldNormal = normalize(i.worldNormal);
                    float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    float nDotl = saturate(dot(worldNormal, worldLightDir));
                    float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * nDotl;
                    color = diffuse;
                    return float4(color, 1.0);
                }
            ENDCG
        }
    }
}
