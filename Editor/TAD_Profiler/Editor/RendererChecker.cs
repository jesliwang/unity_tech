using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;

namespace GSB2
{
    public class RendererChecker : EditorWindow
    {
        public class PrefData
        {
            public GameObject           _hierarchyObj   = null;
            public UnityEngine.Object   _prefabObj      = null;
        };

        private const string TITLE_NAME = "Renderer Checker";
        private static RendererChecker _instance;
        private List<PrefData> _RootPrefData = new List<PrefData>();
        private Vector2 _vScrollPos = Vector2.zero;

        [MenuItem("TAD/Renderer Checker")]
        public static void ShowWindow()
        {
            RendererChecker.instance.Show();
        }

        public static RendererChecker instance
        {
            get
            {
                if( _instance == null )
                {
                    _instance = EditorWindow.GetWindow<RendererChecker>(false, TITLE_NAME, true);
                }
                return _instance;
            }
        }


        void Awake()
        {
            GameObject[] go = UnityEngine.SceneManagement.SceneManager.GetActiveScene().GetRootGameObjects();
            for( int i=0; i<go.Length; ++i )
            {
                Debug.Log(go[i].transform.root);
            }
        }

        void OnGUI()
        {
            if( GUILayout.Button("Find disable Renderer") )
            {
                FindDisabledRenderer();
            }

            EditorGUILayout.BeginVertical(GUI.skin.window);
            _vScrollPos = EditorGUILayout.BeginScrollView(_vScrollPos);
            int count = _RootPrefData.Count;
            for (int i = 0; i < count; ++i )
            {
                GUILayout.BeginHorizontal();
                GUILayout.Label(_RootPrefData[i]._prefabObj.name, GUILayout.Width(200));
                if( GUILayout.Button( "Select Prefab" ) )
                {
                    Selection.activeObject = _RootPrefData[i]._prefabObj;
                    EditorGUIUtility.PingObject(Selection.activeInstanceID);
                }

                if( GUILayout.Button( "Select Hierarchy GameObject") )
                {
                    Selection.activeGameObject = _RootPrefData[i]._hierarchyObj;
                    EditorGUIUtility.PingObject(Selection.activeInstanceID);
                }
                GUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
            EditorGUILayout.EndVertical();
        }

        void FindDisabledRenderer()
        {
            _RootPrefData.Clear();
            GameObject[] go = UnityEngine.SceneManagement.SceneManager.GetActiveScene().GetRootGameObjects();
            UnityEngine.Object tmpObj = null;
            for (int i = 0; i < go.Length; ++i)
            {
                Renderer[] rd = go[i].GetComponentsInChildren<Renderer>();
                for( int j=0; j<rd.Length; ++j)
                {
                    if( rd[j].enabled == false )
                    {
                        tmpObj = PrefabUtility.GetPrefabParent(rd[j].gameObject);
                        if( tmpObj != null )
                        {
                            PrefData d = new PrefData();
                            d._hierarchyObj = rd[j].gameObject;
                            d._prefabObj    = tmpObj;
                            _RootPrefData.Add(d);
                        }
                    }
                }
            }
        }
    }
}
