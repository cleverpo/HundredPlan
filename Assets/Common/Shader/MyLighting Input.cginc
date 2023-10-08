#if !defined(MY_LIGHTING_INPUT_INCLUDED)
#define MY_LIGHTING_INPUT_INCLUDED

#include "UnityStandardUtils.cginc"

fixed4 _Tint;
sampler2D _MainTex; float4 _MainTex_ST;

fixed4 _SpecularTint;
float _Smoothness;

sampler2D _NormalMap;
float _BumpScale;

sampler2D _ParallaxMap;
float _ParallaxStrength;


struct VertexInput
{
    float4 vertex : POSITION;
    float4 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct VertexOutput
{
    float4 pos : SV_POSITION;
    float3 worldNormal : NORMAL;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float3 worldTangent : TEXCOORD2;
    float3 worldBiTangent : TEXCOORD3;

    #if defined(_PARALLAX_MAP)
        float3 tangentViewDir : TEXCOORD8;
    #endif
};

struct FragmentInput
{
    float4 pos : SV_POSITION;
    float3 worldNormal : NORMAL;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float3 worldTangent : TEXCOORD2;
    float3 worldBiTangent : TEXCOORD3;
    
    #if defined(_PARALLAX_MAP)
        float3 tangentViewDir : TEXCOORD8;
    #endif
    
    #if defined(CUSTOM_GEOMETRY_INTERPOLATORS)
        CUSTOM_GEOMETRY_INTERPOLATORS
    #endif
};

struct FragmentOutput
{
    fixed4 color : SV_TARGET;
};

fixed3 CalcTangentViewDir(VertexInput v)
{
    fixed3x3 object2Tangent = fixed3x3(
        v.tangent.xyz,
        cross(v.normal, v.tangent.xyz) * v.tangent.w,
        v.normal
    );
    return mul(object2Tangent, ObjSpaceViewDir(v.vertex));
}

float3 GetAlbedo(FragmentInput i)
{
    return tex2D(_MainTex, i.uv).rgb;
};

float GetParallaxHeight(float2 uv)
{
    return tex2D(_ParallaxMap, uv).r;
};

float2 ParallaxOffset(float2 uv, float2 viewDir)
{
    float height = GetParallaxHeight(uv);
    height = 1.0 - height;
    height *= _ParallaxStrength;
    return viewDir * height * - 1.0;
};

float2 ParallaxRaymarching(float2 uv, float2 viewDir)
{
    #if !defined(PARALLAX_RAYMARCHING_STEPS)
        #define PARALLAX_RAYMARCHING_STEPS 10
    #endif

    float stepSize = 1.0 / PARALLAX_RAYMARCHING_STEPS;
    float2 uvDelta = viewDir * (stepSize * _ParallaxStrength);

    float2 uvOffset = float2(0.0, 0.0);
    float curHeight = 1.0;
    float curHeightMap = GetParallaxHeight(uv);

    float2 preUvOffset = uvOffset;
    float preHeight = curHeight;
    float preHeightMap = curHeightMap;

    for (int i = 1; i < PARALLAX_RAYMARCHING_STEPS; i++)
    {
        if (curHeightMap >= curHeight)
        {
            break;
        }

        preUvOffset = uvOffset;
        preHeight = curHeight;
        preHeightMap = curHeightMap;

        uvOffset -= uvDelta;
        curHeight -= stepSize;
        curHeightMap = GetParallaxHeight(uv + uvOffset);
    }
    
    #if !defined(PARALLAX_RAYMARCHING_RELIEF_STEPS)
        #define PARALLAX_RAYMARCHING_RELIEF_STEPS 0
    #endif

    #if PARALLAX_RAYMARCHING_RELIEF_STEPS > 0
        //Relief Mapping
        for (int i = 0; i < PARALLAX_RAYMARCHING_RELIEF_STEPS; i++)
        {
            uvDelta *= 0.5;
            stepSize *= 0.5;

            preUvOffset = uvOffset;
            preHeight = curHeight;
            preHeightMap = curHeightMap;

            if (curHeightMap >= curHeight)
            {
                uvOffset += uvDelta;
                curHeight += stepSize;
            }
            else
            {
                uvOffset -= uvDelta;
                curHeight -= stepSize;
            }
            curHeightMap = GetParallaxHeight(uv + uvOffset);
        }
    #endif
    
    #if defined(PARALLAX_RAYMARCHING_OCCLUSION)
        //Occlusion Mapping
        float preDifferent = preHeight - preHeightMap;
        float different = abs(curHeight - curHeightMap);
        float t = preDifferent / (preDifferent + different);
        uvOffset = lerp(preUvOffset, uvOffset, t);
    #endif


    return uvOffset;
};

void ApplyParallax(inout FragmentInput i)
{
    #if defined(_PARALLAX_MAP)
        i.tangentViewDir = normalize(i.tangentViewDir);
        i.tangentViewDir.xy /= i.tangentViewDir.z;

        #if !defined(PARALLAX_FUNCTION)
            #define PARALLAX_FUNCTION ParallaxOffset
        #endif

        float2 uvOffset = PARALLAX_FUNCTION(i.uv, i.tangentViewDir.xy);

        i.uv.xy += uvOffset;
    #endif
};

void ApplyNormalMap(inout FragmentInput i)
{
    #if defined(_NORMAL_MAP)
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldTangent = normalize(i.worldTangent);
        fixed3 worldBiTangent = normalize(i.worldBiTangent);
        fixed3x3 world2Tangent = fixed3x3(worldTangent, worldBiTangent, worldNormal);
        float3 normal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);

        i.worldNormal = normalize(mul(normal, world2Tangent));
    #endif
};

#endif