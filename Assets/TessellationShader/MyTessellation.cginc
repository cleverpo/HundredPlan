#if !defined(MYTESSELLATION_INCLUDED)
#define MYTESSELLATION_INCLUDED

#include "../Common/Shader/MyLighting Input.cginc"

struct TessellationFactors {
    float edge[3]: SV_TESSFACTOR;
    float inside: SV_INSIDETESSFACTOR; 
};

struct TessellationControlPoint {
	float4 vertex : INTERNALTESSPOS;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float4 uv : TEXCOORD0;
};

float _TessellationUniform;

TessellationControlPoint tessellationVert (VertexInput v) {
    TessellationControlPoint p;
    p.vertex = v.vertex;
	p.normal = v.normal;
	p.tangent = v.tangent;
    p.uv = v.uv;
	return v;
};

TessellationFactors MyPatchConstantFunction(InputPatch<TessellationControlPoint, 3> patch){
    TessellationFactors f;
    f.edge[0] = _TessellationUniform;
    f.edge[1] = _TessellationUniform;
    f.edge[2] = _TessellationUniform;
	f.inside = _TessellationUniform;
	return f;
};

[UNITY_domain("tri")]
[UNITY_outputcontrolpoints(3)]
[UNITY_outputtopology("triangle_cw")]
[UNITY_partitioning("integer")]
[UNITY_patchconstantfunc("MyPatchConstantFunction")]
TessellationControlPoint hull(InputPatch<TessellationControlPoint, 3> patch, uint id: SV_OUTPUTCONTROLPOINTID){
    return patch[id];
};

[UNITY_domain("tri")]
VertexOutput domain(TessellationFactors factors, OutputPatch<TessellationControlPoint, 3> patch, float3 barycentricCoordinates: SV_DOMAINLOCATION){
    VertexInput data;
    
    #define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) data.fieldName = \
            patch[0].fieldName * barycentricCoordinates.x + \
            patch[1].fieldName * barycentricCoordinates.y + \
            patch[2].fieldName * barycentricCoordinates.z;
    
    MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
    MY_DOMAIN_PROGRAM_INTERPOLATE(normal)
    MY_DOMAIN_PROGRAM_INTERPOLATE(tangent)
    MY_DOMAIN_PROGRAM_INTERPOLATE(uv)

    return vert(data);
}

#endif