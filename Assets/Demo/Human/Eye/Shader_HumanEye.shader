Shader "Quik/Human/HumanEye"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags{
            "LightMode"="ForwardBase"
        }
        Pass{
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"

                sampler2D _MainTex; float4 _MainTex_ST;

                struct a2v{
                    float4 vertex: POSITION;
                    float2 texCoord: TEXCOORD0;
                    float3 normal: NORMAL;
                };

                struct v2f{
                    float4 pos: SV_POSITION;
                    float2 uv: TEXCOORD0;
                    float3 worldPos: TEXCOORD1;
                    float3 worldNormal: TEXCOORD2;
                };

                v2f vert(a2v v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.texCoord;
                    o.worldPos = UnityObjectToWorldDir(v.vertex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    return o;
                };

                float4 frag(v2f i):SV_Target{
                    float3 color = float3(1.0, 1.0, 1.0);
                    float4 texColor = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));


                    return float4(texColor);
                };
            ENDCG
        }
    }
}
