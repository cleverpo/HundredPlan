Shader "Quik/ZTest/XRay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _XRayColor("XRay Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags{"LightMode"="ForwardBase"}
        CGINCLUDE
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _XRayColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f_xray
            {
                float4 vertex : SV_POSITION;
                fixed4 xRayColor: COLOR;
            };

            struct v2f_normal
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
            };

            v2f_xray vert_xray (appdata v)
            {
                v2f_xray o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //模型空间
                fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                fixed3 normal = normalize(v.normal);
                float rim = 1 - dot(viewDir, normal);

                //线性变成非线性，边缘的锐化
                // rim = pow(rim, 4);

                o.xRayColor = _XRayColor * rim;

                return o;
            };

            fixed4 frag_xray (v2f_xray i) : SV_Target
            {
                return i.xRayColor;
            };

            v2f_normal vert_normal (appdata v)
            {
                v2f_normal o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                
                return o;
            };

            fixed4 frag_normal (v2f_normal i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float nDotL = saturate(dot(worldNormal, worldLightDir));

                fixed4 texColor = tex2D(_MainTex, i.uv);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 diffuse = _LightColor0.rgb * texColor.rgb * nDotL;
                
                return fixed4(ambient + diffuse, texColor.a);
            };

        ENDCG

        Pass
        {
            Tags{"RenderType"="Transparent" "Queue"="Transparent"}
            Blend SrcAlpha One
            ZTest Greater
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert_xray
            #pragma fragment frag_xray
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_normal
            #pragma fragment frag_normal
            ENDCG
        }
    }
}
