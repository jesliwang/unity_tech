using System.Collections.Generic;
using System.Linq;
using System.Xml;
using UnityEditor;
using UnityEngine;


public class SymbolWindow : EditorWindow
{
    //===================================================================================================
    private class SymbolData
    {
        public string Name { get; private set; }   
        public string Comment { get; private set; }   
        public bool IsEnable { get; set; }   


        public SymbolData(XmlNode node)
        {
            Name = node.Attributes["name"].Value;
            Comment = node.Attributes["comment"].Value;
        }
    }

    //===================================================================================================

    private const string ITEM_NAME = "TAD/Tools/ChangeSymbols";              
    private const string WINDOW_TITLE = "Symbols";                 
    private const string XML_PATH = "Assets/External Assets/TAD/Editor/symbols.xml";  

    //===================================================================================================

    private static Vector2 mScrollPos;     
    private static SymbolData[] mSymbolList;  

    //===================================================================================================

    [MenuItem(ITEM_NAME)]
    private static void Open()
    {
        var window = GetWindow<SymbolWindow>(true, WINDOW_TITLE);
        window.Init();
    }

    private void Init()
    {
        var document = new XmlDocument();
        document.Load(XML_PATH);

        var root = document.GetElementsByTagName("root")[0];
        var symbolList = new List<XmlNode>();

        foreach (XmlNode n in root.ChildNodes)
        {
            if (n.Name == "symbol")
            {
                symbolList.Add(n);
            }
        }

        mSymbolList = symbolList
            .Select(c => new SymbolData(c))
            .ToArray();

        var defineSymbols = PlayerSettings
            .GetScriptingDefineSymbolsForGroup(EditorUserBuildSettings.selectedBuildTargetGroup)
            .Split(';');

        foreach (var n in mSymbolList)
        {
            n.IsEnable = defineSymbols.Any(c => c == n.Name);
        }
    }


    private void OnGUI()
    {
        EditorGUILayout.BeginVertical();
        mScrollPos = EditorGUILayout.BeginScrollView(
            mScrollPos,
            GUILayout.Height(position.height)
        );
        foreach (var n in mSymbolList)
        {
            EditorGUILayout.BeginHorizontal(GUILayout.ExpandWidth(true));
            n.IsEnable = EditorGUILayout.Toggle(n.IsEnable, GUILayout.Width(20));
            if (GUILayout.Button("Copy"))
            {
                EditorGUIUtility.systemCopyBuffer = n.Name;
            }
            EditorGUILayout.LabelField(n.Name, GUILayout.ExpandWidth(true), GUILayout.MinWidth(0));
            EditorGUILayout.LabelField(n.Comment, GUILayout.ExpandWidth(true), GUILayout.MinWidth(0));          
            EditorGUILayout.EndHorizontal();
        }
        if (GUILayout.Button("Save"))
        {
            var defineSymbols = mSymbolList
                .Where(c => c.IsEnable)
                .Select(c => c.Name)
                .ToArray();

            PlayerSettings.SetScriptingDefineSymbolsForGroup(
                EditorUserBuildSettings.selectedBuildTargetGroup,
                string.Join(";", defineSymbols)
            );
            Close();
        }
        EditorGUILayout.EndScrollView();
        EditorGUILayout.EndVertical();
    }
}
