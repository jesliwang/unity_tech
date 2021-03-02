using UnityEngine;
using System.Collections;


[ExecuteInEditMode]


public class FakeShadow_Light : MonoBehaviour
{
	public Color shadowColor = Color.black;
    //public bool Territory = false;
    //public bool Field = false;
    //public bool Battle = false;

    void OnEnable()
    {
		Vector4 lightDir = new Vector4 (transform.forward.x, transform.forward.y, transform.forward.z, 0.0f);

        //if (Territory)
        //{
        //    Shader.SetGlobalVector("_FakeLightDirTerritory", lightDir);
        //}
        //else if(Field)
        //{
        //    Shader.SetGlobalVector("_FakeLightDirField", lightDir);
        //}else if (Battle)
        //{
        //    Shader.SetGlobalVector("_FakeLightDirBattle", lightDir);
        //}

        Shader.SetGlobalColor("_FakeShadowColor", shadowColor);
        Shader.SetGlobalVector("_FakeLightDir", lightDir);
    }
}
