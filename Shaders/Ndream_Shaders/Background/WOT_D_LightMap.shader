Shader "WOT/Background/WOT_D_LightMap"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}

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

			struct Input 
			{
				float2 uv_MainTex;
			};

			fixed3 _Color;


			void surf(Input IN, inout SurfaceOutputStandard o) 
			{
				fixed3 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
			}
		ENDCG
	}
	//FallBack "Diffuse"
}