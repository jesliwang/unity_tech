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
        //-------------------------------------------------- 
        //Define
        const string WINDOWNAME = "TAD Profiler";
        static MainWindow _Instance;

        enum EState
        {
            Fx,
            Shader,
            Texture,
            Mesh,
        }

        EState _state = EState.Fx;
        bool _bUIInit = false;
        
        #region GUI STYLE
        public GUISkin      _Skin;
        protected GUIStyle  _styleHeader        = new GUIStyle(),
                            _styleHeaderLeft    = new GUIStyle(),
                            _styleCell          = new GUIStyle(),
                            _styleEmptyWindow   = new GUIStyle(),
                            _styleButton        = new GUIStyle();
        #endregion
        
        public static MainWindow instance
        {
            get
            {
                if (_Instance == null)
                    _Instance = EditorWindow.GetWindow<MainWindow>(false, WINDOWNAME, true);

                return _Instance;
            }
        }

        void Awake()
        {
            _bUIInit = false;
            InitGUIStyle();
        }
    
        #region Initialize GUI Style
        public void InitGUIStyle()
        {
            try
            {
                // Header
                _styleHeader.normal.textColor = Color.gray;
                _styleHeader.alignment = TextAnchor.MiddleCenter;
                _styleHeader.fontStyle = FontStyle.Bold;

                // Header Left
                _styleHeaderLeft.normal.textColor = Color.gray;
                _styleHeaderLeft.alignment = TextAnchor.MiddleLeft;
                _styleHeaderLeft.fontStyle = FontStyle.Bold;

                // Cell
                _styleCell.normal.textColor = Color.gray;
                _styleCell.alignment = TextAnchor.MiddleCenter;


                // Button
                _styleButton = new GUIStyle(EditorStyles.toolbarButton);
                _styleButton.alignment = TextAnchor.MiddleLeft;

                // Window
                _styleEmptyWindow.normal.textColor = Color.grey;
                _bUIInit = true;
            }
            catch(System.Exception e)
            {
                Debug.Log(e.Message);
            }
        }
        #endregion

        public static bool IsExist()
        {
            return _Instance != null;
        }

        public virtual void Release()
        {
            _Instance = default(MainWindow);
        }   

        void Update()
        {
            if( _bUIInit == false )
            {
                InitGUIStyle();
            }

            if (!EditorApplication.isPlaying || EditorApplication.isPaused)
            {
                //OnGUI 가속
                Repaint();
            }
        }

        void OnInspectorUpdate()
        {
            // This will only get called 10 times per second.
            Repaint();
        }
        void OnDestroy()
        {
            Release();
        }
        

        void OnGUI()
        {
#if UNITY_EDITOR
            OnGUI_Toolbar();

            if (!_bEnableRun)
                return;


            if (_state == EState.Fx)
            {
                OnGUI_Fx();
            }
            else if (_state == EState.Shader)
            {
                OnGUI_Shader();
            }
            else if (_state == EState.Texture)
            {
                OnGUI_Textrue();
            }
            else if (_state == EState.Mesh)
            {
                OnGUI_Mesh();
            }
#endif
        }     
    }
}