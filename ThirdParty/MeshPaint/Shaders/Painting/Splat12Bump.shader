Shader "MeshPaint/Splat12Bump" {
Properties {
	_Control0 ("Control (RGBA)", 2D) = "black" {}
	_Splat3 ("Ch (A)", 2D) = "white" {}
	_Splat2 ("Ch (B)", 2D) = "white" {}
	_Splat1 ("Ch (G)", 2D) = "white" {}
	_Splat0 ("Ch (R)", 2D) = "white" {}
	
	_Normal3 ("N (A)", 2D) = "bump" {}
	_Normal2 ("N (B)", 2D) = "bump" {}
	_Normal1 ("N (G)", 2D) = "bump" {}
	_Normal0 ("N (R)", 2D) = "bump" {}
	
	_Control1 ("Control1 (RGBA)", 2D) = "black" {}
	_Splat7 ("Ch (A)", 2D) = "white" {}
	_Splat6 ("Ch (B)", 2D) = "white" {}
	_Splat5 ("Ch (G)", 2D) = "white" {}
	_Splat4 ("Ch (R)", 2D) = "white" {}	
	
	_Normal7 ("N (A)", 2D) = "bump" {}
	_Normal6 ("N (B)", 2D) = "bump" {}
	_Normal5 ("N (G)", 2D) = "bump" {}
	_Normal4 ("N (R)", 2D) = "bump" {}
	
	_Control2 ("Control1 (RGBA)", 2D) = "black" {}
	_Splat11 ("Ch (A)", 2D) = "white" {}
	_Splat10 ("Ch (B)", 2D) = "white" {}
	_Splat9 ("Ch (G)", 2D) = "white" {}
	_Splat8 ("Ch (R)", 2D) = "white" {}	
	
	_Normal11 ("N (A)", 2D) = "bump" {}
	_Normal10 ("N (B)", 2D) = "bump" {}
	_Normal9 ("N (G)", 2D) = "bump" {}
	_Normal8 ("N (R)", 2D) = "bump" {}
}
	
SubShader {
	Tags {
		"SplatCount" = "12"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
	
CGPROGRAM
#pragma target 3.0
#pragma debug
#pragma surface surf WrapLambert exclude_path:prepass noforwardadd

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

CGPROGRAM
#pragma target 3.0
#pragma debug
#pragma surface surf WrapLambert decal:add exclude_path:prepass noforwardadd

struct Input {
	float2 uv_Control1 : TEXCOORD0;
	float2 uv_Splat4 : TEXCOORD1;
	float2 uv_Splat5 : TEXCOORD2;
	float2 uv_Splat6 : TEXCOORD3;
	float2 uv_Splat7 : TEXCOORD4;
};

sampler2D _Control1;
sampler2D _Splat4,_Splat5,_Splat6,_Splat7;
sampler2D _Normal4, _Normal5, _Normal6, _Normal7;

half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {
    half NdotL = dot (s.Normal, lightDir);
    half diff = NdotL * 0.5 + 0.5;
    half4 c;
    c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
    c.a = s.Alpha;
    return c;
}
          
void surf (Input IN, inout SurfaceOutput o) {
	float4 splat_control = tex2D (_Control1, IN.uv_Control1);
		
	float4 col;
	col  = splat_control.r * tex2D (_Splat4, IN.uv_Splat4);
	col += splat_control.g * tex2D (_Splat5, IN.uv_Splat5);
	col += splat_control.b * tex2D (_Splat6, IN.uv_Splat6);
	col += splat_control.a * tex2D (_Splat7, IN.uv_Splat7);
	
	float4 nrm;
	nrm  = splat_control.r * tex2D(_Normal4, IN.uv_Splat4);
	nrm	+= splat_control.g * tex2D(_Normal5, IN.uv_Splat5);
	nrm	+= splat_control.b * tex2D(_Normal6, IN.uv_Splat6);
	nrm += splat_control.a * tex2D(_Normal7, IN.uv_Splat7);
		
	o.Albedo = col.rgb;
	o.Alpha = 1;
	o.Normal = 	normalize(UnpackNormal(nrm));
}
ENDCG 

CGPROGRAM
#pragma target 3.0
#pragma debug
#pragma surface surf WrapLambert decal:add exclude_path:prepass noforwardadd

struct Input {
	float2 uv_Control2 : TEXCOORD0;
	float2 uv_Splat8 : TEXCOORD1;
	float2 uv_Splat9 : TEXCOORD2;
	float2 uv_Splat10 : TEXCOORD3;
	float2 uv_Splat11 : TEXCOORD4;
};

sampler2D _Control2;
sampler2D _Splat8,_Splat9,_Splat10,_Splat11;
sampler2D _Normal8, _Normal9, _Normal10, _Normal11;

half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {
    half NdotL = dot (s.Normal, lightDir);
    half diff = NdotL * 0.5 + 0.5;
    half4 c;
    c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
    c.a = s.Alpha;
    return c;
}
          
void surf (Input IN, inout SurfaceOutput o) {
	float4 splat_control = tex2D (_Control2, IN.uv_Control2);
		
	float4 col;
	col  = splat_control.r * tex2D (_Splat8, IN.uv_Splat8);
	col += splat_control.g * tex2D (_Splat9, IN.uv_Splat9);
	col += splat_control.b * tex2D (_Splat10, IN.uv_Splat10);
	col += splat_control.a * tex2D (_Splat11, IN.uv_Splat11);
	
	float4 nrm;
	nrm  = splat_control.r * tex2D(_Normal8, IN.uv_Splat8);
	nrm	+= splat_control.g * tex2D(_Normal9, IN.uv_Splat9);
	nrm	+= splat_control.b * tex2D(_Normal10, IN.uv_Splat10);
	nrm += splat_control.a * tex2D(_Normal11, IN.uv_Splat11);
		
	o.Albedo = col.rgb;
	o.Alpha = 1;
	o.Normal = 	normalize(UnpackNormal(nrm));
}
ENDCG  
}

Fallback "Diffuse"
}
