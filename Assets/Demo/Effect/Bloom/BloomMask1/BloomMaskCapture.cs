using UnityEngine;

[RequireComponent(typeof(Camera))]
public class BloomMaskCapture : MonoBehaviour{
    public Camera m_FollowCamera;

    public RenderTexture m_RenderTexture;

    public Shader m_ReplaceShader;

    private Camera m_Camera;

    void Start(){
        this.m_Camera = GetComponent<Camera>();
        this.m_Camera.enabled = false;
        this.m_Camera.clearFlags = CameraClearFlags.Color;
        this.m_Camera.backgroundColor = Color.white;

        this.m_RenderTexture.width = Screen.width;
        this.m_RenderTexture.height = Screen.height;
    }

    void LateUpdate(){
        this.m_Camera.RenderWithShader(this.m_ReplaceShader, "RenderType");
    }

}