Shader "GNSS/LensDirt" {
	Properties {
		_MainTex ("NoTex", 2D) = "" {}
		_DirtTex ("DirtTex", 2D) = "" {}
	}
	
	CGINCLUDE

	#include "UnityCG.cginc"
	
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv[2] : TEXCOORD0;
	};


	sampler2D _MainTex;
	sampler2D _DirtTex;
    half _DirtIntensity;
	half4 _MainTex_TexelSize;
		
	v2f vert( appdata_img v ) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv[0] =  v.texcoord.xy;
		o.uv[1] =  v.texcoord.xy;
		
		#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0) 
			o.uv[1].y = 1-o.uv[1].y;
		#endif	
		
		return o;
	}

	half4 fragDirt (v2f i) : SV_Target {
		half3 color = (0.0).xxx;
        half3 main = tex2D(_MainTex, i.uv[0]).rgb;
        color += main;
        half3 dirt = tex2D(_DirtTex, i.uv[1]).rgb * _DirtIntensity;
		color += dirt;

		return half4(color, 1.0);
	}

	ENDCG 
	
	Subshader {
	  ZTest Always Cull Off ZWrite Off

		Pass {    
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragDirt
			ENDCG
		}
	}
} // shader
