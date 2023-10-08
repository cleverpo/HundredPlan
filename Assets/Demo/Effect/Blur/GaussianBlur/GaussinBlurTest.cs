using UnityEngine;

public class GaussinBlurTest : PostEffectsBaseComp
{
    [Range(1.0f, 12)]
    public float blurSize = 1.0f;

    public Shader gaussianBlurShader;
    private Material gaussianBlurMat;

    public Material material {
        get {
            gaussianBlurMat = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMat);
            return gaussianBlurMat;
        }
    }

    protected override void OnRenderImage(RenderTexture src, RenderTexture dist){
        if(material != null){
            material.SetFloat("_BlurSize", blurSize);
            
            int rtw = src.width;
            int rth = src.height;

            RenderTexture buffer = RenderTexture.GetTemporary(rtw, rth, 0);

            Graphics.Blit(src, buffer, material, 0);

            Graphics.Blit(buffer, dist, material, 1);

            RenderTexture.ReleaseTemporary(buffer);
        }
    }
}
