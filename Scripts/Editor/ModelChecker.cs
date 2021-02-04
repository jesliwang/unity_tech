using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;

namespace GSB2
{
    public class FBXFile
    {
        public ModelImporter    _ModelImporter  = null;
        public GameObject       _GameObject     = null;
        public string           _strFileName    = null;
    }

    public class Folder
    {
        public string           _strFolderName  = string.Empty;
        public string           _strFullPath    = string.Empty;
        public DefaultAsset     _folderAsset    = null;
        public List<FBXFile>    _listFBX        = new List<FBXFile>();
        public bool             _bFold          = false;
    }

    public class ModelChecker : EditorWindow
    {
        private const string TITLE_NAME = "Model Checker";
        private static ModelChecker _instance;
        private List<Folder> _RootFolder = new List<Folder>();


        private ModelImporterMeshCompression    _eMeshCompression           = ModelImporterMeshCompression.Off;
        private ModelImporterNormals            _eImporterNormals           = ModelImporterNormals.Import;
        private ModelImporterTangents           _eImporterTangents          = ModelImporterTangents.Import;
        private ModelImporterMaterialName       _eImporterMaterialName      = ModelImporterMaterialName.BasedOnMaterialName;
        private ModelImporterMaterialSearch     _eImporterMaterialSearch    = ModelImporterMaterialSearch.Local;

        private DefaultAsset    _SelectedFolder = null;
        
        private bool    _ReadWriteEnable        = false,
                        _OptimizeMesh           = false,
                        _ImportBlendShapes      = false,
                        _GenerateColliders      = false,
                        _KeepQuads              = false,
                        _SwapUVs                = false,
                        _GenerateLightmapUVs    = false,
                        _ImportMaterials        = false,
                        _uiFolderAdvanced       = false,
                        _bSameFolder            = false,
                        _bUseFileScale          = false,
                        _bImportVisibility      = false,
                        _bImportCameras         = false,
                        _bImportLights          = false,
                        _bWeldVertices          = false;

        private float   _fileScale      = 0.0f,
                        _scaleFactor    = 0.0f;
        private int     _HardAngle      = 0,
                        _PackMargin     = 0,
                        _AngleError     = 0,
                        _AreaError      = 0,
                        _SmoothAngle    = 0;

        private string  _strRootPath    = string.Empty,
                        _strSelectPath  = string.Empty;

        private string[] _strMaterialNaming = { "By Base Texture Name", 
                                                "From Model's Material", 
                                                "Model Name + Model's Material" };

        private Vector2 _vScrollPos     = Vector2.zero;

        #region Init Window
        [MenuItem("TAD/Model Checker")]
        public static void ShowWindow()
        {
            ModelChecker.instance.Show();
        }

        public static ModelChecker instance
        {
            get
            {
                if( _instance == null )
                {
                    _instance = EditorWindow.GetWindow<ModelChecker>(false, TITLE_NAME, true);
                }

                return _instance;
            }
        }
        #endregion

        void Awake()
        {
            _strRootPath = System.IO.Path.GetDirectoryName(Application.dataPath);
        }

        void OnGUI()
        {
            OnDrawOptionUI();
            OnDrawList();
        }

        void OnDrawOptionUI()
        {
            EditorGUILayout.LabelField("Meshes", EditorStyles.boldLabel);
            _scaleFactor            = EditorGUILayout.FloatField("Scale Factor", _scaleFactor);
            _bUseFileScale          = EditorGUILayout.Toggle("Use File Scale", _bUseFileScale);
            GUI.enabled             = _bUseFileScale;
            _fileScale              = EditorGUILayout.FloatField("   File Scale", _fileScale);
            GUI.enabled             = true;
            _eMeshCompression       = (ModelImporterMeshCompression)EditorGUILayout.EnumPopup("Mesh Compression", _eMeshCompression);
            _ReadWriteEnable        = EditorGUILayout.Toggle("Read/Write Enabled", _ReadWriteEnable);
            _OptimizeMesh           = EditorGUILayout.Toggle("Optimize Mesh", _OptimizeMesh);
            _ImportBlendShapes      = EditorGUILayout.Toggle("Import BlendShapes", _ImportBlendShapes);
            _GenerateColliders      = EditorGUILayout.Toggle("Generate Colliders", _GenerateColliders);
            _KeepQuads              = EditorGUILayout.Toggle("Keep Quads", _KeepQuads);
            _bWeldVertices          = EditorGUILayout.Toggle("Weld Vertices", _bWeldVertices);
            _bImportVisibility      = EditorGUILayout.Toggle("Import Visibility", _bImportVisibility);
            _bImportCameras         = EditorGUILayout.Toggle("Import Cameras", _bImportCameras);
            _bImportLights          = EditorGUILayout.Toggle("Import Lights", _bImportLights);
            _SwapUVs                = EditorGUILayout.Toggle("Swap UVs", _SwapUVs);
            _GenerateLightmapUVs    = EditorGUILayout.Toggle("Generate Lightmap UVs", _GenerateLightmapUVs);
            if( _GenerateLightmapUVs )
            {
                _uiFolderAdvanced   = EditorGUILayout.Foldout(_uiFolderAdvanced, "Advanced");
                if (_uiFolderAdvanced)
                {
                    _HardAngle  = EditorGUILayout.IntSlider("   Hard Angle", _HardAngle, 0, 180);
                    _PackMargin = EditorGUILayout.IntSlider("   Pack Margin", _PackMargin, 0, 180);
                    _AngleError = EditorGUILayout.IntSlider("   Angle Error", _AngleError, 0, 180);
                    _AreaError  = EditorGUILayout.IntSlider("   Area Error", _AreaError, 0, 180);
                }
            }
            

            EditorGUILayout.LabelField("Normals & Tangents", EditorStyles.boldLabel);
            _eImporterNormals = (ModelImporterNormals)EditorGUILayout.EnumPopup("Normals", _eImporterNormals);

            GUI.enabled     = _eImporterNormals == ModelImporterNormals.Calculate;
            _SmoothAngle    = EditorGUILayout.IntSlider("Smooth Angles", _SmoothAngle, 0, 180);
            GUI.enabled     = _eImporterNormals != ModelImporterNormals.None;
            _eImporterTangents = (ModelImporterTangents)EditorGUILayout.EnumPopup("Tangents", _eImporterTangents);
            GUI.enabled = true;

            EditorGUILayout.LabelField("Materials", EditorStyles.boldLabel);
            _ImportMaterials = EditorGUILayout.Toggle("ImportMaterials", _ImportMaterials);
            if( _ImportMaterials )
            {
                _eImporterMaterialName      = (ModelImporterMaterialName)EditorGUILayout.Popup("Material Naming", (int)_eImporterMaterialName, _strMaterialNaming);
                _eImporterMaterialSearch    = (ModelImporterMaterialSearch)EditorGUILayout.EnumPopup("Material Search", _eImporterMaterialSearch);
            }

            GUILayout.BeginHorizontal();
            if( GUILayout.Button("Find") )
            {
                FindModelImport();
            }

            if( GUILayout.Button("Apply"))
            {
                ApplyModelImport();
            }
            GUILayout.EndHorizontal();
        }

        void OnDrawList()
        {
            int count = _RootFolder.Count;

            GUILayout.BeginVertical(GUI.skin.window);

            if ( !_bSameFolder )
            {
                GUILayout.BeginHorizontal();
                EditorGUILayout.LabelField(_strSelectPath, EditorStyles.boldLabel);
                if (GUILayout.Button("Select", GUILayout.Width(70)))
                {
                    Selection.activeInstanceID = _SelectedFolder.GetInstanceID();
                    EditorGUIUtility.PingObject(Selection.activeInstanceID);
                }
                GUILayout.EndHorizontal();
            }

            _vScrollPos = EditorGUILayout.BeginScrollView(_vScrollPos);
            for( int i=0; i<count; ++i)
            {
                GUILayout.BeginHorizontal();
                _RootFolder[i]._bFold = EditorGUILayout.Foldout(_RootFolder[i]._bFold, _RootFolder[i]._strFullPath);
                if( GUILayout.Button("Select", GUILayout.Width(70)) )
                {
                    Selection.activeInstanceID = _RootFolder[i]._folderAsset.GetInstanceID();
                    EditorGUIUtility.PingObject(Selection.activeInstanceID);
                }
                GUILayout.EndHorizontal();
                if( _RootFolder[i]._bFold )
                {
                    int fbxCount = _RootFolder[i]._listFBX.Count;
                    for( int fi=0; fi<fbxCount; ++fi )
                    {
                        if( GUILayout.Button( _RootFolder[i]._listFBX[fi]._strFileName, EditorStyles.toolbarButton ) )
                        {
                            Selection.activeInstanceID = _RootFolder[i]._listFBX[fi]._GameObject.GetInstanceID();
                            EditorGUIUtility.PingObject(Selection.activeInstanceID);
                        }
                    }
                }
            }
            EditorGUILayout.EndScrollView();
            GUILayout.EndVertical();
            
            
        }

        void FindModelImport()
        {
            _strSelectPath = string.Empty;
            _SelectedFolder = null;
            _RootFolder.Clear();
            if (Selection.activeObject == null ||
                !(Selection.activeObject is DefaultAsset))
            {
                EditorUtility.DisplayDialog(TITLE_NAME, "폴더를 선택해주세요", "확인");
                return;
            }

            _strSelectPath = AssetDatabase.GetAssetPath(Selection.activeObject);
            string message = string.Format(" {0} \n폴더를 탑색합니다.", _strSelectPath);

            bool bOK = EditorUtility.DisplayDialog(TITLE_NAME, message, "OK", "Cancel");
            if (bOK)
            {
                _SelectedFolder = (DefaultAsset)Selection.activeObject;
                string strFullPath = string.Format("{0}/{1}", _strRootPath, _strSelectPath);
                RecursionFolder(strFullPath);
            }
        }

        void ApplyModelImport()
        {
            _RootFolder.Clear();
            if (Selection.activeObject == null ||
                !(Selection.activeObject is DefaultAsset))
            {
                EditorUtility.DisplayDialog(TITLE_NAME, "폴더를 선택해주세요", "확인");
                return;
            }

            string strCurPath = AssetDatabase.GetAssetPath(Selection.activeObject);
            string message = string.Format(" {0} \n폴더에 있는 ModelImporter에 적용합니다.\n 진행하시겠습니까?.", strCurPath);

            bool bOK = EditorUtility.DisplayDialog(TITLE_NAME, message, "OK", "Cancel");
            if (bOK)
            {
                string strFullPath = string.Format("{0}/{1}", _strRootPath, strCurPath);
                RecursionFolder(strFullPath, true);
                message = string.Format("{0}\n폴더에 있는 ModelImporter에 적용하였습니다.", strCurPath);
                EditorUtility.DisplayDialog(TITLE_NAME, message, "확인");
            }
        }

        void RecursionFolder(string path, bool bApply = false)
        {
            string[] strDir = Directory.GetDirectories(path);
            string[] strFbx = Directory.GetFiles(path, "*.fbx");

            if( strFbx.Length > 0 )
            {
                Folder newFolder = new Folder();
                newFolder._strFullPath = path.Remove(0, _strRootPath.Length + 1);
                newFolder._folderAsset = (DefaultAsset)AssetDatabase.LoadAssetAtPath(newFolder._strFullPath, typeof(DefaultAsset));

                if (newFolder._strFullPath != _strSelectPath)
                {
                    newFolder._strFullPath = newFolder._strFullPath.Remove(0, _strSelectPath.Length + 1);
                }
                else
                {
                    _bSameFolder = true;
                }
                
                for (int i = 0; i < strFbx.Length; ++i)
                {
                    string str = strFbx[i].Remove(0, _strRootPath.Length + 1);
                    ModelImporter mi = (ModelImporter)AssetImporter.GetAtPath(str);
                    GameObject go = AssetDatabase.LoadAssetAtPath<GameObject>(str);

                    if (mi != null)
                    {
                        if( bApply )
                        {
                            ApplyOptions(mi);
                        }
                        else
                        {
                            if (false == IsEqualOption(mi))
                            {
                                FBXFile fbx = new FBXFile();
                                fbx._ModelImporter = mi;
                                fbx._GameObject = go;
                                fbx._strFileName = Path.GetFileNameWithoutExtension(mi.assetPath);
                                newFolder._listFBX.Add(fbx);
                            }
                        }
                    }
                }

                if( !bApply )
                {
                    _RootFolder.Add(newFolder);
                }
                
            }            

            for (int i = 0; i < strDir.Length; ++i )
            {
                RecursionFolder(strDir[i]);
            }
        }

        void ApplyOptions(ModelImporter mi)
        {
            mi.globalScale          = _scaleFactor;
            mi.useFileScale         = _bUseFileScale;
            //read only....
            //mi.fileScale = _fileScale; 
            mi.meshCompression      = _eMeshCompression;
            mi.isReadable           = _ReadWriteEnable;
            mi.optimizeMeshVertices         = _OptimizeMesh;
            mi.importBlendShapes    = _ImportBlendShapes;
            mi.addCollider          = _GenerateColliders;
            // Keep Quads 변수가 안보인다...

            mi.weldVertices         = _bWeldVertices;
            mi.importVisibility     = _bImportVisibility;
            mi.importCameras        = _bImportCameras;
            mi.importLights         = _bImportLights;

            mi.swapUVChannels       = _SwapUVs;
            mi.generateSecondaryUV  = _GenerateLightmapUVs;
            if (mi.generateSecondaryUV == true)
            {
                mi.secondaryUVHardAngle = _HardAngle;
                mi.secondaryUVPackMargin = _PackMargin;
                mi.secondaryUVAngleDistortion = _AngleError;
                mi.secondaryUVAreaDistortion = _AreaError;
            }


            mi.importNormals = _eImporterNormals;
            if (mi.importNormals != ModelImporterNormals.None)
            {
                mi.normalSmoothingAngle = _SmoothAngle;
                mi.importTangents = _eImporterTangents;
            }

            //mi.materialImportMode = _ImportMaterials;
            //if (mi.materialImportMode == true)
            //{
            //    mi.materialName = _eImporterMaterialName;
            //    mi.materialSearch = _eImporterMaterialSearch;
            //}
        }

        bool IsEqualOption(ModelImporter mi)
        {
            if( mi.globalScale != _scaleFactor )
            {
                return false;
            }

            if( mi.useFileScale != _bUseFileScale )
            {
                return false;
            }

            //if( mi.fileScale != _fileScale )
            //{
            //    return false;
            //}

            if( mi.meshCompression != _eMeshCompression )
            {
                return false;
            }

            if( mi.isReadable != _ReadWriteEnable )
            {
                return false;
            }

            if( mi.optimizeMeshVertices != _OptimizeMesh )
            {
                return false;
            }

            if( mi.importBlendShapes != _ImportBlendShapes)
            {
                return false;
            }

            if( mi.addCollider != _GenerateColliders )
            {
                return false;
            }

            // Keep Quads 없다....

            if( mi.weldVertices != _bWeldVertices )
            {
                return false;
            }

            if( mi.importVisibility != _bImportVisibility )
            {
                return false;
            }

            if( mi.importCameras != _bImportCameras )
            {
                return false;
            }

            if( mi.importLights != _bImportLights )
            {
                return false;
            }

            if( mi.swapUVChannels != _SwapUVs )
            {
                return false;
            }

            if (mi.generateSecondaryUV != _GenerateLightmapUVs)
            {
                return false;
            }
            else if( mi.generateSecondaryUV == true )
            {
                if( _HardAngle != (int)mi.secondaryUVHardAngle)
                {
                    return false;
                }

                if (_PackMargin != (int)mi.secondaryUVPackMargin)
                {
                    return false;
                }

                if (_AngleError != (int)mi.secondaryUVAngleDistortion)
                {
                    return false;
                }

                if (_AreaError != (int)mi.secondaryUVAreaDistortion)
                {
                    return false;
                }
            }

            
            //if( mi.importNormals != _eImporterNormals )
            //{
            //    return false;
            //}
            //else if( mi.importNormals != ModelImporterNormals.None )
            //{
            //    if( _SmoothAngle != mi.normalSmoothingAngle )
            //    {
            //        return false;
            //    }

            //    if( _eImporterTangents != mi.importTangents )
            //    {
            //        return false;
            //    }
            //}

            //if( _ImportMaterials != mi.materialImportMode )
            //{
            //    return false;
            //}
            //else if( mi.materialImportMode == true )
            //{
            //    if( _eImporterMaterialName != mi.materialName )
            //    {
            //        return false;
            //    }

            //    if( _eImporterMaterialSearch != mi.materialSearch )
            //    {
            //        return false;
            //    }
            //}

            return true;
        }
    }
}