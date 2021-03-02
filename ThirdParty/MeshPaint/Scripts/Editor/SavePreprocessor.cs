using UnityEngine;
using UnityEditor;
using System.Collections;

namespace MeshPainter
{
	public class SavePreprocessor : UnityEditor.AssetModificationProcessor
	{
		public static System.Action BeforeSaveEvent;

		public static string[] OnWillSaveAssets (string[] paths)
		{
			foreach (string path in paths) {
				if (path.Contains (".unity")) {
					#if UNITY_5_3_OR_NEWER
					if (path == UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene().path) {
					#else
					if (path == EditorApplication.currentScene) {
						#endif
						if (BeforeSaveEvent != null)
							BeforeSaveEvent ();
						break;
					}
				}
			}
			return paths;
		}
	}

}