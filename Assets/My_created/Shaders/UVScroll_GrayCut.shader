Shader "Unlit/UVScroll_GrayCut"
{
    Properties
    {
        //[NoScaleOffset]
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Tranparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_particles

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //UnityのRandomRangeのまんま
            float randRange(float2 Seed, float Min, float Max)
            {
                //返値は0.000...~0.999...の値。
                float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
                //生成した乱数を使って、MinとMaxの領域で線形補完する。
                return lerp(Min, Max, randomno);
            }

            float blockNoise(float2 Seed, float Min, float Max)
            {
                float2 floorSeed = floor(Seed);
                return randRange(floorSeed, Min, Max);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //_MainTex_ST.w = v.uv.z * 0.5;
                o.uv.x = v.uv.x;
                //o.uv.y = v.uv.y * v.uv.z + _Time.y; // 最初に生まれたものほどUVSCrollが早く、死期が近づくにつれUVSCrollが遅くなる。
                o.uv.y = v.uv.y + v.uv.z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //マスク用画像のピクセルの色を計算
                fixed4 col = tex2D(_MainTex, i.uv);

                //マスク用画像の色を白黒(GrayScale)に変える。黒色に近いほど0に近い値をとる。 
                fixed grayscale = 0.3*col.r + 0.6*col.g + 0.1*col.b;
                col.a = grayscale;
                //GrayScaleにしたことによって、黒色の部分は0に近い値を持っているので、
                //そこをclipで描画しないようにする。
                clip(col.a-0.7);
                return col;
            }
            ENDCG
        }
    }
}
