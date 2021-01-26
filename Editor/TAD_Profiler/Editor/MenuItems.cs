using UnityEngine;
using UnityEditor;
using System.Collections;

namespace TAD
{
    public class MenuItems : EditorWindow
    {
        //--------------------------------------------------
        //Define
        const string MENUNAME = "TAD/Profiler";

        //--------------------------------------------------
        //Menu
        [MenuItem(MENUNAME)]
        static public void ShowAssetbundle()
        {
            if (!MainWindow.IsExist())
            {
                MainWindow.instance.Show();
            }
            else
            {
                MainWindow.instance.Close();
            }
        }
    }
}
