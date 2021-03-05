// MatCap Shader, (c) 2015-2019 Jean Moreno

Shader "WOT/Character/WOT_MatCapAdditiveZ"
{
	Properties
	{
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_frenelColor ("Franel Color", Color) = (0.5,0.5,0.5,1)
		//_EmissionColor("Emission Color", Color) = (0,0,0)
		_MatCap ("MatCap (RGB)", 2D) = "white" {}
		_Power ("Power", Range(0, 5)) = 1
		_fresnelPower("Fresnel Power", Range(0, 10)) = 1
			
	}
	
	Subshader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		//Tags { "RenderType"="Opaque" }
		Lighting Off
		
	  //  Pass
	  //  {
			//ColorMask 0
	  //  }
		
		Pass
		{
			ZWrite on
			Cull Off			
			//Blend One OneMinusSrcColor
			Blend SrcAlpha OneMinusSrcAlpha
			//ColorMask RGB
			Lighting Off
			
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_instancing
				#pragma target 3.0
				//#pragma multi_compile_fog
				#include "UnityCG.cginc"
				
				//struct appdata_t
				//{
				//	float4 vertex	: POSITION;
				//	float2 texcoord : TEXCOORD0;
				//	half4 color		: COLOR;
				//};

				struct v2f
				{
					float4 vertex	: SV_POSITION;
					float2 cap	: TEXCOORD0;
					float3 fresnel : COLOR;
					//UNITY_FOG_COORDS(1)
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				
				uniform fixed _fresnelPower;

				v2f vert (appdata_base v)
				{
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					UNITY_SETUP_INSTANCE_ID(v);

					o.vertex = UnityObjectToClipPos(v.vertex);
					
					float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
					worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
					o.cap.xy = worldNorm.xy * 0.5 + 0.5;

					float3 viewDir = normalize(v.vertex - _WorldSpaceCameraPos.xyz);
					float3 fresnel = pow(saturate(1 - dot(worldNorm, viewDir)),  _fresnelPower);

					o.fresnel = fresnel;
					
					//UNITY_TRANSFER_FOG(o, o.vertex);

					return o;
				}
				
				uniform float4 _Color;
				uniform float4 _frenelColor;
				uniform float4 _EmissionColor;
				uniform sampler2D _MatCap;
				uniform fixed _Power;

				
				float4 frag (v2f i) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);

					float4 mc = tex2D(_MatCap, i.cap) * _Color * unity_ColorSpaceDouble * _Power;
					//UNITY_APPLY_FOG_COLOR(i.fogCoord, mc, float4(0,0,0,0));
					
					float4 finalColor = mc * _Color;

					float3 imission = _frenelColor.rgb *  i.fresnel;

					//finalColor.rgb = lerp(finalColor.rgb, _frenelColor, imission);

					finalColor.rgb += imission;
					finalColor.a = _Color.a;
				
					return finalColor;
				}
			ENDCG
		}
	}
	
	//Fallback "VertexLit"
}
