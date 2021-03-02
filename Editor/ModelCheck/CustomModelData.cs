using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System;

namespace CheckModelTool
{
    public class CustomModelData
    {
        // from GUID
        public string assetPath { get; private set; }
        public string metaFilePath { get; private set; }

        // from GameObject
        public string name { get; private set; }
        public int instanceID { get; private set; }

        // from Mesh
        public bool readWriteEnabled { get; private set; }
        public int vertexCount { get; private set; }
        public int useUVCount { get; private set; }
        public bool vertextColorSet { get; private set; } // 버택스 컬러가 세팅되어 있는지 [25.10.2016 JeongHyeonJin]

        // from Model Importer
        public float scaleFactor { get; private set; }
        public ModelImporterMeshCompression meshCompression { get; private set; }
        public bool optimizeMesh { get; private set; }
        public bool importBlendShapes { get; private set; }
        public bool generateColliders { get; private set; }
        public bool swapUV { get; private set; }
        public bool generateLightmapUVs { get; private set; }
        public ModelImporterTangents tangents { get; private set; }
        public bool importMaterials { get; private set; }
        public ModelImporterMaterialName materialName { get; private set; }
        public ModelImporterMaterialSearch materialSearch { get; private set; }
        public ModelImporterNormals normals { get; private set; }
        public Byte smoothingAngle { get; private set; }

        //Index format(16)
        public ModelImporterIndexFormat IndexFormat { get; private set; }
        //Import Animation
        public bool ImportAnimation { get; private set; }


        // Tool Data
        public int nWrongCheckType = 0;

        public CustomModelData()
        {
            //float baseScaleFactor = 0.01f;
            //ModelImporterMeshCompression baseMeshCompression = ModelImporterMeshCompression.Off;
            //BOOL baseReadWriteEnabled = BOOL.FALSE;
            //BOOL baseOptimizeMesh = BOOL.FALSE;
            //BOOL baseImportBlendShapes = BOOL.FALSE;
            //BOOL baseGenerateColliders = BOOL.FALSE;
            ////BOOL baseKeepQuads = BOOL.FALSE;
            //BOOL baseSwapUVs = BOOL.FALSE;
            //BOOL baseGenerateLightmapUVs = BOOL.FALSE;
            //TANGENTS baseTangents = TANGENTS.Import;
            //BOOL baseImportMaterials = BOOL.FALSE;
            //MATERIAL_NAMING baseMaterialName = MATERIAL_NAMING.By_Base_Texture_Name;
            //MATERIAL_SEARCH baseMaterialSearch = MATERIAL_SEARCH.Local_Materials_Folder;
        }

        public bool InitFromGUID(string GUID)
        {
            assetPath = AssetDatabase.GUIDToAssetPath(GUID);
            metaFilePath = Path.Combine(Directory.GetCurrentDirectory(),
                AssetDatabase.GetTextMetaFilePathFromAssetPath(assetPath)).Replace("/", "\\");

            GameObject gameobject = AssetDatabase.LoadAssetAtPath(assetPath, typeof(GameObject)) as GameObject;
            name = gameobject.name;
            instanceID = gameobject.GetInstanceID();

            Mesh mesh = AssetDatabase.LoadAssetAtPath(assetPath, typeof(Mesh)) as Mesh;
            if (mesh != null)
                readWriteEnabled = mesh.isReadable;
            else
                return false;

            UnityEngine.Object[] objArr = AssetDatabase.LoadAllAssetsAtPath(assetPath);
            foreach (UnityEngine.Object obj in objArr)
            {
                mesh = obj as Mesh;
                if (mesh != null)
                {
                    vertexCount += mesh.vertexCount;

                    int nUVCount = 0;
                    if (mesh.uv.Length != 0) ++nUVCount;
                    if (mesh.uv2.Length != 0) ++nUVCount;
                    if (mesh.uv3.Length != 0) ++nUVCount;
                    if (mesh.uv4.Length != 0) ++nUVCount;

                    if (nUVCount > useUVCount)
                        useUVCount = nUVCount;

                    if (!mesh.colors.Length.Equals(0))
                        vertextColorSet = true;
                }
            }

            ModelImporter tImporter = AssetImporter.GetAtPath(assetPath) as ModelImporter;
            if (tImporter != null)
            {
                scaleFactor = tImporter.globalScale;
                meshCompression = tImporter.meshCompression;
                optimizeMesh = tImporter.optimizeMesh;
                importBlendShapes = tImporter.importBlendShapes;
                generateColliders = tImporter.addCollider;
                swapUV = tImporter.swapUVChannels;
                generateLightmapUVs = tImporter.generateSecondaryUV;
                tangents = tImporter.importTangents;
                importMaterials = tImporter.importMaterials;
                materialName = tImporter.materialName;
                materialSearch = tImporter.materialSearch;
                normals = tImporter.importNormals;
                smoothingAngle = (Byte)tImporter.normalSmoothingAngle;
                IndexFormat = tImporter.indexFormat;
                ImportAnimation = tImporter.importAnimation;
            }
            else
                return false;

            tImporter = null;
            //EditorUtility.UnloadUnusedAssetsIgnoreManagedReferences();
            EditorUtility.UnloadUnusedAssetsImmediate();

            //CheckBuildFor();
            //EditorUtility.UnloadUnusedAssetsIgnoreManagedReferences();
            EditorUtility.UnloadUnusedAssetsImmediate();

            return true;
        }






        //int CalculateTextureSizeBytes(Texture tTexture)
        //{


        //    int tWidth = tTexture.width;
        //    int tHeight = tTexture.height;
        //    if (tTexture is Texture2D)
        //    {
        //        Texture2D tTex2D = tTexture as Texture2D;
        //        int bitsPerPixel = GetBitsPerPixel(tTex2D.format);
        //        int mipMapCount = tTex2D.mipmapCount;
        //        int mipLevel = 1;
        //        int tSize = 0;
        //        while (mipLevel <= mipMapCount)
        //        {
        //            tSize += tWidth * tHeight * bitsPerPixel / 8;
        //            tWidth = tWidth / 2;
        //            tHeight = tHeight / 2;
        //            mipLevel++;
        //        }
        //        return tSize;
        //    }


        //    if (tTexture is Cubemap)
        //    {
        //        Cubemap tCubemap = tTexture as Cubemap;
        //        int bitsPerPixel = GetBitsPerPixel(tCubemap.format);
        //        return tWidth * tHeight * 6 * bitsPerPixel / 8;
        //    }
        //    return 0;
        //}
        //      int GetBitsPerPixel(TextureFormat format)
        //{ 
        //	switch (format) 
        //	{ 
        //	case TextureFormat.Alpha8: //	 Alpha-only texture format. 
        //		return 8; 
        //	case TextureFormat.ARGB4444: //	 A 16 bits/pixel texture format. Texture stores color with an alpha channel. 
        //		return 16; 
        //	case TextureFormat.RGBA4444: //	 A 16 bits/pixel texture format. 
        //		return 16; 
        //	case TextureFormat.RGB24:	// A color texture format. 
        //		return 24; 
        //	case TextureFormat.RGBA32:	//Color with an alpha channel texture format. 
        //		return 32; 
        //	case TextureFormat.ARGB32:	//Color with an alpha channel texture format. 
        //		return 32; 
        //	case TextureFormat.RGB565:	//	 A 16 bit color texture format. 
        //		return 16; 
        //	case TextureFormat.DXT1:	// Compressed color texture format. 
        //		return 4; 
        //	case TextureFormat.DXT5:	// Compressed color with alpha channel texture format. 
        //		return 8; 
        //		/* 
        //		case TextureFormat.WiiI4:	// Wii texture format. 
        //		case TextureFormat.WiiI8:	// Wii texture format. Intensity 8 bit. 
        //		case TextureFormat.WiiIA4:	// Wii texture format. Intensity + Alpha 8 bit (4 + 4). 
        //		case TextureFormat.WiiIA8:	// Wii texture format. Intensity + Alpha 16 bit (8 + 8). 
        //		case TextureFormat.WiiRGB565:	// Wii texture format. RGB 16 bit (565). 
        //		case TextureFormat.WiiRGB5A3:	// Wii texture format. RGBA 16 bit (4443). 
        //		case TextureFormat.WiiRGBA8:	// Wii texture format. RGBA 32 bit (8888). 
        //		case TextureFormat.WiiCMPR:	//	 Compressed Wii texture format. 4 bits/texel, ~RGB8A1 (Outline alpha is not currently supported). 
        //			return 0;  //Not supported yet 
        //		*/ 
        //	case TextureFormat.PVRTC_RGB2://	 PowerVR (iOS) 2 bits/pixel compressed color texture format. 
        //		return 2; 
        //	case TextureFormat.PVRTC_RGBA2://	 PowerVR (iOS) 2 bits/pixel compressed with alpha channel texture format 
        //		return 2; 
        //	case TextureFormat.PVRTC_RGB4://	 PowerVR (iOS) 4 bits/pixel compressed color texture format. 
        //		return 4; 
        //	case TextureFormat.PVRTC_RGBA4://	 PowerVR (iOS) 4 bits/pixel compressed with alpha channel texture format 
        //		return 4; 
        //	case TextureFormat.ETC_RGB4://	 ETC (GLES2.0) 4 bits/pixel compressed RGB texture format. 
        //		return 4; 
        //	case TextureFormat.ATC_RGB4://	 ATC (ATITC) 4 bits/pixel compressed RGB texture format. 
        //		return 4; 
        //	case TextureFormat.ATC_RGBA8://	 ATC (ATITC) 8 bits/pixel compressed RGB texture format. 
        //		return 8; 
        //	case TextureFormat.BGRA32://	 Format returned by iPhone camera 
        //		return 32; 
        //		#if !UNITY_5 
        //		case TextureFormat.ATF_RGB_DXT1://	 Flash-specific RGB DXT1 compressed color texture format. 
        //		case TextureFormat.ATF_RGBA_JPG://	 Flash-specific RGBA JPG-compressed color texture format. 
        //		case TextureFormat.ATF_RGB_JPG://	 Flash-specific RGB JPG-compressed color texture format. 
        //		return 0; //Not supported yet   
        //		#endif 
        //	} 
        //	return 0; 
        //} 
        //static public string GetFileSize(long byteCount)
        //{
        //    string size = "0 Bytes";
        //    if (byteCount >= 1073741824.0)
        //        size = String.Format("{0:##.##}", byteCount / 1073741824.0) + " GB";
        //    else if (byteCount >= 1048576.0)
        //        size = String.Format("{0:##.##}", byteCount / 1048576.0) + " MB";
        //    else if (byteCount >= 1024.0)
        //        size = String.Format("{0:##.##}", byteCount / 1024.0) + " KB";
        //    else if (byteCount > 0 && byteCount < 1024.0)
        //        size = byteCount.ToString() + " Bytes";

        //    return size;
        //}

        //      private void CheckBuildFor()
        //{
        //	// 파일 없으면 둘 다 아닌 걸로 설정.
        //	if (!File.Exists(metaFilePath))
        //	{
        //		isBuildForAndroid = false;
        //		isBuildForIOS = false;
        //		return;
        //	}

        //	using (FileStream stream = new FileStream(metaFilePath,FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        //	{
        //		using (StreamReader reader = new StreamReader(stream, System.Text.Encoding.Default, true))
        //		{
        //			string line;
        //			while ((line = reader.ReadLine()) != null)
        //			{
        //				if (line.Contains("iPhone"))
        //				{
        //					isBuildForIOS = true;
        //				}
        //				if(line.Contains("Android"))
        //				{
        //					isBuildForAndroid = true;
        //				}
        //			}
        //		}
        //	}
        //}

        //public void GetTexturePropertyValFromGUID(string GUID)
        //{

        //}

        //public void InitFromAssetPath(string assetPath)
        //{

        //}

        //public void InitFromTexture2D(Texture2D texture)
        //{

        //}

        //public override string ToString()
        //{
        //	return string.Format("Format : {0}"
        //		+ "\t{1} * {2}"
        //		+ "\t{3}"
        //		+ "\t{4}"
        //		+ "\tMax Size : {5}"
        //		+ "\tMipMap Enable : {6}"
        //		, format
        //		, width, height
        //		, assetPath
        //		, metaFilePath
        //		, maxTextureSize
        //		, mipmapEnabled
        //		);
        //}
    }
}
