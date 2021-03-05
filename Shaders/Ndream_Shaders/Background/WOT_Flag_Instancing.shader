Shader "WOT/Background/WOT_Flag_Instancing"
{
	Properties 
	{
        //_Color ("Color (RGB)", Color) = (0.5,0.5,0.5,1)
		//_MainTex("Base (RGB)", 2D) = "Balck" {}
		[NoScaleOffset]
        _MainTexArr ("Base_TextureArray (RGB)", 2DArray) = "white" {}
		//[NoScaleOffset]
        //_SymbolTransTexArr ("SymbolTrans_TextureArray (RGB)", 2DArray) = "Black" {}

		[NoScaleOffset]
		_MatCap("MatCap (RGB)", 2D) = "white" {}
		_MatCapBright("MatCap Bright", Range(1,2)) = 1
		_MatCapContrast("MatCap Contrast", Range(1,2)) = 1


		_Curves("Cureves",Range(0,10)) = 1.65
		_gravity("Gravity Fall",Range(0,1)) = 0.27
		_windSpeed("Wind Speed",Range(0,25)) = 9.2
		_damping("Damping",Range(0, 0.1)) = 0.08

		_FlagIndex("Flag Index(Instancing)", Float) = 0
		//_SymbolIndex("Symbol Index", Float) = 0

		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Culling" , Int) = 2
		[Enum(Off, 0, On, 1)]_IsZWrite("ZWrite" , Int) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest" , Int) = 4
	}

	SubShader
	{
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" "ForceNoShadowCasting" = "True" "DisableBatching" = "True"  }
		//LOD 200
		//Blend SrcAlpha OneMinusSrcAlpha
		ZTest[_ZTest]
		Cull[_Cull]
		ZWrite[_IsZWrite]

		Pass
		{
			//Tags {  "LightMode" = "ForwardBase"  }
            CGPROGRAM
			#pragma target 3.0

			//#pragma multi_compile_fwdbase
			#pragma multi_compile_instancing nolightprobe nolightmap

			#pragma vertex vert
			#pragma fragment frag

			#pragma skip_variants POINT POINT_COOKIE DIRECTIONAL_COOKIE SPOT LIGHTPROBE_SH FOG_LINEAR FOG_EXP FOG_EXP2 DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON LIGHTMAP_ON LIGHTMAP_SHADOW_MIXING
			#pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL
			#include "UnityCG.cginc"

//#ifndef INSTANCE_BATCHER_UTILS_INCLUDED
//#define INSTANCE_BATCHER_UTILS_INCLUDED
//
//
//#define INSTANCE_DATA_SIZE 4
//
//
//#if defined(UNITY_STANDARD_CORE_INCLUDED) || defined(UNITY_STANDARD_SHADOW_INCLUDED)
//
//#if defined(UNITY_STANDARD_SHADOW_INCLUDED)
//#define INSTANCE_SHADOW_ALPHA 	o.instanceColorAlpha = tex2Dlod(_InstancingData, instanceUV).a;
//#define INSTANCE_SHADOW_SHADER 	float3 wPos = mul(instanceMatrix, v.vertex).xyz;
//#else
//#define INSTANCE_SHADOW_SHADER	o.instanceColor = tex2Dlod(_InstancingData, instanceUV);\
//										float3x3 instanceRotationMatrix = (float3x3)instanceMatrix;\
//										float4 posWorld = mul(instanceMatrix, v.vertex);
//#endif
//
//
//#define INSTANCE_DATA_DECODE_STANDARD 	float texelSizeX = _InstancingData_TexelSize.x;\
//											float id = v.uv3.x * INSTANCE_DATA_SIZE * texelSizeX;\
//											float4 instanceUV = float4(fmod(id, 1.0), id * _InstancingData_TexelSize.y, 0, 0);\
//											float4 row0 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
//											float4 row1 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
//											float4 row2 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
//											float4x4 instanceMatrix = {row0, row1, row2, float4(0,0,0,1)};\
//											INSTANCE_SHADOW_SHADER
//
//#else
//
//			//============================================================================
//			//
//			//	To add instance batching support to your custom shader,
//			//	include InstanceBatcher_Utils.cginc and add
//			//	INSTANCE_DATA_DECODE_CUSTOM to the vertex shader
//			//
//			//	--------------------------------------------------------------------------
//			//
//			//	Before using the INSTANCE_DATA_DECODE_CUSTOM, the shader must provide:
//			//
//			//		float4 vertex = vertex.position;	//object space vertex position
//			//		float2 uv3 = vertex.uv3;			//instance id
//			//
//			//		NOTE: vertex.uv3 must be defined as:
//			//
//			//			float2 uv3	: TEXCOORD3;
//			//
//			//	--------------------------------------------------------------------------
//			//
//			//	INSTANCE_DATA_DECODE_CUSTOM will provide you with:
//			//
//			//		float4 posWorld .................... the vertex position in world space
//			//		float4 instanceColor ............... the instance color
//			//		float3x3 instanceRotationMatrix .... the instance rotation matrix
//			//
//			//	--------------------------------------------------------------------------
//			//
//			//	Project the posWorld to fragment position with:
//			//
//			//		float4 fragPos = mul(UNITY_MATRIX_VP, posWorld);
//			//
//			//	--------------------------------------------------------------------------
//			//
//			//	Use the instanceRotationMatrix to transform
//			//	vertex normal to world space normal:
//			//
//			//		float3 normalWorld = normalize(mul(instanceRotationMatrix, v.normal));
//			//
//			//============================================================================
//
//		sampler2D	_InstancingData;
//	float4		_InstancingData_TexelSize;
//
//#define INSTANCE_DATA_DECODE_CUSTOM		float texelSizeX = _InstancingData_TexelSize.x;\
//											float id = uv3.x * INSTANCE_DATA_SIZE * texelSizeX;\
//											float4 instanceUV = float4(fmod(id, 1.0), id * _InstancingData_TexelSize.y, 0, 0);\
//											float4 row0 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
//											float4 row1 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
//											float4 row2 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
//											float4x4 instanceMatrix = {row0, row1, row2, float4(0,0,0,1)};\
//											float4 instanceColor = tex2Dlod(_InstancingData, instanceUV);\
//											float3x3 instanceRotationMatrix = (float3x3)instanceMatrix;\
//											float4 posWorld = mul(instanceMatrix, vertex);
//
//#endif
//
//#endif // INSTANCE_BATCHER_UTILS_INCLUDED

			//sampler2D	_MainTex;
			//float4		_MainTex_ST;

			//fixed4		_Color;

			sampler2D	_MatCap;
			float4		_MatCap_ST;
			fixed _MatCapBright;
			fixed _MatCapContrast;

			UNITY_DECLARE_TEX2DARRAY(_MainTexArr);
			//UNITY_DECLARE_TEX2DARRAY(_SymbolTransTexArr);
			half _Curves, _gravity, _damping, _windSpeed;

			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(int, _FlagIndex)
				//UNITY_DEFINE_INSTANCED_PROP(int, _SymbolIndex)
			UNITY_INSTANCING_BUFFER_END(Props)

			struct appdata_t
			{
				float4 vertex		: POSITION;
				fixed4 color		: COLOR0;
				float2 texcoord 	: TEXCOORD0;
				float3 normal		: NORMAL;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 pos			: SV_POSITION;
				//fixed4 diff			: COLOR0;
				float4 uv			: TEXCOORD0;
				half2 cap			: TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			v2f vert(appdata_t v)
			{
				UNITY_SETUP_INSTANCE_ID(v);

				float xPos = v.texcoord.x * 0.5;
				float yoffset = xPos - _Time.x * _windSpeed; // Animates Root of Flag as Well,wind speed
				yoffset = (yoffset * 2) - 1;
				yoffset = yoffset * 1.57079633 * _Curves;	//one cycle of trinometric function, curves controll
				yoffset = cos(yoffset * 2) * xPos * _damping + _gravity * xPos * xPos;
				v.vertex.xy += float2(yoffset, -yoffset) * v.color.rr;

				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);

				o.pos = UnityObjectToClipPos(v.vertex);

				//o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MatCap);

				o.uv.z = UNITY_ACCESS_INSTANCED_PROP(Props, _FlagIndex);
				//o.uv.w = UNITY_ACCESS_INSTANCED_PROP(Props, _SymbolIndex);

				//float3 worldN = UnityObjectToWorldNormal(v.normal);

				//float3 worldNormal = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				//float3 worldNormal = normalize(unity_WorldToObject[0].xyz * (v.normal.x+yoffset) + unity_WorldToObject[1].xyz * (v.normal.y - yoffset) + unity_WorldToObject[2].xyz * (v.normal.z + yoffset));
				float3 worldNormal = normalize(unity_WorldToObject[0].xyz * (v.normal.x) + unity_WorldToObject[1].xyz * (v.normal.y - yoffset) + unity_WorldToObject[2].xyz * (v.normal.z));
				worldNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
				o.cap.xy = worldNormal.xy * 0.5 + 0.5;
				
				//o.diff.a = 1;

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				UNITY_SETUP_INSTANCE_ID(i);
				//fixed4 flagColor = float4(0, 0, 0, 0);
				//fixed4 symbolColor = float4(0, 0, 0, 0);
				fixed4 finalColor = float4(0, 0, 0, 0);

				fixed4 mcTex = tex2D(_MatCap, i.cap);
				mcTex = pow(mcTex, _MatCapContrast);

				//flagColor = UNITY_SAMPLE_TEX2DARRAY(_MainTexArr, fixed3(i.uv.xyz));
				finalColor = UNITY_SAMPLE_TEX2DARRAY(_MainTexArr, fixed3(i.uv.xyz));

				////연맹깃발
				//symbolColor = UNITY_SAMPLE_TEX2DARRAY(_SymbolTransTexArr, fixed3(i.uv.xyw));
				//finalColor = lerp(flagColor, symbolColor, symbolColor.r);

				finalColor *= (mcTex * 2.0f * _MatCapBright);

				return finalColor;
			}
			ENDCG
		}
	}
	//CustomEditor "ShaderGUI_CF_Background_Field"
}