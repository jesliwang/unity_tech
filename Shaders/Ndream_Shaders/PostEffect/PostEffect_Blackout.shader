// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PostEffacts/PostEffect_Blackout"
{
	Properties
	{
	[Header(Render Color)]
	[HideInInspector]_MainTex("Texture", 2D) = "white" {}
	_Color("Screen Color", Color) = (1,1,1,1)
	_GrayScale("Black & White" , Range(0,1)) = 1



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

			////render uv
			//float2 StereoScreenSpaceUVAdjust(float2 uv, float4 st)
			//{
			//#if defined(UNITY_SINGLE_PASS_STEREO)
			//	return UnityStereoScreenSpaceUVAdjust(uv, st);
			//#else
			//	return uv;
			//#endif
			//}



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

				//fixed4 color = tex2D(_MainTex, half4(StereoScreenSpaceUVAdjust(i.uv, _MainTex_ST), 0.0, 0.0));
				fixed4 color = tex2D(_MainTex, i.uv);
				color *= _Color;


				//Gray Mode
				half3 gray = color.r * 0.3 + color.g*0.59 + color.b * 0.11;
				color.rgb = lerp(color.rgb, gray, _GrayScale);


				return color;

			}
			ENDCG
		}
	}
}