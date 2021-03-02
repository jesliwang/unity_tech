Shader "MeshPaint/Splat4Bump" {
Properties {
	_Control0 ("Control (RGBA)", 2D) = "black" {}
	_Splat3 ("Ch (A)", 2D) = "black" {}
	_Splat2 ("Ch (B)", 2D) = "black" {}
	_Splat1 ("Ch (G)", 2D) = "black" {}
	_Splat0 ("Ch (R)", 2D) = "black" {}
	
	_Normal3 ("N (A)", 2D) = "bump" {}
	_Normal2 ("N (B)", 2D) = "bump" {}
	_Normal1 ("N (G)", 2D) = "bump" {}
	_Normal0 ("N (R)", 2D) = "bump" {}
}
	
SubShader {
	Tags {
		"SplatCount" = "4"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}

	CGPROGRAM
	#pragma target 3.0

	#pragma debug

	#pragma exclude_renderers flash
	#pragma surface surf WrapLambert exclude_path:prepass noforwardadd
			
	#include "UnityCG.cginc"

	struct Input {
		float2 uv_Control0 : TEXCOORD0;
		float2 uv_Splat0 : TEXCOORD1;
		float2 uv_Splat1 : TEXCOORD2;
		float2 uv_Splat2 : TEXCOORD3;
		float2 uv_Splat3 : TEXCOORD4;
	};

	sampler2D _Control0;
	sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
	sampler2D _Normal0, _Normal1, _Normal2, _Normal3;
    
	half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {
        half NdotL = dot (s.Normal, lightDir);
        half diff = NdotL * 0.5 + 0.5;
        half4 c;
        c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
        c.a = s.Alpha;
        return c;
    }
      
	void surf (Input IN, inout SurfaceOutput o) {

		float4 splat_control = tex2D (_Control0, IN.uv_Control0);
		
		float4 col;
		col  = splat_control.r * tex2D (_Splat0, IN.uv_Splat0);
		col += splat_control.g * tex2D (_Splat1, IN.uv_Splat1);
		col += splat_control.b * tex2D (_Splat2, IN.uv_Splat2);
		col += splat_control.a * tex2D (_Splat3, IN.uv_Splat3);
		
		float4 nrm;
		nrm  = splat_control.r * tex2D(_Normal0, IN.uv_Splat0);
		nrm	+= splat_control.g * tex2D(_Normal1, IN.uv_Splat1);
		nrm	+= splat_control.b * tex2D(_Normal2, IN.uv_Splat2);
		nrm += splat_control.a * tex2D(_Normal3, IN.uv_Splat3);
			
		o.Albedo = col.rgb;
		o.Alpha = 1;
		o.Normal = 	normalize(UnpackNormal(nrm));
	}

ENDCG  
}



Fallback "Diffuse"
}
