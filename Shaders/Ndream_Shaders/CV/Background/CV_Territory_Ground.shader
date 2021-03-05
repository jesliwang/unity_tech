// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CV/Background/CV_Territory_Ground" {
	Properties{

	   [Header(Land______________________________________________)]
	   _Texture0("Land Textrue A", 2D) = "white" {}
	   _Texture1("Land Textrue B", 2D) = "white" {}
	   _Texture2("Land Textrue C", 2D) = "white" {}
	   
	   [NoScaleOffset]
	   _Mask0("Land Mask A", 2D) = "white" {}


	   _Texture3("Land Textrue D", 2D) = "white" {}
	   _Texture4("Land Textrue E", 2D) = "white" {}
	   _Texture5("Land Textrue F", 2D) = "white" {}
	   [NoScaleOffset]
	   _Mask1("Land Mask B", 2D) = "white" {}
	   _MaskBlendPow("Mas kBlend Pow(Default 2~4)", Range(1,8)) = 4


	   //Curvature
	   [Space(40)]
	   [Header(Curvature______________________________________________)]
	   _CurvatureColor("Curvature Color", Color) = (1,1,1,1)
	   _Texture6("Curvature Textrue", 2D) = "white" {}
	   _Curvature_Alpha("Curvature Alpha", Range(0,1)) = 0.5
       

	   [NoScaleOffset]
	   _Mask2("Curvature Textrue Mask", 2D) = "white" {}

	}


	SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Opaque"
			"Queue" = "Geometry+0"
		}

		//LOD 400
		Pass
		{

			//Name "FORWARD"
			//Tags {"LightMode" = "ForwardBase"}

			//CGPROGRAM
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fwdbase 
			
			// make fog work
			#pragma multi_compile_fog

			// Recieve Shadow
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT

			////Variant
			//#pragma skip_variants SHADOWS_SCREEN
			//#pragma skip_variants VERTEXLIGHT_ON

			////#pragma multi_compile_fog
			//#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x
			//#pragma target 3.0

			#include "Library/PackageCache/com.unity.render-pipelines.universal@7.5.3/ShaderLibrary/Core.hlsl"
			#include "Library/PackageCache/com.unity.render-pipelines.universal@7.5.3/ShaderLibrary/Lighting.hlsl"



			






			struct appdata
			{
				float4 vertex : POSITION;
				//half3 Ambient : COLOR0;

				////Land UV
				//float4 texcoord0 : TEXCOORD0; //Land A, B
				//float4 texcoord1 : TEXCOORD1; //Land C, Mask&Cuvarture
				//float4 texcoord2 : TEXCOORD2; //Land D, E
				//float4 texcoord3 : TEXCOORD2; //Land F
				//Land UV
				float4 uv0 : TEXCOORD0; //Land A, B
				float4 uv1 : TEXCOORD1; //Land C, Mask&Cuvarture
				float4 uv2 : TEXCOORD2; //Land D, E
				float4 uv3 : TEXCOORD3; //Land F

				float3 normal : NORMAL;

			};



			struct v2f
			{
				float4 vertex : SV_POSITION;
				//half3 Ambient : COLOR0;

				//Land UV
				float4 uv0 : TEXCOORD0; //Land A, B
				float4 uv1 : TEXCOORD1; //Land C, Mask&Cuvarture
				float4 uv2 : TEXCOORD2; //Land D, E
				float4 uv3 : TEXCOORD3; //Land F

				float3 normal : NORMAL;

				float fogCoord : TEXCOORD4;
				float4 shadowCoord : TEXCOORD5;
			};

			//uniform sampler2D _Texture0;
			//uniform sampler2D _Texture1;
			//uniform sampler2D _Texture2;
			//uniform sampler2D _Mask0;

			//uniform sampler2D _Texture3;
			//uniform sampler2D _Texture4;
			//uniform sampler2D _Texture5;
			//uniform sampler2D _Mask1;

			

			//uniform sampler2D _Texture6;
			//uniform sampler2D _Mask2;

			//uniform half4 _CurvatureColor;
			//uniform half _Curvature_Alpha;

			TEXTURE2D(_Texture0);			SAMPLER(sampler_Texture0);
			TEXTURE2D(_Texture1);			SAMPLER(sampler_Texture1);
			TEXTURE2D(_Texture2);			SAMPLER(sampler_Texture2);
			TEXTURE2D(_Mask0);				SAMPLER(sampler_Mask0);

			TEXTURE2D(_Texture3);			SAMPLER(sampler_Texture3);
			TEXTURE2D(_Texture4);			SAMPLER(sampler_Texture4);
			TEXTURE2D(_Texture5);			SAMPLER(sampler_Texture5);
			TEXTURE2D(_Mask1);				SAMPLER(sampler_Mask1);

			TEXTURE2D(_Texture6);			SAMPLER(sampler_Texture6);
			TEXTURE2D(_Mask2);				SAMPLER(sampler_Mask2);





			CBUFFER_START(UnityPerMaterial)
				//land Textures
				uniform half _MaskBlendPow;

				uniform half4 _Texture0_ST;
				uniform half4 _Texture1_ST;
				uniform half4 _Texture2_ST;
				uniform half4 _Mask0_ST;




				uniform half4 _Texture3_ST;
				uniform half4 _Texture4_ST;
				uniform half4 _Texture5_ST;
				uniform half4 _Mask1_ST;




				//Curvarture

				uniform half4 _Texture6_ST;
				uniform half _Mask2_ST;

				uniform half4 _CurvatureColor;
				uniform half _Curvature_Alpha;


			CBUFFER_END


			v2f vert(appdata v) 
			{
				v2f o = (v2f)o;

				o.vertex = TransformObjectToHClip(v.vertex.xyz);

				//Land A
				o.uv0.xy = TRANSFORM_TEX(v.uv0.xy, _Texture0);

				//Land B
				o.uv0.zw = v.uv0.xy * (_Texture1_ST.xy + 1) * (_Texture1_ST.zw + 1);

				//Land C
				o.uv1.xy = TRANSFORM_TEX(v.uv1.xy, _Texture2);

				//Mask
				o.uv1.zw = v.uv1.xy * (_Mask0_ST.xy + 0.618) * (_Mask0_ST.zw + 0.618);

				//Land D
				o.uv2.xy = TRANSFORM_TEX(v.uv2.xy, _Texture3);

				//Land E
				o.uv2.zw = v.uv2.xy * (_Texture4_ST.xy + 0.618) * (_Texture4_ST.zw + 0.618);

				//Land F 
				o.uv3.xy = TRANSFORM_TEX(v.uv3.xy, _Texture5);

				//CurvatureTex
				o.uv3.zw = v.uv3.xy * (_Texture6_ST.xy + 0.618) * (_Texture6_ST.zw + 0.618);

				o.normal = TransformObjectToWorldNormal(v.normal);

				//o.Ambient = UNITY_LIGHTMODEL_AMBIENT;
				//o.Ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//#ifdef _MAIN_LIGHT_SHADOWS
				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				o.shadowCoord = GetShadowCoord(vertexInput);
				//#endif

				o.fogCoord = ComputeFogFactor(o.vertex.z);

				return o;
			}

			half4 frag(v2f i) : COLOR
			//half4 frag(v2f i) : SV_Target
			{
				half4 LandTex_A = SAMPLE_TEXTURE2D(_Texture0, sampler_Texture0, i.uv0.xy);
				half4 LandTex_B = SAMPLE_TEXTURE2D(_Texture1, sampler_Texture1, i.uv0.zw);
				half4 LandTex_C = SAMPLE_TEXTURE2D(_Texture2, sampler_Texture2, i.uv1.xy);
				half4 LandTex_D = SAMPLE_TEXTURE2D(_Texture3, sampler_Texture3, i.uv2.xy);
				half4 LandTex_E = SAMPLE_TEXTURE2D(_Texture4, sampler_Texture4, i.uv2.zw);
				half4 LandTex_F = SAMPLE_TEXTURE2D(_Texture5, sampler_Texture5, i.uv3.xy);

				//Mask Textures
				half4 LandTex_Mask_A = SAMPLE_TEXTURE2D(_Mask0, sampler_Mask0, i.uv1.zw);
				half4 LandTex_Mask_B = SAMPLE_TEXTURE2D(_Mask1, sampler_Mask1, i.uv1.zw);

				//Land ABC + Land DEF 
				half MaskBlend = (LandTex_Mask_B.r + LandTex_Mask_B.g + LandTex_Mask_B.b);

				half4 LandSet = lerp((LandTex_A * LandTex_Mask_A.r) + (LandTex_B * LandTex_Mask_A.g) + ((LandTex_C)* LandTex_Mask_A.b)
					, (LandTex_D * LandTex_Mask_B.r) + (LandTex_E * LandTex_Mask_B.g) + (LandTex_F * LandTex_Mask_B.b), pow(abs(MaskBlend), _MaskBlendPow) );

				//Curvature Texture
				half4 CurvatureMask = SAMPLE_TEXTURE2D(_Mask2, sampler_Mask2, i.uv1.zw);
				CurvatureMask = (1 - CurvatureMask);

				half4 CurvatureTex = SAMPLE_TEXTURE2D(_Texture6, sampler_Texture6, i.uv3.zw);
				CurvatureTex = (CurvatureTex + (1 - _Curvature_Alpha)) * _CurvatureColor;
				half4 finalColor = LandSet * (saturate(CurvatureTex + CurvatureMask));

				////	Light & ambient
				//Light mainLight = GetMainLight(i.shadowCoord);
				//float NdotL = saturate(dot(_MainLightPosition.xyz, i.normal));
				//half3 ambient = SampleSH(i.normal);
				//finalColor.rgb *= (NdotL * _MainLightColor.rgb * mainLight.shadowAttenuation + ambient);

				////	Fog
				finalColor.rgb = MixFog(finalColor.rgb, i.fogCoord);

				return finalColor;
			}
			ENDHLSL
		}

		//Pass
		//{
		//	Name "ShadowCaster"

		//	Tags{ "LightMode" = "ShadowCaster" }

		//	Cull Back

		//	HLSLPROGRAM

		//	#pragma prefer_hlslcc gles
		//	#pragma exclude_renderers d3d11_9x
		//	#pragma target 2.0

		//	#pragma vertex ShadowPassVertex
		//	#pragma fragment ShadowPassFragment

		//	// GPU Instancing
		//	#pragma multi_compile_instancing

		//	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		//	#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"


		//	CBUFFER_START(UnityPerMaterial)
		//	CBUFFER_END

		//	struct VertexInput
		//	{
		//		float4 vertex : POSITION;
		//		float4 normal : NORMAL;

		//		UNITY_VERTEX_INPUT_INSTANCE_ID
		//	};

		//	struct VertexOutput
		//	{
		//		float4 vertex : SV_POSITION;

		//		UNITY_VERTEX_INPUT_INSTANCE_ID
		//			UNITY_VERTEX_OUTPUT_STEREO

		//	};

		//	VertexOutput ShadowPassVertex(VertexInput v)
		//	{
		//		VertexOutput o;
		//		UNITY_SETUP_INSTANCE_ID(v);
		//		UNITY_TRANSFER_INSTANCE_ID(v, o);
		//		// UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);                             

		//		float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
		//		float3 normalWS = TransformObjectToWorldNormal(v.normal.xyz);

		//		float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _MainLightPosition.xyz));

		//		o.vertex = positionCS;

		//		return o;
		//	}

		//	half4 ShadowPassFragment(VertexOutput i) : SV_TARGET
		//	{
		//		UNITY_SETUP_INSTANCE_ID(i);
		//	//UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

		//return 0;
		//}

		//ENDHLSL
		//}
	}
}