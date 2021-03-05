// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Background/WOT_SeamlessRoad_Instancing"
{
    Properties
    {
        _Color			("Color", Color)			= (1.0,1.0,1.0,1.0)
		//_Color1			("Color1", Color)			= (1.0,1.0,1.0,1.0)
		//_Color2			("Color2", Color)			= (1.0,1.0,1.0,1.0)
        //_MainTex		("MainTex (RGB)", 2D)		= "white" {}
        //[NoScaleOffset]
        _MainTransTex	("MainTex Trans (R)", 2D)	= "white" {}
		
		_RoadIndex("Tile Count", int)	= 10


		[Toggle]
		_IsRed("Red", Float) = 0

		[Toggle]
		_IsBlue("Blue", Float) = 0


        [Space(20)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull			( "Culling" , Int)			= 2
        [Toggle]
        _IsZWrite		( "ZWrite" , Int)			= 0
    }
	

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
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
				#pragma multi_compile_instancing
                #include "UnityCG.cginc"

                
                fixed4 _Color;
				//fixed4 _Color1;
				//fixed4 _Color2;
                //sampler2D _MainTex;
                sampler2D _MainTransTex;
                //float4 _MainTex_ST;
                float4 _MainTransTex_ST;
                //fixed _IsGray;

				fixed _IsBlue;
				fixed _IsRed;

				//fixed _RoadIndex;
				UNITY_INSTANCING_BUFFER_START(Props)
					UNITY_DEFINE_INSTANCED_PROP(fixed, _RoadIndex)
				UNITY_INSTANCING_BUFFER_END(Props)


				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
                
                
                struct v2f
                {
                    fixed4 vertex	: POSITION;
                    float2 uv		: TEXCOORD0;
                    fixed4 color	: COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
                };
                

                v2f vert(appdata_t v)
                {
					UNITY_SETUP_INSTANCE_ID(v);

                    v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
                    
                    o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv.xy = v.texcoord.xy;
					o.uv.y *= UNITY_ACCESS_INSTANCED_PROP(Props, _RoadIndex);
                    //o.color = v.color * _Color;
                    
                    return o;
                }
                
                
                fixed4 frag(v2f i) : COLOR
                {
					UNITY_SETUP_INSTANCE_ID(i);

                	fixed4 finalColor = fixed4(1, 1, 1, 1);

					//fixed tileCount = UNITY_ACCESS_INSTANCED_PROP(Props, _RoadIndex);

                	//fixed3 mainTransTex	= tex2D (_MainTransTex,float2(i.uv.x, i.uv.y * tileCount));

					//i.uv.y *= _RoadIndex;

					fixed3 mainTransTex = tex2D(_MainTransTex, i.uv);

					finalColor.rgb = mainTransTex.rgb * _Color.rgb;

					//finalColor.rgb = lerp(_Color1, _Color2, 1);

					finalColor.a = mainTransTex.r * _Color.a;
                    
                    return finalColor;
                }
                ENDCG
            }  
        }
	}
}


