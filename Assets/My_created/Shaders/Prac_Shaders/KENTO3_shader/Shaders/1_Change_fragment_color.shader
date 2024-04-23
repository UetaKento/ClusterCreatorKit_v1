Shader "Unlit/Change_fragment_color"
{
    //実行できない場合は最後にFallback "○○" と書いとけば○○で実行される
    SubShader 
    {
		Pass
		{
			//タグ　透明度とか設定できるらしい
			Tags { "RenderType"="Opaque" }
		
			//こっから書きますよ　みたいな宣言
			CGPROGRAM
			//vertexシェーダーとfragmentシェーダーの関数がどれなのか伝える
			//実行モードにしなくても定義したらUnityが勝手に呼びだしてくれる 
			#pragma vertex vert
			#pragma fragment frag
			//便利関数詰め合わせセットらしい
			#include "UnityCG.cginc"

			// vert関数の引数となる構造体
			struct appdata {
				// 描画しようとしているオブジェクトのオブジェクト空間中の座標。「オブジェクト空間」とは、そのオブジェクトの原点を中心とする座標系。
				float4 vertex : POSITION;
			};

			//文字通りvertexシェーダーとfragmentシェーダーの間におけるデータのやりとりで使うための構造体
			//ただし、これはあくまで便宜上の命名であり、変換した座標の情報を真に必要としているのは、後に続くカリングやラスタライズであることを忘れないようにしましょう。
			struct v2f 
			{
				//変数名の後ろの大文字はセマンティクスという。セマンティクスの役割は、その値の意味や目的をレンダリングパイプラインに明示すること。
				float4 pos : SV_POSITION;
			};

			//vertexの関数。この関数は入力される頂点毎に呼び出される
			v2f vert(appdata v)
			{
				v2f o;
				//"3Dの世界での座標は2D(スクリーン)においてはこの位置になりますよ"　という変換を関数を使って行っている 
				o.pos = UnityObjectToClipPos(v.vertex);
				//変換した座標を返す
				return o;
			}

			//fragmentの関数。この関数は、塗りつぶす画素毎に呼び出される。
			half4 frag(v2f i) : SV_Target
			{
				//色情報を返す　R G B A
				return half4(1,	1, 0, 1);
			}
			//ここで終わりの宣言
			ENDCG
		}
	}
}
