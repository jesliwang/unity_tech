using UnityEngine;
using UnityEditor;
using System.Collections;

namespace MeshPainter
{
	public class Settings
	{

		static string AutoCreateMeshColliderSaveKey = "AutoCreateMeshColliderSaveKey";
		static string ImportUserBrushesSaveKey = "ImportUserBrushesSaveKey";
		static string GPUScaleSaveKey = "GPUScaleSaveKey";

		public static void Init ()
		{
			if (!EditorPrefs.HasKey (AutoCreateMeshColliderSaveKey)) {
				EditorPrefs.SetBool (AutoCreateMeshColliderSaveKey, true);
			}
			
			if (!EditorPrefs.HasKey (ImportUserBrushesSaveKey)) {
				EditorPrefs.SetBool (ImportUserBrushesSaveKey, true);
			}

			if (!EditorPrefs.HasKey (GPUScaleSaveKey)) {
				#if UNITY_5
					EditorPrefs.SetBool (GPUScaleSaveKey, true);
				#else
				EditorPrefs.SetBool (GPUScaleSaveKey, false);
				#endif
			}

			_autoCreateMeshCollider = EditorPrefs.GetBool (AutoCreateMeshColliderSaveKey);
			_importUserBrushes = EditorPrefs.GetBool (ImportUserBrushesSaveKey);
			_useGPUScale = EditorPrefs.GetBool (GPUScaleSaveKey);
		}

		static bool _importUserBrushes;
		static bool _autoCreateMeshCollider;
		static bool _useGPUScale;

		public static bool UseGPUScale { 
			get {
				#if UNITY_5
				return _useGPUScale;
				#else
				return false;
				#endif
			} 
			set { 
				_useGPUScale = value; 
				EditorPrefs.SetBool (GPUScaleSaveKey, _useGPUScale);
			}  
		}

		public static bool AutoCreateMeshCollider {
			get {
				return _autoCreateMeshCollider;
			} 
			set { 
				_autoCreateMeshCollider = value; 
				EditorPrefs.SetBool (AutoCreateMeshColliderSaveKey, _autoCreateMeshCollider);
			}  
		}

		public static bool ImportUserBrushes {
			get {
				return _importUserBrushes;
			} 
			set { 
				_importUserBrushes = value; 
				EditorPrefs.SetBool (ImportUserBrushesSaveKey, _importUserBrushes);
			}  
		}
	
	}

}