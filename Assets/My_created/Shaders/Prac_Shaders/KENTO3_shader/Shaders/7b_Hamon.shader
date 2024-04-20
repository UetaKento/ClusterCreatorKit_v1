Shader "Unlit/Hamon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex("MaskTexture", 2D) = "white" {}
        _SizeUpSpeed ("SizeUpSpeed", Range(0, 5)) = 1.0
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
            half _SizeUpSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //メッシュの頂点座標を時間経過に応じてSin関数で変化させている。
				//_Timeで時間が取得でき、_Time.(x|y|z|w)で時間の流れる速さを選べる。[x:1/20、y:1、z:2、w:3] 
				float4 vert = float4(v.vertex.xyz * sin(_Time.y * _SizeUpSpeed), v.vertex.w);
				//そのvertをもとに「3Dの世界での座標は2D(スクリーン)においてはこの位置になりますよ」という変換を行う。
				o.vertex = UnityObjectToClipPos(vert);
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
