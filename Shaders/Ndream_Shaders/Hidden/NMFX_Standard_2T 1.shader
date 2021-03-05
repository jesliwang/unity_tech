// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/COF/FX/NMFX_Standard_2T 1"
{
    Properties
    {
        _Color			("Color", Color)			= (1.0,1.0,1.0,1.0)
        _MainTex		("MainTex (RGB)", 2D)		= "white" {}
        [NoScaleOffset]
        _MainTransTex	("MainTex Trans (R)", 2D)	= "white" {}
        _MainTex1		("MainTex1 (RGB)", 2D)		= "white" {}
        [NoScaleOffset]
        _MainTransTex1	("MainTex1 Trans (R)", 2D)	= "white" {}
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
                sampler2D _MainTex1;
                sampler2D _MainTransTex;
                sampler2D _MainTransTex1;
                fixed4 _MainTex_ST; 
                fixed4 _MainTex1_ST;
                fixed4 _MainTransTex_ST;
                fixed4 _MainTransTex1_ST;
                
				fixed4 _ClipRange0 = fixed4(0.0, 0.0, 1.0, 1.0);
				fixed4 _ClipArgs0 = fixed4(1000.0, 1000.0, 0.0, 1.0);
                
                
				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;
				};
                
                
                struct v2f
                {
                    fixed4 vertex	: POSITION;
                    fixed4 uv		: TEXCOORD0;
                    fixed4 color	: COLOR;
                    fixed2 worldPos : TEXCOORD1;
                };
                

                v2f vert(appdata_t v)
                {
                    v2f o;
                    
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    
                    o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
                    o.uv.zw = TRANSFORM_TEX(v.texcoord.xy,_MainTex1);
                    
                    o.color = v.color;
                    o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
                    
                    return o;
                }
                
                
                fixed4 frag(v2f i) : COLOR
                { 
                	fixed4 finalColor = fixed4(0, 0, 0, 0);
                	
                	fixed4 mainTex			= tex2D (_MainTex,i.uv.xy);
                	fixed4 mainTransTex		= tex2D (_MainTransTex,i.uv.xy);
                	fixed4 mainTex1 		= tex2D (_MainTex1,i.uv.zw);
                	fixed4 mainTransTex1	= tex2D (_MainTransTex1,i.uv.zw);
                	mainTex.a	= mainTransTex.r;
                	mainTex1.a	= mainTransTex1.r;
                	
					float2 factor = (float2(1.0, 1.0) - abs(i.worldPos)) * _ClipArgs0.xy;
					float fade = clamp(min(factor.x, factor.y), 0.0, 1.0);
                	
                	finalColor = mainTex * mainTex1 * _Color * i.color;
                    finalColor.rgb = lerp(half3(0.0, 0.0, 0.0), finalColor.rgb, fade);
                    finalColor.a *= fade;
                    
                    return finalColor;
                }
                ENDCG
            }  
        }
	}
}


