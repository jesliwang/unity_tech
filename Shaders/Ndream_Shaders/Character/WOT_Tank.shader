Shader "WOT/Character/WOT_Tank"
{
	Properties
	{	
		//[Header(ENVIRONMENT___________________________________________________)]
		//[MaterialToggle(USEFOG)] _USEFOG("Fog", Float) = 0
		
		[Header(OPTION________________________________________________________)]
		[MaterialToggle(LIGHT_SPECULAR)] _LIGHT_SPECULAR("Light & Specular", Float) = 0
		[MaterialToggle(LIGHT_MATCAP)] _LIGHT_MATCAP("Light & Matcap", Float) = 0
		[MaterialToggle(LIGHT)] _LIGHT("Ligh", Float) = 0
		[MaterialToggle(LIGHT_CUTOFF)] _LIGHT_CUTOFF("Ligh & Cutoff", Float) = 0
		[MaterialToggle(MATCAP)] _MATCAP("Matcap", Float) = 0
			
		[Header(MAIN__________________________________________________________)]
		_Color("Color", Color)	= (1.0, 1.0, 1.0, 1.0)
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		[NoScaleOffset] _DirtTex("DirtTex", 2D) = "white" {}
		//_DirtDegree("Dirt Degree", Range(0, 1)) = 0
		_Bright("Bright", Range(0, 2)) = 1
		_Contrast("Contrast", Range(0, 2)) = 1

		//PATTERN
		//[Space(10)]
		//[Header(PATTERN_______________________________________________________)]
		//_DyeColor1("DyeColor1(R)", Color) = (1.0,1.0,1.0,1.0)
		//_DyeColor2("DyeColor2(G)", Color) = (1.0,1.0,1.0,1.0)
		//[NoScaleOffset]
		//_PatternTex("PatternTex(RG)", 2D) = "white" {}
		//_Tile("Tile", Range(1, 10)) = 1
		//_RotationSpeed("Rotation Speed", Range(-6.3, 6.3)) = 0

		//[Space(10)]
		[Header(SPECULAR______________________________________________________)]
		//[NoScaleOffset]_BumpTex("Normal Map", 2D) = "bump" {}
		//_BumpPower("Normal Power", Range(0, 10)) = 1
		[NoScaleOffset]_SpecularTex("Specular Map", 2D) = "white" {}
		_Shininess("Shininess Range", Range(1, 100)) = 10
		_ShininessPower("Shininess Power", Range(0, 1)) = 1

		[Header(CUTOFF________________________________________________________)]
		//[NoScaleOffset]_BumpTex("Normal Map", 2D) = "bump" {}
		//_BumpPower("Normal Power", Range(0, 10)) = 1
		[NoScaleOffset]_TransTex("TransTex (R)", 2D) = "white" {}
		_Cutoff("Cutoff", Range(0,1)) = 0.5

		//MATCAP
		//[Space(10)]
		[Header(MATCAP________________________________________________________)]
		[NoScaleOffset]
		_MatCap("MatCap (RGB)", 2D) = "white" {}
		//_MatCap("MatCap (RGB)", 2D) = "gray" {}
		_MatCapBright("MatCap Bright", Range(0,1)) = 1
		_MatCapContrast("MatCap Range", Range(0,10)) = 1

			//Gpu Instancing Ani
			//[Space(10)]
			//[Header(GPU Instancing Ani____________________________________________)]
			//_AnimMap("AnimMap", 2D) = "white" {}
			//_AnimStart("_AnimStart", Float) = 0
			//_AnimEnd("_AnimEnd", Float) = 0
			//_AnimAll("_AnimAll", Float) = 0
			//_AnimOff("_AnimOff", Float) = 0

			//_OldAnimStart("_OldAnimStart", Float) = 0
			//_OldAnimEnd("_OldAnimEnd", Float) = 0
			//_OldAnimOff("_OldAnimOff", Float) = 0

			//_Speed("_Speed", Float) = 1
			//_Blend("_Blend", Range(0, 1)) = 1
	}

		SubShader
		{
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"
				#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
				#pragma multi_compile_instancing
				#pragma multi_compile_fog

			//#pragma skip_variants SHADOWS_CUBE LIGHTPROBE_SH SHADOWS_SCREEN SHADOWS_DEPTH
			#pragma skip_variants LIGHTPROBE_SH
			#pragma skip_variants SHADOWS_DEPTH SHADOWS_CUBE


			#pragma shader_feature LIGHT_SPECULAR
			#pragma shader_feature LIGHT_CUTOFF
			#pragma shader_feature LIGHT_MATCAP
			//#pragma shader_feature USESPECULAR
			//#pragma shader_feature CASTSHADOW
			#pragma shader_feature LIGHT
			#pragma shader_feature MATCAP
			//#pragma shader_feature USEFOG

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DirtTex;
			//float _DirtDegree;
			float _Bright;
			float _Contrast;


			fixed4 _DyeColor1;
			fixed4 _DyeColor2;
			sampler2D	_PatternTex;
			float4		_PatternTex_ST;
			fixed		_Tile;
			float		_RotationSpeed;

#ifdef LIGHT_MATCAP
			//sampler2D _BumpTex;
			//sampler2D _SpecularTex;
			//float _Shininess;
			sampler2D _MatCap;
			fixed _MatCapBright;
			fixed _MatCapContrast;
#endif
#ifdef LIGHT_SPECULAR
			//sampler2D _BumpTex;
			sampler2D _SpecularTex;
			//float _BumpPower;
			float _Shininess;
			float _ShininessPower;
#endif
#ifdef LIGHT_CUTOFF
			//sampler2D _BumpTex;
			sampler2D _TransTex;
			float _Cutoff;
#endif
#ifdef MATCAP
			sampler2D _MatCap;
			fixed _MatCapBright;
			fixed _MatCapContrast;
#endif
			//float _AnimAll;
			//sampler2D _AnimMap;
			//float4 _AnimMap_TexelSize;//x == 1/width

			//UNITY_INSTANCING_BUFFER_START(Props)
			//	UNITY_DEFINE_INSTANCED_PROP(float, _AnimStart)
			//	UNITY_DEFINE_INSTANCED_PROP(float, _AnimEnd)
			//	UNITY_DEFINE_INSTANCED_PROP(float, _AnimOff)
			//	UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimStart)
			//	UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimEnd)
			//	UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimOff)
			//	UNITY_DEFINE_INSTANCED_PROP(float, _Blend)
			//	UNITY_DEFINE_INSTANCED_PROP(float, _Speed)
			//UNITY_INSTANCING_BUFFER_END(Props)

			struct appdata
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;				//Pattern Rotation
				//float2 uv3 : TEXCOORD2;			//Gpu Instancing Animation
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				//float2 uv3 : TEXCOORD2;
//#ifdef USEFOG
				UNITY_FOG_COORDS(2)
//#endif
				//fixed3 ambient : COLOR0;
				float4 pos : SV_POSITION;

#ifdef LIGHT_MATCAP
				fixed3 diff : COLOR1;
				SHADOW_COORDS(7) // put shadows data into TEXCOORD1
				fixed3 normalDir : TEXCOORD3;
				fixed4 posWorld : TEXCOORD6;
				half2 matCapUV : TEXCOORD4;
#endif
//#ifdef LIGHT_SPECULAR
#if defined (LIGHT_SPECULAR) || (LIGHT) || (LIGHT_CUTOFF)
				fixed3 diff : COLOR1;
				SHADOW_COORDS(7) // put shadows data into TEXCOORD1
				fixed3 normalDir : TEXCOORD3;
				fixed4 posWorld : TEXCOORD6;
#endif
#ifdef MATCAP
				half2 matCapUV : TEXCOORD7;
#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			v2f vert(appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);

				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o.uv = v.uv;

				//Rotate UV
				o.uv2 = TRANSFORM_TEX(v.uv2, _PatternTex);
				o.uv2 = o.uv2 * _Tile + (_Tile * -0.5);
				//o.uv3 = TRANSFORM_TEX(v.uv, _MainTex);
				//o.uv3 = o.uv3 * _Tile + (_Tile * -0.5);
				float sinX = sin(_RotationSpeed);
				float cosX = cos(_RotationSpeed);
				float sinY = sin(_RotationSpeed);
				float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
				//v.texcoord.xy = mul(v.texcoord.xy, rotationMatrix);
				o.uv2 = mul(o.uv2, rotationMatrix);
				//o.uv3 = mul(o.uv3, rotationMatrix);

#ifdef LIGHT_MATCAP
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);

				float3 worldNormal = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				worldNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
				o.matCapUV = worldNormal.xy * 0.5 + 0.5;

				fixed NdotL = saturate(dot(o.normalDir, normalize(_WorldSpaceLightPos0.xyz)));
				o.diff = NdotL * _LightColor0.rgb;

				//light
				TRANSFER_SHADOW(o)
#endif
//#ifdef LIGHT_SPECULAR
#if defined (LIGHT_SPECULAR) || (LIGHT) || (LIGHT_CUTOFF)
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);

				fixed NdotL = saturate(dot(o.normalDir, normalize(_WorldSpaceLightPos0.xyz)));
				o.diff = NdotL * _LightColor0.rgb;

				//light
				TRANSFER_SHADOW(o)
#endif
#ifdef MATCAP
				float3 worldNormal = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				worldNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
				o.matCapUV = worldNormal.xy * 0.5 + 0.5;
#endif
				//o.ambient = UNITY_LIGHTMODEL_AMBIENT;
//#ifdef USEFOG
				UNITY_TRANSFER_FOG(o, o.pos);
//#endif

				return o;
			}


			fixed4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);

				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= _Bright * _Color;
				col.rgb = pow(col.rgb, _Contrast);
				
				//Dirt
				//fixed3 dirtTex = tex2D(_DirtTex, i.uv);
				//col.rgb = lerp(col, dirtTex, _DirtDegree);

				//Pattern
				//fixed4 patternTex = tex2D(_PatternTex, i.uv2);
				//col = (col * (1 - (patternTex.r + patternTex.g))) + (col * patternTex.r * _DyeColor1) + (col * patternTex.g * _DyeColor2);

#ifdef LIGHT_MATCAP
				fixed3 mcTex = tex2D(_MatCap, i.matCapUV);
				mcTex = pow(mcTex, _MatCapContrast);
				col.rgb += mcTex * 2.0 * _MatCapBright;

				fixed shadow = SHADOW_ATTENUATION(i);
				//shadow += 1;
				//fixed3 lighting = (i.diff * shadow) + i.ambient;
				fixed3 lighting = ((i.diff * shadow) * 0.5 + 0.5) * 1.5;
				col.rgb *= lighting;
#endif
#ifdef LIGHT_SPECULAR
				fixed specularTex = tex2D(_SpecularTex, i.uv);
				
				fixed shadow = SHADOW_ATTENUATION(i);

				fixed3 normalDirection = normalize(i.normalDir);
				fixed3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
				fixed3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				//float attenuation = 1.0;

				fixed3 diffuseReflection =	_LightColor0.rgb * max(0.0, dot(normalDirection, lightDirection));
				fixed3 specularReflection;
				if (dot(normalDirection, lightDirection) < 0.0)
					// light source on the wrong side?
				{
					specularReflection = fixed3(0.0, 0.0, 0.0);
					// no specular reflection
				}
				else // light source on the right side
				{
					//specularReflection = attenuation * _LightColor0.rgb	* pow(max(0.0, dot(
					//		reflect(-lightDirection, normalDirection),
					//		viewDirection)), _Shininess) * _ShininessPower;
					specularReflection = (_ShininessPower * _LightColor0.rgb	* pow(max(0.0, dot(
							reflect(-lightDirection, normalDirection),
							viewDirection)), _Shininess)) * specularTex;
				}

				//col.rgb = (col.rgb * diffuseReflection * shadow) + (col.rgb * i.ambient + specularReflection * shadow);
				col.rgb = (col.rgb * diffuseReflection * shadow) + (col.rgb + specularReflection * shadow);
#endif
#ifdef LIGHT
				//fixed specularTex = tex2D(_SpecularTex, i.uv);

				fixed shadow = SHADOW_ATTENUATION(i);

				fixed3 normalDirection = normalize(i.normalDir);
				fixed3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
				fixed3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				//float attenuation = 1.0;

				fixed3 diffuseReflection = _LightColor0.rgb * max(0.0, dot(normalDirection, lightDirection));
				//fixed3 specularReflection;
				//if (dot(normalDirection, lightDirection) < 0.0)
				//	// light source on the wrong side?
				//{
					//specularReflection = fixed3(0.0, 0.0, 0.0);
				//	// no specular reflection
				//}
				//else // light source on the right side
				//{
				//	//specularReflection = attenuation * _LightColor0.rgb	* pow(max(0.0, dot(
				//	//		reflect(-lightDirection, normalDirection),
				//	//		viewDirection)), _Shininess) * _ShininessPower;
				//	specularReflection = (_ShininessPower * _LightColor0.rgb	* pow(max(0.0, dot(
				//		reflect(-lightDirection, normalDirection),
				//		viewDirection)), _Shininess)) * specularTex;
				//}

				//col.rgb = (col.rgb * diffuseReflection * shadow) + (col.rgb * i.ambient + specularReflection * shadow);
				//col.rgb = (col.rgb * diffuseReflection * shadow) + (col.rgb + specularReflection * shadow);
				col.rgb = (col.rgb * diffuseReflection * shadow) + col.rgb;
				//col.rgb = col.rgb * diffuseReflection * shadow;
#endif
#ifdef LIGHT_CUTOFF
				fixed shadow = SHADOW_ATTENUATION(i);

				fixed4 transTex = tex2D(_TransTex, i.uv);
				clip(transTex.r - _Cutoff);

				fixed3 normalDirection = normalize(i.normalDir);
				fixed3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
				fixed3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				//float attenuation = 1.0;

				fixed3 diffuseReflection = _LightColor0.rgb * max(0.0, dot(normalDirection, lightDirection));

				col.rgb = (col.rgb * diffuseReflection * shadow) + col.rgb;
#endif
#ifdef MATCAP
				fixed3 mcTex = tex2D(_MatCap, i.matCapUV);
				mcTex = pow(mcTex, _MatCapContrast);
				col.rgb *= mcTex * 2.0 * _MatCapBright;
				//col.rgb *= col.rgb + i.ambient;
				col.rgb *= col.rgb + 1.0;
#endif
//#ifdef USEFOG
				UNITY_APPLY_FOG(i.fogCoord, col);
//#endif
				return col;
			}
			ENDCG
		}

		// shadow casting support
		//Pass
		//{

		//	//Shadow pass

		//	Tags{ "LightMode" = "ShadowCaster" }

		//	CGPROGRAM

		//	#pragma vertex vert
		//	#pragma fragment frag
		//	#pragma multi_compile_shadowcaster
		//	#include "UnityCG.cginc"

		//	struct v2f {
		//	V2F_SHADOW_CASTER;
		//};

		//v2f vert(appdata_base v)
		//{
		//	v2f o;
		//	TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
		//		return o;
		//}

		//float4 frag(v2f i) : SV_Target
		//{
		//	SHADOW_CASTER_FRAGMENT(i)
		//}
		//	ENDCG
		//}
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
	CustomEditor "ShaderGUI_WOT_TANK"
}