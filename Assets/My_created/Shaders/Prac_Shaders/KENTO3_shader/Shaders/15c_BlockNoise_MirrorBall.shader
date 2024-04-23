Shader "Unlit/15c_BlockNoise_MirrorBall"
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //blockNoise内で+1や、+2でrgbの色をずらすことでミラーボールが作れる。floor(_Time.y)で時間経過と共にuv座標を移動させる。
                fixed4 col = fixed4(blockNoise(i.uv*8 + 1 + floor(_Time.y)), blockNoise(i.uv*8 + 2 + floor(_Time.y)), blockNoise(i.uv*8 + 3 + floor(_Time.y)), 1);
                return col;
            }
            ENDCG
        }
    }
}
