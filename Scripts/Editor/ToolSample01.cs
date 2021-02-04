using UnityEditor;
using UnityEngine;
using System.Collections;

public class ExampToolSample01 : EditorWindow
{
    public Object source;

    [MenuItem("TAD/ObjectField Example")]
    static void Init()
    {
        var window = GetWindowWithRect<ExampToolSample01>(new Rect(0, 0, 265, 200));
        window.Show();
    }

    void OnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        source = EditorGUILayout.ObjectField(source, typeof(Object), true);
        EditorGUILayout.EndHorizontal();

        if (GUILayout.Button("Search!"))
        {
            if (source == null)
                ShowNotification(new GUIContent("No object selected for searching"));
            else if (Help.HasHelpForObject(source))
                Help.ShowHelpForObject(source);
            else
                Help.BrowseURL("http://forum.unity3d.com/search.php");
        }
    }
}