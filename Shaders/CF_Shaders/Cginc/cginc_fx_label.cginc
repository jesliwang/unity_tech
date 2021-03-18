	struct appdata_t
	{
		float4 vertex : POSITION;
		half4 color : COLOR;
		float2 texcoord : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		half4 color : COLOR;
		float2 texcoord : TEXCOORD0;
#ifdef CLIP
		float2 worldPos : TEXCOORD1;
#endif
		UNITY_VERTEX_OUTPUT_STEREO
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _ClipArea;
	float4 _OutlineColor;

	v2f vert (appdata_t v)
	{
		v2f o;
		UNITY_SETUP_INSTANCE_ID(v);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.texcoord = v.texcoord;
		//o.color = v.color;
		o.color.rgb = v.color.rgb;
		o.color.a = saturate((v.color.a - 0.1) * 1.2);

#ifdef CLIP
		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xy;
#endif
		return o;
	}

	half4 frag (v2f i) : SV_Target
	{
		half alpha = tex2D(_MainTex, i.texcoord).a;

#ifdef _OUTLINE
		half4 col = lerp(_OutlineColor, i.color, alpha);
		alpha = min(1, alpha * 2);
		//alpha *= 2;
#else
		half4 col = i.color;
#endif
		
		col.a = alpha;

#ifdef CLIP
		bool inArea = i.worldPos.x >= _ClipArea.x && i.worldPos.x <= _ClipArea.z && i.worldPos.y >= _ClipArea.y && i.worldPos.y <= _ClipArea.w;
		col = inArea ? col : fixed4(0, 0, 0, 0);
#endif
		return col;
	}