Shader "Cutaway/TintedGlassCutaway" 
{
	Properties
	{
		_MainTex("diffuse", 2D) = "white" {}
		_Color("diffuse color", Color) = (1,1,1,1)
		_fresnel("fresnel", Range(0, 1)) = 0.3726189
		_transamount("trans amount", Range(1, 0)) = 0.9223301
		_reflectcolor("reflect color", Color) = (1,1,1,1)
			//_Illum ("cubemap", Cube) = "_Skybox" {}
			[HideInInspector]_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
	}
		SubShader{
			//Tags { "RenderType"="Opaque" }
			Tags
			{
				"IgnoreProjector" = "True"
				"Queue" = "Transparent"
				"RenderType" = "Transparent"
			}
			Pass
			{
				Name "ForwardBase"
				Tags
				{
					"LightMode" = "ForwardBase"
				}
				Blend SrcAlpha OneMinusSrcAlpha
				ZWrite Off

				Stencil
				{
					Ref[_StencilMask]
					CompBack Always
					PassBack Replace
					CompFront Always
					PassFront Zero
				}

				Cull Back
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#define UNITY_PASS_FORWARDBASE
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#pragma multi_compile_fwdbase
				#pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
				#pragma target 2.0
				#ifndef LIGHTMAP_OFF
			// float4 unity_LightmapST;
			// sampler2D unity_Lightmap;
			#ifndef DIRLIGHTMAP_OFF
				// sampler2D unity_LightmapInd;
			#endif
		#endif

		uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
		uniform fixed _fresnel;
		uniform fixed _transamount;
		uniform fixed4 _reflectcolor;
		uniform fixed4 _Color;
		//uniform samplerCUBE _Illum;

		struct VertexInput
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float2 texcoord0 : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
		};
		struct VertexOutput
		{
			float4 pos : SV_POSITION;
			float2 uv0 : TEXCOORD0;
			float4 posWorld : TEXCOORD1;
			float3 normalDir : TEXCOORD2;
			float3 tangentDir : TEXCOORD3;
			float3 binormalDir : TEXCOORD4;
			#ifndef LIGHTMAP_OFF
				float2 uvLM : TEXCOORD5;
			#endif
		};

	fixed4 _CrossSectionColor;
	fixed3 _PlaneNormal;
	fixed3 _PlanePosition;

	bool checkVisability(fixed3 worldPos)
	{
		float dotProd1 = dot(worldPos - _PlanePosition, _PlaneNormal);
		return dotProd1 > 0;
	}

	fixed4 frag(VertexOutput i) : COLOR{
		i.normalDir = normalize(i.normalDir);
		float3x3 tangentTransform = float3x3(i.tangentDir, i.binormalDir, i.normalDir);
		/////// Vectors:
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					float3 normalDirection = i.normalDir;
					float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
					#ifndef LIGHTMAP_OFF
						float4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap,i.uvLM);
						#ifndef DIRLIGHTMAP_OFF
							float3 lightmap = DecodeLightmap(lmtex);
							float3 scalePerBasisVector = DecodeLightmap(UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd,unity_Lightmap,i.uvLM));
							UNITY_DIRBASIS
							half3 normalInRnmBasis = saturate(mul(unity_DirBasis, float3(0,0,1)));
							lightmap *= dot(normalInRnmBasis, scalePerBasisVector);
						#else
							float3 lightmap = DecodeLightmap(lmtex);
						#endif
					#endif
							////// Lighting:
							////// Emissive:
										fixed node_1918 = lerp(1.0,(1.0 - max(0,dot(normalDirection, viewDirection))),_fresnel);
										fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
										if (_MainTex_var.r > 0.25)
										{
											_MainTex_var.a = 0;
										}
										//float3 emissive = saturate((saturate(((_reflectcolor.rgb*(texCUBE(_Illum,viewReflectDirection).rgb*node_1918))*(1.0 - _MainTex_var.a)))+(_MainTex_var.rgb*_Color.rgb)));
										float3 emissive = saturate((saturate(((_reflectcolor.rgb * (node_1918)) * (1.0 - _MainTex_var.a))) + (_MainTex_var.rgb * _Color.rgb)));
										float3 finalColor = emissive;
										fixed _mult = (node_1918 * _transamount);
										return fixed4(finalColor,saturate((_mult / (1.0 - _MainTex_var.a))));
									}
									ENDCG
									}
		}
			FallBack "Transparent/Diffuse"
										CustomEditor "ShaderForgeMaterialInspector"
}

//void surf(Input IN, inout SurfaceOutputStandard o)
//{
//	if (checkVisability(IN.worldPos))discard;

//	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);// * _Color;
//	fixed4 metal = tex2D(_MetallicGlossMap, IN.uv_MetallicGlossMap);
//	fixed4 occ = tex2D(_OcclusionMap, IN.uv_OcclusionMap);

//	o.Albedo = tex.rgb * occ.rgb;
//	o.Metallic = metal.r * occ.rgb;
//	o.Smoothness = metal.a;
//	//o.Smoothness = _Glossiness;
//	//o.Smoothness = metal.a * _Glossiness;
//	// Metallic and smoothness come from slider variables
//	//o.Metallic = _Metallic;
//	//o.Smoothness = _Glossiness;
//	//o.Alpha = tex.a * occ.a;
//	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
//}
//ENDCG

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
//ENDCG
