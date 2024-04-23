Shader "Unlit/15g_CellNoise"
{
    Properties
    {
        _SquareNum ("SquareNum", Range(1, 10)) = 1
        _Brightness ("Brightness", Range(0.0, 1.0)) = 0.5
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
            };

            half _SquareNum;
            half _Brightness;

            float2 random2(float2 st)
            {
                //ここら辺のマジックナンバーは変えても一応動く。
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //uvを_SquareNumでスケールアップ。
                float2 st = i.uv * _SquareNum;

                //入力点のブロックでの左下（原点）
                //ここに(-1, -1)~(1, 1)を足すことで、
                //入力点のブロックを含めた仮想的な9つのブロックにおいて、
                //各々のブロックの左下（原点）の座標がわかる。
                float2 ist = floor(st);
                //オフセット
                float2 fst = frac(st);

                float distance = 5;

                //自身含む周囲のマスを探索
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = float2(x, y);
                        //ist + neighborは、仮想的な9つのブロックにおける、各々のブロックの左下（原点）の座標。
                        //各々のブロックの左下(マスの起点？)を基準に、ランダムな母点pの座標を求める。
                        //最初の入力点x0で母点を求めても、次の画素x1には母点の座標が伝わらないように考えられるが、
                        //x0もx1もistは同じ、つまりfloor(x0)とfloor(x1)は同じなので、random2()の結果は
                        //x0もx1も同じになり、よってx0で求めた母点の座標と同じ座標が得られる。
                        //float2 st = i.uv * 1の時のセルノイズを描画して考えるとよくわかる。
                        //つまりオフセットが(0.000..., 0.000...)~(0.999..., 0.999...)の入力点は
                        //全て同じ「仮想的な9つのブロック」と「母点」を持つ。
                        float2 p = 0.5 + 0.5 * sin(_Time.y + 6.2831 * random2(ist + neighbor)); 

                        //「処理対象のピクセル」から「白点p」へのベクトル
                        //aからbの距離 = bの座標-aの座標 
                        float2 diff = (neighbor + p) - (0 + fst);

                        //白点との距離が短くなれば更新
                        //基本的には、入力点と同じブロック内の母点が最短距離になるので
                        //各uv座標の中心が黒くなり、各uv座標にセルにあるように見えがち。
                        distance = min(distance, length(diff));
                    }
                }

                //白点から最も短い距離を色に反映
                return distance * _Brightness;
            }
            ENDCG
        }
    }
}
