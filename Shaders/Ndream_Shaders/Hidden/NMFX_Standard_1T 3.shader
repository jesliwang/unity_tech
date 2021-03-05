// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/COF/FX/NMFX_Standard_1T 3"
{
    Properties
    {
        _Color			("Color", Color)			= (1.0,1.0,1.0,1.0)
        _MainTex		("MainTex (RGB)", 2D)		= "white" {}
        [NoScaleOffset]
        _MainTransTex	("MainTex Trans (R)", 2D)	= "white" {}

        [Toggle]
        _IsGray			("Gray", Float)				= 0

        [Space(20)]
        [KeywordEnum(2Sides, Back, Front)]
        _Cull			( "Culling" , Int)			= 2
        [Toggle]
        _IsZWrite		( "ZWrite" , Int)			= 0
    }
	

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        AlphaTest Greater .01
        Lighting Off
        Cull [_Cull]
        ZWrite [_IsZWrite]
        

        SubShader
        {
            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                
                fixed4 _Color;
                sampler2D _MainTex;
                sampler2D _MainTransTex;
                float4 _MainTex_ST;
                float4 _MainTransTex_ST;
                fixed _IsGray;

				float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
				float4 _ClipArgs0 = float4(1000.0, 1000.0, 0.0, 1.0);
				float4 _ClipRange1 = float4(0.0, 0.0, 1.0, 1.0);
				float4 _ClipArgs1 = float4(1000.0, 1000.0, 0.0, 1.0);
				float4 _ClipRange2 = float4(0.0, 0.0, 1.0, 1.0);
				float4 _ClipArgs2 = float4(1000.0, 1000.0, 0.0, 1.0);


				float2 Rotate (float2 v, float2 rot)
				{
					float2 ret;
					ret.x = v.x * rot.y - v.y * rot.x;
					ret.y = v.x * rot.x + v.y * rot.y;
					return ret;
				}

                
				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;
				};
                
                
                struct v2f
                {
                    float4 vertex	: POSITION;
                    float2 uv		: TEXCOORD0;
                    fixed4 color	: COLOR;
					float4 worldPos : TEXCOORD1;
					float2 worldPos2: TEXCOORD2;
                };
                

                v2f vert(appdata_t v)
                {
                    v2f o;
                    
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
					o.worldPos.xy = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
					o.worldPos.zw = Rotate(v.vertex.xy, _ClipArgs1.zw) * _ClipRange1.zw + _ClipRange1.xy;
					o.worldPos2 = Rotate(v.vertex.xy, _ClipArgs2.zw) * _ClipRange2.zw + _ClipRange2.xy;
                    o.color = v.color * _Color;
                    
                    return o;
                }
                
                
                fixed4 frag(v2f i) : COLOR
                {
                	fixed4 finalColor = fixed4(0, 0, 0, 0);
                	
                	fixed4 mainTex		= tex2D (_MainTex,i.uv.xy);
                	fixed4 mainTransTex	= tex2D (_MainTransTex,i.uv.xy);
                	
                	mainTex.a = mainTransTex.r;
                	
                    finalColor = mainTex * i.color;

					fixed3 grayColor = finalColor.r*0.3 + finalColor.g*0.59 + finalColor.b*0.11;
					finalColor.rgb = lerp(finalColor, grayColor, _IsGray);

					// Softness factor
					fixed2 factor = (fixed2(1.0, 1.0) - abs(i.worldPos.xy)) * _ClipArgs0.xy;
					fixed f = min(factor.x, factor.y);
					factor = (fixed2(1.0, 1.0) - abs(i.worldPos.zw)) * _ClipArgs1.xy;
					f = min(f, min(factor.x, factor.y));
					factor = (fixed2(1.0, 1.0) - abs(i.worldPos2)) * _ClipArgs2.xy;
					f = min(f, min(factor.x, factor.y));
					fixed fade = clamp(f, 0.0, 1.0);
					finalColor.a *= fade;
					finalColor.rgb = lerp(fixed3(0.0, 0.0, 0.0), finalColor.rgb, fade);
                    
                    return finalColor;
                }
                ENDCG
            }  
        }
	}
}


