// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "WOT/Common/WOT_FakeShadow"
{
	Properties
	{
		_FakeLightDir("Light Direction", vector) = (0, 0, 0, 0)
		_FakeShadowColor("Shadow Color", color) = (0, 0, 0, 0)
        _FakeShadowHeightDefault ("Shadow Height Default", float) = 0.01
        _FadeOut ("FadeOut", float) = 1
	}
	

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        AlphaTest Greater .01
        Lighting Off
        Cull [_Cull]
        ZWrite [_IsZWrite]
        //ZWrite On
		SubShader
		{
			Pass
			{
				Stencil
				{
					Ref 0
					Comp Equal
					Pass IncrWrap
					ZFail Keep
				}
				
				
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_instancing
				#pragma target 3.0
				#include "UnityCG.cginc"
				
				
				float4	_FakeLightDir;
				float4	_FakeShadowColor;
				float	_FakeShadowHeightDefault;
				float	_FakeShadowHeightOffset;
				float	_FadeOut;

				struct appdata_t
				{
					float4 vertex	: POSITION;
					float2 texcoord : TEXCOORD0;
					half4 color		: COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
                
				
				struct v2f 
				{
					float4 pos	: SV_POSITION;
					float4 color: COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				
				v2f vert( appdata_t v )
				{
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					UNITY_SETUP_INSTANCE_ID(v);
					
					float4 vertPosWorld = mul( unity_ObjectToWorld, v.vertex);
					float4 lightDir = -normalize(_FakeLightDir);
					float shadowHeight = _FakeShadowHeightDefault + _FakeShadowHeightOffset;
					float opposite = vertPosWorld.y - shadowHeight;
					float cosTheta = -lightDir.y;
					float hypotenuse = opposite / cosTheta;
					float3 vertPos = vertPosWorld.xyz + (lightDir.xyz * hypotenuse);

					float4 pivotPosWorld = mul( unity_ObjectToWorld, float4(0,0,0,1));
					pivotPosWorld.z = vertPos.z;
					float dist = distance (pivotPosWorld.xyz, vertPos);
					o.color = v.color;
					o.color.a = 1 - saturate(dist*_FadeOut);

					o.pos = mul (UNITY_MATRIX_VP, float4(vertPos.x, shadowHeight, vertPos.z ,1));

					return o;
				}
				
				
				float4 frag( v2f i ) : COLOR
				{
					UNITY_SETUP_INSTANCE_ID(i);
					
					float4 c;
					
					c = _FakeShadowColor;
					c.a *= i.color.a;

					return c;
				}
				ENDCG
			}
		}
	}
}