
        sampler2D _MTexture0;
		sampler2D _MaskTex;
		#ifdef _WARFOG
			sampler2D _G_WarfogTex;
			half4 _WarfogTex_TexelSize;
			float4 _G_WarfogArea = float4(-100, -100, 100, 100);
			//float4 unity_FogColor;
		#endif
		#ifdef _NORMALMAP
			sampler2D _BumpMap;

			#ifdef _LAYERBLEND
				sampler2D _BumpLayer1;
				sampler2D _BumpLayer2;
			#endif
		#endif
		#ifdef _DAMAGED
			half _DamagedTime;
		#endif

		float3 _G_TeamColor_Blue, _G_TeamColor_Red;

        fixed4	_Color;
        fixed	_Smoothness;
		fixed	_Smoothness_Min, _Smoothness_Max;
		fixed	_Metallic;
		fixed	_Metallic_Min, _Metallic_Max;

		float3 _GlobalSkillCenterPoint;
		half _GlobalSkillRadius;

		#ifdef _LAYERBLEND
			sampler2D _MMask0;
			uniform sampler2D _MTexture1;
			uniform sampler2D _MTexture2;
			uniform fixed _Bright0;
			uniform fixed _Bright1;
			uniform fixed _Bright2;

			fixed _Metallic1;
			fixed _Metallic1_Min, _Metallic1_Max;
			fixed _Metallic2;
			fixed _Metallic2_Min, _Metallic2_Max;
			fixed _Smoothness1;
			fixed _Smoothness1_Min, _Smoothness1_Max;
			fixed _Smoothness2;
			fixed _Smoothness2_Min, _Smoothness2_Max;

			#ifdef _ROAD
				sampler2D _DecalTex;
				sampler2D _DecalBump;
				uniform fixed _Bright_Decal;
				uniform fixed4 _Color_Decal;
			#endif
		//#else
		//	float4	_UV_Rect_for_Atlas;
		#endif

		#if defined(_GLOWMAP) && !defined(_NATURAL)
			fixed4	_GlowColor;
			fixed	_GlowStrength;
		#endif

		#ifdef _NATURAL
			fixed _ScaleX, _ScaleY, _OffsetX, _OffsetY;
			fixed4 _WorldMaskColor;
		#endif

		#ifdef _VERTEX_WAVE
			fixed3 _WhiffleSpeed;
			fixed3 _WhiffleWidth;
		#endif
		#ifdef _FADE_START
			fixed _FadeTime;
			fixed _FadeMode;
		#endif
		#ifdef _MODE_SELECTION
			fixed	_SelectionTime;
			//float4 _TeamColor;
		#endif
		fixed	_CharacterMode;
		fixed3 _G_ENV_Darkness; //x:bg, y:alli, z:enemy
		fixed 	_Env_DarknessIdentify; // y,z구분
		fixed _TeamColorUsageInfo;
		#ifdef WORLD_CUSTOM_FOG
			fixed4 _G_EnvCustomFogColor;
			float4 _G_EnvCustomFogSetting;
			float4 _G_EnvCustomFogHeightSetting;
		#endif
		fixed3 _G_EnvCustomAmbient_Color;
		fixed _G_EnvCustomAmbient_BG_Multiplier;
		fixed _G_BG_DirectionLightIntensity;

#ifdef _HQ
		inline half4 LightingStandardCustomDefaultGI(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi)
		{
			//gi.indirect.diffuse += _G_EnvCustomAmbient_Color;
			//gi.indirect.diffuse *= _G_EnvCustomAmbient_BG_Multiplier;
			return LightingStandardCustom(s, viewDir, gi);
		}

		inline void LightingStandardCustomDefaultGI_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandardCustom_GI(s, data, gi);
		}
#else
		struct SurfaceOutputCustom
		{
			fixed3 Albedo;  // diffuse color
			fixed3 Normal;  // tangent space normal, if written
			fixed3 Emission;
			half Specular;  // specular power in 0..1 range
			fixed Gloss;    // specular intensity
			fixed Alpha;    // alpha for transparencies
			#ifdef _WARFOG
				fixed3 WarFogColor;
			#endif
			#ifdef WORLD_CUSTOM_FOG
				fixed4 CustomFogColor;
				fixed4 CustomFogSettings;
				fixed4 CustomFogHeightSettings;
				float3 WorldPos;
			#endif
			half3 Reflect;
		};

		inline fixed4 LightingBlinnPhongCustom(SurfaceOutputCustom s, half3 lightDir, half3 viewDir, half atten)
		{
			half NdotL = dot(s.Normal, lightDir);
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
			c.a = s.Alpha;

			return c;
		}
#endif

        struct Input {
			half2 uv_MTexture0;
//#ifndef _LAYERBLEND
//			float2 atlas_UV;
//#endif
			#ifdef _LAYERBLEND
				half2 uv_MMask0;
				half2 uv_MTexture1;
				half2 uv_MTexture2;
				#ifdef _ROAD
					half2 uv2_MTexture0;
					half2 uv_DecalTex;
				#endif
			#endif
//#ifndef _HQ
			half3 worldRefl;
			INTERNAL_DATA
//#endif
            half3	viewDir;
#ifdef _DAMAGED
			float damageTime;
#endif
			//#if !defined (_NORMALMAP)// && !defined(_LAYERBLEND)
			//	float3 normal;
			//#endif
			float3 worldPos;
			#if defined(_NATURAL)
				#ifdef _NATURAL
					half3 worldNormal; INTERNAL_DATA
				#endif
			#endif

#ifdef _MODE_SELECTION
				fixed3 color;
#endif
        };

		void fcolor(Input IN, SurfaceOutputStandardCustom o, inout fixed4 color)
		{
			#ifdef WORLD_CUSTOM_FOG
				color = WORLD_FOG(color, o.CustomFogColor, o.CustomFogSettings, o.CustomFogHeightSettings, o.WorldPos.xyz);
			#else
				color = color;
			#endif
		}

		void vert(inout appdata_full v, out Input o) {
			float4 vertex = v.vertex;
			UNITY_INITIALIZE_OUTPUT(Input, o);
#ifdef _DAMAGED
			o.damageTime = clamp((_Time.y - _DamagedTime) * 8, 0, 1);
			float2 random = sin(float2(_Time.z, (_Time.z + 0.5)) * 24) * 0.1;
			vertex.xz += lerp(random, 0, saturate(o.damageTime));
#endif

			//#if !defined (_NORMALMAP) //&& !defined(_LAYERBLEND)
			//	o.normal = mul(unity_ObjectToWorld, float4(v.normal, 0.0)).xyz;
			//#endif

			#ifdef _VERTEX_WAVE
				float4 wpos = mul(unity_ObjectToWorld, vertex);
				#ifdef _VERTEX_WAVE
					float val = fmod(((wpos.x + wpos.y) + _Time.z * _WhiffleSpeed) * (v.texcoord.y * v.color.r), 360);
					wpos.xyz += sin(val) * _WhiffleWidth;
					vertex = mul(unity_WorldToObject, wpos);
				#endif
			#endif
#ifdef _INSTANCING_CUSTOM
			half2 uv3 = v.texcoord3;
			INSTANCE_DATA_DECODE_CUSTOM
			v.vertex = mul(unity_WorldToObject, posWorld);
#endif
#ifdef _MODE_SELECTION
			o.color = saturate(1.5 - (_Time[1] - _SelectionTime) * 3) * lerp(_G_TeamColor_Blue, _G_TeamColor_Red, _Env_DarknessIdentify) * _TeamColorUsageInfo * 2;
#endif

//#ifndef _LAYERBLEND
//				o.atlas_UV = float2(v.texcoord.xy * _UV_Rect_for_Atlas.zw + _UV_Rect_for_Atlas.xy);
//#endif
		}
		#ifdef _LAYERBLEND
			half _HeightmapBlending;
			half _Height1Shift;
			half _Height2Shift;
			half _Height3Shift;
		#endif
#ifdef _HQ
		void surf(Input IN, inout SurfaceOutputStandardCustom o) {
#else
		void surf(Input IN, inout SurfaceOutputCustom o) {
#endif
			#ifdef _WARFOG
				float2 WarfogUV = saturate((IN.worldPos.xz - _G_WarfogArea.xy) / max(float2(0.0001, 0.0001), (_G_WarfogArea.zw - _G_WarfogArea.xy)));
				float Warfog = tex2D(_G_WarfogTex, WarfogUV).a;
			#endif

			half3 normalDir = half3(0,0,1);

			#ifdef _LAYERBLEND
				half2 mainUV = IN.uv_MMask0;
				//float3 blend = tex2D(_MMask0, mainUV).rgb;
				fixed3 blend = CUSTOM_TEXTURE_SAMPLE(_MMask0, customizedUV(mainUV)).rgb;
				#ifdef _ROAD
					//float3 v1 = tex2D(_MTexture0, IN.uv2_MTexture0).rgb;
					fixed3 v1 = CUSTOM_TEXTURE_SAMPLE(_MTexture0, customizedUV(IN.uv2_MTexture0)).rgb;
				#else
					//float3 v1 = tex2D(_MTexture0, IN.uv_MTexture0).rgb;
					fixed3 v1 = CUSTOM_TEXTURE_SAMPLE(_MTexture0, customizedUV(IN.uv_MTexture0)).rgb;
				#endif
				fixed h1 = v1.r + blend.r * _Height1Shift;

				//float3 v2 = tex2D(_MTexture1, IN.uv_MTexture1).rgb;
				fixed3 v2 = CUSTOM_TEXTURE_SAMPLE(_MTexture1, customizedUV(IN.uv_MTexture1)).rgb;
				fixed h2 = v2.r + blend.g * _Height2Shift;

				//float3 v3 = tex2D(_MTexture2, IN.uv_MTexture2).rgb;
				fixed3 v3 = CUSTOM_TEXTURE_SAMPLE(_MTexture2, customizedUV(IN.uv_MTexture2)).rgb;
				#ifdef _ROAD
					fixed h3 = v3.r * _Height3Shift;
				#else
					fixed h3 = v3.r + blend.b * _Height3Shift;
				#endif

				fixed4 tex = fixed4(HEIGHT_BLEND(v1 * _Bright0, h1, v2 * _Bright1, h2, v3 * _Bright2, h3, _HeightmapBlending), 1);

				fixed metallic0 = lerp(_Metallic_Min, _Metallic_Max, v1.r) * _Metallic;
				fixed metallic1 = lerp(_Metallic1_Min, _Metallic1_Max, v2.r) * _Metallic1;
				fixed metallic2 = lerp(_Metallic2_Min, _Metallic2_Max, v3.r) * _Metallic2;

				fixed smoothness0 = lerp(_Smoothness_Min, _Smoothness_Max, v1.r) * _Smoothness;
				fixed smoothness1 = lerp(_Smoothness1_Min, _Smoothness1_Max, v2.r) * _Smoothness1;
				fixed smoothness2 = lerp(_Smoothness2_Min, _Smoothness2_Max, v3.r) * _Smoothness2;

				#ifdef _ROAD
					fixed3 gs1 = fixed3(0, 0, 0);
				#else
					fixed3 gs1 = fixed3(metallic0, smoothness0, 0) * v1.r;
				#endif
				fixed3 gs2 = fixed3(metallic1, smoothness1, 0) * v2.r;
				fixed3 gs3 = fixed3(metallic2, smoothness2, 0) * v3.r;

				fixed4 MetallicAndRough = fixed4(HEIGHT_BLEND(gs1, h1, gs2, h2, gs3, h3, _HeightmapBlending), 1);

				#ifdef _NORMALMAP
					#ifdef _ROAD
						fixed3 n1 = fixed3(0,0,1);
					#else
						//float3 n1 = tex2D(_BumpMap, IN.uv_MTexture0).rgb;
						fixed3 n1 = UnpackNormal(CUSTOM_TEXTURE_SAMPLE(_BumpMap, customizedUV(IN.uv_MTexture0))).rgb;
					#endif
					//float3 n2 = tex2D(_BumpLayer1, IN.uv_MTexture1).rgb;
					fixed3 n2 = UnpackNormal(CUSTOM_TEXTURE_SAMPLE(_BumpLayer1, customizedUV(IN.uv_MTexture1))).rgb;
					//float3 n3 = tex2D(_BumpLayer2, IN.uv_MTexture2).rgb;
					fixed3 n3 = UnpackNormal(CUSTOM_TEXTURE_SAMPLE(_BumpLayer2, customizedUV(IN.uv_MTexture2))).rgb;

					normalDir = fixed4(HEIGHT_BLEND(n1, h1, n2, h2, n3, h3, _HeightmapBlending), 1);
				#endif

				#ifdef _ROAD
					
					//float3 decal = tex2D(_DecalTex, IN.uv_DecalTex).rgb;
					fixed3 decal = CUSTOM_TEXTURE_SAMPLE(_DecalTex, customizedUV(IN.uv_DecalTex)).rgb;
						
					#ifdef _NORMALMAP
					//float3 decalBump = tex2D(_DecalBump, IN.uv_DecalTex).rgb;
					fixed3 decalBump = UnpackNormal(CUSTOM_TEXTURE_SAMPLE(_DecalBump, customizedUV(IN.uv_DecalTex))).rgb;
					normalDir = lerp(normalDir, decalBump, blend.b);
					#endif
					tex.rgb = lerp(tex.rgb, decal * _Bright_Decal * _Color_Decal, blend.b);
				#endif

				//normalDir = UnpackNormal(float4(normalDir, 1));

				#ifdef DECAL
					o.Alpha = max(blend.b, max(blend.r, blend.g));
				#endif
			#else
				//float2 mainUV = IN.atlas_UV;
				half2 mainUV = IN.uv_MTexture0;
				//float4 tex = tex2D(_MTexture0, mainUV);
				fixed4 tex = CUSTOM_TEXTURE_SAMPLE(_MTexture0, customizedUV(mainUV));
				//float3 mask = tex2D(_MaskTex, mainUV);
				//float3 mask = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(mainUV));
				#ifdef _NATURAL
					half3 correctWorldNormal = WorldNormalVector(IN, half3(0, 0, 1));
					float2 worldUV = IN.worldPos.zx;

					if (abs(correctWorldNormal.x) > 0.5) worldUV = IN.worldPos.zy;
					if (abs(correctWorldNormal.z) > 0.5) worldUV = IN.worldPos.xy;

					worldUV.x = worldUV.x * _ScaleX + _OffsetX;
					worldUV.y = worldUV.y * _ScaleY + _OffsetY;

					//float worldmask = tex2D(_MaskTex, worldUV).b;
					fixed worldmask = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(worldUV));
					tex.rgb = lerp(tex.rgb * _Color.rgb, tex.rgb * _WorldMaskColor.rgb, worldmask);
				#endif
				//#ifndef DECAL
				//	o.Alpha = tex.a;
				//#else
					o.Alpha = tex.a;
				//#endif

				#ifdef _NORMALMAP 
						//float3 normalDir = UnpackNormal(tex2D(_BumpMap, mainUV));
						normalDir = UnpackNormal(CUSTOM_TEXTURE_SAMPLE(_BumpMap, customizedUV(mainUV)));
				#else
						normalDir = UnpackNormal(half4(0.5, 0.5, 1, 1));
				#endif

			#endif
						normalDir = normalize(normalDir);
			fixed envDarkness = lerp(_G_ENV_Darkness.x, lerp(_G_ENV_Darkness.y, _G_ENV_Darkness.z, _Env_DarknessIdentify), _CharacterMode);
			tex.rgb *= _Color.rgb * envDarkness;

			#ifdef _LAYERBLEND
				#ifdef _ROAD
					fixed metallic = lerp(MetallicAndRough.x, metallic0, blend.b);
					fixed smoothness = lerp(MetallicAndRough.y, smoothness0, blend.b);
				#else
					fixed metallic = MetallicAndRough.x;
					fixed smoothness = MetallicAndRough.y;
				#endif
			#else
				fixed metallic = lerp(_Metallic_Min, _Metallic_Max, tex.r) * _Metallic;
				fixed smoothness = lerp(_Smoothness_Min, _Smoothness_Max, tex.g) * _Smoothness;
			#endif

			#ifdef _DAMAGED
				half3 L = normalize(IN.viewDir);//normalize(_WorldSpaceLightPos0.xyz);
				half NdotL = 1.2 - max(0, dot(normalDir, L));
				
				tex.rgb = lerp(NdotL * (tex.rgb + half3(1, 0.8, 0.5)), tex.rgb, IN.damageTime);
			#endif

			fixed3 emission = 0;
			#ifndef DECAL
				#if defined(_GLOWMAP) && !defined(_NATURAL) 
					fixed3 mask = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(mainUV));
					emission += (_GlowColor.rgb * _GlowStrength * mask.b);
				#endif
			#endif

			metallic = min(1, metallic);
			smoothness = min(1, smoothness);

			#ifdef _MODE_SELECTION
				emission += IN.color.rgb;
			#endif

			o.Albedo = tex.rgb;

			fixed3 occ;
			#ifdef _WARFOG
				Warfog = lerp(max(float3(0.35, 0.35, 0.35), tex.rgb * unity_FogColor.rgb), 1, Warfog);
				smoothness *= Warfog;
				metallic *= Warfog;
				emission *= Warfog;
				o.WarFogColor = Warfog;
				occ = lerp(0, 1, Warfog * envDarkness);
			#else
				occ = envDarkness;
			#endif

			#ifdef _HQ
				o.Smoothness = saturate(smoothness);
				o.Metallic = saturate(metallic);
				o.Occlusion = occ;
			#else
				o.Gloss = saturate(smoothness);
				o.Specular = saturate(metallic);
				o.Reflect = _G_EnvCustomAmbient_Color * _G_EnvCustomAmbient_BG_Multiplier * (UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, IN.worldRefl).rgb * unity_SpecCube0_HDR.r) * o.Gloss;
			#endif

			o.Normal = normalDir;

			o.Emission = emission;
#ifdef AREA_SKILL_EFFECT
			float curDistance = distance(_GlobalSkillCenterPoint.xz, IN.worldPos.xz);
			float Factor = (_GlobalSkillRadius - 0.2 - curDistance) / (-0.3);
			o.Emission += (1 - saturate(Factor)) * float3(0, 0.3, 0.5) * envDarkness;
#endif
#ifdef WORLD_CUSTOM_FOG
			o.CustomFogColor = _G_EnvCustomFogColor;
			o.CustomFogSettings = _G_EnvCustomFogSetting;
			o.CustomFogHeightSettings = _G_EnvCustomFogHeightSetting;
			o.WorldPos = IN.worldPos;
#endif
			o.HQ_CustomLightPower = _G_BG_DirectionLightIntensity;

			#ifdef _FADE_START 
				float fadeTime = 1 - clamp((_Time.y - _FadeTime) * 2, 0, 1);
				fadeTime = lerp(1 - fadeTime, fadeTime, _FadeMode);
				tex.a *= fadeTime;
				o.Alpha = max(0.3, tex.a);
			#endif

			//#ifdef _ROAD
			//	o.CustomViewDir = _CustomViewDir;
			//#endif
        }