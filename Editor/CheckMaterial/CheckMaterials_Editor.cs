using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class CheckMaterials_Editor : EditorWindow
{
    public class ResourceDetailInfo
    {
        public int instanceID;
        public string name;
    }


    public enum REF_TYPE
    {
        MATERIAL = 0,
        TEXTURE,
        ANIMATIONCLIP,
        SHADER,
        ALL,
    }

    REF_TYPE _refType = REF_TYPE.MATERIAL;

    Vector2 _contentsScroll = Vector2.zero;
    Vector2 _detailScroll = Vector2.zero;

    int _selectIndex = -1;
    int _selectObjInstID = -1;
    
    //미사용 객체로 주석처리합니다.
    //string _selectedName = string.Empty;
    //static Object obj = null;


    string _selectedPath = string.Empty;
    string _destPath = string.Empty;

    //List<string> _refList = new List<string>();

    Dictionary<int, Object> _refList = new Dictionary<int, Object>();
    Dictionary<int, List<ResourceDetailInfo>> _detailList = new Dictionary<int, List<ResourceDetailInfo>>();

    [MenuItem("NDREAM/Check Material Properties...")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        CheckMaterials_Editor window = (CheckMaterials_Editor)EditorWindow.GetWindow(typeof(CheckMaterials_Editor));
        window.titleContent.text = "Check Materials";
        window.minSize = new Vector2(800f, 910f);
        window.Show();
    }

    //     void Update()
    //     {
    //         Repaint();
    //     }

    //    Object[] roots;

    Object srcObj = null;
    Object destObj = null;

    void OnGUI()
    {
        GUILayout.Space(10f);

        DrawInfo();

        GUI.backgroundColor = Color.white;
        EditorGUILayout.BeginHorizontal();
        DrawContents();
        DrawDetails();
        EditorGUILayout.EndHorizontal();
    }

    void DrawInfo()
    {
        EditorGUILayout.BeginHorizontal();
        {
            _refType = (REF_TYPE)EditorGUILayout.EnumPopup("Resource Type", _refType);
        }
        EditorGUILayout.EndHorizontal();

        GUI.backgroundColor = Color.white;

        EditorGUILayout.BeginVertical();

        EditorGUILayout.BeginHorizontal();
        srcObj = EditorGUILayout.ObjectField("Src Path", srcObj, typeof(Object), true);
        GUI.contentColor = Color.green;
        _selectedPath = AssetDatabase.GetAssetPath(srcObj);
        if (Directory.Exists(_selectedPath))
            EditorGUILayout.LabelField("Path : " + _selectedPath);
        else
            EditorGUILayout.LabelField("Path : - ");
        EditorGUILayout.EndHorizontal();
        GUI.contentColor = Color.white;

        EditorGUILayout.BeginHorizontal();
        destObj = EditorGUILayout.ObjectField("Dest Path", destObj, typeof(Object), true);
        GUI.contentColor = Color.cyan;
        _destPath = AssetDatabase.GetAssetPath(destObj);
        if (Directory.Exists(_destPath))
            EditorGUILayout.LabelField("Path : " + _destPath);
        else
            EditorGUILayout.LabelField("Path : - ");
        EditorGUILayout.EndHorizontal();
        GUI.contentColor = Color.white;

        EditorGUILayout.EndVertical();

        GUI.backgroundColor = Color.yellow;
        if (GUILayout.Button("Check"))
        {
            Exec_Check();
        }
        GUI.backgroundColor = Color.white;
    }

    private void Exec_Check()
    {
        if (string.IsNullOrEmpty(_selectedPath) || string.IsNullOrEmpty(_destPath))
        {
            EditorUtility.DisplayDialog("오류", "경로를 확인해 주세요", "확인");
            return;
        }

        _refList.Clear();
        _detailList.Clear();

        List<string> srcGuidList = new List<string>();
        srcGuidList.Clear();

        if (_refType == REF_TYPE.TEXTURE)
            srcGuidList.AddRange(AssetDatabase.FindAssets("t:Texture", new string[] { _selectedPath }));
        else if (_refType == REF_TYPE.MATERIAL)
            srcGuidList.AddRange(AssetDatabase.FindAssets("t:Material", new string[] { _selectedPath }));
        else if (_refType == REF_TYPE.ANIMATIONCLIP)
            srcGuidList.AddRange(AssetDatabase.FindAssets("t:AnimationClip", new string[] { _selectedPath }));
        else if (_refType == REF_TYPE.SHADER)
            srcGuidList.AddRange(AssetDatabase.FindAssets("t:Shader", new string[] { _selectedPath }));
        else
            srcGuidList.AddRange(AssetDatabase.FindAssets("t:Texture t:Material t:AnimationClip", new string[] { _selectedPath }));

        List<string> targetGuidList = new List<string>();
        targetGuidList.Clear();

        if (_refType == REF_TYPE.TEXTURE)
            targetGuidList.AddRange(AssetDatabase.FindAssets("t:Material", new string[] { _destPath }));
        else if (_refType == REF_TYPE.MATERIAL)
            targetGuidList.AddRange(AssetDatabase.FindAssets("t:Prefab", new string[] { _destPath }));
        else if (_refType == REF_TYPE.ANIMATIONCLIP)
            targetGuidList.AddRange(AssetDatabase.FindAssets("t:Prefab", new string[] { _destPath }));
        else if (_refType == REF_TYPE.SHADER)
            targetGuidList.AddRange(AssetDatabase.FindAssets("t:Material", new string[] { _destPath }));
        else
            targetGuidList.AddRange(AssetDatabase.FindAssets("t:Prefab", new string[] { _destPath }));

        foreach (string guid in srcGuidList)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);
            Object obj = AssetDatabase.LoadAssetAtPath(assetPath, typeof(Object));

            if (_refType == REF_TYPE.TEXTURE)
            {
                if (obj is Texture)
                    _refList[obj.GetInstanceID()] = obj;
            }
            else if (_refType == REF_TYPE.MATERIAL)
            {
                if (obj is Material)
                    _refList[obj.GetInstanceID()] = obj;
            }
            else if (_refType == REF_TYPE.ANIMATIONCLIP)
            {
                if (obj is AnimationClip)
                    _refList[obj.GetInstanceID()] = obj;
            }
            else if (_refType == REF_TYPE.SHADER)
            {
                if (obj is Shader)
                    _refList[obj.GetInstanceID()] = obj;
            }
            else
            {
                _refList[obj.GetInstanceID()] = obj;
            }

            foreach (string guids in targetGuidList)
            {
                // 자기 자신의 참조는 제외
                if (guid == guids)
                    continue;

                string path = AssetDatabase.GUIDToAssetPath(guids);
                Object ob = AssetDatabase.LoadAssetAtPath(path, typeof(Object));

                Object[] g = new Object[] { ob };
                Object[] depndencies = EditorUtility.CollectDependencies(g);

                foreach (Object o in depndencies)
                {
                    try
                    {
                        if (null != o && o.GetInstanceID() == obj.GetInstanceID())
                        {
                            if (_detailList.ContainsKey(obj.GetInstanceID()))
                            {
                                ResourceDetailInfo info = new ResourceDetailInfo();
                                info.name = ob.name;
                                info.instanceID = ob.GetInstanceID();

                                _detailList[obj.GetInstanceID()].Add(info);
                            }
                            else
                            {
                                List<ResourceDetailInfo> list = new List<ResourceDetailInfo>();

                                ResourceDetailInfo info = new ResourceDetailInfo();
                                info.name = ob.name;
                                info.instanceID = ob.GetInstanceID();

                                list.Add(info);

                                _detailList[obj.GetInstanceID()] = list;
                            }

                            break;
                        }
                    }
                    catch (System.Exception e)
                    {
                        NDebug.Log(e.Message);
                    }
                }
            }
        }
    }

    void DrawContents()
    {
        EditorGUILayout.BeginVertical(GUILayout.Width(400f)/*, GUILayout.Height(300f)*/);

        NGUIEditorTools.DrawHeader(_refType.ToString(), true);
        {
            GUILayout.Space(3f);

            _contentsScroll = GUILayout.BeginScrollView(_contentsScroll);

            int index = 0;

            try
            {
                foreach (var refObj in _refList)
                {
                    ++index;
                    GUILayout.Space(-1f);
                    bool highlight = (index == _selectIndex);

                    GUI.backgroundColor = highlight ? Color.white : new Color(0.8f, 0.8f, 0.8f);
                    EditorGUILayout.BeginHorizontal("TextArea", GUILayout.MinHeight(20f));
                    GUI.backgroundColor = Color.white;

                    GUILayout.Label(index.ToString(), GUILayout.Width(40f));

                    if (GUILayout.Button(refObj.Value.name, "OL TextField", GUILayout.Height(20f)))
                    {
                        _selectIndex = index;
                        _selectObjInstID = refObj.Value.GetInstanceID();
                        EditorGUIUtility.PingObject(refObj.Value);
                    }

                    string objType = string.Empty;

                    if (refObj.Value is Texture)
                        objType = "Texture";
                    else if (refObj.Value is Material)
                        objType = "Material";
                    else if (refObj.Value is AnimationClip)
                        objType = "AnimationClip";
                    else if (refObj.Value is Shader)
                        objType = "Shader";
                    else if (refObj.Value is Shader)
                        objType = "FBX";

                    GUILayout.Label(objType, GUILayout.Width(60f));

                    //                GUI.backgroundColor = Color.green;
                    //                 if (GUILayout.Button("Check", GUILayout.Width(60f)))
                    //                 {
                    //                     
                    //                 }
                    //                GUI.backgroundColor = Color.white;

                    EditorGUILayout.EndHorizontal();
                }
            }
            catch(System.Exception)
            {
                Exec_Check();
            }

            EditorGUILayout.EndScrollView();
        }

        EditorGUILayout.EndVertical();
        GUILayout.Space(3f);
    }

    void DrawDetails()
    {
        EditorGUILayout.BeginVertical(GUILayout.MinWidth(400f)/*, GUILayout.Height(300f)*/);

        NGUIEditorTools.DrawHeader("USING OBJECT", true);
        {
            GUILayout.Space(3f);

            Object obj = null;
            if (false == _refList.TryGetValue(_selectObjInstID, out obj))
            {
                EditorGUILayout.EndVertical();
                GUILayout.Space(3f);
                return;
            }

            List<ResourceDetailInfo> details = null;
            if(false == _detailList.TryGetValue(obj.GetInstanceID(), out details))
            {
                EditorGUILayout.EndVertical();
                GUILayout.Space(3f);
                return;
            }

            _detailScroll = EditorGUILayout.BeginScrollView(_detailScroll);

            int index = 0;

            foreach (var detail in details)
            {
                ++index;
                GUILayout.Space(-1f);
                bool highlight = (index == _selectIndex);

                GUI.backgroundColor = highlight ? new Color(0.2f, 0.6f, 0.6f, 1) : Color.cyan;
                EditorGUILayout.BeginHorizontal("TextArea", GUILayout.MinHeight(20f));
                GUI.backgroundColor = Color.white;

                GUILayout.Label(index.ToString(), GUILayout.Width(40f));

                if (GUILayout.Button(detail.name, "OL TextField", GUILayout.Height(20f)))
                {
                    _selectIndex = index;

                    EditorGUIUtility.PingObject(detail.instanceID);
                }

                GUI.backgroundColor = Color.white;

                EditorGUILayout.EndHorizontal();
            }

            EditorGUILayout.EndScrollView();
        }

        EditorGUILayout.EndVertical();
        GUILayout.Space(3f);
    }

    void OnInspectorUpdate()
    {
        Repaint();
    }
}

//     static Object obj = null;
// 
// 
//     [MenuItem("Example/Collect Dependencies")]
//     static void Init()
//     {
//         // Get existing open window or if none, make a new one:
//         RefChecker window = (RefChecker)EditorWindow.GetWindow(typeof(RefChecker));
//         window.Show();
//     }
// 
//     void OnGUI()
//     {
//         obj = EditorGUI.ObjectField(new Rect(3, 3, position.width - 6, 20), "Find Dependency", obj, typeof(Object)) as Object;
// 
//         if (obj)
//         {
//             Object[] roots = new Object[] { obj };
// 
//             if (GUI.Button(new Rect(3, 25, position.width - 6, 20), "Check Dependencies"))
//                 Selection.objects = EditorUtility.CollectDependencies(roots);
//         }
//         else
//             EditorGUI.LabelField(new Rect(3, 25, position.width - 6, 20), "Missing:", "Select an object first");
//     }
// 
//     void OnInspectorUpdate()
//     {
//         Repaint();
//    }
//     private static void Open()
//     {
//         string final = "";
//         List<UnityEngine.Object> matches = new List<UnityEngine.Object>();
// 
//         int iid = Selection.activeInstanceID;
//         if (AssetDatabase.IsMainAsset(iid))
//         {
//             // only main assets have unique paths
//             string path = AssetDatabase.GetAssetPath(iid);
//             // strip down the name
//             final = System.IO.Path.GetFileNameWithoutExtension(path);
//         }
//         else
//         {
//             NDebug.Log("Error Asset not found");
//             return;
//         }
// 
//         // get everything
//         Object[] _Objects = Resources.FindObjectsOfTypeAll(typeof(Object));
// 
//         //loop through everything
//         foreach (Object go in _Objects)
//         {
//             // needs to be an array
//             Object[] g = new Object[1];
//             g[0] = go;
// 
//             // All objects
//             Object[] depndencies = EditorUtility.CollectDependencies(g);
//             foreach (Object o in depndencies)
//             {
//                if (o != null)
//                 {
//                     if (string.Compare(o.name.ToString(), final) == 0)
//                     {
//                         matches.Add(go);// add it to our list to highlight
//                     }
//                 }
//             }
//         }
//         Selection.objects = matches.ToArray();
// 
//         foreach (Object obj in Selection.objects)
//         {
//             NDebug.Log("Object : " + obj.name.ToString());
//         }
//         matches.Clear(); // clear the list 
//    }

