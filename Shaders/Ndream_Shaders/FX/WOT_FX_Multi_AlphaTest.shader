// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/FX/WOT_FX_Multi_AlphaTest"
{
    Properties
    {
    	_Color		("Color", Color)			= (1.0,1.0,1.0,1.0)
    	//_MainTex	("MainTex (RGB)", 2D)		= "white" {}
    	//_ColorPower	("ColorPower", Range(1, 5))	= 1.0
        [Space(20)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull		( "Culling" , Int)			= 2
        [Toggle]
        _IsZWrite	( "ZWrite" , Int)			= 0
	}
	
	
	Category 
	{
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="Transparent" }
    	Blend Zero OneMinusSrcColor
    	AlphaTest Greater .01
        Lighting Off
        Cull [_Cull]
        ZWrite [_IsZWrite]
        
        
		SubShader
		{
			Pass 
			{
				CGPROGRAM
				#pragma fragmentoption ARB_precision_hint_fastest 
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"				

                
				fixed4 _Color;
				//sampler2D _MainTex;
				//fixed4 _MainTex_ST; 
				//fixed _ColorPower;
				
				
				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;
				};
				
				
				struct v2f
				{
					fixed4 vertex	: POSITION;
					//fixed2 uv		: TEXCOORD0;
					fixed4 color	: COLOR;
				}; 
				
				
				v2f vert(appdata_t v)
				{
					v2f o;
					
					o.vertex = UnityObjectToClipPos(v.vertex);
					//o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
					//o.color.rgb = v.color.rgb * _Color.rgb * _ColorPower;
					o.color.rgb = v.color.rgb * _Color.rgb;
					o.color.a = v.color.a * _Color.a;
					
					return o;
				}
				
				
				fixed4 frag(v2f i) : COLOR
				{ 
     				fixed4 finalColor = fixed4 (0,0,0,0);
     				
     				//fixed4 mainTex = tex2D (_MainTex,i.uv.xy);
     				
     				finalColor.rgb = /*mainTex.rgb **/ i.color.rgb * i.color.a;

					return finalColor;
				}
				ENDCG
			}  
		}
	}
}

