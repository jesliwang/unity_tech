using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections;
using System.Linq;
using System;

#if UNITY_5_5_OR_NEWER
using UnityEngine.Profiling;
#endif

namespace CheckTextureTool
{
    public class CustomTexureData
    {
        // from GUID
        public string assetPath { get; private set; }
        // from texture 2d
        public TextureFormat format { get; private set; }
        public int width { get; private set; }
        public int height { get; private set; }
        public int instanceID { get; private set; }
        public bool isBuildForIOS { get; private set; }
        public bool isBuildForAndroid { get; private set; }
        public string metaFilePath { get; private set; }
        public string name { get; private set; }
        //from texture importer
        public TextureImporterFormat importerFormat { get; private set; }
        public int minTextureSize { get; private set; }
        public int maxTextureSize { get; private set; }
        public bool mipmapEnabled { get; private set; }
        public bool readWriteEnabled { get; private set; }
        public bool ChecksRGBEnabled { get; private set; }
        public bool isCheckTrensparencyEnabled { get; private set; }

        //test TextureType
        public bool CheckTpye { get; private set; }

        public string StrTexCapacity { get; private set; }
        public int TexCapacity { get; private set; }


        public CustomTexureData()
        {

        }

        public void InitFromGUID(string GUID)
        {
            assetPath = AssetDatabase.GUIDToAssetPath(GUID);
            metaFilePath = Path.Combine(Directory.GetCurrentDirectory(),
                AssetDatabase.GetTextMetaFilePathFromAssetPath(assetPath)).Replace("/", "\\");

            Texture2D texture = AssetDatabase.LoadAssetAtPath(assetPath, typeof(Texture2D)) as Texture2D;
            if (texture == null)
            {
                NDebug.Log("NOT FOUND TEXTURE:" + assetPath);
                return;
            }
            
            width = texture.width;
            height = texture.height;
            name = texture.name;
            format = texture.format;
            instanceID = texture.GetInstanceID();
            minTextureSize = Mathf.Min(width, height);
            maxTextureSize = Mathf.Max(width, height);

            TexCapacity = CalculateTextureSizeBytes(texture);
            StrTexCapacity = GetFileSize(TexCapacity);
            /*! \note GC가 작동하도록 null로 풀어야 한다. 안하면 System out of memory 오류남.*/
            texture = null;

            TextureImporter tImporter = AssetImporter.GetAtPath(assetPath) as TextureImporter;
            ///*int TexSzie = */Profiler.GetRuntimeMemorySize(tImporter);
            Profiler.GetRuntimeMemorySizeLong(tImporter);
            mipmapEnabled = tImporter.mipmapEnabled;
            readWriteEnabled = tImporter.isReadable;
            ChecksRGBEnabled = tImporter.sRGBTexture;
            isCheckTrensparencyEnabled = tImporter.alphaIsTransparency;

            //test TextureType
            CheckTpye = tImporter.normalmap;

            tImporter = null;
            //EditorUtility.UnloadUnusedAssetsIgnoreManagedReferences();
            EditorUtility.UnloadUnusedAssetsImmediate();


            CheckBuildFor();
            //EditorUtility.UnloadUnusedAssetsIgnoreManagedReferences();
            EditorUtility.UnloadUnusedAssetsImmediate();
        }


        int CalculateTextureSizeBytes(Texture tTexture)
        {


            int tWidth = tTexture.width;
            int tHeight = tTexture.height;
            if (tTexture is Texture2D)
            {
                Texture2D tTex2D = tTexture as Texture2D;
                int bitsPerPixel = GetBitsPerPixel(tTex2D.format);
                int mipMapCount = tTex2D.mipmapCount;
                int mipLevel = 1;
                int tSize = 0;
                while (mipLevel <= mipMapCount)
                {
                    tSize += tWidth * tHeight * bitsPerPixel / 8;
                    tWidth = tWidth / 2;
                    tHeight = tHeight / 2;
                    mipLevel++;
                }
                return tSize;
            }


            if (tTexture is Cubemap)
            {
                Cubemap tCubemap = tTexture as Cubemap;
                int bitsPerPixel = GetBitsPerPixel(tCubemap.format);
                return tWidth * tHeight * 6 * bitsPerPixel / 8;
            }
            return 0;
        }




        int GetBitsPerPixel(TextureFormat format)
        {
            switch (format)
            {
                case TextureFormat.Alpha8: //	 Alpha-only texture format. 
                    return 8;
                case TextureFormat.ARGB4444: //	 A 16 bits/pixel texture format. Texture stores color with an alpha channel. 
                    return 16;
                case TextureFormat.RGBA4444: //	RGBA16 A 16 bits/pixel texture format. 
                    return 16;
                case TextureFormat.RGB24:   // A color texture format. 
                    return 24;
                case TextureFormat.RGBA32:  //Color with an alpha channel texture format. 
                    return 32;
                case TextureFormat.ARGB32:  //Color with an alpha channel texture format. 
                    return 32;
                case TextureFormat.RGB565:  //	 A 16 bit color texture format. 
                    return 16;
                case TextureFormat.DXT1:    // Compressed color texture format. 
                    return 4;
                case TextureFormat.DXT5:    // Compressed color with alpha channel texture format. 
                    return 8;
                /* 
                case TextureFormat.WiiI4:	// Wii texture format. 
                case TextureFormat.WiiI8:	// Wii texture format. Intensity 8 bit. 
                case TextureFormat.WiiIA4:	// Wii texture format. Intensity + Alpha 8 bit (4 + 4). 
                case TextureFormat.WiiIA8:	// Wii texture format. Intensity + Alpha 16 bit (8 + 8). 
                case TextureFormat.WiiRGB565:	// Wii texture format. RGB 16 bit (565). 
                case TextureFormat.WiiRGB5A3:	// Wii texture format. RGBA 16 bit (4443). 
                case TextureFormat.WiiRGBA8:	// Wii texture format. RGBA 32 bit (8888). 
                case TextureFormat.WiiCMPR:	//	 Compressed Wii texture format. 4 bits/texel, ~RGB8A1 (Outline alpha is not currently supported). 
                    return 0;  //Not supported yet 
                */
                case TextureFormat.PVRTC_RGB2://	 PowerVR (iOS) 2 bits/pixel compressed color texture format. 
                    return 2;
                case TextureFormat.PVRTC_RGBA2://	 PowerVR (iOS) 2 bits/pixel compressed with alpha channel texture format 
                    return 2;
                case TextureFormat.PVRTC_RGB4://	 PowerVR (iOS) 4 bits/pixel compressed color texture format. 
                    return 4;
                case TextureFormat.PVRTC_RGBA4://	 PowerVR (iOS) 4 bits/pixel compressed with alpha channel texture format 
                    return 4;
                case TextureFormat.ETC_RGB4://	 ETC (GLES2.0) 4 bits/pixel compressed RGB texture format. 
                    return 4;
                case TextureFormat.ETC2_RGB:    //ETC2 compressed 4 bits / pixel RGB texture format.
                    return 4;
//                 case TextureFormat.ETC2_RGBA1:  //     ETC2 (GL ES 3.0) 4 bits/pixel RGB+1-bit alpha texture format.
//                     return 4;
                case TextureFormat.ETC2_RGBA8: //ETC2 compressed 8 bits / pixel RGBA texture format.
                    return 8;
//                case TextureFormat.ETC_RGB4://	 ATC (ATITC) 4 bits/pixel compressed RGB texture format. 
//                    return 4;
//                case TextureFormat.ETC2_RGBA8://	 ATC (ATITC) 8 bits/pixel compressed RGB texture format. 
//                    return 8;
                case TextureFormat.BGRA32://	 Format returned by iPhone camera 
                    return 32;

//#if !UNITY_5
// 			    //case TextureFormat.ATF_RGB_DXT1://	 Flash-specific RGB DXT1 compressed color texture format. 
// 			    //case TextureFormat.ATF_RGBA_JPG://	 Flash-specific RGBA JPG-compressed color texture format. 
// 			    //case TextureFormat.ATF_RGB_JPG://	 Flash-specific RGB JPG-compressed color texture format. 
//                default:
//         			return 0; //Not supported yet   
//#endif
            }
            return 0;
        }
        static public string GetFileSize(long byteCount)
        {
            string size = "0 Bytes";
            if (byteCount >= 1073741824.0)
                size = String.Format("{0:##.##}", byteCount / 1073741824.0) + " GB";
            else if (byteCount >= 1048576.0)
                size = String.Format("{0:##.##}", byteCount / 1048576.0) + " MB";
            else if (byteCount >= 1024.0)
                size = String.Format("{0:##.##}", byteCount / 1024.0) + " KB";
            else if (byteCount > 0 && byteCount < 1024.0)
                size = byteCount.ToString() + " Bytes";

            return size;
        }

        private void CheckBuildFor()
        {
            // 파일 없으면 둘 다 아닌 걸로 설정.
            if (!File.Exists(metaFilePath))
            {
                isBuildForAndroid = false;
                isBuildForIOS = false;
                return;
            }

            using (FileStream stream = new FileStream(metaFilePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            {
                using (StreamReader reader = new StreamReader(stream, System.Text.Encoding.Default, true))
                {
                    string line;
                    while ((line = reader.ReadLine()) != null)
                    {
                        if (line.Contains("iPhone"))
                        {
                            isBuildForIOS = true;
                        }
                        if (line.Contains("Android"))
                        {
                            isBuildForAndroid = true;
                        }
                    }
                }
            }
        }

        public void GetTexturePropertyValFromGUID(string GUID)
        {

        }

        public void InitFromAssetPath(string assetPath)
        {

        }

        public void InitFromTexture2D(Texture2D texture)
        {

        }

        public override string ToString()
        {
            return string.Format("Format : {0}"
                + "\t{1} * {2}"
                + "\t{3}"
                + "\t{4}"
                + "\tMax Size : {5}"
                + "\tMipMap Enable : {6}"
                , format
                , width, height
                , assetPath
                , metaFilePath
                , maxTextureSize

                );
        }
    }
}
