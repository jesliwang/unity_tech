using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;

namespace MeshPainter
{
    [CustomEditor(typeof(MeshPaint))]
	public partial class MeshPaintEditor : Editor
	{
		MeshPaint _target;
		Material _targetMaterial;
        MeshCollider _targetMeshCollider;
        bool _canPaint;
		bool _painting;
		bool _painted;
		PreviewManager _previewManager = new PreviewManager();
		Brush _currentBrush
        {
            get
            {
                if (null == _target || -1 == _target.SelectedBrushIndex)
                    return null;

                switch(_target.Tool)
                {
                    case ToolBrush:
                        {
                            if (_target.SelectedBrushIndex >= _brushes.Count)
                                return null;

                            return _brushes[_target.SelectedBrushIndex];
                        }

                    case ToolFill:
                        {
                            return _fillBrush;
                        }
                    case ToolNone:
                        {
                            return null;
                        }
                }
                return null;
            }
        }
		List<Brush> _brushes = new List<Brush>();
		const int ButtonSize = 40;
		const int GuiSpace = 10;
		int DetailPerSplat { get { return  MeshPaint.DetailPerSplat; }} 
		public const string AutoCreateMeshColliderSaveKey = "AutoCreateMeshColliderSaveKey";
		public const string ImportUserBrushesSaveKey = "ImportUserBrushesSaveKey";
        [SerializeField] string ShaderDetailProperty = "_Texture";
        [SerializeField] string ShaderControlProperty = "_Mask";
		GUIStyle _textBoxStyle;

		public const int ToolNone = -1;
		public const int ToolBrush = 0;
		public const int ToolFill = 1;

		Texture2D _fillIcon;
		Texture2D _brushIcon;
		Texture2D _fillPreview;
		Brush _fillBrush;

		void OnEnable ()
		{
			_target = target as MeshPaint;
			_targetMaterial = _target.GetComponent<MeshRenderer> ().sharedMaterial;
            _targetMeshCollider = _target.GetComponent<MeshCollider>();

			_target.SplatPainted = false;

			Undo.undoRedoPerformed += UndoCallback;
			CheckCanPaint ();

			var thisPath = CurrentScriptPath();
			
			_fillIcon = LoadTexture(thisPath + "/Icons/Fill.png");
			_brushIcon = LoadTexture(thisPath + "/Icons/Brush.png");
			_fillPreview = LoadTexture(thisPath + "/Icons/FillPreview.png");

			_fillBrush = new Brush (_fillPreview);

			Settings.Init ();

			if (SavePreprocessor.BeforeSaveEvent == null) {
				SavePreprocessor.BeforeSaveEvent += BeforeSave;
			}
		}
        
		void OnDisable ()
		{
			Undo.undoRedoPerformed -= UndoCallback;
			SavePreprocessor.BeforeSaveEvent -= BeforeSave;
            _target.SettingsEnabled = false;
            _previewManager.DestoryProjector ();
		
			if (_brushes != null)
            {
				foreach (Brush b in _brushes)
                {
					b.Destroy ();
				}
			}
            _brushes.Clear();


            if (SelectionChanged ()) {
				_target.UndoManager.Step = -1;
				_target.SelectedBrushIndex = -1;
				_target.Tool = ToolBrush;
				_target.SettingsEnabled = false;
			
				WriteTexture ();
			}
		}

        void BeforeSave ()
		{
			_target.UndoManager.HasUndoRedoPerformed = true;
			EditorUtility.SetDirty (_target);
			WriteTexture ();
		}

		void WriteTexture ()
		{
            if (_target.SplatPainted)
            {
                _target.SplatPainted = false;

                for (int i = 0; i < _target.SplatInfos.Count; ++i)
                {
                    _writeTexture(_target.SplatInfos[i].Mask?.Texture);
                    
                }
            }

            AssetDatabase.Refresh ();
		}
        void _writeTexture(Texture2D splat)
        {
            if (null == splat)
                return;

            string path = AssetDatabase.GetAssetPath(splat);

            if (path.Length > 0)
            {
                var extension = System.IO.Path.GetExtension(path);
                if (string.IsNullOrEmpty(extension))
                    return;

                if (extension == ".tga")
                {
                    System.IO.File.WriteAllBytes(path, splat.EncodeToTGA());
                }
                else
                {
                    System.IO.File.WriteAllBytes(path, splat.EncodeToPNG());
                }
            }
        }

		void CheckCanPaint ()
		{
            _canPaint = CheckMaterial() && _target.CanPaint();
		}

		bool SelectionChanged ()
		{
			return _target == null || Selection.activeObject != _target.gameObject;
		}

		void UndoCallback ()
		{
			_target.UndoManager.UndoRedoPerformed ();
		}
	
		public override void OnInspectorGUI ()
		{
			_textBoxStyle = GUI.skin.GetStyle ("HelpBox");

			KeyBoardShortcutsGUI ();
			CheckCanPaint ();

			if (_canPaint)
            {
				switch (Event.current.type) {
				case EventType.Layout:

					//if (_brushes.Count == 0)
     //                   {
					//	LoadBrushes ();
					//}

					break;
				}

				if (_target.SettingsEnabled) {
					SettingsGUI ();
				} else {
					PaintGUI ();
				}
			}
            else
            {

				if (_target.SelectedBrushScale < 0.1f)
					_target.SelectedBrushScale = 1f;
			
				if (_target.SelectedBrushHardness < 0.1f)
					_target.SelectedBrushHardness = 1f;

				if (_target.SelectedFillThreshold < 0.1f)
					_target.SelectedFillThreshold = 0.2f;

				if (!CheckMaterial ())
                {
					MaterialGUI ();
				}
                else
                {
                    UpdateSplatInfosByAuto();
					//CopyFromMaterial ();
					CheckCanPaint ();

					_target.SettingsEnabled = true;
					SettingsGUI ();
				}
			}

            if (GUILayout.Button("Done", GUILayout.Height(ButtonSize)))
            {
                Done();
            }
        }

        private void Done()
        {
            WriteTexture();
            for (int i = 0; i < _target.SplatInfos.Count; ++i)
            {
                CreateSplatmap.SetPaintTextureFormatReadable(_target.SplatInfos[i].Mask?.Texture, false);
            }
            DestroyImmediate(_target);
            DestroyImmediate(_targetMeshCollider);
        }

		void MaterialGUI ()
		{
			GUILayout.Label ("Please select a supported shader", _textBoxStyle);
		}

		bool AutoCreateMeshColliderOptionItemGUI (string title)
		{
			bool current = Settings.AutoCreateMeshCollider;
			EditorGUILayout.BeginHorizontal ();
			bool result = EditorGUILayout.Toggle (current, GUILayout.Width (20));
			Settings.AutoCreateMeshCollider = result;
			GUILayout.Label (title, EditorStyles.label);
			EditorGUILayout.EndHorizontal ();

			return result != current;
		}

        bool ImportUserBrushesOptionItemGUI(string title)
        {
            bool current = Settings.ImportUserBrushes;
            EditorGUILayout.BeginHorizontal();
            bool result = EditorGUILayout.Toggle(current, GUILayout.Width(20));
            Settings.ImportUserBrushes = result;
            GUILayout.Label(title, EditorStyles.label);
            EditorGUILayout.EndHorizontal();

            return result != current;
        }

        bool UseGPUScaleOptionItemGUI(string title)
        {
            bool current = Settings.UseGPUScale;
            EditorGUILayout.BeginHorizontal();
#if !UNITY_5
            GUI.enabled = false;
#endif
            bool result = EditorGUILayout.Toggle(current, GUILayout.Width(20));
#if !UNITY_5
            GUI.enabled = true;
#endif
            Settings.UseGPUScale = result;
#if !UNITY_5
            GUILayout.Label(title + " (Unity 5+ only)", EditorStyles.label);
#else
			GUILayout.Label (title, EditorStyles.label);
#endif
            EditorGUILayout.EndHorizontal();

            return result != current;
        }

        string GetToolStartText()
		{
			if(_target.Tool == ToolFill)
				return GetToolUseText();

			return "Select a Brush to start painting";;
		}

		string GetToolUseText()
		{
			if (Application.platform == RuntimePlatform.OSXEditor) {
				if(_target.Tool == ToolBrush)
					return "Hold Cmd to start painting";
				else if(_target.Tool == ToolFill)
					return "Hold Cmd and click left mouse button to fill";
			} else {
				if(_target.Tool == ToolBrush)
					return "Hold Ctrl to start painting";
				else if(_target.Tool == ToolFill)
					return "Hold Ctrl and click left mouse button to fill";
			}

			return "Hold Ctrl/Cmd to start";
		}

		string SelectionStyle(bool selected)
		{
			//return selected ? "TL SelectionButton PreDropGlow" : "box";

			//return selected ? "U2D.createRect" : "box";

			//return selected ? "SelectionRect" : "box";

			//return selected ? "ProgressBarBar" : "box";

			return selected ? "LightmapEditorSelectedHighlight" : "box";

		}

		void OnSceneGUI ()
		{
			var ctrlID = GUIUtility.GetControlID ("MeshPainterProjector".GetHashCode (), FocusType.Passive);
		
			KeyBoardShortcutsGUI ();

			if (_canPaint) {
				switch (Event.current.type) {
				case EventType.MouseUp:

					if (_painting && _target.Tool == ToolFill) {

						FloodFill();
					}

					if (_painted) {
						RecordUndo ();
					}
					_painted = false;
					break;								
				case EventType.MouseDown:
				case EventType.MouseDrag:
					if (_painting && _target.Tool == ToolBrush) {
						UpdatePaint ();
						Event.current.Use ();
					}
					break;
				case EventType.MouseMove:
					HandleUtility.Repaint ();
					break;
				case EventType.Layout:
					if (Event.current.control || Event.current.command) {
						HandleUtility.AddDefaultControl (ctrlID);
					}

					break;			
				}

				UpdatePreview ();
			}
		}

		void KeyBoardShortcutsGUI ()
		{
			if (_canPaint) {
				switch (Event.current.type) {
				case EventType.KeyDown:
				
					if (Event.current.keyCode == (KeyCode.LeftBracket)) {
						ModifyBrushScale (-0.1f);
						Event.current.Use ();
						EditorUtility.SetDirty (_target);
					} else if (Event.current.keyCode == (KeyCode.RightBracket)) {
						ModifyBrushScale (0.1f);
						Event.current.Use ();
						EditorUtility.SetDirty (_target);
					}

					break;
				case EventType.Layout:

					bool paint = (Event.current.control || Event.current.command) && !Event.current.alt && _currentBrush != null;

					if (paint != _painting) {
						_painting = paint;
						StartStopPaint (_painting);
					}

					break;
				}
			}
		}

		void StartStopPaint (bool painting)
		{
			_target.PaintStatusPainting = painting;
		}

        bool CheckSplatFormat()
        {
            bool bCheck = true;
            for (int i = 0; i < _target.SplatInfos.Count; ++i)
            {
                var splat = _target.SplatInfos[i].Mask?.Texture;
                if(null == splat)
                {
                    Debug.LogError(string.Format("splatmap is null - index : {0}", i));
                    continue;
                }
                //[2020.06.19 이현태 세팅 따로 변경할일이 없음...]
                CreateSplatmap.ConvertTextureFormat(splat);
                //if (splat.format != TextureFormat.RGB24 && splat.format != TextureFormat.ARGB32 && splat.format != TextureFormat.RGBA32)
                //{
                //    if (EditorUtility.DisplayDialog("Switch format", "The splatmap format must be RGBA32 or  RGB24 \n\n please switch format ", "RGB24", "RGBA32"))
                //    {
                //        CreateSplatmap.ConvertTextureFormat(splat, TextureImporterFormat.RGB24, false);
                //    }
                //    else
                //    {
                //        CreateSplatmap.ConvertTextureFormat(splat, TextureImporterFormat.RGBA32, false);
                //    }
                //    continue;
                //}
                //
                //if ((!CreateSplatmap.isTextureReadable(splat)))
                //{
                //    if (EditorUtility.DisplayDialog("Wrong format", "Read/Write must be enabled to start painting. \n\n Switch format now?", "Yes", "Cancel"))
                //    {
                //        CreateSplatmap.SetPaintTextureFormatReadable(splat, true);
                //    }
                //    else
                //    {
                //        return false;
                //    }
                //}
            }

			return bCheck;
		}

        void SwitchSplatFormat(TextureImporterFormat format)
        {
            _target.SplatPainted = false;
            for (int i = 0; i < _target.SplatInfos.Count; ++i)
            {
                var splat = _target.SplatInfos[i].Mask?.Texture;
                if (null == splat)
                {
                    Debug.LogError(string.Format("splatmap is null - index : {0}", i));
                    continue;
                }

                _writeTexture(splat);

                CreateSplatmap.ConvertTextureFormat(splat, format, true);
            }

            AssetDatabase.Refresh();
        }
        bool IsTextureTGA(string path)
        {
            if (path.Length > 0)
            {
                var extension = System.IO.Path.GetExtension(path);
                if (!string.IsNullOrEmpty(extension) && extension == ".tga")
                    return true;
            }
            return false;
        }


        void PrepareMesh()
		{
			if (_target.UndoManager.Step == -1) { //record original state
				RecordUndo ();
			}
		}

		void SelectFill()
		{
			if (!CheckSplatFormat())
			{
				return;
			}

			if (!EditorApplication.isCompiling) {
				_target.Tool = ToolFill;
				//_currentBrush = _fillBrush;
				_currentBrush.Scale = _target.SelectedBrushScale;
				_previewManager.PreviewBrush (_currentBrush);
				
				PrepareMesh();
			}
		}

		void SelectBrush (int index, float scale)
		{
			if (!CheckSplatFormat())
			{
				return;
			}

			if (!EditorApplication.isCompiling && index < _brushes.Count) {
				_target.Tool = ToolBrush;
				_target.SelectedBrushIndex = index;
				//_currentBrush = _brushes [index];
				_currentBrush.Scale = _target.SelectedBrushScale;
				_previewManager.PreviewBrush (_currentBrush);

				PrepareMesh();
			}
		}

		void ModifyBrushScale (float add)
		{
			if (_target.Tool == ToolBrush && _currentBrush != null) {
				_target.SelectedBrushScale += add; ;
				_currentBrush.Scale = _target.SelectedBrushScale;
				_previewManager.PreviewBrush (_currentBrush);
			}
		}

		void LoadBrushes ()
		{
			if (_brushes != null)
				_brushes.Clear ();

			Texture2D texture = null;
			int num = 1;
			do {

				texture = (Texture2D)EditorGUIUtility.Load ("Brushes/builtin_brush_" + num + ".png");

				if (texture != null) {
					_brushes.Add (new Brush (texture));
				}

				num++;

			} while(texture != null);

			if (Settings.ImportUserBrushes) {

				var pathOnly = CurrentScriptPath();

				num = 0;

				do {

					texture = LoadTexture(pathOnly + "/CustomBrushes/brush_" + num + ".png");

					if (texture != null) {
						_brushes.Add (new Brush (texture));
					}

					num++;

				} while(texture != null);
			}

			if (_target != null) {
				if (_target.UndoManager!=null && _target.UndoManager.HasUndoRedoPerformed ) {
					_target.UndoManager.HasUndoRedoPerformed = false;

					if(_target.Tool == ToolBrush) {
						if (_target.SelectedBrushIndex > -1 && _brushes[_target.SelectedBrushIndex] != _currentBrush) {
							SelectBrush (_target.SelectedBrushIndex, _target.SelectedBrushScale);
						}
					} else if(_target.Tool == ToolFill) {
						SelectFill();
					}
				}
			}

			UpdateMaterial ();
		}

		string CurrentScriptPath()
		{
			var script = MonoScript.FromScriptableObject (this);
			var path = AssetDatabase.GetAssetPath (script);
			var pathOnly = path.Substring (0, path.LastIndexOf ("/"));

			return pathOnly;
		}

		Texture2D LoadTexture(string path)
		{
			#if UNITY_5 || UNITY_5_3_OR_NEWER

				#if UNITY_5_0_0 || UNITY_5_0_1
					return Resources.LoadAssetAtPath<Texture2D> (path);
				#else
					return AssetDatabase.LoadAssetAtPath<Texture2D> (path);
				#endif

			#else
				return Resources.LoadAssetAtPath<Texture2D> (path);
			#endif
		}

		void RecordUndo ()
		{
			Undo.RecordObject (_target, "Paint");

            List<Texture2D> splats = new List<Texture2D>();
            for(int i = 0; i < _target.SplatInfos.Count; ++i)
            {
                splats.Add(_target.SplatInfos[i].Mask?.Texture);
            }
			_target.UndoManager.Record (splats);
		}

		void PaintSplat (Texture2D splatMap, Color targetColor, Texture2D brush, Vector2 textCoord, float hardness)
		{
            if (null == splatMap)
                return;

			int brushWidth = brush.width;
			int brushHeight = brush.height;

			int x = Mathf.FloorToInt (textCoord.x * splatMap.width) - brushWidth / 2;
			int y = Mathf.FloorToInt (textCoord.y * splatMap.height) - brushHeight / 2;

			int xOffset = CalculateOffset (ref brushWidth, x, splatMap.width);
			int yOffset = CalculateOffset (ref brushHeight, y, splatMap.height);

			x = Mathf.Clamp (x, 0, splatMap.width);
			y = Mathf.Clamp (y, 0, splatMap.height);

			Color[] srcPixels = splatMap.GetPixels (x, y, brushWidth, brushHeight, 0);
            
			for (int i = 0; i < srcPixels.Length; i++) {
				int px = i % brushWidth;
				int py = Mathf.FloorToInt (i / brushWidth);

				float blendFactor = brush.GetPixel (px + xOffset, py + yOffset).a * hardness;
				srcPixels [i] = Color.Lerp (srcPixels [i], targetColor, blendFactor);
			}
			splatMap.SetPixels (x, y, brushWidth, brushHeight, srcPixels, 0);
			splatMap.Apply ();
		}

		int CalculateOffset (ref int brushSize, int pos, int sizeLimit)
		{
			int xOffset = 0;
			if (pos < 0) {
				xOffset = -pos;
				brushSize -= -pos;
			} else if (pos + brushSize > sizeLimit) {
				brushSize -= pos + brushSize - sizeLimit;
			}
		
			return xOffset;
		}

		Color GetTargetColor (int detailIndex)
		{
			switch (detailIndex%DetailPerSplat)
            {
			case 0:
				return new Color (1, 0, 0, 0);
			case 1:
				return new Color (0, 1, 0, 0);
			case 2:
				return new Color (0, 0, 1, 0);
			case 3:
				return new Color (0, 0, 0, 1);
			}

			return new Color (0, 0, 0, 0);
		}

        int GetTargetSplatIndex(int detailIndex)
        {
            return detailIndex / DetailPerSplat;
        }

		bool CoordRangeValid(Vector2 coord)
		{
			return coord.x >= 0f && coord.x <= 1f && coord.y >= 0f && coord.y <= 1f;
		}

		void UpdatePaint ()
		{
			Ray ray = HandleUtility.GUIPointToWorldRay (Event.current.mousePosition);
			RaycastHit hit;
            int PaintLayer = _target.gameObject.layer;
            //if (Physics.Raycast (ray, out hit, 1000f, 1 << PaintLayer) && hit.collider.gameObject == _target.gameObject)
            if (RaycastTarget(ray, out hit, 1000f))
            {
				if(CoordRangeValid(hit.textureCoord))
                {
                    int targetlayer = _target.GetTargetMaskLayer();
                    for (int i = 0; i < _target.SplatInfos.Count; ++i)
                    {
                        Color targetColor = _target.GetTargetColor(i);
                        if(_target.SplatInfos[i].MaskLayer == targetlayer)
                            PaintSplat(_target.SplatInfos[i].Mask?.Texture, targetColor, _currentBrush.PaintTexture, hit.textureCoord, _target.SelectedBrushHardness);
					}
					_painted = true;
					_target.SplatPainted = true;
				} else {
					Debug.LogWarning("mesh uv coordinates must be between 0 and 1");
				}
			}
		}

		void FloodFill()
		{
			Ray ray = HandleUtility.GUIPointToWorldRay (Event.current.mousePosition);
			RaycastHit hit;
            int PaintLayer = _target.gameObject.layer;
            
            //if (Physics.Raycast (ray, out hit, 1000f, 1 << PaintLayer) && hit.collider.gameObject == _target.gameObject) 
            if(RaycastTarget(ray, out hit, 1000f))
            { 
				if(CoordRangeValid(hit.textureCoord))
                {

					Color targetColor = GetTargetColor (_target.SelectedDetailIndex);
					int detailSplat = Mathf.CeilToInt (_target.SelectedDetailIndex / DetailPerSplat);

                    List<Texture2D> splats = new List<Texture2D>();
                    for (int i = 0; i < _target.SplatInfos.Count; ++i)
                    {
                        splats.Add(_target.SplatInfos[i].Mask?.Texture);
                    }

                    PaintUtils.FloodFillArea1 (detailSplat, splats, hit.textureCoord, targetColor, _target.SelectedBrushHardness, _target.SelectedFillThreshold);

					_painted = true;
					_target.SplatPainted = true;
				} else {
					Debug.LogWarning("mesh uv coordinates must be between 0 and 1");
				}
			}
		}

		void UpdatePreview ()
		{

			Vector2 newMousePostion = Event.current.mousePosition;

			#if UNITY_5_5_OR_NEWER
			Ray ray = HandleUtility.GUIPointToWorldRay (newMousePostion);
			#else
			newMousePostion.y = Screen.height - (newMousePostion.y + 36);
			Ray ray = Camera.current.ScreenPointToRay (newMousePostion);
			#endif

			RaycastHit hit = new RaycastHit();

            if (_currentBrush == null)
            {
                if(_target.SelectedBrushIndex == -1 || _brushes.Count <= _target.SelectedBrushIndex) 
                {
                    _previewManager.Enable = false;
                    return;
                }
                SelectBrush(_target.SelectedBrushIndex, _target.SelectedBrushScale);
            }
            int PaintLayer = _target.gameObject.layer;
            //if (false == Physics.Raycast(ray, out hit/*, 100000f, 1 << PaintLayer*/))
            if (false == RaycastTarget(ray, out hit/*, 100000f, 1 << PaintLayer*/))
            {
                _previewManager.Enable = false;
                return;
            }

            if (hit.collider.gameObject != _target.gameObject)
            {
                _previewManager.Enable = false;
                return;
            }
            _previewManager.Enable = true;

            if (_previewManager.Enable)
            {
                _previewManager.TransformNow(hit.point + (hit.normal * 100), Quaternion.LookRotation(hit.normal));
                _target.PaintStatusPosition = hit.point;
                _target.PaintStatusNormal = hit.normal;
            }
        }

        bool RaycastTarget(Ray ray, out RaycastHit hit, float maxDistacne = 1000.0f)
        {
            if (null == _target || null == _targetMeshCollider)
            {
                hit = new RaycastHit();
                return false;
            }

            if (_targetMeshCollider.Raycast(ray, out hit, 1000.0f) && hit.collider.gameObject == _target.gameObject)
                return true;

            return false;
        }

        bool CheckMaterial ()
		{
			if (_targetMaterial == null)
				return false;

            if (CountShaderTextureProperties() == 0)
                return false;

            return true;
		}
	

        int CountShaderTextureProperties()
        {
            int count = 0;
            int shadercnt = ShaderUtil.GetPropertyCount(_targetMaterial.shader);
            for (int i = 0; i < shadercnt; ++i)
            {
                if (ShaderUtil.ShaderPropertyType.TexEnv == ShaderUtil.GetPropertyType(_targetMaterial.shader, i))
                    ++count;
            }

            return count;
        }

        List<MeshPaint.TextureProperty> CopyPropertyFromMaterial()
        {
            if (_targetMaterial == null)
                return null;

            List<MeshPaint.TextureProperty> _textureproperties = new List<MeshPaint.TextureProperty>();

            int shadercnt = ShaderUtil.GetPropertyCount(_targetMaterial.shader);
            for (int i = 0; i < shadercnt; ++i)
            {
                if (ShaderUtil.ShaderPropertyType.TexEnv == ShaderUtil.GetPropertyType(_targetMaterial.shader, i))
                {
                    MeshPaint.TextureProperty prop = new MeshPaint.TextureProperty();
                    prop.Name = ShaderUtil.GetPropertyName(_targetMaterial.shader, i);
                    prop.Desc = ShaderUtil.GetPropertyDescription(_targetMaterial.shader, i);
                    prop.Texture = (Texture2D)_targetMaterial.GetTexture(prop.Name);
                    prop.Tiling = _targetMaterial.GetTextureScale(prop.Name);
                    _textureproperties.Add(prop);
                }
            }
            return _textureproperties;
        }

     

        void UpdateMaterial ()
		{
			if (_targetMaterial == null || _target == null) {
				return;
			}

        
            for (int i = 0; i < _target.SplatInfos.Count; ++i)
            {
                var splat = _target.SplatInfos[i].Mask;
                _targetMaterial.SetTexture(splat.Name, splat.Texture);

                for(int j = 0; j < _target.SplatInfos[i].RGBA.Length; ++j)
                {
                    var detail = _target.SplatInfos[i].RGBA[j];
                    if (null == detail) continue;
                    _targetMaterial.SetTexture(detail.Name, detail.Texture);
                    _targetMaterial.SetTextureScale(detail.Name, detail.Tiling);
                }
            }

			CheckCanPaint ();
		}


        void OnChangeMode(bool isPaint)
        {
            if(isPaint)
            {
                // update preview
                if(null != _previewManager)
                    _previewManager.DestoryProjector();

                _previewManager = new PreviewManager();
                _previewManager.CreateProjector(_target.GetComponent<MeshFilter>(), _target);

                // load brush
                LoadBrushes();
            }
        }

        void UpdateSplatInfosByAuto()
        {
            var textureproperties = CopyPropertyFromMaterial();
            if(null == textureproperties)
            {
                return;
            }

            _target.Clear();

            MeshPaint.SplatInfo addInfo = null;
            List<MeshPaint.SplatInfo> temp = new List<MeshPaint.SplatInfo>();
            for (int i = 0; i < textureproperties.Count; ++i)
            {
                if (null == addInfo)
                    addInfo = new MeshPaint.SplatInfo();

                // 디테일
                if (textureproperties[i].Name.Contains(ShaderDetailProperty))
                {
                    if(addInfo.DetailCount >= DetailPerSplat)
                    {
                        // RGB 개수를 넘기고 마스크가 없으면 자동 입력 종료
                        if (null == addInfo.Mask)
                            break;
                        temp.Add(addInfo);
                        addInfo = null;
                        addInfo = new MeshPaint.SplatInfo();
                        
                    }
                    ;
                    addInfo.RGBA[addInfo.DetailCount++] = textureproperties[i];
                }
                // 마스크
                else if(textureproperties[i].Name.Contains(ShaderControlProperty))
                {
                    if(null != addInfo.Mask)
                    {
                        temp.Add(addInfo);
                        // 마스크가 연속으로 들어온 경우 중단
                        if (0 == addInfo.DetailCount)
                            break;
                        addInfo = null;
                        addInfo = new MeshPaint.SplatInfo();
                    }
                    addInfo.Mask = textureproperties[i];
                    // 디테일 먼저 들어간 경우
                    if(addInfo.DetailCount > 0)
                    {
                        temp.Add(addInfo);
                        addInfo = null;
                        addInfo = new MeshPaint.SplatInfo();
                    }
                }

            }

            for(int i = 0; i < temp.Count; ++i)
            {
                if (null == temp[i].Mask || null == temp[i].Mask.Texture)
                    continue;
                _target.SplatInfos.Add(temp[i]);

            }
            temp.Clear();
            addInfo = null;
        }

	}

}
