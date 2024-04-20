Shader "Unlit/Mask_UV_Rolling"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex("MaskTexture", 2D) = "white" {}
        _RotateSpeed ("Rotate Speed", Range(0, 5)) = 0.0
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
            fixed _RotateSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //i.uvは後で回転の計算をするので、先にマスク用画像のピクセルの色をmaskに代入。
                fixed4 mask = tex2D(_MaskTex, i.uv); 
                mask.a = 0.3*mask.r + 0.6*mask.g + 0.1*mask.b;
                //GrayScaleにしたことによって、黒色の部分は0に近い値を持っているので、
                //そこをclipで描画しないようにする。
                clip(mask.a-0.5);

                half timer = _Time.y;
                //回転行列を作る
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);
                half2x2 rotateMatrix = half2x2(angleCos, -angleSin, angleSin, angleCos);
                //中心合わせ。-0.5をしないと、右上の頂点、つまりUV座標(1, 1)を中心に回転する。
                half2 uv = i.uv - 0.5; 
                i.uv = mul(uv, rotateMatrix) + 0.5;

                fixed4 col = tex2D(_MainTex, i.uv);
                return col*mask;
            }
            ENDCG
        }
    }
}