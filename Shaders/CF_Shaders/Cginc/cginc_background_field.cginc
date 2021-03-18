				//float4		_Color;
				sampler2D	_MainTex;
				float4		_MainTex_ST;
				sampler2D	_MaskTex;
				float4 _G_CustomAmbientColor;
				float4 _G_DayNightLightColor;
				float  _G_DayNightLightIntensity;
				//fixed		_IsGray;
				#ifdef _ALPHA_CUTOFF
					float		_Cutoff;
				#endif
#ifdef _FLAG
			#ifndef _UV_ATLAS
				UNITY_DECLARE_TEX2DARRAY(_MainTexArr);
			#endif	
				half _Curves, _gravity, _damping, _windSpeed;
#endif
				#ifdef WORLD_CUSTOM_FOG
						float4 _G_EnvCustomFogColor;
						float4 _G_EnvCustomFogSetting;
						float4 _G_EnvCustomFogHeightSetting;
				#endif

				float _PreventCamPenetrating;
				float _LOD_ScaleMode;
				float _LodScale_Max, _LodScale_Min;
				float _LodChangeDelay;
				float4 _LodScale_LockAxis_Min, _LodScale_LockAxis_Max;
				float4 _LodMovePosition;
				float3 _G_FieldShadowColor;
#ifdef _CUSTOM_FAST_REFLECT
				samplerCUBE _ReflectMap;
				sampler2D _ReflectMask;
				float _ReflectStrength;
#endif

#ifdef GRAPHITY
				UNITY_DECLARE_TEX2DARRAY(_GraphityTexArr);
				float _Graphity_Offset_U, _Graphity_Offset_V;
				float _Graphity_Scale_U, _Graphity_Scale_V;
#endif

#ifdef _WAITING_FOR_CREATION
				sampler2D	_G_WatingForCreationTex;
				float4 _G_WatingForCreationColor;
#endif

				UNITY_INSTANCING_BUFFER_START(Props)
#ifdef _FLAG
				#ifdef _UV_ATLAS
					UNITY_DEFINE_INSTANCED_PROP(float4, _FlagUVRect)
				#else
					UNITY_DEFINE_INSTANCED_PROP(float, _FlagIndex)
				#endif
#endif
#ifdef LD_GUILD_COLOR
					UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
#endif
#ifdef GRAPHITY
					UNITY_DEFINE_INSTANCED_PROP(float, _Graphity_Index)
#endif
				UNITY_INSTANCING_BUFFER_END(Props)


				struct appdata_t
				{
					float4 vertex		: POSITION;
					float4 color		: COLOR0;
					float2 texcoord 	: TEXCOORD0;
					float3 normal		: NORMAL;
#ifdef _INSTANCING_CUSTOM
					//uv3 required for instancing
					float2 uv3		: TEXCOORD3;
#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				
				struct v2f
				{
					float4 pos			: SV_POSITION;
					float4 diff			: COLOR0;
					#ifdef LD_GUILD_COLOR
					float4 guildColor	: COLOR1;
					#endif

					#if defined (_FLAG) && !defined (_UV_ATLAS)
						float3 uv			: TEXCOORD0;
					#else
						float2 uv			: TEXCOORD0;
					#endif
					#ifdef GRAPHITY
						float4 GraphityUV	: TEXCOORD1;
					#endif
					float4 worldPos		: TEXCOORD2;
#ifdef _WAITING_FOR_CREATION
					float4 uvFlow		: TEXCOORD3;
					float distort		: TEXCOORD4;
					float4 scrPos		: TEXCOORD5;
#endif

	#ifdef _CUSTOM_FAST_REFLECT
					float3 worldRefl : TEXCOORD6;
	#endif

#ifdef WORLD_CUSTOM_FOG
				#ifdef _VERTEX_FOG
					float4 customFog : TEXCOORD7;
				#endif
#endif
					#ifdef PREVIEW_SELF_SHADOW
						LIGHTING_COORDS(8, 9)
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				v2f vert(appdata_t v)
				{
					
					UNITY_SETUP_INSTANCE_ID(v);
#ifdef _FORCE_SCALE_CROSSFADE
	#ifdef _USE_CROSSFADE
					#ifdef FIRST_CROSSFADE
						v.vertex.xyz *= CUSTOM_CROSSFADE(_G_CrossfadeTime.z, max(max(_G_CrossfadeMode.x, _G_CrossfadeMode.y), _G_CrossfadeMode.z));
					#endif
					#ifdef CITY_CROSSFADE
						v.vertex.xyz *= CUSTOM_CROSSFADE(_G_CrossfadeTime.w, _G_CrossfadeMode.w);
					#endif
	#endif
#endif

#ifdef _FLAG
					float xPos = v.texcoord.x * 0.5;
					float yoffset = xPos - _Time.x * _windSpeed; // Animates Root of Flag as Well,wind speed
					yoffset = (yoffset * 2) - 1;
					yoffset = yoffset * 1.57079633 * _Curves;	//one cycle of trinometric function, curves controll
					yoffset = cos(yoffset * 2) * xPos * _damping + _gravity * xPos * xPos;
					v.vertex.yz += float2(yoffset, -yoffset) * v.color.rr;
#endif
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);

#ifdef _INSTANCING_CUSTOM
					float4 vertex = v.vertex;
					float2 uv3 = v.uv3;
					INSTANCE_DATA_DECODE_CUSTOM
					o.pos = mul(UNITY_MATRIX_VP, posWorld);
					#if defined (_WAITING_FOR_CREATION) || defined (WORLD_CUSTOM_FOG)
						o.worldPos.xyz = posWorld.xyz;
					#endif
#else
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos.xyz = mul(unity_ObjectToWorld, v.vertex).xyz;
#endif 
#ifdef LD_GUILD_COLOR
					o.guildColor = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
#endif
					
					float3 worldN = UnityObjectToWorldNormal(v.normal);
#ifdef _FLAG
					#ifdef _UV_ATLAS
						float4 rect = UNITY_ACCESS_INSTANCED_PROP(Props, _FlagUVRect);
						o.uv.xy = v.texcoord.xy * rect.zw + rect.xy;
					#else
						o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
						o.uv.z = UNITY_ACCESS_INSTANCED_PROP(Props, _FlagIndex);
					#endif
#else
					o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
					#ifdef GRAPHITY
						#ifdef _USER_BUILDING
							o.GraphityUV = float4((v.vertex.xz + float2(v.vertex.y + _Graphity_Offset_U, -_Graphity_Offset_V)) * float2(_Graphity_Scale_U, _Graphity_Scale_V), UNITY_ACCESS_INSTANCED_PROP(Props, _Graphity_Index), min(0.1, worldN.y));
						#else
							o.GraphityUV = float4((o.worldPos.zy + float2(-o.worldPos.x + _Graphity_Offset_U, -_Graphity_Offset_V)) * float2(_Graphity_Scale_U, _Graphity_Scale_V), UNITY_ACCESS_INSTANCED_PROP(Props, _Graphity_Index), min(0.1, worldN.y));
						#endif
					#endif
#endif
					
#ifdef _CUSTOM_FAST_REFLECT
					float3 viewDir = WorldSpaceViewDir(v.vertex);
					o.worldRefl = reflect(-viewDir, worldN);
#endif 

#ifdef _WAITING_FOR_CREATION
					o.uvFlow.xy = o.uv.xy * 3 + _Time.x * 2;
					o.uvFlow.zw = o.uv.xy + _Time.x * float2(0.5, 0.5);
					o.worldPos.w = pow(dot(normalize(_WorldSpaceCameraPos.xyz - o.worldPos.xyz), worldN) , 3);

					o.distort = 0.03 * (step(0.8, sin(_Time[1] * 1.5 + (v.vertex.x + v.vertex.y))) * step(0.99, sin(_Time[1] * /*_GlitchSpeed*/ 20)));
					o.scrPos = ComputeScreenPos(o.pos);
#endif
					
#ifdef _FLAG
					o.diff.rgb = lerp(0.5, 0.3 + (yoffset) * 12 * (1 - v.texcoord.x), saturate(v.color.r));
					o.diff.a = 1;
#else
					float nl = dot(worldN, _WorldSpaceLightPos0.xyz);
					o.diff = lerp(_G_CustomAmbientColor, _G_DayNightLightColor * _G_DayNightLightIntensity, nl);
					o.diff.a = v.color.r;
#endif
#ifdef WORLD_CUSTOM_FOG
				#ifdef _VERTEX_FOG
					o.customFog = WORLD_FOG(_G_EnvCustomFogColor, _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, o.worldPos.xyz);
					o.customFog.a *= _G_EnvCustomFogHeightSetting.w;
				#endif
#endif
#ifdef PREVIEW_SELF_SHADOW
					TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
					return o;
				}
				
				fixed4 frag(v2f i) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);
					float4 finalColor = float4(0, 0, 0, 0);
#ifdef _FLAG
					#ifdef _UV_ATLAS
						finalColor = CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(i.uv.xy)); 
					#else
						finalColor = UNITY_SAMPLE_TEX2DARRAY(_MainTexArr, float3(i.uv.xyz));
					#endif
#else
					float4 mainTex = CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(i.uv.xy));
					float3 maskTex = float3(0,0,0);
					#ifdef LD_USE_MASK
						maskTex = CUSTOM_TEXTURE_SAMPLE(_MaskTex, customizedUV(i.uv.xy));
						finalColor = fixed4(mainTex.rgb, mainTex.a * maskTex.r);
					#else
						finalColor = mainTex;
					#endif

					#ifdef LD_GUILD_COLOR
						finalColor *= lerp(1, i.guildColor * 2, maskTex.r);
					#endif

					#ifdef GRAPHITY
						fixed4 cx = UNITY_SAMPLE_TEX2DARRAY(_GraphityTexArr, i.GraphityUV.xyz);
						#ifdef _USER_BUILDING
							finalColor.rgb = lerp(finalColor.rgb, cx.rgb, min(0.5, maskTex.b) * cx.a);
						#else
							finalColor.rgb *= lerp(1, cx.rgb + max(0, i.GraphityUV.w), cx.a * maskTex.b);
						#endif
					#endif
#endif
#ifdef _WAITING_FOR_CREATION
						finalColor.rgb += i.distort;
					
						float lineSize = _ScreenParams.y * 0.0022;
						float displacement = (_Time[1] * 150) % _ScreenParams.y;
						float ps = (i.scrPos.y * _ScreenParams.y / max(0.0001, i.scrPos.w));
						finalColor.rgb = lerp(float3(0,0.3,0.8), finalColor.rgb, saturate((ps / max(0.0001, floor(lineSize))) % 2));
					
						float3 creationFX1 = tex2D(_G_WatingForCreationTex, i.uvFlow.xy).rgb;
						float3 creationFX2 = tex2D(_G_WatingForCreationTex, i.uvFlow.zw).rgb;
						float3 creationFX = saturate(creationFX1 + creationFX2);
						finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb + creationFX * _G_WatingForCreationColor.rgb * 2, saturate(i.worldPos.w));
						finalColor.a = max(0.3, finalColor.b * 0.5);
#else
						finalColor.rgb *= i.diff.rgb;
#endif
						//finalColor.rgb *= L;
#ifdef _CUSTOM_FAST_REFLECT
						float4 refl = texCUBE(_ReflectMap, i.worldRefl);
						float4 refl_mask = tex2D(_ReflectMask, i.uv.xy);
						finalColor.rgb = lerp(finalColor, refl, refl_mask * _ReflectStrength);
#endif
#ifdef _FLAG
					finalColor.rgb *= 2;
#endif
#ifndef _FORCE_SCALE_CROSSFADE
					float crossfade = 1;
			#ifdef _USE_CROSSFADE
					#ifdef FIRST_CROSSFADE
						crossfade = CUSTOM_CROSSFADE(_G_CrossfadeTime.z, max(max(_G_CrossfadeMode.x, _G_CrossfadeMode.y), _G_CrossfadeMode.z));
					#endif	
					#ifdef CITY_CROSSFADE
						crossfade = CUSTOM_CROSSFADE(_G_CrossfadeTime.w, _G_CrossfadeMode.w);
					#endif
					finalColor.a *= crossfade;
			#endif
					#ifdef _ALPHA_CUTOFF
						if (crossfade == 1)
						{
							clip(finalColor.a - _Cutoff);
						}
					#endif
#endif

#ifdef PREVIEW_SELF_SHADOW
					float shadow = lerp(_G_FieldShadowColor, 1, LIGHT_ATTENUATION(i));
						finalColor.rgb *= shadow;
#endif
					#ifdef WORLD_CUSTOM_FOG
						#ifdef _VERTEX_FOG
							//finalColor.rgb = lerp(finalColor.rgb, i.customFog.rgb, i.customFog.a);
							//float3 fogCol = i.customFog.rgb * i.customFog.a;
							finalColor.rgb = lerp(finalColor.rgb, i.customFog.rgb, i.customFog.a);
						#else
							finalColor.rgb = WORLD_FOG(finalColor, _G_EnvCustomFogColor, _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, i.worldPos.xyz).rgb;
						#endif
					#endif
					return finalColor;
				}