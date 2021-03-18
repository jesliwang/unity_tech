
        sampler2D _MTexture0;
		sampler2D _MaskTex;
#ifdef  CUSTOM_LIGHTMAP
		sampler2D _CustomLightMap;
#endif
		fixed _UVFlowSpeed_X, _UVFlowSpeed_Y;
		fixed _SpecStrength;

#ifdef _WARFOG
		sampler2D_float _TextureWarFogA, _TextureWarFogB, _TextureWarFogC;
		float4 _WarFogSelectionArray[3] = { float4(0,0,0,0), float4(0,0,0,0), float4(0,0,0,0) };
		float4 _WarFogTimeArray[3] = { float4(-5, -5, -5, -5), float4(-5, -5, -5, -5), float4(-5, -5, -5, -5) };
		float4 _WarFogFadeModeArray[3] = { float4(0,0,0,0), float4(0,0,0,0), float4(0,0,0,0) };
		float4 _WarFogArea = float4(-1213.7, -154.67, -918.68, 186.62);
#endif
        fixed4	_Color;

		fixed4	_RimColor;
		fixed	_RimPower;
		//fixed	_CustomAmbient;

		#if defined(_GLOWMAP)
			fixed4	_GlowColor;
			fixed	_GlowStrength;
		#endif

		//fixed3 _G_DayNightLightColor;
		//fixed  _G_DayNightLightIntensity;
		//fixed2  _G_DayNightCurrentInfo;
		//fixed _G_DayNightCurrentTime;

		float3 _GlobalSkillCenterPoint;
		half _GlobalSkillRadius;

		fixed3 _G_EnvCustomAmbient_Color;
		fixed _G_EnvCustomAmbient_BG_Multiplier;
		fixed _G_BG_DirectionLightIntensity;

		fixed3 _G_ENV_Darkness; //x:bg, y:alli, z:enemy
		fixed 	_Env_DarknessIdentify; // y,z구분

		half3	_G_CustomSpecularDirection;
		//fixed3 _G_TerritoryCustomAmbientColor;
		//fixed2 _G_FieldDarkValue;
		//fixed  _TextureArrayDepth;
		fixed3 _SpecularColor;
#ifdef WORLD_CUSTOM_FOG
		fixed4 _G_EnvCustomFogColor;
		float4 _G_EnvCustomFogSetting;
		float4 _G_EnvCustomFogHeightSetting;
#endif
//sampler2D _ParallaxMap;
//fixed _Parallax;
//fixed _NormalDepth;
#ifdef _LAYERBLEND
		sampler2D _MMask0;
		uniform sampler2D _MTexture1;
		uniform sampler2D _MTexture2;
		uniform fixed _Bright0;
		uniform fixed _Bright1;
		uniform fixed _Bright2;

		half _HeightmapBlending;
		half _Height1Shift;
		half _Height2Shift;
		half _Height3Shift;
#endif

	fixed _Specular, _Gloss;
	fixed _Gloss_White, _Gloss_Black;


#ifdef _REFLECTION
fixed _Reflect;
fixed4 _ReflectColor;
#endif

struct Input {
	half2 uv_MTexture0;
	#ifdef _LAYERBLEND
		half2 uv_MMask0;
		half2 uv_MTexture1;
		half2 uv_MTexture2;
	#else
		#ifdef  CUSTOM_LIGHTMAP
				half2 uv2_CustomLightMap;
		#endif
	#endif
#ifdef _GLOWMAP
	fixed  glowOn;
#endif
	half3 viewDir;
	float3 worldPos;
	half3 worldRefl;
	INTERNAL_DATA
};
	struct SurfaceOutputCustom
	{
		fixed3 Albedo;  // diffuse color
		fixed3 Normal;  // tangent space normal, if written
		fixed3 Emission;
		half Specular;  // specular power in 0..1 range
		fixed Gloss;    // specular intensity
		fixed Alpha;    // alpha for transparencies
		//#ifdef _WARFOG
		//	fixed3 WarFogColor;
		//#endif
		#ifdef WORLD_CUSTOM_FOG
			#ifndef _VERTEX_FOG
				fixed4 CustomFogColor;
				fixed4 CustomFogSettings;
				fixed4 CustomFogHeightSettings;
				float3 WorldPos;
			#else
				float4 customFog;
			#endif
		#endif
#ifdef  CUSTOM_LIGHTMAP
		fixed3 CustomLightmap;
#endif
	};
	half4 LightingSimpleSpecularCustom(SurfaceOutputCustom s, half3 lightDir, half3 viewDir, half atten) {
		half3 h = normalize(lightDir + viewDir);

		half diff = max(0, dot(s.Normal, lightDir));

		float nh = max(0, dot(s.Normal, h));
		float spec = pow(nh, 2.0);

		half4 c = float4(s.Albedo, 1);
#ifdef  CUSTOM_LIGHTMAP
		c.rgb = s.Albedo * min(s.CustomLightmap, atten);
#endif
		c.rgb = (c.rgb * _LightColor0.rgb * diff) * atten;
		c.a = s.Alpha;


		return c;
	}


	void fcolor(Input IN, SurfaceOutputCustom o, inout fixed4 color)
	{
		#ifdef WORLD_CUSTOM_FOG
			#ifndef _VERTEX_FOG
				color = WORLD_FOG(color, o.CustomFogColor, o.CustomFogSettings, o.CustomFogHeightSettings, o.WorldPos.xyz);
			#else
				float3 fogCol = o.customFog.rgb * o.customFog.a;
				color.rgb = lerp(color.rgb, fogCol + max(color.rgb, fogCol) , o.customFog.a);
			#endif
		#else
			color = color;
		#endif
		BrightnessCollectionPerDevice(color);
	}

float4 TimeCalc(float4 t, float4 mode) {
	float4 time = clamp((_Time.y - t) * 2.2, 0, 1);
	time = lerp(1 - time, time, mode);
	return time;
}

void vert(inout appdata_full v, out Input o)
{
	UNITY_INITIALIZE_OUTPUT(Input, o);

#ifdef _GLOWMAP
	float4 objectOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));
	o.glowOn = fmod((objectOrigin.x + objectOrigin.y), 10) * 0.05;
#endif
}

void surf(Input IN, inout SurfaceOutputCustom o) 
{
	float4 c;
	float4 m;
	half2 mainUV;

#ifdef _LAYERBLEND
	mainUV = IN.uv_MMask0;
	fixed3 blend = CUSTOM_TEXTURE_SAMPLE(_MMask0, customizedUV(mainUV)).rgb;
	fixed3 v1 = CUSTOM_TEXTURE_SAMPLE(_MTexture0, customizedUV(IN.uv_MTexture0)).rgb;
	fixed h1 = v1.r + blend.r * _Height1Shift;
	fixed3 v2 = CUSTOM_TEXTURE_SAMPLE(_MTexture1, customizedUV(IN.uv_MTexture1)).rgb;
	fixed h2 = v2.r + blend.g * _Height2Shift;
	fixed3 v3 = CUSTOM_TEXTURE_SAMPLE(_MTexture2, customizedUV(IN.uv_MTexture2)).rgb;
	fixed h3 = v3.r + blend.b * _Height3Shift;

	c = fixed4(HEIGHT_BLEND(v1 * _Bright0, h1, v2 * _Bright1, h2, v3 * _Bright2, h3, _HeightmapBlending), 1);
#else
	mainUV = IN.uv_MTexture0;
	c = CUSTOM_TEXTURE_SAMPLE(_MTexture0, customizedUV(mainUV)); //tex2D(_MTexture0, mainUV);
#endif
	fixed envDarkness = _G_ENV_Darkness.x;// lerp(_G_ENV_Darkness.x, lerp(_G_ENV_Darkness.y, _G_ENV_Darkness.z, _Env_DarknessIdentify), 0);
	c.rgb = max(0.05, c.rgb) * envDarkness;

#if defined (_GLOWMAP) || defined(_REFLECTION) || defined(_SIMPLE_SPECULAR)
	m = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(mainUV)); //tex2D(_MaskTex, mainUV);
	m = saturate(m);
	float reflectMask = m.x;
	float roughMask = m.y;
	float glowMask = m.z;
#endif

	fixed3 emission = 0;// c.rgb * 0.35;

#ifdef _REFLECTION

	float3 reflectedDir = IN.worldRefl;
	float4 reflection = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect(-IN.viewDir, o.Normal)).r * _ReflectColor;

	emission += (c * reflection.rgb * _Reflect * 3) * reflectMask;
	c.rgb = lerp(c.rgb, reflection.rgb, max(1, _Reflect) * reflectMask);
#endif

#ifdef _GLOWMAP
	fixed IncreaseTime = IN.glowOn;
	float mode = min(1, (_Time.y - _G_DayNightCurrentInfo.x + IncreaseTime) * 5);
	mode = saturate(lerp(1 - mode, mode, _G_DayNightCurrentInfo.y));

	emission += (_GlowColor.rgb * max(0, _GlowStrength * (glowMask - 0.1)) * mode);
#endif

	o.Albedo = c.rgb * _Color;
	o.Alpha = c.a;
	
#ifdef AREA_SKILL_EFFECT
	float curDistance = distance(_GlobalSkillCenterPoint.xz, IN.worldPos.xz);
	float Factor = (_GlobalSkillRadius - 0.2 - curDistance) / (-0.3);
	emission += (1 - saturate(Factor)) * float3(0, 0.3, 0.5) * envDarkness;
#endif
	o.Emission = emission;

	#ifdef _SIMPLE_SPECULAR
		o.Gloss = saturate((1 - c.y) * _Gloss);
		o.Specular = saturate(c.y * _Specular * lerp(_Gloss_Black, _Gloss_White, roughMask));
	#endif
	
#ifdef WORLD_CUSTOM_FOG
	#ifdef _VERTEX_FOG
		o.customFog = WORLD_FOG(_G_EnvCustomFogColor, _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, IN.worldPos.xyz);
	#else
		o.CustomFogColor = _G_EnvCustomFogColor;
		o.CustomFogSettings = _G_EnvCustomFogSetting;
		o.CustomFogHeightSettings = _G_EnvCustomFogHeightSetting;
		o.WorldPos = IN.worldPos;
	#endif
#endif
#ifdef CUSTOM_LIGHTMAP
		#ifdef _LAYERBLEND
			fixed4 customLightmap = CUSTOM_TEXTURE_SAMPLE(_CustomLightMap, customizedUV(mainUV));
		#else
			fixed4 customLightmap = CUSTOM_TEXTURE_SAMPLE(_CustomLightMap, customizedUV(IN.uv2_CustomLightMap));
		#endif
		
		o.CustomLightmap = customLightmap.rgb;
#endif

}
