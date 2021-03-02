Shader "MeshPaint/Splat4DiffStandard" {
	Properties {

		_Control0 ("Control (RGBA)", 2D) = "black" {}
		_Splat3 ("Ch (A)", 2D) = "white" {}
		_Splat2 ("Ch (B)", 2D) = "white" {}
		_Splat1 ("Ch (G)", 2D) = "white" {}
		_Splat0 ("Ch (R)", 2D) = "white" {}

		_Normal3 ("N (A)", 2D) = "bump" {}
		_Normal2 ("N (B)", 2D) = "bump" {}
		_Normal1 ("N (G)", 2D) = "bump" {}
		_Normal0 ("N (R)", 2D) = "bump" {}

		_Metallic0 ("Metallic 0", Range(0.0, 1.0)) = 0.0	
		_Metallic1 ("Metallic 1", Range(0.0, 1.0)) = 0.0	
		_Metallic2 ("Metallic 2", Range(0.0, 1.0)) = 0.0	
		_Metallic3 ("Metallic 3", Range(0.0, 1.0)) = 0.0
		_Smoothness0 ("Smoothness 0", Range(0.0, 1.0)) = 1.0	
		_Smoothness1 ("Smoothness 1", Range(0.0, 1.0)) = 1.0	
		_Smoothness2 ("Smoothness 2", Range(0.0, 1.0)) = 1.0	
		_Smoothness3 ("Smoothness 3", Range(0.0, 1.0)) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:SplatmapVert finalcolor:SplatmapFinalColor fullforwardshadows
		#pragma debug
		#pragma multi_compile_fog
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		float4 _Control0_ST;
		sampler2D _Control0;
		sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
		sampler2D _Normal0, _Normal1, _Normal2, _Normal3;

		half _Metallic0;
		half _Metallic1;
		half _Metallic2;
		half _Metallic3;
		
		half _Smoothness0;
		half _Smoothness1;
		half _Smoothness2;
		half _Smoothness3;

		struct Input {
			float2 tc_Control0 : TEXCOORD0;
			float2 uv_Splat0 : TEXCOORD1;
			float2 uv_Splat1 : TEXCOORD2;
			float2 uv_Splat2 : TEXCOORD3;
			float2 uv_Splat3 : TEXCOORD4;
			UNITY_FOG_COORDS(5)
		};

		half _Glossiness;
		half _Metallic;

         void SplatmapVert(inout appdata_full v, out Input data)
		{
			UNITY_INITIALIZE_OUTPUT(Input, data);
			data.tc_Control0 = TRANSFORM_TEX(v.texcoord, _Control0);
			
			#if UNITY_VERSION >= 560 			
			float4 pos = UnityObjectToClipPos(v.vertex);
			#else
			float4 pos = UnityObjectToClipPos(float4(v.vertex.xyz, 1.0));			
			#endif
						
			UNITY_TRANSFER_FOG(data, pos);

			#ifdef _TERRAIN_NORMAL_MAP
			v.tangent.xyz = cross(v.normal, float3(0,0,1));
			v.tangent.w = -1;
			#endif
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {

			fixed4 splat_control = tex2D (_Control0, IN.tc_Control0);

			half weight = dot(splat_control, half4(1,1,1,1));

			splat_control /= (weight + 1e-3f);

			fixed4 col = 0.0f;
			col += splat_control.r * tex2D (_Splat0, IN.uv_Splat0) * half4(1.0, 1.0, 1.0, _Smoothness0);
			col += splat_control.g * tex2D (_Splat1, IN.uv_Splat1) * half4(1.0, 1.0, 1.0, _Smoothness1);
			col += splat_control.b * tex2D (_Splat2, IN.uv_Splat2) * half4(1.0, 1.0, 1.0, _Smoothness2);
			col += splat_control.a * tex2D (_Splat3, IN.uv_Splat3) * half4(1.0, 1.0, 1.0, _Smoothness3);

			float4 nrm;
			nrm  = splat_control.r * tex2D(_Normal0, IN.uv_Splat0);
			nrm	+= splat_control.g * tex2D(_Normal1, IN.uv_Splat1);
			nrm	+= splat_control.b * tex2D(_Normal2, IN.uv_Splat2);
			nrm += splat_control.a * tex2D(_Normal3, IN.uv_Splat3);

			o.Albedo = col.rgb;
			o.Smoothness = col.a;
			o.Metallic = dot(splat_control, half4(_Metallic0, _Metallic1, _Metallic2, _Metallic3));
			o.Alpha = weight;

			o.Normal = 	normalize(UnpackNormal(nrm));
		}

		void SplatmapFinalColor(Input IN, SurfaceOutputStandard o, inout fixed4 color)
		{
			color *= o.Alpha;
			UNITY_APPLY_FOG(IN.fogCoord, color);
		}

		ENDCG
	}
	FallBack "Diffuse"
}
