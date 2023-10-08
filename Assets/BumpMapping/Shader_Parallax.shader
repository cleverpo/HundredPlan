Shader "Quik/BumpMapping/Shader_Parallax"
{
    Properties
    {
        _Tint ("Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" { }

        _SpecularTint ("Specular Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _Smoothness ("Smoothness", Range(0.0, 255)) = 8.0

        _NormalMap ("Normal Map", 2D) = "white" { }
        _BumpScale ("Bump Scale", Float) = 1
        
        _ParallaxMap ("Parallax Map", 2D) = "white" { }
        _ParallaxStrength ("Parallax Strength", Range(0.0, 0.1)) = 0.0
    }
    
	CGINCLUDE
        #define _NORMAL_MAP
        #define _PARALLAX_MAP
        #define PARALLAX_FUNCTION ParallaxRaymarching
        #define PARALLAX_RAYMARCHING_RELIEF_STEPS 10
        #define PARALLAX_RAYMARCHING_OCCLUSION
    ENDCG

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM

            #include "../Common/Shader/MyLighting.cginc"

			#pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            ENDCG

        }
    }
}
