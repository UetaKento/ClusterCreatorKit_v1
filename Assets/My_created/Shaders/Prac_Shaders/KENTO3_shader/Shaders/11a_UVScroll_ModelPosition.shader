Shader "Unlit/11a_UVScroll_ModelPosition"
{
    Properties
    {
        //[NoScaleOffset]でタイリングとオフセットの設定を消す。
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _SliceSpace("SliceSpace",Range(0,30)) = 15
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 modelPos : MODEL_POS;
            };

            sampler2D _MainTex;
            half _SliceSpace;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.modelPos = v.vertex;
                //o.uv.y = v.uv.y + _Time.x;だけの記述だとおかしくなるので、
                //o.uv.x = v.uv.x;もちゃんと書く。
                o.uv.y = v.uv.y + _Time.y;
                o.uv.x = v.uv.x;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float modelSlice = frac(i.modelPos.y * _SliceSpace);
                clip(modelSlice - 0.5);
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
