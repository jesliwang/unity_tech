			struct appdata
			{
				float4 color : COLOR;
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 color : COLOR;
				float4 pos : SV_POSITION;
				float4 uv  : TEXCOORD0; //xy:number, zw:bg
#ifdef _UPGRADEABLE
				float upgradeable : TEXCOORD1;
#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
#if defined (_MODE_NUMBER) || (_MODE_HPBAR)
			sampler2D _DataTex;
#endif
			sampler2D _MainTex;
			sampler2D _UpgradeMark;
			float4 _MainTex_ST;
			float _colCount, _rowCount;
			//float4 _Color;
			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(float, _NumberIndex)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				#ifdef _MODE_NGUIATLAS
					UNITY_DEFINE_INSTANCED_PROP(float4, _UVRect)
				#endif
				#ifdef _UPGRADEABLE
					UNITY_DEFINE_INSTANCED_PROP(float, _Upgradeable)
				#endif
			UNITY_INSTANCING_BUFFER_END(Props)
			v2f vert (appdata v)
			{ 
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);

#ifdef _MODE_NUMBER
				float index = UNITY_ACCESS_INSTANCED_PROP(Props, _NumberIndex) - 0.999;
				index = max(0.5, min(81.999, index));
				float colCount = max(1, _colCount);// UNITY_ACCESS_INSTANCED_PROP(Props, _colCount);
				float rowCount = max(1, _rowCount);// UNITY_ACCESS_INSTANCED_PROP(Props, _rowCount);

				//float scale = length(float3(unity_ObjectToWorld[0].z, unity_ObjectToWorld[1].z, unity_ObjectToWorld[2].z));
				float2 size = float2(1 / colCount, 1 / rowCount);
				int uIndex = round(fmod(index, colCount));
				int vIndex = abs(float(index / colCount));

				float2 offset = float2((uIndex) * size.x, (1 - size.y) - (vIndex) * size.y);
				_MainTex_ST.z += offset.x;
				_MainTex_ST.w += offset.y;
#endif

				UNITY_TRANSFER_INSTANCE_ID(v, o);

#ifdef _MODE_NUMBER		
				o.uv.zw = v.uv.xy * _MainTex_ST.xy * size.xy + _MainTex_ST.zw;
#else
				o.uv.zw = v.uv.xy;
#endif
#ifdef _MODE_NGUIATLAS
				v.uv.y = 1 - v.uv.y;
				float4 rect = UNITY_ACCESS_INSTANCED_PROP(Props, _UVRect);

				o.uv.xy = v.uv.xy * rect.xy + rect.zw;
#else
				o.uv.xy = v.uv.xy;
#endif

#ifdef BILLBOARD
				float3 vpos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
				float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
				float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
				float4 outPos = mul(UNITY_MATRIX_P, viewPos);
				o.pos = outPos;
#else
				o.pos = UnityObjectToClipPos(v.vertex);
#endif
				o.color = v.color;
#ifdef _UPGRADEABLE
				o.upgradeable = UNITY_ACCESS_INSTANCED_PROP(Props, _Upgradeable);
#endif
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float4 col;
#ifdef _UPGRADEABLE
				float4 upgradeMark = tex2D(_UpgradeMark, i.uv.xy /*- float2(0, saturate(tan(_Time.y)) ) */) ;
				upgradeMark.a *= i.upgradeable;
				float4 bg = tex2D(_MainTex, i.uv.xy);
				bg = lerp(upgradeMark, bg, i.color.r);
#else
				float4 bg = tex2D(_MainTex, i.uv.xy);
#endif
#if defined (_MODE_NUMBER) || (_MODE_HPBAR)
				float4 number = tex2D(_DataTex, i.uv.zw) * i.color.r;

				#ifdef _MODE_NUMBER
					col.rgb = (bg + number.a * UNITY_ACCESS_INSTANCED_PROP(Props, _Color).rgb);
					col.a = max(0, number.a + bg.a);
				#endif

				#ifdef _MODE_HPBAR
					float4 gauge = tex2D(_DataTex, i.uv.zw);
					gauge *= UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
					gauge *= normalize(max(0, UNITY_ACCESS_INSTANCED_PROP(Props, _NumberIndex) * 0.01 - i.uv.x));

					col = bg + gauge;
				#endif
#else
				col = bg * UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
#endif
#ifndef _UPGRADEABLE
				col.a *= i.color.r;
#endif
				return col;
			}
