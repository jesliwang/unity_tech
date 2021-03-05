				fixed4 _Color;
				fixed _ColorPower;

#ifdef ALPHABLEND
	#ifdef TEXTURE0
					sampler2D _MainTransTex;
					float4 _MainTransTex_ST;
	#endif
	#ifdef TEXTURE1
					sampler2D _MainTex;
					sampler2D _MainTransTex;
					float4 _MainTex_ST;
		#if USEMASKUV
							float4 _MainTransTex_ST;
		#endif
	#endif
	#ifdef TEXTURE2
					sampler2D _MainTex;
					sampler2D _MainTex1;
					sampler2D _MainTransTex;
					sampler2D _MainTransTex1;
					float4 _MainTex_ST;
					float4 _MainTex1_ST;
		#if USEMASKUV
							float4 _MainTransTex_ST;
							float4 _MainTransTex1_ST;
		#endif
	#endif
	#ifdef TEXTURE3
					sampler2D _MainTex;
					sampler2D _MainTex1;
					sampler2D _MainTex2;
					sampler2D _MainTransTex;
					sampler2D _MainTransTex1;
					sampler2D _MainTransTex2;
					float4 _MainTex_ST;
					float4 _MainTex1_ST;
					float4 _MainTex2_ST;
		#if USEMASKUV
							float4 _MainTransTex_ST;
							float4 _MainTransTex1_ST;
							float4 _MainTransTex2_ST;
		#endif
	#endif
#else	//additive, multiply
	#ifdef TEXTURE1
					sampler2D _MainTex;
					float4 _MainTex_ST;
	#endif
	#ifdef TEXTURE2
					sampler2D _MainTex;
					sampler2D _MainTex1;
					float4 _MainTex_ST;
					float4 _MainTex1_ST;
	#endif
	#ifdef TEXTURE3
					sampler2D _MainTex;
					sampler2D _MainTex1;
					sampler2D _MainTex2;
					float4 _MainTex_ST;
					float4 _MainTex1_ST;
					float4 _MainTex2_ST;
	#endif
#endif
#ifdef DISSOLVE
					sampler2D _MainTransTex;
					float4 _EdgeColor1;
					float4 _EdgeColor2;
					float _Level;
					float _Edges;
					sampler2D _MainTex;
					float4 _MainTex_ST;
#endif


							
				struct appdata_t
				{
					float4 vertex	: POSITION;

#ifdef ALPHABLEND
	#ifdef TEXTURE0
						float2 texcoord : TEXCOORD0;
	#endif
	#ifdef TEXTURE1
						float4 texcoord : TEXCOORD0;
	#endif
	#ifdef TEXTURE2
						float4 texcoord : TEXCOORD0;
		#ifdef USEMASKUV
							float2 texcoord1 : TEXCOORD1;
		#endif
	#endif
	#ifdef TEXTURE3
						float4 texcoord : TEXCOORD0;
						float4 texcoord1 : TEXCOORD1;
		#ifdef USEMASKUV
							float4 texcoord2 : TEXCOORD2;
		#endif
	#endif
#else	//additive, multiply, dissolve
	#if defined (TEXTURE1) || (DISSOLVE)
						float2 texcoord : TEXCOORD0;
	#endif
	#ifdef TEXTURE2
						float4 texcoord : TEXCOORD0;
	#endif
	#ifdef TEXTURE3
						float4 texcoord : TEXCOORD0;
						float2 texcoord1 : TEXCOORD1;
	#endif
#endif

					half4 color		: COLOR;
				};
				
				
				struct v2f
				{
					fixed4 vertex	: POSITION;

#ifdef ALPHABLEND
	#ifdef TEXTURE0
						float2 uv		: TEXCOORD0;
	#endif
	#ifdef TEXTURE1
		#ifdef USEMASKUV
							float4 uv		: TEXCOORD0;
		#else
							float2 uv		: TEXCOORD0;
		#endif
	#endif
	#ifdef TEXTURE2
		#ifdef USEMASKUV
							float4 uv		: TEXCOORD0;
							float4 uv1		: TEXCOORD1;
		#else
							float4 uv		: TEXCOORD0;
		#endif
	#endif
	#ifdef TEXTURE3
		#ifdef USEMASKUV
							float4 uv		: TEXCOORD0;
							float4 uv1		: TEXCOORD1;
							float4 uv2		: TEXCOORD2;
		#else
							float4 uv		: TEXCOORD0;
							float2 uv1		: TEXCOORD1;
		#endif
	#endif
#else	//additive, multiply, dissolve
	#if defined (TEXTURE1) || defined (DISSOLVE)
					float2 uv		: TEXCOORD0;
	#endif
	#ifdef TEXTURE2
					float4 uv		: TEXCOORD0;
	#endif
	#ifdef TEXTURE3
					float4 uv		: TEXCOORD0;
					float2 uv1		: TEXCOORD1;
	#endif
#endif

					fixed4 color	: COLOR;

				//----- cginc용 단락 -----------------------------------------------
				//};	// 각 쉐이더별로 변수 선언 필요
				//----- cginc용 단락 -----------------------------------------------



//// 히든 쉐이더 클리핑 때문에 버텍스/프래그먼트 쉐이더는 cginc로 안묶음 -----------------------


//				v2f vert(appdata_t v)
//				{
//					v2f o;
//					UNITY_INITIALIZE_OUTPUT(v2f, o);
//
//					o.vertex = UnityObjectToClipPos(v.vertex);
//
//#ifdef ALPHABLEND
//	#ifdef TEXTURE0
//						o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTransTex);
//	#endif
//	#ifdef TEXTURE1
//		#ifdef USEMASKUV
//						o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex); 
//						o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTransTex);
//		#else
//						o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//		#endif
//	#endif
//	#ifdef TEXTURE2
//		#ifdef USEMASKUV
//							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
//							o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _MainTransTex);
//							o.uv1.zw = TRANSFORM_TEX(v.texcoord1.xy, _MainTransTex1);
//		#else
//							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
//		#endif
//	#endif
//#ifdef TEXTURE3
//	#ifdef USEMASKUV
//							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
//							o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _MainTex2);
//							o.uv1.zw = TRANSFORM_TEX(v.texcoord1.xy, _MainTransTex);
//							o.uv2.xy = TRANSFORM_TEX(v.texcoord2.xy, _MainTransTex1);
//							o.uv2.zw = TRANSFORM_TEX(v.texcoord2.xy, _MainTransTex2);
//	#else
//							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
//							o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _MainTex2);
//	#endif
//#endif
//
//#else	//additive, multiply, dissolve
//	#if defined (TEXTURE1) || (DISSOLVE)
//							//o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//							o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//	#endif
//	#ifdef TEXTURE2
//							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
//	#endif
//	#ifdef TEXTURE3
//							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
//							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
//							o.uv1.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex2);
//	#endif
//#endif 
//					o.color = v.color * _Color * _ColorPower;
//
//					return o;
//				}
//				 
//				
//				fixed4 frag(v2f i) : COLOR
//				{
//					fixed4 finalColor = fixed4(1,1,1,1);
//
//#ifdef DISSOLVE		//Dissove
//					float cutout = tex2D(_MainTransTex, i.uv.xy).r;
//					fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
//
//					if (cutout < _Level)
//						discard;
//
//					if (cutout < mainTex.a && cutout < _Level + _Edges)
//						mainTex = lerp(_EdgeColor1, _EdgeColor2, (cutout - _Level) / _Edges);
//
//					finalColor = mainTex;
//#elif ALPHABLEND	//Alphablend
//	#ifdef TEXTURE0
//					fixed4 mainTransTex = tex2D(_MainTransTex, i.uv.xy);
//					finalColor.a = mainTransTex.r;
//
//					finalColor *= i.color;
//	#endif
//	#ifdef TEXTURE1
//					fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
//		#ifdef  USEMASKUV
//						fixed mainTransTex = tex2D(_MainTransTex, i.uv.zw);
//						mainTex.a = mainTransTex;
//		#else
//						fixed mainTransTex = tex2D(_MainTransTex, i.uv.xy);
//						mainTex.a = mainTransTex;
//		#endif
//					finalColor = mainTex * i.color;
//	#endif
//	#ifdef TEXTURE2
//					fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
//					fixed4 mainTex1 = tex2D(_MainTex1, i.uv.zw);
//		#ifdef  USEMASKUV
//							fixed mainTransTex = tex2D(_MainTransTex, i.uv1.xy);
//							fixed mainTransTex1 = tex2D(_MainTransTex1, i.uv1.zw);
//							mainTex.a = mainTransTex;
//							mainTex1.a = mainTransTex1;
//		#else
//						fixed mainTransTex = tex2D(_MainTransTex, i.uv.xy);
//						fixed mainTransTex1 = tex2D(_MainTransTex1, i.uv.zw);
//						mainTex.a = mainTransTex;
//						mainTex1.a = mainTransTex1;
//		#endif
//					finalColor = mainTex * mainTex1 * i.color;
//	#endif
//	#ifdef TEXTURE3
//				fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
//				fixed4 mainTex1 = tex2D(_MainTex1, i.uv.zw);
//				fixed4 mainTex2 = tex2D(_MainTex2, i.uv1.xy);
//		#ifdef USEMASKUV
//						fixed mainTransTex = tex2D(_MainTransTex, i.uv1.zw);
//						fixed mainTransTex1 = tex2D(_MainTransTex1, i.uv2.xy);
//						fixed mainTransTex2 = tex2D(_MainTransTex2, i.uv2.zw);
//						mainTex.a = mainTransTex;
//						mainTex1.a = mainTransTex1;
//						mainTex2.a = mainTransTex2;
//		#else
//						fixed mainTransTex = tex2D(_MainTransTex, i.uv.xy);
//						fixed mainTransTex1 = tex2D(_MainTransTex1, i.uv.zw);
//						fixed mainTransTex2 = tex2D(_MainTransTex2, i.uv1.xy);
//						mainTex.a = mainTransTex;
//						mainTex1.a = mainTransTex1;
//						mainTex2.a = mainTransTex2;
//		#endif
//				finalColor = mainTex * mainTex1 * mainTex2 * i.color;
//	#endif
//#else	//Additive, Multiply
//	#ifdef TEXTURE0
//				finalColor.rgb *= i.color.rgb * _Color.a;
//	#endif 
//	#ifdef TEXTURE1
//				fixed4 mainTex = tex2D(_MainTex, i.uv);
//				finalColor.rgb = mainTex.rgb * i.color.rgb * i.color.a;
//	#endif 
//	#ifdef TEXTURE2
//				fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
//				fixed4 mainTex1 = tex2D(_MainTex1, i.uv.zw);
//				finalColor.rgb = mainTex.rgb * mainTex1.rgb * i.color.rgb * i.color.a;
//	#endif 
//	#ifdef TEXTURE3
//				fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
//				fixed4 mainTex1 = tex2D(_MainTex1, i.uv.zw);
//				fixed4 mainTex2 = tex2D(_MainTex2, i.uv1.xy);
//				finalColor.rgb = mainTex.rgb * mainTex1.rgb * mainTex2.rgb * i.color.rgb * i.color.a;
//	#endif 
//#endif
//
//					return finalColor;
//				}