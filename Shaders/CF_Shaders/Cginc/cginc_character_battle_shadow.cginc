
			struct appdata
			{
				half2 uv : TEXCOORD0;
				half4 uv2 : TEXCOORD1;
				half3 normal : NORMAL;
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				V2F_SHADOW_CASTER;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
#ifdef _INSTANCING_CUSTOM
			float _AnimAll;
			sampler2D _AnimMap;
			float4 _AnimMap_TexelSize;//x == 1/width
			UNITY_INSTANCING_BUFFER_START(Props)
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
#endif

			v2f vert(appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);

#ifdef _INSTANCING_CUSTOM
			//v.vertex *= UNITY_ACCESS_INSTANCED_PROP(Props, _ScaleFade);

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
	#endif
#else
			float4 pos = v.vertex;
#endif

				v.vertex.xyz = pos.xyz;

				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.pos = UnityObjectToClipPos(pos);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}