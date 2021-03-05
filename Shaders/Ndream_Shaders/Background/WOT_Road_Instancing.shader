// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Background/WOT_Road_Instancing"
{
	Properties
	{
		[Header(Color)]
		_Color			("Color", Color)		= (1.0,1.0,1.0,1.0)
		[NoScaleOffset]
        _MainTexArr		("MainTex (RGB)", 2DArray)	= "white" {}
		[NoScaleOffset]
		_TransTexArr	("TransTex (R)", 2DArray)	= "white" {}
		_UVScale		("UV Scale", Range(0, 1)) = 1
		_RoadIndex		("Road Index", Float) = 0

		_Alpha ("Alpha", Range(0,1)) = 1

        [Space(30)]
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
				#pragma multi_compile_instancing nolightprobe nolightmap
//                #pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF
                #include "UnityCG.cginc"


				fixed3	_Color;
				float	_UVScale;
				UNITY_DECLARE_TEX2DARRAY(_MainTexArr);
				UNITY_DECLARE_TEX2DARRAY(_TransTexArr);

				fixed _Alpha;

				UNITY_INSTANCING_BUFFER_START(Props)
					UNITY_DEFINE_INSTANCED_PROP(fixed, _RoadIndex)
				UNITY_INSTANCING_BUFFER_END(Props)
                
				
				struct appdata_t
				{
					float4 vertex		: POSITION;
					float4 uv 			: TEXCOORD0;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				
				
				struct v2f
				{
					float4 vertex		: SV_POSITION;
					float3 uv			: TEXCOORD0;

					UNITY_VERTEX_INPUT_INSTANCE_ID
					
					UNITY_FOG_COORDS(1)
				};
				
				
				v2f vert(appdata_t v)
				{
					UNITY_SETUP_INSTANCE_ID(v);

					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					
					o.vertex = UnityObjectToClipPos(v.vertex);

					//o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
					//o.uv = float3(v.uv.xy, UNITY_DEFINE_INSTANCED_PROP(float, _FlagIndex));
					//o.uv.xy = v.uv.xy;
					o.uv.xy = v.uv.xy * _UVScale + (1 - _UVScale) * 0.5;
					o.uv.z = UNITY_ACCESS_INSTANCED_PROP(Props, _RoadIndex); //깃발 인스턴싱과 같이 쓰려다보니..

					//UNITY_TRANSFER_FOG(o, o.vertex);
					
					return o;
				}  
				
				
				fixed4 frag(v2f i) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);

					fixed4 finalColor = fixed4(1,1,1,1);
					fixed4 finalColor1 = fixed4(1,1,1,1);
					
					finalColor = UNITY_SAMPLE_TEX2DARRAY(_MainTexArr, fixed3(i.uv.xyz));
					finalColor1 = UNITY_SAMPLE_TEX2DARRAY(_TransTexArr, fixed3(i.uv.xyz));
					
					finalColor.a = finalColor1.r * _Alpha;
					//UNITY_APPLY_FOG(i.fogCoord, finalColor);

     				return finalColor;
				}
				ENDCG
			}
		}
	}
}