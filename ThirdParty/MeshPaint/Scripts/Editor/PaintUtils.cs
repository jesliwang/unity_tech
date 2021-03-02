using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace MeshPainter
{

	public static class PaintUtils
	{
		public struct Point
		{
			public short x;
			public short y;

			public Point (short aX, short aY)
			{
				x = aX;
				y = aY;
			}

			public Point (int aX, int aY) : this((short)aX, (short)aY)
			{
			}
		}

		public static void FloodFillArea1 (int targetIndex, List<Texture2D> textures, Vector2 textCoord, Color aFillColor, float hardness, float threshold)
		{
			Texture2D aTex = textures [targetIndex];

			int w = aTex.width;
			int h = aTex.height;
		
			int aX = Mathf.FloorToInt (textCoord.x * w);
			int aY = Mathf.FloorToInt (textCoord.y * h);

			Color aBlackColor = new Color (0, 0, 0, 0);
		
			Color[][] colors = new Color[textures.Count][];

			for (int i = 0 ; i < textures.Count ; i++) {
				colors[i] = textures[i].GetPixels();
			}

			Color refCol = colors[targetIndex][aX + aY * w];
			Queue<Point> nodes = new Queue<Point> ();
			nodes.Enqueue (new Point (aX, aY));
			while (nodes.Count > 0) {
				Point current = nodes.Dequeue ();
				for (int i = current.x; i < w; i++) {
					Color C = colors[targetIndex][i + current.y * w];
					if (!IsSimilar(C, refCol, threshold) || C == aFillColor)
						break;

					//colors [targetIndex][i + current.y * w] = BlendColor (C, aFillColor, hardness);
					int index = i + current.y * w;
					foreach(Color[] c in colors)
					{
						if(c == colors[targetIndex])
							c[index] = BlendColor (C, aFillColor, hardness);
						else
							c[index] = BlendColor (c[index], aBlackColor, hardness);
					}

					if (current.y + 1 < h) {
						C = colors[targetIndex][i + current.y * w + w];
						if (IsSimilar(C, refCol, threshold) && C != aFillColor)
							nodes.Enqueue (new Point (i, current.y + 1));
					}
					if (current.y - 1 >= 0) {
						C = colors[targetIndex][i + current.y * w - w];
						if (IsSimilar(C, refCol, threshold) && C != aFillColor)
							nodes.Enqueue (new Point (i, current.y - 1));
					}
				}
				for (int i = current.x - 1; i >= 0; i--) {
					Color C = colors[targetIndex] [i + current.y * w];
					if (!IsSimilar(C, refCol, threshold) || C == aFillColor)
						break;
					//colors [i + current.y * w] = BlendColor (C, aFillColor, hardness);

					int index = i + current.y * w;
					foreach(Color[] c in colors)
					{
						if(c == colors[targetIndex])
							c[index] = BlendColor (C, aFillColor, hardness);
						else
							c[index] = BlendColor (c[index], aBlackColor, hardness);
					}

					if (current.y + 1 < h) {
						C = colors[targetIndex] [i + current.y * w + w];
						if (IsSimilar(C, refCol, threshold) && C != aFillColor)
							nodes.Enqueue (new Point (i, current.y + 1));
					}
					if (current.y - 1 >= 0) {
						C = colors[targetIndex] [i + current.y * w - w];
						if (IsSimilar(C, refCol, threshold) && C != aFillColor)
							nodes.Enqueue (new Point (i, current.y - 1));
					}
				}
			}

			for (int i = 0; i< textures.Count; i++) {
				textures[i].SetPixels(colors[i]);
				textures[i].Apply();
			}
			//aTex.SetPixels (colors);
			//aTex.Apply ();
		}

		static Color BlendColor (Color src, Color target, float hardness)
		{
			return Color.Lerp (src, target, hardness);
		}

		public static bool IsSimilar (Color a, Color b, float threshold)
		{
			Color diff = b - a;
			
			return Mathf.Abs (diff.r) < threshold &&
				Mathf.Abs (diff.g) < threshold &&
					Mathf.Abs (diff.b) < threshold &&
					Mathf.Abs (diff.a) < threshold;
		}
	}

}