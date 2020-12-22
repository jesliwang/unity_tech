 
Shader "TAD/BackFacingForVerCol" 
{
	Properties 
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Outline ("Outline", float) = 0.1
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
	}
    SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass {
			NAME "OUTLINEVERCOL"
			
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			float _Outline;
			fixed4 _OutlineColor;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 color : COLOR;
			}; 
			
			struct v2f {
			    float4 pos : SV_POSITION;
			};
			
			v2f vert (a2v v) {
				v2f o;
				
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
				float3 norcol = v.color.xyz;
				norcol = (norcol - 0.5) * 2.0;
				float3 expend = mul((float3x3)UNITY_MATRIX_IT_MV, norcol);
				pos = pos + float4(normalize(expend), 0) * _Outline * v.color.w;
				o.pos = mul(UNITY_MATRIX_P, pos);
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				return float4(_OutlineColor.rgb, 1);               
			}
			
			ENDCG
		}
 
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }
				Cull Back
				CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				fixed4 diff : COLOR0;
				float4 vertex : SV_POSITION;
			};
 
			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				o.diff = nl * _LightColor0;
 
				o.diff.rgb += ShadeSH9(half4(worldNormal,1));
				return o;
			}
 
			sampler2D _MainTex;
 
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
			col *= i.diff;
			return col;
			}
				ENDCG
			}
 
	}
}