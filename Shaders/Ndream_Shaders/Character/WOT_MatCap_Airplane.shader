Shader "WOT/Character/WOT_MatCap_Airplane"
{
	Properties
	{	
		[Header(MAIN__________________________________________________________)]
		_Color("Color", Color)	= (1.0, 1.0, 1.0, 1.0)
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		_Bright("Bright", Range(0, 2)) = 1
		_Contrast("Contrast", Range(0, 2)) = 1

		[Space(10)]
		[Header(MATCAP________________________________________________________)]
		_RoadIndex("Matcap Index", int) = 0
		[NoScaleOffset]
		_MatCapTexArr("MatCap_TextureArray (RGB)", 2DArray) = "white" {}
		//_MatCap("MatCap (RGB)", 2D) = "gray" {}

		[Space(10)]
		_MatCapBright("MatCap Bright", Range(0.5, 2)) = 1
		_MatCapContrast("MatCap Range", Range(0.5, 2)) = 1
	}

		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100
			Cull off

			Pass
			{
				//Tags{ "LightMode" = "ForwardBase" }
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_instancing
				#pragma target 3.0
				#include "UnityCG.cginc"

				//#include "Lighting.cginc"
				//#include "AutoLight.cginc"
				//#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
				//#pragma multi_compile_instancing
				//#pragma target 3.0
				//#pragma multi_compile_fog

			//#pragma skip_variants SHADOWS_CUBE LIGHTPROBE_SH SHADOWS_SCREEN SHADOWS_DEPTH
			//#pragma skip_variants LIGHTPROBE_SH
			//#pragma skip_variants SHADOWS_DEPTH SHADOWS_CUBE

			//#pragma shader_feature LIGHT_SPECULAR
			//#pragma shader_feature LIGHT_CUTOFF
			//#pragma shader_feature LIGHT_MATCAP
			//#pragma shader_feature USESPECULAR
			//#pragma shader_feature CASTSHADOW
			//#pragma shader_feature LIGHT
			//#pragma shader_feature MATCAP
			//#pragma shader_feature USEFOG


			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Bright;
			float _Contrast;
			//sampler2D _MatCap;
			UNITY_DECLARE_TEX2DARRAY(_MatCapTexArr);
			fixed _MatCapBright;
			fixed _MatCapContrast;

			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(int, _RoadIndex)
			UNITY_INSTANCING_BUFFER_END(Props)

			struct appdata
			{
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 vertex : POSITION;
				fixed4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				half2 matCapUV : TEXCOORD2;
				fixed4 color : COLOR0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_SETUP_INSTANCE_ID(v);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.z = UNITY_ACCESS_INSTANCED_PROP(Props, _RoadIndex);

				float3 worldNormal = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				worldNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
				o.matCapUV = worldNormal.xy * 0.5 + 0.5;
				o.color = v.color * _Color;

				return o;
			}


			fixed4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= _Bright * i.color;
				col.rgb = pow(col.rgb, _Contrast);
				
				//fixed3 mcTex = tex2D(_MatCap, i.matCapUV);
				fixed3 mcTex = UNITY_SAMPLE_TEX2DARRAY(_MatCapTexArr, float3(i.matCapUV, i.uv.z));
				mcTex = pow(mcTex, _MatCapContrast);
				col.rgb *= mcTex * 2.0f * _MatCapBright;

				return col;
			}
			ENDCG
		}
	}
}