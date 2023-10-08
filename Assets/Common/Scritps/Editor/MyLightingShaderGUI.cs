// using UnityEngine;
// using UnityEditor;

// namespace Quik
// {
//     public class MyLightingShaderGUI : ShaderGUI
//     {
//         private MaterialEditor editor;
//         private MaterialProperty[] properties;

//         public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties){
//             this.editor = materialEditor;
//             this.properties = properties;

//             DoMain();
//         }

//         private MaterialProperty FindProperty(string name){
//             return FindProperty(name, properties);
//         }

//         private void DoMain(){
//             GUILayout.Label("Main Maps", EditorStyles.boldLabel);
            
//             MaterialProperty mainTex = FindProperty("_MainTex");
//             MaterialProperty tint = FindProperty("_Tint");
//             GUIContent albedoLabel = new GUIContent(mainTex.displayName, "albedo");
//             editor.TexturePropertySingleLine(albedoLabel, mainTex, tint);

            

//             editor.TextureScaleOffsetProperty(mainTex);
//         }
//     }
// }
