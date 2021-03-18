// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//#define CF_BATTLE_MONSTER

		sampler2D _MainTex;
		sampler2D _MaskTex;
		#ifdef _NORMALMAP
			sampler2D _BumpMap;
		#endif

		fixed	_G_BattleDirectionLightIntensity;
		fixed	_Shininess;
		fixed	_Gloss;
		fixed	_FresnelPower;

		#ifdef INFRARED_RAY
			fixed _Temperature;
		#endif
		#ifdef _GLOWMAP
			fixed4	_GlowColor;
			fixed	_GlowStrength;
		#endif

		fixed3 _G_ENV_Darkness; //x:bg, y:alli, z:enemy
		fixed3 _G_TeamColor_Blue, _G_TeamColor_Red;
		fixed  _MainTexBright;

		fixed3 _G_EnvCustomAmbient_Color;
#ifdef WORLD_CUSTOM_FOG
		fixed4 _G_EnvCustomFogColor;
		float4 _G_EnvCustomFogSetting;
		float4 _G_EnvCustomFogHeightSetting;
#endif
#ifdef _HOLOGRAM
		fixed _BrightForReplacement;
#endif
		float3 _GlobalSkillCenterPoint;
		float _GlobalSkillRadius;

#ifdef _INSTANCING_CUSTOM
			float _AnimAll;
			sampler2D _AnimMap;
			float4 _AnimMap_TexelSize;//x == 1/width
			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(float, _AnimStart)
				UNITY_DEFINE_INSTANCED_PROP(float, _AnimEnd)
				UNITY_DEFINE_INSTANCED_PROP(float, _AnimOff)
				UNITY_DEFINE_INSTANCED_PROP(float, _Alpha)
				UNITY_DEFINE_INSTANCED_PROP(float, _Speed)

				//#ifdef _GAME_FADEOUT
				//	UNITY_DEFINE_INSTANCED_PROP(float, _FadeTime)
				//	UNITY_DEFINE_INSTANCED_PROP(float, _FadeState)
				//#endif
				#ifdef _MODE_SELECTION
					UNITY_DEFINE_INSTANCED_PROP(float, _SelectionTime)
				#endif
				#ifdef _USE_TEAM_COLOR
					UNITY_DEFINE_INSTANCED_PROP(float, _TeamColorUsageInfo)
				#endif
				UNITY_DEFINE_INSTANCED_PROP(float, _Env_DarknessIdentify)

				//#ifdef _PAUSE_ANIMATION
				UNITY_DEFINE_INSTANCED_PROP(float, _LastFrameFreez)
				UNITY_DEFINE_INSTANCED_PROP(float, _TimeInput)
				//#endif
				#ifdef _INSTANCING_BLEND
					UNITY_DEFINE_INSTANCED_PROP(float, _OldTimeInput)
					//UNITY_DEFINE_INSTANCED_PROP(float, _OldLastFrameFreez)
					UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimStart)
					UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimEnd)
					UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimOff)
					UNITY_DEFINE_INSTANCED_PROP(float, _MotionBlendOff)
					UNITY_DEFINE_INSTANCED_PROP(float, _MotionBlendTime)
				#endif

				#ifdef _TOP_ROTATION
					UNITY_DEFINE_INSTANCED_PROP(float, _TopRotate)
					UNITY_DEFINE_INSTANCED_PROP(float4, _TopOffset)
				#endif
				UNITY_INSTANCING_BUFFER_END(Props)
#else
				//#ifdef _GAME_FADEOUT
				//	float _FadeTime;
				//	float _FadeState;
				//#endif
				#ifdef _MODE_SELECTION
					float _SelectionTime;
				#endif
				#ifdef _USE_TEAM_COLOR
					float _TeamColorUsageInfo;
				#endif
				float _Env_DarknessIdentify;
#endif
#ifdef _INSTANCING_CUSTOM
	//#define FADE_TIME UNITY_ACCESS_INSTANCED_PROP(Props, _FadeTime)
	//#define FADE_STATE UNITY_ACCESS_INSTANCED_PROP(Props, _FadeState)
	#define SELECTION_TIME UNITY_ACCESS_INSTANCED_PROP(Props, _SelectionTime)
	#define USAGE_TEAM_COLOR UNITY_ACCESS_INSTANCED_PROP(Props, _TeamColorUsageInfo)
	#define ENV_DARK_IDENTIFY UNITY_ACCESS_INSTANCED_PROP(Props, _Env_DarknessIdentify)
#else
	//#define FADE_TIME _FadeTime
	//#define FADE_STATE _FadeState
	#define SELECTION_TIME _SelectionTime
	#define USAGE_TEAM_COLOR _TeamColorUsageInfo
	#define ENV_DARK_IDENTIFY _Env_DarknessIdentify
#endif

        struct Input {
            half2 uv_MainTex;
			half3 viewDir;
#ifdef _HOLOGRAM 
			fixed distort;
			float4 screenPos;
#endif
			#ifndef _NORMALMAP
				half3 normal;
			#endif
			#ifdef _HQ
				INTERNAL_DATA
			#endif
			float3 worldPos;
#ifdef _MODE_SELECTION
			float4 color;
#endif
        };

#ifdef _HQ
		inline half4 LightingStandardCustomDefaultGI(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi)
		{
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
            #ifdef _MODE_SELECTION
			fixed3 SelectionColor;
            #endif

			#ifdef WORLD_CUSTOM_FOG
				fixed4 CustomFogColor;
				fixed4 CustomFogSettings;
				fixed4 CustomFogHeightSettings;
				float3 WorldPos;
			#endif
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

		void fcolor(Input IN, SurfaceOutputStandardCustom o, inout fixed4 color)
		{
			#ifdef WORLD_CUSTOM_FOG
				color = WORLD_FOG(color, o.CustomFogColor, o.CustomFogSettings, o.CustomFogHeightSettings, o.WorldPos.xyz);
			#else
				color = color;
			#endif
		}
		float4 RotateAroundY(float4 vertex, float radian)
		{
			float sina, cosa;
			sincos(radian, sina, cosa);

			float4x4 m;

			m[0] = float4(cosa, 0, sina, 0);
			m[1] = float4(0, 1, 0, 0);
			m[2] = float4(-sina, 0, cosa, 0);
			m[3] = float4(0, 0, 0, 1);

			return mul(m, vertex);
		}

		float4 RotateAroundZ(float4 vertex, float radian)
		{
			float sina, cosa;
			sincos(radian, sina, cosa);

			float4x4 m;

			m[0] = float4(cosa, -sina, 0, 0);
			m[1] = float4(sina, cosa, 0, 0);
			m[2] = float4(0, 0, 1, 0);
			m[3] = float4(0, 0, 0, 1);

			return mul(m, vertex);
		}
		//float4 RotateAroundYInDegrees(float4 vertex, float degrees)
		//{
		//	float alpha = 30 * UNITY_PI / 180.0;
		//	float sina, cosa;
		//	sincos(alpha, sina, cosa);
		//	float2x2 m = float2x2(cosa, -sina, sina, cosa);
		//	return float4(mul(m, float2(vertex.x, vertex.z)), vertex.yw).xzyw;
		//}

		void vert(inout appdata_full v, out Input o) {
			UNITY_SETUP_INSTANCE_ID(v);

#ifdef _INSTANCING_CUSTOM
			//v.vertex *= UNITY_ACCESS_INSTANCED_PROP(Props, _ScaleFade);

			float speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
			float animMap_x1 = (v.texcoord2.x * 3 + 0.5) * _AnimMap_TexelSize.x;
			float animMap_x2 = (v.texcoord2.x * 3 + 1.5) * _AnimMap_TexelSize.x;
			float animMap_x3 = (v.texcoord2.x * 3 + 2.5) * _AnimMap_TexelSize.x;
			float4 row3 = float4(0, 0, 0, 1);

			float lastFrameFreez = UNITY_ACCESS_INSTANCED_PROP(Props, _LastFrameFreez);
			float freezTime = (CUSTOM_SHADER_TIME - UNITY_ACCESS_INSTANCED_PROP(Props, _TimeInput)) * speed;

	#ifdef _INSTANCING_BLEND
			//float oldlastFrameFreez = UNITY_ACCESS_INSTANCED_PROP(Props, _OldLastFrameFreez);
			float oldfreezTime = (CUSTOM_SHADER_TIME - UNITY_ACCESS_INSTANCED_PROP(Props, _OldTimeInput)) * speed;

			float _blend = max(UNITY_ACCESS_INSTANCED_PROP(Props, _MotionBlendOff), saturate((CUSTOM_SHADER_TIME - UNITY_ACCESS_INSTANCED_PROP(Props, _MotionBlendTime)) * 6));

			float2 start = float2(UNITY_ACCESS_INSTANCED_PROP(Props, _AnimStart), UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimStart));
			float2 end = float2(UNITY_ACCESS_INSTANCED_PROP(Props, _AnimEnd), UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimEnd));
			float2 off = float2(UNITY_ACCESS_INSTANCED_PROP(Props, _AnimOff), UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimOff));
			float2 _AnimLen = float2(end.x - start.x, end.y - start.y);
			float2 f = (off + float2(freezTime, oldfreezTime)) / max(0.0001, _AnimLen);
			float2 ff = (off / max(0.0001, _AnimLen));
			f = saturate(lerp(fmod(f, 1.0), (f - ff), float2(lastFrameFreez, 1)));

			float2 animMap_y = (f * _AnimLen + start) / _AnimAll;

			float4 row0 = tex2Dlod(_AnimMap, float4(animMap_x1, animMap_y.x, 0, 0));
			float4 row1 = tex2Dlod(_AnimMap, float4(animMap_x2, animMap_y.x, 0, 0)); 
			float4 row2 = tex2Dlod(_AnimMap, float4(animMap_x3, animMap_y.x, 0, 0)); 

			float4 row10 = tex2Dlod(_AnimMap, float4(animMap_x1, animMap_y.y, 0, 0));
			float4 row11 = tex2Dlod(_AnimMap, float4(animMap_x2, animMap_y.y, 0, 0));
			float4 row12 = tex2Dlod(_AnimMap, float4(animMap_x3, animMap_y.y, 0, 0));

			float4x4 mat = lerp(float4x4(row10, row11, row12, row3), float4x4(row0, row1, row2, row3), _blend);

			float4 pos = mul(mat, v.vertex);
			float3 normal = mul(mat, float4(v.normal, 0)).xyz;

	#else

			float start = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimStart);
			float end = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimEnd);
			float off = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimOff);
			float _AnimLen = end - start;
			float f = (off + freezTime) / max(0.0001, _AnimLen);
			float ff = off / max(0.0001, _AnimLen);
			f = lerp(fmod(f, 1.0), saturate(f - ff), lastFrameFreez);
			float animMap_y = (f * _AnimLen + start) / _AnimAll;
			float4 row0 = tex2Dlod(_AnimMap, float4(animMap_x1, animMap_y, 0, 0));
			float4 row1 = tex2Dlod(_AnimMap, float4(animMap_x2, animMap_y, 0, 0));
			float4 row2 = tex2Dlod(_AnimMap, float4(animMap_x3, animMap_y, 0, 0));
			float4x4 mat = float4x4(row0, row1, row2, row3);

			float4 pos = mul(mat, v.vertex);
			float3 normal = mul(mat, float4(v.normal, 0)).xyz;
	#endif
#else
			float4 pos = v.vertex;
			half3 normal = v.normal;
#endif

#ifdef _TOP_ROTATION
			float4 offset = UNITY_ACCESS_INSTANCED_PROP(Props, _TopOffset);
			float2 rotate = UNITY_ACCESS_INSTANCED_PROP(Props, _TopRotate);
			float m = (1 - v.color.r);
			pos = lerp(pos, RotateAroundY(pos - float4(offset.x, 0, offset.z, 0) , radians(rotate)), m);
			pos.xyz = pos.xyz + float3(offset.x, 0, offset.z) * m;
#endif
			v.vertex = pos;
			v.normal.xyz = normal.xyz;

			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
#ifndef INFRARED_RAY
			#ifndef _NORMALMAP
				o.normal = mul(unity_ObjectToWorld, half4(normal, 0.0)).xyz;
			#endif
#endif

#ifdef _HOLOGRAM
			o.distort = 0.03 * (step(0.8, sin(CUSTOM_SHADER_TIME * 1.5 + (v.vertex.x + v.vertex.y))) * step(0.99, sin(CUSTOM_SHADER_TIME * /*_GlitchSpeed*/ 20)));
#endif
#ifdef _MODE_SELECTION
			o.color.rgb = lerp(_G_TeamColor_Blue, _G_TeamColor_Red, ENV_DARK_IDENTIFY);// 
			o.color.a = saturate(1.5 - (CUSTOM_SHADER_TIME - SELECTION_TIME) * 3); 
#endif
		}

#ifdef _HQ
		void surf(Input IN, inout SurfaceOutputStandardCustom o) {
#else
		void surf(Input IN, inout SurfaceOutputCustom o) {
#endif

#ifdef INFRARED_RAY
			o.Albedo = float3(1, 1, 1);
#else
			half2 mainUV = IN.uv_MainTex;
		#ifdef _HOLOGRAM
			mainUV.x *= (1 - IN.distort);
		#endif
			fixed4 tex = min(1, CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(mainUV)) * _MainTexBright);
			fixed4 mask = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(mainUV));

			#ifdef _NORMALMAP
				half3 normalDir = UnpackNormal(CUSTOM_TEXTURE_SAMPLE(_BumpMap, customizedUV(mainUV)));
			#else
			half3 normalDir = half3(0,0,1);
			#endif
			o.Normal = normalDir;
			fixed envDarkness = lerp(_G_ENV_Darkness.y, _G_ENV_Darkness.z, ENV_DARK_IDENTIFY);
			tex.rgb *= envDarkness;

		#ifdef _HOLOGRAM
			tex.rgb += IN.distort;
			tex.rgb += max(0, dot(tex.rgb, fixed3(0.3, 0.51, 0.11)));

			float lineSize = _ScreenParams.y * 0.0022;
			float displacement = (CUSTOM_SHADER_TIME * 110) % max(0.0001, _ScreenParams.y);
			float ps = displacement + (IN.screenPos.y * _ScreenParams.y / max(0.0001, IN.screenPos.w));
			tex.rgb += fixed3(0, 1.2, 2.5);
			tex.rgb = lerp(tex.rgb * 0.5, tex.rgb, saturate((ps / max(0.0001, floor(lineSize))) % 2));
			tex.rgb = pow(tex.rgb, 2) * 0.1;
			o.Alpha = 0.5;
		#else
			o.Alpha = 1;
		#endif
		#ifdef _MODE_SELECTION
				float3 selectionCol = lerp(tex.rgb, IN.color.rgb, USAGE_TEAM_COLOR);
		#endif
		#ifdef _USE_TEAM_COLOR
			tex.rgb = lerp(tex.rgb, selectionCol, mask.g);
		#endif

			#ifdef INFRARED_RAY
				half fresnel = 1 - saturate(dot(IN.viewDir, normalDir));
				o.Albedo = saturate(fresnel + _Temperature);
			#else
			o.Albedo = tex.rgb;

				//half3 h = normalize(lightDir + viewDir);
				//half nh = max(0, dot(s.Normal, h));
				//float spec = min(1, pow(nh, s.Specular * 48) * s.Gloss);
				//c.rgb = saturate(s.Albedo * lerp(s.Albedo + _G_EnvCustomAmbient_Color, _LightColor0.rgb * atten * _G_BattleDirectionLightIntensity + spec, diff));
				#if defined (_MODE_SELECTION ) || defined (SHOW_HIDDEN_FACE)
					half rim = 1.0 - saturate(dot(normalize(IN.viewDir), normalDir));
					#ifdef SHOW_HIDDEN_FACE
						tex.rgb = float3(0.2,0.2,0.2);
					#else
						tex.rgb += selectionCol * IN.color.a * rim * 2;
					#endif
				#endif
			#endif

		#ifdef _HQ
			float m = (1 + mask.r) * 0.5;
			o.Smoothness = min(0.5, lerp(0, _Gloss, m));
			o.Metallic = min(1, m * _Shininess);
			o.Occlusion = tex.rgb;
		#else
			o.Gloss = mask.r * _Gloss;
			o.Specular = _Shininess; 
		#endif
		o.Emission = o.Albedo.rgb;
		#ifndef _HOLOGRAM
			#ifdef _GLOWMAP
			o.Emission += _GlowColor.rgb * _GlowStrength * max(0, mask.b - 0.1);
			#endif
		#endif
		#ifdef AREA_SKILL_EFFECT
			float curDistance = distance(_GlobalSkillCenterPoint.xz, IN.worldPos.xz);
			float Factor = (_GlobalSkillRadius - 0.2 - curDistance) / (-0.3);
			o.Emission += (1 - saturate(Factor)) * fixed3(0, 0.3, 0.5) * envDarkness;
		#endif
		#ifdef _MODE_SELECTION
			o.Emission += IN.color.rgb * IN.color.a;
		#endif

		o.SkinEyeMask = float3(0, 1, 1);
		o.HQ_CustomLightPower = _G_BattleDirectionLightIntensity * 5;
		
		#ifdef WORLD_CUSTOM_FOG
			o.CustomFogColor = _G_EnvCustomFogColor;
			o.CustomFogSettings = _G_EnvCustomFogSetting;
			o.CustomFogHeightSettings = _G_EnvCustomFogHeightSetting;
			o.WorldPos = IN.worldPos;
		#endif
#endif
        }
