// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/FX/WOT_FX_Shield"
{
    Properties
    {
		_Color("Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTex (RGB)", 2D) = "white" {}
		_UV_X	("Move X", Float) = 0
		_UV_Y	("Move Y", Float) = 0
		//[Space(10)]
		MainTex1("MainTex1 (RGB)", 2D) = "white" {}
		_UV1_X("Move X", Float) = 0
		_UV1_Y("Move Y", Float) = 0
		//_ColorPower("ColorPower", Range(1, 5)) = 1.0
		
		[Space(20)]
        _Color1		("Color1", Color)			= (1.0,1.0,1.0,1.0)
        _MainTex2	("MainTex2 (RGB)", 2D)		= "white" {}
		_UV2_X("Move X", Float) = 0
		_UV2_Y("Move Y", Float) = 0
        _MainTex3	("MainTex3 (RGB)", 2D)		= "white" {}
		_UV3_X("Move X", Float) = 0
		_UV3_Y("Move Y", Float) = 0
		//_ColorPower1	("ColorPower1", Range(1, 5))	= 1.0
		
		[Space(30)]
		_Color2("Color2", Color) = (1.0,1.0,1.0,1.0)
		_MainTex4("MainTex4 (RGB)", 2D) = "white" {}
		_UV4_X("Move X", Float) = 0
		_UV4_Y("Move Y", Float) = 0
		//_MainTex5("MainTex5 (RGB)", 2D) = "white" {}
		//_ColorPower2("ColorPower2", Range(1, 5)) = 1.0

        [Space(30)]
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
				#pragma fragmentoption ARB_precision_hint_fastest 
				#pragma target 2.0
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				
				
				fixed4 _Color;
				fixed4 _Color1;
				fixed4 _Color2;
				fixed _UV_X;
				fixed _UV_Y;
				fixed _UV1_X;
				fixed _UV1_Y;
				fixed _UV2_X;
				fixed _UV2_Y;
				fixed _UV3_X;
				fixed _UV3_Y;
				fixed _UV4_X;
				fixed _UV4_Y;

				sampler2D _MainTex;
				sampler2D _MainTex1;
				sampler2D _MainTex2;
				sampler2D _MainTex3;
				sampler2D _MainTex4;
				//sampler2D _MainTex5;
				float4 _MainTex_ST; 
				float4 _MainTex1_ST;
				float4 _MainTex2_ST;
				float4 _MainTex3_ST;
				float4 _MainTex4_ST;
				//float4 _MainTex5_ST;
				//fixed _ColorPower;
				//fixed _ColorPower1;
				//fixed _ColorPower2;
				
				
				struct appdata_t
				{
					float4 vertex	: POSITION;
					float4 texcoord : TEXCOORD0;
					half4 color		: COLOR;
				};
				
				
				struct v2f
				{
					fixed4 vertex	: POSITION;
					float2 uv		: TEXCOORD0;
					float2 uv1		: TEXCOORD1;
					float2 uv2		: TEXCOORD2;
					float2 uv3		: TEXCOORD3;
					float2 uv4		: TEXCOORD4;
					fixed4 color	: COLOR;
				};

				
				v2f vert(appdata_t v)
				{
					v2f o;
					//UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					
					float T = _Time;

					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
					o.uv.x += fmod(T*_UV_X, 1);
					o.uv.y += fmod(T*_UV_Y, 1);

					o.uv1.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
					o.uv1.x += fmod(T*_UV1_X, 1);
					o.uv1.y += fmod(T*_UV1_Y, 1);

					o.uv2.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex2);
					o.uv2.x += fmod(T*_UV2_X, 1);
					o.uv2.y += fmod(T*_UV2_Y, 1);

					o.uv3.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex3);
					o.uv3.x += fmod(T*_UV3_X, 1);
					o.uv3.y += fmod(T*_UV3_Y, 1);

					o.uv4.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex4);
					o.uv4.x += fmod(T*_UV4_X, 1);
					o.uv4.y += fmod(T*_UV4_Y, 1);
					
					o.color = v.color * _Color;
					
					return o;
				}
				
				
				fixed4 frag(v2f i) : COLOR
				{
					fixed4 finalColor = fixed4 (0,0,0,0);
					
					fixed4 mainTex = tex2D(_MainTex, i.uv);
					fixed4 mainTex1 = tex2D(_MainTex1, i.uv1);
					fixed4 mainTex2 = tex2D(_MainTex2, i.uv2);
					fixed4 mainTex3 = tex2D(_MainTex3, i.uv3);
					fixed4 mainTex4 = tex2D(_MainTex4, i.uv4);
					
					finalColor.rgb = (mainTex.rgb * mainTex1.rgb * _Color) + (mainTex2.rgb * mainTex3.rgb * _Color1) + (mainTex4.rgb * _Color2);
     				
     				return finalColor;
				}
				ENDCG
			}  
		}
	}
}
