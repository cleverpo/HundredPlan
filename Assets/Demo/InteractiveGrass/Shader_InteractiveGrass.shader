Shader "Quik/Demo/Shader_InteractiveGrass"
{
    Properties
    {
        _Tint ("Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Main Tex", 2D) = "white" { }

        _GrassTopColor ("Grass Top Color", Color) = (0.0, 1.0, 0.0, 1.0)
        _GrassBottomColor ("Grass Bottom Color", Color) = (0.0, 1.0, 1.0, 1.0)
        _TranslucentGain ("Translucent Gain", Range(0, 1)) = 0.5

        _GrassBendRotateRandom ("Grass Bend Rotate Random", Range(0.0, 1)) = 0.2

        //尺寸
        _GrassWidth ("Grass Width", Float) = 0.05
        _GrassWidthRandom ("Grass Width Random", Float) = 0.02
        _GrassHeight ("Grass Height", Float) = 0.5
        _GrassHeightRandom ("Grass Height Random", Float) = 0.3

        //草 曲率
        _GrassForward ("Grass Forward", Float) = 0.38
        _GrassCurve ("Grass Curve", Range(1, 4)) = 2

        //细分
        _TessellationUniform ("Grass Tessellation", Float) = 2.0

        //风
        _WindDistortionMap ("Wind Distortion Map", 2D) = "white" { }
        _WindFrequency ("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
        _WindStrength ("Wind Strength", Float) = 1

        //交互半径
        _InteractiveRadius ("Interactive Radius", Float) = 3.0
    }

    CGINCLUDE
    #define BLADE_SEGMENT 5
    ENDCG

    SubShader
    {
        Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
        Pass
        {
            CGPROGRAM

            #include "../../Common/Shader/MyLighting.cginc"
            #include "Shader_InteractiveGrassTessellation.cginc"

            #pragma target 4.6
            #pragma vertex vertTess
            #pragma hull hull
            #pragma domain domain
            #pragma geometry geo
            #pragma fragment fragGeo
            #pragma multi_compile_fwdbase
            
            fixed4 _GrassTopColor;
            fixed4 _GrassBottomColor;
            float _TranslucentGain;

            float _GrassBendRotateRandom;

            float _GrassForward;
            float _GrassCurve;

            float _GrassWidth;
            float _GrassWidthRandom;
            float _GrassHeight;
            float _GrassHeightRandom;

            sampler2D _WindDistortionMap; float4 _WindDistortionMap_ST;
            float4 _WindFrequency;
            float _WindStrength;

            //interactive
            uniform float3 _PositionMoving;
            float _InteractiveRadius;

            struct VertexOutputGeo
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct GeometryOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            GeometryOutput CreateGeometryOutput(float3 vertexPosition, float2 uv, float width, float height, float forward, float3x3 transformMatrix)
            {
                float3 tangentPos = float3(width, forward, height);
                float3 normal = normalize(mul(transformMatrix, float3(0, -1.0, forward)));
                float3 pos = vertexPosition + mul(transformMatrix, tangentPos);

                GeometryOutput o;
                o.pos = UnityObjectToClipPos(pos);
                o.uv = uv;
                o.normal = UnityObjectToWorldNormal(normal);

                return o;
            };

            VertexOutputGeo vertGeo(VertexInput i)
            {
                VertexOutputGeo o;
                o.vertex = i.vertex;
                o.normal = i.normal;
                o.tangent = i.tangent;

                return o;
            };

            //rand trick
            float rand(float3 seed)
            {
                return frac(sin(dot(seed.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
            };

            //SpeedTreeWind里源码，旋转矩阵
            float3x3 Rotation3x3(float3 vAxis, float fAngle)
            {
                // compute sin/cos of fAngle
                float2 vSinCos;
                #ifdef OPENGL
                    vSinCos.x = sin(fAngle);
                    vSinCos.y = cos(fAngle);
                #else
                    sincos(fAngle, vSinCos.x, vSinCos.y);
                #endif

                const float c = vSinCos.y;
                const float s = vSinCos.x;
                const float t = 1.0 - c;
                const float x = vAxis.x;
                const float y = vAxis.y;
                const float z = vAxis.z;

                return float3x3(t * x * x + c, t * x * y - s * z, t * x * z + s * y,
                t * x * y + s * z, t * y * y + c, t * y * z - s * x,
                t * x * z - s * y, t * y * z + s * x, t * z * z + c);
            }

            [maxvertexcount(BLADE_SEGMENT * 2 + 1)]
            void geo(triangle DomainOutput i[3], inout TriangleStream<GeometryOutput> triStream)
            {
                float3 pos = i[0].vertex;
                float3 normal = normalize(i[0].normal);
                float4 tangent = normalize(i[0].tangent);
                float3 bitangent = cross(normal, tangent.xyz) * tangent.w;
                // float3x3 tangent2Object = transpose(float3x3(tangent.xyz, bitangent, normal));
                
                float3x3 tangent2Object = float3x3(
                    tangent.x, bitangent.x, normal.x,
                    tangent.y, bitangent.y, normal.y,
                    tangent.z, bitangent.z, normal.z
                );
                float width = rand(pos.zyx) * _GrassWidthRandom + _GrassWidth;
                float height = rand(pos.xzy) * _GrassHeightRandom + _GrassHeight;
                //自身旋转
                float3x3 rotateMatrix = Rotation3x3(float3(0.0, 0.0, 1.0), rand(pos.xyz) * UNITY_TWO_PI);
                
                //自身弯曲
                float3x3 bendRotateMatrix = Rotation3x3(float3(-1.0, 0.0, 0.0), rand(pos.zzx) * _GrassBendRotateRandom * UNITY_PI * 0.5);
                
                //曲率（curvature)
                float forward = rand(pos.yyz) * _GrassForward;
                
                //wind
                float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;
                float2 distortion = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1.0) * _WindStrength;
                float3 wind = normalize(float3(distortion.x, distortion.y, 0.0));
                float3x3 windRotateMatrix = Rotation3x3(wind, distortion * UNITY_PI);

                //交互
                float dist = distance(pos, _PositionMoving);
                float interactIntensity = 1.0 - saturate(dist / _InteractiveRadius);
                float3 interactDir = normalize(pos - _PositionMoving) * interactIntensity;

                float3x3 rotateAndT2OMatrix = mul(tangent2Object, rotateMatrix);
                float3x3 totalMatrix = mul(mul(rotateAndT2OMatrix, bendRotateMatrix), windRotateMatrix);

                for (int i = 0; i < BLADE_SEGMENT; i++)
                {
                    float3x3 transformMatrix = i == 0 ? rotateAndT2OMatrix : totalMatrix;
                    float t = i / (float)BLADE_SEGMENT;
                    float segmentWidth = width * (1 - t);
                    float segmentHeight = height * t;

                    //计算顶点foward偏移
                    float segmentForward = pow(t, _GrassCurve) * forward;

                    //交互
                    float3 newPos = i == 0 ? pos : pos + interactDir * t;

                    triStream.Append(CreateGeometryOutput(newPos, float2(0.0, t), segmentWidth, segmentHeight, segmentForward, transformMatrix));
                    triStream.Append(CreateGeometryOutput(newPos, float2(1.0, t), -segmentWidth, segmentHeight, segmentForward, transformMatrix));
                }

                float3 newPos = pos + interactDir;
                triStream.Append(CreateGeometryOutput(newPos, float2(0.5, 1.0), 0.0, height, forward, totalMatrix));
            };

            fixed4 fragGeo(GeometryOutput i, fixed facing : VFACE) : SV_TARGET
            {
                float3 normal = facing > 0 ? i.normal : - i.normal;
                float3 ambient = ShadeSH9(float4(normal, 1));
                // float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float nDotL = saturate(saturate(dot(_WorldSpaceLightPos0, normal)) + _TranslucentGain);
                float4 lightIntensity = nDotL * _LightColor0 + float4(ambient, 1.0);
                fixed4 color = lerp(_GrassBottomColor, _GrassTopColor * lightIntensity, i.uv.y);
                return fixed4(color.rgb, 1.0);
                // return fixed4(i.normal, 1.0);

            };

            ENDCG

        }
    }
    FallBack "Diffuse"
}
