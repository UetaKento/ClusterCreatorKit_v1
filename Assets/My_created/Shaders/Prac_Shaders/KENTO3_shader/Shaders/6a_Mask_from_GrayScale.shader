Shader "Unlit/Mask_from_GrayScale"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex("MaskTexture", 2D) = "white" {}
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
            sampler2D _MaskTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //マスク用画像のピクセルの色を計算
                fixed4 mask = tex2D(_MaskTex, i.uv);

                //マスク用画像の色を白黒(GrayScale)に変える。黒色に近いほど0に近い値をとる。 
                fixed grayscale = 0.3*mask.r + 0.6*mask.g + 0.1*mask.b;
                mask.a = grayscale;
                //GrayScaleにしたことによって、黒色の部分は0に近い値を持っているので、
                //そこをclipで描画しないようにする。
                clip(mask.a-0.5);

                fixed4 col = tex2D(_MainTex, i.uv);
                return col*mask;
            }
            ENDCG
        }
    }
}
