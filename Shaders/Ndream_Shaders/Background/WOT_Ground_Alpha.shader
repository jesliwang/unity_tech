// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Background/WOT_Ground_Alpha" 
{
	Properties
	{

	   [Header(Land______________________________________________)]
	   _Texture0("Land Textrue A", 2D) = "white" {}
	   _Texture1("Land Textrue B", 2D) = "white" {}
	   _Texture2("Land Textrue C", 2D) = "white" {}
	   
	   [NoScaleOffset]
	   _Mask0("Land Mask A", 2D) = "white" {}

	   [Space(10)]
	   //_GG_SeamlessAlpha("Seamless Alpha", Range(0,1)) = 1			//Global변수
	   [NoScaleOffset]
	   _AlphaMask("Alpha Mask", 2D) = "white" {}

	   [Space(10)]
	   [Toggle]
		_IsZWrite("ZWrite" , Int) = 0
	}


	SubShader
	{
		//LOD 400

		Pass
		{

			//Name "FORWARD"
			//Tags {"LightMode" = "ForwardBase"}
			Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite[_IsZWrite]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			//#pragma multi_compile_fwdbase

			//Variant
			#pragma skip_variants SHADOWS_SCREEN
			#pragma skip_variants VERTEXLIGHT_ON
			#pragma skip_variants DIRECTIONAL
			#pragma skip_variants LIGHTPROBE_SH

			//#pragma multi_compile_fog
			#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x
			#pragma target 3.0
			#pragma multi_compile_instancing


			//land Textures
			sampler2D _Texture0;
			sampler2D _Texture1;
			sampler2D _Texture2;
			sampler2D _Mask0;
			sampler2D _AlphaMask;
			fixed4 _Texture0_ST;
			fixed4 _Texture1_ST;
			fixed4 _Texture2_ST;
			fixed4 _Mask0_ST;

			//Global변수
			uniform fixed _GG_SeamlessAlpha;


			struct VertexInput 
			{
				float4 vertex : POSITION;
				//fixed3 Ambient : COLOR0;

				//Land UV
				float4 texcoord0 : TEXCOORD0; //Land A, B
				float4 texcoord1 : TEXCOORD1; //Land C, Mask&Alpha

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};



			struct VertexOutput 
			{
				float4 pos : SV_POSITION;
				//fixed3 Ambient : COLOR0;

				//Land UV
				float4 uv0 : TEXCOORD0; //Land A, B
				float4 uv1 : TEXCOORD1; //Land C, Mask&Alpha

				LIGHTING_COORDS(4,5)
				//UNITY_FOG_COORDS(8)
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};



				VertexOutput vert(VertexInput v) 
				{
					UNITY_SETUP_INSTANCE_ID(v);
					VertexOutput o = (VertexOutput)0;


					UNITY_TRANSFER_INSTANCE_ID(v, o);

					//Land A
					o.uv0.xy = TRANSFORM_TEX(v.texcoord0.xy, _Texture0);

					//Land B
					o.uv0.zw = v.texcoord0.xy * (_Texture1_ST.xy + 1) * (_Texture1_ST.zw + 1);

					//Land C
					o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _Texture2);

					//Mask
					o.uv1.zw = v.texcoord1.xy * (_Mask0_ST.xy + 0.618) * (_Mask0_ST.zw + 0.618);

					 

					//o.Ambient = UNITY_LIGHTMODEL_AMBIENT;

					o.pos = UnityObjectToClipPos(v.vertex);
					return o;
				}


				fixed4 frag(VertexOutput i) : COLOR 
				{
					UNITY_SETUP_INSTANCE_ID(i);
					//fixed3 AttenColor =i.Ambient;


					//Land Textures Blend
					fixed3 LandTex_A = tex2D(_Texture0, i.uv0.xy);
					fixed3 LandTex_B = tex2D(_Texture1, i.uv0.zw);
					fixed3 LandTex_C = tex2D(_Texture2, i.uv1.xy);

					//Mask Textures
					fixed3 LandTex_Mask_A = tex2D(_Mask0, i.uv1.zw);

					//Alpha Mask
					fixed AlphaMask = tex2D(_AlphaMask, i.uv1.zw);
					


					fixed3 LandSet = (LandTex_A * LandTex_Mask_A.r) + (LandTex_B * LandTex_Mask_A.g) + ((LandTex_C)* LandTex_Mask_A.b);



					// Final Color:
					fixed4 finalColor = fixed4(LandSet, AlphaMask * (1 - _GG_SeamlessAlpha));

					//fixed4 final = fixed4(finalColor * AttenColor , AlphaMask);

					//UNITY_APPLY_FOG(i.fogCoord, final);
					return finalColor;

				}
			ENDCG
		}

	}
}