Shader "WOT/Character/WOT_Tank_UI"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		//_NormalTex ("Normal Map", 2D) = "white" {}
		//_NormalPower ("Normal Power", Range(0, 5)) = 1
		_SpecularTex ("Specular Map", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,5)) = 0.5
        //_Metallic ("Metallic", Range(0,1)) = 0.5
		[NoScaleOffset]_TransTex("TransTex (R)", 2D) = "white" {}
		_Cutoff("Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows //nolightmap 

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		//#pragma skip_variants LIGHTPROBE_SH						// ambient
		//#pragma skip_variants SHADOWS_SCREEN
		//#pragma skip_variants POINT SHADOWS_SHADOWMASK
		//#pragma skip_variants DIRECTIONAL							// receive directional light
		//#pragma skip_variants SPOT							// receive directional light
		//#pragma skip_variants SHADOWS_DEPTH						// spot light shadow
		//#pragma skip_variants SPOT								// spot light
		//#pragma skip_variants VERTEXLIGHT_ON
		//#pragma skip_variants POINT_COOKIE DIRECTIONAL_COOKIE
		#pragma skip_variants DIRLIGHTMAP_COMBINED INSTANCING_ON LIGHTMAP_ON 
		#pragma skip_variants LIGHTMAP_SHADOW_MIXING
		#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2 INSTANCING_ON
		//#pragma skip_variants EDITOR_VISUALIZATION 
		//#pragma skip_variants LIGHTPROBE_SH
		//#pragma skip_variants SHADOWS_SCREEN
		#pragma skip_variants VERTEXLIGHT_ON
		#pragma skip_variants POINT_COOKIE
		#pragma skip_variants DIRECTIONAL_COOKIE
		#pragma skip_variants SHADOWS_CUBE
		#pragma skip_variants UNITY_HDR_ON


        sampler2D _MainTex;
        sampler2D _NormalTex;
        sampler2D _SpecularTex;

		//half _NormalPower;
		half _Glossiness;
		//half _Metallic;
		fixed3 _Color;

		sampler2D _TransTex;
		float _Cutoff;

        struct Input
        {
            float2 uv_MainTex;
        };



        // #pragma instancing_options assumeuniformscaling
        //UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        //UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed3 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;

			fixed3 transTex = tex2D(_TransTex, IN.uv_MainTex);
			clip(transTex.r - _Cutoff);

			//fixed3 n = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));
			//o.Normal = fixed3(n.x * _NormalPower, n.y * _NormalPower, n.z);

            //o.Metallic = _Metallic;

			fixed smoothnessTex = tex2D(_SpecularTex, IN.uv_MainTex);
            o.Smoothness = smoothnessTex * _Glossiness;
            //o.Alpha = transTex.r;
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


			struct v2f 
			{
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v) 
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
    }
    //FallBack "Diffuse"
}
