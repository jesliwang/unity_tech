Shader "CV/Background/CV_Background_Road"
{
    Properties
    {
		[Enum]_RoadMode("Road Mode", Float) = 0

		_X_Tile("X Tile", float) = 1
        _MainTex("Texture1 (RGB)", 2D) = "white" {}
		[NoScaleOffset]_MainTexMask("Texture1 Mask (R)", 2D) = "white" {}
		_RoadMask("Road Mask (R)", 2D) = "white" {}

		//Blending texture Add
		_blendTex("Texture2 (RGB)", 2D) = "white" {}
		[NoScaleOffset]_blendMask("Blend Mask (R)", 2D) = "white" {}

		//RIVER
		[Space(20)]
		//RIVER
		/*[NoScaleOffset]*/_RiverNormalMap_A("River Normal A", 2D) = "bump" {}
		/*[NoScaleOffset]*/_RiverNormalMap_B("River Normal B", 2D) = "bump" {}
		_RiverColor("River Color", Color) = (1,1,1,1)
		_RiverfloorAlpha("River floor Alpha", Range(0,1)) = 1
		_RiverReflact("River Reflact", Range(0,1)) = 0.5
		_RiverSpecularColor("River SpecularColor", Color) = (1,1,1,1)
		_RiverSpecularRange("River Specular Range", Range(1, 100)) = 50

		[Space(10)]
		_RiverNormalMap_A_Time_V("River Normal A Speed", Float) = 0

		[Space(10)]
		_RiverNormalMap_B_Time_V("River Normal B Speed", Float) = 0
			 
		//Wave
		[Space(20)]
		/*[NoScaleOffset]*/_FoamTex_A("Foam Texture (RGB)", 2D) = "white" {}
		[NoScaleOffset]_WaveFoamMask("Wave Foam Mask (R)", 2D) = "white" {}
		_Wave_Speed("Wave Speed", Float) = 0

		[Space(10)]
		[KeywordEnum(2Sides, Back, Front)]
		_Cull("Culling" , Int) = 2
		[Toggle]
		_IsZWrite("ZWrite" , Int) = 0
    }


    SubShader
    {
		//Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "LightMode" = "ForwardBase"}
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull[_Cull]
		Fog {mode off}
		ZWrite[_IsZWrite]
        

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			//#pragma multi_compile_fog

			#pragma shader_feature ROAD1
			#pragma shader_feature RIVER
			#pragma shader_feature ROAD2
			#pragma shader_feature WAVE

			#include "Library/PackageCache/com.unity.render-pipelines.universal@7.5.3/ShaderLibrary/Core.hlsl"
			#include "Library/PackageCache/com.unity.render-pipelines.universal@7.5.3/ShaderLibrary/Lighting.hlsl"
            //#include "UnityCG.cginc"
			//#include "AutoLight.cginc"
			//#include "Lighting.cginc"
			
			
			TEXTURE2D(_RoadMask); 			SAMPLER(sampler_RoadMask);
			TEXTURE2D(_MainTex);			SAMPLER(sampler_MainTex);
			TEXTURE2D(_MainTexMask);		SAMPLER(sampler_MainTexMask);

			#if ROAD1
				//sampler2D _MainTex;
				//half4 _MainTex_ST;
				//sampler2D _MainTexMask;
				//half4 _MainTexMask_ST;
			

			#endif
			
			#if ROAD2
				//sampler2D _blendTex;
				//sampler2D _blendMask;
				//half4 _blendTex_ST;
				//half4 _blendMask_ST;
				TEXTURE2D(_blendTex);
				SAMPLER(sampler_blendTex);
				TEXTURE2D(_blendMask);
				SAMPLER(sampler_blendMask);
			#endif

				 
			#if RIVER
				//uniform half3 _RiverColor;
				//uniform half _RiverfloorAlpha;
				//uniform half _RiverReflact;
				//uniform half _RiverSpecularRange;
				//uniform half4 _RiverSpecularColor;

				//uniform sampler2D _RiverNormalMap_A;
				//uniform half4 _RiverNormalMap_A_ST;
				TEXTURE2D(_RiverNormalMap_A);
				SAMPLER(sampler_RiverNormalMap_A);



				//uniform float _RiverNormalMap_A_Time_V;

				//uniform sampler2D _RiverNormalMap_B;
				//uniform half4 _RiverNormalMap_B_ST;
				TEXTURE2D(_RiverNormalMap_B);
				SAMPLER(sampler_RiverNormalMap_B);

				//uniform float _RiverNormalMap_B_Time_V;
			#endif

			#if WAVE
				//uniform sampler2D _FoamTex_A;
				//uniform half4 _FoamTex_A_ST;
				//uniform sampler2D _WaveFoamMask;
				//uniform half4 _WaveFoamMask_ST;
				TEXTURE2D(_FoamTex_A);
				SAMPLER(sampler_FoamTex_A);
				TEXTURE2D(_WaveFoamMask);
				SAMPLER(sampler_WaveFoamMask);

				//uniform half _Wave_Speed;
			#endif


			CBUFFER_START(UnityPerMaterial)
				half4 _MainTex_ST;
				half4 _RoadMask_ST;
				half _X_Tile;
				#if ROAD2
					half4 _blendTex_ST;
					half4 _blendMask_ST;
				#endif

				#if RIVER
					uniform half3 _RiverColor;
					uniform half _RiverfloorAlpha;
					uniform half _RiverReflact;
					uniform half _RiverSpecularRange;
					uniform half4 _RiverSpecularColor;
					uniform float _RiverNormalMap_A_Time_V;
					uniform float _RiverNormalMap_B_Time_V;
					half4 _RiverNormalMap_A_ST;
					half4 _RiverNormalMap_B_ST;
				#endif

				#if WAVE
					half4 _FoamTex_A_ST;
					//half4 _WaveFoamMask_ST;
					uniform half _Wave_Speed;
				#endif

			CBUFFER_END




            struct appdata
            {
				float4 vertex : POSITION;
				//half3 Ambient : COLOR0;
				//float3 normal : NORMAL;

				#if ROAD1
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
				#endif
				
				
				#if ROAD2
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float2 texcoord2 : TEXCOORD2;
				#endif


				#if RIVER
					half3 normal : NORMAL;
					half4 tangent : TANGENT;
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float4 texcoord2 : TEXCOORD2;
				#endif

				#if WAVE
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float2 texcoord2 : TEXCOORD2;
					float2 texcoord3 : TEXCOORD3;
				#endif

			};


            struct v2f
            {
				//half3 Ambient : COLOR0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;

				#if ROAD1
					float2 uv : TEXCOORD0;
					float2 uv1 :TEXCOORD1;
					//LIGHTING_COORDS(2, 3)
					//UNITY_FOG_COORDS(4)
				#endif	
				

				#if ROAD2
					float2 uv : TEXCOORD0;
					float2 uv1 :TEXCOORD1;
					float2 uv2 : TEXCOORD2;
					//LIGHTING_COORDS(3, 4)
					//UNITY_FOG_COORDS(5)
				#endif
			
				#if RIVER
					float2 uv : TEXCOORD0;
					float2 uv1 :TEXCOORD1;
					float4 uv2 : TEXCOORD2;
					half3 normalDir : TEXCOORD3;
					half3 tangentDir : TEXCOORD4;
					half3 bitangentDir : TEXCOORD5;
					half4 posWorld : TEXCOORD6;
					//LIGHTING_COORDS(7, 8)
					//UNITY_FOG_COORDS(9)
				#endif

				#if WAVE
					float2 uv : TEXCOORD0;
					float2 uv1 :TEXCOORD1;
					float2 uv2 : TEXCOORD2;
					float2 uv3 : TEXCOORD3;
					//LIGHTING_COORDS(4, 5)
					//UNITY_FOG_COORDS(6)
				#endif
				
				//UNITY_FOG_COORDS(1)
            };


            v2f vert (appdata v)
            {
                //v2f o;
				v2f o = (v2f)o;
				
                //o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex = TransformObjectToHClip(v.vertex.xyz);

				#if ROAD1
					o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
					o.uv.x *= _X_Tile;
					o.uv1 = TRANSFORM_TEX(v.texcoord1, _RoadMask);
					//o.normal = TransformObjectToWorldNormal(v.normal);
				#endif
			

				#if ROAD2
					o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
					o.uv.x *= _X_Tile;
					o.uv1 = TRANSFORM_TEX(v.texcoord1, _RoadMask);
					o.uv2 = TRANSFORM_TEX(v.texcoord2, _blendTex);
				#endif


					 
				#if RIVER
					o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
					o.uv.x *= _X_Tile;
					//o.uv1 = TRANSFORM_TEX(v.texcoord1, _MainTexMask);
					o.uv1 = TRANSFORM_TEX(v.texcoord1, _RoadMask);

					//Normal UV A
					o.uv2.xy = TRANSFORM_TEX(v.texcoord2.xy, _RiverNormalMap_A);

					float NATV_A = fmod(_Time * _RiverNormalMap_A_Time_V, 1);
					o.uv2.xy = (o.uv2.xy + float2(0, NATV_A)) /** _RiverNormalMap_A_Scale*/;

					//Normal UV B (Offset + 1)
					o.uv2.zw = v.texcoord2.xy * (_RiverNormalMap_B_ST.xy + 1) * (_RiverNormalMap_B_ST.zw + 1);
					float NATV_B = fmod(_Time * _RiverNormalMap_B_Time_V, 1);
					o.uv2.zw = (o.uv2.zw + float2(0, NATV_B)) /** _RiverNormalMap_B_Scale*/;

					//Light
					//o.normalDir = UnityObjectToWorldNormal(v.normal);
					o.normalDir = TransformObjectToWorldNormal(v.normal);
					o.tangentDir = normalize(mul(unity_ObjectToWorld, half4(v.tangent.xyz, 0.0)).xyz);
					o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				#endif


				#if WAVE
					o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
					o.uv.x *= _X_Tile;
					o.uv1 = TRANSFORM_TEX(v.texcoord1, _RoadMask);
					o.uv2 = TRANSFORM_TEX(v.texcoord2, _FoamTex_A);
					//o.uv3 = TRANSFORM_TEX(v.texcoord3, _WaveFoamMask);
					float WV = fmod(_Time * _Wave_Speed, 1);
					o.uv2 = (o.uv2 + float2(0, WV)) /** _RiverNormalMap_A_Scale*/;
				#endif

				//o.Ambient = UNITY_LIGHTMODEL_AMBIENT;
				//float3 ambient = SampleSH(i.normal);


				//UNITY_TRANSFER_FOG(o,o.vertex);

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {

				//half3 Ambient = /*_LightColor0.xyz **/ i.Ambient;

				//float3 Ambient = SampleSH(i.normal);

				//POAD 1
				#if ROAD1
					//half3 TexA = tex2D(_MainTex, i.uv);
					half3 TexA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv).rgb;
					//half MainTexMask = tex2D(_MainTexMask, i.uv1).r;
					half MainTexMask = SAMPLE_TEXTURE2D(_MainTexMask, sampler_MainTexMask, i.uv).r * SAMPLE_TEXTURE2D(_RoadMask, sampler_RoadMask, i.uv1).r;
				#endif


				//BLENDTEX
				#if ROAD2
					//half3 TexA = tex2D(_MainTex, i.uv);
					half3 TexA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv).rgb;
					//half3 TexB = tex2D(_blendTex, i.uv);
					half3 TexB = SAMPLE_TEXTURE2D(_blendTex, sampler_blendTex, i.uv2).rgb;
					//half Mask = tex2D(_blendMask, i.uv2).r;
					half Mask = SAMPLE_TEXTURE2D(_blendMask, sampler_blendMask, i.uv2).r;

					//half MainTexMask = tex2D(_MainTexMask, i.uv1).r;
					half MainTexMask = SAMPLE_TEXTURE2D(_MainTexMask, sampler_MainTexMask, i.uv).r* SAMPLE_TEXTURE2D(_RoadMask, sampler_RoadMask, i.uv1).r;
					
					half3 BlendTex = lerp(TexA, TexB, Mask);
				#endif


				#if RIVER
					//Lighting
					half3 RiverNormalMap_A = UnpackNormal(SAMPLE_TEXTURE2D(_RiverNormalMap_A, sampler_RiverNormalMap_A, i.uv2.xy));
					half3 RiverNormalMap_B = UnpackNormal(SAMPLE_TEXTURE2D(_RiverNormalMap_A, sampler_RiverNormalMap_A, i.uv2.zw));
					half3 RiverNormal = lerp(RiverNormalMap_A, RiverNormalMap_B, 0.5);
					//half3 RiverNormal = RiverNormalMap_A;
					//half3 RiverNormal = float3(RiverNormalMap_A.r * RiverNormalMap_B.r, RiverNormalMap_A.g*RiverNormalMap_B.g,
					//							RiverNormalMap_A.b * RiverNormalMap_B.b);

					half3 Riverfloor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, lerp(i.uv, RiverNormal.rg, _RiverReflact));

					half3x3 tangentTransform = half3x3(i.tangentDir, i.bitangentDir, normalize(i.normalDir));
					half3 NormalDirection = normalize(mul(RiverNormal, tangentTransform));
					//half3 LightDirection = normalize(_WorldSpaceLightPos0.xyz);
					half3 LightDirection = normalize(_MainLightPosition.xyz);
					half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					half NdotL = saturate(dot(NormalDirection, LightDirection) * 0.5 + 0.5);
					half3 halfDirection = normalize(viewDirection + LightDirection);

					//River Specular Lighting
					float NH = saturate(max(0, dot(NormalDirection, halfDirection)));
					float Specular = saturate(pow(NH, _RiverSpecularRange * 5));

					//RiverColor
					//TexA = tex2D(_MainTex, i.uv);
					half3 TexA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv).rgb;
					//half MainTexMask = tex2D(_MainTexMask, i.uv1).r;
					half MainTexMask = SAMPLE_TEXTURE2D(_MainTexMask, sampler_MainTexMask, i.uv).r* SAMPLE_TEXTURE2D(_RoadMask, sampler_RoadMask, i.uv1).r;;

					//half3 River = (Riverfloor * _RiverfloorAlpha)  + (NdotL *_RiverColor.rgb);
					half3 River = lerp(_RiverColor, Riverfloor, _RiverfloorAlpha);
					River += (Specular * _RiverSpecularColor);
				#endif

				#if WAVE
					//half3 TexA = tex2D(_MainTex, i.uv);
					half3 TexA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv).rgb;
					//half MainTexMask = tex2D(_MainTexMask, i.uv1).r;
					half MainTexMask = SAMPLE_TEXTURE2D(_MainTexMask, sampler_MainTexMask, i.uv).r;
					half RoadMask = SAMPLE_TEXTURE2D(_RoadMask, sampler_RoadMask, i.uv1).r;
					half3 FoamTex = SAMPLE_TEXTURE2D(_FoamTex_A, sampler_FoamTex_A, i.uv2);
					half WaveFoamMask = SAMPLE_TEXTURE2D(_WaveFoamMask, sampler_WaveFoamMask,i.uv2).r;
				#endif
				 


				//FinalColor-------------------------------------------------------------
				half4 FinalColor = half4(1,1,1,1);
			
				#if ROAD1
					FinalColor = half4(TexA.rgb /** Ambient*/, MainTexMask);
				#endif


				#if ROAD2
					FinalColor = half4(BlendTex.rgb/* * Ambient*/, MainTexMask);
				#endif


				#if RIVER
					FinalColor = half4(River/* * Ambient*/, MainTexMask);
				#endif


				#if WAVE
					//FinalColor = half4((TexA + FoamTex) /** Ambient*/, RoadMask * WaveFoamMask * MainTexMask * FoamTex.r);
					FinalColor = half4(FoamTex /** Ambient*/, RoadMask * WaveFoamMask);
				#endif

				//UNITY_APPLY_FOG(i.fogCoord, FinalColor);

                return FinalColor;
            }
            ENDHLSL
        }
    }
	CustomEditor "WOT_RoadEditor1"
	//CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.CV_Background_Road"
}
