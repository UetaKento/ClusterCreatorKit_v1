Shader "Unlit/Slice_woldPosition"
{
    Properties
    {
        _Color("MainColor",Color) = (0,0,1,0)
        _SliceSpace("SliceSpace",Range(1,10)) = 5
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            //frag関数の戻り値と同じ型(今回の場合はfixed4)にしないと色が出力されない。
            fixed4 _Color;
            half _SliceSpace;

            v2f vert (appdata v)
            {
                v2f o;

                //UnityObjectToClipPosは実は、MVP行列をかけている(=mul(UNITY_MATRIX_MVP, v.vertex))のと同じ処理。
                //頂点シェーダの役割は、受け取った頂点データが画面上のどの位置に映し出されるかを計算することであり、この計算には複雑な座標変換をする必要がある。
                //座標変換の処理は、モデル変換、ビュー変換、プロジェクション変換の3段階で行われる(厳密には透視変換もある)。
                //頂点シェーダに渡される頂点座標は、メッシュデータにおけるモデリング時の原点を中心とする座標「モデル空間(or オブジェクト空間)」の座標になっている。

                //モデル空間中の座標を、シーンの原点(0, 0, 0)を中心とする座標「ワールド空間」の座標に変換するのが「モデル変換」。
                //ワールド空間中の座標を、カメラを基準とする座標「ビュー空間」の座標に変換するのが「ビュー変換」。
                //ビュー空間中の座標 (X, Y, Z)を、それぞれ -1 ~ 1 の値で表現する「クリッピング空間」の座標に変換するのが「プロジェクション変換」と呼ぶ。
                //(プロジェクション変換には、透視変換という変換も行う必要があるが、透視変換はGPUで自動的に行われるため割愛。)

                //モデル変換に必要なのがモデル(M)行列、ビュー変換に必要なのがビュー(V)行列、プロジェクション変換に必要なのがプロジェクション(P)行列で
                //それらを1つにまとめたものがMVP行列(UNITY_MATRIX_MVP)。
                o.vertex = UnityObjectToClipPos(v.vertex);

                //unity_ObjectToWorldはモデル行列と同じ意味で、ここではモデル変換をしてワールド空間を算出している。
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //各頂点のワールド座標(Y軸)それぞれに_SliceSpaceをかけてfrac関数で少数だけ取り出す
                float3 worldSlice = frac(i.worldPos.y * _SliceSpace);
                //そこから-0.5してclip関数に渡す。0を下回ったら描画しない
                clip(worldSlice - 0.5);
                //RGBAにそれぞれのプロパティを当てはめてみる 
                return _Color;
            }
            ENDCG
        }
    }
}
