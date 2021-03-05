// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Background/WOT_Space" {
   Properties {
      _MainTex ("Texture", Rect) = "white" {}
      _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	  _Speed ("Move Speed", float) = 0.12
   }
   SubShader {

      Pass {

         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag

         #include "UnityCG.cginc" 

         uniform sampler2D _MainTex;
         uniform float4 _Color;
		 uniform fixed _Speed;
 
		 
         struct v2f {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
         };
 
		 v2f vert(appdata_base v)
         {
            v2f o;
			float f = sin(_Time.x) * _Speed;
			o.pos = UnityObjectToClipPos(v.vertex);
			float4 screenPos = ComputeScreenPos(o.pos);
			o.uv = (screenPos.xy / screenPos.w) + float2(f, 0);
            return o;
         }
 
         float4 frag(v2f i) : COLOR
         {
            return _Color * tex2D(_MainTex, i.uv);
         }
 
         ENDCG
      }
   }
		  Fallback Off
}