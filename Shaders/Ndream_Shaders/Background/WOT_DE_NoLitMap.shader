Shader "WOT/Background/WOT_DE_NoLitMap"
{

	Properties {
		_Color ("Color", Color)					= (1.0,1.0,1.0,1.0)
        _MainTex ("MainTex (RGB)", 2D)				= "white" {}

		_EmissionColor("Color", Color) = (1.0,1.0,1.0,1.0)
		_EmissionTex("MainTex (RGB)", 2D) = "white" {}
        /*_Bright	("Bright", Range(0,3))				= 1

        [Header(Cull)]
        [KeywordEnum (2Sides, Back, Front)]
        _Cull ( "Culling" , Int)					= 2*/
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		//Cull [_Cull]
		//Fog {mode off}

		CGPROGRAM
		//#pragma surface surf Lambert fullforwardshadows //noforwardadd 
		//#pragma surface surf Lambert nodynlightmap nometa nolppv exclude_path:prepass
		#pragma surface surf Lambert nodynlightmap nometa nolppv exclude_path:prepass
		#pragma skip_variants VERTEXLIGHT_ON
		#pragma skip_variants SPOT
		#pragma skip_variants POINT_COOKIE
		#pragma skip_variants DIRECTIONAL_COOKIE
		#pragma skip_variants UNITY_HDR_ON
		#pragma skip_variants INSTANCING_ON

		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _EmissionTex;
		fixed3 _Color;
		fixed3 _EmissionColor;
		//fixed _Bright;

		struct Input {
			float2 uv_MainTex;
		};


		void surf (Input IN, inout SurfaceOutput o) {

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			//o.Albedo = c.rgb* _Color * _Bright;
			o.Albedo = c.rgb * _Color;

			fixed3 ES = tex2D(_EmissionTex, IN.uv_MainTex);
			o.Emission = ES * _EmissionColor;
			//o.Alpha = c.a;
		}

		ENDCG

		Pass
			{
				Tags{ "LightMode" = "ShadowCaster" }

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_shadowcaster
				#pragma skip_variants SHADOWS_CUBE
				#pragma skip_variants SHADOWS_DEPTH
				#pragma skip_variants INSTANCING_ON
				#pragma skip_variants LIGHTPROBE_SH
				#pragma skip_variants SHADOWS_SCREEN
				#pragma skip_variants POINT
				#pragma skip_variants DIRLIGHTMAP_COMBINED
				#include "UnityCG.cginc"


				struct v2f {
				V2F_SHADOW_CASTER;
				};

				v2f vert(appdata_base v) {
					v2f o;
					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

						return o;
				}

				float4 frag(v2f i) : SV_Target{
					SHADOW_CASTER_FRAGMENT(i)
				}
			ENDCG
		}
	}
	//Fallback "Mobile/VertexLit"
}