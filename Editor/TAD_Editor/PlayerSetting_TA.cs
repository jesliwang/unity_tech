using UnityEditor;
using UnityEngine;
using System.Collections;

namespace TAD.PlayerSettingSC
{
    public class MenuItems : EditorWindow
    {
        //--------------------------------------------------
        //Define
        const string MENUNAME1 = "TAD/Setting/SC_PlayerSettings";
        const string MENUNAME2 = "TAD/Setting/SC_Quality";

        //--------------------------------------------------
        //Menu
        [MenuItem(MENUNAME1)]
        private static void OpenPlayerSettings()
        {
            EditorApplication.ExecuteMenuItem("Edit/Project Settings/Player");
            
        }

        [MenuItem(MENUNAME2)]
        private static void OpenQuality()
        {
            EditorApplication.ExecuteMenuItem("Edit/Project Settings/Quality");
        }
    }
}
