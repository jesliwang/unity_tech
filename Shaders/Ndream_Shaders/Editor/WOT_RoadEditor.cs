using UnityEngine;
using UnityEditor;
using System;

public class WOT_RoadEditor : ShaderGUI
{

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {

        //메터리얼 타겟 설정
        Material targetMat = materialEditor.target as Material;


        //UI 프로퍼티 받아오기
        MaterialProperty _MainTex = ShaderGUI.FindProperty("_MainTex", properties);
        MaterialProperty _X_Tile = ShaderGUI.FindProperty("_X_Tile", properties);
        MaterialProperty _RoadMask = ShaderGUI.FindProperty("_RoadMask", properties);
        MaterialProperty _MainTexMask = ShaderGUI.FindProperty("_MainTexMask", properties);

        
        MaterialProperty _BrendTex = ShaderGUI.FindProperty("_BrendTex", properties);
        MaterialProperty _BrendMask = ShaderGUI.FindProperty("_BrendMask", properties);

        //RIVER
        MaterialProperty _RiverNormalMap_A = ShaderGUI.FindProperty("_RiverNormalMap_A", properties);
        MaterialProperty _RiverNormalMap_B = ShaderGUI.FindProperty("_RiverNormalMap_B", properties);
        
        MaterialProperty _RiverColor = ShaderGUI.FindProperty("_RiverColor", properties);
        MaterialProperty _RiverfloorAlpha = ShaderGUI.FindProperty("_RiverfloorAlpha", properties);
        MaterialProperty _RiverReflact = ShaderGUI.FindProperty("_RiverReflact", properties);

        MaterialProperty _RiverSpecularColor = ShaderGUI.FindProperty("_RiverSpecularColor", properties);
        MaterialProperty _RiverSpecularRange = ShaderGUI.FindProperty("_RiverSpecularRange", properties);
        
        MaterialProperty _RiverNormalMap_A_Time_V = ShaderGUI.FindProperty("_RiverNormalMap_A_Time_V", properties);
        
        MaterialProperty _RiverNormalMap_B_Time_V = ShaderGUI.FindProperty("_RiverNormalMap_B_Time_V", properties);


        //WAVE
        MaterialProperty _FoamTex_A = ShaderGUI.FindProperty("_FoamTex_A", properties);
        MaterialProperty _WaveFoamMask = ShaderGUI.FindProperty("_WaveFoamMask", properties);
        MaterialProperty _Wave_Speed = ShaderGUI.FindProperty("_Wave_Speed", properties);
        
         

        //Options
        MaterialProperty _Cull = ShaderGUI.FindProperty("_Cull", properties);
        MaterialProperty _IsZWrite = ShaderGUI.FindProperty("_IsZWrite", properties);


        //인스펙터 GUI 표시
        //materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
        //materialEditor.ShaderProperty(_RoadMask, _RoadMask.displayName);
        


        //쉐이더 전처리
        GUILayout.Space(20);
        bool ROAD = Array.IndexOf(targetMat.shaderKeywords, "ROAD") != -1;
        bool BLENDINGTEX = Array.IndexOf(targetMat.shaderKeywords, "BLENDINGTEX") != -1;
        bool RIVER = Array.IndexOf(targetMat.shaderKeywords, "RIVER") != -1;
        bool WAVE = Array.IndexOf(targetMat.shaderKeywords, "WAVE") != -1;


        //__________________________________________________________________________
        EditorGUI.BeginChangeCheck();

        //ROAD
        ROAD = EditorGUILayout.Toggle("ROAD 1", ROAD);
        if (ROAD)
        {
            materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
            materialEditor.ShaderProperty(_RoadMask, _RoadMask.displayName);
            materialEditor.ShaderProperty(_X_Tile, _X_Tile.displayName);
            materialEditor.ShaderProperty(_MainTexMask, _MainTexMask.displayName);
        }


        //Blending
        GUILayout.Space(20);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        BLENDINGTEX = EditorGUILayout.Toggle("ROAD 2", BLENDINGTEX);
        if (BLENDINGTEX)
        {
            GUILayout.Space(20);
            materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
            materialEditor.ShaderProperty(_RoadMask, _RoadMask.displayName);
            materialEditor.ShaderProperty(_X_Tile, _X_Tile.displayName);
            materialEditor.ShaderProperty(_MainTexMask, _MainTexMask.displayName);
            GUILayout.Space(20);
            materialEditor.ShaderProperty(_BrendTex, _BrendTex.displayName);
            materialEditor.ShaderProperty(_BrendMask, _BrendMask.displayName);
        }


        //RIVER
        GUILayout.Space(20);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        RIVER = EditorGUILayout.Toggle("RIVER", RIVER);
        if (RIVER)
        {
            materialEditor.ShaderProperty(_RiverColor, _RiverColor.displayName);

            GUILayout.Space(20);
            materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
            materialEditor.ShaderProperty(_X_Tile, _X_Tile.displayName);
            materialEditor.ShaderProperty(_MainTexMask, _MainTexMask.displayName);

            materialEditor.ShaderProperty(_RiverNormalMap_A, _RiverNormalMap_A.displayName);
            materialEditor.ShaderProperty(_RiverNormalMap_B, _RiverNormalMap_B.displayName);

            GUILayout.Space(20);
            materialEditor.ShaderProperty(_RiverfloorAlpha, _RiverfloorAlpha.displayName);
            materialEditor.ShaderProperty(_RiverReflact, _RiverReflact.displayName);

            GUILayout.Space(20);
            materialEditor.ShaderProperty(_RiverSpecularColor, _RiverSpecularColor.displayName);
            materialEditor.ShaderProperty(_RiverSpecularRange, _RiverSpecularRange.displayName);

            GUILayout.Space(20);
            materialEditor.ShaderProperty(_RiverNormalMap_A_Time_V, _RiverNormalMap_A_Time_V.displayName);
            materialEditor.ShaderProperty(_RiverNormalMap_B_Time_V, _RiverNormalMap_B_Time_V.displayName);
        }


        //WAVE
        GUILayout.Space(20);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        WAVE = EditorGUILayout.Toggle("WAVE", WAVE);
        if (WAVE)
        {
            materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
            materialEditor.ShaderProperty(_X_Tile, _X_Tile.displayName);
            materialEditor.ShaderProperty(_FoamTex_A, _FoamTex_A.displayName);
            GUILayout.Space(20);
            materialEditor.ShaderProperty(_WaveFoamMask, _WaveFoamMask.displayName);
            materialEditor.ShaderProperty(_MainTexMask, _MainTexMask.displayName);
            GUILayout.Space(20);
            materialEditor.ShaderProperty(_Wave_Speed, _Wave_Speed.displayName);
        }


        //Options
        GUILayout.Space(20);
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(2.0f) });
        materialEditor.ShaderProperty(_Cull, _Cull.displayName);
        materialEditor.ShaderProperty(_IsZWrite, _IsZWrite.displayName);
        materialEditor.RenderQueueField();

        if (EditorGUI.EndChangeCheck())
        {
            //ROAD
            if (ROAD)
            {
                targetMat.EnableKeyword("ROAD");
                targetMat.DisableKeyword("BLENDINGTEX");
                targetMat.DisableKeyword("RIVER");
                targetMat.DisableKeyword("WAVE");
            }
            else
            {
                targetMat.DisableKeyword("ROAD");
            }


            //BLENDINGTEX
            if (BLENDINGTEX)
            {
                targetMat.EnableKeyword("BLENDINGTEX");
                targetMat.DisableKeyword("ROAD");
                targetMat.DisableKeyword("RIVER");
                targetMat.DisableKeyword("WAVE");
            }
            else
            {
                targetMat.DisableKeyword("BLENDINGTEX");
            }


            //RIVER
            if (RIVER)
            {
                targetMat.EnableKeyword("RIVER");
                targetMat.DisableKeyword("ROAD");
                targetMat.DisableKeyword("BLENDINGTEX");
                targetMat.DisableKeyword("WAVE");
            }
            else
            {
                targetMat.DisableKeyword("RIVER");
            }

            //RIVER
            if (WAVE)
            {
                targetMat.EnableKeyword("WAVE");
                targetMat.DisableKeyword("ROAD");
                targetMat.DisableKeyword("BLENDINGTEX");
                targetMat.DisableKeyword("RIVER");
            }
            else
            {
                targetMat.DisableKeyword("WAVE");
            }


        }
        //__________________________________________________________________________
    }
}
