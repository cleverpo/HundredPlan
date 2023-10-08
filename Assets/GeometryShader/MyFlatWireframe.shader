Shader "Quik/Geometry/Wireframe"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" { }

        _Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)

        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(1.0, 255)) = 8.0
        
        _WireframeColor ("Wireframe Color", Color) = (0, 0, 0)
        _WireframeThickness ("Wireframe Thickness", Range(0, 10)) = 1
    }

    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #include "MyFlatWireframe.cginc"
            #pragma target 4.0
            #pragma vertex vert
            #pragma geometry geo
            #pragma fragment frag

            ENDCG

        }
    }
}