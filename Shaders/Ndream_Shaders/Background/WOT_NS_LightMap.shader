Shader "WOT/Background/WOT_NS"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_NormalTex("Normal Map", 2D) = "bump" {}
		_SpecTex("Specular Map (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		//_Metallic("Metallic", Range(0,1)) = 0.5
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
			sampler2D _NormalTex;
			sampler2D _SpecTex;

			struct Input {
				float2 uv_MainTex;
			};

			half _Glossiness;
			//half _Metallic;
			fixed3 _Color;

			void surf(Input IN, inout SurfaceOutputStandard o) 
			{
				fixed3 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));

				fixed SmoothnessTex = tex2D(_SpecTex, IN.uv_MainTex);
				o.Smoothness = SmoothnessTex * _Glossiness;
				//o.Metallic = _Metallic;
			}
		ENDCG
	}
	//FallBack "Diffuse"
}