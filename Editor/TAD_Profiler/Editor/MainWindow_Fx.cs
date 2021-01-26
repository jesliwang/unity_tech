using UnityEngine;
using System.Text;
using System.IO;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;

namespace TAD
{

    public partial class MainWindow : EditorWindow
    {

        void OnGUI_Fx()
        {
           
            GUILayout.BeginVertical("FX", GUI.skin.window);
            {
                if (GUILayout.Button("Scan"))
                {
                    Debug.Break();
                    _fxData.Clear();

                    GameObject[] go = UnityEngine.SceneManagement.SceneManager.GetActiveScene().GetRootGameObjects();
                    foreach (GameObject obj in go)
                    {
                        RecursionFX(obj.transform);
                    }

                    if (Application.isPlaying)
                    {
                        GameObject[] ggo = FindDontDestroyScene().GetRootGameObjects();
                        foreach (GameObject obj in ggo)
                        {
                            RecursionFX(obj.transform);
                        }
                    }


                    return;
                            //ResourceManager.instance._load = (o, path) =>
                            //{
                            //    if (o.name.Contains("fx_"))
                            //    {
                            //        bool have = false;
                            //        for (int i = 0; i < _fxData.Count; ++i)
                            //        {
                            //            if (_fxData[i]._name == o.name)
                            //            {
                            //                _fxData[i]._count++;
                            //                have = true;
                            //                break;
                            //            }
                            //        }
                            //        if (have == false)
                            //        {
                            //            FxData fxData = new FxData();
                            //            fxData._count = 1;
                            //            fxData._name = o.name;
                            //            string strTemp = "Assets/Resources/ResourcesInGame/fx/" + path + ".prefab";
                            //            fxData._prefab = AssetDatabase.LoadAssetAtPath(strTemp, typeof(GameObject));
                            //            _fxData.Add(fxData);
                            //        }
                            //    }
                            //};
                }

                if (GUILayout.Button("Clear"))
                {
                    _fxData.Clear();
                }

                if (GUILayout.Button("저장 - Assets/Fx.txt"))
                {
                    string path = Utility.PathForDocumentsFile("Fx.txt");
                    using (FileStream file = new FileStream(path, FileMode.Create, FileAccess.Write))
                    {
                        using (StreamWriter sw = new StreamWriter(file))
                        {
                            string str = "";
                            for (int i = 0; i < _fxData.Count; ++i)
                            {
                                str += _fxData[i]._name + "\r\n";
                            }
                            sw.WriteLine(str);
                            sw.Close();
                        }
                        file.Close();
                    }
                }

                EditorGUILayout.LabelField("LIST");

                GUILayout.BeginHorizontal(GUI.skin.box);
                GUILayout.Label("Name", _styleHeaderLeft);
                GUILayout.EndHorizontal();
                _scrollVec = EditorGUILayout.BeginScrollView(_scrollVec);
                {
                    for (int i = 0; i < _fxData.Count; ++i)
                    {
                        GUILayout.BeginHorizontal();

                        if (GUILayout.Button(_fxData[i]._name, _styleButton))
                        {
                            Selection.activeObject = _fxData[i]._transform;
                            EditorGUIUtility.PingObject(_fxData[i]._transform);
                        }

                        GUILayout.EndHorizontal();
                    }
                }
                EditorGUILayout.EndScrollView();
            }
            GUILayout.EndVertical();      
        }



        void RecursionFX(Transform tf)
        {
            int count = tf.childCount;

            Transform t = null;

            for ( int i=0; i<count; ++i )
            {
                t = tf.GetChild(i);

                if( t.name.IndexOf("FX_") != -1 || t.name.IndexOf("fx_") != -1 )
                {
                    FxData fxData = new FxData();
                    fxData._count = 1;
                    fxData._name = t.name;
                    fxData._transform = t;
                    //string strTemp = "Assets/Resources/ResourcesInGame/fx/" + path + ".prefab";
                    //fxData._prefab = AssetDatabase.LoadAssetAtPath(strTemp, typeof(GameObject));
                    _fxData.Add(fxData);
                }

                RecursionFX(t);
                t = null;
            }
        }

        //public bool _fx = false;
        public class FxData
        {
            public string   _name;
            public int      _count;
            //public Object  _prefab;
            public Transform _transform;
        }
        List<FxData> _fxData = new List<FxData>();
        Vector2 _scrollVec = Vector2.zero;
    }
}