// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#ifdef CLIP
	#undef WORLD_CUSTOM_FOG
#endif


half4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _MainTransTex;
float4 _MainTransTex_ST;

#ifdef ENABLE_TWO_TEXTURES
	sampler2D _MainTex1;
	float4 _MainTex1_ST;
	sampler2D _MainTransTex1;
	float4 _MainTransTex1_ST;
#else
	//#ifdef _SPECIALMODE_SHEETANIMATION //메쉬이펙트에서 Texture Sheet Animation을 적용할 수 있도록 함
	//fixed _fps;
	//fixed _totalCells;
	//fixed _colCount;
	//fixed _rowCount;
	//fixed _Index;
	//#else
	#ifdef _SPECIALMODE_ROTATION //UV회전
		float _RotationSpeed;
	#endif

	#ifdef _SPECIALMODE_UVFLOW
		float _FlowSpeed_X1;
		float _FlowSpeed_Y1;
	#endif

	#ifdef _SPECIALMODE_DISTORTION //외곡효과(사용예: 영웅정보창에서의 영웅 뒤 연기표현)
	uniform sampler2D _DistortTex;
	uniform half4 _DistortTex_ST;	
	uniform fixed _Strength;
	uniform fixed _DistortFlow_X;
	uniform fixed _DistortFlow_Y;
	#endif
	//#endif

	#ifdef _SPECIALMODE_BURN  //불타는것과 같은 효과
	sampler2D _BurnMap;
	float4	_BurnMap_ST;
	uniform fixed _BurnAmount;
	uniform fixed4 _BurnedColor;
	uniform fixed4 _BurnColor1;
	uniform fixed4 _BurnColor2;				
	uniform fixed _LineWidth1;
	uniform fixed _LineWidth2;	
	#endif

	#ifdef _SPECIALMODE_BURN // 불타는 효과에서 선의 두께를 정함
		fixed strangth(fixed lineWidth, fixed burnArea)
		{
			return max(0.0, clamp(1.0 - ((lineWidth - clamp(abs(burnArea), 0.0, 1.0)) / lineWidth), 0.0, 1.0));
		}
	#endif
#endif

fixed _ColorBalance_R;
fixed _ColorBalance_G;
fixed _ColorBalance_B;
fixed _Transparency;
fixed _ColorPower;
fixed _RetainAngle;
fixed _IsGray;
fixed _Temperature;
fixed _FogCalcID;

float4 _ClipArea;

#ifdef WORLD_CUSTOM_FOG
	float4 _G_EnvCustomFogColor;
	float4 _G_EnvCustomFogSetting;
	float4 _G_EnvCustomFogHeightSetting;
#endif

float  _G_DayNightLightIntensity;
float _G_DayNightCurrentTime;

struct appdata_t {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 texcoord : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
	float4 vertex : SV_POSITION;
	fixed4 color : COLOR;

	#ifndef USE_SECOND_TRANSFORM
		float2 texcoord : TEXCOORD0;
	#else
		float4 texcoord : TEXCOORD0;
	#endif

	#if defined( ENABLE_TWO_TEXTURES) || defined(_SPECIALMODE_DISTORTION)
		#ifndef USE_SECOND_TRANSFORM
			float2 texcoord1 : TEXCOORD1;
		#else
			float4 texcoord1 : TEXCOORD1;
		#endif
	#endif

#ifdef WORLD_CUSTOM_FOG
	#ifdef _VERTEX_FOG
		float4 customFog : TEXCOORD2;
	#else
		float3 worldPos : TEXCOORD2;
	#endif
#elif defined (CLIP)
		float2 worldPos : TEXCOORD2;
#endif
	//UNITY_FOG_COORDS(2)
	//#if defined( _SPECIALMODE_DISTORTION)
	//	//#ifndef _SPECIALMODE_SHEETANIMATION
	//		float2 texcoord2 : TEXCOORD1; //DISTORTION 텍스쳐의 UV연산에 필요
	//	//#endif
	//#endif
};

v2f vert (appdata_t v)
{
	v2f o;
	UNITY_SETUP_INSTANCE_ID(v);

#ifdef UISPRITE
	v.texcoord.y = 1 - v.texcoord.y;
	//float4 worldpos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
	//v.vertex = mul(unity_ObjectToWorld, v.vertex);
	//v.vertex.xyz -= worldpos.xyz;
	//v.vertex.xy *= -1;
	//v.vertex.xyz += worldpos.xyz;
	//v.vertex = mul(unity_WorldToObject, v.vertex);
#endif

#ifdef BILLBOARD
	o.vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0)) + float4(v.vertex.x, v.vertex.y, v.vertex.z, 1));
#else
	o.vertex = UnityObjectToClipPos(v.vertex);
#endif

	o.color = v.color * _Color * _ColorPower;
	o.color.a *= _Transparency;

#if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
	#if !defined (USE_SECOND_TRANSFORM) &&  !defined (ENABLE_TWO_TEXTURES) 
			vertInstancingColor(o.color);
			vertInstancingUVs(v.texcoord, o.texcoord);
	#endif
#endif
	//#if !defined (_SPECIALMODE_BURN) && !defined(ENABLE_TWO_TEXTURES)
	//	//#ifdef _SPECIALMODE_SHEETANIMATION // Texture Sheet Animaion 사용 시 인덱스 번호에 따른 UV위치 계산
	//	//	half2 size = fixed2 (1 / _colCount, 1 / _rowCount);
	//	//	fixed uIndex = fmod(_Index, _colCount);
	//	//	fixed vIndex = int(_Index / _colCount);
	//	//	half2 offset = fixed2 ((uIndex) * size.x, (1 - size.y) - (vIndex) * size.y);
	//	//	_MainTex_ST.z += offset.x;
	//	//	_MainTex_ST.w += offset.y;
	//	//	o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy * size.xy + _MainTex_ST.zw; 
	//	//#else
	//		o.texcoord.xy = v.texcoord.xy;
	//	//#endif
	//#else
	//o.texcoord.xy = v.texcoord.xy; 
	//#endif
	//#if !defined (_SPECIALMODE_SHEETANIMATION) && !defined(ENABLE_TWO_TEXTURES)
	#ifdef _SPECIALMODE_UVFLOW
		o.texcoord.xy = _MainTex_ST.xy * v.texcoord.xy + _MainTex_ST.zw + float2(_FlowSpeed_X1 * _Time.x, _FlowSpeed_Y1 * _Time.x);
	#else
		o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);// _MainTex_ST.xy * v.texcoord.xy + _MainTex_ST.zw;
	#endif
	
	#ifdef USE_SECOND_TRANSFORM
		o.texcoord.zw = TRANSFORM_TEX(v.texcoord, _MainTransTex); //_MainTransTex_ST.xy * v.texcoord.xy + _MainTransTex_ST.zw;
	#endif

	#ifdef _SPECIALMODE_DISTORTION
		float2 distortionFlow = TRANSFORM_TEX(v.texcoord, _DistortTex) + fmod((float2(_DistortFlow_X, _DistortFlow_Y) * _Time[1]), float2(1, 1));
		o.texcoord1.xy = distortionFlow;
	#else
		#ifdef ENABLE_TWO_TEXTURES
			o.texcoord1.xy = TRANSFORM_TEX(v.texcoord, _MainTex1); //_MainTex1_ST.xy * v.texcoord.xy + _MainTex1_ST.zw;
			#ifdef USE_SECOND_TRANSFORM
				o.texcoord1.zw = TRANSFORM_TEX(v.texcoord, _MainTransTex1); //_MainTransTex1_ST.xy * v.texcoord.xy + _MainTransTex1_ST.zw;
			#endif
		#endif
	#endif

	#if !defined(ENABLE_TWO_TEXTURES)
		#ifndef _SPECIALMODE_BURN
			#ifdef _SPECIALMODE_ROTATION  // UV 회전공식 적용
				float RotValue = lerp(fmod(_Time[1] * _RotationSpeed, 360), _RotationSpeed, _RetainAngle);
				float s = sin (RotValue);
				float c = cos (RotValue);
				float2x2 rotationMatrix = float2x2( c, -s, s, c);
				float2 RotOffset = float2((_MainTex_ST.z + _MainTex_ST.x), (_MainTex_ST.w + _MainTex_ST.y)) * 0.5;
				float2 customXY = v.texcoord.xy - RotOffset;
				
				o.texcoord.xy = mul(customXY, rotationMatrix ) + RotOffset; 
			#endif

			//#if !defined( _SPECIALMODE_ROTATION) && !defined(_SPECIALMODE_DISTORTION) && !defined(ENABLE_TWO_TEXTURES)
			//	o.texcoord.xy = v.texcoord.xy; 
			//#endif
		#else
			o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _BurnMap);// _BurnMap_ST.xy * v.texcoord.xy + _BurnMap_ST.zw;
		#endif
	#endif

#ifdef WORLD_CUSTOM_FOG
		float3 wPos = mul(unity_ObjectToWorld, v.vertex);
		#ifdef _VERTEX_FOG
			o.customFog = WORLD_FOG(lerp(float4(0, 0, 0, 0), _G_EnvCustomFogColor, _FogCalcID), _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, wPos);
			o.customFog.a *= _G_EnvCustomFogHeightSetting.w;
		#else
			o.worldPos = wPos;
		#endif
#elif defined (CLIP)
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xy;
#endif

	return o;
}

fixed4 frag (v2f i) : SV_Target
{
	half2 mainUV = i.texcoord.xy;
	#ifdef _SPECIALMODE_DISTORTION
		fixed4 distortionTex = tex2D(_DistortTex, i.texcoord1.xy);
		float2 uv = distortionTex.rg * _Strength;
		mainUV += uv;
	#endif

	fixed mask = 1;
	#ifdef USE_MASKTEXTURE
		#ifdef USE_SECOND_TRANSFORM 
			mask = tex2D(_MainTransTex, i.texcoord.zw).r;
		#else
			mask = tex2D(_MainTransTex, mainUV).r;
		#endif

		#ifdef ENABLE_TWO_TEXTURES //텍스쳐를 두장 사용하겠다는 뜻.
			#ifdef USE_SECOND_TRANSFORM  // 두번째 텍스쳐의 UV매트릭스 연산을 함(텍스쳐의 타일링 혹은 Offset이 가능해짐.)
				half2 mask2UV = i.texcoord1.zw;
			#else
				half2 mask2UV = mainUV; // 텍스쳐의 타일링 혹은 Offset이 불가능
			#endif
			#ifdef SPLITALPHA_ADD
			mask = saturate(mask + tex2D(_MainTransTex1, mask2UV).r); // 두장의 텍스쳐를 더함
			#else
			mask *= tex2D(_MainTransTex1, mask2UV).r; // 두장의 텍스쳐를 곱함
			#endif
		#endif
	#endif

	float4 tex = tex2D(_MainTex, mainUV);

	#ifndef _SPECIALMODE_DISTORTION
		#ifdef ENABLE_TWO_TEXTURES //두장의 텍스쳐를 사용
			//#ifdef USE_SECOND_TRANSFORM  //이 키워드가 활성화 되면 두번째 텍스쳐의 UV매트릭스를 계산한다.
			half2 main2UV = i.texcoord1.xy;
			//#else
			//half2 main2UV = mainUV;
			//#endif

			tex *= tex2D(_MainTex1, main2UV);
		#endif
	#endif

#ifdef CLIP
			bool inArea = i.worldPos.x >= _ClipArea.x && i.worldPos.x <= _ClipArea.z && i.worldPos.y >= _ClipArea.y && i.worldPos.y <= _ClipArea.w;
#endif

	#ifdef _SPECIALMODE_BURN //타서 사라지는 효과
		fixed4 burn = tex2D(_BurnMap, i.texcoord.xy);
		float tmp = burn.r - _BurnAmount;   
		tex.rgb = lerp(_BurnedColor.rgb, tex.rgb, clamp(tmp * 255, 0.0, 1));
		tex.rgb = lerp(_BurnColor2.rgb * tex.rgb * 2.0, tex.rgb, strangth(_LineWidth1 + _LineWidth2, tmp));
		tex.rgb = lerp(_BurnColor1.rgb + tex.rgb, tex.rgb, strangth(_LineWidth1, tmp));
		float transp = lerp(1, tmp, strangth(_LineWidth1 + _LineWidth2, tmp));

		tex.a = saturate(transp) * mask;
	#else
		#ifndef UISPRITE
			tex.a = mask;
			#ifdef CLIP
				tex = inArea ? tex : fixed4(0, 0, 0, 0);
			#endif
			return tex * i.color;
		#endif
	#endif

	float3 grayCol = dot(tex.rgb, fixed3(0.3, 0.59, 0.11));

	#ifdef ENABLE_CUSTOMCOLOR
		float3 colBalance = float3(_ColorBalance_R, _ColorBalance_G, _ColorBalance_B);
		tex.rgb = saturate(grayCol.rgb * (grayCol.rgb + colBalance));
	#endif

	tex.rgb = lerp(grayCol, tex.rgb, _IsGray);

	float4 col = tex * i.color;
#ifdef INFRARED_RAY
	col.rgb += col.rrr * _Temperature;
#endif

#ifdef _USE_CROSSFADE
	float crossfade = 1;
	#ifdef FIRST_CROSSFADE
		crossfade = CUSTOM_CROSSFADE(_G_CrossfadeTime.z, max(max(_G_CrossfadeMode.x, _G_CrossfadeMode.y), _G_CrossfadeMode.z));
	#endif	
	#ifdef CITY_CROSSFADE
		crossfade = CUSTOM_CROSSFADE(_G_CrossfadeTime.w, _G_CrossfadeMode.w);
	#endif
		col.a *= crossfade;
#endif
		col.rgb *= lerp(1, _G_DayNightLightIntensity, _G_DayNightCurrentTime);

#ifdef WORLD_CUSTOM_FOG
	#ifdef _VERTEX_FOG
		col.rgb = lerp(col, i.customFog.rgb, i.customFog.a);
	#else
		col.rgb = WORLD_FOG(col, lerp(float4(0, 0, 0, 0), _G_EnvCustomFogColor, _FogCalcID), _G_EnvCustomFogSetting, _G_EnvCustomFogHeightSetting, i.worldPos.xyz).rgb;
	#endif
#elif defined (CLIP)
		col = inArea ? col : fixed4(0, 0, 0, 0);
#endif
	return col;
}