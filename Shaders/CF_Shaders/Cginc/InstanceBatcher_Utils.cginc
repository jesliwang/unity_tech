#ifndef INSTANCE_BATCHER_UTILS_INCLUDED
#define INSTANCE_BATCHER_UTILS_INCLUDED


#define INSTANCE_DATA_SIZE 4


#if defined(UNITY_STANDARD_CORE_INCLUDED) || defined(UNITY_STANDARD_SHADOW_INCLUDED)

	#if defined(UNITY_STANDARD_SHADOW_INCLUDED)
		#define INSTANCE_SHADOW_ALPHA 	o.instanceColorAlpha = tex2Dlod(_InstancingData, instanceUV).a;
		#define INSTANCE_SHADOW_SHADER 	float3 wPos = mul(instanceMatrix, v.vertex).xyz;
	#else
		#define INSTANCE_SHADOW_SHADER	o.instanceColor = tex2Dlod(_InstancingData, instanceUV);\
										float3x3 instanceRotationMatrix = (float3x3)instanceMatrix;\
										float4 posWorld = mul(instanceMatrix, v.vertex);
	#endif


	#define INSTANCE_DATA_DECODE_STANDARD 	float texelSizeX = _InstancingData_TexelSize.x;\
											float id = v.uv3.x * INSTANCE_DATA_SIZE * texelSizeX;\
											float4 instanceUV = float4(fmod(id, 1.0), id * _InstancingData_TexelSize.y, 0, 0);\
											float4 row0 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
											float4 row1 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
											float4 row2 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
											float4x4 instanceMatrix = {row0, row1, row2, float4(0,0,0,1)};\
											INSTANCE_SHADOW_SHADER

#else

	//============================================================================
	//
	//	To add instance batching support to your custom shader,
	//	include InstanceBatcher_Utils.cginc and add
	//	INSTANCE_DATA_DECODE_CUSTOM to the vertex shader
	//
	//	--------------------------------------------------------------------------
	//
	//	Before using the INSTANCE_DATA_DECODE_CUSTOM, the shader must provide:
	//
	//		float4 vertex = vertex.position;	//object space vertex position
	//		float2 uv3 = vertex.uv3;			//instance id
	//
	//		NOTE: vertex.uv3 must be defined as:
	//
	//			float2 uv3	: TEXCOORD3;
	//
	//	--------------------------------------------------------------------------
	//
	//	INSTANCE_DATA_DECODE_CUSTOM will provide you with:
	//
	//		float4 posWorld .................... the vertex position in world space
	//		float4 instanceColor ............... the instance color
	//		float3x3 instanceRotationMatrix .... the instance rotation matrix
	//
	//	--------------------------------------------------------------------------
	//
	//	Project the posWorld to fragment position with:
	//
	//		float4 fragPos = mul(UNITY_MATRIX_VP, posWorld);
	//
	//	--------------------------------------------------------------------------
	//
	//	Use the instanceRotationMatrix to transform
	//	vertex normal to world space normal:
	//
	//		float3 normalWorld = normalize(mul(instanceRotationMatrix, v.normal));
	//
	//============================================================================

	sampler2D	_InstancingData;
	float4		_InstancingData_TexelSize;

	#define INSTANCE_DATA_DECODE_CUSTOM		float texelSizeX = _InstancingData_TexelSize.x;\
											float id = uv3.x * INSTANCE_DATA_SIZE * texelSizeX;\
											float4 instanceUV = float4(fmod(id, 1.0), id * _InstancingData_TexelSize.y, 0, 0);\
											float4 row0 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
											float4 row1 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
											float4 row2 = tex2Dlod(_InstancingData, instanceUV); instanceUV.x += texelSizeX;\
											float4x4 instanceMatrix = {row0, row1, row2, float4(0,0,0,1)};\
											float4 instanceColor = tex2Dlod(_InstancingData, instanceUV);\
											float3x3 instanceRotationMatrix = (float3x3)instanceMatrix;\
											float4 posWorld = mul(instanceMatrix, vertex);

#endif

#endif // INSTANCE_BATCHER_UTILS_INCLUDED