Shader "Unlit/15f_OriginalPerlinNoise_v3"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags
		{
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

		//Blend構文は色の合成方法を設定するための構文。この1行でブレンドモードが変更され、アルファブレンディングが行われる。
		//もっとも基本的なアルファブレンディングは「SrcColor * SrcFactor + DstColor * DstFactor」のように設定される。
		//SrcColorは今現在Fragmentシェーダが算出して書き込もうとしている色。DstColorは既に描画先に書き込まれている色。
		//SrcFactorはSrcAlpha、DstFactorはOneMinusSrcAlph。
		//Blend構文を使ってブレンディング(の式)を設定するとき、SrcColorとDstColorは省略され、係数となるSrcFactorとDstFactorだけを記述する。
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
            float rand(float2 seed)
            {
                //返値は0.000...~0.999...の値。
                //return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453);
                float st = dot(seed.xy, float2(12.9898, 78.233));
                return frac(sin(st)*43758.5453);
            }

            fixed2 random2(fixed2 seed)
            {
                fixed2 st = fixed2( dot(seed, fixed2(127.1,311.7)), dot(seed, fixed2(269.5,183.3)) );
                return -1.0 + 2.0*frac(sin(st)*43758.5453123);
            }

            //3次関数補間。イーズ曲線？とも呼ばれるらしい。
            fixed easeFunction(fixed x)
            {
                return -2*pow(x, 3)+3*pow(x, 2);
            }

            //バリューノイズでは、格子点が乱数値を持っていて、格子点からどれくらいの距離にいるか、をもとに格子点の値からノイズ値を決めていた。
            //パーリンノイズでは、格子点が勾配ベクトルを持っていて、格子点からどれくらいの距離、方向にいるか、をもとにノイズ値を決める。勾配ベクトル自体は乱数値から決定する．
            float perlinNoise(fixed2 uv)
            {
                //n倍スケールされたuv座標(例えば、(2.4, 3.2))であっても
                //floor()とfrac()を使って、0~1のuv座標で考えれるようにする。

                //入力点がどのブロックにいるかの計算。uv_intは整数。
                fixed2 uv_int = floor(uv);
                //入力点がブロック内の左下からどれくらい離れているか(オフセット値)の計算。uv_floatは小数。
                fixed2 uv_float = frac(uv);

                //uv_int + fixed2(0, 0)~fixed2(1, 1)で、入力点におけるブロックの4隅の格子点を計算。
                //その格子点に、random2()でランダムなベクトルを持たせる。
                float2 uv00_RamVec = random2(uv_int + fixed2(0, 0));
                float2 uv10_RamVec = random2(uv_int + fixed2(1, 0));
                float2 uv01_RamVec = random2(uv_int + fixed2(0, 1));
                float2 uv11_RamVec = random2(uv_int + fixed2(1, 1));

                //uv_float - fixed2(0, 0)~fixed2(1, 1)で、格子点から入力点までの距離ベクトルを計算(距離=目的地-現在地)。
                //格子点のランダムなベクトルと距離ベクトルを内積。 
                float uv00_dot = dot(uv00_RamVec, uv_float - fixed2(0, 0));
                float uv10_dot = dot(uv10_RamVec, uv_float - fixed2(1, 0));
                float uv01_dot = dot(uv01_RamVec, uv_float - fixed2(0, 1));
                float uv11_dot = dot(uv11_RamVec, uv_float - fixed2(1, 1));

                //オフセット値を補間することで、色の境界が滑らかになる。
                float2 interpolate_uv = float2(easeFunction(uv_float.x), easeFunction(uv_float.y));

                //入力点のx座標で格子点との色のブレンドを行っている。
                //直感的にはinterpolate_uv.xではなく、uv_float.xだが、これだと色の境界がガビガビになってしまう。
                //uv_float.xを3次関数補間で変換した値を使うことで、色の境界が滑らかになる。
                float uv0010 = lerp(uv00_dot, uv10_dot, interpolate_uv.x);
                float uv0111 = lerp(uv01_dot, uv11_dot, interpolate_uv.x);

                ////入力点のy座標で格子点との色のブレンドを行っている。。+0.5がないと黒くなりすぎてしまうので注意。
                return lerp(uv0010, uv0111, interpolate_uv.y)+0.5;
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

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.y = v.uv.y;
                o.uv.x = v.uv.x+_Time.x;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed4 tex = tex2D(_MainTex, i.uv);
                float perlinUV = perlinNoise(i.uv*8);
                fixed4 col = fixed4(perlinUV, perlinUV, perlinUV, perlinUV);
                return col;
            }
            ENDCG
        }
    }
}
