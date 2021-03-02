using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace MeshPainter
{
	[RequireComponent(typeof(MeshRenderer))]
    [RequireComponent(typeof(MeshCollider))]
    public class MeshPaint : MonoBehaviour
	{
        // 알파 안쓴다. 알파쓰려면 4로 변경
        public const int DetailPerSplat = 3;
        [System.Serializable]
        public class TextureProperty
        {
            [SerializeField] Texture2D _texture;
            [SerializeField] string _propertyName = string.Empty;
            [SerializeField] string _propertyDesc = string.Empty;
            [SerializeField] Vector2 _tiling;

            public Texture2D Texture { get { return _texture; } set { _texture = value; } }
            public string Name { get { return _propertyName; } set { _propertyName = value; } }
            public string Desc { get { return _propertyDesc; } set { _propertyDesc = value; } }
            public Vector2 Tiling { get { return _tiling; } set { _tiling = value; } }

            public void Clear()
            {
                _texture = null;
                _propertyName = string.Empty;
                _propertyDesc = string.Empty;
                _tiling = Vector2.one;
            }
        }


        [System.Serializable]
		public class Detail
		{
			[SerializeField] Texture2D _texture;
			[SerializeField] Vector2 _tiling;

			public Texture2D Texture { get { return _texture; } set { _texture = value; } }
			public Vector2 Tiling { get { return _tiling; } set { _tiling = value; } }
		}

        [System.Serializable]
        public class SplatInfo
        {
            public SplatInfo() { }

            [SerializeField] TextureProperty _mask = null;
            [SerializeField] TextureProperty[] _rgba = new TextureProperty[DetailPerSplat];
            [SerializeField] int _masklayer = 0;
            [SerializeField] int _detailcount = 0;


            public TextureProperty Mask { get { return _mask; } set { _mask = value; } }
            public TextureProperty[] RGBA { get { return _rgba; } set { _rgba = value; } }
            
            public int MaskLayer { get { return _masklayer;} set { _masklayer = value; }}
            public int DetailCount { get { return Mathf.Min(_detailcount, DetailPerSplat) ; } set { _detailcount = Mathf.Min(value, DetailPerSplat) ; } }
        }

#if UNITY_EDITOR
        [SerializeField] List<SplatInfo> _splatInfos = new List<SplatInfo>();
        [SerializeField, HideInInspector] UndoManager _undoManager;
		[SerializeField] Texture2D _splatMap;
		[SerializeField] float _scale;
		[SerializeField] float _hardness;
		[SerializeField] float _fillThreshold;
     
        public void Clear()
        {
            for (int i = 0; i < _splatInfos.Count; ++i)
            {
                _splatInfos[i].Mask?.Clear();
                for(int j = 0; j < _splatInfos[i].RGBA.Length; ++j)
                {
                    _splatInfos[i].RGBA[j].Clear();
                }
            }

            _splatInfos.Clear();
        }

   
        public List<SplatInfo> SplatInfos { get { return _splatInfos; } }

        public int SelectedBrushIndex { get; set; }

		public int Tool { get; set; }

		public float SelectedBrushScale { get { return _scale; } set { _scale = value; } }

		public float SelectedBrushHardness { get { return _hardness; } set { _hardness = value; } }

		public float SelectedFillThreshold { get { return _fillThreshold; } set { _fillThreshold = value; } }

		public int SelectedDetailIndex { get; set; }

        public int SelectedPaintDetailIndex { get; set; }
        public int SelectedSplatIndex { get{ return SelectedPaintDetailIndex / DetailPerSplat; } }
        public int GetTargetMaskLayer()
        {
            if ((SplatInfos.Count > SelectedSplatIndex) == false)
                return 0;
            return SplatInfos[SelectedSplatIndex].MaskLayer;
        }

        public Color GetTargetColor(int splatIndex)
        {
            if (SelectedSplatIndex != splatIndex)
                return new Color(0, 0, 0, 0);
            return GetTargetColor();
        }

        public Color GetTargetColor()
        {
            switch (SelectedPaintDetailIndex % DetailPerSplat)
            {
                case 0:
                    return new Color(1, 0, 0, 0);
                case 1:
                    return new Color(0, 1, 0, 0);
                case 2:
                    return new Color(0, 0, 1, 0);
                case 3:
                    return new Color(0, 0, 0, 1);
            }

            return new Color(0, 0, 0, 0);
        }

        public bool CanPaint() { return _splatInfos.Count > 0/*_textureproperties.Count > 0*/; }

        //public MeshCollider PaintMeshCollider { get; set; }

		public Dictionary<Collider,bool> OriginalColliders { get; set; }

		public int OriginalLayer { get; set; }

		public bool SplatPainted { get; set; }

		public bool SettingsEnabled { get; set; }

		public Vector2 BrushesScrollPosition { get; set; }

		public UndoManager UndoManager { get { return _undoManager; } }

		public bool PaintStatusPainting  { get; set; }

		public Vector3 PaintStatusPosition  { get; set; }

		public Vector3 PaintStatusNormal  { get; set; }
	
		void OnDrawGizmos ()
		{
			if (PaintStatusPainting) {
				Gizmos.DrawRay (PaintStatusPosition, PaintStatusNormal);
			}
		}

	#endif
	}

}
	