// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Background/WOT_Background_Blend"
{
	Properties
	{
		[Header(Color)]
		_Color ("Color (RGB)", Color)		= (1.0,1.0,1.0,1.0)
		_MainTex ("MainTex1 (RGB)", 2D)	= "white" {}
		[NoScaleOffset]_MainTex1 ("MainTex2 (RGB)", 2D)	= "white" {}
		[NoScaleOffset]_TransTex ("TransTex (R)", 2D)	= "white" {}

		_Blend ("Blend", Range(0,1)) = 1
		//_Alpha ("Alpha", Range(0,1)) = 1
		
		//[Space(10)]
		//[Toggle(USE_CLIP)] _UseClip("[Use Clip]", float) = 0
		//_Clip("Clip", Range(0,1)) = 0.1

        [Space(10)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull ( "Culling" , Int)		= 2
        
		[Toggle]
        _IsZWrite ( "ZWrite" , Int)		= 0
    }
    
    
	Category
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
        //Lighting Off
        Cull [_Cull]
		//Fog {mode off}
		ZWrite [_IsZWrite]
		
		
		SubShader
		{
			Pass
			{
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
				//#pragma multi_compile_fog
//                #pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF
				#pragma multi_compile_instancing
				#pragma target 3.0
                #include "UnityCG.cginc"

				#pragma shader_feature USE_CLIP
                
				sampler2D	_MainTex;
				sampler2D	_MainTex1;
				sampler2D	_TransTex;
				
				fixed3	_Color;
				fixed4	_MainTex_ST;

				fixed _Blend;
				//fixed _Alpha;
				//fixed _UseClip;
				//fixed _Clip;
                
				
				struct appdata_t
				{
					float4 vertex		: POSITION;
					float2 texcoord 	: TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				
				
				struct v2f
				{
					float4 vertex		: POSITION;
					fixed2 uv			: TEXCOORD0;
					
					UNITY_VERTEX_INPUT_INSTANCE_ID
					//UNITY_FOG_COORDS(1)
				};
				
				
				v2f vert(appdata_t v)
				{
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					UNITY_SETUP_INSTANCE_ID(v);
					
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);

					//UNITY_TRANSFER_FOG(o, o.vertex);
					
					return o;
				}
				
				
				fixed4 frag(v2f i) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);
					fixed4 finalColor = fixed4(1,1,1,1);
					
					fixed3 mainTex = tex2D (_MainTex,i.uv);
					fixed3 mainTex1 = tex2D (_MainTex1,i.uv);
					fixed3 transTex = tex2D (_TransTex,i.uv);

					mainTex = lerp(mainTex, mainTex1, _Blend);
					finalColor = fixed4(mainTex * _Color, transTex.r /** _Alpha*/);
//#ifdef USE_CLIP
//					clip(finalColor.a - _Clip);
//#endif

					//UNITY_APPLY_FOG(i.fogCoord, finalColor);

     				return finalColor;
				}
				ENDCG
			}
		}
	}
}