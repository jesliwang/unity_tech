Shader "MeshPaint/Mobile/Splat4Diff" {
Properties {
	_Control0 ("Control (RGBA)", 2D) = "black" {}
	_Splat3 ("Ch (A)", 2D) = "white" {}
	_Splat2 ("Ch (B)", 2D) = "white" {}
	_Splat1 ("Ch (G)", 2D) = "white" {}
	_Splat0 ("Ch (R)", 2D) = "white" {}
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
#pragma surface surf WrapLambert exclude_path:prepass nolightmap noforwardadd halfasview interpolateview

struct Input {
	float2 uv_Control0 : TEXCOORD0;
	float2 uv_Splat0 : TEXCOORD1;
	float2 uv_Splat1 : TEXCOORD2;
	float2 uv_Splat2 : TEXCOORD3;
	float2 uv_Splat3 : TEXCOORD4;
};

sampler2D _Control0;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
    
inline fixed4 LightingWrapLambert (SurfaceOutput s, fixed3 lightDir, fixed atten) {
    fixed NdotL = dot (s.Normal, lightDir);
    fixed diff = NdotL * 0.5 + 0.5;
    fixed4 c;
    c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
    c.a = s.Alpha;
    return c;
}
      
void surf (Input IN, inout SurfaceOutput o) {
	half4 splat_control = tex2D (_Control0, IN.uv_Control0);
	half3 col;
	col  = splat_control.r * tex2D (_Splat0, IN.uv_Splat0).rgb;
	col += splat_control.g * tex2D (_Splat1, IN.uv_Splat1).rgb;
	col += splat_control.b * tex2D (_Splat2, IN.uv_Splat2).rgb;
	col += splat_control.a * tex2D (_Splat3, IN.uv_Splat3).rgb;
	o.Albedo = col;
	o.Alpha = 1.0;
}
ENDCG  
}

Fallback "Diffuse"
}
