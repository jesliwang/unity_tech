using UnityEngine;
using UnityEditor;
using System;

public class ShaderGUI_WOT_TANK : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //EditorGUIUtility.fieldWidth = 64.0f;

        //메터리얼 타겟 설정
        Material targetMat = materialEditor.target as Material;

        //UI 프로퍼티 받아오기
        MaterialProperty Color = ShaderGUI.FindProperty("_Color", properties);
        MaterialProperty MainTex = ShaderGUI.FindProperty("_MainTex", properties);
        MaterialProperty Bright = ShaderGUI.FindProperty("_Bright", properties);
        MaterialProperty Contrast = ShaderGUI.FindProperty("_Contrast", properties);

        //MaterialProperty DirtTex = ShaderGUI.FindProperty("_DirtTex", properties);
        //MaterialProperty MaskTex = ShaderGUI.FindProperty("_MaskTex", properties);
        //MaterialProperty DirtDegree = ShaderGUI.FindProperty("_DirtDegree", properties);

        //MaterialProperty BumpTex = ShaderGUI.FindProperty("_BumpTex", properties);
        //MaterialProperty BumpPower = ShaderGUI.FindProperty("_BumpPower", properties);

        MaterialProperty SpecularTex = ShaderGUI.FindProperty("_SpecularTex", properties);
        MaterialProperty Shininess = ShaderGUI.FindProperty("_Shininess", properties);
        MaterialProperty ShininessPower = ShaderGUI.FindProperty("_ShininessPower", properties);

        //MaterialProperty DyeColor1 = ShaderGUI.FindProperty("_DyeColor1", properties);
        //MaterialProperty DyeColor2 = ShaderGUI.FindProperty("_DyeColor2", properties);
        //MaterialProperty PatternTex = ShaderGUI.FindProperty("_PatternTex", properties);
        //MaterialProperty Tile = ShaderGUI.FindProperty("_Tile", properties);
        //MaterialProperty RotationSpeed = ShaderGUI.FindProperty("_RotationSpeed", properties);

        MaterialProperty TransTex = ShaderGUI.FindProperty("_TransTex", properties);
        MaterialProperty Cutoff = ShaderGUI.FindProperty("_Cutoff", properties);

        MaterialProperty MatCap = ShaderGUI.FindProperty("_MatCap", properties);
        MaterialProperty MatCapBright = ShaderGUI.FindProperty("_MatCapBright", properties);
        MaterialProperty MatCapContrast = ShaderGUI.FindProperty("_MatCapContrast", properties);

        //MaterialProperty AnimMap = ShaderGUI.FindProperty("_AnimMap", properties);
        //MaterialProperty AnimStart = ShaderGUI.FindProperty("_AnimStart", properties);
        //MaterialProperty AnimEnd = ShaderGUI.FindProperty("_AnimEnd", properties);
        //MaterialProperty AnimAll = ShaderGUI.FindProperty("_AnimAll", properties);
        //MaterialProperty AnimOff = ShaderGUI.FindProperty("_AnimOff", properties);

        //MaterialProperty OldAnimStart = ShaderGUI.FindProperty("_OldAnimStart", properties);
        //MaterialProperty OldAnimEnd = ShaderGUI.FindProperty("_OldAnimEnd", properties);
        //MaterialProperty OldAnimOff = ShaderGUI.FindProperty("_OldAnimOff", properties);

        //MaterialProperty Speed = ShaderGUI.FindProperty("_Speed", properties);
        //MaterialProperty Blend = ShaderGUI.FindProperty("_Blend", properties);

        EditorGUI.BeginChangeCheck();

        //쉐이더 전처리
        GUILayout.Space(10);
        bool LIGHT_MATCAP = Array.IndexOf(targetMat.shaderKeywords, "LIGHT_MATCAP") != -1;
        bool LIGHT_SPECULAR = Array.IndexOf(targetMat.shaderKeywords, "LIGHT_SPECULAR") != -1;
        bool LIGHT = Array.IndexOf(targetMat.shaderKeywords, "LIGHT") != -1;
        bool LIGHT_CUTOFF = Array.IndexOf(targetMat.shaderKeywords, "LIGHT_CUTOFF") != -1;
        bool MATCAP = Array.IndexOf(targetMat.shaderKeywords, "MATCAP") != -1;


        //인스펙터 GUI 표시
        GUILayout.Label("OPTION", EditorStyles.boldLabel);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        LIGHT_SPECULAR = EditorGUILayout.Toggle("Light & Specular", LIGHT_SPECULAR);
        //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        LIGHT_MATCAP = EditorGUILayout.Toggle("Light & Matcap", LIGHT_MATCAP);
        //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        LIGHT = EditorGUILayout.Toggle("Light", LIGHT);
        LIGHT_CUTOFF = EditorGUILayout.Toggle("Light & Cutoff", LIGHT_CUTOFF);
        MATCAP = EditorGUILayout.Toggle("Matcap", MATCAP);

        GUILayout.Space(10);
        //GUILayout.Label("MAIN", EditorStyles.boldLabel);
        //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        materialEditor.ShaderProperty(Color, Color.displayName);
        materialEditor.ShaderProperty(MainTex, MainTex.displayName);
        //materialEditor.ShaderProperty(DirtTex, DirtTex.displayName);
        //materialEditor.ShaderProperty(DirtDegree, DirtDegree.displayName);
        materialEditor.ShaderProperty(Bright, Bright.displayName);
        materialEditor.ShaderProperty(Contrast, Contrast.displayName);

        //GUILayout.Space(10);
        //GUILayout.Label("DIRT", EditorStyles.boldLabel);
        //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });

        //GUILayout.Space(10);
        //GUILayout.Label("PATTERN", EditorStyles.boldLabel);
        //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        //materialEditor.ShaderProperty(DyeColor1, DyeColor1.displayName);
        //materialEditor.ShaderProperty(DyeColor2, DyeColor2.displayName);
        //materialEditor.ShaderProperty(PatternTex, PatternTex.displayName);
        //materialEditor.ShaderProperty(Tile, Tile.displayName);
        //materialEditor.ShaderProperty(RotationSpeed, RotationSpeed.displayName);

        GUILayout.Space(10);

        if (LIGHT_MATCAP)
        {
            //GUILayout.Label("MATCAP", EditorStyles.boldLabel);
            //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
            materialEditor.ShaderProperty(MatCap, MatCap.displayName);
            materialEditor.ShaderProperty(MatCapBright, MatCapBright.displayName);
            materialEditor.ShaderProperty(MatCapContrast, MatCapContrast.displayName);
        }

        if (LIGHT_SPECULAR)
        {
            //GUILayout.Label("SPECULAR", EditorStyles.boldLabel);
            //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
            //materialEditor.ShaderProperty(BumpTex, BumpTex.displayName);
            //materialEditor.ShaderProperty(BumpPower, BumpPower.displayName);
            materialEditor.ShaderProperty(SpecularTex, SpecularTex.displayName);
            materialEditor.ShaderProperty(Shininess, Shininess.displayName);
            materialEditor.ShaderProperty(ShininessPower, ShininessPower.displayName);
        }
        
        if (LIGHT)
        {

        }

        if (LIGHT_CUTOFF)
        {
            materialEditor.ShaderProperty(TransTex, TransTex.displayName);
            materialEditor.ShaderProperty(Cutoff, Cutoff.displayName);
        }


        if (MATCAP)
        {
            //GUILayout.Label("MATCAP", EditorStyles.boldLabel);
            //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
            materialEditor.ShaderProperty(MatCap, MatCap.displayName);
            materialEditor.ShaderProperty(MatCapBright, MatCapBright.displayName);
            materialEditor.ShaderProperty(MatCapContrast, MatCapContrast.displayName);
        }

        //GUILayout.Space(10);
        //GUILayout.Label("GPU INSTANCING ANI", EditorStyles.boldLabel);
        //GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        //materialEditor.ShaderProperty(AnimMap, AnimMap.displayName);
        //materialEditor.ShaderProperty(AnimStart, AnimStart.displayName);
        //materialEditor.ShaderProperty(AnimEnd, AnimEnd.displayName);
        //materialEditor.ShaderProperty(AnimAll, AnimAll.displayName);
        //materialEditor.ShaderProperty(AnimOff, AnimOff.displayName);

        //materialEditor.ShaderProperty(OldAnimStart, OldAnimStart.displayName);
        //materialEditor.ShaderProperty(OldAnimEnd, OldAnimEnd.displayName);
        //materialEditor.ShaderProperty(OldAnimOff, OldAnimOff.displayName);

        //materialEditor.ShaderProperty(Speed, Speed.displayName);
        //materialEditor.ShaderProperty(Blend, Blend.displayName);



        //OPTION
        GUILayout.Space(20);
        //GUILayout.Label("OPTION", EditorStyles.boldLabel);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        //materialEditor.ShaderProperty(_Cull, _Cull.displayName);
        //materialEditor.ShaderProperty(_IsZWrite, _IsZWrite.displayName);
        materialEditor.RenderQueueField();


        if (EditorGUI.EndChangeCheck())
        {
            if (LIGHT_SPECULAR)
            {
                targetMat.EnableKeyword("LIGHT_SPECULAR");
                targetMat.DisableKeyword("LIGHT_MATCAP");
                targetMat.DisableKeyword("MATCAP");
                targetMat.DisableKeyword("LIGHT");
                targetMat.DisableKeyword("LIGHT_CUTOFF");

            }
            if (!LIGHT_SPECULAR)
            {
                targetMat.DisableKeyword("LIGHT_SPECULAR");
            }

            if (LIGHT_MATCAP)
            {
                targetMat.EnableKeyword("LIGHT_MATCAP");
                targetMat.DisableKeyword("LIGHT_SPECULAR");
                targetMat.DisableKeyword("LIGHT");
                targetMat.DisableKeyword("MATCAP");
                targetMat.DisableKeyword("LIGHT_CUTOFF");

            }
            if (!LIGHT_MATCAP)
            {
                targetMat.DisableKeyword("LIGHT_MATCAP");
            }

            if (LIGHT)
            {
                targetMat.EnableKeyword("LIGHT");
                targetMat.DisableKeyword("LIGHT_SPECULAR");
                targetMat.DisableKeyword("LIGHT_MATCAP");
                targetMat.DisableKeyword("MATCAP");
                targetMat.DisableKeyword("LIGHT_CUTOFF");
            }
            if (!LIGHT)
            {
                targetMat.DisableKeyword("LIGHT");
            }

            if (LIGHT_CUTOFF)
            {
                targetMat.EnableKeyword("LIGHT_CUTOFF");
                targetMat.DisableKeyword("LIGHT_SPECULAR");
                targetMat.DisableKeyword("LIGHT_MATCAP");
                targetMat.DisableKeyword("LIGHT");
                targetMat.DisableKeyword("MATCAP");
            }
            if (!LIGHT_CUTOFF)
            {
                targetMat.DisableKeyword("LIGHT_CUTOFF");
            }

            if (MATCAP)
            {
                targetMat.EnableKeyword("MATCAP");
                targetMat.DisableKeyword("LIGHT_SPECULAR");
                targetMat.DisableKeyword("LIGHT_MATCAP");
                targetMat.DisableKeyword("LIGHT");
                targetMat.DisableKeyword("LIGHT_CUTOFF");
            }
            if (!MATCAP)
            {
                targetMat.DisableKeyword("MATCAP");
            }
        }
        //__________________________________________________________________________
    }
}