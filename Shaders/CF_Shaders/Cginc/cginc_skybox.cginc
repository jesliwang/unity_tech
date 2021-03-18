
        samplerCUBE _DayTex;
#ifdef _SUPPORT_DAY_NIGHT
		samplerCUBE _NightTex;
		half3 _DayTint;
		float  _G_DayNightCurrentTime;
		half3 _NightTint;
		half _NightExposure;
#else
		half3 _G_SkyTintColor;
#endif
        
        half _DayExposure;
        float _Rotation;

		float _G_SkyBoxHeight;
		float _G_SkyFog_Height;
		float _G_SkyFog_Strangth;
		float _G_SkyFog_Limit;

#ifdef WORLD_CUSTOM_FOG
		fixed4 _G_EnvCustomFogColor;
#endif
        float3 RotateAroundYInDegrees (float3 vertex, float degrees)
        {
            float alpha = degrees * UNITY_PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float3(mul(m, vertex.xz), vertex.y).xzy;
        }

        struct appdata_t {
            float4 vertex : POSITION;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float3 texcoord : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        v2f vert (appdata_t v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			float4 vt = float4(v.vertex.x, (v.vertex.y - _G_SkyBoxHeight), v.vertex.z, v.vertex.w);
            float3 rotated = RotateAroundYInDegrees(vt, _Rotation);
            o.vertex = UnityObjectToClipPos(rotated);
            o.texcoord = v.vertex.xyz;
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
			half3 finalColor;
            half4 dayTex = texCUBE (_DayTex, i.texcoord);
			half exposure;
			half3 tint;
#ifdef _SUPPORT_DAY_NIGHT
			half4 nightTex = texCUBE(_NightTex, i.texcoord);
			finalColor = lerp(dayTex, nightTex, _G_DayNightCurrentTime);
			exposure = lerp(_DayExposure, _NightExposure, _G_DayNightCurrentTime);
			tint = lerp(_DayTint, _NightTint + finalColor.r, _G_DayNightCurrentTime);
#else
			finalColor = dayTex;
			exposure = _DayExposure;
			tint = _G_SkyTintColor;
#endif
			finalColor = finalColor * tint * exposure;
			
#ifdef WORLD_CUSTOM_FOG
			//lerp(col.rgb, fogCol + max(col.rgb, fogCol), i.customFog.a);
			finalColor = lerp(_G_EnvCustomFogColor + max(finalColor.rgb, _G_EnvCustomFogColor) , finalColor, saturate(max(_G_SkyFog_Limit, (i.texcoord.y + _G_SkyFog_Height) * _G_SkyFog_Strangth)));
#endif

            return half4(finalColor, 1);
        }