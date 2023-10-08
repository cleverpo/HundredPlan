Shader "Quik/Effect/Bloom/BloomSprite"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
 
        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            #pragma vertex SpriteVert
            #pragma fragment frag
            
            #include "UnitySprites.cginc"

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;
                return c;
            }

            ENDCG
        }
    }
}
