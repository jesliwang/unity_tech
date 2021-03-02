using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections;

namespace MeshPainter
{
	public class CreateSplatmap : EditorWindow
	{
		public System.Action<Texture2D> EventCreated;
		int _selectedSplatSize;
		string[] _splatSizes;
		const int sizesNum = 5;
		const int initialSize = 128;

		void OnEnable ()
		{
			_selectedSplatSize = 3; //default

			_splatSizes = new string[sizesNum];
		
			for (int i = 0; i < sizesNum; i ++) {
				int size = CalcSize (i);
				_splatSizes [i] = size + "x" + size;
			}
		}

		int CalcSize (int pow)
		{
			return initialSize * Mathf.CeilToInt (Mathf.Pow (2, pow));
		}

		Texture2D CreateMixTexture (int size)
		{
			var path = EditorUtility.SaveFilePanel ("Save texture as?", "Assets", "splatMap.png", "png");
			if (path.Length != 0 && path.IndexOf ("Assets") != -1) {
				Texture2D splatmap = new Texture2D (size, size);
				splatmap.hideFlags = HideFlags.DontSave;

				var c = new Color[size * size];
				for (var i = 0; i < c.Length; i++)
					c [i] = new Color (0, 0, 0, 0);

				splatmap.SetPixels (c);
				var data = splatmap.EncodeToPNG ();
				File.WriteAllBytes (path, data);

				AssetDatabase.Refresh (ImportAssetOptions.ForceSynchronousImport);
				path = path.Substring (path.IndexOf ("Assets"));
				splatmap = (Texture2D)AssetDatabase.LoadAssetAtPath (path, typeof(Texture2D));

				var textureImporter = AssetImporter.GetAtPath (path) as TextureImporter;
				#if UNITY_5_5_OR_NEWER
				textureImporter.textureCompression = TextureImporterCompression.Uncompressed;
				#else
				textureImporter.textureFormat = TextureImporterFormat.ARGB32;
				#endif
				textureImporter.mipmapEnabled = false;
				textureImporter.isReadable = true;
				AssetDatabase.ImportAsset (path, ImportAssetOptions.ForceUpdate);

				return splatmap;
			}

			Debug.LogWarning ("Please select a folder inside Assets folder");

			return null;
		}

		public static void SetPaintTextureFormatReadable (Texture2D texture, bool isReadable)
		{
			string path = AssetDatabase.GetAssetPath (texture);
			var textureImporter = AssetImporter.GetAtPath (path) as TextureImporter;
			textureImporter.isReadable = isReadable;
			AssetDatabase.ImportAsset (path, ImportAssetOptions.ForceUpdate);
            //AssetDatabase.Refresh();
        }

     
        public static void ConvertTextureFormat(Texture2D texture, TextureImporterFormat targetformat, bool overriden)
        {
            string path = AssetDatabase.GetAssetPath(texture);

            var textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;

            TextureImporterPlatformSettings platformSettings = textureImporter.GetPlatformTextureSettings("Android");
            platformSettings.overridden = overriden;
            platformSettings.format = targetformat;
            //platformSettings.textureCompression = TextureImporterCompression.Uncompressed;
            textureImporter.SetPlatformTextureSettings(platformSettings);
            textureImporter.mipmapEnabled = false;
            textureImporter.isReadable = true;
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            //AssetDatabase.Refresh();
        }


        public static void ConvertTextureFormat(Texture2D texture)
        {
            string path = AssetDatabase.GetAssetPath(texture);

            var textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;

            TextureImporterPlatformSettings platformSettings = textureImporter.GetPlatformTextureSettings("Android");
            platformSettings.format = TextureImporterFormat.RGB24;
            platformSettings.overridden = true;
            textureImporter.SetPlatformTextureSettings(platformSettings);
            textureImporter.mipmapEnabled = false;
            textureImporter.isReadable = true;
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            //AssetDatabase.Refresh();
        }




        public static bool isTextureReadable (Texture2D texture)
		{
			string path = AssetDatabase.GetAssetPath (texture);
		
			var textureImporter = AssetImporter.GetAtPath (path) as TextureImporter;
            if (null == textureImporter)
            {
                Debug.LogError("textureImporter is null");
                return false;
            }
                

			return textureImporter.isReadable;
		}

		void OnGUI ()
		{
			_selectedSplatSize = EditorGUILayout.Popup ("size", _selectedSplatSize, _splatSizes); 

			if (GUILayout.Button ("Create")) {
				var t = CreateMixTexture (CalcSize (_selectedSplatSize));

				if (EventCreated != null)
					EventCreated (t);

				this.Close ();
			}
		}
	}

}
