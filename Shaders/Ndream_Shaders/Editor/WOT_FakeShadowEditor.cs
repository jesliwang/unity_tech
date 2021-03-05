using UnityEngine;
using UnityEditor;
using System;

public class WOT_FakeShadowEditor : ShaderGUI
{

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {

        //메터리얼 타겟 설정
        Material targetMat = materialEditor.target as Material;


        //UI 프로퍼티 받아오기
        MaterialProperty _FakeShadowHeightDefault = ShaderGUI.FindProperty("_FakeShadowHeightDefault", properties);
        MaterialProperty _FadeOut = ShaderGUI.FindProperty("_FadeOut", properties);
        
        
        //Options
        MaterialProperty _Cull = ShaderGUI.FindProperty("_Cull", properties);
        MaterialProperty _IsZWrite = ShaderGUI.FindProperty("_IsZWrite", properties);


        //인스펙터 GUI 표시
        materialEditor.ShaderProperty(_FakeShadowHeightDefault, _FakeShadowHeightDefault.displayName);
        materialEditor.ShaderProperty(_FadeOut, _FadeOut.displayName);
        


        //쉐이더 전처리
        GUILayout.Space(20);
        //bool USEFOG = Array.IndexOf(targetMat.shaderKeywords, "USEFOG") != -1;

        bool TERRITORY = Array.IndexOf(targetMat.shaderKeywords, "TERRITORY") != -1;

        bool Field = Array.IndexOf(targetMat.shaderKeywords, "Field") != -1;

        bool Battle = Array.IndexOf(targetMat.shaderKeywords, "Battle") != -1;


        //__________________________________________________________________________
        EditorGUI.BeginChangeCheck();

        //USEFOG = EditorGUILayout.Toggle("Fog", USEFOG);
        //GUILayout.Space(20);
        TERRITORY = EditorGUILayout.Toggle("TERRITORY Light", TERRITORY);
        Field = EditorGUILayout.Toggle("Field Light", Field);
        Battle = EditorGUILayout.Toggle("Battle Light", Battle);


        //Options
        GUILayout.Space(20);
        materialEditor.ShaderProperty(_Cull, _Cull.displayName);
        materialEditor.ShaderProperty(_IsZWrite, _IsZWrite.displayName);
        materialEditor.RenderQueueField();

        if (EditorGUI.EndChangeCheck())
        {
            //BLENDINGTEX
            //if (USEFOG)
            //{
            //    targetMat.EnableKeyword("USEFOG");
            //}
            //else
            //{
            //    targetMat.DisableKeyword("USEFOG");
            //}

            if (TERRITORY)
            {
                targetMat.EnableKeyword("TERRITORY");
                targetMat.DisableKeyword("Field");
                targetMat.DisableKeyword("Battle");
            }
            else
            {
                targetMat.DisableKeyword("TERRITORY");
            }

            if (Field)
            {
                targetMat.EnableKeyword("Field");
                targetMat.DisableKeyword("TERRITORY");
                targetMat.DisableKeyword("Battle");
            }
            else
            {
                targetMat.DisableKeyword("Field");
            }

            if (Battle)
            {
                targetMat.EnableKeyword("Battle");
                targetMat.DisableKeyword("TERRITORY");
                targetMat.DisableKeyword("Field");
            }
            else
            {
                targetMat.DisableKeyword("Battle");
            }
        }
        //__________________________________________________________________________
    }
}
