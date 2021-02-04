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

        void OnGUI_Mesh()
        {
            GUILayout.BeginVertical("Mesh", GUI.skin.window);
            {
                EditorGUILayout.BeginHorizontal(GUI.skin.box);
                if (GUILayout.Button("Find"))
                {
                    FindMesh(true);
                }

                if (GUILayout.Button("Find - Active"))
                {
                    FindMesh(false);
                }


                if (GUILayout.Button("Clear"))
                {
                    _meshData.Clear();
                    _totalVertex = 0;
                }
                EditorGUILayout.EndHorizontal();


                if (GUILayout.Button("Save - Assets/Mesh.txt"))
                {
                    SaveMeshTxt();
                }


                EditorGUILayout.LabelField("Total Vertices " + _totalVertex.ToString());
                GUILayout.BeginHorizontal(GUI.skin.box);
                GUILayout.Label("Name", _styleHeader, GUILayout.Width(NAME_LENGTH));
                GUILayout.Label("Count", _styleHeader, GUILayout.Width(FORMAT_LENGTH));
                GUILayout.Label("Vertex", _styleHeader, GUILayout.Width(FORMAT_LENGTH));
                GUILayout.Label("Triangle", _styleHeader, GUILayout.Width(FORMAT_LENGTH));
                GUILayout.Label("SubMesh", _styleHeader, GUILayout.Width(FORMAT_LENGTH));
                GUILayout.EndVertical();
                
                _scrollPOS = EditorGUILayout.BeginScrollView(_scrollPOS);
                {
                    for (int i = _meshData.Count - 1; i >= 0; --i)
                    {
                        GUILayout.BeginHorizontal();
                        if( GUILayout.Button(_meshData[i]._name + "/" + _meshData[i]._nameObj, _styleButton, GUILayout.Width(NAME_LENGTH)) )
                        {
                            Selection.activeObject = _meshData[i].meshFilter;
                            EditorGUIUtility.PingObject(_meshData[i].meshFilter);
                        }

                        // 65536 
                        if ( _meshData[i].vertexCount > 65000)
                            GUI.color = Color.red;

                        EditorGUILayout.LabelField(_meshData[i].count.ToString(), _styleCell, GUILayout.Width(FORMAT_LENGTH));
                        EditorGUILayout.LabelField(_meshData[i].vertexCount.ToString(), _styleCell, GUILayout.Width(FORMAT_LENGTH));
                        GUI.color = Color.white;

                        EditorGUILayout.LabelField(_meshData[i].triangleCount.ToString(), _styleCell, GUILayout.Width(FORMAT_LENGTH));
                        EditorGUILayout.LabelField(_meshData[i].subMeshCount.ToString(), _styleCell, GUILayout.Width(FORMAT_LENGTH));
                        GUILayout.EndHorizontal();
                    }
                }
                EditorGUILayout.EndScrollView();
            }
            GUILayout.EndVertical();
        }

        void FindMesh(bool all)
        {

            _meshData.Clear();

            MeshFilter[] meshFilters = (MeshFilter[])Resources.FindObjectsOfTypeAll(typeof(MeshFilter));

            foreach (MeshFilter meshFilter in meshFilters)
            {

                if (all != EditorUtility.IsPersistent(meshFilter))
                    continue;
                
                Object[] o = EditorUtility.CollectDependencies(new UnityEngine.Object[] { meshFilter.sharedMesh });

                foreach (Object obj in o)
                {
                    if (obj is Mesh)
                    {

                        Mesh mesh = obj as Mesh;
                        bool have = false;
                        for (int i = 0; i < _meshData.Count; ++i)
                        {

                            if (_meshData[i]._name == mesh.name)
                            {
                                have = true;
                                _meshData[i].count++;

                                if (_meshData[i]._name.Contains("Combined Mesh") == false)
                                    _meshData[i].vertexCount += mesh.vertexCount;

                            }
                        }

                        if (have == false)
                        {
                            MESHData meshData = new MESHData();
                            meshData._name = mesh.name;
                            meshData._nameObj = meshFilter.gameObject.name;
                            
                            meshData.instanceID = mesh.GetInstanceID();
                            meshData.vertexCount = mesh.vertexCount;
                            meshData.triangleCount = mesh.triangles.Length / 3;
                            meshData.subMeshCount = mesh.subMeshCount;
                            meshData._name = mesh.name;
                            meshData.meshFilter = meshFilter;
                            meshData.count = 1;


                            for (int i = 0; i < mesh.boneWeights.Length; ++i)
                            {
                                if (mesh.boneWeights[i].boneIndex0 != 0 ||
                                    mesh.boneWeights[i].boneIndex1 != 0 ||
                                    mesh.boneWeights[i].boneIndex2 != 0 ||
                                    mesh.boneWeights[i].boneIndex3 != 0)
                                {
                                    meshData.boneWeightsOver = true;
                                }
                            }
                            _meshData.Add(meshData);
                        }
                    }
                }
            }

            _totalVertex = 0;
            for (int i = 0; i < _meshData.Count; ++i)
            {
                _totalVertex += _meshData[i].vertexCount;
            }
            



            _meshData = _meshData.OrderBy(go => go.vertexCount ).ToList();
        }

        void SaveMeshTxt()
        {
            string path = Utility.PathForDocumentsFile("Mesh.txt");
             using (FileStream file = new FileStream(path, FileMode.Create, FileAccess.Write))
             {
                 using (StreamWriter sw = new StreamWriter(file, Encoding.ASCII))
                 {
                     string str = "";
                     for (int i = 0; i < _meshData.Count; ++i)
                     {
                         str += _meshData[i]._name.ToString()+"/" +
                              _meshData[i].meshFilter.gameObject.name.ToString() + "\t " +
                              "Count " + _meshData[i].count.ToString() + "\t " +
                              "Vertex " + _meshData[i].vertexCount.ToString() + "\t" +
                              "Triangle " + _meshData[i].triangleCount.ToString() + "\t" +
                              "Submesh " + _meshData[i].subMeshCount.ToString() + "\t" +
                              "InstanceID " + _meshData[i].instanceID.ToString() + "\r\n";

                         GUI.color = Color.white;
                     }
                     sw.WriteLine(str);
                     sw.Close();
                 }
                 file.Close();
             }
             

        }

        public class MESHData
        {
            public string _name;
            public string _nameObj;
            public int instanceID;
            public int count;
            public int vertexCount;
            public int triangleCount;
            public int subMeshCount;
            public bool boneWeightsOver = false;
            public MeshFilter meshFilter = null;
            public int _count = 0;

        }

        List<MESHData> _meshData = new List<MESHData>();
        int _totalVertex = 0;
    }
}