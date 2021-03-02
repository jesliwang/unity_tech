using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System;
using CheckModelTool;

namespace CheckModelTool
{
    public class CheckModelPropTool : EditorWindow
    {
        enum CheckType
        {
            CheckNone = 0,
            CheckScaleFactor = 1 << 0,
            CheckMeshCompression = 1 << 1,
            CheckReadWriteEnabled = 1 << 2,
            CheckOptimizeMesh = 1 << 3,
            CheckImportBlendShapes = 1 << 4,
            CheckGenerateColliders = 1 << 5,
            CheckKeepQuads = 1 << 6,
            CheckSwapUVs = 1 << 7,
            CheckGenerateLightmapUVs = 1 << 8,
            CheckImportMaterials = 1 << 9,
            CheckTangents = 1 << 10,
            CheckMaterialNaming = 1 << 11,
            CheckMaterialSearch = 1 << 12,
            CheckUVCount = 1 << 13,
            CheckVertexColor = 1 << 14,
            CheckNormalsOption = 1 << 15,
            CheckIndexFormat = 1 << 16,
            CheckImportAnimation = 1 << 17,
        }

        enum BOOL : byte
        {
            FALSE,
            TRUE,
        };

        enum TANGENTS : byte
        {
            Import = 0,
            Calculate_Legacy = 1,
            None = 2,
            Calculate_Tangent_Space = 3,
            Calculate_Legacy_Split_Tangents = 4
        };

        enum MATERIAL_NAMING : byte
        {
            By_Base_Texture_Name = 0,
            From_Models_Material = 1,
            Model_Name_Models_Material = 2,
        };

        enum MATERIAL_SEARCH : byte
        {
            Local_Materials_Folder = 0,
            Recursive_Up = 1,
            Project_Wide = 2,
        };

        enum NORMALS : byte
        {
            Import = 0,
            Calculate = 1,
            None = 2,
        };

        enum SortType
        {
            ModelName,
            UVCount,
            VertextCount,
        }
        


        string selectedFolder;
        List<string> modelGUID = new List<string>();
        List<CustomModelData> savedModelData = new List<CustomModelData>();
        Dictionary<int, CustomModelData> dicFilteredData = new Dictionary<int, CustomModelData>(); // Key - InstanceID

        // 필터링 옵션 저장 파일 경로
        const string savePath = @"ToolSettingData";
        const string saveFileName = "/CehckModelPropTool.dat";

        // 에디터 스크롤 변수
        Vector2 scroll;

        // 필터링 옵션
        int CheckTypes = 0;

        // 필더링 옵션 기본값
        float baseScaleFactor = 0.01f;
        ModelImporterMeshCompression baseMeshCompression = ModelImporterMeshCompression.Off;
        BOOL baseReadWriteEnabled = BOOL.FALSE;
        BOOL baseOptimizeMesh = BOOL.FALSE;
        BOOL baseImportBlendShapes = BOOL.FALSE;
        BOOL baseGenerateColliders = BOOL.FALSE;
        //BOOL baseKeepQuads = BOOL.FALSE;
        BOOL baseSwapUVs = BOOL.FALSE;
        BOOL baseGenerateLightmapUVs = BOOL.FALSE;
        TANGENTS baseTangents = TANGENTS.Import;
        BOOL baseImportMaterials = BOOL.FALSE;
        MATERIAL_NAMING baseMaterialName = MATERIAL_NAMING.By_Base_Texture_Name;
        MATERIAL_SEARCH baseMaterialSearch = MATERIAL_SEARCH.Local_Materials_Folder;
        byte baseUVCount = 2;
        BOOL baseVertexColorSet = BOOL.FALSE;
        NORMALS baseNormalsOption = NORMALS.Calculate;
        Byte baseSmoothingAngle = 180;
        ModelImporterIndexFormat baseIndexFormat = ModelImporterIndexFormat.Auto;
        BOOL baseImportAnimation = BOOL.FALSE;

        // 정렬
        SortType _sortType = SortType.ModelName;
        bool _sortDir = true;

        // 선택 표시
        int _InstID = 0;

        [MenuItem("NDREAM/Check Model Properties...")]
        static public void InitWindow()
        {
            CheckModelPropTool window = (CheckModelPropTool)EditorWindow.GetWindow<CheckModelPropTool>();
            if (window == null)
            {
                return;
            }
            window.titleContent.text = "NDREAM : Model Properties";
            window.minSize = new Vector2(960, 470);
            window.Show();

            System.GC.Collect();
        }

        void OnGUI()
        {
            GUILayout.Space(10f);

            GUI.contentColor = Color.yellow;
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("ModelPropTool   |   " + selectedFolder);
            EditorGUILayout.EndHorizontal();
            GUI.contentColor = Color.white;

            DrawButton();

            EditorGUILayout.BeginVertical();
            DrawFilters();
            FilteringData();
            DrawScrollList();
            EditorGUILayout.EndVertical();
        }

        void GetModelDataFromFolders()
        {
            modelGUID.Clear();
            savedModelData.Clear();

            modelGUID.AddRange(AssetDatabase.FindAssets("t:Model", new string[] { selectedFolder }));

            foreach (string GUID in modelGUID)
            {
                CustomModelData data = new CustomModelData();
                if (data.InitFromGUID(GUID))
                    savedModelData.Add(data);
            }
        }

        bool GetFolderFromSelection(UnityEngine.Object selection)
        {
            string selectedPath = AssetDatabase.GetAssetPath(selection);
            if (Directory.Exists(selectedPath))
            {
                selectedFolder = selectedPath;
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// recursive folder seach 추가 해야 함
        /// </summary>
        void OnSelectionChange()
        {
            //EditorUtility.UnloadUnusedAssetsIgnoreManagedReferences();
            //System.GC.Collect();

            //if (GetFolderFromSelection(Selection.activeObject))
            //{
            //    GetModelDataFromFolders();
            //}
            //else
            //{
            //    NDebug.Log("selection is not a folder");
            //}
        }

        private bool BOOLTobool(BOOL eData)
        {
            if (eData == BOOL.TRUE)
                return true;

            return false;
        }

        bool GetCheckType(int checkTypes, CheckType type)
        {
            return (checkTypes & (int)type) != 0;
        }

        void SetCheckType(CheckType type)
        {
            CheckTypes = CheckTypes ^ (int)type;
        }

        void DrawButton()
        {
            Rect screenButtonRect = new Rect(620, 5, 100, 50);
            GUILayout.BeginArea(screenButtonRect);
            GUI.backgroundColor = Color.yellow;
            if (GUILayout.Button("Save Filter"))
            {
                SaveFilterOption();
            }
            GUILayout.EndArea();

            //screenButtonRect = new Rect(620, 5, 100, 50);
            //GUILayout.BeginArea(screenButtonRect);
            //GUI.backgroundColor = Color.yellow;
            //if (GUILayout.Button("Load Filter"))
            //{
            //    LoadFilterOption();
            //}
            //GUILayout.EndArea();

            screenButtonRect = new Rect(730, 5, 100, 50);
            GUILayout.BeginArea(screenButtonRect);
            GUI.backgroundColor = Color.yellow;
            if (GUILayout.Button("출력"))
            {
                Print();
            }
            GUILayout.EndArea();

            screenButtonRect = new Rect(840, 5, 100, 50);
            GUILayout.BeginArea(screenButtonRect);
            GUI.backgroundColor = Color.yellow;
            if (GUILayout.Button("검색"))
            {
                Search();
            }
            GUILayout.EndArea();

            GUI.backgroundColor = Color.white;
        }

        void DrawFilters()
        {
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.BeginVertical("box", GUILayout.Width(300));
                {
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckScaleFactor)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("1. Scale Factor is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckScaleFactor);
                        GUI.backgroundColor = Color.white;

                        baseScaleFactor = EditorGUILayout.FloatField(baseScaleFactor, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckOptimizeMesh)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("4. Optimize Mesh is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckOptimizeMesh);
                        GUI.backgroundColor = Color.white;

                        baseOptimizeMesh = (BOOL)EditorGUILayout.EnumPopup(baseOptimizeMesh, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckSwapUVs)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("7. Swap UVs is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckSwapUVs);
                        GUI.backgroundColor = Color.white;

                        baseSwapUVs = (BOOL)EditorGUILayout.EnumPopup(baseSwapUVs, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckTangents)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("10. Tangents is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckTangents);
                        GUI.backgroundColor = Color.white;

                        baseTangents = (TANGENTS)EditorGUILayout.EnumPopup(baseTangents, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckUVCount)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("13. UV-Count is more than", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckUVCount);
                        GUI.backgroundColor = Color.white;

                        baseUVCount = (byte)EditorGUILayout.IntField((int)baseUVCount, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    //Index Format
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckIndexFormat)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("16. Index Format is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckIndexFormat);
                        GUI.backgroundColor = Color.white;

                        baseIndexFormat = (ModelImporterIndexFormat)EditorGUILayout.EnumPopup(baseIndexFormat, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();


                }
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical("box", GUILayout.Width(300));
                {
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckMeshCompression)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("2. Mesh Compression is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckMeshCompression);
                        GUI.backgroundColor = Color.white;

                        baseMeshCompression = (ModelImporterMeshCompression)EditorGUILayout.EnumPopup(baseMeshCompression, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckImportBlendShapes)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("5. Import BlendShapes is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckImportBlendShapes);
                        GUI.backgroundColor = Color.white;

                        baseImportBlendShapes = (BOOL)EditorGUILayout.EnumPopup(baseImportBlendShapes, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();
                    

                    //EditorGUILayout.BeginHorizontal();
                    //{
                    //    if (GetCheckType(CheckTypes, CheckType.CheckKeepQuads)) GUI.backgroundColor = Color.green;
                    //    if (GUILayout.Button("Keep Quads is not ", GUILayout.Width(200)))
                    //        SetCheckType(CheckType.CheckKeepQuads);
                    //    GUI.backgroundColor = Color.white;

                    //    baseKeepQuads = (BOOL)EditorGUILayout.EnumPopup(baseKeepQuads, GUILayout.Width(100));
                    //}
                    //EditorGUILayout.EndHorizontal();
                    

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckGenerateLightmapUVs)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("8. Generate Lightmap UVs is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckGenerateLightmapUVs);
                        GUI.backgroundColor = Color.white;

                        baseGenerateLightmapUVs = (BOOL)EditorGUILayout.EnumPopup(baseGenerateLightmapUVs, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckMaterialNaming)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("11. Material Naming is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckMaterialNaming);
                        GUI.backgroundColor = Color.white;

                        baseMaterialName = (MATERIAL_NAMING)EditorGUILayout.EnumPopup(baseMaterialName, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckVertexColor)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("14. VertexColor Setting is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckVertexColor);
                        GUI.backgroundColor = Color.white;

                        baseVertexColorSet = (BOOL)EditorGUILayout.EnumPopup(baseVertexColorSet, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    //Import Animation
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckImportAnimation)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("17. Import Animation is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckImportAnimation);
                        GUI.backgroundColor = Color.white;

                        baseImportAnimation = (BOOL)EditorGUILayout.EnumPopup(baseImportAnimation, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();


                }
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical("box", GUILayout.Width(300));
                {
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckReadWriteEnabled)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("3. Read/Write Enabled is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckReadWriteEnabled);
                        GUI.backgroundColor = Color.white;

                        baseReadWriteEnabled = (BOOL)EditorGUILayout.EnumPopup(baseReadWriteEnabled, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckGenerateColliders)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("6. Generate Colliders is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckGenerateColliders);
                        GUI.backgroundColor = Color.white;

                        baseGenerateColliders = (BOOL)EditorGUILayout.EnumPopup(baseGenerateColliders, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckImportMaterials)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("9. Import Materials is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckImportMaterials);
                        GUI.backgroundColor = Color.white;

                        baseImportMaterials = (BOOL)EditorGUILayout.EnumPopup(baseImportMaterials, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckMaterialSearch)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("12. MaterialSearch is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckMaterialSearch);
                        GUI.backgroundColor = Color.white;

                        baseMaterialSearch = (MATERIAL_SEARCH)EditorGUILayout.EnumPopup(baseMaterialSearch, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();
                    

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GetCheckType(CheckTypes, CheckType.CheckNormalsOption)) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("15. Normars Option is not ", GUILayout.Width(200)))
                            SetCheckType(CheckType.CheckNormalsOption);
                        GUI.backgroundColor = Color.white;

                        baseNormalsOption = (NORMALS)EditorGUILayout.EnumPopup(baseNormalsOption, GUILayout.Width(100));
                    }
                    EditorGUILayout.EndHorizontal();

                    if (baseNormalsOption == NORMALS.Calculate)
                    {
                        EditorGUILayout.BeginHorizontal();
                        //GUI.enabled = baseNormalsOption == NORMALS.Calculate ? true : false;
                        baseSmoothingAngle = (Byte)EditorGUILayout.IntSlider(baseSmoothingAngle, 0, 180, GUILayout.Width(300));
                        //GUI.enabled = true;
                        EditorGUILayout.EndHorizontal();
                    }

                }
                EditorGUILayout.EndVertical();
                
            }
            EditorGUILayout.EndHorizontal();
            
        }

        void SetSortType(SortType _type)
        {
            if (_sortType != _type)
            {
                _sortType = _type;
                _sortDir = true;
            }
            else
                _sortDir = !_sortDir;
        }
        void DrawScrollList()
        {
            if (dicFilteredData != null)
            {
                EditorGUILayout.BeginHorizontal();
                GUI.contentColor = Color.yellow;
                EditorGUILayout.LabelField(string.Format("폴더 모델 수 : {0}", dicFilteredData.Count()), GUILayout.Width(160));
                GUI.contentColor = Color.white;

                GUI.backgroundColor = Color.white;
                if (GUILayout.Button("Name", GUILayout.Width(250)))
                {
                    SetSortType(SortType.ModelName);
                    SortingData();
                }

                if (GUILayout.Button("UV Count", GUILayout.Width(120)))
                {
                    SetSortType(SortType.UVCount);
                    SortingData();
                }

                if (GUILayout.Button("Total VertextCount", GUILayout.Width(150)))
                {
                    SetSortType(SortType.VertextCount);
                    SortingData();
                }

                if (GUILayout.Button("Filter Type", GUILayout.Width(240)))
                {
                }

                EditorGUILayout.EndHorizontal();
            }
            scroll = EditorGUILayout.BeginScrollView(scroll);
            if (dicFilteredData == null || dicFilteredData.Count() == 0)
            {
                EditorGUILayout.LabelField("없음.");
            }
            else
            {
                foreach (CustomModelData t in dicFilteredData.Values)
                {
                    EditorGUILayout.BeginHorizontal();

                    GUI.backgroundColor = Color.yellow;
                    if (GUILayout.Button("모델 위치로!!", GUILayout.Width(160)))
                    {
                        EditorGUIUtility.PingObject(t.instanceID);
                    }

                    if (_InstID.Equals(t.instanceID))
                        GUI.backgroundColor = Color.blue;
                    else
                        GUI.backgroundColor = Color.white;

                    if (GUILayout.Button(t.name, GUI.skin.textField, GUILayout.Width(250)))
                        _InstID = t.instanceID;

                    if (GUILayout.Button(string.Format("{0}", t.useUVCount), GUI.skin.textField, GUILayout.Width(120)))
                        _InstID = t.instanceID;

                    if (GUILayout.Button(string.Format("{0}", t.vertexCount), GUI.skin.textField, GUILayout.Width(150)))
                        _InstID = t.instanceID;

                    if (GUILayout.Button(GetStringWrongFilterType(t), GUI.skin.textField, GUILayout.Width(240)))
                        _InstID = t.instanceID;

                    GUI.backgroundColor = Color.yellow;
                    EditorGUILayout.EndHorizontal();
                }
            }
            EditorGUILayout.EndScrollView();
        }

        bool CheckScaleFactor(float val)
        {
            return val != baseScaleFactor;
        }

        bool CheckMeshCompression(CustomModelData d)
        {
            return d.meshCompression != baseMeshCompression;
        }

        bool CheckReadWriteEnabled(CustomModelData d)
        {
            return d.readWriteEnabled != BOOLTobool(baseReadWriteEnabled);
        }

        bool CheckOptimizeMesh(CustomModelData d)
        {
            return d.optimizeMesh != BOOLTobool(baseOptimizeMesh);
        }

        bool CheckImportBlendShapes(CustomModelData d)
        {
            return d.importBlendShapes != BOOLTobool(baseImportBlendShapes);
        }

        bool CheckGenerateColliders(CustomModelData d)
        {
            return d.generateColliders != BOOLTobool(baseGenerateColliders);
        }

        //bool CheckKeepQuads(CustomModelData d)
        //{
        //    return d.keepQuads != BOOLTobool(baseKeepQuads);
        //}

        bool CheckSwapUVs(CustomModelData d)
        {
            return d.swapUV != BOOLTobool(baseSwapUVs);
        }

        bool CheckGenerateLightmapUVs(CustomModelData d)
        {
            return d.generateLightmapUVs != BOOLTobool(baseGenerateLightmapUVs);
        }

        bool CheckImportMaterials(CustomModelData d)
        {
            return d.importMaterials != BOOLTobool(baseImportMaterials);
        }

        bool CheckTangents(CustomModelData d)
        {
            return d.tangents != (ModelImporterTangents)baseTangents;
        }

        bool CheckMaterialNaming(CustomModelData d)
        {
            return d.materialName != (ModelImporterMaterialName)baseMaterialName;
        }

        bool CheckMaterialSearch(CustomModelData d)
        {
            return d.materialSearch != (ModelImporterMaterialSearch)baseMaterialSearch;
        }

        bool CheckUVCount(CustomModelData d)
        {
            return d.useUVCount >= baseUVCount;
        }

        bool CheckVertexColor(CustomModelData d)
        {
            return d.vertextColorSet != BOOLTobool(baseVertexColorSet);
        }

        bool CheckNormalsOption(CustomModelData d)
        {
            bool bCheck = d.normals != (ModelImporterNormals)baseNormalsOption;

            // 같은대 조건이 Calculate이면
            if (!bCheck && baseNormalsOption == NORMALS.Calculate)
            {
                if (d.smoothingAngle < baseSmoothingAngle)
                    bCheck = true;
            }

            return bCheck;
        }
        
        //Indexx Format(16)
        bool CheckIndexFormat(CustomModelData d)
        {
            return d.IndexFormat != baseIndexFormat;
        }

        bool CheckImportAnimation(CustomModelData d)
        {
            return d.ImportAnimation != BOOLTobool(baseImportAnimation);
        }


        void SortingData()
        {
            if (savedModelData == null || savedModelData.Count == 0)
                return;

            switch (_sortType)
            {
                case SortType.ModelName:
                    if (_sortDir)
                        savedModelData.Sort(delegate (CustomModelData v1, CustomModelData v2) { return v1.name.CompareTo(v2.name); });
                    else
                        savedModelData.Sort(delegate (CustomModelData v1, CustomModelData v2) { return v2.name.CompareTo(v1.name); });
                    break;

                case SortType.UVCount:
                    if (_sortDir)
                        savedModelData.Sort(delegate (CustomModelData v1, CustomModelData v2) { return v1.useUVCount.CompareTo(v2.useUVCount); });
                    else
                        savedModelData.Sort(delegate (CustomModelData v1, CustomModelData v2) { return v2.useUVCount.CompareTo(v1.useUVCount); });
                    break;

                case SortType.VertextCount:
                    if (_sortDir)
                        savedModelData.Sort(delegate (CustomModelData v1, CustomModelData v2) { return v1.vertexCount.CompareTo(v2.vertexCount); });
                    else
                        savedModelData.Sort(delegate (CustomModelData v1, CustomModelData v2) { return v2.vertexCount.CompareTo(v1.vertexCount); });
                    break;
            }
        }

        void AddModelData(CheckType checktype, IEnumerable<CustomModelData> filteredData)
        {
            foreach (CustomModelData t in filteredData)
            {
                t.nWrongCheckType = t.nWrongCheckType | (int)checktype;

                if (dicFilteredData.ContainsKey(t.instanceID) == false)
                    dicFilteredData.Add(t.instanceID, t);
            }
        }


        void FilteringData()
        {
            // 에디터 필터링 옵션 변수
            if (savedModelData == null || savedModelData.Count == 0)
            {
                return;
            }

            // 초기화
            dicFilteredData.Clear();
            foreach (CustomModelData d in savedModelData)
                d.nWrongCheckType = 0;

            if (CheckTypes != 0)
            {
                if (GetCheckType(CheckTypes, CheckType.CheckScaleFactor))
                {
                    AddModelData(CheckType.CheckScaleFactor, savedModelData.Where(t => CheckScaleFactor(t.scaleFactor)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckMeshCompression))
                {
                    AddModelData(CheckType.CheckMeshCompression, savedModelData.Where(t => CheckMeshCompression(t)));
                }
                
                if (GetCheckType(CheckTypes, CheckType.CheckReadWriteEnabled))
                {
                    AddModelData(CheckType.CheckReadWriteEnabled, savedModelData.Where(t => CheckReadWriteEnabled(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckOptimizeMesh))
                {
                    AddModelData(CheckType.CheckOptimizeMesh, savedModelData.Where(t => CheckOptimizeMesh(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckImportBlendShapes))
                {
                    AddModelData(CheckType.CheckImportBlendShapes, savedModelData.Where(t => CheckImportBlendShapes(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckGenerateColliders))
                {
                    AddModelData(CheckType.CheckGenerateColliders, savedModelData.Where(t => CheckGenerateColliders(t)));
                }

                //if (GetCheckType(CheckType.CheckKeepQuads))
                //{
                //    AddModelData(CheckType.CheckScaleFactor, savedModelData.Where(t => CheckKeepQuads(t)));
                //}

                if (GetCheckType(CheckTypes, CheckType.CheckSwapUVs))
                {
                    AddModelData(CheckType.CheckSwapUVs, savedModelData.Where(t => CheckSwapUVs(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckGenerateLightmapUVs))
                {
                    AddModelData(CheckType.CheckGenerateLightmapUVs, savedModelData.Where(t => CheckGenerateLightmapUVs(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckImportMaterials))
                {
                    AddModelData(CheckType.CheckImportMaterials, savedModelData.Where(t => CheckImportMaterials(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckTangents))
                {
                    AddModelData(CheckType.CheckTangents, savedModelData.Where(t => CheckTangents(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckMaterialNaming))
                {
                    AddModelData(CheckType.CheckMaterialNaming, savedModelData.Where(t => CheckMaterialNaming(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckMaterialSearch))
                {
                    AddModelData(CheckType.CheckMaterialSearch, savedModelData.Where(t => CheckMaterialSearch(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckUVCount))
                {
                    AddModelData(CheckType.CheckUVCount, savedModelData.Where(t => CheckUVCount(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckVertexColor))
                {
                    AddModelData(CheckType.CheckVertexColor, savedModelData.Where(t => CheckVertexColor(t)));
                }

                if (GetCheckType(CheckTypes, CheckType.CheckNormalsOption))
                {
                    AddModelData(CheckType.CheckNormalsOption, savedModelData.Where(t => CheckNormalsOption(t)));
                }
                //Index Format
                if (GetCheckType(CheckTypes, CheckType.CheckIndexFormat))
                {
                    AddModelData(CheckType.CheckIndexFormat, savedModelData.Where(t => CheckIndexFormat(t)));
                }
                //ImportAnimation
                if (GetCheckType(CheckTypes, CheckType.CheckImportAnimation))
                {
                    AddModelData(CheckType.CheckImportAnimation, savedModelData.Where(t => CheckImportAnimation(t)));
                }

            }
            else
            {
                AddModelData(CheckType.CheckNone, savedModelData);
            }
        }

        string GetStringWrongFilterType(CustomModelData t)
        {
            string strWrongType = " ";

            if (t.nWrongCheckType != 0)
            {
                if (GetCheckType(t.nWrongCheckType, CheckType.CheckScaleFactor))
                    strWrongType += "1  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckMeshCompression))
                    strWrongType += "2  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckReadWriteEnabled))
                    strWrongType += "3  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckOptimizeMesh))
                    strWrongType += "4  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckImportBlendShapes))
                    strWrongType += "5  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckGenerateColliders))
                    strWrongType += "6  ";

                //if (GetCheckType(CheckType.CheckKeepQuads))
                //{
                //    AddModelData(CheckType.CheckScaleFactor, savedModelData.Where(t => CheckKeepQuads(t)));
                //}

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckSwapUVs))
                    strWrongType += "7  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckGenerateLightmapUVs))
                    strWrongType += "8  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckImportMaterials))
                    strWrongType += "9  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckTangents))
                    strWrongType += "10  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckMaterialNaming))
                    strWrongType += "11  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckMaterialSearch))
                    strWrongType += "12  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckUVCount))
                    strWrongType += "13  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckVertexColor))
                    strWrongType += "14  ";

                if (GetCheckType(t.nWrongCheckType, CheckType.CheckNormalsOption))
                    strWrongType += "15  ";
                //Index Format
                if (GetCheckType(t.nWrongCheckType, CheckType.CheckIndexFormat))
                    strWrongType += "16  ";
                //Import Animation
                if (GetCheckType(t.nWrongCheckType, CheckType.CheckImportAnimation))
                    strWrongType += "17  ";

            }

            return strWrongType;
        }

        void Search()
        {
            //EditorUtility.UnloadUnusedAssetsIgnoreManagedReferences();
            EditorUtility.UnloadUnusedAssetsImmediate();
            System.GC.Collect();

            if (GetFolderFromSelection(Selection.activeObject))
            {
                GetModelDataFromFolders();
            }
            else
            {
                NDebug.Log("selection is not a folder");
            }
        }

        void WriteWrongType(StreamWriter sw, CheckType checktype)
        {
            if (GetCheckType(CheckTypes, checktype) == false)
                return;

            sw.Write("-----------------" + checktype.ToString());
            sw.Write("\r\n");

            foreach (CustomModelData t in dicFilteredData.Values)
            {
                if (GetCheckType(t.nWrongCheckType, checktype))
                {
                    // UV 카운트 필터에 걸려서 출력되는 데이터는 옆에 UV 채널 수도 같이 출력
                    if (checktype == CheckType.CheckUVCount)
                        sw.Write(t.name + string.Format("\t| UV Count - {0}", t.useUVCount));
                    else
                        sw.Write(t.name);

                    sw.Write("\r\n");
                }
            }

            sw.Write("\r\n");
            sw.Write("\r\n");
        }

        void Print()
        {
            if (null == dicFilteredData)
                return;

            string _path = "Assets/Model_" + DateTime.Now.ToString("MM_dd_HH_mm_ss") + ".txt";
            StreamWriter sw = new StreamWriter(_path);

            if (CheckTypes != 0)
            {
                WriteWrongType(sw, CheckType.CheckScaleFactor);
                WriteWrongType(sw, CheckType.CheckMeshCompression);
                WriteWrongType(sw, CheckType.CheckReadWriteEnabled);
                WriteWrongType(sw, CheckType.CheckOptimizeMesh);
                WriteWrongType(sw, CheckType.CheckImportBlendShapes);
                WriteWrongType(sw, CheckType.CheckGenerateColliders);
                //WriteWrongType(sw, CheckType.CheckKeepQuads);
                WriteWrongType(sw, CheckType.CheckSwapUVs);
                WriteWrongType(sw, CheckType.CheckGenerateLightmapUVs);
                WriteWrongType(sw, CheckType.CheckImportMaterials);
                WriteWrongType(sw, CheckType.CheckTangents);
                WriteWrongType(sw, CheckType.CheckMaterialNaming);
                WriteWrongType(sw, CheckType.CheckMaterialSearch);
                WriteWrongType(sw, CheckType.CheckUVCount);
                WriteWrongType(sw, CheckType.CheckVertexColor);
                WriteWrongType(sw, CheckType.CheckNormalsOption);
                WriteWrongType(sw, CheckType.CheckIndexFormat);
                WriteWrongType(sw, CheckType.CheckImportAnimation);
            }
            else
            {
                sw.Write("----------------- None Filter".ToString());
                sw.Write("\r\n");

                foreach (CustomModelData t in dicFilteredData.Values)
                {
                    sw.Write(t.name);
                    sw.Write("\r\n");
                }
            }

            sw.Close();
        }

        void SaveFilterOption()
        {
            // --- 폴더가 있는지 체크하고 없으면 생성
            DirectoryInfo di = new DirectoryInfo(savePath);
            if (di.Exists == false)
                di.Create();

            using (FileStream fileStream = new FileStream(savePath + saveFileName, FileMode.Create))
            {
                byte[] _floatTobyte = BitConverter.GetBytes(baseScaleFactor);
                fileStream.Write(_floatTobyte, 0, _floatTobyte.Length);

                fileStream.WriteByte((byte)baseMeshCompression);
                fileStream.WriteByte((byte)baseReadWriteEnabled);
                fileStream.WriteByte((byte)baseOptimizeMesh);
                fileStream.WriteByte((byte)baseImportBlendShapes);
                fileStream.WriteByte((byte)baseGenerateColliders);
                //fileStream.WriteByte((byte)baseKeepQuads);
                fileStream.WriteByte((byte)baseSwapUVs);
                fileStream.WriteByte((byte)baseGenerateLightmapUVs);
                fileStream.WriteByte((byte)baseTangents);
                fileStream.WriteByte((byte)baseImportMaterials);
                fileStream.WriteByte((byte)baseMaterialName);
                fileStream.WriteByte((byte)baseMaterialSearch);
                fileStream.WriteByte((byte)baseUVCount);
                fileStream.WriteByte((byte)baseVertexColorSet);
                fileStream.WriteByte((byte)baseNormalsOption);
                fileStream.WriteByte((byte)baseSmoothingAngle);
                fileStream.WriteByte((byte)baseIndexFormat);
                fileStream.WriteByte((byte)baseImportAnimation);

                fileStream.Close();
            }
        }

        void LoadFilterOption()
        {
            try
            {
                FileStream fileStream = new FileStream(savePath + saveFileName, FileMode.Open);
                if (fileStream == null)
                    return;

                using (fileStream)
                {
                    byte[] _Loadfloat = new byte[4];
                    for (int i = 0; i < _Loadfloat.Length; ++i)
                        _Loadfloat[i] = (byte)fileStream.ReadByte();
                    baseScaleFactor = BitConverter.ToSingle(_Loadfloat, 0);

                    baseMeshCompression = (ModelImporterMeshCompression)fileStream.ReadByte();
                    baseReadWriteEnabled = (BOOL)fileStream.ReadByte();
                    baseOptimizeMesh = (BOOL)fileStream.ReadByte();
                    baseImportBlendShapes = (BOOL)fileStream.ReadByte();
                    baseGenerateColliders = (BOOL)fileStream.ReadByte();
                    //baseKeepQuads = (BOOL)fileStream.ReadByte();
                    baseSwapUVs = (BOOL)fileStream.ReadByte();
                    baseGenerateLightmapUVs = (BOOL)fileStream.ReadByte();
                    baseTangents = (TANGENTS)fileStream.ReadByte();
                    baseImportMaterials = (BOOL)fileStream.ReadByte();
                    baseMaterialName = (MATERIAL_NAMING)fileStream.ReadByte();
                    baseMaterialSearch = (MATERIAL_SEARCH)fileStream.ReadByte();
                    baseUVCount = (byte)fileStream.ReadByte();
                    baseVertexColorSet = (BOOL)fileStream.ReadByte();
                    baseNormalsOption = (NORMALS)fileStream.ReadByte();
                    baseSmoothingAngle = (Byte)fileStream.ReadByte();
                    baseIndexFormat = (ModelImporterIndexFormat)fileStream.ReadByte();
                    baseImportAnimation = (BOOL)fileStream.ReadByte();


                    //if (fileStream.Position < fileStream.Length)
                    //    baseMeshCompression = (ModelImporterMeshCompression)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseReadWriteEnabled = (BOOL)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseOptimizeMesh = (BOOL)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseImportBlendShapes = (BOOL)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseGenerateColliders = (BOOL)fileStream.ReadByte();
                    ////if (fileStream.Position < fileStream.Length)
                    //    //baseKeepQuads = (BOOL)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseSwapUVs = (BOOL)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseGenerateLightmapUVs = (BOOL)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseTangents = (TANGENTS)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseImportMaterials = (BOOL)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseMaterialName = (MATERIAL_NAMING)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseMaterialSearch = (MATERIAL_SEARCH)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseUVCount = (byte)fileStream.ReadByte();
                    //if (fileStream.Position < fileStream.Length)
                    //    baseVertexColorSet = (BOOL)fileStream.ReadByte();
                }

                fileStream.Close();
            }
            catch { }
        }


        void OnEnable()
        {
            LoadFilterOption();
        }

        // Use this for initialization
        void Start()
        {
        }

        // Update is called once per frame
        void Update()
        {

        }
    }
}
