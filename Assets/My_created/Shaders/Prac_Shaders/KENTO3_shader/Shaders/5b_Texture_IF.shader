Shader "Unlit/Texture_IF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                //ポリゴンの各頂点には、テクスチャの座標情報が含まれている。
                //テクスチャの座標情報とは、張り付けられるテクスチャのどの画素(部分)が、
                //その頂点の位置に対応するかを示す情報で、この座標を「UV座標」と呼ぶ。
                //Unityの標準的なキューブの正面側の面には4つの頂点があり、その左下の頂点にはUV座標(0, 0)が、右上の頂点にはUV座標(1, 1)が与えられる。
                //したがって、UV座標(0, 0)が与えられた画素には、テクスチャの座標(0, 0)の色が描画される。 
                float2 uv : TEXCOORD;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD;
            };

            //Unityのスクリプト側のライブラリに定義されるように、
            //型名がTextureやTexture2Dではないが、テクスチャそのものを表す型と覚えてもよい。
            sampler2D _MainTex;
            float _RotateSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //step(edge, x)は「x < edge」の時に0を、それ以外で1を返す。
                //stepは全ての条件がTrue(論理和がTrue)の時にしか1を返さない。
                //例えば、step(0.5, i.uv)で、(i.uv.x, i.uv.y)=(0.7, 0.3)の時、i.uv.yが0.5より小さいので、stepは0を返す。
                //同様に、(i.uv.x, i.uv.y)=(0.2, 0.8)の時、i.uv.xが0.5より小さいので、stepは0を返す。
                //(i.uv.x, i.uv.y)=(0.6, 0.6)の時、両方とも0.5より大きいので、stepは1を返す。 
                half uv_x = step(0.5, i.uv.x);
                half uv_y = step(0.5, i.uv.y);
                //画素ごとにuv_xとuv_yという変数を持たせて、その合計が0.1より小さかったら描画しない。 
                i.uv = step(0.1, uv_x+uv_y) * i.uv;
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
