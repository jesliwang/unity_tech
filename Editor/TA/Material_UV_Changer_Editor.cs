using UnityEditor;  //Editor 클래스 사용하기 위해 넣어줍니다.
using UnityEngine;

[CustomEditor(typeof(Material_UV_Changer))]
public class Material_UV_Changer_Editor : Editor //Monobehaviour 대신 Editor를 넣습니다.
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        //Material_UV_Changer.cs 의 객체를 받아옵니다 => 이래야 버튼시 명령을 내릴수 잇습니다
        Material_UV_Changer Material_UV_Changer = (Material_UV_Changer)target;

        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();  // BeginHorizontal() 이후 부터는 GUI 들이 가로로 생성됩니다.
        GUILayout.FlexibleSpace();          // 고정된 여백을 넣습니다. ( 버튼이 가운데 오기 위함)

        //버튼을 만듭니다 . GUILayout.Button("버튼이름" , 가로크기, 세로크기)
        if (GUILayout.Button("Reset", GUILayout.Width(120), GUILayout.Height(25)))
        {
            Material_UV_Changer.ResetValue();
        }
        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        if (GUILayout.Button("Save", GUILayout.Width(120), GUILayout.Height(25)))
        {
            Material_UV_Changer.SaveMaterial();
            //Material_UV_Changer.ScaleMesh();
            Material_UV_Changer.SaveMesh();
        }

        //if (GUILayout.Button("Start Vlaue", GUILayout.Width(120), GUILayout.Height(25)))
        //{
        //    //Material_UV_Changer.getNowValue();
        //    Material_UV_Changer.GetAllChildren();
        //}
        GUILayout.FlexibleSpace();          // 고정된 여백을 넣습니다.
        EditorGUILayout.EndHorizontal();    // 가로 생성 끝
    }
}