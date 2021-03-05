// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PostEffacts/PostEffect_MotionBlur"
{

	Properties
	{
		[HideInInspector]_MainTex("Texture", 2D) = "white" {}
		_WhiteScreen("White Screen", Range(0,1)) = 0
		_Color("Color", Color) = (1,1,1,1)
		_GrayScale("GrayScale" , Range(0,1)) = 1
		_verticalBlur("verticalBlur" , Range(-10,10)) = 0
		_horizontalBlur("horizontalBlur" , Range(-10,10)) = 0
	}

	SubShader{

		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _Parameter;

			uniform fixed _GrayScale;
			uniform fixed _WhiteScreen;
			uniform fixed4 _Color;
			uniform half _verticalBlur;
			uniform half _horizontalBlur;


			struct v2f_tap
			{
				float4 pos : SV_POSITION;
				half2 uv20 : TEXCOORD0;
				half2 uv21 : TEXCOORD1;
				half2 uv22 : TEXCOORD2;
				half2 uv23 : TEXCOORD3;
			};

			v2f_tap vert(appdata_img v)
			{
				v2f_tap o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv20 = UnityStereoScreenSpaceUVAdjust(v.texcoord + _MainTex_TexelSize.xy , _MainTex_ST);
				o.uv21 = UnityStereoScreenSpaceUVAdjust(v.texcoord + _MainTex_TexelSize.xy * half2( (1- _horizontalBlur), (1 - _verticalBlur)), _MainTex_ST);
				o.uv22 = UnityStereoScreenSpaceUVAdjust(v.texcoord + _MainTex_TexelSize.xy * half2( _horizontalBlur, (1- _verticalBlur)), _MainTex_ST);
				o.uv23 = UnityStereoScreenSpaceUVAdjust(v.texcoord + _MainTex_TexelSize.xy * half2( (1- _horizontalBlur), _verticalBlur), _MainTex_ST);

				return o;
			}

			fixed4 frag(v2f_tap i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv20);
				color += tex2D(_MainTex, i.uv21);
				color += tex2D(_MainTex, i.uv22);
				color += tex2D(_MainTex, i.uv23);
				color = color / 4;
				color *= pow(_Color, 0.3f);

				//Gray Mode
				half3 gray = color.r * 0.3 + color.g*0.59 + color.b * 0.11;
				gray *= 0.99f;
				color.rgb = lerp(color.rgb, gray, _GrayScale);
				color += (_WhiteScreen * 0.3f);

				return color;
			}
		ENDCG
		}//pass
	}//SubShader
}//Shader