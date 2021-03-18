		//struct SurfaceOutputAniso 
		//{
		//	float3 Albedo;
		//	float3 Normal;
		//	float3 Emission;
		//	float Specular;
		//	float Gloss;
		//	float Alpha;
		//
		//	//float2 SpecInfo;
		//	//float3 tangent_output;
		//	//float3 lightDirection;
		//	#ifdef WORLD_CUSTOM_FOG
		//		fixed4 CustomFogColor;
		//		fixed4 CustomFogSettings;
		//		fixed3 CustomFogHeightSettings;
		//		float3 WorldPos;
		//	#endif 
		//};
					
		struct Input
		{
			float2 uv_MainTex;
			float3 tangent_input;
			float3 worldPos;
			float3 viewDir;
			float3 worldNormal; 
			INTERNAL_DATA
		};
		float _MirrorScale;
		void vert(inout appdata_full i, out Input o)
		{	
			UNITY_INITIALIZE_OUTPUT(Input, o);	
			half tangentSign = i.tangent.w * unity_WorldTransformParams.w;
			o.tangent_input = tangentSign * normalize(mul(unity_ObjectToWorld, float4(i.tangent.xyz, 0)));
		}

		sampler2D _MainTex, _MaskTex, _SpecularTex;
		float _PrimaryMultiplier, _SecondaryMultiplier, _PrimaryShift, _SecondaryShift, _HairBright, _Emissive, _G_HQ_DirectionLightIntensity; //_AmbientOcc
		float4 _PrimaryColor, _Color, _SecondaryColor, _LightDirection;
		float3 _G_EnvCustomAmbient_Color;
#ifdef WORLD_CUSTOM_FOG
		float4 _G_EnvCustomFogColor;
		float4 _G_EnvCustomFogSetting;
		float4 _G_EnvCustomFogHeightSetting;
#endif

		float StrandSpecular(float3 T, float3 V, float3 L, float exponent)
		{
			float3 H = normalize(L + V);
			float dotTH = dot(T, H);
			float sinTH = sqrt(1 - dotTH * dotTH);
			float dirAtten = smoothstep(-1, 0, dotTH);
			return dirAtten * pow(sinTH, exponent);
		}

		float3 ShiftTangent(float3 T, float3 N, float shift)
		{
			return normalize(T + shift * N);
		}
		inline half4 LightingStandardCustomDefaultGI(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi)
		{
			return LightingStandardCustom(s, viewDir, gi);
		}

		inline void LightingStandardCustomDefaultGI_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi)
		{
#ifndef _TUTORIAL
			data.atten = min(0.25, data.atten);
#endif
			LightingStandardCustom_GI(s, data, gi);
		}

		void surf (Input IN, inout SurfaceOutputStandardCustom o)
		{
			float4 albedo = tex2D(_MainTex, IN.uv_MainTex);
			float4 alpha = tex2D(_MaskTex, IN.uv_MainTex);
			float3 spec = tex2D(_SpecularTex, IN.uv_MainTex).rgb;

			o.Albedo = lerp(albedo.rgb, albedo.rgb * _Color.rgb * 3, 0.5) * _HairBright;

			float3 emission = o.Albedo * _Emissive;
			o.Alpha = alpha.r;
			o.Smoothness = 0;
			o.Metallic = 0;
			o.Occlusion = pow(albedo, 1.5);
			o.SkinEyeMask = float3(0, 0, 0.5);
			#ifdef _HQ
				#ifndef _HOLOGRAM
					#ifndef _TUTORIAL
						o.HQ_CustomLightPower = _G_HQ_DirectionLightIntensity;
					#endif
				#endif
			#else
				#ifndef _TUTORIAL
					o.HQ_CustomLightPower = _G_HQ_DirectionLightIntensity;
				#endif
			#endif
			
			float3 lightdir = normalize(IN.viewDir + _LightDirection);

			float shiftTex = spec.g - 0.5;
			float3 T = normalize(cross(IN.worldNormal, IN.tangent_input));

			float3 t1 = ShiftTangent(T, IN.worldNormal, _PrimaryShift + shiftTex);
#ifdef _HQ
			float3 t2 = ShiftTangent(T, IN.worldNormal, _SecondaryShift + shiftTex);
#endif
			float3 L = lightdir;
//#ifdef _TUTORIAL
//			float3 L = lightdir; 
//#else
//			float3 L = CUSTOM_LIGHTDIRECTION(IN.viewDir);
//#endif
			float3 h_spec = _PrimaryColor * StrandSpecular(t1, IN.viewDir, lightdir, _PrimaryMultiplier);
#ifdef _HQ
			h_spec = h_spec + _SecondaryColor * spec.b * StrandSpecular(t2, IN.viewDir, L, _SecondaryMultiplier);
#else
			h_spec = h_spec + _SecondaryColor * 0.5;
#endif
			
#ifdef _TUTORIAL
			emission = (emission + h_spec) * 0.35;
			emission *= (1 + CUSTOM_FIXED_AMBIENT);
#else
			h_spec *= _G_HQ_DirectionLightIntensity;
			emission = (emission + h_spec) * 0.35;
			emission *= (1 + (CUSTOM_FIXED_AMBIENT * _G_EnvCustomAmbient_Color));
#endif
			o.Emission = emission;
#ifdef WORLD_CUSTOM_FOG
			o.CustomFogColor = _G_EnvCustomFogColor;
			o.CustomFogSettings = _G_EnvCustomFogSetting;
			o.CustomFogHeightSettings = _G_EnvCustomFogHeightSetting;
			o.WorldPos = IN.worldPos;
#endif
		}


//		inline float4 LightingAniso (SurfaceOutputAniso s, float3 lightDir, float3 viewDir, float atten)
//		{
//			float3 lightdir = normalize(viewDir + s.lightDirection);
//#ifdef _TUTORIAL
//			//float3 lightdir = normalize(viewDir + s.lightDirection);
//			float lightPower = atten;
//#else
//			//float3 lightdir = CUSTOM_LIGHTDIRECTION(viewDir);
//			float lightPower = max(0.65, atten) * _G_HQ_DirectionLightIntensity;
//#endif
//			//lightPower = min(2.8, lightPower);
//			float NdotL = max(0, dot(s.Normal, lightDir));
//			float shiftTex = s.SpecInfo.x - 0.5;
//			float3 T = -normalize(cross(s.Normal, s.tangent_output));
//
//			float3 t1 = ShiftTangent(T, s.Normal, _PrimaryShift + shiftTex);
//#ifdef _HQ
//			float3 t2 = ShiftTangent(T, s.Normal, _SecondaryShift + shiftTex);
//#endif
//			float3 ambient = float3(1,1,1);
//			
//			float3 diff;
//			#ifdef _TUTORIAL
//				diff = saturate(lerp(_HairBright, ambient, NdotL)) * _Color;
//			#else
//				diff = saturate(lerp(_LightColor0.rgb * lightPower * _HairBright, ambient, NdotL)) * _Color;
//				diff *= _G_HQ_DirectionLightIntensity;
//			#endif
//#ifdef _TUTORIAL
//			float3 L = lightdir; 
//#else
//			float3 L = CUSTOM_LIGHTDIRECTION(viewDir);
//#endif
//			float3 spec = _PrimaryColor * StrandSpecular(t1, viewDir, lightdir, _PrimaryMultiplier);
//#ifdef _HQ
//			spec = spec + _SecondaryColor * s.SpecInfo.y * StrandSpecular(t2, viewDir, L, _SecondaryMultiplier);
//#else
//			spec = spec + _SecondaryColor * 0.5;
//#endif
//			float4 c;
//
//
//#ifdef _TUTORIAL
//			c.rgb = (diff * _Emissive + spec * s.Specular) * s.Albedo * max(_AmbientOcc, NdotL) * 2.4;
//#else
//			c.rgb = (diff * _Emissive + spec * s.Specular) * s.Albedo * max(_G_EnvCustomAmbient_Color, NdotL) * 2.4;
//#endif
//#ifdef _TUTORIAL
//			c.rgb = saturate(c * _LightColor0.rgb * lightPower);
//#else
//			c.rgb = saturate(c);
//#endif
//			c.a = s.Alpha;
//
//			return c;
//		}