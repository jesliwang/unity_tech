Shader "Hidden/MeshPaint/ProjectorAdditiveTint" {
	Properties {
		_Color ("Tint Color", Color) = (0,1,1,1)
		_MainTex ("Cookie", 2D) = "gray" {}
	}
	Subshader {
		Tags {"Queue"="Transparent"}
		Pass {
			ZWrite Off
			ColorMask RGB
			Blend SrcAlpha One // Additive blending
			Offset -1, -1

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f {
				float4 uvShadow : TEXCOORD0;
				float4 pos : SV_POSITION;
			};
			
			float4x4 unity_Projector;
			
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (vertex);
				o.uvShadow = mul (unity_Projector, vertex);
				return o;
			}
			
			sampler2D _MainTex;
			fixed4 _Color;
			
			fixed4 frag (v2f i) : SV_Target
			{
				clip(i.uvShadow.xyw);
		        clip(1.0 - i.uvShadow.xy);
				fixed4 texCookie = tex2Dproj (_MainTex, UNITY_PROJ_COORD(i.uvShadow));
				fixed4 outColor = _Color * texCookie.a;
				return outColor;
			}
        
			ENDCG
		}
	}
}