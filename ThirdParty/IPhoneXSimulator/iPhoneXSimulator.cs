#region 헤더 코멘트
/// <license>
///      <company>FunGrove/NDREAM Co.</company>
///      <writer>조현준(actdoll.2018~).CF팀.</writer>
///      <title>아이폰X 시뮬레이터</title>
/// </license>
#endregion// 헤더 코멘트
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEditor.Experimental.SceneManagement;
#endif

#if UNITY_EDITOR
[ExecuteInEditMode]
#endif
public class iPhoneXSimulator : MonoBehaviour
{
#if UNITY_EDITOR
	UIPanel m_panel = null;

	bool m_reverse = false;

	public enum eKIND
	{
		IPhoneX,			// 아이폰 X 계열
		GalaxyS10Plus,		// 갤럭시 S10+
		GalaxyS10,			// 갤럭시 S10
		GalaxyNote10Plus,	// 갤럭시 노트10+

		_Max
	}

	public eKIND CurrentKIND { get; private set; } = eKIND.IPhoneX;

	public List<GameObject> phoneImages = new List<GameObject>();

	/// <summary>
	/// 대상 게임오브젝트가 프리팹 스테이지 내에 있는가?
	/// - 프리팹 스테이지 내에 배치된 오브젝트다.
	/// - 실제 프리팹 루트 외에 편집 씬에 배치된 오브젝트까지 판정한다.
	/// </summary>
	bool IsPrefabStageGameObject(GameObject go)
	{
		if(!go)
			return false;

		var prefabStage = PrefabStageUtility.GetCurrentPrefabStage();
		if(prefabStage == null)
			return false;

		var stage = UnityEditor.SceneManagement.StageUtility.GetStageHandle(go);
		return prefabStage.stageHandle == stage;
	}

	private void Start()
	{
		if(IsPrefabStageGameObject(gameObject))
			return;

		m_panel = GetComponent<UIPanel>();
		var uiRoot = FindObjectOfType<UIRoot>();
		if(uiRoot && !transform.IsChildOf(uiRoot.transform))
		{
			transform.parent = uiRoot.transform;
			transform.localScale = Vector3.one;
			transform.localPosition = Vector3.zero;
		}
		SetPhoneKIND(CurrentKIND);
	}

	// Update is called once per frame
	void Update ()
	{
		if(IsPrefabStageGameObject(gameObject))
			return;

		if(!Application.isPlaying)
		{
			m_panel.depth = 100000;
		}
		else
		{
			var newDepth = UIPanel.nextUnusedDepth;
			if(m_panel.depth != newDepth - 1)
				m_panel.depth = newDepth;
		}
	}

	public void ToggleReverse()
	{
		m_reverse = !m_reverse;
		transform.localEulerAngles = !m_reverse ? Vector3.zero : new Vector3(0, 180f, 0);
	}

	public void SetPhoneKIND(eKIND KIND)
	{
		var idx = (int)KIND;
		if(phoneImages.Count <= idx)
			return;

		CurrentKIND = eKIND._Max;
		for(int i=0; i<phoneImages.Count; ++i)
		{
			var img = phoneImages[i];
			if(!img)
				continue;
			img.gameObject.SetActive(i == idx);
			if(i == idx)
				CurrentKIND = KIND;
		}
	}
#endif
}

#if UNITY_EDITOR
/// <summary>
/// 시트 메뉴
/// </summary>
public class iPhoneXSimulatorMenu
{
	static iPhoneXSimulator tmp_target = null;

	public static iPhoneXSimulator GetInstanceInScene()
	{
		// 이미 로딩된 게 있나 확인
		return Object.FindObjectOfType<iPhoneXSimulator>();
	}

	[MenuItem("NDREAM/GUI System/Show Phone Simulate Image", true, 401)]
	public static bool ShowIPhoneXSimulatorQ()
	{
		// 이미 로딩된 게 있나 확인
		var tgt = Object.FindObjectOfType<iPhoneXSimulator>();
		if(tgt)
			return false;

		var rootui = Object.FindObjectOfType<UIRoot>();
		return rootui != null;
	}
	/// <summary>
	/// 메뉴 - 시뮬레이터 만들기
	/// </summary>
	[MenuItem("NDREAM/GUI System/Show Phone Simulate Image", false, 401)]
	public static void ShowIPhoneXSimulator()
	{
		var go = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/ThirdParty/IPhoneXSimulator/iPhoneX_portrait.prefab");
		if (!go)
			return;

        var root = Object.FindObjectOfType<UIRoot>().transform.FindChildRecursive("Camera_NGUI_Overlay").GetChild(0);
        if (!root)
            return;

        go = Object.Instantiate(go, root.transform);
		go.transform.localScale = Vector3.one;
		go.transform.localPosition = Vector3.zero;
		go.transform.SetAsFirstSibling();
	}

	[MenuItem("NDREAM/GUI System/Hide Phone Simulate Image", true, 402)]
	public static bool HideIPhoneXSimulatorQ()
	{
		tmp_target = null;

		// 이미 로딩된 게 있나 확인
		tmp_target = Object.FindObjectOfType<iPhoneXSimulator>();
		return tmp_target != null;
	}
	/// <summary>
	/// 시뮬레이터 제거하기
	/// </summary>
	[MenuItem("NDREAM/GUI System/Hide Phone Simulate Image", false, 402)]
	public static void HideIPhoneXSimulator()
	{
		if(!tmp_target)
			return;

		Object.DestroyImmediate(tmp_target.gameObject);
		tmp_target = null;
	}

	[MenuItem("NDREAM/GUI System/Reverse Phone Image", true, 403)]
	public static bool ReverseIPhoneXSimulatorQ()
	{
		tmp_target = null;

		// 이미 로딩된 게 있나 확인
		tmp_target = Object.FindObjectOfType<iPhoneXSimulator>();
		return tmp_target != null;
	}
	/// <summary>
	/// 시뮬레이터 반전시키기
	/// </summary>
	[MenuItem("NDREAM/GUI System/Reverse Phone Image", false, 403)]
	public static void ReverseIPhoneXSimulator()
	{
		if(!tmp_target)
			return;

		tmp_target.ToggleReverse();
	}

	[MenuItem("NDREAM/GUI System/Change Phone Image", true, 404)]
	public static bool ChangeTestPhoneImageQ()
	{
		tmp_target = null;

		// 이미 로딩된 게 있나 확인
		tmp_target = Object.FindObjectOfType<iPhoneXSimulator>();
		return tmp_target?.gameObject.activeInHierarchy ?? false;
	}
	/// <summary>
	/// 폰 이미지 교체
	/// </summary>
	[MenuItem("NDREAM/GUI System/Change Phone Image", false, 404)]
	public static void ChangeTestPhoneImage()
	{
		if(!tmp_target || !tmp_target.gameObject.activeInHierarchy)
			return;

		var kind = tmp_target.CurrentKIND;
		kind++;
		if(kind >= iPhoneXSimulator.eKIND._Max)
			kind = iPhoneXSimulator.eKIND.IPhoneX;
		tmp_target.SetPhoneKIND(kind);
	}
}
#endif