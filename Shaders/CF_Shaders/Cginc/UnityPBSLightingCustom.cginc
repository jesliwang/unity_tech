#ifndef UNITY_PBS_LIGHTING_INCLUDED
#define UNITY_PBS_LIGHTING_INCLUDED

#include "UnityShaderVariables.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityGBuffer.cginc"
#include "UnityGlobalIllumination.cginc"

//-------------------------------------------------------------------------------------
// Default BRDF to use:
#if !defined (UNITY_BRDF_PBS) // allow to explicitly override BRDF in custom shader
    // still add safe net for low shader models, otherwise we might end up with shaders failing to compile
    #if SHADER_TARGET < 30 || defined(SHADER_TARGET_SURFACE_ANALYSIS) // only need "something" for surface shader analysis pass; pick the cheap one
        #define UNITY_BRDF_PBS BRDF3_Unity_PBS
    #elif defined(UNITY_PBS_USE_BRDF3)
        #define UNITY_BRDF_PBS BRDF3_Unity_PBS
    #elif defined(UNITY_PBS_USE_BRDF2)
        #define UNITY_BRDF_PBS BRDF2_Unity_PBS
    #elif defined(UNITY_PBS_USE_BRDF1)
        #define UNITY_BRDF_PBS BRDF1_Unity_PBS
    #else
        #error something broke in auto-choosing BRDF
    #endif
#endif

//-------------------------------------------------------------------------------------
// little helpers for GI calculation
// CAUTION: This is deprecated and not use in Untiy shader code, but some asset store plugin still use it, so let here for compatibility

#if !defined (UNITY_BRDF_GI)
    #define UNITY_BRDF_GI BRDF_Unity_Indirect
#endif

inline half3 BRDF_Unity_Indirect (half3 baseColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, half occlusion, UnityGI gi)
{
    return half3(0,0,0);
}

#define UNITY_GLOSSY_ENV_FROM_SURFACE(x, s, data)               \
    Unity_GlossyEnvironmentData g;                              \
    g.roughness /* perceptualRoughness */   = SmoothnessToPerceptualRoughness(s.Smoothness); \
    g.reflUVW = reflect(-data.worldViewDir, s.Normal);  \


#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    #define UNITY_GI(x, s, data) x = UnityGlobalIllumination (data, s.Occlusion, s.Normal);
#else
    #define UNITY_GI(x, s, data)                                \
        UNITY_GLOSSY_ENV_FROM_SURFACE(g, s, data);              \
        x = UnityGlobalIllumination (data, s.Occlusion, s.Normal, g);
#endif

/////////////////////  스킨 커스텀 라이팅을 위해 추가
// Surface shader output structure to be used with physically
// based shading model.

//-------------------------------------------------------------------------------------
// Metallic workflow

struct SurfaceOutputStandardCustom
{
    fixed3 Albedo;      // base (diffuse or specular) color
    fixed3 Normal;      // tangent space normal, if written
    half3 Emission;
    half Metallic;      // 0=non-metal, 1=metal
    // Smoothness is the user facing name, it should be perceptual smoothness but user should not have to deal with it.
    // Everywhere in the code you meet smoothness it is perceptual smoothness
    half Smoothness;    // 0=rough, 1=smooth
    half Occlusion;     // occlusion (default 1)
    fixed Alpha;        // alpha for transparencies

	#ifdef CF_BGSHADER
		fixed3 WarFogColor;
		fixed HQ_CustomLightPower;
		//#ifdef _ROAD
		//fixed3 CustomViewDir;
		//#endif
	#else
		fixed3 SkinEyeMask;
		#ifndef _TUTORIAL
			fixed HQ_CustomLightPower;
		#endif
	#endif
#ifdef WORLD_CUSTOM_FOG
			fixed4 CustomFogColor;
			fixed4 CustomFogSettings;
			fixed4 CustomFogHeightSettings;
			float3 WorldPos;
#endif

};

inline half4 LightingStandardCustom (SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi)
{
    s.Normal = normalize(s.Normal);

    half oneMinusReflectivity;
    half3 specColor;

	//half3 CustomViewDirection;
	///////////////////////////////////////

	///////////////////////////////////////


    s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);
	//CustomViewDirection = viewDir;
#ifdef CF_BGSHADER
	#ifdef _WARFOG
		gi.light.color *= s.WarFogColor;
	#endif
	gi.light.color *= s.HQ_CustomLightPower;
	//#ifdef _ROAD
	//	CustomViewDirection *= s.CustomViewDir;
	//#endif
#else
		gi.indirect.specular *= (1 - s.SkinEyeMask.x);
		gi.light.color = lerp(gi.light.color * s.SkinEyeMask.z, s.Albedo, s.SkinEyeMask.y);
		#ifndef _TUTORIAL
			gi.light.color *= s.HQ_CustomLightPower;
			#ifdef _HAIR
				gi.light.color = min(1, gi.light.color);
			#endif
			//gi.light.dir = max(0, (gi.light.dir + 1) / 2);
		#endif
#endif

    half4 c = UNITY_BRDF_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
//ifdef WORLD_CUSTOM_FOG
//	#ifdef CF_BGSHADER
//		c.rgb = WORLD_FOG(c, s.CustomFogColor, s.CustomFogSettings, s.CustomFogHeightSettings, s.WorldPos.xyz).rgb;
//	//#else
//	//	c.rgb = FIELD_FOG(c.rgb, s.CustomFogColor, s.CustomFogSettings, 1, s.WorldPos.xyz).rgb;
//	#endif	
//endif

    c.a = outputAlpha;

    return BrightnessCollectionPerDevice(c);
}

inline half4 LightingStandardCustom_Deferred (SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    half oneMinusReflectivity;
    half3 specColor;
	//half3 CustomViewDirection;
    s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);
	//CustomViewDirection = viewDir;
#ifdef CF_BGSHADER
	#ifdef _WARFOG
		gi.light.color *= s.WarFogColor;
	#endif
	//#ifdef _ROAD
	//	CustomViewDirection *= s.CustomViewDir;
	//#endif
#else
		gi.indirect.specular *= (1 - s.SkinEyeMask.x);
		gi.light.color = lerp(gi.light.color * s.SkinEyeMask.z, s.Albedo, s.SkinEyeMask.y);
		#ifndef _TUTORIAL
			gi.light.color *= s.HQ_CustomLightPower;
			//gi.light.dir = CUSTOM_LIGHTDIRECTION(viewDir);
		#endif
#endif
    half4 c = UNITY_BRDF_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);

    UnityStandardData data;
    data.diffuseColor   = s.Albedo;
    data.occlusion      = s.Occlusion;
    data.specularColor  = specColor;
    data.smoothness     = s.Smoothness;
    data.normalWorld    = s.Normal;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    half4 emission = half4(s.Emission + c.rgb, 1);
    return emission;
}

inline void LightingStandardCustom_GI (
    SurfaceOutputStandardCustom s,
    UnityGIInput data,
    inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
#endif

}

//////////////////////


// Surface shader output structure to be used with physically
// based shading model.

//-------------------------------------------------------------------------------------
// Metallic workflow
struct SurfaceOutputStandard
{
    fixed3 Albedo;      // base (diffuse or specular) color
    float3 Normal;      // tangent space normal, if written
    half3 Emission;
    half Metallic;      // 0=non-metal, 1=metal
    // Smoothness is the user facing name, it should be perceptual smoothness but user should not have to deal with it.
    // Everywhere in the code you meet smoothness it is perceptual smoothness
    half Smoothness;    // 0=rough, 1=smooth
    half Occlusion;     // occlusion (default 1)
    fixed Alpha;        // alpha for transparencies
};

inline half4 LightingStandard (SurfaceOutputStandard s, float3 viewDir, UnityGI gi)
{
    s.Normal = normalize(s.Normal);

    half oneMinusReflectivity;
    half3 specColor;
    s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    half4 c = UNITY_BRDF_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
    c.a = outputAlpha;
    return c;
}

inline half4 LightingStandard_Deferred (SurfaceOutputStandard s, float3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    half oneMinusReflectivity;
    half3 specColor;
    s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    half4 c = UNITY_BRDF_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);

    UnityStandardData data;
    data.diffuseColor   = s.Albedo;
    data.occlusion      = s.Occlusion;
    data.specularColor  = specColor;
    data.smoothness     = s.Smoothness;
    data.normalWorld    = s.Normal;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    half4 emission = half4(s.Emission + c.rgb, 1);
    return emission;
}

inline void LightingStandard_GI (
    SurfaceOutputStandard s,
    UnityGIInput data,
    inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
#endif
}

//-------------------------------------------------------------------------------------
// Specular workflow

struct SurfaceOutputStandardSpecular
{
    fixed3 Albedo;      // diffuse color
    fixed3 Specular;    // specular color
    float3 Normal;      // tangent space normal, if written
    half3 Emission;
    half Smoothness;    // 0=rough, 1=smooth
    half Occlusion;     // occlusion (default 1)
    fixed Alpha;        // alpha for transparencies
};

inline half4 LightingStandardSpecular (SurfaceOutputStandardSpecular s, float3 viewDir, UnityGI gi)
{
    s.Normal = normalize(s.Normal);

    // energy conservation
    half oneMinusReflectivity;
    s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    half outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    half4 c = UNITY_BRDF_PBS (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
    c.a = outputAlpha;
    return c;
}

inline half4 LightingStandardSpecular_Deferred (SurfaceOutputStandardSpecular s, float3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    // energy conservation
    half oneMinusReflectivity;
    s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

    half4 c = UNITY_BRDF_PBS (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);

    UnityStandardData data;
    data.diffuseColor   = s.Albedo;
    data.occlusion      = s.Occlusion;
    data.specularColor  = s.Specular;
    data.smoothness     = s.Smoothness;
    data.normalWorld    = s.Normal;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    half4 emission = half4(s.Emission + c.rgb, 1);
    return emission;
}

inline void LightingStandardSpecular_GI (
    SurfaceOutputStandardSpecular s,
    UnityGIInput data,
    inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, s.Specular);
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
#endif
}

#endif // UNITY_PBS_LIGHTING_INCLUDED
