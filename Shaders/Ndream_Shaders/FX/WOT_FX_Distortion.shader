Shader "WOT/FX/WOT_FX_Distortion" {
	Properties{
		//_BumpTex("Normalmap (RG) & Alpha (A)", 2D) = "black" {}
		_BumpTex("Distortion Bump(RG)", 2D) = "black" {}
		_BumpAmt("Distortion Power", Float) = 10
	}

	Category{

		SubShader{
			Tags{ "Queue" = "Overlay+999"  "IgnoreProjector" = "True"  "RenderType" = "Overlay" }
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			Lighting Off
			ZWrite Off
			ZTest Always
			Fog{ Mode Off }

			GrabPass{"_GrabTexture"} 
			Pass{
				Name "BASE"
				Tags{ "LightMode" = "Always" }

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_particles
				#include "UnityCG.cginc"

				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord: TEXCOORD0;
					float2 texcoord1: TEXCOORD1;
					half4 color : COLOR;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float4 uvgrab : TEXCOORD0;
					float2 uvbump : TEXCOORD1;
					half4 color : COLOR;
				};

				sampler2D _BumpTex;
				float _BumpAmt;
				sampler2D _GrabTexture;
				float4 _GrabTexture_TexelSize;
				float4 _BumpTex_ST;

				v2f vert(appdata_t v)	{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					#if UNITY_UV_STARTS_AT_TOP
						half scale = -1.0;	//Upside down
						o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
					#else
						o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y) + o.vertex.w) * 0.5;
					#endif

					o.uvgrab.zw = o.vertex.w;
					o.uvbump = TRANSFORM_TEX(v.texcoord.xy, _BumpTex);
					return o;
				}

				half4 frag(v2f i) : SV_Target	{
					half3 bump = tex2D(_BumpTex, i.uvbump);
					half2 offset = bump.rg;
					//offset *= _BumpAmt * _GrabTexture_TexelSize.xy * i.color.a;
					offset *= _BumpAmt * _GrabTexture_TexelSize.xy;
					i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
					half4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));

					return col;
				}
				ENDCG
			}
		}
	}
}
