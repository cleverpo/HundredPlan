Shader "Quik/Tessellation/Shader_Tessellation"
{
    Properties
    {
        _Tint ("Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" {}

        _SpecularTint ("Specular Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _Smoothness ("Smoothness", Range(1.0, 255)) = 8.0

        _WireframeColor ("Wireframe Color", Color) = (0, 0, 0)
        _WireframeThickness ("Wireframe Thickness", Range(0, 10)) = 1

        _TessellationUniform("Tessellation", Range(1, 60)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #include "../GeometryShader/MyFlatWireframe.cginc"
            #include "MyTessellation.cginc"

            #pragma target 4.6
            #pragma vertex tessellationVert
            #pragma hull hull
            #pragma domain domain
            #pragma geometry geo
            #pragma fragment frag

            ENDCG
        }
    }
}
