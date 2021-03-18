#ifdef _USE_TEX_ARRAY
		UNITY_DECLARE_TEX2DARRAY(_MainTexArr);
		UNITY_DECLARE_TEX2DARRAY(_MaskTexArr);
#else
        sampler2D _MainTex;
		sampler2D _MaskTex;
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

		fixed3 _G_DayNightLightColor;
		fixed  _G_DayNightLightIntensity;
		//fixed2  _G_DayNightCurrentInfo;
		//fixed _G_DayNightCurrentTime;

		half3	_G_CustomSpecularDirection;
		fixed3 _G_CustomAmbientColor;
		//fixed2 _G_FieldDarkValue;
		fixed  _TextureArrayDepth;
		fixed3 _SpecularColor;
#ifdef WORLD_CUSTOM_FOG
		fixed4 _G_EnvCustomFogColor;
		float4 _G_EnvCustomFogSetting;
		float4 _G_EnvCustomFogHeightSetting;
#endif
//sampler2D _ParallaxMap;
//fixed _Parallax;
//fixed _NormalDepth;

#ifdef _HQ
	fixed _Metallic, _Roughness;
	fixed _Roughness_White, _Roughness_Black;
#else
	fixed _Specular, _Gloss;
	fixed _Gloss_White, _Gloss_Black;
#endif

#ifdef _REFLECTION
fixed _Reflect;
fixed4 _ReflectColor;
#endif
sampler2D _MatCap;
fixed4 _G_TerritoryShadowColor;
struct Input {
	float4 color: Color;
	half2 uv_MainTex;
	//float2 uv_MaskTex;
#ifdef _USE_TEX_ARRAY
	fixed  arrayIndex;
#endif
#ifdef _GLOWMAP
	fixed  glowOn;
#endif
	half3 viewDir;
	float3 worldPos;
	half3 worldRefl;
	INTERNAL_DATA
};
#ifdef _HQ
	inline half4 LightingStandardCustomDefaultGI(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi)
	{
		//gi.light.color.rgb *= _G_DayNightLightColor.rgb * _G_DayNightLightIntensity;
		//gi.indirect.specular *= float3(1, 0.8, 0.75) * 2;// _G_DayNightLightColor * 2;
		//gi.indirect.diffuse += s.Albedo * _G_CustomAmbientColor;
	
		return LightingStandardCustom(s, viewDir, gi);
	}

	inline void LightingStandardCustomDefaultGI_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi)
	{
		//gi.light.color.rgb *= _G_DayNightLightColor.rgb * _G_DayNightLightIntensity;
		//gi.indirect.specular *= float3(1, 0.8, 0.75) * 2;// _G_DayNightLightColor * 2;
		//gi.indirect.diffuse += s.Albedo * _G_CustomAmbientColor;
	
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
		fixed ignoreShadow;
	};
	half4 LightingSimpleSpecularCustom(SurfaceOutputCustom s, half3 lightDir, half3 viewDir, half atten) {
		half NdotL = dot(s.Normal, lightDir);
		half4 c;
		c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
		c.a = s.Alpha;

		return c;
	}

#endif

#ifdef _HQ
	void fcolor(Input IN, SurfaceOutputStandardCustom o, inout fixed4 color)
#else
	void fcolor(Input IN, SurfaceOutputCustom o, inout fixed4 color)
#endif
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

float2 ifNode(float A, float B, float2 AA, float2 AEB, float2 ALB)
{
	half2 out_;
	if (A > B) {
		out_ = AA;
	}
	if (A == B) {
		out_ = AEB;
	}
	if (A < B) {
		out_ = ALB;
	}
	return out_;
}

float4 TimeCalc(float4 t, float4 mode) {
	float4 time = clamp((_Time.y - t) * 2.2, 0, 1);
	time = lerp(1 - time, time, mode);
	return time;
}

void vert(inout appdata_full v, out Input o)
{
	UNITY_INITIALIZE_OUTPUT(Input, o);

	#ifdef _USE_TEX_ARRAY
		o.arrayIndex = v.texcoord.z;
	#endif
#ifdef _GLOWMAP
	float4 objectOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));
	o.glowOn = fmod((objectOrigin.x + objectOrigin.y), 10) * 0.05;
#endif
}
#ifdef _HQ
	void surf(Input IN, inout SurfaceOutputStandardCustom o) {
#else
	void surf(Input IN, inout SurfaceOutputCustom o) {
#endif
	float4 c;
	float4 m;
	half2 mainUV;

	#ifdef UV_FLOW
		mainUV = IN.uv_MainTex + float2(_Time.x * _UVFlowSpeed_X, _Time.x * _UVFlowSpeed_Y);
	#else
		mainUV = IN.uv_MainTex;
	#endif

#ifdef PARALLAX_MAPPING
	half h;
	#ifdef _USE_TEX_ARRAY
		h = UNITY_SAMPLE_TEX2DARRAY(_MaskTexArr, float3(mainUV, IN.arrayIndex)).x;
	#else
		h = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(mainUV)).x; //tex2D(_MaskTex, mainUV).x;
	#endif
	
	half2 offset = ParallaxOffset(h * _Parallax, _Parallax * 10, IN.viewDir);
	mainUV += offset;
#endif

	#ifdef _USE_TEX_ARRAY
		c = UNITY_SAMPLE_TEX2DARRAY(_MainTexArr, float3(mainUV, IN.arrayIndex));
	#else
		c = CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(mainUV)); //tex2D(_MainTex, mainUV);
	#endif
	c.rgb = max(0.05, c.rgb);

#if defined (_GLOWMAP) || defined(_REFLECTION) || defined(_SIMPLE_SPECULAR)
	#ifdef _USE_TEX_ARRAY
		m = UNITY_SAMPLE_TEX2DARRAY(_MaskTexArr, float3(mainUV, IN.arrayIndex));
	#else
		m = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(mainUV)); //tex2D(_MaskTex, mainUV);
	#endif
	m = saturate(m);
	float reflectMask = m.x;
	float roughMask = m.y;
	float glowMask = m.z;
#endif

#ifdef _NORMALMAP
	half A, B;
	half2 AA, AEB, ALB;

	A = mainUV.x;
	B = 0;
	AA = half2(0, -200000);
	AEB = mainUV;
	ALB = half2(0, -200000);

	half2 nuv = ifNode(A, B, AA, AEB, ALB);
	nuv = ifNode(nuv.x, B, nuv, mainUV, nuv);

	float Pow_ = (pow(0.5, 5) * 0.01);
	half2 nuv_1 = (half2((nuv.x + Pow_), nuv.y));
	half2 nuv_2 = (half2(nuv.x, (nuv.y + Pow_)));

	float3 n;

	#ifdef _USE_TEX_ARRAY
		n.x = UNITY_SAMPLE_TEX2DARRAY(_MainTexArr, float3(nuv_1, IN.arrayIndex)).x;
		n.y = UNITY_SAMPLE_TEX2DARRAY(_MainTexArr, float3(nuv, IN.arrayIndex)).x;
		n.z = UNITY_SAMPLE_TEX2DARRAY(_MainTexArr, float3(nuv_2, IN.arrayIndex)).x;
	#else
		n.x = CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(nuv_1)).x; //tex2D(_MaskTex, nuv_1).x;
		n.y = CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(nuv)).x; //tex2D(_MaskTex, nuv).x;
		n.z = CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(nuv_2)).x; //tex2D(_MaskTex, nuv_2).x;
	#endif

	n *= lerp(_NormalBallance_Black, _NormalBallance_White, n) * m.r;// +n pow(n * 2, _Height) * _Height * 0.5;// _Height, n * _Mass));

	half3 appendResult13_g1 = half3(1.0, 0.0, (n.x - n.y) * (m.r * _NormalDepth));
	half3 appendResult16_g1 = half3(0.0, 1.0, (n.z - n.y) * (m.r * _NormalDepth));

	half3 FinalNormal = normalize(cross(appendResult13_g1, appendResult16_g1));
	o.Normal = FinalNormal;
#endif
	fixed3 emission = c.rgb * 0.35;

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
#ifndef WORLD_CUSTOM_FOG
	o.Albedo = max(0.1, o.Albedo) + 0.05;
#endif
	o.Alpha = c.a;

	o.Emission = emission;
#ifdef _HQ
	o.Smoothness = saturate((1 - c.y) * lerp(_Roughness_Black, _Roughness_White, roughMask) * _Roughness);
	o.Metallic = saturate(c.y * _Metallic);
#else
	#ifdef _SIMPLE_SPECULAR
		o.Gloss = saturate((1 - c.y) * _Gloss);
		o.Specular = saturate(c.y * _Specular * lerp(_Gloss_Black, _Gloss_White, roughMask));
	#endif
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
		o.ignoreShadow = saturate(IN.color.a);

}
