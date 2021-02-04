#pragma warning disable 0618

using UnityEngine;
using System.Text;
using System.IO;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.Linq;


namespace TAD
{

    public partial class MainWindow : EditorWindow
    {
    
        const int   NAME_LENGTH = 250,
                    WIDTH_LENGTH = 70,
                    HEIGHT_LENGTH = 70,
                    MEMORY_LENGTH = 100,
                    FORMAT_LENGTH = 100,
                    MIPMAP_LENGTH = 100;
        void OnGUI_Textrue()
        {
            GUILayout.BeginVertical("TEXTURE", GUI.skin.window);
            {
                EditorGUILayout.BeginHorizontal(GUI.skin.box);
                if (GUILayout.Button("Find All"))
                {
                    _textureData.Clear();

                    
                    var sortAll = FindObjectsOfTypeIncludingAssets(typeof(Texture2D)).OrderBy(go => UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(go)).ToList();
                    //var sortAll = Resources.FindObjectsOfTypeAll(typeof(Texture2D)).OrderBy(go => Profiler.GetRuntimeMemorySize(go)).ToList();
                    
                    for (int i = 0; i < sortAll.Count; ++i)
                    {
                        Texture2D texture = sortAll[i] as Texture2D;
                        if (texture != null)
                        {
                            TextureData textureData = new TextureData();
                            textureData._name = texture.name;
                            textureData._ToString = texture.ToString();
                            textureData.anisoLevel = texture.anisoLevel;
                            textureData.dimension = texture.dimension;
                            textureData.filterMode = texture.filterMode;
                            textureData.height = texture.height;
                            textureData.width = texture.width;
                            textureData.memory = UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(sortAll[i]) / 1024;
                            textureData.textureFormat = texture.format;
                            textureData.mipmapCount = texture.mipmapCount;
                            textureData.texture = texture;

                            _textureData.Add(textureData);
                            //memTexture += Profiler.GetRuntimeMemorySize(sortAll[i]);
                            //Debug.Log(sortAll[i].name + "/ " + Profiler.GetRuntimeMemorySize(sortAll[i]).ToString() + "/" + (memTexture / 1024).ToString() + "KB");
                        }
                    }
                }
                
                if (GUILayout.Button("Find Hierarchy"))
                {
                    _textureData.Clear();

                    Renderer[] renderers = (Renderer[])Resources.FindObjectsOfTypeAll(typeof(Renderer));
                    //Renderer[] renderers = (Renderer[])FindObjectsOfTypeAll(typeof(Renderer));
                    //Debug.Log("Total renderers "+renderers.Length);
                    foreach (Renderer renderer in renderers)
                    {
                        if (EditorUtility.IsPersistent(renderer))
                            continue;

                        foreach (Material material in renderer.sharedMaterials)
                        {
                            foreach (Object obj in EditorUtility.CollectDependencies(new UnityEngine.Object[] { material }))
                            {
                                if (obj is Texture2D)
                                {

                                    Texture2D texture = obj as Texture2D;
                                    bool have = false;
                                    if (texture != null)
                                    {
                                        for (int i = 0; i < _textureData.Count; ++i)
                                        {
                                            if (_textureData[i]._name == texture.name)
                                            {
                                                have = true;
                                            }
                                        }
                                    }

                                    if (have == false)
                                    {
                                        if (texture.name.Length == 0 || texture.name == "")
                                        {
                                            Debug.Log(renderer.transform.name);
                                        }
                                        TextureData textureData = new TextureData();
                                        textureData._name = texture.name;
                                        textureData._ToString = texture.ToString();
                                        textureData.anisoLevel = texture.anisoLevel;
                                        textureData.dimension = texture.dimension;
                                        textureData.filterMode = texture.filterMode;
                                        textureData.height = texture.height;
                                        textureData.width = texture.width;
                                        textureData.memory = UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(texture) / 1024;
                                        textureData.textureFormat = ((Texture2D)texture).format;
                                        textureData.mipmapCount = ((Texture2D)texture).mipmapCount;
                                        textureData.renderer = renderer;

                                        _textureData.Add(textureData);
                                    }
                                }
                            }
                        }
                    }


                    _textureData = _textureData.OrderBy(go => go.memory ).ToList();
                }

                if (GUILayout.Button("Clear"))
                {
                    _textureData.Clear();
                }
                EditorGUILayout.EndHorizontal();

                if (GUILayout.Button("Save - Assets/Texture.txt"))
                {
                    string path = Utility.PathForDocumentsFile("Texture.txt");
                    using (FileStream file = new FileStream(path, FileMode.Create, FileAccess.Write))
                    {
                        using (StreamWriter sw = new StreamWriter(file, Encoding.ASCII))
                        {
                            string str = "";
                            for (int i = 0; i < _textureData.Count; ++i)
                            {
                                str += _textureData[i]._name.ToString() + "\t" +
                                     "w " + _textureData[i].width.ToString() + ", " +
                                      "h " + _textureData[i].height.ToString() + "\t" +
                                      "mem " + _textureData[i].memory.ToString() + "KB \t" +
                                      "format " + _textureData[i].textureFormat.ToString() + "\t" +
                                      "mipmap " + _textureData[i].mipmapCount.ToString() + "\r\n";

                                GUI.color = Color.white;
                            }
                            sw.WriteLine(str);
                            sw.Close();
                        }
                        file.Close();
                    }
                }

                GUILayout.BeginVertical(GUI.skin.window);
                // Column head

                GUILayout.BeginHorizontal(GUI.skin.box);
                GUILayout.Label("Name", _styleHeader, GUILayout.Width(NAME_LENGTH));
                GUILayout.Label("Width", _styleHeader, GUILayout.Width(WIDTH_LENGTH));
                GUILayout.Label("Height", _styleHeader, GUILayout.Width(HEIGHT_LENGTH));
                GUILayout.Label("Memory(KB)", _styleHeader, GUILayout.Width(MEMORY_LENGTH));
                GUILayout.Label("Format", _styleHeader, GUILayout.Width(FORMAT_LENGTH));
                GUILayout.Label("Mipmap", _styleHeader, GUILayout.Width(MIPMAP_LENGTH));
                GUILayout.EndHorizontal();
                _scrollPOS = EditorGUILayout.BeginScrollView(_scrollPOS);
                {
                    int count = _textureData.Count;
                    for (int i =  count-1 ; i >= 0 ; --i)
                    {
                        GUILayout.BeginHorizontal();
                        _styleCell.alignment = TextAnchor.MiddleLeft;
                        if (GUILayout.Button(_textureData[i]._name, _styleButton, GUILayout.Width(NAME_LENGTH)))
                        {
                            if (_textureData[i].texture != null )
                            {
                                EditorGUIUtility.PingObject(_textureData[i].texture);
                            }
                            else if (_textureData[i].renderer != null)
                            {
                                Selection.activeObject = _textureData[i].renderer;
                                EditorGUIUtility.PingObject(_textureData[i].renderer);
                            }
                            
                        }
                        //정사각형아니면
                        if (_textureData[i].width != _textureData[i].height)
                            GUI.color = Color.red;
                        //2048보다 크면
                        if (_textureData[i].width > 2048 || _textureData[i].height > 2048)
                            GUI.color = Color.red;

                        _styleCell.alignment = TextAnchor.MiddleCenter;
                        EditorGUILayout.LabelField(_textureData[i].width.ToString(), _styleCell, GUILayout.Width(WIDTH_LENGTH));
                        EditorGUILayout.LabelField(_textureData[i].height.ToString(), _styleCell, GUILayout.Width(HEIGHT_LENGTH));
                        
                        GUI.color = Color.white;

                        //택스처 메모리 용량이 크면
                        if (_textureData[i].memory > 1024)
                            GUI.color = Color.yellow;

                        if (_textureData[i].memory > 2048)
                            GUI.color = Color.red;

                        EditorGUILayout.LabelField(_textureData[i].memory.ToString(), _styleCell, GUILayout.Width(MEMORY_LENGTH));
                        GUI.color = Color.white;

                        //타입 및 압축
                        if (_textureData[i].textureFormat.ToString().Contains("ETC") == false)
                            GUI.color = Color.red;
                        EditorGUILayout.LabelField(_textureData[i].textureFormat.ToString(), _styleCell, GUILayout.Width(MIPMAP_LENGTH));
                        GUI.color = Color.white;
                        
                        if (_textureData[i].mipmapCount <= 1)
                            GUI.color = Color.yellow;

                        EditorGUILayout.LabelField(_textureData[i].mipmapCount.ToString(), _styleCell, GUILayout.Width(MIPMAP_LENGTH));
                        GUI.color = Color.white;

                        GUILayout.EndHorizontal();
                    }
                }
                EditorGUILayout.EndScrollView();
                GUILayout.EndVertical();
            }
            GUILayout.EndVertical();
        }

        public class TextureData
        {
            public string _name;
            public string _ToString;
            
            public int anisoLevel;
            public UnityEngine.Rendering.TextureDimension dimension;
            public FilterMode filterMode;
            public float height;
            public float width;
            public Vector2 texelSize;
            public int memory;
            public TextureFormat textureFormat;
            public int mipmapCount;
            public Texture texture = null;
            public Renderer renderer = null;
        }

        List<TextureData> _textureData = new List<TextureData>();

        public void RecursionTEXTURE(Transform trans)
        {
            Renderer renderer = trans.gameObject.GetComponent<Renderer>();
            if (renderer != null && renderer.sharedMaterial != null && renderer.sharedMaterial.mainTexture != null)
            {
                
                for (int t = 0; t < 1; ++t)
                {
                    bool have = false;
                    Texture texture = renderer.sharedMaterial.mainTexture;
                    if (texture != null)
                    {
                        for (int i = 0; i < _textureData.Count; ++i)
                        {
                            if (_textureData[i]._name == texture.name)
                            {
                                have = true;
                            }
                        }
                    }
                    
                    if (have == false)
                    {
                        if( texture.name.Length == 0 || texture.name == "" )
                        {
                            Debug.Log(trans);
                        }
                        TextureData textureData = new TextureData();
                        textureData._name = texture.name;
                        textureData._ToString = texture.ToString();
                        textureData.anisoLevel = texture.anisoLevel;
                        textureData.dimension = texture.dimension;
                        textureData.filterMode = texture.filterMode;
                        textureData.height = texture.height;
                        textureData.width = texture.width;
                        textureData.memory = UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(texture) / 1024;
                        textureData.textureFormat = ((Texture2D)texture).format;
                        textureData.mipmapCount = ((Texture2D)texture).mipmapCount;

                        _textureData.Add(textureData);
                    }
                }
              

            }

            for (int i = 0; i < trans.childCount; ++i)
            {
                RecursionTEXTURE(trans.GetChild(i));
            }
        }
    }
}