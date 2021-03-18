
				uniform sampler2D _MainTex;
				
				struct appdata
				{
					float4 vertex : POSITION;
					float3 color : COLOR;
					float2 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float3 worldPos		: TEXCOORD1;
#ifdef WORLD_CUSTOM_FOG
	#ifdef _VERTEX_FOG
					float4 customFog	: TEXCOORD2;
	#endif
#endif
					UNITY_FOG_COORDS(3)
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				float4 _wind_dir;
				float _wind_size;
				float _tree_sway_speed;
				float _tree_sway_disp;
				float _leaves_wiggle_disp;
				float _leaves_wiggle_speed;
				float _branches_disp;
				float _tree_sway_stutter;
				float _tree_sway_stutter_influence;
				//float _r_influence;
				float _h_influence;
				float _Cutoff;
#ifdef WORLD_CUSTOM_FOG
				float4 _G_EnvCustomFogColor;
				float4 _G_EnvCustomFogSetting;
				float4 _G_EnvCustomFogHeightSetting;
#endif
				UNITY_INSTANCING_BUFFER_START(Props)
					UNITY_DEFINE_INSTANCED_PROP(float4, _Color0)
					UNITY_DEFINE_INSTANCED_PROP(float4, _Color1)
					UNITY_DEFINE_INSTANCED_PROP(float4, _Scaling)
					UNITY_DEFINE_INSTANCED_PROP(float4, _UV_Rect)
				UNITY_INSTANCING_BUFFER_END(Props)

				v2f vert(appdata v)
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					#ifdef _WIND

						#ifdef _LEAF
							float2 wave = (cos(_Time.z * _tree_sway_speed + (o.worldPos.xz / _wind_size) + (sin(_Time.z * _tree_sway_stutter * _tree_sway_speed + (o.worldPos.xz / _wind_size)) * _tree_sway_stutter_influence)) + 1) / 2 * _tree_sway_disp * _wind_dir.xz * (v.vertex.y / 10) +
										  cos(_Time.w * v.vertex.xz * _leaves_wiggle_speed + (o.worldPos.x / _wind_size)) * _leaves_wiggle_disp * _wind_dir.xz * _h_influence;

							v.vertex.xz += wave;
						#endif

						#ifdef _BARK
							v.vertex.xz += sin(_Time.w * _tree_sway_speed + _wind_dir.xz + (o.worldPos.z / _wind_size)) * _branches_disp * _h_influence;
						#endif
					#endif

					#ifdef _BILLBOARD
						float scale = length(float3 (unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x));
						o.vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0)) + float4(v.vertex.x, v.vertex.y, v.vertex.z, 1) * UNITY_ACCESS_INSTANCED_PROP(Props, _Scaling));
					#else
						o.vertex = UnityObjectToClipPos(v.vertex);
					#endif
					#ifdef _UV_ATLAS
						float4 rect = UNITY_ACCESS_INSTANCED_PROP(Props, _UV_Rect);
						o.texcoord.xy = v.texcoord.xy * rect.zw + rect.xy;
					#else
						o.texcoord.xy = v.texcoord.xy;
					#endif
					float randomRange = fmod(unity_ObjectToWorld._m23, 1); //x:_m03, y:_m13, z:_m23
					o.color = lerp(UNITY_ACCESS_INSTANCED_PROP(Props, _Color0), UNITY_ACCESS_INSTANCED_PROP(Props, _Color1), randomRange);
#ifdef WORLD_CUSTOM_FOG
				#ifdef _VERTEX_FOG
					o.customFog = WORLD_FOG(_G_EnvCustomFogColor, _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, o.worldPos.xyz);
					o.customFog.a *= (_G_EnvCustomFogHeightSetting.w + 0.1);
				#endif
#endif
					UNITY_TRANSFER_FOG(o, o.vertex);
					return o;
				}

				float4 frag(v2f i) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);
					float4 col = tex2D(_MainTex, float2(i.texcoord.xy));
#ifdef _LEAF
					col.rgb *= lerp(1, i.color.rgb * 2, col.r);
#endif
#ifdef _BARK
					clip(col.a - _Cutoff);
#endif

			#ifdef WORLD_CUSTOM_FOG
				#ifdef _VERTEX_FOG
					col.rgb = lerp(col.rgb, i.customFog.rgb, i.customFog.a);
				#else
					col.rgb = WORLD_FOG(col, _G_EnvCustomFogColor, _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, i.worldPos.xyz).rgb;
				#endif
			#endif
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
