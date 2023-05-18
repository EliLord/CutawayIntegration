Shader "Cutaway/StandardGlassCutaway" 
{
	Properties
	{
		_CrossSectionColor("Cross Section Color", Color) = (1,1,1,1)

		_Color("Color", Color) = (1,1,1,1)

		_MainTex("Albedo", 2D) = "white" {}

		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		//_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

		//[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		_MetallicGlossMap("Metallic", 2D) = "white" {}

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

		_BumpScale("Scale", Float) = 1.0
		[Normal] _BumpMap("Normal Map", 2D) = "bump" {}

		_Parallax("Height Scale", Range(0.005, 0.08)) = 0.02
		_ParallaxMap("Height Map", 2D) = "black" {}

		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}

		_EmissionColor("Color", Color) = (0,0,0)
		_EmissionMap("Emission", 2D) = "white" {}

		_DetailMask("Detail Mask", 2D) = "white" {}

		_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
		_DetailNormalMapScale("Scale", Float) = 1.0
		[Normal] _DetailNormalMap("Normal Map", 2D) = "bump" {}

		[Enum(UV0,0,UV1,1)] _UVSec("UV Set for secondary textures", Float) = 0

		_PlaneNormal("PlaneNormal",Vector) = (0,1,0,0)
		_PlanePosition("PlanePosition",Vector) = (0,0,0,1)
		_StencilMask("Stencil Mask", Range(0, 255)) = 255

			// Blending state
			[HideInInspector] _Mode("__mode", Float) = 0.0
			[HideInInspector] _SrcBlend("__src", Float) = 1.0
			[HideInInspector] _DstBlend("__dst", Float) = 0.0
			[HideInInspector] _ZWrite("__zw", Float) = 1.0
	}
	SubShader
	{
		//Tags { "RenderType"="Opaque" }
		Tags
		{
			//"RenderType" = "Opaque" "PerformanceChecks" = "False"
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		//LOD 200
		Stencil
		{
			Ref[_StencilMask]
			CompBack Always
			PassBack Replace
			CompFront Always
			PassFront Zero
		}

		//Cull Back //Backside Coloring
		Cull Off
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma surface surf Standard fullforwardshadows
		#pragma surface surf Standard alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MetallicGlossMap;
		sampler2D _BumpMap;
		sampler2D _OcclusionMap;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_MetallicGlossMap;
			float2 uv_BumpMap;
			float2 uv_OcclusionMap;

			float3 worldPos;
		};

		//half _Glossiness;
		//half _Metallic;
		fixed4 _Color;
		fixed4 _CrossSectionColor;
		fixed3 _PlaneNormal;
		fixed3 _PlanePosition;
		bool checkVisability(fixed3 worldPos)
		{
			float dotProd1 = dot(worldPos - _PlanePosition, _PlaneNormal);
			return dotProd1 > 0;
		}
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			if (checkVisability(IN.worldPos))discard;

			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 metal = tex2D(_MetallicGlossMap, IN.uv_MetallicGlossMap);
			fixed4 occ = tex2D(_OcclusionMap, IN.uv_OcclusionMap);

			//o.Albedo = tex.rgb * occ.rgb;
			o.Albedo = tex.rgb;
			//o.Metallic = metal.r * occ.rgb;
			o.Smoothness = metal.a;
			//o.Smoothness = _Glossiness;
			//o.Smoothness = metal.a * _Glossiness;
			// Metallic and smoothness come from slider variables
			//o.Metallic = _Metallic;
			//o.Smoothness = _Glossiness;
			o.Alpha = tex.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}
		ENDCG
		
		//Backside Coloring (unnecessary for glass)
//			Cull Front
//			CGPROGRAM
//#pragma surface surf NoLighting  noambient
//
//		struct Input 
//		{
//			half2 uv_MainTex;
//			float3 worldPos;
//		};
//		sampler2D _MainTex;
//		//fixed4 _Color;
//		fixed4 _CrossSectionColor;
//		fixed3 _PlaneNormal;
//		fixed3 _PlanePosition;
//		//Checks visibility of materials/shaders
//		bool checkVisability(fixed3 worldPos)
//		{
//			float dotProd1 = dot(worldPos - _PlanePosition, _PlaneNormal);
//			return dotProd1 > 0;
//			//If true, hides the sections cut away
//			//If false, colors the sections the _CrossSectionColor
//		}
//		fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
//		{
//			//Applies Transparecy affect of Cut locations.
//			fixed4 c;
//		//	c.rgb = s.Albedo;
//		//	c.a = s.Alpha;
//			return c;
//		}
//
//		void surf(Input IN, inout SurfaceOutput o)
//		{
//			//if DotProd is visible, discard function.
//			if (checkVisability(IN.worldPos))discard;
//			//Applies _CrossSectionColor to untextured/unmaterialed backfaces.
//			//o.Albedo = _CrossSectionColor;
//		}
//			ENDCG
//		
	}
	FallBack "Diffuse"
	CustomEditor "StandardShaderGUI"
}
