Shader "WOT/Background/WOT_Road"
{
    Properties
    {
        _MainTex("Texture A", 2D) = "white" {}
		_X_Tile("X Tile", float) = 1
		[NoScaleOffset]_RoadMask("Road Mask(A UV)", 2D) = "white" {}
		[NoScaleOffset]_MainTexMask("Texture A Mask", 2D) = "white" {}


		//Blending texture Add
		_BrendTex("Texture B", 2D) = "white" {}
		[NoScaleOffset]_BrendMask("Texture B Mask", 2D) = "white" {}

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
		/*[NoScaleOffset]*/_FoamTex_A("Foam Texture", 2D) = "white" {}
		/*[NoScaleOffset]*/_WaveFoamMask("Wave Foam Mask", 2D) = "white" {}
		_Wave_Speed("Wave Speed", Float) = 0

		[Space(10)]
		[KeywordEnum(2Sides, Back, Front)]
		_Cull("Culling" , Int) = 2
		[Toggle]
		_IsZWrite("ZWrite" , Int) = 0
    }


    SubShader
    {
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "LightMode" = "ForwardBase"}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull[_Cull]
		Fog {mode off}
		ZWrite[_IsZWrite]
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			//#pragma multi_compile_fog

			#pragma shader_feature ROAD
			#pragma shader_feature RIVER
			#pragma shader_feature BLENDINGTEX
			#pragma shader_feature WAVE

            #include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			
			//Global변수 ( GameMain.cs )
			uniform fixed _GG_SeamlessAlpha;

			#if ROAD
				sampler2D _MainTex;
				fixed4 _MainTex_ST;
				sampler2D _RoadMask;
				fixed4 _RoadMask_ST;
				sampler2D _MainTexMask;
				fixed4 _MainTexMask_ST;
				fixed _X_Tile;
			#endif
			
			#if BLENDINGTEX
				sampler2D _MainTex;
				fixed4 _MainTex_ST;
				sampler2D _RoadMask;
				fixed4 _RoadMask_ST;
				sampler2D _MainTexMask;
				fixed4 _MainTexMask_ST;
				fixed _X_Tile;

				sampler2D _BrendTex;
				sampler2D _BrendMask;
				fixed4 _BrendTex_ST;
				fixed4 _BrendMask_ST;
			#endif

				 
			#if RIVER
				sampler2D _MainTex;
				fixed4 _MainTex_ST;
				sampler2D _RoadMask;
				fixed4 _RoadMask_ST;
				sampler2D _MainTexMask;
				fixed4 _MainTexMask_ST;
				fixed _X_Tile;

				uniform fixed3 _RiverColor;
				uniform fixed _RiverfloorAlpha;
				uniform fixed _RiverReflact;
				uniform fixed _RiverSpecularRange;
				uniform fixed4 _RiverSpecularColor;

				uniform sampler2D _RiverNormalMap_A;
				uniform fixed4 _RiverNormalMap_A_ST;

				uniform float _RiverNormalMap_A_Time_V;

				uniform sampler2D _RiverNormalMap_B;
				uniform fixed4 _RiverNormalMap_B_ST;

				uniform float _RiverNormalMap_B_Time_V;
			#endif

			#if WAVE
				sampler2D _MainTex;
				fixed4 _MainTex_ST;
				sampler2D _MainTexMask;
				fixed4 _MainTexMask_ST;
				fixed _X_Tile;

				uniform sampler2D _FoamTex_A;
				uniform sampler2D _WaveFoamMask;

				uniform fixed4 _FoamTex_A_ST;
				uniform fixed4 _WaveFoamMask_ST;

				uniform fixed _Wave_Speed;
			#endif

            struct appdata
            {
                float4 vertex : POSITION;
				//fixed3 Ambient : COLOR0;

				#if ROAD
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
				#endif
				
				
				#if BLENDINGTEX
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float2 texcoord2 : TEXCOORD2;
				#endif


				#if RIVER
					fixed3 normal : NORMAL;
					fixed4 tangent : TANGENT;
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
				//fixed3 Ambient : COLOR0;
				

				#if ROAD
					float2 uv : TEXCOORD0;
					float2 uv1 :TEXCOORD1;
					LIGHTING_COORDS(2, 3)
					//UNITY_FOG_COORDS(4)
				#endif	
				

				#if BLENDINGTEX
					float2 uv : TEXCOORD0;
					float2 uv1 :TEXCOORD1;
					float2 uv2 : TEXCOORD2;
					LIGHTING_COORDS(3, 4)
					//UNITY_FOG_COORDS(5)
				#endif
			
				#if RIVER
					float2 uv : TEXCOORD0;
					float2 uv1 :TEXCOORD1;
					float4 uv2 : TEXCOORD2;
					fixed3 normalDir : TEXCOORD3;
					fixed3 tangentDir : TEXCOORD4;
					fixed3 bitangentDir : TEXCOORD5;
					fixed4 posWorld : TEXCOORD6;
					LIGHTING_COORDS(7, 8)
					//UNITY_FOG_COORDS(9)
				#endif

				#if WAVE
					float2 uv : TEXCOORD0;
					float2 uv1 :TEXCOORD1;
					float2 uv2 : TEXCOORD2;
					float2 uv3 : TEXCOORD3;
					LIGHTING_COORDS(4, 5)
					//UNITY_FOG_COORDS(6)
				#endif

				
                float4 vertex : SV_POSITION;
				//UNITY_FOG_COORDS(1)
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				#if ROAD
					o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
					o.uv.x *= _X_Tile;
					o.uv1 = TRANSFORM_TEX(v.texcoord1, _MainTexMask);
				#endif
			

				#if BLENDINGTEX
					o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
					o.uv.x *= _X_Tile;
					o.uv1 = TRANSFORM_TEX(v.texcoord1, _MainTexMask);
					o.uv2 = TRANSFORM_TEX(v.texcoord2, _BrendMask);
				#endif


					 
				#if RIVER
					o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
					o.uv.x *= _X_Tile;
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
					o.normalDir = UnityObjectToWorldNormal(v.normal);
					o.tangentDir = normalize(mul(unity_ObjectToWorld, fixed4(v.tangent.xyz, 0.0)).xyz);
					o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				#endif


				#if WAVE
					o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
					o.uv.x *= _X_Tile;
					o.uv1 = TRANSFORM_TEX(v.texcoord1, _MainTexMask);
					o.uv2.xy = TRANSFORM_TEX(v.texcoord2.xy, _FoamTex_A);
					o.uv3 = TRANSFORM_TEX(v.texcoord3, _WaveFoamMask);
					float WV = fmod(_Time * _Wave_Speed, 1);
					o.uv3 = (o.uv3 + float2(WV, 0)) /** _RiverNormalMap_A_Scale*/;
				#endif

				//o.Ambient = UNITY_LIGHTMODEL_AMBIENT;



				//UNITY_TRANSFER_FOG(o,o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				//fixed3 Ambient = /*_LightColor0.xyz **/ i.Ambient;

				//POAD 1
				#if ROAD
					fixed3 TexA = tex2D(_MainTex, i.uv);
					//fixed MainTexMask = tex2D(_MainTexMask, i.uv1).r;
					fixed MainTexMask = tex2D(_MainTexMask, i.uv1).r * tex2D(_RoadMask, i.uv).r;
				#endif


				//BLENDTEX
				#if BLENDINGTEX
					fixed3 TexA = tex2D(_MainTex, i.uv);

					fixed3 TexB = tex2D(_BrendTex, i.uv);
					fixed Mask = tex2D(_BrendMask, i.uv2).r;

					//fixed MainTexMask = tex2D(_MainTexMask, i.uv1).r;
					fixed MainTexMask = tex2D(_MainTexMask, i.uv1).r * tex2D(_RoadMask, i.uv).r;
					
					fixed3 BlendTex = lerp(TexA, TexB, Mask);
				#endif


				#if RIVER
					//Lighting
					fixed3 RiverNormalMap_A = UnpackNormal(tex2D(_RiverNormalMap_A, i.uv2.xy));
					fixed3 RiverNormalMap_B = UnpackNormal(tex2D(_RiverNormalMap_A, i.uv2.zw));
					fixed3 RiverNormal = lerp(RiverNormalMap_A, RiverNormalMap_B, 0.5);

					fixed3 Riverfloor = tex2D(_MainTex, lerp(i.uv, RiverNormal.rg, _RiverReflact));

					fixed3x3 tangentTransform = fixed3x3(i.tangentDir, i.bitangentDir, normalize(i.normalDir));
					fixed3 NormalDirection = normalize(mul(RiverNormal, tangentTransform));
					fixed3 LightDirection = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					fixed NdotL = saturate(dot(NormalDirection, LightDirection) * 0.5 + 0.5);
					fixed3 halfDirection = normalize(viewDirection + LightDirection);

					//River Specular Lighting
					float NH = saturate(max(0, dot(NormalDirection, halfDirection)));
					float Specular = saturate(pow(NH, _RiverSpecularRange * 5));

					//RiverColor
					//TexA = tex2D(_MainTex, i.uv);
					fixed MainTexMask = tex2D(_MainTexMask, i.uv1).r * tex2D(_RoadMask, i.uv).r;

					fixed3 River = (Riverfloor * _RiverfloorAlpha)  + (NdotL *_RiverColor.rgb);
					River += (Specular * _RiverSpecularColor);
				#endif

				#if WAVE
					fixed3 TexA = tex2D(_MainTex, i.uv);
					fixed MainTexMask = tex2D(_MainTexMask, i.uv1).r;
					fixed3 FoamTex = tex2D(_FoamTex_A, i.uv2);
					fixed WaveFoamMask = tex2D(_WaveFoamMask, i.uv3).r;
				#endif
				 


				//FinalColor-------------------------------------------------------------
				fixed4 FinalColor = fixed4(1,1,1,1);
			
				#if ROAD
					//FinalColor = fixed4(TexA.rgb * Ambient, MainTexMask);
					FinalColor = fixed4(TexA.rgb, MainTexMask);
				#endif


				#if BLENDINGTEX
					//FinalColor = fixed4(BlendTex.rgb * Ambient, MainTexMask);
					FinalColor = fixed4(BlendTex.rgb, MainTexMask);
				#endif


				#if RIVER
					//FinalColor = fixed4(River * Ambient, MainTexMask);
					FinalColor = fixed4(River, MainTexMask);
				#endif


				#if WAVE
					//FinalColor = fixed4((TexA + FoamTex) * Ambient, WaveFoamMask * MainTexMask * FoamTex.r);
					FinalColor = fixed4((TexA + FoamTex), WaveFoamMask * MainTexMask * FoamTex.r);
				#endif

				//UNITY_APPLY_FOG(i.fogCoord, FinalColor);
					FinalColor.a *= (1 - _GG_SeamlessAlpha);

                return FinalColor;
            }
            ENDCG
        }
    }
	CustomEditor "WOT_RoadEditor"
}
