using UnityEngine;
using System.Collections;
using UnityEditor;

namespace MeshPainter
{
	public class PreviewManager
	{
		bool _active;
		Projector _projector;
		bool _enabled;
		MeshFilter _mesh;
		MeshPaint _meshPaint;

		public bool Enable
        {
			get { return _enabled; }
			set
            {
				_enabled = value;
                if(null != _projector)
                    _projector.enabled = value;
			}
		}

		public void CreateProjector (MeshFilter targetMesh, MeshPaint meshPaint)
		{
			_mesh = targetMesh;
			_meshPaint = meshPaint;

			GameObject instance = EditorUtility.CreateGameObjectWithHideFlags ("MeshPainterProjector", 
		                                                                  HideFlags.HideAndDontSave, 
		                                                                  new System.Type[] { typeof(Projector) });
		
			_projector = instance.GetComponent<Projector> ();
		
			_projector.enabled = false;
			_projector.nearClipPlane = -1000f;
			_projector.farClipPlane = 1000f;
			_projector.orthographic = true;
			_projector.orthographicSize = 1f;
			_projector.aspectRatio = 1f;
			_projector.transform.Rotate (90f, 0, 0);
			_projector.material = new Material (Shader.Find ("Hidden/MeshPaint/ProjectorAdditiveTint"));
			_projector.material.hideFlags = HideFlags.HideAndDontSave;
            _projector.enabled = _enabled;
            _active = true;
		}

		public void PreviewBrush (Brush brush)
		{
			if (_active) {
				float size = Mathf.Max (_mesh.sharedMesh.bounds.size.x, _mesh.sharedMesh.bounds.size.y, _mesh.sharedMesh.bounds.size.z);
				float scale = Mathf.Max (_mesh.transform.lossyScale.x, _mesh.transform.lossyScale.y, _mesh.transform.lossyScale.z);

				_projector.orthographicSize = brush.PaintTexture.width * 0.5f / _meshPaint.SplatInfos[0].Mask.Texture.width * size * scale;

				_projector.material.mainTexture = brush.PaintTexture;
			}
		}

		public void SetColor (Color color)
		{
			if (_projector != null) {
				_projector.material.SetColor ("_Color", color);
			}
		}

		public void TransformNow (Vector3 position, Quaternion rotation)
		{
			_projector.transform.position = position;
			_projector.transform.rotation = rotation;
			_projector.transform.Rotate (0, 180f, 0);
		}

		public void DestoryProjector ()
		{
			if (_projector != null) {
				Object.DestroyImmediate (_projector.material);
				Object.DestroyImmediate (_projector.gameObject);
			}

			_active = false;
		}
    }

}
