#if !defined(MYFLATWIREFRAME_INCLUDED)
#define MYFLATWIREFRAME_INCLUDED

#define CUSTOM_GEOMETRY_INTERPOLATORS \
    float2 barycentricCoordinates : TEXCOORD9;   //重心坐标

#include "../Common/Shader/MyLighting Input.cginc"

struct InterpolatorsGeometry
{
    VertexOutput data;
    CUSTOM_GEOMETRY_INTERPOLATORS   //重心坐标
};

fixed4 _WireframeColor;
float _WireframeThickness;

fixed3 GetAlbedoWithWireFrame(FragmentInput i)
{
    fixed3 albedo = tex2D(_MainTex, i.uv);

    fixed3 barys;
    barys.xy = i.barycentricCoordinates;
    barys.z = 1 - barys.x - barys.y;

    // albedo = barys;

    float3 deltas = fwidth(barys);
    float3 thickness = deltas * _WireframeThickness;
    barys = smoothstep(thickness, thickness * 2, barys);
    float minBary = min(barys.x, min(barys.y, barys.z));
    // float delta = abs(ddx(minBary)) + abs(ddy(minBary));
    // minBary = smoothstep(delta, delta*2, minBary);
    return lerp(_WireframeColor, albedo, minBary);
};

#define GET_ALBEDO_FUNC GetAlbedoWithWireFrame
#include "../Common/Shader/MyLighting.cginc"

[maxvertexcount(3)]
void geo(triangle VertexOutput i[3], inout TriangleStream<InterpolatorsGeometry> stream)
{
    // //改变顶点法线，成flatshader，也可以用uninterpolater或者ddx,ddy方法
    // float3 p0 = i[0].worldPos;
    // float3 p1 = i[1].worldPos;
    // float3 p2 = i[2].worldPos;
    // float3 normalTriangle = cross(p1 - p0, p2 - p0);
    // i[0].worldNormal = normalTriangle;
    // i[1].worldNormal = normalTriangle;
    // i[2].worldNormal = normalTriangle;
    InterpolatorsGeometry g0, g1, g2;
    g0.data = i[0];
    g1.data = i[1];
    g2.data = i[2];

    g0.barycentricCoordinates = float2(1.0, 0.0);
    g1.barycentricCoordinates = float2(0.0, 1.0);
    g2.barycentricCoordinates = float2(0.0, 0.0);

    stream.Append(g0);
    stream.Append(g1);
    stream.Append(g2);
}
#endif