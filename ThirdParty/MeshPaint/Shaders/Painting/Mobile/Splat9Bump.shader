Shader "MeshPaint/Mobile/Splat9Bump" {
Properties {
	_Control0 ("Control (RGBA)", 2D) = "black" {}
	_Splat2 ("Ch (B)", 2D) = "white" {}
	_Splat1 ("Ch (G)", 2D) = "white" {}
	_Splat0 ("Ch (R)", 2D) = "white" {}
	
	_Normal2 ("N (B)", 2D) = "bump" {}
	_Normal1 ("N (G)", 2D) = "bump" {}
	_Normal0 ("N (R)", 2D) = "bump" {}
	
	_Control1 ("Control1 (RGBA)", 2D) = "black" {}
	_Splat5 ("Ch (B)", 2D) = "white" {}
	_Splat4 ("Ch (G)", 2D) = "white" {}
	_Splat3 ("Ch (R)", 2D) = "white" {}	
	
	_Normal5 ("N (B)", 2D) = "bump" {}
	_Normal4 ("N (G)", 2D) = "bump" {}
	_Normal3 ("N (R)", 2D) = "bump" {}
	
	_Control2 ("Control2 (RGBA)", 2D) = "black" {}
	_Splat8 ("Ch (B)", 2D) = "white" {}
	_Splat7 ("Ch (G)", 2D) = "white" {}
	_Splat6 ("Ch (R)", 2D) = "white" {}	
	
	_Normal8 ("N (B)", 2D) = "bump" {}
	_Normal7 ("N (G)", 2D) = "bump" {}
	_Normal6 ("N (R)", 2D) = "bump" {}
}
	
SubShader {
	Tags {
		"SplatCount" = "9"
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
};

sampler2D _Control0;
sampler2D _Splat0,_Splat1,_Splat2;
sampler2D _Normal0, _Normal1, _Normal2;

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
		
		half4 col;
		col  = splat_control.r * tex2D (_Splat0, IN.uv_Splat0);
		col += splat_control.g * tex2D (_Splat1, IN.uv_Splat1);
		col += splat_control.b * tex2D (_Splat2, IN.uv_Splat2);
		
		half4 nrm;
		nrm  = splat_control.r * tex2D(_Normal0, IN.uv_Splat0);
		nrm	+= splat_control.g * tex2D(_Normal1, IN.uv_Splat1);
		nrm	+= splat_control.b * tex2D(_Normal2, IN.uv_Splat2);
			
		o.Albedo = col.rgb;
		o.Alpha = 1;
		o.Normal = 	normalize(UnpackNormal(nrm));
}
ENDCG 

CGPROGRAM
#pragma target 3.0
#pragma debug
#pragma surface surf WrapLambert decal:add exclude_path:prepass nolightmap noforwardadd halfasview interpolateview

struct Input {
	float2 uv_Control1 : TEXCOORD0;
	float2 uv_Splat3 : TEXCOORD1;
	float2 uv_Splat4 : TEXCOORD2;
	float2 uv_Splat5 : TEXCOORD3;
};

sampler2D _Control1;
sampler2D _Splat3,_Splat4,_Splat5;
sampler2D _Normal3, _Normal4, _Normal5;

inline fixed4 LightingWrapLambert (SurfaceOutput s, fixed3 lightDir, fixed atten) {
    fixed NdotL = dot (s.Normal, lightDir);
    fixed diff = NdotL * 0.5 + 0.5;
    fixed4 c;
    c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
    c.a = s.Alpha;
    return c;
}
          
void surf (Input IN, inout SurfaceOutput o) {
	half4 splat_control = tex2D (_Control1, IN.uv_Control1);
		
	half4 col;
	col  = splat_control.r * tex2D (_Splat3, IN.uv_Splat3);
	col += splat_control.g * tex2D (_Splat4, IN.uv_Splat4);
	col += splat_control.b * tex2D (_Splat5, IN.uv_Splat5);
	
	half4 nrm;
	nrm  = splat_control.r * tex2D(_Normal3, IN.uv_Splat3);
	nrm	+= splat_control.g * tex2D(_Normal4, IN.uv_Splat4);
	nrm	+= splat_control.b * tex2D(_Normal5, IN.uv_Splat5);
		
	o.Albedo = col.rgb;
	o.Alpha = 1;
	o.Normal = 	normalize(UnpackNormal(nrm));
}
ENDCG 

CGPROGRAM
#pragma target 3.0
#pragma debug
#pragma surface surf WrapLambert decal:add exclude_path:prepass nolightmap noforwardadd halfasview interpolateview

struct Input {
	float2 uv_Control2 : TEXCOORD0;
	float2 uv_Splat6 : TEXCOORD1;
	float2 uv_Splat7 : TEXCOORD2;
	float2 uv_Splat8 : TEXCOORD3;
};

sampler2D _Control2;
sampler2D _Splat6,_Splat7,_Splat8;
sampler2D _Normal6, _Normal7, _Normal8;

inline fixed4 LightingWrapLambert (SurfaceOutput s, fixed3 lightDir, fixed atten) {
    fixed NdotL = dot (s.Normal, lightDir);
    fixed diff = NdotL * 0.5 + 0.5;
    fixed4 c;
    c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
    c.a = s.Alpha;
    return c;
}
          
void surf (Input IN, inout SurfaceOutput o) {
	half4 splat_control = tex2D (_Control2, IN.uv_Control2);
		
	half4 col;
	col  = splat_control.r * tex2D (_Splat6, IN.uv_Splat6);
	col += splat_control.g * tex2D (_Splat7, IN.uv_Splat7);
	col += splat_control.b * tex2D (_Splat8, IN.uv_Splat8);
	
	half4 nrm;
	nrm  = splat_control.r * tex2D(_Normal6, IN.uv_Splat6);
	nrm	+= splat_control.g * tex2D(_Normal7, IN.uv_Splat7);
	nrm	+= splat_control.b * tex2D(_Normal8, IN.uv_Splat8);
		
	o.Albedo = col.rgb;
	o.Alpha = 1;
	o.Normal = 	normalize(UnpackNormal(nrm));
}
ENDCG  
}

Fallback "Diffuse"
}
