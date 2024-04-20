Shader "Unlit/15e_OriginalPerlinNoise"
{
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

            //UnityのRandomRangeのまんま
            float randRange(float2 Seed, float Min, float Max)
            {
                //返値は0.000...~0.999...の値。
                float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
                //生成した乱数を使って、MinとMaxの領域で線形補完する。
                return lerp(Min, Max, randomno);
            }

            float wavelet(float2 xy)
            {
                float Cx = 1-3*pow(xy.x, 2)+2*pow(abs(xy.x),3);
                float Cy = 1-3*pow(xy.y, 2)+2*pow(abs(xy.y),3);
                float2 axay = float2(randRange(xy, 1, 5), randRange(xy+1, 5, 10));
                return Cx*Cy*dot(axay, xy);
            }

            //入力はuv座標(u, v)で、線形保管された値が返る。
            float perlinNoise(float2 uv)
            {
                //float2 p = floor(uv);
                float2 uv00 = floor(uv) + float2(0, 0);
                float2 uv10 = floor(uv) + float2(1, 0);
                float2 uv01 = floor(uv) + float2(0, 1);
                float2 uv11 = floor(uv) + float2(1, 1);

                float uv0010 = lerp(wavelet(uv00), wavelet(uv10), uv.x);
                float uv0111 = lerp(wavelet(uv01), wavelet(uv11), uv.x);

                return lerp(uv0010, uv0111, uv.y);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float perlinUV = perlinNoise(i.uv*8);
                fixed4 col = fixed4(perlinUV, perlinUV, perlinUV, 1);
                return col;
            }
            ENDCG
        }
    }
}
