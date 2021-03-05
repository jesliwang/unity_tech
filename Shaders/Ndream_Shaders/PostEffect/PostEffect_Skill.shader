// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PostEffacts/PostEffect_Skill"
{
	Properties
	{
	[Header(Render Color)]
	[HideInInspector]_MainTex("Texture", 2D) = "white" {}
	_Color("Screen Color", Color) = (1,1,1,1)
	_GrayScale("Black & White" , Range(0,1)) = 1
	_WhiteScreen("White Screen", Range(0,1)) = 0

	[Header(Color Balance)]
	_Contrast("Contrast", Range(1,2)) = 1


	[Space(20)]
	[Header(Radial Blur)]
	_Center("Center Point", Vector) = (0.5, 0.5, 0.0, 0.0)
	[HideInInspector]_Params("Strength (X) Samples (Y) Sharpness (Z) Darkness (W)", Vector) = (0.05, 0, 0, 0)

	}

	SubShader{
		Cull Off ZWrite Off ZTest Always


		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"


			uniform sampler2D _MainTex;
			float4 _MainTex_ST;
			uniform fixed _GrayScale;
			uniform fixed4 _Color;
			uniform fixed _WhiteScreen;

			uniform float _Contrast;

			uniform half2 _Center;
			uniform half4 _Params;


			float2 StereoScreenSpaceUVAdjust(float2 uv, float4 st)
			{
			#if defined(UNITY_SINGLE_PASS_STEREO)
				return UnityStereoScreenSpaceUVAdjust(uv, st);
			#else
				return uv;
			#endif
			}


			//비겐팅을 최적화를 위해 제거, 꼭 필요하면 되살리면됨 / 스무스 스탭 함수 사용
			/*half vignette(half2 uv)
			{
				half v = normalize(1.0 * _Params.w);
				half d = distance(uv, _Center);
				v *= smoothstep(0.8, _Params.z * 0.799, d * (_Params.w + _Params.z));
				return 1.0 - v;
			}*/


			struct appdata{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			};


			struct v2f{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};


			v2f vert(appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}


			fixed4 frag(v2f i) : SV_Target{


				//---------------Radial Blur-------------
				half2 Radial_UV = i.uv - _Center;
				half scale;
				half samples = _Params.y;
				half factor = samples - 1;
				//half amount = _Params.x  * vignette(i.uv);
				half amount = _Params.x;
				half4 color = half4(0.0, 0.0, 0.0, 0.0);

				for (int i = 0; i < samples; i++)
				{
					scale = 1.0 + amount * (i / factor);
					//밉맵 제거
					//color += tex2Dlod(_MainTex, half4(StereoScreenSpaceUVAdjust(Radial_UV * scale + _Center, _MainTex_ST), 0.0, 2.5));
					color += tex2D(_MainTex, half4(StereoScreenSpaceUVAdjust(Radial_UV * scale + _Center, _MainTex_ST), 0.0, 0.0));
				}
				color /= samples;


				//--------------My Color---------------
				color *= _Color;
				//Gray Mode
				half3 gray = color.r * 0.3 + color.g*0.59 + color.b * 0.11;
				color.rgb = lerp(color.rgb, gray, _GrayScale);
				color += _WhiteScreen;

				//Contrast
				fixed4 fianalColor = pow(color, _Contrast);

				return fianalColor;

			}
			ENDCG
		}
	}
}