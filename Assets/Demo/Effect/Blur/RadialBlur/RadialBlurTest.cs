using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadialBlurTest : PostEffectsBaseComp
{
    [Range(0.0f, 0.1f)]
    public float m_blurFactor = 0.1f;

    public Vector2 m_blurCenter = new Vector2(0.5f, 0.5f);

    public Shader m_blurShader;

    public Material material
    {
        get
        {
            m_blurMaterial = CheckShaderAndCreateMaterial(m_blurShader, m_blurMaterial);
            return m_blurMaterial;
        }
    }

    private Material m_blurMaterial = null;

    protected override void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (material != null)
        {
            material.SetFloat("_BlurFactor", m_blurFactor);
            material.SetVector("_BlurCenter", m_blurCenter);
            Graphics.Blit(src, dst, material, 0);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
