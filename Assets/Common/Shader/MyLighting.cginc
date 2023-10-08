#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#pragma multi_complie_fwdbase

#include "Lighting.cginc"
#include "MyLighting Input.cginc"

#if !defined(GET_ALBEDO_FUNC)
    #define GET_ALBEDO_FUNC GetAlbedo
#endif

fixed3 DoLighting(FragmentInput i)
{
    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
    fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

    //tex color
    fixed3 albedo = GET_ALBEDO_FUNC(i) * _Tint;
    //ambient
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
    //diffuse
    float nDotL = saturate(dot(i.worldNormal, worldLightDir));
    // fixed3 diffuse = _LightColor0.rgb * _Tint * albedo * nDotL;
    fixed3 diffuse = lerp(ambient.rgb * _Tint.rgb  * albedo.rgb, _LightColor0.rgb * _Tint.rgb * albedo.rgb, nDotL);
    //specular
    fixed3 halfRefl = normalize(worldLightDir + worldViewDir);
    float nDotR = saturate(dot(i.worldNormal, halfRefl));
    fixed3 specular = _LightColor0.rgb * _SpecularTint * pow(nDotR, _Smoothness);
    
    return ambient + diffuse + specular;

};

VertexOutput vert(VertexInput v)
{
    VertexOutput o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv.xy, _MainTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldTangent = UnityObjectToWorldDir(v.tangent);
    o.worldBiTangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    #if defined(_PARALLAX_MAP)
        o.tangentViewDir = CalcTangentViewDir(v);
    #endif

    return o;
};

FragmentOutput frag(FragmentInput i)
{
    #if defined(_PARALLAX_MAP)
        //parallax map
        ApplyParallax(i);
    #endif

    //normal map
    ApplyNormalMap(i);

    //lighting
    fixed3 light = DoLighting(i);

    FragmentOutput output;
    output.color = fixed4(light, _Tint.a);
    return output;
};

#endif