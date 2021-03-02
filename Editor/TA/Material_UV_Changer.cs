using UnityEngine;

public class Material_UV_Changer : MonoBehaviour

{
    [Header("Target")]
    //public bool forceUpdate = false;
    //public Object _Object;
    public Renderer _Renderer;
    //private Renderer _Renderer;
    public Material _Material;
    public GameObject _Prefab;
    private Transform[] _Children;
    [Header("UV Control")]
    [Range(-5, 5)] public float _moveX = 0;
    [Range(-1, 1)] public float _moveY = 0;
    [Range(0, 3)] public float _scaleXY = 1;
    
    [Header("Mesh Control")]
    [Range(0.1f, 3)] public float _scaleMeshX = 1;
    [Range(0.1f, 2)] public float _scaleMeshY = 1;

    //private float _Start_MoveX = 0;
    //private float _Start_MoveY = 0;

    private bool _Start = true;
    private float _Start_OffsetX = 0;
    private float _Start_OffsetY = 0;
    private float _Start_ScaleX = 1;
    private float _Start_ScaleY = 1;
    private float _Start_MeshScale_X = 1;
    private float _Start_MeshScale_Y = 1;

    private GameObject _TargetMesh;
    private Vector3 _MeshScale;
    private string newName;
    private string oldName;


    void OnEnable()
    {
        getStartValue();
    }


    void Update()
    {
        if (_Renderer == null)
        {
            ResetValue();
            return;
        }

        else
        {
            newName = _Renderer.ToString();

            if (newName != oldName)
            {
                getStartValue();
                ResetValue();
                _Start = false;
            }

            _Renderer.material.mainTextureScale = new Vector2(_Start_ScaleX * _scaleXY, _Start_ScaleY * _scaleXY);

            float _MovePivotX2 = (_scaleMeshX * _Start_ScaleX - _Start_ScaleX) * -0.5f;
            float _MovePivotY2 = (_scaleMeshY * _Start_ScaleY - _Start_ScaleY) * -0.5f;
            _Renderer.material.mainTextureScale *= new Vector2(_scaleMeshX, _scaleMeshY);

            _MeshScale = new Vector3(_Start_MeshScale_X * _scaleMeshX, _Start_MeshScale_Y * _scaleMeshY, 1.0f);
            _Renderer.transform.localScale = _MeshScale;

            //uv 센터보정
            _Renderer.material.mainTextureOffset = new Vector2((_scaleMeshX * _scaleXY - 1) * -0.5f * _Start_ScaleX + _Start_OffsetX + _moveX, (_scaleMeshY * _scaleXY - 1) * -0.5f * _Start_ScaleY + _Start_OffsetY + _moveY);

            oldName = _Renderer.ToString();
        }
    }


    public void SaveMaterial()
    {
        print("material : " + _Material);
        _Material.mainTextureOffset = _Renderer.material.mainTextureOffset;
        _Material.mainTextureScale = _Renderer.material.mainTextureScale;
        _Renderer.material = _Material;
    }

    public void SaveMesh()
    {
        GameObject _TargetMesh = _Prefab.transform.GetChild(0).gameObject;
        _TargetMesh.transform.localScale = _MeshScale;
        _TargetMesh.layer = 13;

        //print(_TargetMesh.name + " : " + _TargetMesh.transform.localScale);
        //print(_MeshScale);
        //print(_TargetMesh.layer);
    }

    public void ScaleMesh()
    {
        _Renderer.transform.localScale = new Vector3(_Start_MeshScale_X * _scaleMeshX, _Start_MeshScale_Y * _scaleMeshY, 1.0f);
    }

    public void ResetValue()
    {
        _moveX = 0;
        _moveY = 0;
        _scaleXY = 1;
        _scaleMeshX = 1;
        _scaleMeshY = 1;
    }

    public void getStartValue()
    {
        //print("Start Value 주인 : " + _Renderer);
        _Start_OffsetX = _Renderer.material.mainTextureOffset.x;
        _Start_OffsetY = _Renderer.material.mainTextureOffset.y;
        _Start_ScaleX = _Renderer.material.mainTextureScale.x;
        _Start_ScaleY = _Renderer.material.mainTextureScale.y;
        _Start_MeshScale_X = _Renderer.transform.lossyScale.x;
        _Start_MeshScale_Y = _Renderer.transform.lossyScale.y;

        //print("_Start_OffsetXY - " + _Start_OffsetX + " / " + _Start_OffsetY);
        //print("_Start_ScaleXY - " + _Start_ScaleX  + " / " + _Start_ScaleY);
        //print("_Start_MeshScale_XY - " + _Start_MeshScale_X + " / " + _Start_MeshScale_Y);

    }

    public void getNowValue()
    {
        //print("_Start_OffsetXY - " + _Start_OffsetX + " / " + _Start_OffsetY);
        //print("_Start_ScaleXY - " + _Start_ScaleX + " / " + _Start_ScaleY);
        //print("_Start_MeshScale_XY - " + _Start_MeshScale_X + " / " + _Start_MeshScale_Y);
    }
       
    public void GetAllChildren()
    {
        GameObject _TargetMesh = _Prefab.transform.GetChild(0).gameObject;
        Debug.Log(_TargetMesh.name);
    }

}