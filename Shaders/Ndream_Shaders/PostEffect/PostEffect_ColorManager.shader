Shader "PostEffacts/PostEffect_ColorManager"
{
	Properties
	{
	[Header(Render Color)]
	[HideInInspector]_MainTex("Texture", 2D) = "white" {}
	_Brightness("Brightness", Range(0,1)) = 0
	_HighlightColor("HighlightColor", Color) = (1,1,1,1)
	_ShadowColor("ShadowColor", Color) = (1,1,1,1)
	_Saturation("Saturation" , Range(0,3)) = 1
	_Contrast("Contrast" , Range(0,2)) = 1
	_TintColor("TintColor", Color) = (1,1,1,1)
	_Amount("Amount", Range(0,1)) = 0


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
			uniform fixed _Brightness;
			uniform fixed4 _HighlightColor;
			uniform fixed4 _ShadowColor;
			uniform fixed _ColorBlendRange;
			uniform fixed _Saturation;
			uniform fixed _Contrast;
			uniform fixed4 _TintColor;
			uniform fixed _Amount;

			//Saturation
			inline float3 Saturat(float3 c)
			{
				float3 intensity = dot(c.rgb, float3(0.299, 0.587, 0.114));
				c.rgb = lerp(intensity, c.rgb, _Saturation);
				return c;
			}


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

				fixed4 MainColor = tex2D(_MainTex, i.uv);
				fixed4 CM = fixed4(1, 1, 1, 1);

				//Gray Mode
				half3 gray = MainColor.r * 0.3 + MainColor.g*0.59 + MainColor.b * 0.11;
				fixed4 hColor = fixed4(1- gray.rgb,1) + _HighlightColor;
				fixed4 sColor = fixed4((gray.rgb), 1) + _ShadowColor;
				 
				//Saturat
				CM.rgb = Saturat(MainColor.rgb);
				CM *= hColor;
				CM *= sColor;
				CM += _Brightness;
				CM = pow(CM, _Contrast);
				CM = CM * _TintColor;

				MainColor = (MainColor * (1 - _Amount)) + (CM * _Amount);


				return MainColor;

			}
			ENDCG
		}
	}
}