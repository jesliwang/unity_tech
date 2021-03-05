#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System;
using UnityEditorInternal;

public class ShaderGUI_WOT_Background : ShaderGUI
{
    MaterialProperty cull = null;
    MaterialProperty isZWrite = null;
    //MaterialProperty zTest = null;
    //MaterialProperty useAlpha = null;
    MaterialProperty useSeamlessAlpha = null;
    MaterialProperty useCutoff = null;
    MaterialProperty alphaCutoff = null;

    MaterialProperty color = null;
    MaterialProperty mainTex = null;
    MaterialProperty maskTex = null;
    MaterialProperty alpha = null;

    

    private MaterialProperty blendProp;

    MaterialEditor m_MaterialEditor;
 
    //string shader_Default     = "CF/Background/BgSimple/CF_BgSimple_Base";
    //string shader_Transparent = "Hidden/CF/Background/BgSimple/CF_BgSimple_Transparent";
    //string shader_Transparent_cutoff = "Hidden/CF/Background/BgSimple/CF_BgSimple_Transparent(Clip)";

    public void FindProperties(MaterialProperty[] props)
    {
        //zTest = FindProperty("_ZTest", props);
        cull = FindProperty("_Cull", props);
        isZWrite = FindProperty("_IsZWrite", props);
        //useAlpha = FindProperty("_UseAlpha", props);
        useSeamlessAlpha = FindProperty("_UseSeamlessAlpha", props);
        useCutoff = FindProperty("_UseCutoff", props);
        alphaCutoff = FindProperty("_AlphaCutoff", props);

        color = FindProperty("_Color", props);
        mainTex = FindProperty("_MainTex",   props);
        maskTex = FindProperty("_TransTex", props);
        alpha = FindProperty("_Alpha", props);
        //cutoff = FindProperty("_Cutoff", props);

    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props);
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        ShaderPropertiesGUI(material);
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        base.AssignNewShaderToMaterial(material, oldShader, newShader);
    }

    void ShowMaterialProperty(Material mat, MaterialProperty prop, string name, int i)
    {
        if (prop != null && mat != null)
        {
            if (mat.HasProperty(prop.name))
            {
                m_MaterialEditor.ShaderProperty(prop, name, MaterialEditor.kMiniTextureFieldLabelIndentLevel + i);
            }
        }
    }

    public void ShaderPropertiesGUI(Material material)
    {
        //EditorGUIUtility.fieldWidth = 64.0f;

        GUILayout.Label("OPTION", EditorStyles.boldLabel);
        ////m_MaterialEditor.ShaderProperty(cull, "Cull", MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);
        ////m_MaterialEditor.ShaderProperty(isZWrite, "Z Write", MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);
        ////m_MaterialEditor.ShaderProperty(zTest, "Z Test", MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);
        //m_MaterialEditor.ShaderProperty(zTest, "Z Test", MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);
        m_MaterialEditor.ShaderProperty(useSeamlessAlpha, "Seamless Alpha", MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);

        //bool USE_SEAMLESSALPHA = Array.IndexOf(material.shaderKeywords, "USE_SEAMLESSALPHA") != -1;
        //EditorGUI.BeginChangeCheck();
        //ShowMaterialProperty(material, useSeamlessAlpha, "Seamless Alpha", 0);
        if (useSeamlessAlpha.floatValue == 1)
        {
            material.EnableKeyword("USE_SEAMLESSALPHA");
        }
        else
        {
            material.DisableKeyword("USE_SEAMLESSALPHA");
        }

        m_MaterialEditor.ShaderProperty(useCutoff, "Cutoff", MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);
        if (useCutoff.floatValue == 1)
        {
            material.EnableKeyword("USE_CUTOFF");
            ShowMaterialProperty(material, alphaCutoff, "       Alpha Cutoff", 0);
        }
        else
        {
            material.DisableKeyword("USE_CUTOFF");
        }



        EditorGUILayout.Space();
        GUILayout.Label("BASE", EditorStyles.boldLabel);
        //GUILayout.Label(" ◆  알파채널은 디퓨즈텍스쳐의 A채널을 사용합니다.", EditorStyles.textArea);
        ShowMaterialProperty(material, color, "Color", 0);
        ShowMaterialProperty(material, mainTex, "Main Texture (RGB)", 0);
        ShowMaterialProperty(material, maskTex, "Mask Texture (R)", 0);
        ShowMaterialProperty(material, alpha, "Alpha", 0);

        m_MaterialEditor.ShaderProperty(cull, "Culling", MaterialEditor.kMiniTextureFieldLabelIndentLevel + 0);
        ShowMaterialProperty(material, isZWrite, "Z Write", 0);




        EditorGUILayout.Space();
        GUILayout.Label("ADVANCED", EditorStyles.boldLabel);
        m_MaterialEditor.RenderQueueField();
        m_MaterialEditor.EnableInstancingField();
        m_MaterialEditor.DoubleSidedGIField();

        //EditorGUIUtility.fieldWidth = 64.0f;
        //EditorGUILayout.Space();
        //if (EditorGUI.EndChangeCheck())
        //{
        //    if (USE_SEAMLESSALPHA)
        //    {
        //        material.EnableKeyword("USE_SEAMLESSALPHA");
        //    }
        //    else
        //    {
        //        material.DisableKeyword("USE_SEAMLESSALPHA");
        //    }
        //}
    }
}
#endif