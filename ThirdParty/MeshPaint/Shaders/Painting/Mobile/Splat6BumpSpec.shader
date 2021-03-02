Shader "MeshPaint/Mobile/Splat6BumpSpec" {
Properties {
	_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
	_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
	_Gloss ("Gloss", Range (0.03, 1)) = 0.5
	
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
}
	
SubShader {
	Tags {
		"SplatCount" = "8"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
	
CGPROGRAM
#pragma target 3.0
#pragma debug
#pragma surface surf WrapLambertSpec exclude_path:prepass nolightmap noforwardadd halfasview interpolateview

struct Input {
	float2 uv_Control0 : TEXCOORD0;
	float2 uv_Splat0 : TEXCOORD1;
	float2 uv_Splat1 : TEXCOORD2;
	float2 uv_Splat2 : TEXCOORD3;
};

sampler2D _Control0;
sampler2D _Splat0,_Splat1,_Splat2;
sampler2D _Normal0, _Normal1, _Normal2;

half _Shininess;
half _Gloss;

inline fixed4 LightingWrapLambertSpec (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
{
	fixed diff = max (0, dot (s.Normal, lightDir)) * 0.5 + 0.5;
	fixed nh = max (0, dot (s.Normal, halfDir));
	fixed spec = pow (nh, s.Gloss*128) * s.Specular;

	fixed4 c;
	c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * atten;
	c.a = 1;
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
		o.Gloss = _Gloss;
		o.Normal = 	normalize(UnpackNormal(nrm));
		o.Specular = _Shininess * col.a;
}
ENDCG 

CGPROGRAM
#pragma target 3.0
#pragma debug
#pragma surface surf WrapLambertSpec decal:add exclude_path:prepass nolightmap noforwardadd halfasview interpolateview

struct Input {
	float2 uv_Control1 : TEXCOORD0;
	float2 uv_Splat3 : TEXCOORD1;
	float2 uv_Splat4 : TEXCOORD2;
	float2 uv_Splat5 : TEXCOORD3;
};

sampler2D _Control1;
sampler2D _Splat3,_Splat4,_Splat5;
sampler2D _Normal3, _Normal4, _Normal5;

half _Shininess;
half _Gloss;
	
inline fixed4 LightingWrapLambertSpec (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
{
	fixed diff = max (0, dot (s.Normal, lightDir)) * 0.5 + 0.5;
	fixed nh = max (0, dot (s.Normal, halfDir));
	fixed spec = pow (nh, s.Gloss*128) * s.Specular;

	fixed4 c;
	c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * atten;
	c.a = 1;
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
	o.Gloss = _Gloss;
	o.Normal = 	normalize(UnpackNormal(nrm));
	o.Specular = _Shininess * col.a;
}
ENDCG  
}

Fallback "Diffuse"
}