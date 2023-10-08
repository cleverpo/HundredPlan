using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
[RequireComponent(typeof(Camera))]
public abstract class PostEffectsBaseComp : MonoBehaviour
{   
    protected Camera m_Camera;
    protected virtual void Start(){
        CheckResources();

        this.m_Camera = GetComponent<Camera>();
    }

    protected void CheckResources(){
        bool isSupported = CheckSupport();
        if(isSupported == false){
            NotSupported();
        }
    }

    protected bool CheckSupport(){
        return true;
    }

    protected void NotSupported(){
        this.enabled = false;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material){
        if(shader == null){
            return null;
        }
        if(shader.isSupported && material && material.shader == shader){
            return material;
        }

        if(!shader.isSupported){
            return null;
        }else{
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;

            if(material){
                return material;
            }else{
                return null;
            }
        }
    }

    protected abstract void OnRenderImage(RenderTexture src, RenderTexture dst);
}
