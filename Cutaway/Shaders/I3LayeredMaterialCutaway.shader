Shader "Cutaway/I3LayeredMaterialCutaway" 
{
	Properties
	{
		_CrossSectionColor("Cross Section Color", Color) = (1,1,1,1)
		_MaterialMask("Material Mask", 2D) = "white" {}
		_WearMask("Wear Mask", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_AmbientOcclusion("Ambient Occlusion", 2D) = "white" {}
		_BaseMaterial("Base Material", 2DArray) = "white" {}
		_MaterialR("Material (R)", 2DArray) = "white" {}
		_MaterialG("Material (G)", 2DArray) = "white" {}
		_MaterialB("Material (B)", 2DArray) = "white" {}
		_Tiling("Tiling", Float) = 0
		_BaseTint("BaseTint", Color) = (1,1,1,1)
		_R_Tint("R_Tint", Color) = (1,1,1,1)
		_G_Tint("G_Tint", Color) = (1,1,1,1)
		_B_Tint("B_Tint", Color) = (1,1,1,1)
		_WearRColor("Wear R Color", Color) = (0.5283019,0.5283019,0.5283019,0)
		_WearGColor("Wear G Color", Color) = (0.5283019,0.5283019,0.5283019,0)
		_WearBColor("Wear B Color", Color) = (0.5283019,0.5283019,0.5283019,0)
		_WearRMetallic("Wear R Metallic", Range(0 , 1)) = 0
		_WearGMetallic("Wear G Metallic", Range(0 , 1)) = 0
		_WearBMetallic("Wear B Metallic", Range(0 , 1)) = 0
		_WearRSmoothness("Wear R Smoothness", Range(0 , 1)) = 0.5
		_WearGSmoothness("Wear G Smoothness", Range(0 , 1)) = 0.5
		_WearBSmoothness("Wear B Smoothness", Range(0 , 1)) = 0.5
		[HideInInspector] _texcoord("", 2D) = "white" {}
		[HideInInspector] __dirty("", Int) = 1
	}
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
		//LOD 200
		Stencil
		{
			Ref[_StencilMask]
			CompBack Always
			PassBack Replace
			CompFront Always
			PassFront Zero
		}

		//Cull Back //(Backside Coloring)
		Cull Off
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#include "UnityStandardUtils.cginc"
		#pragma target 4.5
		#pragma multi_compile __ _UNITY_IOS_ON
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D_ARRAY(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D_ARRAY(tex,samplertex,coord) tex2DArray(tex,coord)
		#endif//ASE Sampling Macros

		#pragma surface surf Standard keepalpha addshadow fullforwardshadows

		struct Input
		{
			float2 uv_texcoord;

			float3 worldPos;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _WearMask;
		uniform float4 _WearMask_ST;
		uniform sampler2D _MaterialMask;
		uniform float4 _MaterialMask_ST;
		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_BaseMaterial);
		uniform float _Tiling;
		SamplerState sampler_BaseMaterial;
		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_MaterialR);
		SamplerState sampler_MaterialR;
		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_MaterialG);
		SamplerState sampler_MaterialG;
		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_MaterialB);
		SamplerState sampler_MaterialB;
		uniform float _WearRMetallic;
		uniform float _WearGMetallic;
		uniform float _WearBMetallic;
		uniform float4 _BaseTint;
		uniform float4 _R_Tint;
		uniform float4 _G_Tint;
		uniform float4 _B_Tint;
		uniform float4 _WearRColor;
		uniform float _WearRSmoothness;
		uniform float4 _WearGColor;
		uniform float _WearGSmoothness;
		uniform float4 _WearBColor;
		uniform float _WearBSmoothness;
		uniform sampler2D _AmbientOcclusion;
		uniform float4 _AmbientOcclusion_ST;

		fixed4 _CrossSectionColor;
		fixed3 _PlaneNormal;
		fixed3 _PlanePosition;

		bool checkVisability(fixed3 worldPos)
		{
			float dotProd1 = dot(worldPos - _PlanePosition, _PlaneNormal);
			return dotProd1 > 0;
		}

		void surf(Input i, inout SurfaceOutputStandard o)
		{
			if (checkVisability(i.worldPos))discard;

			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float2 uv_WearMask = i.uv_texcoord * _WearMask_ST.xy + _WearMask_ST.zw;
			float3 WearMask45 = (tex2D(_WearMask, uv_WearMask)).rgb;
			float2 uv_MaterialMask = i.uv_texcoord * _MaterialMask_ST.xy + _MaterialMask_ST.zw;
			float3 MaterialMask40 = (tex2D(_MaterialMask, uv_MaterialMask)).rgb;
			float2 uv_TexCoord67 = i.uv_texcoord * (_Tiling).xx;
			float2 GlobalTiling79 = uv_TexCoord67;
			float4 BaseMaterial193 = SAMPLE_TEXTURE2D_ARRAY(_BaseMaterial, sampler_BaseMaterial, float3(GlobalTiling79, 1.0));
			float4 Mat_R_197 = SAMPLE_TEXTURE2D_ARRAY(_MaterialR, sampler_MaterialR, float3(GlobalTiling79, 1.0));
			float4 Mat_G_1101 = SAMPLE_TEXTURE2D_ARRAY(_MaterialG, sampler_MaterialG, float3(GlobalTiling79, 1.0));
			float4 Mat_B_1103 = SAMPLE_TEXTURE2D_ARRAY(_MaterialB, sampler_MaterialB, float3(GlobalTiling79, 1.0));
			float3 layeredBlendVar36 = MaterialMask40;
			float4 layeredBlend36 = (lerp(lerp(lerp(BaseMaterial193, Mat_R_197, layeredBlendVar36.x), Mat_G_1101, layeredBlendVar36.y), Mat_B_1103, layeredBlendVar36.z));
			float4 BaseMaterialBlend1166 = layeredBlend36;
			float4 _Color1 = float4(0.5019608, 0.5019608, 1, 1);
			float4 appendResult191 = (float4(_Color1.r, _Color1.g, _Color1.b, _WearRMetallic));
			float4 WearRMetallic119 = appendResult191;
			float4 _Color0 = float4(0.5019608, 0.5019608, 1, 0);
			float4 appendResult189 = (float4(_Color0.r, _Color0.g, _Color0.b, _WearGMetallic));
			float4 WearGMetallic122 = appendResult189;
			float4 _NormalColor = float4(0.5019608, 0.5019608, 1, 0);
			float4 appendResult188 = (float4(_NormalColor.r, _NormalColor.g, _NormalColor.b, _WearBMetallic));
			float4 WearBMetallic133 = appendResult188;
			float3 layeredBlendVar183 = WearMask45;
			float4 layeredBlend183 = (lerp(lerp(lerp(BaseMaterialBlend1166, WearRMetallic119, layeredBlendVar183.x), WearGMetallic122, layeredBlendVar183.y), WearBMetallic133, layeredBlendVar183.z));
			float4 FinalMaterialBlend1184 = layeredBlend183;
			float4 temp_output_8_0_g7 = FinalMaterialBlend1184;
			float4 appendResult4_g7 = (float4(1.0, (temp_output_8_0_g7).y, 0.0, (temp_output_8_0_g7).x));
			#ifdef _UNITY_IOS_ON
				float3 staticSwitch17_g7 = UnpackNormal(temp_output_8_0_g7);
			#else
				float3 staticSwitch17_g7 = UnpackNormal(appendResult4_g7);
			#endif
			o.Normal = BlendNormals(UnpackNormal(tex2D(_NormalMap, uv_NormalMap)), staticSwitch17_g7);
			float4 BaseMaterial092 = (_BaseTint * SAMPLE_TEXTURE2D_ARRAY(_BaseMaterial, sampler_BaseMaterial, float3(GlobalTiling79, 0.0)));
			float4 Mat_R_096 = (_R_Tint * SAMPLE_TEXTURE2D_ARRAY(_MaterialR, sampler_MaterialR, float3(GlobalTiling79, 0.0)));
			float4 Mat_G_0100 = (_G_Tint * SAMPLE_TEXTURE2D_ARRAY(_MaterialG, sampler_MaterialG, float3(GlobalTiling79, 0.0)));
			float4 Mat_B_0102 = (_B_Tint * SAMPLE_TEXTURE2D_ARRAY(_MaterialB, sampler_MaterialB, float3(GlobalTiling79, 0.0)));
			float3 layeredBlendVar31 = MaterialMask40;
			float4 layeredBlend31 = (lerp(lerp(lerp(BaseMaterial092, Mat_R_096, layeredBlendVar31.x), Mat_G_0100, layeredBlendVar31.y), Mat_B_0102, layeredBlendVar31.z));
			float4 BaseMaterialBlend0164 = layeredBlend31;
			float4 appendResult176 = (float4(_WearRColor.r, _WearRColor.g, _WearRColor.b, _WearRSmoothness));
			float4 WearRColor118 = appendResult176;
			float4 appendResult175 = (float4(_WearGColor.r, _WearGColor.g, _WearGColor.b, _WearGSmoothness));
			float4 WearGColor127 = appendResult175;
			float4 appendResult174 = (float4(_WearBColor.r, _WearBColor.g, _WearBColor.b, _WearBSmoothness));
			float4 WearBColor131 = appendResult174;
			float3 layeredBlendVar162 = WearMask45;
			float4 layeredBlend162 = (lerp(lerp(lerp(BaseMaterialBlend0164, WearRColor118, layeredBlendVar162.x), WearGColor127, layeredBlendVar162.y), WearBColor131, layeredBlendVar162.z));
			float4 FinalMaterialBlend0170 = layeredBlend162;
			float4 temp_output_172_0 = FinalMaterialBlend0170;
			o.Albedo = temp_output_172_0.rgb;
			o.Metallic = (temp_output_8_0_g7).w;
			o.Smoothness = (FinalMaterialBlend0170).a;
			float2 uv_AmbientOcclusion = i.uv_texcoord * _AmbientOcclusion_ST.xy + _AmbientOcclusion_ST.zw;
			o.Occlusion = tex2D(_AmbientOcclusion, uv_AmbientOcclusion).r;
			o.Alpha = 1;
		}

		ENDCG
		
			//(Backside Coloring)
		//Cull Front
		//CGPROGRAM
		//#pragma surface surf NoLighting  noambient

		//struct Input
		//{
		//	half2 uv_MainTex;
		//	float3 worldPos;
		//};
		//sampler2D _MainTex;
		////fixed4 _Color;
		//fixed4 _CrossSectionColor;
		//fixed3 _PlaneNormal;
		//fixed3 _PlanePosition;
		////Checks visibility of materials/shaders
		//bool checkVisability(fixed3 worldPos)
		//{
		//	float dotProd1 = dot(worldPos - _PlanePosition, _PlaneNormal);
		//	return dotProd1 > 0;
		//	//If true, hides the sections cut away
		//	//If false, colors the sections the _CrossSectionColor
		//}
		//fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
		//{
		//	//Applies Transparecy affect of Cut locations.
		//	fixed4 c;
		//	c.rgb = s.Albedo;
		//	c.a = s.Alpha;
		//	return c;
		//}

		//void surf(Input IN, inout SurfaceOutput o)
		//{
		//	//if DotProd is visible, discard function.
		//	if (checkVisability(IN.worldPos))discard;
		//	//Applies _CrossSectionColor to untextured/unmaterialed backfaces.
		//	o.Albedo = _CrossSectionColor;
		//}
		//	ENDCG

		}

	FallBack "Diffuse"
	CustomEditor "LayeredShaderGUI"
}
