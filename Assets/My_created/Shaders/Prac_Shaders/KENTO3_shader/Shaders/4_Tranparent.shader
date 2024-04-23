Shader "Unlit/Tranparent"
{
	//半透明なオブジェクトを描画するためには、(1) オブジェクトの描画順を制御し、(2) 半透明に見えるように色を合成する必要がある。
	//レンダリングパイプラインがオブジェクトを描画するとき、Z Testによって
	//すでに描かれているオブジェクトよりも手前にあるオブジェクトだけが上書きして描画される。
	//つまり、半透明なオブジェクトを描画するためには、それよりも後ろにあるオブジェクトをあらかじめ描画しておく必要がある。
	Properties
    {
        //ここに書いたものがInspectorに表示される 
		_Color("MainColor",Color) = (0,0,0,0)
    }

    SubShader 
    {
		//Render Queueによってオブジェクトの描画順を制御する。
		//Queueに与えられる値が小さいほどレンダーキューの前方に追加され、それより後方にあるオブジェクトよりも先に描画されるようになる。
		//既定値の「Geometry」の値は2000、透明なものに対して使う「Transparent」の値は3000

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

		Pass
		{
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			//変数の宣言　Propertiesで定義した名前と一致させる 
            fixed4 _Color;

			struct appdata {
				float4 vertex : POSITION;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
	}
}
