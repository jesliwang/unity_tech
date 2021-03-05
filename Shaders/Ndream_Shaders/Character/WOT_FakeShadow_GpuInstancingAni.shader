// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "WOT/Character/WOT_FakeShadow_GpuInstancingAni"
{
	Properties
	{
		_FakeLightDir("Light Direction", vector) = (-4.69, 7.96, 3.18, 0)
		_FakeShadowColor("Shadow Color", color) = (0, 0, 0, 0)
        _FakeShadowHeightDefault ("Shadow Height Default", float) = 0.01
        _FadeOut ("FadeOut", float) = 1

		//Gpu Instancing Ani
		_AnimMap("AnimMap", 2D) = "white" {}
		_AnimStart("_AnimStart", Float) = 0
		_AnimEnd("_AnimEnd", Float) = 0
		_AnimAll("_AnimAll", Float) = 0
		_AnimOff("_AnimOff", Float) = 0

		_OldAnimStart("_OldAnimStart", Float) = 0
		_OldAnimEnd("_OldAnimEnd", Float) = 0
		_OldAnimOff("_OldAnimOff", Float) = 0

		_Speed("_Speed", Float) = 1
		//_Frezz("_Frezz", Float) = 0
		//_Alpha("_Alpha", Range(0, 1)) = 1
		//_Blend("_Blend", Range(0, 1)) = 1
		[Space(10)]
		[Toggle(ENABLE_CITYBATTLE)]
		_Enable_Down("For City Battle", float) = 0
		_FlagHeight("Flag Height", float) = 0
		_Alpha("Flag Alpha", Range(0, 1)) = 1


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
				//#pragma shader_feature TERRITORY
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"
				#pragma multi_compile_instancing
				//#pragma multi_compile_fog
				#pragma shader_feature ENABLE_CITYBATTLE

				
				//Fake Light
				//float4 _FakeLightDirField;
				float4 _FakeLightDir;
				
				//#if TERRITORY
				//	float4 _FakeLightDirTerritory;
				//#endif
				
				float4 _FakeShadowColor;
				float _FakeShadowHeightDefault;
				float _FakeShadowHeightOffset;
				float _FadeOut;

				float _AnimAll;
				sampler2D _AnimMap;
				float4 _AnimMap_TexelSize;//x == 1/width

				fixed _Alpha;

				UNITY_INSTANCING_BUFFER_START(Props)
					UNITY_DEFINE_INSTANCED_PROP(float, _AnimStart)
					UNITY_DEFINE_INSTANCED_PROP(float, _AnimEnd)
					UNITY_DEFINE_INSTANCED_PROP(float, _AnimOff)
					UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimStart)
					UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimEnd)
					UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimOff)
					UNITY_DEFINE_INSTANCED_PROP(float, _Blend)
					UNITY_DEFINE_INSTANCED_PROP(float, _Speed)
#ifdef ENABLE_CITYBATTLE
					UNITY_DEFINE_INSTANCED_PROP(half, _FlagHeight)
#endif
				UNITY_INSTANCING_BUFFER_END(Props)

				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					float2 uv3 : TEXCOORD2;
					half4 color		: COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
                
				
				struct v2f 
				{
					float4 pos	: SV_POSITION;
					float4 color: COLOR;
					float2 uv3 : TEXCOORD2;
					//UNITY_FOG_COORDS(0)
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

	 
				v2f vert( appdata_t v )
				{
					UNITY_SETUP_INSTANCE_ID(v);
					float start = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimStart);
					float end = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimEnd);
					float off = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimOff);
					float start1 = UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimStart);
					float end1 = UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimEnd);
					float off1 = UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimOff);
					float speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
					float _AnimLen = (end - start);
					float _AnimLen1 = (end1 - start1);
					float f = (off + _Time.y * speed) / _AnimLen;
					float f1 = (off1 + _Time.y * speed) / _AnimLen1;

					f = fmod(f, 1.0);
					f1 = fmod(f1, 1.0);

					float animMap_x1 = (v.uv3.x * 3 + 0.5) * _AnimMap_TexelSize.x;
					float animMap_x2 = (v.uv3.x * 3 + 1.5) * _AnimMap_TexelSize.x;
					float animMap_x3 = (v.uv3.x * 3 + 2.5) * _AnimMap_TexelSize.x;
					float animMap_y = (f * _AnimLen + start) / _AnimAll;
					float animMap_y1 = (f1 * _AnimLen1 + start1) / _AnimAll;
					float4 row0 = tex2Dlod(_AnimMap, float4(animMap_x1, animMap_y, 0, 0));
					float4 row1 = tex2Dlod(_AnimMap, float4(animMap_x2, animMap_y, 0, 0));
					float4 row2 = tex2Dlod(_AnimMap, float4(animMap_x3, animMap_y, 0, 0));
					float4 row3 = float4(0, 0, 0, 1);
					float4 row10 = tex2Dlod(_AnimMap, float4(animMap_x1, animMap_y1, 0, 0));
					float4 row11 = tex2Dlod(_AnimMap, float4(animMap_x2, animMap_y1, 0, 0));
					float4 row12 = tex2Dlod(_AnimMap, float4(animMap_x3, animMap_y1, 0, 0));
					float4x4 mat = float4x4(row0, row1, row2, row3);
					float4x4 mat1 = float4x4(row10, row11, row12, row3);
					float4 pos = mul(mat, v.vertex);
					float4 pos1 = mul(mat1, v.vertex);
					//float3 normal = mul(mat, float4(v.normal, 0)).xyz;
					//float3 normal1 = mul(mat1, float4(v.normal, 0)).xyz;
					//float3 normal = mul(mat, v.normal);
					//float3 normal1 = mul(mat1, v.normal);

					//float4 tangent = mul(mat, v.tangent);
					//float4 tangent1 = mul(mat1, v.tangent);

					//float _blend = UNITY_ACCESS_INSTANCED_PROP(Props, _Blend);

					//pos = lerp(pos1, pos, _blend);

#ifdef ENABLE_CITYBATTLE
					half  flagHeight = UNITY_ACCESS_INSTANCED_PROP(Props, _FlagHeight);

					if (v.color.r < 0.5)
					{
						pos.y += flagHeight * v.color.a;
					}
#endif

					v.vertex = pos;

					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);

					//normal = lerp(normal1, normal, _blend);
					//tangent = lerp(tangent1, tangent, _blend);
					o.pos = UnityObjectToClipPos(v.vertex);
					//o.uv = TRANSFORM_TEX(v.uv, _MainTex);



					float4 vertPosWorld = mul( unity_ObjectToWorld, v.vertex);
					float4 lightDir = -normalize(_FakeLightDir);
					
					//#if TERRITORY
					//	lightDir = -normalize(_FakeLightDirTerritory);
					//#endif

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


					//UNITY_TRANSFER_FOG(o, o.pos);

					return o;
				}
				
				 
				float4 frag( v2f i ) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);

					fixed4 c;
					
					c = _FakeShadowColor;
					c.a *= i.color.a;

#ifdef ENABLE_CITYBATTLE
					c.a *= saturate(i.color.r + _Alpha);
#endif



					//UNITY_APPLY_FOG(i.fogCoord, c);

					return c;
				}
				ENDCG
			}
		}
	}
		//CustomEditor "WOT_FakeShadowEditor"
}