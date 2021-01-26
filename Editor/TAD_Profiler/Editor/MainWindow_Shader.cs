using UnityEngine;
using System.Text;
using System.IO;
using UnityEditor;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace TAD
{

    public partial class MainWindow : EditorWindow
    {
        private List<ShaderFolder> _listShaderFolder = new List<ShaderFolder>();
        private Vector2 _scrollPOS = Vector2.zero;

        private string _strRootPath = string.Empty;
        private string[] _strShaders = { "" };
        private List<Shader> _listShader = new List<Shader>();

        private int _shaderIndex = 0;

        UnityEngine.SceneManagement.Scene FindDontDestroyScene()
        {
            GameObject go = new GameObject("TADProfiler");
            DontDestroyOnLoad(go);

            UnityEngine.SceneManagement.Scene s = go.scene;
            GameObject.Destroy(go);

            return s;
        }

        void OnGUI_Shader()
        {
            GUILayout.BeginVertical("SHADER", GUI.skin.window);
            {
                GUILayout.BeginHorizontal();
                if (GUILayout.Button("Find"))
                {
                    _listShaderFolder.Clear();

                    {
                        GameObject[] go = UnityEngine.SceneManagement.SceneManager.GetActiveScene().GetRootGameObjects();
                        foreach (GameObject obj in go)
                        {
                            RecursionSHADER(obj.transform);
                        }
                    }

                    {
                        if (Application.isPlaying)
                        {
                            GameObject[] go = FindDontDestroyScene().GetRootGameObjects();
                            foreach (GameObject obj in go)
                            {
                                RecursionSHADER(obj.transform);
                            }
                        }
                    }
                }
                if (GUILayout.Button("Clear"))
                {
                    _listShaderFolder.Clear();
                }
                GUILayout.EndHorizontal();
                    
                if (GUILayout.Button("Save - Assets/Shader.txt"))
                {
                    SaveShaderTxt();
                }

                {
                    GUILayout.BeginVertical(GUI.skin.window);
                    _scrollPOS = EditorGUILayout.BeginScrollView(_scrollPOS);
                    if (_listShaderFolder.Count > 0)
                    {
                        for (int i = 0; i < _listShaderFolder.Count; ++i)
                        {
                            GUILayout.BeginHorizontal();
                            _listShaderFolder[i]._isFold    = EditorGUILayout.Foldout(_listShaderFolder[i]._isFold, _listShaderFolder[i]._name);
                            if( GUILayout.Button("Select", GUILayout.Width(70)) )
                            {
                                Selection.activeInstanceID = _listShaderFolder[i]._shader.GetInstanceID();
                                EditorGUIUtility.PingObject(Selection.activeInstanceID);
                            }
                            
                            string strBtName = _listShaderFolder[i]._isCheck == true ? "Uncheck all" : "Check all";
                            if( GUILayout.Button(strBtName, GUILayout.Width(75)))
                            {
                                _listShaderFolder[i]._isCheck = !_listShaderFolder[i]._isCheck;
                                var lst = _listShaderFolder[i]._listObject;

                                for (int j = 0; j < lst.Count; ++j)
                                {
                                    _listShaderFolder[i]._listObject[j]._isCheck = _listShaderFolder[i]._isCheck;
                                }
                            }

                            GUILayout.EndHorizontal();
                                
                            if( _listShaderFolder[i]._isFold )
                            {
                                var lst = _listShaderFolder[i]._listObject;

                                for( int j=0; j<lst.Count; ++j )
                                {
                                    var tmp = _listShaderFolder[i]._listObject[j];
                                    GUILayout.BeginHorizontal();
                                    GUILayout.Space(20);
                                    tmp._isCheck = GUILayout.Toggle(tmp._isCheck, "", GUILayout.Width(15));
                                    GUILayout.Label(lst[j]._name);
                                    if( GUILayout.Button( "Select", GUILayout.Width(70) ) )
                                    {
                                        EditorGUIUtility.PingObject(lst[j]._renderer.GetInstanceID());
                                        Selection.activeInstanceID = lst[j]._renderer.GetInstanceID();
                                    }
                                    GUILayout.EndHorizontal();
                                }
                            }
                        }
                    }
                    else
                    {
                        GUILayout.Label("Empty");
                    }
                    EditorGUILayout.EndScrollView();
                    GUILayout.EndVertical();
                }

                GUILayout.BeginVertical(GUI.skin.window);
                if( GUILayout.Button("Select Shader Folder") )
                {
                    FindShaderFile();
                }

                _shaderIndex = EditorGUILayout.Popup("Shader", _shaderIndex, _strShaders);

                if( GUILayout.Button("Apply") )
                {
                    ApplyShader();
                    _listShaderFolder.Clear();
                    foreach (GameObject obj in Resources.FindObjectsOfTypeAll(typeof(GameObject)))
                    {
                        RecursionSHADER(obj.transform);
                    }
                    
                }

                GUILayout.EndVertical();
            }
            GUILayout.EndVertical();
        }

        #region Find Shader Files
        void FindShaderFile()
        {
            _listShader.Clear();
            _strRootPath = Path.GetDirectoryName(Application.dataPath);
            string path = EditorUtility.OpenFolderPanel("Select Shader Folder", "", "");
            
            if( path.Length < 1 )
            {
                return;
            }

            RecursionFindShader(path);

            _strShaders = _listShader.Select( s => s.name ).ToArray();
        }

        void LoadShader(string path)
        {
            Shader asset = AssetDatabase.LoadAssetAtPath<Shader>(path);
            if (asset != null)
            {
                _listShader.Add(asset);
            }
        }

        void RecursionFindShader(string path)
        {
            string[] strDir     = Directory.GetDirectories(path);
            string[] strFile    = Directory.GetFiles(path, "*.shader");

            if( strFile.Length > 0 )
            {
                for( int i=0; i<strFile.Length; ++i )
                {
                    strFile[i] = strFile[i].Remove(0, _strRootPath.Length + 1);
                    LoadShader(strFile[i]);
                }
            }

            for( int i=0; i<strDir.Length; ++i )
            {
                RecursionFindShader(strDir[i]);
            }
        }
        #endregion
        
        private void ApplyShader()
        {
            int count = _listShaderFolder.Count;

            if( _listShader.Count < 1 )
            {
                EditorUtility.DisplayDialog("SHADER", "Shader폴더를 선택해주세요", "확인");
                FindShaderFile();
                return;
            }

            for( int i=0; i<count; ++i )
            {
                int childCount = _listShaderFolder[i]._listObject.Count;
                for( int j=0; j<childCount; ++j )
                {
                    var tmp = _listShaderFolder[i]._listObject[j];
                    if( tmp._isCheck )
                    {
                        tmp._renderer.sharedMaterial.shader = _listShader[_shaderIndex];
                    }
                }
            }
        }
        
        private void SaveShaderTxt()
        {
            string path = Utility.PathForDocumentsFile("Shader.txt");
            using (FileStream file = new FileStream(path, FileMode.Create, FileAccess.Write))
            {
                using (StreamWriter sw = new StreamWriter(file, Encoding.ASCII))
                {
                    string str = "";
                    for (int i = 0; i < _listShaderFolder.Count; ++i)
                    {
                        str += _listShaderFolder[i]._count.ToString() + "\t" + _listShaderFolder[i]._name + "\r\n";
                    }
                    sw.WriteLine(str);
                    sw.Close();
                }
                file.Close();
            }
        }

        public class ShaderInfo
        {
            public string   _strName;
            public Shader   _shader;
        }

        public class ShaderFolder
        {
            public string   _name       = string.Empty;
            public int      _count      = 0;
            public Shader   _shader     = null;
            public bool     _isFold     = false,
                            _isCheck    = false;

            public List<ShaderGameObject> _listObject = new List<ShaderGameObject>();
        }

        public class ShaderGameObject
        {
            public string   _name       = string.Empty;
            public Renderer _renderer   = null;
            public bool     _isCheck    = false;
        }

        public void RecursionSHADER(Transform trans)
        {
            Renderer renderer = trans.gameObject.GetComponent<Renderer>();
            if (renderer != null)
            {
                bool have = false;
                if (renderer.sharedMaterial == null)
                    return;

                for (int i = 0; i < _listShaderFolder.Count; ++i )
                {
                    if( _listShaderFolder[i]._name == renderer.sharedMaterial.shader.name )
                    {
                        _listShaderFolder[i]._count++;

                        ShaderGameObject ob = new ShaderGameObject();
                        ob._name = renderer.name;
                        ob._renderer = renderer;
                        _listShaderFolder[i]._listObject.Add(ob);
                        have = true;
                    }
                }

                if (have == false)
                {
                    if (renderer.sharedMaterial == null)
                        return;

                    ShaderFolder folder = new ShaderFolder();
                    folder._name = renderer.sharedMaterial.shader.name;
                    folder._shader = renderer.sharedMaterial.shader;
                    folder._count = 1;

                    ShaderGameObject ob = new ShaderGameObject();
                    ob._name = renderer.name;
                    ob._renderer = renderer;

                    folder._listObject.Add(ob);
                    _listShaderFolder.Add(folder);
                }

            }

            for (int i = 0; i < trans.childCount; ++i)
            {
                RecursionSHADER(trans.GetChild(i));
            }
        }
    }
}