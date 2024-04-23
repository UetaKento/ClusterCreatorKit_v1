Shader "Unlit/15b_BlockNoise"
{
    SubShader
    {
        Tags{
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
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

            float blockNoise(float2 Seed)
            {
                float2 floorSeed = floor(Seed);
                return rand(floorSeed);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                //v.vertex.xyz * (1 + frac(_Time.x*5))で時間経過でサイズを変えている。
                // frac(_Time.x*5)で0.000..~0.999..の値をループさせる。「1 +」は最初の大きさを1にするための処理。
                float4 vert = float4(v.vertex.xyz * (1 + frac(_Time.x*5)), v.vertex.w);
                o.vertex = UnityObjectToClipPos(vert);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //floor(_Time.y)で時間経過するごとに、i.uvを別の場所に飛ばして色をかえる。
                float blockUV = blockNoise(i.uv*8 + floor(_Time.x*5));
                //float blockUV = blockNoise(i.uv*8);
                fixed4 col = fixed4(blockUV, blockUV, blockUV, 1);
                //グレイスケールとアルファブレンドで、黒色は透明に、白色は不透明に見せる。
                col.a = 0.3*col.r + 0.6*col.g + 0.1*col.b;
                //時間経過と共に、col.aを減少させていく。min()で下限を0に設定することで、col.aが負の値になるのを防ぐ。
                col.a = max(0, col.a - frac(_Time.x*5));

                //col.a = lerp(0, 1, sin(_Time.y)); //現れたり消えたりする表現。
                return col;
            }
            ENDCG
        }
    }
}
