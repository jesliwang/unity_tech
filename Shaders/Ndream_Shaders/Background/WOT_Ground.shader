// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Background/WOT_Ground" {
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


	SubShader{
		//LOD 400

		Pass
		{

			Name "FORWARD"
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#pragma multi_compile_fwdbase 

			//Variant
			#pragma skip_variants SHADOWS_SCREEN
			#pragma skip_variants VERTEXLIGHT_ON

			//#pragma multi_compile_fog
			#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x
			#pragma target 3.0


			//land Textures
			uniform sampler2D _Texture0;
			uniform sampler2D _Texture1;
			uniform sampler2D _Texture2;
			uniform sampler2D _Mask0;

			uniform fixed4 _Texture0_ST;
			uniform fixed4 _Texture1_ST;
			uniform fixed4 _Texture2_ST;
			uniform fixed4 _Mask0_ST;


			uniform sampler2D _Texture3;
			uniform sampler2D _Texture4;
			uniform sampler2D _Texture5;
			uniform sampler2D _Mask1;
			
			uniform fixed4 _Texture3_ST;
			uniform fixed4 _Texture4_ST;
			uniform fixed4 _Texture5_ST;
			uniform fixed4 _Mask1_ST;


			uniform fixed _MaskBlendPow;

			//Curvarture
			uniform sampler2D _Texture6;
			uniform sampler2D _Mask2;
			uniform fixed4 _Texture6_ST;
			uniform fixed _Mask2_ST;

			uniform fixed4 _CurvatureColor;
			uniform fixed _Curvature_Alpha;
			






			struct VertexInput {
				float4 vertex : POSITION;
				//fixed3 Ambient : COLOR0;

				//Land UV
				float4 texcoord0 : TEXCOORD0; //Land A, B
				float4 texcoord1 : TEXCOORD1; //Land C, Mask&Cuvarture
				float4 texcoord2 : TEXCOORD2; //Land D, E
				float4 texcoord3 : TEXCOORD2; //Land F

			};



			struct VertexOutput {
				float4 pos : SV_POSITION;
				//fixed3 Ambient : COLOR0;

				//Land UV
				float4 uv0 : TEXCOORD0; //Land A, B
				float4 uv1 : TEXCOORD1; //Land C, Mask&Cuvarture
				float4 uv2 : TEXCOORD2; //Land D, E
				float4 uv3 : TEXCOORD3; //Land F




				LIGHTING_COORDS(4,5)
				//UNITY_FOG_COORDS(8)
				};



				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;

					//Land A
					o.uv0.xy = TRANSFORM_TEX(v.texcoord0.xy, _Texture0);

					//Land B
					o.uv0.zw = v.texcoord0.xy * (_Texture1_ST.xy + 1) * (_Texture1_ST.zw + 1);

					//Land C
					o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _Texture2);

					//Mask
					o.uv1.zw = v.texcoord1.xy * (_Mask0_ST.xy + 0.618) * (_Mask0_ST.zw + 0.618);

					//Land D
					o.uv2.xy = TRANSFORM_TEX(v.texcoord2.xy, _Texture3);

					//Land E
					o.uv2.zw = v.texcoord2.xy * (_Texture4_ST.xy + 0.618) * (_Texture4_ST.zw + 0.618);

					//Land F 
					o.uv3.xy = TRANSFORM_TEX(v.texcoord3.xy, _Texture5);

					//CurvatureTex
					o.uv3.zw = v.texcoord3.xy * (_Texture6_ST.xy + 0.618) * (_Texture6_ST.zw + 0.618);
					 

					//o.Ambient = UNITY_LIGHTMODEL_AMBIENT;

					o.pos = UnityObjectToClipPos(v.vertex);
					return o;
				}


				fixed4 frag(VertexOutput i) : COLOR {

					//fixed3 AttenColor =i.Ambient;

				

					//************* i.uv1.zw == All Mask & Curvature ************//
					//Land Textures A Blend
					fixed3 LandTex_A = tex2D(_Texture0, i.uv0.xy);
					fixed3 LandTex_B = tex2D(_Texture1, i.uv0.zw);
					fixed3 LandTex_C = tex2D(_Texture2, i.uv1.xy);
					fixed3 LandTex_D = tex2D(_Texture3, i.uv2.xy);
					fixed3 LandTex_E = tex2D(_Texture4, i.uv2.zw);
					fixed3 LandTex_F = tex2D(_Texture5, i.uv3.xy);


					//Mask Textures
					fixed3 LandTex_Mask_A = tex2D(_Mask0, i.uv1.zw);
					fixed3 LandTex_Mask_B = tex2D(_Mask1, i.uv1.zw);

					//Land ABC + Land DEF 
					fixed3 MaskBlend = (LandTex_Mask_B.r + LandTex_Mask_B.g + LandTex_Mask_B.b);

					//Land Textures B Blend
					//fixed3 LandTex_D = tex2D(_Texture3, i.uv2.xy);
					//fixed3 LandTex_Mask_B = tex2D(_Mask1, i.uv1.zw);


					//All Blending 
					//fixed3 LandSet = lerp( (LandTex_A * LandTex_Mask_A.r) + (LandTex_B * LandTex_Mask_A.g) + (LandTex_C * LandTex_Mask_A.b), LandTex_D , LandTex_Mask_B.r );
					//fixed3 LandSet = lerp( (LandTex_A * LandTex_Mask_A.r) + (LandTex_B * LandTex_Mask_A.g) + (LandTex_C * LandTex_Mask_A.b), LandTex_D , LandTex_Mask_A.a );
					/*fixed3 LandSet = (LandTex_A * LandTex_Mask_A.r) + (LandTex_B * LandTex_Mask_A.g) + ((LandTex_C)* LandTex_Mask_A.b)
						+ (LandTex_D * LandTex_Mask_B.r) + (LandTex_E * LandTex_Mask_B.g) + (LandTex_F * LandTex_Mask_B.b);*/

					fixed3 LandSet = lerp((LandTex_A * LandTex_Mask_A.r) + (LandTex_B * LandTex_Mask_A.g) + ((LandTex_C)* LandTex_Mask_A.b)
						, (LandTex_D * LandTex_Mask_B.r) + (LandTex_E * LandTex_Mask_B.g) + (LandTex_F * LandTex_Mask_B.b), pow(MaskBlend, _MaskBlendPow) );



					//Curvature Texture
					fixed CurvatureMask = tex2D(_Mask2, i.uv1.zw);
					CurvatureMask = (1 - CurvatureMask);

					fixed3 CurvatureTex = tex2D(_Texture6, i.uv3.zw);
					CurvatureTex = (CurvatureTex + (1 - _Curvature_Alpha)) * _CurvatureColor;


					//AllBlend * Curvature
					//fixed3 AllLandTex = lerp(LandSet, _CurvatureColor, ((1 - CurvatureTex) * CurvatureMask) * _Curvature_Alpha);
					fixed3 AllLandTex = LandSet * (saturate(CurvatureTex + CurvatureMask ));



					// Final Color:
					fixed3 finalColor = AllLandTex;

					//fixed4 final = fixed4(finalColor * AttenColor ,1);

					//UNITY_APPLY_FOG(i.fogCoord, finalColor);
					return fixed4(finalColor,1);

				}
			ENDCG
		}

	}
}