Shader "Unlit/15_RandomVertex"
{
    Properties
    {
        //頂点の動きの幅
        _VertMoveRange("VertMoveRange",Range(0,0.5)) = 0.025
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

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float _VertMoveRange;

            v2f vert (appdata v)
            {
                v2f o;
                float random = rand(v.vertex.xy);
                //ランダムな値をsin関数の引数に渡して経過時間を掛け合わせることで各頂点にランダムな変化を与える
                float4 vert = float4(v.vertex.xyz + v.vertex.xyz * sin(_Time.w * random) * _VertMoveRange, v.vertex.w);
                //float4 vert = float4(v.vertex.xyz + random, v.vertex.w);
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
