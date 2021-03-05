// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Background/WOT_Background"
{
	Properties
	{
		//[Toggle(Use_SeamlessAlpha)] _UseSeamlessAlpha ("[Seamless Alpha]", Int) = 0
		[Toggle]_UseSeamlessAlpha("Seamless Alpha", Float) = 0
		[Toggle]_UseCutoff("Cutoff", Float) = 1
		_AlphaCutoff("Alpha Cutoff", Range(0, 1)) = 0.1
		//[Header(Color)]
		_Color ("Color", Color)		= (1.0,1.0,1.0,1.0)
        _MainTex ("MainTex (RGB)", 2D)	= "white" {}
		[NoScaleOffset]_TransTex ("TransTex (R)", 2D)	= "white" {}
		_Alpha ("Alpha", Range(0,1)) = 1

		[Space(10)]
		//_GG_SeamlessAlpha("Seamless Alpha", Range(0,1)) = 1			//Global변수
		//[Space(10)]
		//[Toggle(USE_CLIP)] _UseClip("[Use Clip]", float) = 0
		//_Clip("Clip", Range(0,1)) = 0.1
		//_Clip4("Clip", Range(0,1)) = 0.1

        [Space(10)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull ( "Culling" , Int)		= 2
        
		[Toggle] _IsZWrite ( "ZWrite" , Int)		= 0
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

				//#pragma shader_feature USE_CLIP
				#pragma shader_feature USE_SEAMLESSALPHA
				#pragma shader_feature USE_CUTOFF
                
				sampler2D	_MainTex;
				sampler2D	_TransTex;
				
				fixed3	_Color;
				fixed4	_MainTex_ST;

				fixed _Alpha;
				float _AlphaCutoff;
				//fixed _Clip;
				//fixed _Clip4;

				//Global변수 ( GameMain.cs )
				uniform fixed _GG_SeamlessAlpha;			
                
				
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
					
					fixed4 mainTex = tex2D (_MainTex,i.uv);
					fixed4 transTex = tex2D (_TransTex,i.uv);
					
					finalColor = fixed4(mainTex.rgb * _Color, transTex.r * _Alpha);

#ifdef USE_SEAMLESSALPHA
					finalColor.a *= (1 - _GG_SeamlessAlpha);
#endif
#ifdef USE_CUTOFF
					clip(finalColor.a - _AlphaCutoff);
					//clip(finalColor.a - _Clip4);
#endif


					//UNITY_APPLY_FOG(i.fogCoord, finalColor);

     				return finalColor;
				}
				ENDCG
			}
		}
	}
	CustomEditor "ShaderGUI_WOT_Background"	
}