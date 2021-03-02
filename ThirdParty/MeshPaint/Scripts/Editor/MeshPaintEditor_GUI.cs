using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;

namespace MeshPainter
{
    public partial class MeshPaintEditor
    {
        #region Setting
        void SettingsGUI()
        {
            if (_canPaint)
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("Paint"))
                {
                    _target.SettingsEnabled = false;
                    OnChangeMode(true);
                    UpdateMaterial();
                }
                EditorGUILayout.EndHorizontal();
            }
            else
            {
                GUILayout.Label("fill the required fields", _textBoxStyle);
            }
            layoutSettingAuto();
            layoutSettingSplats();
            layoutSettingDetails();

            //GUILayout.Label("Options", EditorStyles.boldLabel);

            //if (AutoCreateMeshColliderOptionItemGUI("Auto create mesh collider"))
            //    SetupColiders();
            //if (ImportUserBrushesOptionItemGUI("Import custom brushes"))
            //    LoadBrushes();
            //if (UseGPUScaleOptionItemGUI("Use GPU brush scale"))
            //    LoadBrushes();
        }
        private void layoutSettingAuto()
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.BeginVertical();
            string detail = EditorGUILayout.TextField("DetailName", ShaderDetailProperty, GUILayout.Height(ButtonSize / 2));
            if (detail != ShaderDetailProperty)
            {
                Undo.RecordObject(_target, "DetailName");
                ShaderDetailProperty = detail;
            }
            string mask = EditorGUILayout.TextField("MaskName", ShaderControlProperty, GUILayout.Height(ButtonSize / 2));
            if (mask != ShaderControlProperty)
            {
                Undo.RecordObject(_target, "MaskName");
                ShaderControlProperty = mask;
            }
            EditorGUILayout.EndVertical();

            if (GUILayout.Button("SetPropertiesAuto", GUILayout.Height(ButtonSize)))
            {
                UpdateSplatInfosByAuto();
            }
            EditorGUILayout.EndHorizontal();
        }

        private void layoutSettingSplats()
        {
            GUILayout.Label("*Splatmap", EditorStyles.boldLabel);

            EditorGUILayout.BeginHorizontal();

            Texture2D source = null;

            for (int i = 0; i < _target.SplatInfos.Count; i++)
            {
                EditorGUILayout.BeginVertical(GUILayout.Width(ButtonSize));
                source = (Texture2D)EditorGUILayout.ObjectField(_target.SplatInfos[i].Mask?.Texture, typeof(Texture2D), false, GUILayout.Width(ButtonSize), GUILayout.Height(ButtonSize));

                if (null!= _target.SplatInfos[i].Mask && source != _target.SplatInfos[i].Mask.Texture)
                {
                    Undo.RecordObject(_target, "Change Splatmap");
                    _target.SplatInfos[i].Mask.Texture = source;
                    UpdateMaterial();
                }
                if (_target.SplatInfos.Count <= i)
                    continue;

                // 레이어 
                GUILayout.Label("MaskLayer", EditorStyles.miniLabel);
                int maskLayer = EditorGUILayout.IntField(_target.SplatInfos[i].MaskLayer, GUILayout.Width(ButtonSize));
                // 디테일 카운트
                GUILayout.Label("DetailCount", EditorStyles.miniLabel);
                int detailCount = EditorGUILayout.IntField(_target.SplatInfos[i].DetailCount, GUILayout.Width(ButtonSize));


                if (maskLayer != _target.SplatInfos[i].MaskLayer)
                {
                    Undo.RecordObject(_target, "Splat MaskLayer");

                    _target.SplatInfos[i].MaskLayer = maskLayer;
                }

                if (detailCount != _target.SplatInfos[i].DetailCount)
                {
                    Undo.RecordObject(_target, "Splat DetailCount");

                    _target.SplatInfos[i].DetailCount = detailCount;
                    //UpdateSplatInfos();
                }


                EditorGUILayout.EndVertical();
            }


            EditorGUILayout.EndHorizontal();
        }

        private void layoutSettingDetails()
        {
            GUILayout.Label("*Detail", EditorStyles.boldLabel);

            Texture2D source = null;

            for (int i = 0; i < _target.SplatInfos.Count; ++i)
            {
                if (null == _target.SplatInfos[i])
                    continue;

                EditorGUILayout.BeginHorizontal();

                for (int j = 0; j < _target.SplatInfos[i].DetailCount; ++j)
                {

                    EditorGUILayout.BeginVertical(GUILayout.Width(ButtonSize));
                    source = (Texture2D)EditorGUILayout.ObjectField(_target.SplatInfos[i].RGBA[j].Texture, typeof(Texture2D), false, GUILayout.Width(ButtonSize), GUILayout.Height(ButtonSize));

                    if (source != _target.SplatInfos[i].RGBA[j].Texture)
                    {
                        Undo.RecordObject(_target, "Detail Texture");

                        _target.SplatInfos[i].RGBA[j].Texture = source;

                        UpdateMaterial();
                    }

                    GUILayout.Label("Tiling xy", EditorStyles.miniLabel);
                    float tilingx = EditorGUILayout.FloatField(_target.SplatInfos[i].RGBA[j].Tiling.x, GUILayout.Width(ButtonSize));
                    float tilingy = EditorGUILayout.FloatField(_target.SplatInfos[i].RGBA[j].Tiling.y, GUILayout.Width(ButtonSize));

                    if (tilingx != _target.SplatInfos[i].RGBA[j].Tiling.x || tilingy != _target.SplatInfos[i].RGBA[j].Tiling.y)
                    {
                        Undo.RecordObject(_target, "Detail Tiling");

                        _target.SplatInfos[i].RGBA[j].Tiling = new Vector2(tilingx, tilingy);

                        UpdateMaterial();
                    }

                    
                    EditorGUILayout.EndVertical();
                }

                EditorGUILayout.EndHorizontal();
            }
        }
        #endregion Setting

        #region Paint
        void PaintGUI()
        {
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("Setings"))
            {
                _target.SettingsEnabled = true;
                OnChangeMode(false);
                //UpdateDetails();
            }
            EditorGUILayout.EndHorizontal();

            if (_canPaint)
            {
                if (_currentBrush == null)
                {
                    GUILayout.Label(GetToolStartText(), _textBoxStyle);
                }
                else if (_target.GetComponent<MeshCollider>() == null)
                {
                    GUILayout.Label("Please add a MeshColider to painting", _textBoxStyle);
                }
                else
                {
                    GUILayout.Label(GetToolUseText(), _textBoxStyle);
                }
            }

            layoutPaintDetails();


            GUILayout.Label("Tools", EditorStyles.boldLabel);

            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(4);


            if (GUILayout.Button(_brushIcon, SelectionStyle(_target.Tool == ToolBrush), GUILayout.Width(ButtonSize), GUILayout.Height(ButtonSize)))
            {
                _target.Tool = ToolBrush;

                if (_target.SelectedBrushIndex > 0)
                    SelectBrush(_target.SelectedBrushIndex, _target.SelectedBrushScale);
                else
                    SelectBrush(0, 1);
            }

            //if (GUILayout.Button(_fillIcon, SelectionStyle(_target.Tool == ToolFill), GUILayout.Width(ButtonSize), GUILayout.Height(ButtonSize)))
            //{
            //    SelectFill();
            //}

            EditorGUILayout.EndHorizontal();

            GUILayout.Label("Brushes", EditorStyles.boldLabel);

            int maxPerLine = Screen.width / (ButtonSize + GuiSpace + 4);
            int buttonsPerLine = Mathf.Min(maxPerLine, _brushes.Count);
            int lines = Mathf.CeilToInt((float)_brushes.Count / (float)buttonsPerLine);

            _target.BrushesScrollPosition = GUILayout.BeginScrollView(_target.BrushesScrollPosition, GUILayout.Height((ButtonSize + GuiSpace) * 3));

            GUILayout.BeginVertical();

            for (int i = 0; i < lines; i++)
            {
                GUILayout.Space(4);
                GUILayout.BeginHorizontal();

                for (int j = 0; j < buttonsPerLine; j++)
                {
                    int index = (i * buttonsPerLine) + j;

                    if (index < _brushes.Count)
                    {
                        GUILayout.Space(4);
                        if (GUILayout.Button(_brushes[index].OriginalTexture, SelectionStyle(_brushes[index] == _currentBrush), GUILayout.Width(ButtonSize), GUILayout.Height(ButtonSize)))
                        {
                            SelectBrush(index, 1f);
                        }
                    }
                }

                GUILayout.EndHorizontal();
            }

            GUILayout.EndVertical();

            GUILayout.EndScrollView();

            //GUILayout.BeginHorizontal();
            //layoutSwitchToAndroidFormat();
            

            //GUILayout.EndHorizontal();

            if (_target.Tool == ToolBrush)
            {
                GUILayout.Label("Scale", EditorStyles.boldLabel);

                float scale = EditorGUILayout.Slider(_target.SelectedBrushScale, 0.1f, 10f);
                if (!Mathf.Approximately(scale, _target.SelectedBrushScale))
                {
                    Undo.RecordObject(_target, "Brush Scale");
                    _target.SelectedBrushScale = scale;

                    if (_currentBrush != null)
                    {
                        _currentBrush.Scale = scale;
                        _previewManager.PreviewBrush(_currentBrush);
                    }
                }
            }

            GUILayout.Label("Softness", EditorStyles.boldLabel);

            float hardness = EditorGUILayout.Slider(_target.SelectedBrushHardness, 0.01f, 0.2f);

            if (!Mathf.Approximately(hardness, _target.SelectedBrushHardness))
            {
                Undo.RecordObject(_target, "Brush Softness");
                _target.SelectedBrushHardness = hardness;
            }


            if (_target.Tool == ToolFill)
            {
                GUILayout.Label("Fill Threshold", EditorStyles.boldLabel);

                float threshold = EditorGUILayout.Slider(_target.SelectedFillThreshold, 0.1f, 0.8f);

                if (!Mathf.Approximately(threshold, _target.SelectedFillThreshold))
                {
                    Undo.RecordObject(_target, "Fill Threshold");
                    _target.SelectedFillThreshold = threshold;
                }
            }

        }

        private void layoutPaintDetails()
        {
            GUILayout.Label("Detail", EditorStyles.boldLabel);

            for (int i = 0; i < _target.SplatInfos.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                GUILayout.Space(4);
                for (int j = 0; j < _target.SplatInfos[i].DetailCount; ++j)
                {
                    int paintIndex = i * DetailPerSplat + j;
                    if (_target.SplatInfos[i].RGBA[j] != null && GUILayout.Button(new GUIContent(_target.SplatInfos[i].RGBA[j].Texture), SelectionStyle(paintIndex == _target.SelectedPaintDetailIndex), GUILayout.Width(ButtonSize), GUILayout.Height(ButtonSize)))
                    {
                        _target.SelectedPaintDetailIndex = paintIndex;
                    }
                }
                //Rect rect = GUILayoutUtility.GetLastRect();
                //rect.x += 2;
                //rect.y += 2;
                //rect.width -= 4;
                //rect.height -= 4;
                //GUI.DrawTexture(rect, _target.Details[i].Texture, ScaleMode.ScaleToFit, false);
                EditorGUILayout.EndHorizontal();
                GUILayout.Space(4);
            }

        }
        private void layoutSwitchToAndroidFormat()
        {
            GUILayout.Label("Switch Android Format", EditorStyles.boldLabel);
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("RGB24", GUILayout.Width(ButtonSize * 1.5f)))
            {
                SwitchSplatFormat(TextureImporterFormat.ETC2_RGB4);
            }
            if (GUILayout.Button("RGBA32", GUILayout.Width(ButtonSize * 1.5f)))
            {
                SwitchSplatFormat(TextureImporterFormat.ETC2_RGBA8);
            }
            
            GUILayout.EndHorizontal();
        }
        #endregion
    }
}
