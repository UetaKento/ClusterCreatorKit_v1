Shader "Unlit/Mask_UV_Rolling_Sep_cv"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex("MaskTexture", 2D) = "white" {}
        _RotateSpeed ("Rotate Speed", float) = 1.0
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
                float2 uv4main : TEXCOORD0;
                float2 uv4mask : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv4main : TEXCOORD0;
                float2 uv4mask : TEXCOORD1;
            };

            //Unityのスクリプト側のライブラリに定義されるように、
            //型名がTextureやTexture2Dではないが、テクスチャそのものを表す型と覚えてもよい。
            sampler2D _MainTex;
            sampler2D _MaskTex;
            float _RotateSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv4main = v.uv4main;
                o.uv4mask = v.uv4mask;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                half timer = _Time.x;
                //回転行列を作る
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);
                half2x2 rotateMatrix = half2x2(angleCos, -angleSin, angleSin, angleCos);
                //中心合わせ。-0.5をしないと、右上の頂点、つまりUV座標(1, 1)を中心に回転する。
                half2 uv = i.uv4main - 0.5; 
                i.uv4main = mul(uv, rotateMatrix) + 0.5;

                //マスク用画像のピクセルの色を計算
                fixed4 mask = tex2D(_MaskTex, i.uv4mask); 
                mask.a = 0.3*mask.r + 0.6*mask.g + 0.1*mask.b;
                //GrayScaleにしたことによって、黒色の部分は0に近い値を持っているので、
                //そこをclipで描画しないようにする。 
                clip(mask.a-0.5);

                fixed4 col = tex2D(_MainTex, i.uv4main);
                return col*mask;
            }
            ENDCG
        }
    }
}
