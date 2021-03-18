	struct appdata_t
	{
		float4 vertex : POSITION;
		float2 texcoord: TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float2 texcoord : TEXCOORD0;
		float4 uvgrab : TEXCOORD1;
		float amount : TEXCOORD2;
		UNITY_VERTEX_OUTPUT_STEREO
	};
	float _UseUnityTime;
	sampler2D _GrabTexture;
	float4 _GrabTexture_TexelSize;
	float _CurrentTime, _FadeSpeed, _FadeInOutMode, _Amount, _TargetBright;
	float _G_ElapsedTime;
	v2f o;

	v2f vert(appdata_t v)
	{
		UNITY_SETUP_INSTANCE_ID(v);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
		o.vertex = UnityObjectToClipPos(v.vertex);
		#if UNITY_UV_STARTS_AT_TOP
		float scale = -1.0;
		#else
		float scale = 1.0;
		#endif
		o.uvgrab = ComputeGrabScreenPos(o.vertex); 
		o.texcoord = v.texcoord;
		float fadeTime = saturate((_G_ElapsedTime - _CurrentTime) * _FadeSpeed);
		fadeTime = lerp(1 - fadeTime, fadeTime, _FadeInOutMode);
		o.amount = fadeTime;
		return o;
	}

	half4 frag(v2f i) : SV_Target
	{
		half4 col = tex2Dproj(_GrabTexture, i.uvgrab);

		#ifdef M_SIZE
			const int mSize = M_SIZE;
			const int iter = (mSize - 1) * 0.5;

			half4 sum = 0;
			float blurAmount = _Amount * AMOUNT;

			for (int k = 0; k <= iter * 2; ++k)
			{
				for (int j = 0; j <= iter * 2; ++j)
				{
					float4 blurUV = float4(float2(i.uvgrab.xy + _GrabTexture_TexelSize.xy * float2(k - iter, j - iter) * blurAmount), i.uvgrab.z, i.uvgrab.w);
					sum += tex2Dproj(_GrabTexture, blurUV) * NORMPDF;
				}
			}
			sum = sum / iter;
			col = lerp(col, sum * _TargetBright, i.amount);
		#else
			col = lerp(col, lerp(0, col * _TargetBright, _TargetBright), i.amount);
		#endif
		col.a = 1;
		return col;
	}