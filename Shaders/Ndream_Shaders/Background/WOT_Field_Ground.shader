
Shader "WOT/Background/WOT_Field_Ground" {

	Properties{
		[Header(World Map______________________________________________)]
		//_WorldMapColor1("MapColor 1", Color) = (1, 1, 1, 1)
		_WorldMapColor2("Map Ocean Color", Color) = (1, 1, 1, 1)
		_Paper("Map Paper(RGB)", 2D) = "white" {}
		[NoScaleOffset]	_WorldMap("World Map(RGB)", 2D) = "white" {}
		_isWorldMap("isWorldMap", range(0, 1)) = 0


		[Header(Land______________________________________________)]
		_Texture0("Land Textrue A", 2D) = "white" {}
		_Texture1("Land Textrue B", 2D) = "white" {}
		_Texture2("Land Textrue C", 2D) = "white" {}
		[NoScaleOffset]_Mask0("Land Mask A", 2D) = "white" {}
		
		[Space(40)]
		_Texture3("Land Textrue D", 2D) = "white" {}
		_Texture4("Land Textrue E", 2D) = "white" {}
		_Texture5("Land Textrue F", 2D) = "white" {}
		[NoScaleOffset]_Mask1("Land Mask B", 2D) = "white" {}

		//Curvature
		//[Space(40)]
		//[Header(Curvature______________________________________________)]
		//_Curvature_LandColor_A("Curvature Land A Color", Color) = (1,1,1,1)
		//_Curvature_LandColor_B("Curvature Land B Color", Color) = (1,1,1,1)
		//_Curvature_LandColor_C("Curvature Land C Color", Color) = (1,1,1,1)
		//_Curvature_LandColor_D("Curvature Land D Color", Color) = (1,1,1,1)
		//_Curvature_LandColor_E("Curvature Land E Color", Color) = (1,1,1,1)
		//_Curvature_LandColor_F("Curvature Land F Color", Color) = (1,1,1,1)

		//_Curvature_Alpha("Curvature Alpha", Range(0,1)) = 0.5
		//_Texture10("Curvature Textrue", 2D) = "white" {}
		//[NoScaleOffset]_Mask3("Curvature Textrue Mask", 2D) = "white" {}

		[Space(40)]
		[Header(Ocean______________________________________________________)]
		[NoScaleOffset]_Texture8("Ocean Normal A", 2D) = "bump" {}
		//[NoScaleOffset]_Texture9("Ocean Normal B", 2D) = "bump" {}

		[Space(10)]
		_OceanColor("Ocean Color", Color) = (1,1,1,1)
		_OceanSpecularColor("Ocean SpecularColor", Color) = (1,1,1,1)
		_OceanSpecularRange("Ocean Specular Range", Range(1, 100)) = 50

		[Space(10)]
		_Texture8_Scale("Ocean Normal A Scale", int) = 10
		_Texture8_Time_U("Ocean Normal A_U(Speed)", Float) = 0
		_Texture8_Time_V("Ocean Normal A_V(Speed)", Float) = 0

		[Space(10)]
		_Texture9_Scale("Ocean Normal B Scale", int) = 10
		_Texture9_Time_U("Ocean Normal B_U(Speed)", Float) = 0
		_Texture9_Time_V("Ocean Normal B_V(Speed)", Float) = 0

		
		[Space(40)]
		[Header(Ocean Floor______________________________________________)]
		_OceanFloor("Ocean Floor", 2D) = "white" {}
		_OceanfloorReflact("Ocean floor Reflact", Range(0,1)) = 0.5
		_OceanfloorAlpha("Ocean floor Alpha", Range(0,1)) = 1

		[Space(40)]
		[Header(Ocean Mask______________________________________________________)]
		[NoScaleOffset]_Mask2("Ocean Mask", 2D) = "white" {}

	}


	SubShader{
		//LOD 400

		//Stencil //구멍을 뚫기 위한 목적으로 스텐실 버퍼 설정 필요
		//{
		//	Ref 1
		//	Comp notequal
		//	Pass keep
		//}

		Pass 
		{

			Name "FORWARD"
			//Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			//#pragma multi_compile_fwdbase 

			//Variant
			#pragma skip_variants SHADOWS_SCREEN
			#pragma skip_variants VERTEXLIGHT_ON

			//#pragma multi_compile_fog
			#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x
			#pragma target 3.0


			//land Textures
			//uniform fixed4 _WorldMapColor1;
			uniform fixed4 _WorldMapColor2;
			uniform sampler2D _Paper;
			uniform fixed4 _Paper_ST;
			uniform sampler2D _WorldMap;
			//uniform fixed4 _WorldMap_ST;

			uniform fixed _isWorldMap;

			uniform sampler2D _Texture0;
			uniform sampler2D _Texture1;
			uniform sampler2D _Texture2;
			uniform sampler2D _Mask0;

			uniform sampler2D _Texture3;
			uniform sampler2D _Texture4;
			uniform sampler2D _Texture5;
			uniform sampler2D _Mask1;

			uniform fixed4 _Texture0_ST;
			uniform fixed4 _Texture1_ST;
			uniform fixed4 _Texture2_ST;
			uniform fixed4 _Mask0_ST;

			uniform fixed4 _Texture3_ST;
			uniform fixed4 _Texture4_ST;
			uniform fixed4 _Texture5_ST;
			uniform fixed4 _Mask1_ST;
			 

			//Curvarture
			//uniform sampler2D _Texture10;
			//uniform fixed4 _Texture10_ST;
			//uniform fixed4 _Curvature_LandColor_A;
			//uniform fixed4 _Curvature_LandColor_B;
			//uniform fixed4 _Curvature_LandColor_C;
			//uniform fixed4 _Curvature_LandColor_D;
			//uniform fixed4 _Curvature_LandColor_E;
			//uniform fixed4 _Curvature_LandColor_F;
			//uniform fixed _Curvature_Alpha;
			//uniform sampler2D _Mask3;
			//uniform fixed _Mask3_ST;


			//Normal Map
			uniform fixed3 _OceanColor;
			uniform fixed _OceanSpecularRange;
			uniform fixed4 _OceanSpecularColor;

			uniform sampler2D _Texture8;
			uniform fixed4 _Texture8_ST;

			uniform float _Texture8_Time_U;
			uniform float _Texture8_Time_V;
			uniform int _Texture8_Scale;

			//uniform sampler2D _Texture9;
			//uniform fixed4 _Texture9_ST;

			uniform float _Texture9_Time_U;
			uniform float _Texture9_Time_V;
			uniform int _Texture9_Scale;

			uniform sampler2D _Mask2;
			uniform fixed4 _Mask2_ST;

			uniform sampler2D _OceanFloor;
			uniform fixed4 _OceanFloor_ST;
			uniform fixed _OceanfloorReflact;
			uniform fixed _OceanfloorAlpha;


			struct VertexInput {
				float4 vertex : POSITION;
				fixed3 normal : NORMAL;
				fixed4 tangent : TANGENT;
				//fixed3 Ambient : COLOR0;

				//Land UV
				float4 texcoord0 : TEXCOORD0; //Land A, B
				float4 texcoord1 : TEXCOORD1; //Land C, Mask A(Mask B)
				float4 texcoord2 : TEXCOORD2; //Land D, E
				float4 texcoord3 : TEXCOORD3; //Land F, _Paper

				float4 texcoord4 : TEXCOORD4; //Normal A,B
				float4 texcoord5 : TEXCOORD5; //OceanMask ,OceanFloor

				float2 texcoord6 : TEXCOORD6;//Curvarture
				float2 texcoord7 : TEXCOORD7;//Curvarture
			};



			struct VertexOutput {
				float4 pos : SV_POSITION;
				//fixed3 Ambient : COLOR0;

				//Land UV
				float4 uv0 : TEXCOORD0; //Land A, B
				float4 uv1 : TEXCOORD1; //Land C, Mask A(Mask B )
				float4 uv2 : TEXCOORD2; //Land D, E
				//float4 uv3 : TEXCOORD3; //Land F, Mask B
				float4 uv3 : TEXCOORD3; //Land F, _Paper

				float4 uv4 : TEXCOORD4; //Normal A,B
				float4 uv5 : TEXCOORD5; //OceanMask ,OceanFloor

				//float2 uv6 : TEXCOORD6; //Curvature

				fixed4 posWorld : TEXCOORD7;
				fixed3 normalDir : TEXCOORD8;
				fixed3 tangentDir : TEXCOORD9;
				fixed3 bitangentDir : TEXCOORD10;
				//LIGHTING_COORDS(11,12)
				//UNITY_FOG_COORDS(8)
			};



			VertexOutput vert(VertexInput v) {
				VertexOutput o = (VertexOutput)0;

				//Land A,B UV
				o.uv0.xy = TRANSFORM_TEX(v.texcoord0.xy, _Texture0);
				o.uv0.zw = v.texcoord0.xy * (_Texture1_ST.xy + 1) * (_Texture1_ST.zw + 1);


				//Land C,Mask A UV
				o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _Texture2);
				o.uv1.zw = v.texcoord1.xy * (_Mask0_ST.xy + 0.618) * (_Mask0_ST.zw + 0.618);

				//Land D,E UV
				o.uv2.xy = TRANSFORM_TEX(v.texcoord2.xy, _Texture3);
				o.uv2.zw = v.texcoord2.xy * (_Texture4_ST.xy + 1) * (_Texture4_ST.zw + 1);

				//Land F,Mask B UV
				o.uv3.xy = TRANSFORM_TEX(v.texcoord3.xy, _Texture5);
				//o.uv3.zw = v.texcoord3.xy * (_Mask1_ST.xy + 0.618) * (_Mask1_ST.zw + 0.618);   //o.uv1.zw 와 공용
				o.uv3.zw = TRANSFORM_TEX(v.texcoord3.xy, _Paper);

				//Normal UV A
				o.uv4.xy = TRANSFORM_TEX(v.texcoord4.xy, _Texture8);

				float NATU_A = fmod(_Time * _Texture8_Time_U, 1);
				float NATV_A = fmod(_Time * _Texture8_Time_V, 1);
				o.uv4.xy = (o.uv4.xy + float2(NATU_A, NATV_A)) * _Texture8_Scale;

				//Normal UV B (Offset + 1)
				o.uv4.zw = v.texcoord4.xy * (_Texture8_ST.xy + 1) * (_Texture8_ST.zw + 1);
				float NATU_B = fmod(_Time * _Texture9_Time_U, 1);
				float NATV_B = fmod(_Time * _Texture9_Time_V, 1);
				o.uv4.zw = (o.uv4.zw + float2(NATU_B, NATV_B)) * _Texture9_Scale;


				//ocean Mask UV
				o.uv5.xy = TRANSFORM_TEX(v.texcoord5.xy, _Mask2);
				
				//OceanFloor UV (Offset + 1)
				o.uv5.zw = v.texcoord5.xy * (_OceanFloor_ST.xy + 1) * (_OceanFloor_ST.zw + 1);

				//o.uv6.xy = TRANSFORM_TEX(v.texcoord6.xy, _Texture10);

				//_Paper UV
				//o.uv3.zw = TRANSFORM_TEX(v.texcoord3.zw, _Paper);
				 

				//Light
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.tangentDir = normalize(mul(unity_ObjectToWorld, fixed4(v.tangent.xyz, 0.0)).xyz);
				o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				
				//o.Ambient = ShadeSH9(half4(o.normalDir, 1));
				//o.Ambient = UNITY_LIGHTMODEL_AMBIENT;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}


			fixed4 frag(VertexOutput i) : COLOR {

				//Ocean Normal
				fixed3 OceanNormalMap_A = UnpackNormal(tex2D(_Texture8, i.uv4.xy));
				fixed3 OceanNormalMap_B = UnpackNormal(tex2D(_Texture8, i.uv4.zw));
				fixed3 OceanNormal = lerp(OceanNormalMap_A , OceanNormalMap_B , 0.5);

				//Ocean Mask
				fixed2 OceanMask = tex2D(_Mask2, i.uv5.xy);

				//Lighting
				fixed3x3 tangentTransform = fixed3x3(i.tangentDir, i.bitangentDir, normalize(i.normalDir));
				fixed3 NormalDirection = normalize(mul(OceanNormal, tangentTransform));
				fixed3 LightDirection = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				fixed NdotL = saturate(dot(NormalDirection, LightDirection) * 0.5 +0.5);
				fixed3 halfDirection = normalize(viewDirection + LightDirection);
				//fixed3 AttenColor = /*_LightColor0.xyz **/ i.Ambient;

				//Ocean Specular Lighting
				float NH = saturate(max(0, dot(NormalDirection, halfDirection)));
				float Specular = saturate(pow(NH, _OceanSpecularRange * 5)/* * (1 - OceanMask)*/);


				//Paper
				fixed3 Paper = tex2D(_Paper, i.uv3.zw);
				//fixed3 worldMapColor = (1, 1, 1);
				fixed3 Map = tex2D(_WorldMap, i.uv1.zw);


				//Paper = Paper * OceanMask.r * _WorldMapColor1 + Paper * OceanMask.g * _WorldMapColor2;
				Paper = Paper * OceanMask.r + Paper * OceanMask.g * _WorldMapColor2;
				Map *= Paper;

				//Land Textures A Blend
				fixed3 LandTex_A = tex2D(_Texture0, i.uv0.xy);
				fixed3 LandTex_B = tex2D(_Texture1, i.uv0.zw);
				fixed3 LandTex_C = tex2D(_Texture2, i.uv1.xy);
				fixed3 LandTex_Mask_A = tex2D(_Mask0, i.uv1.zw);
				fixed3 LandTex_Mask_A_Black = (LandTex_Mask_A.r + LandTex_Mask_A.g + LandTex_Mask_A.b);


				//Land Textures B Blend
				fixed3 LandTex_D = tex2D(_Texture3, i.uv2.xy);
				fixed3 LandTex_E = tex2D(_Texture4, i.uv2.zw);
				fixed3 LandTex_F = tex2D(_Texture5, i.uv3.xy);
				//fixed3 LandTex_Mask_B = tex2D(_Mask1, i.uv3.zw);
				fixed3 LandTex_Mask_B = tex2D(_Mask1, i.uv1.zw);	//uv1.zw와 공용
				fixed3 LandTex_Mask_B_Black = (LandTex_Mask_B.r + LandTex_Mask_B.g + LandTex_Mask_B.b);
				
				//All Blending 
				fixed3 LandSet = (LandTex_A * LandTex_Mask_A.r) + (LandTex_B * LandTex_Mask_A.g) + ((LandTex_C) * LandTex_Mask_A.b)
					+ (LandTex_D * LandTex_Mask_B.r) + (LandTex_E * LandTex_Mask_B.g) + (LandTex_F * LandTex_Mask_B.b);
				

				//Curvature Texture
				//fixed3 Curvature = tex2D(_Texture10, i.uv6.xy);
				//fixed CurvatureMask = tex2D(_Mask3, i.uv1.zw);
				
				//Color
				//fixed3 AllCurvatureColor = (_Curvature_LandColor_A * LandTex_Mask_A.r) + (_Curvature_LandColor_B * LandTex_Mask_A.g) + (_Curvature_LandColor_C * LandTex_Mask_A.b)
				//							+(_Curvature_LandColor_D * LandTex_Mask_B.r) + (_Curvature_LandColor_E * LandTex_Mask_B.g) + (_Curvature_LandColor_F * LandTex_Mask_B.b);

				//AllBlend * Curvature
				//fixed3 AllLandTex = lerp(LandSet, AllCurvatureColor, ((1 - Curvature) * CurvatureMask) * _Curvature_Alpha);
				


				//OceanFloor
				fixed3 OceanFloor = tex2D(_OceanFloor, lerp(i.uv5.zw, OceanNormal.rg, _OceanfloorReflact));

				//OceanColor
				fixed3 Ocean = (OceanFloor * _OceanfloorAlpha) + _OceanColor.rgb;// +(NdotL *_OceanColor.rgb);
				//Ocean +=(Specular * _OceanSpecularColor);
				//Ocean += OceanFloor;

				// Final Color:
				//fixed3 finalColor = lerp(Ocean, AllLandTex, OceanMask.r);
				fixed3 finalColor = lerp(Ocean, LandSet, OceanMask.r);

				//fixed4 final = fixed4(finalColor * AttenColor ,1);
				fixed4 final = fixed4(finalColor,1);

				//final.rgb = lerp(final.rgb, Paper, _isWorldMap);
				final.rgb = lerp(final.rgb, Map, _isWorldMap);
				//final = lerp(final, fixed4(1,1,1,1), _isWorldMap);

				//UNITY_APPLY_FOG(i.fogCoord, final);
				return final;

			}
			ENDCG
		}

	}
}