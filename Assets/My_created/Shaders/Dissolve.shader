Shader "Unlit/Dissolve"
{
    Properties
    {
        [NoScaleOffset]
        _MainTex ("Texture", 2D) = "white" {}
        _DissolveTex("DissolveTexture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Tranparent" }
        Blend SrcAlpha OneMinusSrcAlpha
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
                // パーティクルの情報がTEXCOORD0.zに入っているのでfloat3。
                float3 uv : TEXCOORD0;
                // パーティクルの色情報。
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                // 今回はFragmentShaderでパーティクルの情報を
                // 使うのでこっちもfloat3に。
                float3 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _DissolveTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 dissolve = tex2D(_DissolveTex, i.uv);
                // Dissolve画像の白黒度合い(GrayScale)を計算する。
                // 白色に近いほど1に、黒色に近いほど0に近い値をとる。 
                float threshold = 0.3*dissolve.r + 0.6*dissolve.g + 0.1*dissolve.b;

                // clip()は引数が0以下の場合、そのpixelを描画しないという処理をする。
                // Custom Dataで設定したCurveによってi.uv.zは変化し、
                // i.uv.zを使った計算によってpixelを描画するかしないかを決める。
                clip(threshold - i.uv.z);
                return col * i.color;
            }
            ENDCG
        }
    }
}
