// illu shader for PC Platform
//  1 Directional Lighting
//  Adding LOD 1 Pass by Joycity TAD @JYW

Shader "WOT/Background/WOT_Territory_Water_BumpedDisortMovement(Joycity)"
{
	Properties
	{
		[Space(5)][Header(CustomLight)]
		_CustomLightDir("Custom LightDirection", vector) = (0.05, 0.25, 0.55, 1)
		[Header(LOD 0)][Space(5)]
		[Space(5)][Header(Base Textures)]
		_Color("Water Color", Color) = (1,1,1,1)
		_MainTex("Water Texture", 2D) = "black"
	
		[Space(10)]
		[Normal]_DistortionMap1("Normal Texture 1", 2D) = "black" {}
		[Normal]_DistortionMap2("Normal Texture 2", 2D) = "black" {}

		_NormalBias("Normal Intensity x=texture 1, y=texture 2", vector) = (0, 0, 0, 0)
		_DistortionPower("Distortion Power", Range(0, 1) ) = 0
		_Opacity  ("Opacity" , Range(0  , 1.0)) = 0


		[Space(5)][Header(Water Scroll)]	
		_Move1("Normal 1 x.y, Base Texture z.w", vector) = (0, 0, 0, 0)
		_Move2("Normal 2 x y", vector) = (0, 0, 0, 0)

		_WaterAlpha("WaterAlphaTex", 2D) = "white" {}
		_WaterAlphaRange("WaterAlpha", Range(0, 1)) = 0.9
		
		[Space][Header(Lighting option)]
		_SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
		_Specular ("Specular", Range(0,10))  = 1
		_Gloss    ("Glossness"   , Range(0.3, 10 )) = 0.3
	
		
		[Space][Header(Fresnel)]
		_FresnelColor("Fresnel Color", Color) = (0,0,0,1)	
		_FresnelRange("Frensel Range",     Range(0,10)) = 10
		_FresnelInten("Fresnel Intensity", Range(0,10)) = 1

		//_ReflectMap("Reflection Cubemap", Cube) = "_Skybox" {}
		//_ReflectStrength("Reflect Strength", Range(0,1)) = 0

		//LOD1
		//[Header(LOD 1)][Space(5)]
		//[Space(5)][Header(Base Textures)]
		//_ColorLOD("Water Color", Color) = (1,1,1,1)
		//_MainTexLOD("Water Texture", 2D) = "black"

		//[Space(10)]
		//[Normal]_DistortionMap1LOD("Normal Texture 1", 2D) = "black" {}
		//_NormalBiasLOD("Normal Intensity x=texture 1, y=texture 2", vector) = (0, 0, 0, 0)
		//_DistortionPowerLOD("Distortion Power", Range(0, 1)) = 0

		//[Space(5)][Header(Water Scroll)]
		//_Move1LOD("Normal 1 x.y, Base Texture z.w", vector) = (0, 0, 0, 0)
		//_Move2LOD("Normal 2 x y", vector) = (0, 0, 0, 0)

		//[Space][Header(Lighting option)]
		//_SpecColorLOD("Specular Material Color", Color) = (1,1,1,1)
		//_SpecularLOD("Specular", Range(0,7)) = 1
		//_GlossLOD("Glossness"   , Range(0.3, 10)) = 0.3
		//_OpacityLOD("Specular Opacity" , Range(0  , 1.0)) = 0.9

}


SubShader {
    Tags {"Queue"="Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" "DisableBatching" = "True"  }

        ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
   
		CGPROGRAM

		#pragma target 3.0

		//#pragma vertex vert
		#pragma surface surf illuSpec alpha keepalpha noshadow nolightmap nodirlightmap nodynlightmap interpolateview noambient//noforwardadd
		#pragma skip_variants POINT POINT_COOKIE DIRECTIONAL_COOKIE SPOT LIGHTPROBE_SH FOG_LINEAR FOG_EXP FOG_EXP2
		//#define WORLD_CUSTOM_FOG
		//#define	_VERTEX_FOG
		//#include "../../Cginc/cginc_custom_define.cginc"
		#include "UnityCG.cginc"
		float4 _Color;
		
		sampler2D _MainTex;
		
		uniform sampler2D _DistortionMap1;
		uniform sampler2D _DistortionMap2;
		
		uniform sampler2D _WaterAlpha;
		uniform float4 _WaterAlpha_ST;
		uniform float _WaterAlphaRange;
		float3 _CustomLightDir;
		float _DistortionPower;
		float _Specular;
		float _Gloss;

		float _Opacity;

		float4 _FresnelColor;
		float  _FresnelRange, _FresnelInten;

		float4 _NormalBias;
		float4 _Move1;
		float4 _Move2;

		float3 _G_DayNightLightColor;
		float  _G_DayNightLightIntensity;
		float2  _G_DayNightCurrentInfo;
		float _G_DayNightCurrentTime;
		float3 _G_TerritoryCustomAmbientColor;

//#ifdef WORLD_CUSTOM_FOG
//		float4 _G_EnvCustomFogColor;
//		float4 _G_EnvCustomFogSetting;
//		float4 _G_EnvCustomFogHeightSetting;
//#endif

		//samplerCUBE _ReflectMap;
		//float _ReflectStrength;

	// Custom BlinnPhong Lighting model

		struct SurfaceOutputCustom
		{
			fixed3 Albedo;  // diffuse color
			fixed3 Normal;  // tangent space normal, if written
			fixed3 Emission;
			half Specular;  // specular power in 0..1 range
			fixed Gloss;    // specular intensity
			fixed Alpha;    // alpha for transparencies
	//#ifdef WORLD_CUSTOM_FOG
	//	#ifndef _VERTEX_FOG
	//		fixed4 CustomFogColor;
	//		fixed4 CustomFogSettings;
	//		fixed4 CustomFogHeightSettings;
	//		float3 WorldPos;
	//	#else
	//		float4 customFog;
	//	#endif
	//#endif
		};
		struct Input {
			
			float2 uv_MainTex;
			float3 viewDir;
			float3 worldRefl;
			float2 uv_DistortionMap1;
			float2 uv_DistortionMap2;
//#ifdef WORLD_CUSTOM_FOG
//			float3 worldPos;
//#endif
			//INTERNAL_DATA
		};
		float4 LightingilluSpec(SurfaceOutputCustom s, float3 lightDir, float3 viewDir, float atten)
		{
			float3 L = normalize(_CustomLightDir);
			float3 h = normalize(L + viewDir);
			float diff = max(0, dot(s.Normal, L));
			float nh = max(0, dot(s.Normal, h));
			float spec = pow(nh, 48 * s.Gloss) * s.Specular;

			// Add Specular Light   
			//float3 lightColor = lerp(lerp(_G_TerritoryCustomAmbientColor, _G_DayNightLightColor, diff), _G_DayNightLightColor * _G_DayNightLightIntensity, _G_DayNightCurrentTime);
			float3 lightColor = float3(1, 1, 1);
			float3 c = (s.Albedo * lightColor + lightColor * spec) * atten * _SpecColor;
//#ifdef WORLD_CUSTOM_FOG
//			//c = WORLD_FOG(float4(c, 1), s.CustomFogColor, s.CustomFogSettings, s.CustomFogHeightSettings, s.WorldPos.xyz).xyz;
//		#ifndef _VERTEX_FOG
//			c = WORLD_FOG(float4(c, 1), s.CustomFogColor, s.CustomFogSettings, s.CustomFogHeightSettings, s.WorldPos.xyz).xyz;
//		#else
//			c.rgb = lerp(c.rgb, (s.customFog.rgb * s.customFog.a) + max(c.rgb, s.customFog.rgb) , s.customFog.a);
//		#endif
//#endif

			return float4(c.rgb, s.Alpha);
		}
		void surf (Input IN, inout SurfaceOutputCustom o) {
			
			o.Normal = float3(0.0,0.0,1.0);
			
			float2 DistortUV=(IN.uv_DistortionMap1.xy);
			float4 DistortNormal1 = tex2D(_DistortionMap1,DistortUV) ;

			float2 FinalDistortion = DistortNormal1 * _DistortionPower;
															
			// Animate DistortionMap1
			float2 Bump1UV=(float2(IN.uv_DistortionMap1.x  + _Time.x * _Move1.x , IN.uv_DistortionMap1.y  + _Time.x * _Move1.y)) ;
			
			
			float4 DistortedDistortionMap1=tex2D(_DistortionMap1, Bump1UV + FinalDistortion) * float4(1, _NormalBias.x, 1, 1);
			
			float2 Bump2UV=(float2(IN.uv_DistortionMap2.x + _Time.x * _Move2.x , IN.uv_DistortionMap2.y  + _Time.x * _Move2.y)) ;
			
			// Apply Distortion to DistortionMap2			
			float4 DistortedDistortionMap2=tex2D(_DistortionMap2,Bump2UV + FinalDistortion) * float4(1, _NormalBias.y, 1, 1);;
			
			// Get Average from DistortionMap1 and DistortionMap2
			float4 AvgBump= (DistortedDistortionMap1 + DistortedDistortionMap2) / 2;
			
			// Unpack Normals
			float4 UnpackNormal1=float4(UnpackNormal(AvgBump).xyz, 1.0);
			
			// Fresnel
			float fresnel = 1.0 - saturate(dot (o.Normal, normalize(IN.viewDir))); 							
			float3 WaterFresnel = pow(fresnel, _FresnelRange) * 0.5 * _FresnelColor;


			//Diffuse Texture render and scroll
			float3 c = tex2D(_MainTex, float2(IN.uv_MainTex.x + _Time.x * _Move1.z, IN.uv_MainTex.y + _Time.x * _Move1.w)) + (WaterFresnel * _FresnelInten);
			
			float4 _WaterAlpha_var = tex2D(_WaterAlpha, IN.uv_MainTex);
			
			o.Albedo = (c * _Color.rgb) * _WaterAlpha_var;
				
			o.Normal = UnpackNormal1;
			
			o.Specular = _Specular * _WaterAlpha_var;// *texCUBE(_ReflectMap, IN.worldRefl + DistortUV.xyxy).rgb * _ReflectStrength * 5;
			o.Gloss = _Gloss;
			
			o.Emission = WaterFresnel;// max(WaterFresnel, texCUBE(_ReflectMap, IN.worldRefl + DistortUV.xyxy).rgb * _ReflectStrength) * 5;
						
			o.Alpha = _WaterAlpha_var * _WaterAlphaRange;

//#ifdef WORLD_CUSTOM_FOG
//		#ifdef _VERTEX_FOG
//			o.customFog = WORLD_FOG(_G_EnvCustomFogColor, _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, IN.worldPos.xyz);
//		#else
//			o.CustomFogColor = _G_EnvCustomFogColor;
//			o.CustomFogSettings = _G_EnvCustomFogSetting;
//			o.CustomFogHeightSettings = _G_EnvCustomFogHeightSetting;
//			o.WorldPos = IN.worldPos;
//		#endif
//#endif
		}
	ENDCG
 }
 Fallback Off


//SubShader{
//		LOD 200
//
//		Tags{ "Queue" = "Geometry+1" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
//
//		CGPROGRAM
//		#pragma target 3.0
//
//		#pragma surface surf illuSpec alpha keepalpha noshadow nolightmap nodirlightmap nodynlightmap interpolateview noforwardadd
//
//		float4 _ColorLOD;
//
//		sampler2D _MainTexLOD;
//
//		uniform sampler2D _DistortionMap1LOD;
//
//		float _DistortionPowerLOD;
//		float _SpecularLOD;
//		float _GlossLOD;
//
//		float _OpacityLOD;
//
//		float4 _NormalBiasLOD;
//		float4 _Move1LOD;
//		float4 _Move2LOD;
//
//
//	// Custom BlinnPhong Lighting model
//		float4 LightingilluSpec(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
//		float3 h = normalize(lightDir + viewDir);
//		float diff = max(0, dot(s.Normal, lightDir));
//		float nh = max(0, dot(s.Normal, h));
//		float spec = pow(nh, 48 * s.Gloss) * s.Specular;
//
//		// Add Specular Light   
//		float3 c = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten * _SpecColor;
//
//		return float4(c.rgb, s.Alpha);
//		}
//
//		struct Input {
//
//		float2 uv_MainTex;
//		float3 viewDir;
//		float2 uv_DistortionMap1LOD;
//		float2 uv_DistortionMap2LOD;
//		};
//		
//		void surf(Input IN, inout SurfaceOutput o) {
//
//		float2 DistortUV = (IN.uv_DistortionMap1LOD.xy);
//		float4 DistortNormal1 = tex2D(_DistortionMap1LOD,DistortUV);
//		float2 FinalDistortion = DistortNormal1 * _DistortionPowerLOD;
//
//		// Animate DistortionMap1
//		float2 Bump1UV = (float2(IN.uv_DistortionMap1LOD.x + _Time.x * _Move1LOD.x , IN.uv_DistortionMap1LOD.y + _Time.x * _Move1LOD.y));
//		float4 DistortedDistortionMap1 = tex2D(_DistortionMap1LOD, Bump1UV + FinalDistortion) * float4(1, _NormalBiasLOD.x, 1, 1);
//
//		float2 Bump2UV = (float2(IN.uv_DistortionMap2LOD.x + _Time.x * _Move2LOD.x , IN.uv_DistortionMap2LOD.y + _Time.x * _Move2LOD.y));
//		float4 DistortedDistortionMap2 = tex2D(_DistortionMap1LOD,(Bump1UV + float2(-0.1,0)) + FinalDistortion) * float4(1, _NormalBiasLOD.y, 1, 1);;
//
//		// Get Average from DistortionMap1 and DistortionMap2
//		float4 AvgBump = (DistortedDistortionMap1 + DistortedDistortionMap2) * 0.5;
//
//		// Unpack Normals
//		float4 UnpackNormal1 = float4(UnpackNormal(AvgBump).xyz, 1.0);
//
//		//Diffuse Texture render and scroll
//		float3 c = tex2D(_MainTexLOD, IN.uv_MainTex);
//
//		o.Albedo = c * _ColorLOD;
//		o.Normal = UnpackNormal1;
//		o.Specular = _SpecularLOD * 0.8 * _OpacityLOD;
//		o.Gloss = _GlossLOD;
//		o.Alpha = 0.8;
//	}
//	ENDCG
//
// }
//		Fallback "Off"
	
}