// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/FX/WOT_FX_Shield_System"
{
    Properties
    {
        _Color		("Color", Color)			= (1.0,1.0,1.0,1.0)
        _MainTex	("MainTex (RGB)", 2D)		= "white" {}
        //_ColorPower	("ColorPower", Range(1, 5))	= 1.0
		_Speed		("Speed", Range(0, 100))		= 1.0

        [Space(20)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull		( "Culling" , Int)			= 2
        [Toggle]
        _IsZWrite	( "ZWrite" , Int)			= 0
	}
	
	
	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend One One
		AlphaTest Greater .01
        Lighting Off
        Cull [_Cull]
        ZWrite [_IsZWrite]
		Fog {mode off}
		
		
		SubShader
		{
			Pass 
			{
				CGPROGRAM
//				#pragma fragmentoption ARB_precision_hint_fastest 
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				//#pragma multi_compile_instancing
				//#pragma target 3.0
				
				
				fixed4		_Color;
				fixed		_Speed; 
				sampler2D	_MainTex;
				fixed4		_MainTex_ST; 
				fixed		_ColorPower;
				

				//UNITY_INSTANCING_BUFFER_START(Props)
				//	UNITY_DEFINE_INSTANCED_PROP(float, _Speed)
				//	UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color) 
				//UNITY_INSTANCING_BUFFER_END(Props)
				
				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;

					//UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				
				
				struct v2f
				{
					fixed4 vertex	: POSITION;
					fixed2 uv		: TEXCOORD0;
					fixed4 color	: COLOR;

					//UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				
				v2f vert(appdata_t v)
				{
					//UNITY_SETUP_INSTANCE_ID(v);
					//_Speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
					//_Color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);

					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					//UNITY_TRANSFER_INSTANCE_ID(v, o);

					float T = sin(fmod(_Time * _Speed, 360)) * 0.25 + 0.75;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);

					//o.color.rgb = v.color.rgb * _Color.rgb * _ColorPower;
					//o.color.a = v.color.a * _Color.a * T;
					o.color.rgb = _Color.rgb;// *_ColorPower;
					o.color.a = _Color.a * T;
					
					return o;
				}
				
				
				fixed4 frag(v2f i) : COLOR
				{
					//UNITY_SETUP_INSTANCE_ID(i);

					fixed4 finalColor = fixed4 (0,0,0,0);
					fixed4 mainTex = tex2D (_MainTex,i.uv);
					finalColor.rgb = mainTex.rgb * i.color.rgb * i.color.a;
     				
     				return finalColor;
				}
				ENDCG
			}  
		}
	}
}
