using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSAOTest : PostEffectsBaseComp
{
    public Shader m_SSAOShader;

    public Material material
    {
        get
        {
            m_SSAOMaterial = CheckShaderAndCreateMaterial(m_SSAOShader, m_SSAOMaterial);
            return m_SSAOMaterial;
        }
    }
    private Material m_SSAOMaterial = null;

    protected override void Start()
    {
        base.Start();

        this.m_Camera.depthTextureMode = this.m_Camera.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    protected override void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (material != null)
        {
            Graphics.Blit(src, dst, material, 0);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
