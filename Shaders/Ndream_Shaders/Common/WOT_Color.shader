// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Common/WOT_Color"
{
	Properties
	{
		[Header(Color)]
		_Color			("Color", Color)					= (1.0,1.0,1.0,1.0)

		[Header(Cull)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull			( "Culling" , Int)					= 2
    }
    
    
	Category 
	{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        //Lighting Off
        Cull [_Cull]
		//Fog {mode off}
		
		 
		SubShader
		{
			Pass 
			{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
				
				
				fixed4	_Color;
                
				
				struct appdata_t
				{
					float4 vertex		: POSITION;
				};
				
				
				struct v2f
				{
					float4 vertex	: POSITION;
				};
				
				
				v2f vert(appdata_t v)
				{
					v2f o;
					
					o.vertex = UnityObjectToClipPos(v.vertex);
					
					return o;
				}
				
				
				fixed4 frag(v2f i) : COLOR
				{
					return _Color;
				}
				ENDCG
			}
		}
	}
}