// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/WOT/FX/WOT_FX 3"
{
    Properties
    {
		[Space(20)]
		//[Enum]_BlendMode("Blend Mode", Float) = 0
		[Enum]_BlendMode("Blend Mode", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]	_SrcBlend("Src Factor", Float) = 5  // SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)]	_DstBlend("Dst Factor", Float) = 10 // OneMinusSrcAlpha

		[Enum]_TexNumbMode("Texture Number", Float) = 0
		[Enum]_AlphaTexNumbMode("Texture Number", Float) = 1
		[Enum]_AlphaTexNumb_AlphaMode("Texture Number", Float) = 0
		[Toggle(USEMASKUV)] _UseMaskUV("Use Mask UV", Int) = 0

		//dissolve
		_EdgeColor1("Edge color 1", Color) = (1.0, 1.0, 1.0, 1.0)
		_EdgeColor2("Edge color 2", Color) = (1.0, 1.0, 1.0, 1.0)
		_Level("Dissolution level", Range(0.0, 1.0)) = 0.1
		_Edges("Edge width", Range(0.0, 1.0)) = 0.1

		_Color		("Color", Color)				= (1.0,1.0,1.0,1.0)
		_ColorPower("ColorPower", Range(1, 5)) = 1.0

		_MainTex						("MainTex 1 (RGB)", 2D)	= "white" {}
		//[Noscaleoffset]_MainTransTex	("_Mask 1 (R)", 2D)		= "white" {}
		_MainTransTex	("Mask 1 (R)", 2D)		= "white" {}
		_MainTex1						("MainTex 2 (RGB)", 2D)	= "white" {}
		//[Noscaleoffset]_MainTransTex1	("_Mask 2 (R)", 2D)		= "white" {}
		_MainTransTex1	("Mask 2 (R)", 2D)		= "white" {}
		_MainTex2						("MainTex 3 (RGB)", 2D) = "white" {}
		//[Noscaleoffset]_MainTransTex2	("_Mask 3 (R)", 2D)		= "white" {}
		_MainTransTex2	("Mask 3 (R)", 2D)		= "white" {}

        [KeywordEnum(2Sides, Back, Front)]
        _Cull		( "Culling" , Int)			= 2
        [Toggle]
        _IsZWrite	( "ZWrite" , Int)			= 0
	}
	
	
	Category
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend[_SrcBlend][_DstBlend]

		AlphaTest Greater .01
        Lighting Off
        Cull [_Cull]
        ZWrite [_IsZWrite]
		Fog {mode off}	
		
		
		SubShader
		{
			Pass 
			{
				CGPROGRAM
//				#pragma fragmentoption ARB_precision_hint_fastest 
				#pragma target 2.0
				#pragma vertex vert
				#pragma fragment frag
				//#pragma shader_feature TEXTURE0
				//#pragma shader_feature TEXTURE1
				//#pragma shader_feature TEXTURE2
				//#pragma shader_feature TEXTURE3
				//#pragma shader_feature ALPHABLEND
				//#pragma shader_feature USEMASKUV
				////#pragma shader_feature USEMASK
				//#pragma shader_feature DISSOLVE

				#pragma multi_compile __ TEXTURE0 TEXTURE1 TEXTURE2 TEXTURE3
				#pragma multi_compile __ ALPHABLEND //DISSOLVE
				#pragma multi_compile __ USEMASK

				#include "UnityCG.cginc"

				//----- NGUI Hidden  ---------------------------------------------
				float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
				float4 _ClipArgs0 = float4(1000.0, 1000.0, 0.0, 1.0);
				float4 _ClipRange1 = float4(0.0, 0.0, 1.0, 1.0);
				float4 _ClipArgs1 = float4(1000.0, 1000.0, 0.0, 1.0);
				float4 _ClipRange2 = float4(0.0, 0.0, 1.0, 1.0);
				float4 _ClipArgs2 = float4(1000.0, 1000.0, 0.0, 1.0);

				float2 Rotate(float2 v, float2 rot)
				{
					float2 ret;
					ret.x = v.x * rot.y - v.y * rot.x;
					ret.y = v.x * rot.x + v.y * rot.y;
					return ret;
				}
				//----- NGUI Hidden  ---------------------------------------------

				#include "Assets/Resources/Shaders/FX/Cginc_WOT_FX.cginc"	

				//----- cginc용 단락 ---------------------------------------------
				//struct appdata_t
				//{
					float4 worldPos : TEXCOORD3;
					float2 worldPos2 : TEXCOORD4;
				};
				//----- cginc용 단락 ---------------------------------------------





				
				v2f vert(appdata_t v)
				{
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);

					o.vertex = UnityObjectToClipPos(v.vertex);

#ifdef ALPHABLEND
	#ifdef TEXTURE0
						o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTransTex);
	#endif
	#ifdef TEXTURE1
		#ifdef USEMASKUV
						o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex); 
						o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTransTex);
		#else
						o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
		#endif
	#endif
	#ifdef TEXTURE2
		#ifdef USEMASKUV
							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
							o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _MainTransTex);
							o.uv1.zw = TRANSFORM_TEX(v.texcoord1.xy, _MainTransTex1);
		#else
							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
		#endif
	#endif
#ifdef TEXTURE3
	#ifdef USEMASKUV
							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
							o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _MainTex2);
							o.uv1.zw = TRANSFORM_TEX(v.texcoord1.xy, _MainTransTex);
							o.uv2.xy = TRANSFORM_TEX(v.texcoord2.xy, _MainTransTex1);
							o.uv2.zw = TRANSFORM_TEX(v.texcoord2.xy, _MainTransTex2);
	#else
							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
							o.uv1.xy = TRANSFORM_TEX(v.texcoord1.xy, _MainTex2);
	#endif
#endif

#else	//additive, multiply, dissolve
	//#ifdef (TEXTURE1) || (DISSOLVE)
	#ifdef TEXTURE1
							//o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
							o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
	#endif
	#ifdef TEXTURE2
							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
	#endif
	#ifdef TEXTURE3
							o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
							o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _MainTex1);
							o.uv1.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex2);
	#endif
#endif 
					o.worldPos.xy = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
					o.worldPos.zw = Rotate(v.vertex.xy, _ClipArgs1.zw) * _ClipRange1.zw + _ClipRange1.xy;
					o.worldPos2 = Rotate(v.vertex.xy, _ClipArgs2.zw) * _ClipRange2.zw + _ClipRange2.xy;
					o.color = v.color * _Color * _ColorPower;

					return o;
				}
				 
				
				fixed4 frag(v2f i) : COLOR
				{
					fixed4 finalColor = fixed4 (1,1,1,1);

//#ifdef DISSOLVE		//Dissove
//					float cutout = tex2D(_MainTransTex, i.uv.xy).r;
//					fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
//
//					if (cutout < _Level)
//						discard;
//
//					if (cutout < mainTex.a && cutout < _Level + _Edges)
//						mainTex = lerp(_EdgeColor1, _EdgeColor2, (cutout - _Level) / _Edges);
//
//					finalColor = mainTex;
//#elif ALPHABLEND	//Alphablend
#ifdef ALPHABLEND	//Alphablend
	#ifdef TEXTURE0
					fixed4 mainTransTex = tex2D(_MainTransTex, i.uv.xy);
					finalColor.a = mainTransTex.r;

					finalColor *= i.color;
	#endif
	#ifdef TEXTURE1
					fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
		#ifdef  USEMASKUV
						fixed mainTransTex = tex2D(_MainTransTex, i.uv.zw);
						mainTex.a = mainTransTex;
		#else
						fixed mainTransTex = tex2D(_MainTransTex, i.uv.xy);
						mainTex.a = mainTransTex;
		#endif
					finalColor = mainTex * i.color;
	#endif
	#ifdef TEXTURE2
					fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
					fixed4 mainTex1 = tex2D(_MainTex1, i.uv.zw);
		#ifdef  USEMASKUV
							fixed mainTransTex = tex2D(_MainTransTex, i.uv1.xy);
							fixed mainTransTex1 = tex2D(_MainTransTex1, i.uv1.zw);
							mainTex.a = mainTransTex;
							mainTex1.a = mainTransTex1;
		#else
						fixed mainTransTex = tex2D(_MainTransTex, i.uv.xy);
						fixed mainTransTex1 = tex2D(_MainTransTex1, i.uv.zw);
						mainTex.a = mainTransTex;
						mainTex1.a = mainTransTex1;
		#endif
					finalColor = mainTex * mainTex1 * i.color;
	#endif
	#ifdef TEXTURE3
				fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
				fixed4 mainTex1 = tex2D(_MainTex1, i.uv.zw);
				fixed4 mainTex2 = tex2D(_MainTex2, i.uv1.xy);
		#ifdef USEMASKUV
						fixed mainTransTex = tex2D(_MainTransTex, i.uv1.zw);
						fixed mainTransTex1 = tex2D(_MainTransTex1, i.uv2.xy);
						fixed mainTransTex2 = tex2D(_MainTransTex2, i.uv2.zw);
						mainTex.a = mainTransTex;
						mainTex1.a = mainTransTex1;
						mainTex2.a = mainTransTex2;
		#else
						fixed mainTransTex = tex2D(_MainTransTex, i.uv.xy);
						fixed mainTransTex1 = tex2D(_MainTransTex1, i.uv.zw);
						fixed mainTransTex2 = tex2D(_MainTransTex2, i.uv1.xy);
						mainTex.a = mainTransTex;
						mainTex1.a = mainTransTex1;
						mainTex2.a = mainTransTex2;
		#endif
					finalColor = mainTex * mainTex1 * mainTex2 * i.color;
	#endif
#else	//Additive, Multiply
	#ifdef TEXTURE0
						finalColor.rgb *= i.color.rgb * _Color.a;
	#endif 
	#ifdef TEXTURE1
						fixed4 mainTex = tex2D(_MainTex, i.uv);
						finalColor.rgb = mainTex.rgb * i.color.rgb * i.color.a;
	#endif 
	#ifdef TEXTURE2
						fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
						fixed4 mainTex1 = tex2D(_MainTex1, i.uv.zy);
						finalColor.rgb = mainTex.rgb * mainTex1.rgb * i.color.rgb * i.color.a;
	#endif 
	#ifdef TEXTURE3
						fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
						fixed4 mainTex1 = tex2D(_MainTex1, i.uv.zw);
						fixed4 mainTex2 = tex2D(_MainTex2, i.uv1.xy);
						finalColor.rgb = mainTex.rgb * mainTex1.rgb * mainTex2.rgb * i.color.rgb * i.color.a;
	#endif 
#endif

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
	CustomEditor "ShaderGUI_WOT_FX"
}
