Shader "Hidden/MeshPaint/Splat4Channels" {
Properties {
	_Control ("Control (RGBA)", 2D) = "red" {}
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
	
	Lighting Off
	
CGPROGRAM
#pragma target 3.0

#pragma debug

#pragma surface surf WrapLambert exclude_path:prepass noforwardadd
struct Input {
	float2 uv_Control : TEXCOORD0;
	float2 uv_Splat0 : TEXCOORD1;
	float2 uv_Splat1 : TEXCOORD2;
	float2 uv_Splat2 : TEXCOORD3;
	float2 uv_Splat3 : TEXCOORD4;
	float3 worldNormal;
	INTERNAL_DATA
};

sampler2D _Control;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
    
half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {
        half NdotL = dot (s.Normal, lightDir);
        half diff = NdotL * 0.5 + 0.5;
        half4 c;
        c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
        c.a = s.Alpha;
        return c;
}
      
void surf (Input IN, inout SurfaceOutput o) {
	float4 splat_control = tex2D (_Control, IN.uv_Control);
	float3 col;
	col  = splat_control.r * tex2D (_Splat0, IN.uv_Splat0).rgb;
	col += splat_control.g * tex2D (_Splat1, IN.uv_Splat1).rgb;
	col += splat_control.b * tex2D (_Splat2, IN.uv_Splat2).rgb;
	col += splat_control.a * tex2D (_Splat3, IN.uv_Splat3).rgb;
	o.Albedo = col;
	o.Alpha = 1.0;
	o.Specular = 0.15;
	o.Normal = IN.worldNormal;
}
ENDCG  
}

Fallback "Diffuse"
}