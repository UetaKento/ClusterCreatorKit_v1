Shader "Unlit/14_UseCameraDistance"
{
    Properties
    {
        //テクスチャー(オフセットの設定なし)
        [NoScaleOffset] _NearTex ("NearTexture", 2D) = "white" {}
        //テクスチャー(オフセットの設定なし)
        [NoScaleOffset] _FarTex ("FarTexture", 2D) = "white" {}
    }
    SubShader
    {
        //透明度に関する設定
        Tags { "RenderType"="Transparent" }
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : WORLD_POS;
                float4 vertex : SV_POSITION;
            };

            //変数の宣言
            sampler2D _NearTex;
            sampler2D _FarTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //unity_ObjectToWorldはモデル行列と同じ意味で、ここではモデル変換をしてワールド空間を算出している。
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //それぞれのテクスチャとUVからピクセルの色を計算
                float4 nearCol = tex2D(_NearTex,i.uv);
                float4 farCol = tex2D(_FarTex,i.uv);

                //マスク用画像の色を白黒(GrayScale)に変える。黒色に近いほど0に近い値をとる。
                float grayscale = 0.3*farCol.r + 0.6*farCol.g + 0.1*farCol.b;
                farCol.a = grayscale;

                // カメラとオブジェクトの距離(長さ)を取得
                // _WorldSpaceCameraPos:定義済の値　ワールド座標系のカメラの位置
                float cameraToObjDistance = distance(_WorldSpaceCameraPos, i.worldPos);
                // Lerpを使って色を変化　補間値に"カメラとオブジェクトの距離"を使用
                fixed4 col = fixed4(lerp(nearCol, farCol, cameraToObjDistance * 0.05));
                //Alphaが0以下なら描画しない
                clip(col);
                //最終的なピクセルの色を返す
                return col;
            }
            ENDCG
        }
    }
}
