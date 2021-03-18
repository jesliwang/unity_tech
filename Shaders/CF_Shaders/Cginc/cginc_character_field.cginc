				struct appdata_t
				{
					float4 vertex		: POSITION;
					float3 normal		: NORMAL;
					float2 texcoord 	: TEXCOORD0;
#ifdef _INSTANCING_CUSTOM
					float4 uv2			: TEXCOORD1;
#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				struct v2f
				{
					float4 pos		: SV_POSITION;
					float2 uv		: TEXCOORD0;
					float2 cap		: TEXCOORD1;
#ifdef WORLD_CUSTOM_FOG
					float4 customFog : TEXCOORD2;
#endif

#ifdef PREVIEW_SELF_SHADOW
					LIGHTING_COORDS(3, 4)
#endif
					UNITY_FOG_COORDS(5)
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				float4 _Color;
				sampler2D _MainTex;
				sampler2D _MatCap;

				half4 _G_CustomAmbientColor;
				//half4 _G_AmbientColor;
				//half  _G_AmbientStrenth;
				half  _G_LightStrenth;
				//half2 _G_FieldDarkValue;
#ifdef INFRARED_RAY
				half _Temperature;
#endif
				half3 _G_DayNightLightColor;
				half  _G_DayNightLightIntensity;
				//float2 _G_DayNightCurrentInfo;
				float  _G_DayNightCurrentTime;

#ifdef _INSTANCING_CUSTOM
				half _AnimAll;
				sampler2D _AnimMap;
				float4 _AnimMap_TexelSize;//x == 1/width
				UNITY_INSTANCING_BUFFER_START(Props)
					UNITY_DEFINE_INSTANCED_PROP(float, _ScaleFade)

					UNITY_DEFINE_INSTANCED_PROP(float, _AnimStart)
					UNITY_DEFINE_INSTANCED_PROP(float, _AnimEnd)
					UNITY_DEFINE_INSTANCED_PROP(float, _AnimOff)
					UNITY_DEFINE_INSTANCED_PROP(float, _Speed)

					UNITY_DEFINE_INSTANCED_PROP(float, _LastFrameFreez)
					UNITY_DEFINE_INSTANCED_PROP(float, _TimeInput)

					#ifdef _INSTANCING_BLEND
						UNITY_DEFINE_INSTANCED_PROP(float, _OldTimeInput)
						//UNITY_DEFINE_INSTANCED_PROP(float, _OldLastFrameFreez)
						UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimStart)
						UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimEnd)
						UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimOff)
						UNITY_DEFINE_INSTANCED_PROP(float, _MotionBlendOff)
						UNITY_DEFINE_INSTANCED_PROP(float, _MotionBlendTime)
					#endif
				UNITY_INSTANCING_BUFFER_END(Props)
#else
				float _ScaleFade;
#endif
			#ifdef WORLD_CUSTOM_FOG
					half4 _G_EnvCustomFogColor;
					float4 _G_EnvCustomFogSetting;
					float4 _G_EnvCustomFogHeightSetting;
			#endif

				v2f vert(appdata_t v)
				{
					UNITY_SETUP_INSTANCE_ID(v);
					float scaleFade = 1;
#ifdef _INSTANCING_CUSTOM
					scaleFade = UNITY_ACCESS_INSTANCED_PROP(Props, _ScaleFade);
					v.vertex *= scaleFade;

					float speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
					float animMap_x1 = (v.uv2.x * 3 + 0.5) * _AnimMap_TexelSize.x;
					float animMap_x2 = (v.uv2.x * 3 + 1.5) * _AnimMap_TexelSize.x;
					float animMap_x3 = (v.uv2.x * 3 + 2.5) * _AnimMap_TexelSize.x;
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
					v.vertex *= scaleFade;
					float4 pos = v.vertex;
					half3 normal = v.normal;
#endif
					
					v.vertex.xyz = pos.xyz;
					v.normal = normal;

					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
#ifdef WORLD_CUSTOM_FOG
					o.customFog = WORLD_FOG(_G_EnvCustomFogColor, _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, mul(unity_ObjectToWorld, v.vertex).xyz);
					o.customFog.a *= _G_EnvCustomFogHeightSetting.w * scaleFade;
#endif
					float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
					worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);

					o.cap.xy = worldNorm.xy * 0.5 + 0.5;

					o.pos = UnityObjectToClipPos(pos);
					o.uv = v.texcoord.xy;
					UNITY_TRANSFER_FOG(o, o.pos);
#ifdef PREVIEW_SELF_SHADOW
					TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
					
					return o;
				}

				half4 frag(v2f i) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);
					half4 tex = CUSTOM_TEXTURE_SAMPLE(_MainTex, customizedUV(i.uv)) * _Color;
					half4 cap = tex2D(_MatCap, i.cap);
					
					//half3 light = _G_DayNightLightColor * _G_DayNightLightIntensity * cap.r;// lerp(_LightColor0 * _LightStrenth, _G_DayNightLightColor * _G_DayNightLightIntensity, _G_InTerritory);
					//half3 ambient = _G_AmbientColor * _G_AmbientStrenth;
					
					//L *= _G_DayNightLightIntensity;// lerp(1, _G_DayNightLightIntensity, _G_InTerritory);
					
					//ambient *= 0;// lerp(1, _G_DayNightLightIntensity, _G_InTerritory);
					float L = lerp(_G_CustomAmbientColor, _G_DayNightLightColor * _G_DayNightLightIntensity, cap.r);;
					//tex.rgb *= lerp(_G_CustomAmbientColor, light, cap.r);
					tex.rgb *= L;
					cap *= lerp(1.65, 1.2, _G_InTerritory);
					#ifdef PREVIEW_SELF_SHADOW
					tex.rgb *= max(0.6, LIGHT_ATTENUATION(i));// lerp(1, max(0.6, LIGHT_ATTENUATION(i)), i.worldPos.w);
					#endif
					#ifndef _USE_CROSSFADE
						#ifdef INFRARED_RAY
							tex.rgb += saturate((L + _Temperature)) * 0.2;// *_G_DayNightCurrentInfo.y;
						#endif
					#endif

			#ifdef WORLD_CUSTOM_FOG
					tex.rgb = lerp(tex.rgb, i.customFog.rgb, i.customFog.a);
			#endif
					
#ifdef SIL_COLOR
					tex *= half4(1, 2, 3, 1);
#else
					tex *= cap * 2;
#endif
					UNITY_APPLY_FOG(i.fogCoord, tex);
					return tex;
				}