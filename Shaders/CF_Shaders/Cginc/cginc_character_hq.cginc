
		float /*LOD_LightWrap,LOD_SkinBright,*/ LOD_Gloss, LOD_Gloss_Skin, LOD_Specular, LOD_Specular_Skin;
		float _BrightBody, _BrightOther;
        sampler2D	_MainTex, _MaskTex, _AreaMask, _BumpMap;
		float4		_Color;// , LOD_HairColor;
		
		float		_FresnelPower_Metal, _FresnelPower_Other, _SmoothnessEye_Strength;// _FresnelPower_Hair;
		float4		_Smoothness_Metal, _Smoothness_Skin, _Smoothness_Other;

		float		_Emissive;
		float		_LightStrength;

		uniform float4 _TeamColor;// , _GlobalTeamColor_Blue;
#ifdef _HOLOGRAM
		//float _GlitchSpeed;
		//float _GlitchIntensity;
		float _G_ElapsedTime;
		float _G_HoloMode;
		float _BrightForReplacement;
#endif
		#ifdef _GLOWMAP
			float4	_GlowColor;
			float	_GlowStrength;
		#endif
		#ifdef _INCLUDE_CONTINUOUS_TRACK
			float _MovingValue;
			float _VSplit;
		#endif
		float _EyesBrightness;
		//skin
		float4	fLTAmbient;
		float	fLTAmbient_Saturation;
		float	fLTDistortion;
		float	fLTScale;
		float	fLightAttentuation;
		float	_Thickness_Max;
		float	_Thickness_Min;
		float	_ThicknessStrength;
		float _G_HQ_DirectionLightIntensity;
#ifdef _DAYNIGHT
		float3 _G_DayNightLightColor;
		float _G_DayNightLightIntensity;
#endif
#ifdef WORLD_CUSTOM_FOG
		float4 _G_EnvCustomFogColor;
		float4 _G_EnvCustomFogSetting;
		float4 _G_EnvCustomFogHeightSetting;
#endif
		float3 _G_EnvCustomAmbient_Color;
		#ifdef _HQ
			inline half4 LightingStandardCustomDefaultGI(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi)
			{
				return LightingStandardCustom(s, viewDir, gi);
			}

			inline void LightingStandardCustomDefaultGI_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi)
			{
//#ifndef _TUTORIAL
//				data.atten = lerp(data.atten, max(0.5, data.atten), s.SkinEyeMask.x);
//#endif
				LightingStandardCustom_GI(s, data, gi);
			}
		#else
			struct SurfaceOutputCustom
			{
				fixed3 Albedo;  // diffuse color
				fixed3 Normal;  // tangent space normal, if written
				fixed3 Emission;
				//half Specular;  // specular power in 0..1 range
				//fixed Gloss;    // specular intensity
				fixed Alpha;    // alpha for transparencies
				fixed HQ_CustomLightPower;
				#ifdef WORLD_CUSTOM_FOG
					fixed4 CustomFogColor;
					fixed4 CustomFogSettings;
					fixed4 CustomFogHeightSettings;
					float3 WorldPos;
				#endif
			};

			inline void LightingLambertCustom_GI(
				SurfaceOutputCustom s,
				UnityGIInput data,
				inout UnityGI gi)
			{
				gi = UnityGlobalIllumination(data, 1.0, s.Normal);
			}

			inline fixed4 UnityLambertLightCustom(SurfaceOutputCustom s, UnityLight light)
			{
				fixed diff = max(0, dot(s.Normal, light.dir));

				fixed4 c;
				#ifndef _TUTORIAL
					light.color *= s.HQ_CustomLightPower;
				#endif
				c.rgb = s.Albedo * light.color * diff;
				c.a = s.Alpha;
				return c;
			}

			inline fixed4 LightingLambertCustom(SurfaceOutputCustom s, UnityGI gi)
			{
				fixed4 c;
				c = UnityLambertLightCustom(s, gi.light);
				#ifdef WORLD_CUSTOM_FOG
					c = WORLD_FOG(c, s.CustomFogColor, s.CustomFogSettings, s.CustomFogHeightSettings, s.WorldPos.xyz);
				#endif
				return BrightnessCollectionPerDevice(c);
			}

		#endif

        struct Input {
            float2 uv_MainTex;
            float3 viewDir;
			#ifdef _HOLOGRAM 
				float normal;
				float distort;
				float4 screenPos;
			#endif
			#ifdef _HQ
				float3 tangentDir;
			#endif
#ifdef WORLD_CUSTOM_FOG
			float3 worldPos;
#endif
        };

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			#ifdef _HOLOGRAM
				o.distort = 0.03 * (step(0.8, sin(_G_ElapsedTime * 1.5 + (v.vertex.x + v.vertex.y))) * step(0.99, sin(_G_ElapsedTime * /*_GlitchSpeed*/ 20)));
				o.normal = v.normal;
			#endif
		
			#ifdef _HQ
				o.tangentDir = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
			#endif
		}
	#ifdef _HQ
		void surf (Input IN, inout SurfaceOutputStandardCustom o) {
	#else
		void surf(Input IN, inout SurfaceOutputCustom o) {
	#endif
			float2 mainUV = IN.uv_MainTex;
			
			#ifdef _INCLUDE_CONTINUOUS_TRACK
				mainUV -= fmod( float2(_MovingValue, 0) * max(0, normalize(IN.uv_MainTex.y - _VSplit)), 1);
			#endif
#ifdef _HOLOGRAM
				mainUV.x *= (1 - IN.distort);
#endif
			float4 tex = CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(mainUV));
			float4 pbr_mask = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(mainUV));
			float4 area_mask = CUSTOM_TEXTURE_SAMPLE(_AreaMask, customizedUV(mainUV));

			#ifdef _USE_TEAM_COLOR
				tex.rgb = lerp(tex.rgb, (1 + tex.rgb) * 0.5 * _TeamColor, area_mask.b);
			#endif

            tex.rgb *= _Color.rgb;

			#ifdef _NORMALMAP
				float3 normalDir = UnpackNormal(CUSTOM_TEXTURE_SAMPLE(_BumpMap, customizedUV(mainUV)));
			#else
				float3 normalDir = normalize(float3(0, 0, 1));
			#endif

#ifdef _HOLOGRAM
				float area_eye = saturate(area_mask.r * area_mask.g);
				float area_skin = saturate(area_mask.r);
#else
			float area_eye = saturate(area_mask.r * area_mask.g);
			float area_skin = saturate(area_mask.r - area_eye);
#endif
			float area_other = saturate(1 - area_skin);

			tex.rgb = lerp(tex.rgb * _BrightOther, tex.rgb * _BrightBody, saturate(area_skin + area_eye));

#ifdef _HOLOGRAM
			float area_hair = min(area_other, area_skin);
			half fresnel = 1 - saturate(dot(IN.viewDir, lerp(normalDir, IN.normal, area_hair)));
#else
			half fresnel = 1 - saturate(dot(IN.viewDir, normalDir));
#endif

			#ifdef _HQ
				#ifdef _HOLOGRAM
					tex.rgb += IN.distort;
					fresnel = lerp(min(0.8, fresnel), tex, area_skin);
					tex.rgb *= (1 + fresnel);//max(0, dot(tex.rgb, float3(0.3, 0.51, 0.11)) * (1 + fresnel)) * _G_HoloMode;
				
					float lineSize = _ScreenParams.y * 0.0038;
					float displacement = (_G_ElapsedTime * 110) % _ScreenParams.y;
					float ps = displacement + (IN.screenPos.y * _ScreenParams.y / max(0.0001, IN.screenPos.w));
					tex.rgb += (fresnel + (area_skin * _BrightForReplacement * 0.65) + lerp(saturate(tex.rgb * 1.5), float3(0, 0.6, 1.5), _G_HoloMode));
					tex.rgb = lerp(tex.rgb * 0.5, tex.rgb, saturate((ps / max(0.0001, floor(lineSize))) % 2)) * 0.5;
					tex.rgb = pow(tex.rgb, 2) * lerp(0.25, 0.135, area_eye);
				#else
					float final_fresnel = lerp(_FresnelPower_Other, _FresnelPower_Metal, pbr_mask.g);
					//final_fresnel = lerp(final_fresnel, _FresnelPower_Hair, area_hair);
					fresnel = smoothstep(0, final_fresnel, fresnel);
					fresnel = lerp(fresnel, 0, area_skin) * (1 - area_eye);
				#endif
			#else
				fresnel = smoothstep(0, /*LOD_LightWrap*/4.5, fresnel) * area_other;
			#endif
#ifndef _TUTORIAL
				fresnel = min(0.35, fresnel);
#endif
			//셰이더GUI에서 처리
			//_Smoothness_Skin	= (_SmoothnessSkin_Min, _SmoothnessSkin_Max, _SmoothnessSkin_Strength, _SpecularSkin);
			//_Smoothness_Metal = (_SmoothnessMetal_Min, _SmoothnessMetal_Max, _SmoothnessMetal_Strength, _SpecularMetal);
			//_Smoothness_Other = (_SmoothnessOther_Min, _SmoothnessOther_Max, _SmoothnessOther_Strength, _SpecularOther);

			#ifdef _HQ
				float4 pbr_Parameters = lerp(_Smoothness_Other, _Smoothness_Metal, pbr_mask.g);
				pbr_Parameters = lerp(pbr_Parameters, _Smoothness_Skin, area_skin);

				float smoothness = lerp(pbr_Parameters.x, pbr_Parameters.y, pbr_mask.r * pbr_Parameters.z);
				smoothness = lerp(smoothness, _SmoothnessEye_Strength, area_eye);

				float metallic = lerp(0, pbr_Parameters.w, pbr_mask.g);// lerp(area_hair, pbr_Parameters.w, pbr_mask.g);
			#endif

			float3 fLTAmbientColor = lerp(fLTAmbient, dot(fLTAmbient, float3(0.3, 0.59, 0.11)), fLTAmbient_Saturation * pbr_mask.b);
			float fLTThickness = smoothstep(0, _ThicknessStrength, 1 + lerp(_Thickness_Max, _Thickness_Min, pbr_mask.b));

			float3 vLTLight = o.Normal.xyz * fLTDistortion;
#ifdef _TUTORIAL
			float fLTDot = dot(IN.viewDir, -vLTLight) * fLTScale;
#else
			float fLTDot = dot(IN.viewDir, -vLTLight) * min(0.01, fLTScale);
#endif
			float3 fLT = (fLTDot + fLTThickness) * fLTAmbientColor * fLightAttentuation;
#ifdef _TUTORIAL
			fLT = lerp(0.5, fLT, area_skin);
#else
			fLT = lerp(0.5, fLT * 0.8, area_skin);
#endif

			#ifdef _HQ
				o.Albedo = saturate(tex.rgb * lerp(1, _EyesBrightness, area_eye));
#ifdef _TUTORIAL
				o.Smoothness = smoothness;
				o.Metallic = metallic;
#else
				o.Smoothness = min(0.35, smoothness);
				o.Metallic = metallic;
#endif
				
				o.Occlusion = (1 + fresnel) * 0.5;
			#else
				tex.rgb = saturate((tex.rgb + fresnel) * lerp(1, _EyesBrightness, area_eye));
				
				#ifdef _TUTORIAL
					o.Albedo = saturate((tex.rgb + tex.rgb * fresnel));
				#else
					o.Albedo = saturate((tex.rgb + tex.rgb * fresnel) * 0.85);
				#endif
				//o.Gloss = saturate(lerp(saturate(0.1 + pbr_mask.r) * lerp(LOD_Gloss, LOD_Gloss_Skin, area_skin), 1, area_eye));
				//o.Specular = saturate(lerp(saturate(0.3 + pbr_mask.g) * lerp(LOD_Specular, LOD_Specular_Skin, area_skin), 1, area_eye));
			#endif
				o.Normal = normalDir;

				float3 emission;
				#ifdef _TUTORIAL
					emission = o.Albedo * fLT * (1 + CUSTOM_FIXED_AMBIENT);
				#else
				emission = o.Albedo * fLT;// *(1 + _G_EnvCustomAmbient_Color * 0.5);
				#endif
			#ifdef _GLOWMAP
				emission += (_GlowStrength * _GlowColor.rgb * area_other * max(0, pbr_mask.b - 0.1));
			#endif
#ifdef _HOLOGRAM
				o.Emission = o.Albedo.rgb;
#else
				emission *= _Emissive;
				o.Emission = emission;
#endif
#ifdef _DAYNIGHT
				o.Emission *= _G_DayNightLightIntensity * _G_DayNightLightColor;
#endif
			#ifdef _HQ
				#ifdef _HOLOGRAM
					o.SkinEyeMask = float3(0, 0, 1);
					o.Alpha = 0.85;
				#else
					#ifdef _TUTORIAL
						o.SkinEyeMask = float3(/*노스펙큘러*/area_skin, /*눈동자영역*/area_eye, _LightStrength);
					#else
						o.SkinEyeMask = float3(area_skin, area_eye, 0.5);
						o.HQ_CustomLightPower = _G_HQ_DirectionLightIntensity;
					#endif
					o.Alpha = 1;
				#endif
			#else
				#ifndef _TUTORIAL
					o.HQ_CustomLightPower = _G_HQ_DirectionLightIntensity;
				#endif
			#endif

			#ifdef WORLD_CUSTOM_FOG
				o.CustomFogColor = _G_EnvCustomFogColor;
				o.CustomFogSettings = _G_EnvCustomFogSetting;
				o.CustomFogHeightSettings = _G_EnvCustomFogHeightSetting;
				o.WorldPos = IN.worldPos;
			#endif
		}
