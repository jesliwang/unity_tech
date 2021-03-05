using UnityEngine;
using UnityEditor;
using System;

public class ShaderGUI_NGUI_TransparentColored : ShaderGUI
{
    public enum FXMode
    {
        Additive,
        AlphaBlend,
        Invert,
        //Dissolve,
    }

    private MaterialProperty fxModeProp;
    private MaterialProperty texNumProp;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //메터리얼 타겟 설정
        Material targetMat = materialEditor.target as Material;

		//UI 프로퍼티 받아오기
		MaterialProperty _MainTex = ShaderGUI.FindProperty("_MainTex", properties);
		MaterialProperty _UseTransTex = FindProperty("_UseTransTex", properties);
		MaterialProperty _TransTex = ShaderGUI.FindProperty("_TransTex", properties);
		MaterialProperty _UseGrayscale = FindProperty("_UseGrayscale", properties);
		MaterialProperty _Grayscale = ShaderGUI.FindProperty("_Grayscale", properties);

		this.fxModeProp = ShaderGUI.FindProperty("_BlendMode", properties);

        FXMode fxmode = (FXMode)this.fxModeProp.floatValue;

        EditorGUI.BeginChangeCheck();


        //인스펙터 GUI 표시
        GUILayout.Space(20);
        fxmode = (FXMode)EditorGUILayout.Popup("FX Mode", (int)fxmode, Enum.GetNames(typeof(FXMode)));

        GUILayout.Space(20);
        materialEditor.ShaderProperty(_MainTex, _MainTex.displayName);
		//	조현준 (2020/08/06 1:12) : CF 동기화. 알파텍스쳐 사용여부 키워드 결정
		if(_UseTransTex != null)
			materialEditor.ShaderProperty(_UseTransTex, _UseTransTex.displayName);
		if(_TransTex != null)
		{
			//	키워드가 없거나 키워드 등록된 상태라면 알파텍스쳐 프로퍼티 출력
			if (_UseTransTex == null || _UseTransTex.floatValue > 0f)
				materialEditor.ShaderProperty(_TransTex, _TransTex.displayName);
		}
		//	조현준 (2020/08/06 1:12) : CF 동기화. 그레이스케일 사용여부 키워드 결정
		if (_UseGrayscale != null)
			materialEditor.ShaderProperty(_UseGrayscale, _UseGrayscale.displayName);
		if (_Grayscale != null)
		{
			if (_UseTransTex == null || _UseTransTex.floatValue > 0f)
				materialEditor.ShaderProperty(_Grayscale, _Grayscale.displayName);
		}

		GUILayout.Space(20);
        materialEditor.RenderQueueField();
        materialEditor.DoubleSidedGIField();



        if (EditorGUI.EndChangeCheck())
        {
            //Blend Mode
            this.fxModeProp.floatValue = (float)fxmode;
            foreach (UnityEngine.Object obj in this.fxModeProp.targets)
                this.SetupBlendMode(obj as Material, fxmode);
        }
    }

    //블렌드모드
    private void SetupBlendMode(Material targetMat, FXMode fxMode)
    {
        switch (fxMode)
        {
            case FXMode.Additive:
                targetMat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
                targetMat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.One);
                break;

            case FXMode.Invert:
                targetMat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.Zero);
                targetMat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcColor);
                break;

            case FXMode.AlphaBlend:
                targetMat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
                targetMat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                break;
        }
    }
}


