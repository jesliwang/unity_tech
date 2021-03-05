// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WOT/Background/WOT_Field_Foam"
{
	Properties
	{
		[Header(Foam______________________________________________)]
		//_Color				("Color", Color)			= (1,1,1,1)
		[Space(10)]
		_FoamAlpha("Foam Alpha", Range(0,10)) = 2
		_FoamRange("Foam Range", Range(0,3)) = 1
		_FoamPower("Foam Power", Range(0,20)) = 3

		[Space(20)]
		_FoamTex ("Foam", 2D) = "white" {}
		_FoamTexSize ("Size", int) = 1
		_FoamTex_X ("Foam speed X", Float) = 1.0
		_FoamTex_Y ("Foam speed Y", Float) = 0.0
		
		_FoamTex1("Foam1", 2D) = "white" {}
		_FoamTex1Size ("Size", int) = 1
		_FoamTex1_X ("Foam1 speed X", Float) = 1.0
		_FoamTex1_Y ("Foam1 speed Y", Float) = 0.0

		_FoamMaskTex("Foam Mask", 2D) = "white" {}
		
		

		//[Space(40)]
		//[Header(Wave______________________________________________)]
		//_WaveTex			("Wave", 2D)				= "black" {}
		//_WaveTexSize		("Size", int)				= 1
		//_WaveMoveMaskTex	("Wave Move Mask", 2D)		= "black" {}
		////_WaveTex_X			("Wave speed X", Float)		= 1.0
		////_WaveTex_Y			("Wave speed Y", Float)		= 0.0

		//_WaveMaskTex		("Wave Mask", 2D)			= "black" {}
		//
		////_ColorPower			("Color Power", Float)		= 2.0

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

                
				//fixed4 _Color;
				
				sampler2D _FoamTex;
				sampler2D _FoamTex1;
				sampler2D _FoamMaskTex;
				sampler2D _WaveTex;
				sampler2D _WaveMaskTex;
				sampler2D _WaveMoveMaskTex;
				
				fixed4 _FoamTex_ST;
				fixed4 _FoamTex1_ST;
				fixed4 _FoamMaskTex_ST;
				fixed4 _WaveTex_ST;
				fixed4 _WaveMaskTex_ST;
				fixed4 _WaveMoveMaskTex_ST;

				int _FoamTexSize;
				int _FoamTex1Size;
				int _WaveTexSize;
				
				fixed _FoamTex_X;
				fixed _FoamTex_Y;
				fixed _FoamTex1_X;
				fixed _FoamTex1_Y;
				//fixed _WaveTex_X;
				//fixed _WaveTex_Y;

				fixed _FoamAlpha;
				fixed _FoamRange;
				fixed _FoamPower;
				//fixed _ColorPower;
				

				struct v2f
				{
					fixed4 pos			: POSITION;
					float4 foam_uv		: TEXCOORD0;
					float2 foamMask_uv	: TEXCOORD1;
					float2 wave_uv		: TEXCOORD2;
					float2 moveMask_uv	: TEXCOORD3;
					//fixed4 color		: TEXCOORD4;
				};
			 
				 
				v2f vert (appdata_full v)
				{
					v2f o;
					
					o.pos = UnityObjectToClipPos(v.vertex);


					float2 baseUV = TRANSFORM_TEX(v.texcoord.xy,_FoamTex);

					float time = _Time;
					float tu = fmod(time*_FoamTex_X, 1);
					float tv = fmod(time*_FoamTex_Y, 1);
					o.foam_uv.xy = (baseUV + float2(tu, tv)) *_FoamTexSize;

					tu = fmod(time*_FoamTex1_X, 1);
					tv = fmod(time*_FoamTex1_Y, 1);
					o.foam_uv.zw = (baseUV + float2(tu, tv)) *_FoamTex1Size;

					o.foamMask_uv = baseUV;

					//tu = fmod(time*_WaveTex_X, 1);
					//tv = fmod(time*_WaveTex_Y, 1);
					o.wave_uv = (baseUV /*+ float2(tu, tv)*/) *_WaveTexSize;

					o.moveMask_uv = baseUV;


					//o.color = _ColorPower * _Color * v.color;
					
					return o;
				}
			 

				fixed4 frag (v2f i) : COLOR
				{
					fixed4 finalColor = fixed4(0, 0, 0, 0);
					
					fixed4 foamTex			= tex2D (_FoamTex, i.foam_uv.xy);
					fixed4 foamTex1			= tex2D (_FoamTex1, i.foam_uv.zw);

					fixed foamMaskTex		= tex2D (_FoamMaskTex, i.foamMask_uv).r;
					foamMaskTex = pow(foamMaskTex, _FoamRange);

					fixed4 waveTex			= tex2D (_WaveTex, i.wave_uv);
					fixed4 waveMoveMaskTex	= tex2D (_WaveMoveMaskTex, i.wave_uv);
					fixed4 waveMaskTex		= tex2D (_WaveMaskTex, i.moveMask_uv);
					
					fixed4 foamColor = pow((foamTex * foamTex1) , _FoamAlpha) * _FoamPower;
					//fixed4 foamColor = (foamTex * foamTex1)* _FoamAlpha;
					
					finalColor.rgb	= (foamColor + waveTex) /** i.color.rgb*/;
					finalColor.a	= (foamColor*foamMaskTex) /*+ ((foamColor*waveMoveMaskTex + waveTex) * waveMaskTex)*/;
					//finalColor.a	*= i.color.a;
					
					return finalColor;
				}
				ENDCG
			}
        }
	}
}