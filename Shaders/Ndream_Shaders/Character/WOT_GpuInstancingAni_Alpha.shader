Shader "WOT/Character/WOT_GpuInstancingAni_Alpha"
{
	Properties
	{	
		[Space(10)]
		[Header(MAIN__________________________________________________________)]
		_Color("Color", color) = (1.0, 1.0, 1.0, 1.0)
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		_Bright("Bright", Range(0, 2)) = 1
		_Contrast("Contrast", Range(0, 2)) = 1
		[NoScaleOffset]_TransTex("TransTex (R)", 2D) = "white" {}
		_Alpha("Alpha", Range(0,1)) = 1

		//Gpu Instancing Ani
		[Space(10)]
		[Header(GPU Instancing Ani____________________________________________)]
		_AnimMap("AnimMap", 2D) = "white" {}
		_AnimStart("_AnimStart", Float) = 0
		_AnimEnd("_AnimEnd", Float) = 0
		_AnimAll("_AnimAll", Float) = 0
		_AnimOff("_AnimOff", Float) = 0

		_OldAnimStart("_OldAnimStart", Float) = 0
		_OldAnimEnd("_OldAnimEnd", Float) = 0
		_OldAnimOff("_OldAnimOff", Float) = 0

		_Speed("_Speed", Float) = 1
		_Blend("_Blend", Range(0, 1)) = 1
		//_FlagIndex("FlagIndex", Range(-1, 1)) = 1  //�ν��Ͻ̿� �¿����
	}

	SubShader
	{
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
		//LOD 100
		Cull off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			//#include "Lighting.cginc"
			//#include "AutoLight.cginc"
			#pragma multi_compile_instancing
			//#pragma target 3.0

			fixed3 _Color;
			sampler2D _MainTex;
			sampler2D	_TransTex;
			float4 _MainTex_ST;			//Gpu Instancing Ani
			fixed _Bright;
			fixed _Contrast;
			fixed _Alpha;

			float _AnimAll;
			sampler2D _AnimMap;
			float4 _AnimMap_TexelSize;//x == 1/width

			UNITY_INSTANCING_BUFFER_START(Props)
				//UNITY_DEFINE_INSTANCED_PROP(float, _FlagIndex) //�ν��Ͻ̿� �¿����

				UNITY_DEFINE_INSTANCED_PROP(float, _AnimStart)
				UNITY_DEFINE_INSTANCED_PROP(float, _AnimEnd)
				UNITY_DEFINE_INSTANCED_PROP(float, _AnimOff)
				UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimStart)
				UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimEnd)
				UNITY_DEFINE_INSTANCED_PROP(float, _OldAnimOff)
				UNITY_DEFINE_INSTANCED_PROP(float, _Blend)
				UNITY_DEFINE_INSTANCED_PROP(float, _Speed)
			UNITY_INSTANCING_BUFFER_END(Props)

			struct appdata
			{
				float2 uv : TEXCOORD0;
				//float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
				//float3 normal : NORMAL;
				//float4 tangent : TANGENT;
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv3 : TEXCOORD1;
				float4 pos : SV_POSITION;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			v2f vert (appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				float start = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimStart);
				float end = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimEnd);
				float off = UNITY_ACCESS_INSTANCED_PROP(Props, _AnimOff);
				float start1 = UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimStart);
				float end1 = UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimEnd);
				float off1 = UNITY_ACCESS_INSTANCED_PROP(Props, _OldAnimOff);

				float speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
				float _AnimLen = (end - start);
				float _AnimLen1 = (end1 - start1);
				float f = (off + _Time.y * speed) / _AnimLen;
				float f1 = (off1 + _Time.y * speed) / _AnimLen1;

				f = fmod(f, 1.0);
				f1 = fmod(f1, 1.0);

				float animMap_x1 = (v.uv3.x * 3 + 0.5) * _AnimMap_TexelSize.x;
				float animMap_x2 = (v.uv3.x * 3 + 1.5) * _AnimMap_TexelSize.x;
				float animMap_x3 = (v.uv3.x * 3 + 2.5) * _AnimMap_TexelSize.x;
				float animMap_y = (f * _AnimLen + start) / _AnimAll;
				float animMap_y1 = (f1 * _AnimLen1 + start1) / _AnimAll;
				float4 row0 = tex2Dlod(_AnimMap, float4(animMap_x1, animMap_y, 0, 0));
				float4 row1 = tex2Dlod(_AnimMap, float4(animMap_x2, animMap_y, 0, 0));
				float4 row2 = tex2Dlod(_AnimMap, float4(animMap_x3, animMap_y, 0, 0));
				float4 row3 = float4(0, 0, 0, 1);
				float4 row10 = tex2Dlod(_AnimMap, float4(animMap_x1, animMap_y1, 0, 0));
				float4 row11 = tex2Dlod(_AnimMap, float4(animMap_x2, animMap_y1, 0, 0));
				float4 row12 = tex2Dlod(_AnimMap, float4(animMap_x3, animMap_y1, 0, 0));

				float4x4 mat = float4x4(row0, row1, row2, row3);
				float4x4 mat1 = float4x4(row10, row11, row12, row3);
				//�ν��Ͻ̿� �¿� ����
				//float4x4 mat = float4x4(row0 * UNITY_ACCESS_INSTANCED_PROP(Props, _FlagIndex), row1, row2, row3);
				//float4x4 mat1 = float4x4(row10 * UNITY_ACCESS_INSTANCED_PROP(Props, _FlagIndex), row11, row12, row3);

				float4 pos = mul(mat, v.vertex);
				float4 pos1 = mul(mat1, v.vertex);
				//float3 normal = mul(mat, float4(v.normal, 0)).xyz;
				//float3 normal1 = mul(mat1, float4(v.normal, 0)).xyz;
					//Old Normal//////////////////////////////
					//float3 normal = mul(mat, v.normal);	
					//float3 normal1 = mul(mat1, v.normal);

				//float4 tangent = mul(mat, v.tangent);
				//float4 tangent1 = mul(mat1, v.tangent);

				float _blend = UNITY_ACCESS_INSTANCED_PROP(Props, _Blend);

				pos = lerp(pos1, pos, _blend);
				v.vertex = pos; //�׸��ڴ� v.vertex�� �״�� ������ ��. gpu instancing ����ġ�� ������

				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				//normal = lerp(normal1, normal, _blend);
				//tangent = lerp(tangent1, tangent, _blend);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);

				fixed4 col = tex2D(_MainTex, i.uv);
				fixed transTex = tex2D(_TransTex, i.uv);
				col.rgb *= _Bright * _Color.rgb;
				col.rgb = pow(col.rgb, _Contrast);
				col.a = transTex * _Alpha;

				return col;
			}
			ENDCG
		}
	}
}