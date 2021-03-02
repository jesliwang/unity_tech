using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class UVAnimator : MonoBehaviour {
    
    [SerializeField] float _speed;
    [SerializeField] Vector2 _uvStart;
    [SerializeField] Vector2 _direction;
    [SerializeField] string _shaderParamName = "";
    
	Material _material;
    
	void Start () {
		Renderer renderer = GetComponent<Renderer>();
		_material = renderer.material;
	}
	
	void Update () {
		if(_material != null && _material.HasProperty(_shaderParamName))
        {
			_material.SetTextureOffset(_shaderParamName, _material.GetTextureOffset(_shaderParamName)+_direction*_speed*Time.deltaTime);
        }
	}
}
