using UnityEngine;

public class GodRayTest : PostEffectsBaseComp
{
    public Shader m_GodRayShader;

    public Material material
    {
        get
        {
            m_GodRayMaterial = CheckShaderAndCreateMaterial(m_GodRayShader, m_GodRayMaterial);
            return m_GodRayMaterial;
        }
    }

    private Material m_GodRayMaterial = null;

    //发射位置
    public Transform m_GodRayTransform;

    [Range(0.0f, 1.0f)]
    public float m_LuminanceThreshold = 0.0f;
    [Range(0.0f, 8.0f)]
    public float m_LightIntensity = 1.0f;
    [Range(0, 10)]
    public int m_SampleCount = 1;
    [Range(1.0f, 10.0f)]
    public float m_SampleScale = 1;
    public Color m_LightColor = Color.white;

    protected override void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (material != null)
        {
            int rtw = src.width;
            int rth = src.height;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtw, rth, 0, src.format);
			buffer0.filterMode = FilterMode.Bilinear;
            
            material.SetFloat("_LuminanceThreshold", m_LuminanceThreshold);
            Graphics.Blit(src, buffer0, material, 0);

            float samplerOffset = m_SampleScale / rtw;

            for(int i = 0; i < m_SampleCount; i++){
                float offset = samplerOffset * (i * 2 + 1);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtw, rth, 0, src.format);
                Vector3 godRayPos = this.m_Camera.WorldToViewportPoint(m_GodRayTransform.position);
                material.SetVector("_BlurCenter", godRayPos);
                material.SetFloat("_BlurFactor", offset); 
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            material.SetTexture("_BlurTex", buffer0);
            material.SetFloat("_LightIntensity", m_LightIntensity);
            material.SetVector("_LightColor", m_LightColor);
            Graphics.Blit(src, dst, material, 2);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
