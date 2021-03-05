// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "WOT/Background/WOT_FakeShadow"
{
	Properties
	{
        _FakeShadowHeightDefault ("Shadow Height Default", float) = 0.01
        _FadeOut ("FadeOut", float) = 1

		//[MaterialToggle(USEFOG)] _USEFOG("Fog", Float) = 0

		[Space(20)]
		[KeywordEnum(2Sides, Back, Front)]
		_Cull("Culling" , Int) = 2
		[Toggle]
		_IsZWrite("ZWrite" , Int) = 0
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
				Stencil
				{
					Ref 0
					Comp Equal
					Pass IncrWrap
					ZFail Keep
				}
				
				
				CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert
				#pragma fragment frag
				/*#pragma shader_feature TERRITORY
				#pragma shader_feature Field
				#pragma shader_feature Battle*/
				//#pragma multi_compile_fog
				//#pragma shader_feature USEFOG
				#pragma multi_compile_instancing
				
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"
				

				//Fake Light
				//float4 _FakeLightDirTerritory;
				/*float4 _FakeLightDirField;
				float4 _FakeLightDirBattle;*/
				
				/*#if TERRITORY
					float4 _FakeLightDirTerritory;
				#endif

				#if Field
					float4 _FakeLightDirField;
				#endif

				#if Battle
					float4 _FakeLightDirBattle;
				#endif*/
				
				float4 _FakeLightDir;
				float4 _FakeShadowColor;
				float _FakeShadowHeightDefault;
				float _FakeShadowHeightOffset;
				float _FadeOut;


				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
                
				
				struct v2f 
				{
					float4 pos	: SV_POSITION;
					float4 color: COLOR;
//#ifdef USEFOG
					//UNITY_FOG_COORDS(1)
//#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

	 
				v2f vert( appdata_t v )
				{
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					UNITY_SETUP_INSTANCE_ID(v);

					float4 vertPosWorld = mul( unity_ObjectToWorld, v.vertex);
					float4 lightDir = -normalize(_FakeLightDir);
					//float4 lightDir = -normalize(float4(0,0,0,0));
					
					/*#if TERRITORY
						lightDir = -normalize(_FakeLightDirTerritory);
					#endif

					#if Field
						lightDir = -normalize(_FakeLightDirField);
					#endif

					#if Battle
						lightDir = -normalize(_FakeLightDirBattle);
					#endif*/

					float shadowHeight = _FakeShadowHeightDefault + _FakeShadowHeightOffset;
					float opposite = vertPosWorld.y - shadowHeight;
					float cosTheta = -lightDir.y;
					float hypotenuse = opposite / cosTheta;
					float3 vertPos = vertPosWorld.xyz + (lightDir.xyz * hypotenuse);

					float4 pivotPosWorld = mul( unity_ObjectToWorld, float4(0,0,0,1));
					pivotPosWorld.z = vertPos.z;
					float dist = distance (pivotPosWorld.xyz, vertPos);
					o.color = v.color;
					o.color.a = 1 - saturate(dist*_FadeOut);

					o.pos = mul (UNITY_MATRIX_VP, float4(vertPos.x, shadowHeight, vertPos.z ,1));
//#ifdef USEFOG
					//UNITY_TRANSFER_FOG(o, o.pos);
//#endif
					return o;
				}
				
				 
				float4 frag( v2f i ) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);

					//float4 c;
					fixed4 c;
					
					c = _FakeShadowColor;
					c.a *= i.color.a;
//#ifdef USEFOG
					//UNITY_APPLY_FOG(i.fogCoord, c);
//#endif
					return c;
				}
				ENDCG
			}
		}
	}
		//CustomEditor "WOT_FakeShadowEditor"
}