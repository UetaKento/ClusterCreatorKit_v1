Shader "Unlit/15d_OriginalPerlinNoise_v2"
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

            //UnityのRandomRangeで定義されている擬似乱数生成関数。
            //引数はシード値と呼ばれ、同じ値を渡せば同じものを返す。
            //この乱数はある点とその次の点での差が大きい。
            //つまり、xの時にでてくる乱数とx+1の時にでてくる乱数はとびとびの値になる。なので、とても細かいノイズに見える。
            float rand(float2 co)
            {
                //返値は0.000...~0.999...の値。
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            fixed2 random2(fixed2 st)
            {
                st = fixed2( dot(st,fixed2(127.1,311.7)), dot(st,fixed2(269.5,183.3)) );
                return -1.0 + 2.0*frac(sin(st)*43758.5453123);
            }

            //入力はuv座標(u, v)で、線形保管された値が返る。
            float perlinNoise(float2 uv)
            {
                //n倍スケールされたuv座標(例えば、(2.4, 3.2))であっても
                //floor()とfrac()を使って、0~1のuv座標で考えれるようにする。

                //床関数を使って、入力点における4隅の格子点を計算。
                float2 uv00 = floor(uv) + float2(0, 0);
                float2 uv10 = floor(uv) + float2(1, 0);
                float2 uv01 = floor(uv) + float2(0, 1);
                float2 uv11 = floor(uv) + float2(1, 1);

                //天井関数を使って、入力点における位置ベクトルを取得。
                float2 uv_vec = frac(uv);

                float2 uvf = uv_vec*uv_vec*(3.0-2.0*uv_vec);

                //入力点と4隅の格子点の距離ベクトルを計算する。距離ベクトルは単純に、入力点から隅の格子点の位置ベクトルを減算する。
                float2 uv00Distance = uv_vec - uv00;
                float2 uv10Distance = uv_vec - uv10;
                float2 uv01Distance = uv_vec - uv01;
                float2 uv11Distance = uv_vec - uv11;

                //4隅の格子点にランダムなベクトルを持たせる。
                //float2 uv00_RamVec = float2(rand(uv_vec), rand(uv_vec+1));
                float2 uv00_RamVec = float2(rand(uv_vec), rand(uv_vec+1));
                float2 uv10_RamVec = float2(rand(uv_vec+2), rand(uv_vec+3));
                float2 uv01_RamVec = float2(rand(uv_vec+4), rand(uv_vec+5));
                float2 uv11_RamVec = float2(rand(uv_vec+6), rand(uv_vec+7));

                //距離ベクトルと4隅の格子点のランダムなベクトルを内積。
                float uv00_dot = dot(uv00Distance, uv00_RamVec);
                float uv10_dot = dot(uv10Distance, uv10_RamVec);
                float uv01_dot = dot(uv01Distance, uv01_RamVec);
                float uv11_dot = dot(uv11Distance, uv11_RamVec);

                //入力点のx座標で線形補完
                float uv0010 = lerp(uv00_dot, uv10_dot, uv_vec.x);
                float uv0111 = lerp(uv01_dot, uv11_dot, uv_vec.x);

                //入力点のy座標で線形補完 
                return lerp(uv0010, uv0111, uv_vec.y);
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
