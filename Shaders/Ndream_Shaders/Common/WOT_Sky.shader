// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Common/WOT_Sky"
{
	Properties
	{
		[Header(Color)]
		_Color			("Color", Color)					= (1.0,1.0,1.0,1.0)
        _MainTex		("MainTex (RGB)", 2D)				= "white" {}
        _Bright			("Bright", Range(0,3))				= 1
        
    }
    
    
	Category 
	{
		Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
		
		
		SubShader
		{
			Pass 
			{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
				
				
				fixed4		_Color;
				sampler2D	_MainTex;
				fixed4		_MainTex_ST;
				fixed		_Bright;
                
				
				struct appdata_t
				{
					float4 vertex		: POSITION;
					float2 texcoord 	: TEXCOORD0;
					fixed4 color		: COLOR;
				};
				
				
				struct v2f
				{
					float4 vertex	: POSITION;
					fixed2 uv		: TEXCOORD0;
					fixed4 color	: COLOR;

				};
				
				
				v2f vert(appdata_t v)
				{
					v2f o;
					
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
					o.color = v.color * _Color * _Bright;
					
					return o;
				}
				
				
				fixed4 frag(v2f i) : COLOR
				{
					fixed4 c = tex2D (_MainTex,i.uv);
					
					c.rgb *= i.color.rgb;
     				

     				return c;
				}
				ENDCG
			}
		}
	}
}