using UnityEngine;
using System.Collections;

namespace MeshPainter
{
	public class Brush
	{
		Texture2D _originalTexture;
		Texture2D _scaledTexture;
		float _scale;

		public float Scale {
			get{ return _scale; }
			set {
				float scale = Mathf.Clamp (value, 0.1f, 10f);
				ScaleBrush (scale);
				_scale = scale;
			}
		}

		public Texture2D OriginalTexture { get { return _originalTexture; } }

		public Texture2D PaintTexture { get { return _scaledTexture; } }

		public Brush (Texture2D brush)
		{
			LoadBrush (brush);
		}

		public void LoadBrush (Texture2D brush)
		{
			_originalTexture = brush;
			_scaledTexture = _originalTexture;
			_scale = 1f;
		}

		public void Destroy ()
		{
			if (_scaledTexture != null && _scaledTexture != _originalTexture)
				Object.DestroyImmediate (_scaledTexture);
		}

		void ScaleBrush (float scale)
		{
			if (!Mathf.Approximately (scale, Scale))
				_scaledTexture = ScaleTexture (_originalTexture, scale);
		}
	
		Texture2D ScaleTexture (Texture2D src, float scale)
		{
			Texture2D scaled = ScaleTexture (src, 
		                                 Mathf.CeilToInt (src.width * scale), 
		                                 Mathf.CeilToInt (src.height * scale)
			);

			return scaled;
		}
	
		Texture2D ScaleTexture (Texture2D src, int width, int height)
		{
			Texture2D result;

			if (Settings.UseGPUScale)
				ScaleTextureGPU (src, width, height, out result);
			else
				ScaleTextureCPU (src, width, height, out result);

			result.wrapMode = TextureWrapMode.Clamp;
			result.filterMode = FilterMode.Bilinear;
			result.hideFlags = HideFlags.HideAndDontSave;
			result.Apply ();

			return result;
		}
	
		void ScaleTextureGPU (Texture2D src, int width, int height, out Texture2D result)
		{
			src.filterMode = FilterMode.Bilinear;
			src.Apply (true);	
		
			RenderTexture rtt = new RenderTexture (width, height, 32);
			rtt.hideFlags = HideFlags.HideAndDontSave;
			rtt.useMipMap = false;

			Graphics.SetRenderTarget (rtt);

			GL.Clear (true, true, new Color (0, 0, 0, 0));
			GL.LoadPixelMatrix (0, 1, 1, 0);
			Graphics.DrawTexture (new Rect (0, 0, 1, 1), src);

			//Get rendered texture back
			result = new Texture2D (width, height, TextureFormat.ARGB32, false);
			result.ReadPixels (new Rect (0, 0, width, height), 0, 0, false);
		}

		void ScaleTextureCPU (Texture2D src, int width, int height, out Texture2D result)
		{
			result = new Texture2D (width, height, TextureFormat.ARGB32, false);

			float ratioX = 1.0f / ((float)width / (src.width - 1));
			float ratioY = 1.0f / ((float)height / (src.height - 1));

			int originalWidth = src.width;

			Color[] texColors = src.GetPixels ();
			Color[] newColors = new Color[width * height];
		
			for (var y = 0; y < height; y++) {
				int yFloor = (int)Mathf.Floor (y * ratioY);
				var y1 = yFloor * originalWidth;
				var y2 = (yFloor + 1) * originalWidth;
				var yw = y * width;
			
				for (var x = 0; x < width; x++) {
					int xFloor = (int)Mathf.Floor (x * ratioX);
					var xLerp = x * ratioX - xFloor;
					newColors [yw + x] = ColorLerpUnclamped (ColorLerpUnclamped (texColors [y1 + xFloor], texColors [y1 + xFloor + 1], xLerp),
				                                       ColorLerpUnclamped (texColors [y2 + xFloor], texColors [y2 + xFloor + 1], xLerp),
				                                       y * ratioY - yFloor);
				}
			}

			result.SetPixels (newColors);
			result.Apply ();
		}

		Color ColorLerpUnclamped (Color c1, Color c2, float value)
		{
			return new Color (c1.r + (c2.r - c1.r) * value, 
		                  c1.g + (c2.g - c1.g) * value, 
		                  c1.b + (c2.b - c1.b) * value, 
		                  c1.a + (c2.a - c1.a) * value);
		}

	}

}
