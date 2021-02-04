using UnityEngine;
using System.Text;
using System.IO;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;

namespace TAD
{

    public partial class MainWindow : EditorWindow
    {
        private bool _bEnableRun = false;

        void OnGUI_Toolbar()
        {
            GUILayout.BeginHorizontal(EditorStyles.toolbar, GUILayout.ExpandWidth(true));
            {
                GUILayout.BeginHorizontal();
                {


                    _bEnableRun = GUILayout.Toggle(_bEnableRun, "Enable", EditorStyles.toolbarButton);

                    if (GUILayout.Toggle(_state == EState.Fx, "FX", EditorStyles.toolbarButton))
                    {
                        _state = EState.Fx;
                    }
                    if (GUILayout.Toggle(_state == EState.Shader, "SHADER", EditorStyles.toolbarButton))
                    {
                        _state = EState.Shader;
                    }
                    if (GUILayout.Toggle(_state == EState.Texture, "TEXTURE", EditorStyles.toolbarButton))
                    {
                        _state = EState.Texture;
                    }
                    if (GUILayout.Toggle(_state == EState.Mesh, "MESH", EditorStyles.toolbarButton))
                    {
                        _state = EState.Mesh;
                    }

                    
                }
                GUILayout.EndHorizontal();

                GUILayout.FlexibleSpace();

                GUILayout.BeginHorizontal();
                {
                    GUIContent createButton = new GUIContent("Menu");
                    Rect createButtonRect = GUILayoutUtility.GetRect(createButton, EditorStyles.toolbarDropDown, GUILayout.ExpandWidth(false));
                    if (GUI.Button(createButtonRect, createButton, EditorStyles.toolbarDropDown))
                    {
                        OnGUI_Toolbar_Menu(createButtonRect);  // >>>>> Menu 호출
                    }
                }
                GUILayout.EndHorizontal();
            }
            GUILayout.EndHorizontal();          
        }

        void OnGUI_Toolbar_Menu(Rect rect)
        {
            GUIUtility.hotControl = 0;
            GUIContent[] menuItems = new GUIContent[] 
                { 
                    new GUIContent("Close"), 
                };
            EditorUtility.DisplayCustomMenu(rect, menuItems, -1,
                                            delegate(object userData, string[] options, int selected)
                                            {
                                                switch (selected)
                                                {
                                                    case 0:
                                                        Close();
                                                        break;
                                                }
                                            }
            , null);
        }

    }
}