// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Common/WOT_Unlit_Texture"
{
	Properties
	{
		[Header(Color)]
		_Color			("Color", Color)					= (1.0,1.0,1.0,1.0)
        _MainTex		("MainTex (RGB)", 2D)				= "white" {}
        _Bright			("Bright", Range(0,3))				= 1
        
        /*[Toggle]
        _IsGray			("Gray", Float)						= 0*/
        
		[Header(Cull)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull			( "Culling" , Int)					= 2
    }
    
    
	Category 
	{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Lighting Off
        Cull [_Cull]
		//Fog {mode off}
		
		
		SubShader
		{
			Pass 
			{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
				#pragma multi_compile_fog
                #include "UnityCG.cginc"
				
				
				fixed3		_Color;
				sampler2D	_MainTex;
				fixed4		_MainTex_ST;
				fixed		_Bright;
				//fixed		_IsGray;
                
				
				struct appdata_t
				{
					float4 vertex		: POSITION;
					float2 texcoord 	: TEXCOORD0;
					//fixed4 color		: COLOR;
				};
				
				
				struct v2f
				{
					float4 vertex	: POSITION;
					fixed2 uv		: TEXCOORD0;
					//fixed4 color	: COLOR;

					UNITY_FOG_COORDS(1)
				};
				
				
				v2f vert(appdata_t v)
				{
					v2f o;
					
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
					/*o.color = v.color * _Color * _Bright;
					o.color = _Color * _Bright;*/

					UNITY_TRANSFER_FOG(o, o.vertex);
					
					return o;
				}
				
				
				fixed4 frag(v2f i) : COLOR
				{
					fixed3 c = tex2D (_MainTex,i.uv) * _Color.rgb * _Bright;
					
					//c.rgb *= _Color;
     				
					/*fixed3 grayColor = c.r*0.3 + c.g*0.59 + c.b*0.11;
					c.rgb = lerp(c.rgb, grayColor, _IsGray);*/
     				
					//UNITY_APPLY_FOG(i.fogCoord, c);

     				return fixed4(c.rgb,1);
				}
				ENDCG
			}
		}
	}
}