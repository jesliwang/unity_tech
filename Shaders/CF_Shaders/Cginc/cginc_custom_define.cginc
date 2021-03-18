#ifdef MIP_BIAS
	float _G_MipmapBias;

	#define customizedUV(uv) float4(uv.xy, 0, _G_MipmapBias)
	#define CUSTOM_TEXTURE_SAMPLE tex2Dbias
#else
	#define customizedUV(uv) float2(uv)
	#define CUSTOM_TEXTURE_SAMPLE tex2D
#endif

#ifdef SHADER_API_MOBILE 
	#define CUSTOM_SHADER_TIME _Time.y
#else
	float _GInstancingShaderTime;
	#define CUSTOM_SHADER_TIME _GInstancingShaderTime
#endif

#define FIELD_DARKNESS_VALUE FieldDarknessValue
float FieldDarknessValue(float time, float mode)
{
	float fadeTime = 1 - saturate((_Time.y - time) * 2);
	fadeTime = lerp(1 - fadeTime, fadeTime, mode);
	return fadeTime;
}

#define HEIGHT_BLEND heightblend
float3 heightblend(float3 input1, float height1, float3 input2, float height2, float3 input3, float height3, float heightmapBlending)
{
	float height_start = max(max(height1, height2), height3) - heightmapBlending;
	float3 b = max(0, float3(height1, height2, height3) - height_start);

	return ((input1 * b.x) + (input2 * b.y) + (input3 * b.z)) / (b.x + b.y + b.z);
}

#define FIELD_FOG FieldCustomFog
float3 FieldCustomFog(float3 col, float3 fogCol, float4 fogSetting, float value, float3 worldpos)
{
	float fieldFogFactor = clamp((fogSetting.x - min(fogSetting.w, distance(worldpos, _WorldSpaceCameraPos.xyz))) / (fogSetting.x - max(fogSetting.x + 0.0001, fogSetting.y)), 0, 1);
	return lerp(col.rgb, fogCol.rgb * fogSetting.z, fieldFogFactor * value);
}

float4 _G_CamGroundPosition;
float _G_InTerritory;
float _G_EnvCustomFogFactorCharacter;
#define WORLD_FOG WorldCustomFog 
#ifdef _VERTEX_FOG
float4 WorldCustomFog(float4 fogCol, float4 fogSetting, float4 fogHeightSetting, float3 worldpos)
#else
float4 WorldCustomFog(float4 col, float4 fogCol, float4 fogSetting, float4 fogHeightSetting, float3 worldpos)
#endif
{
	float2 fogMin = float2(fogSetting.x, fogHeightSetting.x);
	float2 fogMax = float2(fogSetting.y, fogHeightSetting.y);
	float2 fogLimit = float2(fogSetting.w, fogHeightSetting.z);
	float fogBright = fogSetting.z;
	float3 camPos = lerp(_WorldSpaceCameraPos.xyz, _G_CamGroundPosition.xyz, _G_CamGroundPosition.w);
	float2 worldFogFactor = (fogMin - min(fogLimit, distance(worldpos, camPos))) / (fogMin - max(fogMin + 0.0001, fogMax));

	//float finalFactor = saturate(worldFogFactor.x + (1-worldFogFactor.y));
	float finalFactor = worldFogFactor.x * worldFogFactor.y;
#ifndef CF_BGSHADER
	finalFactor *= _G_EnvCustomFogFactorCharacter;
#endif
	finalFactor = saturate(finalFactor);

	float3 finalFogColor = fogCol.rgb * fogBright;
#ifdef _VERTEX_FOG
	return float4(finalFogColor, finalFactor);
#else
	return float4(lerp(col.rgb, finalFogColor, finalFactor), col.a);
#endif
}

#define CUSTOM_LIGHTDIRECTION CustomLightDirection
float3 CustomLightDirection(float3 viewDir)
{
	return viewDir + float3(0, 0.3, 0);// normalize(viewDir + float3(-10, 30, 20));
}

#define CUSTOM_FIXED_AMBIENT float3(0.12, 0.12, 0.12)

#ifdef _USE_CROSSFADE
	float4 _G_CrossfadeTime;
	float4 _G_CrossfadeMode;
#endif

#define CUSTOM_CROSSFADE Crossfade
float Crossfade(float time, float mode)
{
	float fadeTime = saturate((_Time.y - time) * 3);
	fadeTime = lerp(fadeTime, 1 - fadeTime, mode);
	return fadeTime;
}
#define BRIGHTNESS_COLLECTION_PER_DEVICE BrightnessCollectionPerDevice
fixed4 BrightnessCollectionPerDevice(float4 tex)
{
	#ifdef SHADER_API_METAL
		tex.rgb *= 0.8;
	#endif

	return tex;
}
