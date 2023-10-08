#if !defined(INTERACTIVE_GRASS_TESSELLATION)
#define INTERACTIVE_GRASS_TESSELLATION
#include "../../Common/Shader/MyLighting.cginc"

float _TessellationUniform;

struct TessFactors
{
    float edge[3] : SV_TESSFACTOR;
    float inside : SV_INSIDETESSFACTOR;
};

struct VertexOutputTess
{
    float4 vertex : INTERNALTESSPOS;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

#define HullOutput VertexOutputTess
struct DomainOutput
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

TessFactors TessPatchConstant(InputPatch < VertexOutputTess, 3 > patch)
{
    TessFactors factors;
    factors.edge[0] = _TessellationUniform;
    factors.edge[1] = _TessellationUniform;
    factors.edge[2] = _TessellationUniform;
    factors.inside = (factors.edge[0] + factors.edge[1] + factors.edge[2]) / 3.0;
    return factors;
};

VertexOutputTess vertTess(VertexInput i)
{
    VertexOutputTess o;
    o.vertex = i.vertex;
    o.normal = i.normal;
    o.tangent = i.tangent;

    return o;
};

[UNITY_domain("tri")]
[UNITY_patchconstantfunc("TessPatchConstant")]
[UNITY_partitioning("integer")]
[UNITY_outputtopology("triangle_cw")]
[UNITY_outputcontrolpoints(3)]
HullOutput hull(InputPatch < VertexOutputTess, 3 > patch, uint id : SV_OUTPUTCONTROLPOINTID)
{
    return patch[id];
};

[UNITY_domain("tri")]
DomainOutput domain(TessFactors factors, const OutputPatch < HullOutput, 3 > patch, float3 barys : SV_DOMAINLOCATION)
{
    DomainOutput o;

    #define MY_DOMAIN_INTERPOLATE(fieldName) o.fieldName = \
        patch[0].fieldName * barys.x + \
        patch[1].fieldName * barys.y + \
        patch[2].fieldName * barys.z;

    MY_DOMAIN_INTERPOLATE(vertex)
    MY_DOMAIN_INTERPOLATE(normal)
    MY_DOMAIN_INTERPOLATE(tangent)
    // o.vertex = i.vertex;
    // o.uv = i.uv;
    // o.normal = i.normal;
    // o.tangent = i.tangent;
    return o;
};
#endif