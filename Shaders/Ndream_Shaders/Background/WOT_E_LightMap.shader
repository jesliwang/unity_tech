Shader "WOT/Background/WOT_E_LightMap"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_ESColor("Emission Color", Color) = (1,1,1,1)
		_ESPow("Emission Power", Range(0,10)) = 1
		_EmissionTex("Emission Map (RGB)", 2D) = "white" {}

	}

	SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows

			#pragma target 3.0

			#pragma skip_variants LIGHTPROBE_SH
			#pragma skip_variants SHADOWS_SCREEN
			#pragma skip_variants VERTEXLIGHT_ON
			#pragma skip_variants POINT_COOKIE
			#pragma skip_variants DIRECTIONAL_COOKIE
			#pragma skip_variants SHADOWS_CUBE
			#pragma skip_variants UNITY_HDR_ON
			//#pragma skip_variants POINT SHADOWS_SHADOWMASK
			//#pragma skip_variants DIRLIGHTMAP_COMBINED LIGHTMAP_ON
			//#pragma skip_variants DIRECTIONAL
			//#pragma skip_variants SHADOWS_DEPTH


			sampler2D _MainTex;
			sampler2D _EmissionTex;

			struct Input 
			{
				float2 uv_MainTex;
			};

			half _Glossiness;
			//half _Metallic;
			fixed3 _Color;
			fixed3 _ESColor;
			fixed _ESPow;

			void surf(Input IN, inout SurfaceOutputStandard o) 
			{
				fixed3 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				fixed3 ES = tex2D(_EmissionTex, IN.uv_MainTex) * _ESColor;
				o.Emission = ES * _ESPow;
			}
		ENDCG
	}
	//FallBack "Diffuse"
}