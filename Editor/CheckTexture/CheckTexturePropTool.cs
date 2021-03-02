using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System;
using CheckTextureTool;

namespace CheckTextureTool
{
    public class CheckTexturePropTool : EditorWindow
    {
        string selectedFolder;
        List<string> texturesGUID = new List<string>();
        List<CustomTexureData> savedTextureData = new List<CustomTexureData>();
        IEnumerable<CustomTexureData> filteredData = null;

        // 필터링 옵션 저장 파일 경로
        const string savePath = @"ToolSettingData";
        const string saveFileName = "/CehckTexturePropTool.dat";

        enum AndroidFormat
        {
            RGB_Compressed_DXT1 = 1 << 0,
            RGBA_Compressed_DXT5 = 1 << 1,
            RGB_Crunched_DXT1 = 1 << 2,
            RGBA_Crunched_DX5 = 1 << 3,
            RGB_Compressed_ETC_4bit = 1 << 4,
            RGB_Compressed_ETC2_4bit = 1 << 5,
            RGB_1bit_Alpha_Compressed_ETC2_4bit = 1 << 6,
            RGBA_Compressed_ETC2_8bit = 1 << 7,
            RGB_Compressed_PVRTC_2bit = 1 << 8,
            RGBA_Compressed_PVRTC_2bit = 1 << 9,
            RGB_Compressed_PVRTC_4bit = 1 << 10,
            RGBA_Compressed_PVRTC_4bit = 1 << 11,
            RGB_Compressed_ATC_4bit = 1 << 12,
            RGBA_Compressed_ATC_8bit = 1 << 13,
            RGB_Compressed_ASTC_4x4block = 1 << 14,
            RGB_Compressed_ASTC_5x5block = 1 << 15,
            RGB_Compressed_ASTC_6x6block = 1 << 16,
            RGB_Compressed_ASTC_8x8block = 1 << 17,
            RGB_Compressed_ASTC_10x10block = 1 << 18,
            RGB_Compressed_ASTC_12x12block = 1 << 19,
            RGBA_Compressed_ASTC_4x4block = 1 << 20,
            RGBA_Compressed_ASTC_5x5block = 1 << 21,
            RGBA_Compressed_ASTC_6x6block = 1 << 22,
            RGBA_Compressed_ASTC_8x8block = 1 << 23,
            RGBA_Compressed_ASTC_10x10block = 1 << 24,
            RGBA_Compressed_ASTC_12x12block = 1 << 25,
            RGB_16bit = 1 << 26,
            RGB_24bit = 1 << 27,
            Alpha8 = 1 << 28,
            RGBA_16bit = 1 << 29,
            RGBA_32bit = 1 << 30,
        }

        enum IOSFormat
        {
            RGB_Compressed_PVRTC_2bit = 1 << 0,
            RGBA_Compressed_PVRTC_2bit = 1 << 1,
            RGB_Compressed_PVRTC_4bit = 1 << 2,
            RGBA_Compressed_PVRTC_4bit = 1 << 3,
            RGB_Compressed_ASTC_4x4block = 1 << 4,
            RGB_Compressed_ASTC_5x5block = 1 << 5,
            RGB_Compressed_ASTC_6x6block = 1 << 6,
            RGB_Compressed_ASTC_8x8block = 1 << 7,
            RGB_Compressed_ASTC_10x10block = 1 << 8,
            RGB_Compressed_ASTC_12x12block = 1 << 9,
            RGBA_Compressed_ASTC_4x4block = 1 << 10,
            RGBA_Compressed_ASTC_5x5block = 1 << 11,
            RGBA_Compressed_ASTC_6x6block = 1 << 12,
            RGBA_Compressed_ASTC_8x8block = 1 << 13,
            RGBA_Compressed_ASTC_10x10block = 1 << 14,
            RGBA_Compressed_ASTC_12x12block = 1 << 15,
            RGB_16bit = 1 << 16,
            RGB_24bit = 1 << 17,
            Alpha8 = 1 << 18,
            RGBA_16bit = 1 << 19,
            RGBA_32bit = 1 << 20,
        }

        enum SortType
        {
            TextureName,
            TextureSize,
            TextureFormat,
            TextureCapacity
        }

        // 에디터 스크롤 변수
        Vector2 scroll;

        // 에디터 필터링 옵션 변수
        bool isNotSquare = false;
        bool isNotPower2 = false;
        bool isNotForIOS = false;
        bool isNotForAndroid = false;
        bool isNotCheckReadWrite = false;
        bool enableMipmap = false;

        //sRGB Check
        bool isChecksRGB = false;
        //bool isChecksTexType = false;

        bool isCheckTrensparency = false;


        bool checkTextureSize = false;
        long maxTextureSize = 0;
        long minTextureSize = 0;

        // IOS 빌드용 포맷 체크
        IOSFormat _IOSFilterFormat;
#if UNITY_IOS
        bool isCheckIOSFormat = false;
#endif
        // 안드로이드 빌드용 포맷 체크
        AndroidFormat _AndroidFilterFormat;
        bool isCheckAndroidFormat = false;

        // 정렬 
        SortType _sortType = SortType.TextureName;
        bool _sortDir = true;

        // 선택 표시
        int _InstID = 0;

        [MenuItem("NDREAM/Check Texture Properties...")]
        static public void InitWindow()
        {
            CheckTexturePropTool window = (CheckTexturePropTool)EditorWindow.GetWindow<CheckTexturePropTool>();
            if (window == null)
            {
                return;
            }
            window.titleContent.text = "NDREAM : Texture Properties";
            window.minSize = new Vector2(960, 470);
            window.Show();

            System.GC.Collect();
        }

        void OnGUI()
        {
            GUILayout.Space(10f);

            GUI.contentColor = Color.yellow;
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("TexturePropTool   |   " + selectedFolder);
            EditorGUILayout.EndHorizontal();
            GUI.contentColor = Color.white;

            DrawButton();

            EditorGUILayout.BeginVertical();
            DrawFilters();
            FilteringData();
            DrawScrollList();
            EditorGUILayout.EndVertical();
        }

        /// <summary>
        /// texture GUID 에서 asset path 추출
        /// asset path 통해서 CustomTextureData 초기화
        /// </summary>
        void ClearAndTrim<T>(List<T> targets)
        {
            targets.Clear();
            targets.TrimExcess();
        }

        void GetTextureDataFromFolders()
        {
            texturesGUID.Clear();
            savedTextureData.Clear();

            texturesGUID.AddRange(AssetDatabase.FindAssets("t:texture2D", new string[] { selectedFolder }));

            foreach (string GUID in texturesGUID)
            {
                CustomTexureData data = new CustomTexureData();
                data.InitFromGUID(GUID);
                savedTextureData.Add(data);
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
            //    GetTextureDataFromFolders();
            //}
            //else
            //{
            //    NDebug.Log("selection is not a folder");
            //}
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
            if (GUILayout.Button("폴더검색"))
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
                EditorGUILayout.BeginVertical("box", GUILayout.Width(310));
                {
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (isNotSquare) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("정사각형이 아닌 텍스쳐"))
                            isNotSquare = !isNotSquare;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (isNotPower2) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("2의 거듭제곱이 아닌 텍스쳐"))
                            isNotPower2 = !isNotPower2;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (enableMipmap) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("밉맵 가능한 텍스쳐"))
                            enableMipmap = !enableMipmap;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();
                }
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical("box", GUILayout.Width(310));
                {
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (checkTextureSize) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("Texture Size", GUILayout.Width(110)))
                            checkTextureSize = !checkTextureSize;
                        GUI.backgroundColor = Color.white;

                        //if (minTextureSize > maxTextureSize)
                        //    minTextureSize = maxTextureSize;
                        minTextureSize = EditorGUILayout.LongField(minTextureSize, GUILayout.Width(80));

                        EditorGUILayout.LabelField("  ~  ", GUILayout.Width(40));

                        if (minTextureSize > maxTextureSize)
                            maxTextureSize = minTextureSize;
                        maxTextureSize = EditorGUILayout.LongField(maxTextureSize, GUILayout.Width(80));
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (isNotForAndroid) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("Android 체크 안된 텍스쳐"))
                            isNotForAndroid = !isNotForAndroid;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (isNotForIOS) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("iOS 체크 안된 텍스쳐"))
                            isNotForIOS = !isNotForIOS;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (isCheckTrensparency) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("Alpha is Trensperency 체크된 텍스쳐"))
                            isCheckTrensparency = !isCheckTrensparency;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();
                    
                }
                EditorGUILayout.EndVertical();

                //Format Filter
                EditorGUILayout.BeginVertical("box", GUILayout.Width(310));
                {
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (isNotCheckReadWrite) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("Read/Write 체크 된 텍스쳐"))
                            isNotCheckReadWrite = !isNotCheckReadWrite;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        if (isChecksRGB) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("sRGB(ColorTexture) 체크 안된 텍스쳐"))
                            isChecksRGB = !isChecksRGB;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();
#if UNITY_IOS
                    EditorGUILayout.BeginHorizontal();
                    {
                        if(isCheckAndroidFormat) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("Check IOS Format", GUILayout.Width(320)))
                            isCheckIOSFormat = !isCheckIOSFormat;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        _IOSFilterFormat = (IOSFormat)EditorGUILayout.EnumFlagsField("IOS Skip Format", _IOSFilterFormat, GUILayout.Width(310));
                    }
                    EditorGUILayout.EndHorizontal();
#endif

#if UNITY_ANDROID
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (isCheckAndroidFormat) GUI.backgroundColor = Color.green;
                        if (GUILayout.Button("Check Android Format"))
                            isCheckAndroidFormat = !isCheckAndroidFormat;
                        GUI.backgroundColor = Color.white;
                    }
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    {
                        _AndroidFilterFormat = (AndroidFormat)EditorGUILayout.EnumFlagsField("Android Skip Format", _AndroidFilterFormat);
                    }
                    EditorGUILayout.EndHorizontal();
#endif
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
            if (filteredData != null)
            {
                EditorGUILayout.BeginHorizontal();
                GUI.contentColor = Color.yellow;
                EditorGUILayout.LabelField(string.Format("폴더 텍스쳐 수 : {0}", filteredData.Count()), GUILayout.Width(160));
                GUI.contentColor = Color.white;

                GUI.backgroundColor = Color.white;
                if (GUILayout.Button("Name", GUILayout.Width(250)))
                {
                    SetSortType(SortType.TextureName);
                    SortingData();
                }
                if (GUILayout.Button("PixelSize", GUILayout.Width(150)))
                {
                    SetSortType(SortType.TextureSize);
                    SortingData();
                }
                if (GUILayout.Button("Format", GUILayout.Width(150)))
                {
                    SetSortType(SortType.TextureFormat);
                    SortingData();
                }

                int totalCapacity = 0;
                foreach (CustomTexureData t in filteredData)
                {
                    totalCapacity += t.TexCapacity;
                }
                string strTotalCapacity = CustomTexureData.GetFileSize(totalCapacity);

                if (GUILayout.Button("용량 - 총용량 :" + strTotalCapacity, GUILayout.Width(200)))
                {
                    SetSortType(SortType.TextureCapacity);
                    SortingData();
                }
                GUI.backgroundColor = Color.yellow;
                EditorGUILayout.EndHorizontal();
            }
            scroll = EditorGUILayout.BeginScrollView(scroll);
            if (filteredData == null || filteredData.Count() == 0)
            {
                EditorGUILayout.LabelField("없음.");
            }
            else
            {
                foreach (CustomTexureData t in filteredData)
                {
                    EditorGUILayout.BeginHorizontal();
                    if (GUILayout.Button("텍스쳐 위치로!!", GUILayout.Width(160)))
                    {
                        EditorGUIUtility.PingObject(t.instanceID);
                    }

                    if (_InstID.Equals(t.instanceID))
                        GUI.backgroundColor = Color.blue;
                    else
                        GUI.backgroundColor = Color.white;

                    if (GUILayout.Button(t.name, GUI.skin.textField, GUILayout.Width(250)))
                        _InstID = t.instanceID;

                    if (GUILayout.Button(string.Format("{0} * {1}", t.width, t.height), GUI.skin.textField, GUILayout.Width(150)))
                        _InstID = t.instanceID;

                    if (GUILayout.Button(t.format.ToString(), GUI.skin.textField, GUILayout.Width(150)))
                        _InstID = t.instanceID;

                    if (GUILayout.Button(t.StrTexCapacity, GUI.skin.textField, GUILayout.Width(200)))
                        _InstID = t.instanceID;

                    GUI.backgroundColor = Color.yellow;
                    EditorGUILayout.EndHorizontal();
                }
            }
            EditorGUILayout.EndScrollView();
        }

        bool CheckNotPower2(long val)
        {
            return !(val != 0 && (val & (val - 1)) == 0);
        }

        bool CheckNotSquared(int w, int h)
        {
            return w != h;
        }

        bool CheckSize(long minSize, long maxSize)
        {
            return minTextureSize <= minSize && maxSize <= maxTextureSize;
        }


#if UNITY_ANDROID
        bool CheckAndroidFormat(CustomTexureData d)
        {
            if (false == d.isBuildForAndroid)
                return true;

            if ((_AndroidFilterFormat & GetExportAnroidFormat(d.format)) != 0)
                return false;

            return true;
        }
#endif

#if UNITY_IOS
        bool CheckIOSFormat(CustomTexureData d)
		{
            if (false == d.isBuildForIOS)
                return true;


            if ((_IOSFilterFormat & GetExportIOSFormat(d.format)) != 0)
                return false;

            return true;
        }
#endif

        void SortingData()
        {
            if (savedTextureData == null || savedTextureData.Count == 0)
                return;

            switch (_sortType)
            {
                case SortType.TextureName:
                    if (_sortDir)
                        savedTextureData.Sort(delegate (CustomTexureData v1, CustomTexureData v2) { return v1.name.CompareTo(v2.name); });
                    else
                        savedTextureData.Sort(delegate (CustomTexureData v1, CustomTexureData v2) { return v2.name.CompareTo(v1.name); });
                    break;

                case SortType.TextureSize:
                    if (_sortDir)
                        savedTextureData.Sort(delegate (CustomTexureData v1, CustomTexureData v2) { return v1.maxTextureSize.CompareTo(v2.maxTextureSize); });
                    else
                        savedTextureData.Sort(delegate (CustomTexureData v1, CustomTexureData v2) { return v2.maxTextureSize.CompareTo(v1.maxTextureSize); });
                    break;

                case SortType.TextureFormat:
                    if (_sortDir)
                        savedTextureData.Sort(delegate (CustomTexureData v1, CustomTexureData v2) { return v1.format.CompareTo(v2.format); });
                    else
                        savedTextureData.Sort(delegate (CustomTexureData v1, CustomTexureData v2) { return v2.format.CompareTo(v1.format); });
                    break;

                case SortType.TextureCapacity:
                    if (_sortDir)
                        savedTextureData.Sort(delegate (CustomTexureData v1, CustomTexureData v2) { return v1.TexCapacity.CompareTo(v2.TexCapacity); });
                    else
                        savedTextureData.Sort(delegate (CustomTexureData v1, CustomTexureData v2) { return v2.TexCapacity.CompareTo(v1.TexCapacity); });
                    break;
            }
        }
        void FilteringData()
        {
            // 에디터 필터링 옵션 변수
            if (savedTextureData == null || savedTextureData.Count == 0)
            {
                return;
            }

            filteredData = savedTextureData;

            if (isNotPower2)
            {
                filteredData = filteredData.Where(t => CheckNotPower2(t.width) || CheckNotPower2(t.height));
            }

            if (isNotSquare)
            {
                filteredData = filteredData.Where(t => CheckNotSquared(t.width, t.height));
            }

            if (checkTextureSize)
            {
                filteredData = filteredData.Where(t => CheckSize(t.minTextureSize, t.maxTextureSize));
            }

            if (enableMipmap)
            {
                filteredData = filteredData.Where(t => t.mipmapEnabled);
            }

            if (isNotForAndroid)
            {
                filteredData = filteredData.Where(t => !t.isBuildForAndroid);
            }

            if (isNotForIOS)
            {
                filteredData = filteredData.Where(t => !t.isBuildForIOS);
            }

            if (isCheckTrensparency)
            {
                filteredData = filteredData.Where(t => t.isCheckTrensparencyEnabled);
            }

            if (isNotCheckReadWrite)
            {
                filteredData = filteredData.Where(t => t.readWriteEnabled);
            }

            if (isChecksRGB)
            {
                filteredData = filteredData.Where(t => !t.ChecksRGBEnabled);
                filteredData = filteredData.Where(t => !t.CheckTpye);


            }

#if UNITY_IOS
            if (isCheckIOSFormat && (int)_IOSFilterFormat != 0) {
				filteredData = filteredData.Where(t => CheckIOSFormat(t));
			}
#endif
#if UNITY_ANDROID
            if (isCheckAndroidFormat && (int)_AndroidFilterFormat != 0)
            {
                filteredData = filteredData.Where(t => CheckAndroidFormat(t));
            }
#endif
        }

        void Search()
        {
            //EditorUtility.UnloadUnusedAssetsIgnoreManagedReferences();
            EditorUtility.UnloadUnusedAssetsImmediate();
            System.GC.Collect();

            if (GetFolderFromSelection(Selection.activeObject))
            {
                GetTextureDataFromFolders();
            }
            else
            {
                NDebug.Log("selection is not a folder");
            }
        }

        void Print()
        {
            if (null == filteredData)
                return;

            string _path = "Assets/" + DateTime.Now.ToString("MM_dd_HH_mm_ss") + ".txt";
            StreamWriter sw = new StreamWriter(_path);

            if (isNotPower2)
            {
                sw.Write("2의 거듭제곱이 아닌 텍스쳐");
                sw.Write("\r\n");
            }

            if (isNotSquare)
            {
                sw.Write("정사각형이 아닌 텍스쳐");
                sw.Write("\r\n");
            }

            if (checkTextureSize)
            {
                sw.Write("사이즈가 " + minTextureSize + " ~ " + maxTextureSize);
                sw.Write("\r\n");
            }

            if (isChecksRGB)
            {
                sw.Write("sRGB가 해제된 텍스쳐");
                sw.Write("\r\n");
            }

            if (isNotCheckReadWrite)
            {
                sw.Write("ReadWrite가 활성화된 텍스쳐");
                sw.Write("\r\n");
            }

            if(isCheckTrensparency)
            {
                sw.Write("Alpha is Trensperency 체크된 텍스쳐");
                sw.Write("\r\n");
            }

            if (enableMipmap)
            {
                sw.Write("밉맵 가능한 텍스쳐");
                sw.Write("\r\n");
            }

            if (isNotForAndroid)
            {
                sw.Write("Android 체크 안된 텍스쳐");
                sw.Write("\r\n");
            }

            if (isNotForIOS)
            {
                sw.Write("Ios 체크 안된 텍스쳐");
                sw.Write("\r\n");
            }

#if UNITY_IOS
            if (isCheckIOSFormat)
            {
                sw.Write("IOS 용으로 사용하면 안되는 포맷의 텍스쳐");
                sw.Write("\r\n");
            }
#endif
#if UNITY_ANDROID
            if (isCheckAndroidFormat)
            {
                sw.Write("안드로이드 용으로 사용하면 안되는 포맷의 텍스쳐");
                sw.Write("\r\n");
            }
#endif

            sw.Write("\r\n");
            sw.Write("\r\n");

            foreach (CustomTexureData t in filteredData)
            {
                sw.Write(t.name);
                sw.Write("\r\n");
            }

            sw.Close();
        }

        // Use this for initialization
        void Start()
        {
        }

        // Update is called once per frame
        void Update()
        {

        }

        IOSFormat[] GetIOSFormats(Int32 _value)
        {
            List<IOSFormat> _Formatlist = new List<IOSFormat>();
            for (int i = 0; i < 32; ++i)
            {
                if ((_value & 1 << i) != 0)
                    _Formatlist.Add((IOSFormat)(1 << i));
            }

            return _Formatlist.ToArray();
        }

        AndroidFormat[] GetAndroidFormats(Int32 _value)
        {
            List<AndroidFormat> _Formatlist = new List<AndroidFormat>();
            for (int i = 0; i < 32; ++i)
            {
                if ((_value & 1 << i) != 0)
                    _Formatlist.Add((AndroidFormat)(1 << i));
            }

            return _Formatlist.ToArray();
        }

        IOSFormat GetExportIOSFormat(TextureFormat _format)
        {
            switch (_format)
            {
                case TextureFormat.Alpha8:
                    return IOSFormat.Alpha8;
                case TextureFormat.RGBA4444:
                    return IOSFormat.RGBA_16bit;
                case TextureFormat.RGBA32:
                    return IOSFormat.RGBA_32bit;
                case TextureFormat.ASTC_RGBA_10x10:
                    return IOSFormat.RGBA_Compressed_ASTC_10x10block;
                case TextureFormat.ASTC_RGBA_12x12:
                    return IOSFormat.RGBA_Compressed_ASTC_12x12block;
                case TextureFormat.ASTC_RGBA_4x4:
                    return IOSFormat.RGBA_Compressed_ASTC_4x4block;
                case TextureFormat.ASTC_RGBA_5x5:
                    return IOSFormat.RGBA_Compressed_ASTC_5x5block;
                case TextureFormat.ASTC_RGBA_6x6:
                    return IOSFormat.RGBA_Compressed_ASTC_6x6block;
                case TextureFormat.ASTC_RGBA_8x8:
                    return IOSFormat.RGBA_Compressed_ASTC_8x8block;
                case TextureFormat.PVRTC_RGBA2:
                    return IOSFormat.RGBA_Compressed_PVRTC_2bit;
                case TextureFormat.PVRTC_RGBA4:
                    return IOSFormat.RGBA_Compressed_PVRTC_4bit;
                case TextureFormat.RGB565:
                    return IOSFormat.RGB_16bit;
                case TextureFormat.RGB24:
                    return IOSFormat.RGB_24bit;
                case TextureFormat.ASTC_RGB_10x10:
                    return IOSFormat.RGB_Compressed_ASTC_10x10block;
                case TextureFormat.ASTC_RGB_12x12:
                    return IOSFormat.RGB_Compressed_ASTC_12x12block;
                case TextureFormat.ASTC_RGB_4x4:
                    return IOSFormat.RGB_Compressed_ASTC_4x4block;
                case TextureFormat.ASTC_RGB_5x5:
                    return IOSFormat.RGB_Compressed_ASTC_5x5block;
                case TextureFormat.ASTC_RGB_6x6:
                    return IOSFormat.RGB_Compressed_ASTC_6x6block;
                case TextureFormat.ASTC_RGB_8x8:
                    return IOSFormat.RGB_Compressed_ASTC_8x8block;
                case TextureFormat.PVRTC_RGB2:
                    return IOSFormat.RGB_Compressed_PVRTC_2bit;
                case TextureFormat.PVRTC_RGB4:
                    return IOSFormat.RGB_Compressed_PVRTC_4bit;
            }
            return IOSFormat.RGBA_32bit;
        }

        AndroidFormat GetExportAnroidFormat(TextureFormat _format)
        {
            switch (_format)
            {
                case TextureFormat.Alpha8:
                    return AndroidFormat.Alpha8;
                case TextureFormat.RGBA4444:
                    return AndroidFormat.RGBA_16bit;
                case TextureFormat.RGBA32:
                    return AndroidFormat.RGBA_32bit;
                case TextureFormat.RGB565:
                    return AndroidFormat.RGB_16bit;
                case TextureFormat.RGB24:
                    return AndroidFormat.RGB_24bit;
                case TextureFormat.ASTC_RGBA_10x10:
                    return AndroidFormat.RGBA_Compressed_ASTC_10x10block;
                case TextureFormat.ASTC_RGBA_12x12:
                    return AndroidFormat.RGBA_Compressed_ASTC_12x12block;
                case TextureFormat.ASTC_RGBA_4x4:
                    return AndroidFormat.RGBA_Compressed_ASTC_4x4block;
                case TextureFormat.ASTC_RGBA_5x5:
                    return AndroidFormat.RGBA_Compressed_ASTC_5x5block;
                case TextureFormat.ASTC_RGBA_6x6:
                    return AndroidFormat.RGBA_Compressed_ASTC_6x6block;
                case TextureFormat.ASTC_RGBA_8x8:
                    return AndroidFormat.RGBA_Compressed_ASTC_8x8block;
                case TextureFormat.ETC2_RGBA8:
                    return AndroidFormat.RGBA_Compressed_ATC_8bit;
                case TextureFormat.DXT5:
                    return AndroidFormat.RGBA_Compressed_DXT5;
//                case TextureFormat.ETC2_RGBA8:
//                    return AndroidFormat.RGBA_Compressed_ETC2_8bit;
                case TextureFormat.PVRTC_RGBA2:
                    return AndroidFormat.RGBA_Compressed_PVRTC_2bit;
                case TextureFormat.PVRTC_RGBA4:
                    return AndroidFormat.RGBA_Compressed_PVRTC_4bit;
                case TextureFormat.DXT5Crunched:
                    return AndroidFormat.RGBA_Crunched_DX5;
                case TextureFormat.ETC2_RGBA1:
                    return AndroidFormat.RGB_1bit_Alpha_Compressed_ETC2_4bit;
                case TextureFormat.ASTC_RGB_10x10:
                    return AndroidFormat.RGB_Compressed_ASTC_10x10block;
                case TextureFormat.ASTC_RGB_12x12:
                    return AndroidFormat.RGB_Compressed_ASTC_12x12block;
                case TextureFormat.ASTC_RGB_4x4:
                    return AndroidFormat.RGB_Compressed_ASTC_4x4block;
                case TextureFormat.ASTC_RGB_5x5:
                    return AndroidFormat.RGB_Compressed_ASTC_5x5block;
                case TextureFormat.ASTC_RGB_6x6:
                    return AndroidFormat.RGB_Compressed_ASTC_6x6block;
                case TextureFormat.ASTC_RGB_8x8:
                    return AndroidFormat.RGB_Compressed_ASTC_8x8block;
                case TextureFormat.ETC_RGB4:
                    return AndroidFormat.RGB_Compressed_ATC_4bit;
                case TextureFormat.DXT1:
                    return AndroidFormat.RGB_Compressed_DXT1;
                case TextureFormat.ETC2_RGB:
                    return AndroidFormat.RGB_Compressed_ETC2_4bit;
//                case TextureFormat.ETC_RGB4:
//                    return AndroidFormat.RGB_Compressed_ETC_4bit;
                case TextureFormat.PVRTC_RGB2:
                    return AndroidFormat.RGB_Compressed_PVRTC_2bit;
                case TextureFormat.PVRTC_RGB4:
                    return AndroidFormat.RGB_Compressed_PVRTC_4bit;
                case TextureFormat.DXT1Crunched:
                    return AndroidFormat.RGB_Crunched_DXT1;
            }

            return AndroidFormat.Alpha8;
        }

        void SaveFilterOption()
        {
            // --- 폴더가 있는지 체크하고 없으면 생성
            DirectoryInfo di = new DirectoryInfo(savePath);
            if (di.Exists == false)
                di.Create();

            using (FileStream fileStream = new FileStream(savePath + saveFileName, FileMode.Create))
            {
                byte[] _floatTobyte = BitConverter.GetBytes(maxTextureSize);
                fileStream.Write(_floatTobyte, 0, _floatTobyte.Length);

                _floatTobyte = BitConverter.GetBytes((Int32)_IOSFilterFormat);
                fileStream.Write(_floatTobyte, 0, _floatTobyte.Length);

                _floatTobyte = BitConverter.GetBytes((Int32)_AndroidFilterFormat);
                fileStream.Write(_floatTobyte, 0, _floatTobyte.Length);

                _floatTobyte = BitConverter.GetBytes(minTextureSize);
                fileStream.Write(_floatTobyte, 0, _floatTobyte.Length);


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
                    if (fileStream.Position < fileStream.Length)
                    {
                        byte[] _LoadByte = new byte[8];
                        for (int i = 0; i < _LoadByte.Length; ++i)
                            _LoadByte[i] = (byte)fileStream.ReadByte();
                        maxTextureSize = BitConverter.ToInt64(_LoadByte, 0);
                    }

                    if (fileStream.Position < fileStream.Length)
                    {
                        byte[] _LoadByte = new byte[4];
                        for (int i = 0; i < _LoadByte.Length; ++i)
                            _LoadByte[i] = (byte)fileStream.ReadByte();
                        _AndroidFilterFormat = (AndroidFormat)BitConverter.ToInt32(_LoadByte, 0);
                    }

                    if (fileStream.Position < fileStream.Length)
                    {
                        byte[] _LoadByte = new byte[4];
                        for (int i = 0; i < _LoadByte.Length; ++i)
                            _LoadByte[i] = (byte)fileStream.ReadByte();
                        _IOSFilterFormat = (IOSFormat)BitConverter.ToInt32(_LoadByte, 0);
                    }

                    if (fileStream.Position < fileStream.Length)
                    {
                        byte[] _LoadByte = new byte[8];
                        for (int i = 0; i < _LoadByte.Length; ++i)
                            _LoadByte[i] = (byte)fileStream.ReadByte();
                        minTextureSize = BitConverter.ToInt64(_LoadByte, 0);
                    }
                }

                fileStream.Close();
            }
            catch { }
        }

        void OnEnable()
        {
            LoadFilterOption();
        }
    }
}
