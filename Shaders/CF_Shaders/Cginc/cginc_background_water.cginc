            struct v2f {
                float4 pos			: SV_POSITION;
                half4 uv0			: TEXCOORD0;
				half2 uv1			: TEXCOORD1;
#ifdef _CUSTOM_FAST_REFLECT
				half3 worldRefl : TEXCOORD2;
#endif
				float3 worldPos		: TEXCOORD3;
				//#ifndef _FIELD
				//	UNITY_FOG_COORDS(4)
				//#endif
            };

			fixed4 _G_EnvCustomFogColor;
			float4 _G_EnvCustomFogSetting;
			float4 _G_EnvCustomFogHeightSetting;
			//float _GlobalFieldCustomFogFactor_Min;
			//float _GlobalFieldCustomFogFactor_Max;

            sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _MaskTex;
            sampler2D _FlowMap;
			fixed4 _Color, _Color2, _AreaColor1, _AreaColor2;
            fixed _Speed1, _Speed2;
			//float _CustomDirection;
			//fixed2 _G_FieldDarkValue;
            half4 _MainTex_ST;
			half4 _MainTex2_ST;
			half4 _FlowMap_ST;
			samplerCUBE _Cube;
#ifdef _CUSTOM_FAST_REFLECT
			samplerCUBE _ReflectMap;
			fixed _ReflectStrength;
#endif
#ifdef _WARFOG
			sampler2D_float _TextureWarFogA, _TextureWarFogB, _TextureWarFogC;
			float4 _WarFogSelectionArray[3] = { float4(0,0,0,0), float4(0,0,0,0), float4(0,0,0,0) };
			float4 _WarFogTimeArray[3] = { float4(-5, -5, -5, -5), float4(-5, -5, -5, -5), float4(-5, -5, -5, -5) };
			float4 _WarFogFadeModeArray[3] = { float4(0,0,0,0), float4(0,0,0,0), float4(0,0,0,0) };
			float4 _WarFogArea = float4(-1213.7, -154.67, -918.68, 186.62);

			float4 TimeCalc(float4 t, float4 mode) {
				float4 time = clamp((_Time.y - t) * 2.2, 0, 1);
				time = lerp(1 - time, time, mode);
				return time;
			}
#endif
            v2f vert(float4 vertex : POSITION, float3 normal : NORMAL, float4 tangent : TANGENT, float2 texcoord0 : TEXCOORD0) {
                v2f o;
				o.uv0.xy = TRANSFORM_TEX(texcoord0, _MainTex);
				o.uv0.zw = TRANSFORM_TEX(texcoord0, _MainTex2);
				o.uv1.xy = texcoord0;
				o.pos = UnityObjectToClipPos(vertex);
				o.worldPos.xyz = mul(unity_ObjectToWorld, vertex).xyz;
#ifdef _CUSTOM_FAST_REFLECT
				half3 viewDir = WorldSpaceViewDir(vertex);
				o.worldRefl = reflect(-viewDir, UnityObjectToWorldNormal(normal));
#endif 

                return o;
            }
       
            fixed4 frag(v2f i) : SV_Target {
				
//#ifdef _WARFOG
//				float2 WarFogAreaUV = saturate((i.worldPos.xz - _WarFogArea.xy) / (_WarFogArea.zw - _WarFogArea.xy));
//
//				fixed4 WarFogArea_A = tex2D(_TextureWarFogA, WarFogAreaUV);
//				fixed4 WarFogArea_B = tex2D(_TextureWarFogB, WarFogAreaUV);
//				fixed4 WarFogArea_C = tex2D(_TextureWarFogC, WarFogAreaUV);
//
//				float4 warFogTime0 = TimeCalc(_WarFogTimeArray[0], _WarFogFadeModeArray[0]);
//				float4 warFogTime1 = TimeCalc(_WarFogTimeArray[1], _WarFogFadeModeArray[1]);
//				float4 warFogTime2 = TimeCalc(_WarFogTimeArray[2], _WarFogFadeModeArray[2]);
//
//				float4 WarFog_Mask_A = WarFogArea_A * _WarFogSelectionArray[0] * warFogTime0;
//				float4 WarFog_Mask_B = WarFogArea_B * _WarFogSelectionArray[1] * warFogTime1;
//				float4 WarFog_Mask_C = WarFogArea_C * _WarFogSelectionArray[2] * warFogTime2;
//
//				float WarFog_Mask = WarFog_Mask_A.x + WarFog_Mask_A.y + WarFog_Mask_A.z + WarFog_Mask_A.w +
//									WarFog_Mask_B.x + WarFog_Mask_B.y + WarFog_Mask_B.z + WarFog_Mask_B.w +
//									WarFog_Mask_C.x + WarFog_Mask_C.y + WarFog_Mask_C.z + WarFog_Mask_C.w;
//
//				WarFog_Mask = saturate(WarFog_Mask);
//#endif
                half3 flowVal1 = (tex2D(_FlowMap, i.uv1) * 2 - 1) * _Speed1;
				half3 flowVal2 = (tex2D(_FlowMap, i.uv1) * 2 - 1) * _Speed2;
				
				fixed3 mask = tex2D(_MaskTex, i.uv1);
				half3 flowVal = lerp(flowVal1, flowVal2, mask.b);

                float dif1 = frac(_Time.y * 0.25 + 0.5);
                float dif2 = frac(_Time.y * 0.25);
 
                float lerpVal = abs((0.5 - dif1)/0.5);
 
                fixed4 col1 = tex2D(_MainTex, i.uv0.xy - flowVal.xy * dif1);
				fixed4 col2 = tex2D(_MainTex, i.uv0.xy - flowVal.xy * dif2);
				fixed4 col21 = tex2D(_MainTex2, i.uv0.zw - flowVal.xy * dif1);
				fixed4 col22 = tex2D(_MainTex2, i.uv0.zw - flowVal.xy * dif2);

				fixed4 finalColor1 = lerp(col1, col2, lerpVal);
				fixed4 finalColor2 = lerp(col21, col22, lerpVal);
				fixed4 finalColor = lerp(finalColor2, finalColor1, pow(mask.g, 2));
				fixed4 c = lerp(_Color, _Color2, mask.r);

				c.rgb *= finalColor.rgb * 2;
				c.a = mask.r;
				c *= lerp(_AreaColor1, _AreaColor2, mask.g);

#ifdef _WARFOG
				c.rgb = lerp(dot(c.rgb, fixed3(0.3, 0.59, 0.11)) * fixed3(0.15, 0.18, 0.2), c.rgb, WarFog_Mask);
#endif
#ifdef _CUSTOM_FAST_REFLECT
				fixed4 refl = texCUBE(_ReflectMap, i.worldRefl + flowVal);
				c.rgb = lerp(c, c * refl * 2, mask.b * _ReflectStrength);
#endif

				#ifdef WORLD_CUSTOM_FOG
					c.rgb = WORLD_FOG(c, _G_EnvCustomFogColor, _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, i.worldPos.xyz).rgb;
				#endif

                return c;
            }