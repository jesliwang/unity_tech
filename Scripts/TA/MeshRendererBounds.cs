//using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshRendererBounds : MonoBehaviour
{
    public List<MeshFilter> _meshFilter;
    public Bounds bounds;

    void Start()
    {
        foreach (MeshFilter meshFilter in _meshFilter)
        {
            //meshFilter.mesh.bounds = bounds;
            meshFilter.sharedMesh.bounds = bounds;
        }
     }

#if UNITY_EDITOR
    private void OnDrawGizmosSelected()
    {
        foreach (MeshFilter meshFilter in _meshFilter)
        {
            //meshFilter.mesh.bounds = bounds;
            //meshFilter.sharedMesh.bounds = bounds;
            if (null == meshFilter)
            {
                NDebug.LogError("Mesh Renderer Bound에 그림자 메쉬를 등록해주세요.");
            }
        }
    }
#endif
}
