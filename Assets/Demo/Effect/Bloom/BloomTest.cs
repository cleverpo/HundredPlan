using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BloomTest : PostEffectsBaseComp
{
    public Shader bloomShader;
    private Material bloomMaterial = null;

    [Range(0.2f, 3.0f)]
    public float blurSpeed = 0.6f;
    [Range(0.0f, 1.0f)]
    public float luminanceThreshold = 1.0f;
    [Range(0, 4)]
    public int iterations = 3;
    [Range(1, 8)]
    public int downSample = 2;

    public Material material
    {
        get
        {
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial;
        }
    }

    protected override void OnRenderImage(RenderTexture src, RenderTexture dist)
    {
        if (material != null)
        {
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtw = src.width / downSample;
            int rth = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtw, rth, 0, src.format);
			buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0, material, 0);

            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpeed);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtw, rth, 0);

                Graphics.Blit(buffer0, buffer1, material, 1);
                
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtw, rth, 0);

                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            material.SetTexture("_BloomTex", buffer0);
            Graphics.Blit(src, dist, material, 3);

            RenderTexture.ReleaseTemporary(buffer0);
        }
    }
}
