// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/FX/WOT_FX_Add_SpriteAni"
{
    Properties
    {
        _Color("Color", Color)									= (1.0,1.0,1.0,1.0)
		_MainTex("MainTex (RGB)", 2D)			= "white" {}
        //[NoScaleOffset]_MainTransTex("MainTex Trans (R)", 2D)	= "white" {}

		_TilesU("Tiles U Count", Int) = 2
		_TilesV("Tiles V Count", Int) = 2
		_Frame("Frame Length", Float) = 1

        [Space(20)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull			( "Culling" , Int)			= 2
        [Toggle]
        _IsZWrite		( "ZWrite" , Int)			= 0
    }
	

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Blend One One
        AlphaTest Greater .01
        Lighting Off
        Cull [_Cull]
        ZWrite [_IsZWrite]
        

        SubShader
        {
            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                
                fixed4 _Color;
                sampler2D _MainTex;
                //sampler2D _MainTransTex;
                float4 _MainTex_ST;
                //float4 _MainTransTex_ST;
                //fixed _IsGray;

				uint _TilesU;
				uint _TilesV;

				float _Frame;
                
                
				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;
				};
                
                
                struct v2f
                {
					float4 vertex	: POSITION;
                    float2 uv		: TEXCOORD0;
                    fixed4 color	: COLOR;
                };
                

				fixed4 shot(sampler2D tex, float2 uv, float dx, float dy, int frame) 
				{
					//return tex2D(tex, float2((uv.x * dx) + fmod(frame, _TilesU) * dx, ((uv.y * dy) + (frame / _TilesU) * dy)));
					return tex2D(tex, float2((uv.x * dx) + fmod(frame, _TilesU) * dx, ((uv.y * dy) - (frame / _TilesU) * dy)));
				}


                v2f vert(appdata_t v)
                {
                    v2f o;
                    
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
                    o.color = v.color * _Color;
                    
                    return o;
                }
                
                
                fixed4 frag(v2f i) : COLOR
                {
					fixed4 finalColor = fixed4(0, 0, 0, 1);
					
					//sprite ani======================================
					int frames = _TilesV * _TilesU;
					float frame = fmod(_Time.y / _Frame, frames);
					int current = floor(frame);
					float dx = 1.0 / _TilesU;
					//float dx = 1 - (1.0 / _TilesU);
					float dy = 1.0 / _TilesV;

					fixed4 mainTex = shot(_MainTex, i.uv, dx, dy, current) * _Color;
					//finalColor.a = shot(_MainTransTex, i.uv, dx, dy, current).r;
					//================================================

					finalColor.rgb = mainTex.rgb * i.color.rgb;

					return finalColor;
                }
                ENDCG
            }  
        }
	}
}


