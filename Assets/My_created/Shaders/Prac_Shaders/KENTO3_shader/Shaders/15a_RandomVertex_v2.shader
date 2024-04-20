Shader "Unlit/15a_RandomVertex_v2"
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

            //UnityのRandomRangeのまんま
            float randRange(float2 Seed, float Min, float Max)
            {
                //返値は0.000...~0.999...の値。
                float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
                //生成した乱数を使って、MinとMaxの領域で線形補完する。
                return lerp(Min, Max, randomno);
            }

            float blockNoise(float2 Seed)
            {
                float2 floorSeed = floor(Seed);
                return frac(sin(dot(floorSeed, float2(12.9898, 78.233))) * 43758.5453);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                //モデル空間での法線ベクトル
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                //頂点座標を元に乱数を作ることで、トゲトゲした表現になる。
                float random = rand(v.vertex.xy);
                //float random_1 = rand(float2(_Time.x, _Time.x+0.5));
                //float random_2 = rand(float2(_Time.x+1, _Time.x+1.5));
                //float random_3 = rand(float2(_Time.x+2, _Time.x+2.5));
                //float4 vert = float4(v.vertex.x + (v.normal.x*random_1), v.vertex.y + (v.normal.y*random_2), v.vertex.z + (v.normal.z*random_3), v.vertex.w);
                //float4 vert = float4(v.vertex.xyz + random, v.vertex.w); //この書き方だと、x軸、y軸、z軸が正になる領域(第1象限)でしか頂点が変化しない。
                //float4 vert = float4(v.vertex.xyz + (v.normal *　random, v.vertex.w);　//この書き方だと、球の形は変化しない。

                //sin(random + _Time.y)だと、球が拡大縮小をする。sin(random * _Time.y)だと、球の輪郭だと波打つ。
                //sin(random * _Time.y)だと最初に_Time.y=0になり球の形が安定しないので、sin(1 + random * _Time.y)で安定させる。
                float4 vert = float4(v.vertex.xyz + (v.normal * sin(1 + random * _Time.y)), v.vertex.w);
                o.vertex = UnityObjectToClipPos(vert);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //シード値に同じ値を渡すと全部同じ値になるので引数のシード値に別の値を渡す
                float r = rand(i.vertex.xy + 0.1);
                float g = rand(i.vertex.xy + 0.2);
                float b = rand(i.vertex.xy + 0.3);
                return float4(r,g,b,1);
            }
            ENDCG
        }
    }
}
