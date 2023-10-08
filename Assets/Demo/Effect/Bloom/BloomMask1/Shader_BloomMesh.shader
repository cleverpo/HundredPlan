Shader "Quik/Effect/Bloom/BloomMesh"
{
    Properties
    {
        _Tint ("Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" { }

        _SpecularTint ("Specular Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _Smoothness ("Smoothness", Range(1.0, 255)) = 8.0
    }
    SubShader
    {
        Tags { "RenderType" = "Bloom" "LightMode" = "ForwardBase" }

        Pass
        {

            CGPROGRAM

            #include "../../../../Common/Shader/MyLighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            ENDCG

        }
    }
}
