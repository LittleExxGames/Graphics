﻿Shader "Hidden/Light2D-Shape"
{
	Properties
	{
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
	}

	HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"

	struct Attributes
	{
		float4 positionOS   : POSITION;
		float4 color		: COLOR;

		#ifdef SPRITE_LIGHT
		float2 uv			: TEXCOORD0;
		#endif
	};

	struct Varyings
	{
		float4  positionCS	: SV_POSITION;
		float4  color		: COLOR;
		float2  uv			: TEXCOORD0;
	};
	ENDHLSL

	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		Blend[_SrcBlend][_DstBlend]
		BlendOp Add
		ZWrite Off
		Cull Off

		Pass
		{
			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile SPRITE_LIGHT __

			uniform float  _InverseLightIntensityScale;
			uniform float  _FalloffCurve;

			#ifdef SPRITE_LIGHT
			TEXTURE2D(_CookieTex);			// This can either be a sprite texture uv or a falloff texture
			SAMPLER(sampler_CookieTex);
			#else
			TEXTURE2D(_FalloffLookup);
			SAMPLER(sampler_FalloffLookup);
			#endif
			
			Varyings vert (Attributes attributes)
			{
				Varyings o;
				o.positionCS = TransformObjectToHClip(attributes.positionOS);
				o.color = attributes.color * _InverseLightIntensityScale;

				#ifdef SPRITE_LIGHT
					o.uv = attributes.uv;
				#else
					o.uv = float2(o.color.a, _FalloffCurve);
				#endif

				return o;
			}
			
			half4 frag (Varyings i) : SV_Target
			{
				half4 col = i.color;
				#if SPRITE_LIGHT
				col = col * SAMPLE_TEXTURE2D(_CookieTex, sampler_CookieTex, i.uv);
				#else
				col = col * SAMPLE_TEXTURE2D(_FalloffLookup, sampler_FalloffLookup, i.uv).r;
				#endif
				return col;
			}
			ENDHLSL
		}
	}
}
