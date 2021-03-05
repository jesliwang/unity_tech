using UnityEngine;
using UnityEditor;
using System;

public class ShaderGUI_WOT_FX : ShaderGUI
{
    public enum FXMode
    {
        Additive,
        AlphaBlend,
        Multiply,
        Dissolve,
    }

    public enum TexNumber
    {
        One,
        Two,
        Three,
        None,
    }

    private MaterialProperty fxModeProp;
    private MaterialProperty texNumbProp;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //메터리얼 타겟 설정
        Material targetMat = materialEditor.target as Material;


        //UI 프로퍼티 받아오기
        MaterialProperty _Color = ShaderGUI.FindProperty("_Color", properties);
        MaterialProperty _ColorPower = ShaderGUI.FindProperty("_ColorPower", properties);
        MaterialProperty _MainTex = ShaderGUI.FindProperty("_MainTex", properties);
        MaterialProperty _MainTransTex = ShaderGUI.FindProperty("_MainTransTex", properties);
        MaterialProperty _MainTex1 = ShaderGUI.FindProperty("_MainTex1", properties);
        MaterialProperty _MainTransTex1 = ShaderGUI.FindProperty("_MainTransTex1", properties);
        MaterialProperty _MainTex2 = ShaderGUI.FindProperty("_MainTex2", properties);
        MaterialProperty _MainTransTex2 = ShaderGUI.FindProperty("_MainTransTex2", properties);
        MaterialProperty _UseMaskUV = ShaderGUI.FindProperty("_UseMaskUV", properties);

        MaterialProperty _Cull = ShaderGUI.FindProperty("_Cull", properties);
        MaterialProperty _IsZWrite = ShaderGUI.FindProperty("_IsZWrite", properties);

        //dissolve
        MaterialProperty _EdgeColor1 = ShaderGUI.FindProperty("_EdgeColor1", properties);
        MaterialProperty _EdgeColor2 = ShaderGUI.FindProperty("_EdgeColor2", properties);
        MaterialProperty _Level = ShaderGUI.FindProperty("_Level", properties);
        MaterialProperty _Edges = ShaderGUI.FindProperty("_Edges", properties);

        this.fxModeProp = ShaderGUI.FindProperty("_BlendMode", properties);
        this.texNumbProp = ShaderGUI.FindProperty("_TexNumbMode", properties);

        FXMode fxmode = (FXMode)this.fxModeProp.floatValue;
        TexNumber texNumber = (TexNumber)this.texNumbProp.floatValue;
        EditorGUI.BeginChangeCheck();


        //인스펙터 GUI 표시
        GUILayout.Label("FX MODE & COLOR", EditorStyles.boldLabel);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });

        fxmode = (FXMode)EditorGUILayout.Popup("FX Mode", (int)fxmode, Enum.GetNames(typeof(FXMode)));


        //쉐이더 전처리
        GUILayout.Space(20);
        bool USEMASKUV = Array.IndexOf(targetMat.shaderKeywords, "USEMASKUV") != -1;        //bool 값은 존재
        bool TEXTURE0 = Array.IndexOf(targetMat.shaderKeywords, "TEXTURE0") != -1;
        bool TEXTURE1 = Array.IndexOf(targetMat.shaderKeywords, "TEXTURE1") != -1;
        bool TEXTURE2 = Array.IndexOf(targetMat.shaderKeywords, "TEXTURE2") != -1;
        bool TEXTURE3 = Array.IndexOf(targetMat.shaderKeywords, "TEXTURE3") != -1;
        bool DISSOLVE = Array.IndexOf(targetMat.shaderKeywords, "DISSOLVE") != -1;
        bool ALPHABLEND = Array.IndexOf(targetMat.shaderKeywords, "ALPHABLEND") != -1;

        materialEditor.ShaderProperty(_Color, _Color.displayName);
        materialEditor.ShaderProperty(_ColorPower, _ColorPower.displayName);

        GUILayout.Space(20);
        GUILayout.Label("TEXTURE", EditorStyles.boldLabel);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });

        //USEMASK = EditorGUILayout.Toggle("Use Mask", USEMASK);            //gui 표시 안함
        //TEXTURE2 = EditorGUILayout.Toggle("Use MainTex1", TEXTURE2);
        //TEXTURE3 = EditorGUILayout.Toggle("Use MainTex2", TEXTURE3);

        if (!DISSOLVE)
        {
            texNumber = (TexNumber)EditorGUILayout.Popup("MainTex Number", (int)texNumber, Enum.GetNames(typeof(TexNumber)));



            //texNumber = (TexNumber)EditorGUILayout.Popup("Texture Number", (int)texNumber, Enum.GetNames(typeof(TexNumber)));
            //if (TEXTURE0)
            //{
            //    if (ALPHABLEND)
            //    {
            //        materialEditor.ShaderProperty(_UseMaskUV, _UseMaskUV.displayName);
            //        materialEditor.ShaderProperty(_MainTransTex, _MainTex.displayName);
            //    }
            //}


            //materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
            if (ALPHABLEND)
            {
                materialEditor.ShaderProperty(_UseMaskUV, _UseMaskUV.displayName);
                GUILayout.Space(20);
                if (TEXTURE0)
                {
                    materialEditor.ShaderProperty(_MainTransTex, _MainTransTex.displayName);
                }
                if (TEXTURE1)
                {
                    if (USEMASKUV)
                    {
                        materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                        materialEditor.ShaderProperty(_MainTransTex, _MainTransTex.displayName);
                        //materialEditor.ShaderProperty(_MainTransTex, "Mask 1", MaterialEditor.kMiniTextureFieldLabelIndentLevel);
                        //materialEditor.TextureProperty(_MainTransTex, "Mask 1", false);
                    }
                    else
                    {
                        materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                        materialEditor.TextureProperty(_MainTransTex, _MainTransTex.displayName, false);
                    }
                }
                if (TEXTURE2)
                {
                    if (USEMASKUV)
                    {
                        materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                        materialEditor.ShaderProperty(_MainTransTex, _MainTransTex.displayName);
                        materialEditor.ShaderProperty(_MainTex1, _MainTex1.displayName);
                        materialEditor.ShaderProperty(_MainTransTex1, _MainTransTex1.displayName);
                    }
                    else
                    {
                        materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                        materialEditor.TextureProperty(_MainTransTex, _MainTransTex.displayName, false);
                        materialEditor.ShaderProperty(_MainTex1, _MainTex1.displayName);
                        materialEditor.TextureProperty(_MainTransTex1, _MainTransTex1.displayName, false);
                    }
                }
                if (TEXTURE3)
                {
                    if (USEMASKUV)
                    {
                        materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                        materialEditor.ShaderProperty(_MainTransTex, _MainTransTex.displayName);
                        materialEditor.ShaderProperty(_MainTex1, _MainTex1.displayName);
                        materialEditor.ShaderProperty(_MainTransTex1, _MainTransTex1.displayName);
                        materialEditor.ShaderProperty(_MainTex2, _MainTex2.displayName);
                        materialEditor.ShaderProperty(_MainTransTex2, _MainTransTex2.displayName);
                    }
                    else
                    {
                        materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                        materialEditor.TextureProperty(_MainTransTex, _MainTransTex.displayName, false);
                        materialEditor.ShaderProperty(_MainTex1, _MainTex1.displayName);
                        materialEditor.TextureProperty(_MainTransTex1, _MainTransTex1.displayName, false);
                        materialEditor.ShaderProperty(_MainTex2, _MainTex2.displayName);
                        materialEditor.TextureProperty(_MainTransTex2, _MainTransTex2.displayName, false);
                    }
                }
            }

            else
            {
                //_UseMaskUV.floatValue = 0;  //에디터에서 반응이 한템포 느림
                if (TEXTURE0)
                {

                }
                if (TEXTURE1)
                {
                    materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                }
                if (TEXTURE2)
                {
                    materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                    materialEditor.ShaderProperty(_MainTex1, _MainTex1.displayName);
                }
                if (TEXTURE3)
                {
                    materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
                    materialEditor.ShaderProperty(_MainTex1, _MainTex1.displayName);
                    materialEditor.ShaderProperty(_MainTex2, _MainTex2.displayName);
                }
            }
        }


        if (DISSOLVE)
        {
            materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
            materialEditor.TextureProperty(_MainTransTex, _MainTransTex.displayName, false);
            materialEditor.ShaderProperty(_EdgeColor1, _EdgeColor1.displayName);
            materialEditor.ShaderProperty(_EdgeColor2, _EdgeColor2.displayName);
            materialEditor.ShaderProperty(_Level, _Level.displayName);
            materialEditor.ShaderProperty(_Edges, _Edges.displayName);
        }
        //}


        //OPTION
        GUILayout.Space(20);
        GUILayout.Label("OPTION", EditorStyles.boldLabel);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        materialEditor.ShaderProperty(_Cull, _Cull.displayName);
        materialEditor.ShaderProperty(_IsZWrite, _IsZWrite.displayName);
        materialEditor.RenderQueueField();


        if (EditorGUI.EndChangeCheck())
        {
            //Texture Number
            this.texNumbProp.floatValue = (float)texNumber;
            foreach (UnityEngine.Object obj in this.texNumbProp.targets)
                this.SetupTexNumb(obj as Material, texNumber);

            //Blend Mode
            this.fxModeProp.floatValue = (float)fxmode;
            foreach (UnityEngine.Object obj in this.fxModeProp.targets)
                this.SetupBlendMode(obj as Material, fxmode);
            //this.SetupBlendMode(obj as Material, fxmode, texNumber);

            if (_UseMaskUV.floatValue == 1)
            {
                targetMat.EnableKeyword("USEMASKUV");
            }
            else
            {
                targetMat.DisableKeyword("USEMASKUV");
            }
        }
    }


    // 블렌드모드
    private void SetupBlendMode(Material targetMat, FXMode fxMode)
    //private void SetupBlendMode(Material targetMat, FXMode fxMode, TexNumber texNumber)
    {
        switch (fxMode)
        {
            case FXMode.Additive:
                targetMat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.One);
                targetMat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.One);
                targetMat.DisableKeyword("DISSOLVE");
                targetMat.DisableKeyword("ALPHABLEND");
                //targetMat.DisableKeyword("USEMASKUV");
                break;
            case FXMode.Multiply:
                targetMat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.Zero);
                targetMat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcColor);
                targetMat.DisableKeyword("DISSOLVE");
                targetMat.DisableKeyword("ALPHABLEND");
                //targetMat.DisableKeyword("USEMASKUV");
                break;
            case FXMode.AlphaBlend:
                targetMat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
                targetMat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                targetMat.DisableKeyword("DISSOLVE");
                targetMat.EnableKeyword("ALPHABLEND");
                break;
            case FXMode.Dissolve:
                targetMat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
                targetMat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                //targetMat.EnableKeyword("TEXTURE2");
                //targetMat.EnableKeyword("ALPHABLEND");
                //this.SetupTexNumb(targetMat, 0);
                targetMat.DisableKeyword("ALPHABLEND");
                targetMat.EnableKeyword("DISSOLVE");
                targetMat.DisableKeyword("TEXTURE0");
                targetMat.DisableKeyword("TEXTURE1");
                targetMat.DisableKeyword("TEXTURE2");
                targetMat.DisableKeyword("TEXTURE3");
                //targetMat.DisableKeyword("USEMASKUV");
                break;
        }
    }

    private void SetupTexNumb(Material targetMat, TexNumber texNumber)
    {
        switch (texNumber)
        {
            case TexNumber.One:
                targetMat.DisableKeyword("TEXTURE0");
                targetMat.EnableKeyword("TEXTURE1");
                targetMat.DisableKeyword("TEXTURE2");
                targetMat.DisableKeyword("TEXTURE3");
                break;

            case TexNumber.Two:
                targetMat.DisableKeyword("TEXTURE0");
                targetMat.DisableKeyword("TEXTURE1");
                targetMat.EnableKeyword("TEXTURE2");
                targetMat.DisableKeyword("TEXTURE3");
                break;

            case TexNumber.Three:
                targetMat.DisableKeyword("TEXTURE0");
                targetMat.DisableKeyword("TEXTURE1");
                targetMat.DisableKeyword("TEXTURE2");
                targetMat.EnableKeyword("TEXTURE3");
                break;

            case TexNumber.None:
                targetMat.EnableKeyword("TEXTURE0");
                targetMat.DisableKeyword("TEXTURE1");
                targetMat.DisableKeyword("TEXTURE2");
                targetMat.DisableKeyword("TEXTURE3");
                break;
        }
    }
}