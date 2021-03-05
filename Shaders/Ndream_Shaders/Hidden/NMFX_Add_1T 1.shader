// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/COF/FX/NMFX_Add_1T 1"
{
    Properties
    {
        _Color		("Color", Color)			= (1.0,1.0,1.0,1.0)
        _MainTex	("MainTex (RGB)", 2D)		= "white" {}
        _ColorPower	("ColorPower", Range(1, 5))	= 1.0
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
				#pragma target 2.0
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				
				
				fixed4		_Color;
				sampler2D	_MainTex;
				fixed4		_MainTex_ST; 
				fixed		_ColorPower;

				float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
				float4 _ClipArgs0 = float4(1000.0, 1000.0, 0.0, 1.0);
				
				
				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;
				};
				
				
				struct v2f
				{
					fixed4 vertex	: POSITION;
					fixed2 uv		: TEXCOORD0;
					fixed4 color	: COLOR;
					float2 worldPos : TEXCOORD1;
				};

				
				v2f vert(appdata_t v)
				{
					v2f o;
					
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
					o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
					o.color = v.color * _Color * _ColorPower;
					
					return o;
				}
				
				
				fixed4 frag(v2f i) : COLOR
				{
					fixed4 finalColor = fixed4 (0,0,0,0);
					
					fixed4 mainTex = tex2D (_MainTex,i.uv);
					
					finalColor.rgb = mainTex.rgb * i.color.rgb * i.color.a;

					// Softness factor
					fixed2 factor = (float2(1.0, 1.0) - abs(i.worldPos)) * _ClipArgs0.xy;
					fixed fade = clamp( min(factor.x, factor.y), 0.0, 1.0);
					finalColor.a *= fade;
					finalColor.rgb = lerp(half3(0.0, 0.0, 0.0), finalColor.rgb, fade);
     				
     				return finalColor;
				}
				ENDCG
			}  
		}
	}
}
