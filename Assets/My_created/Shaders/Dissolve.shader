Shader "Unlit/Dissolve"
{
    Properties
    {
        //[NoScaleOffset]
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
                float3 uv : TEXCOORD0;
                float4 color : COLOR; // パーティクル用の色情報。
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
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
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 dissolve = tex2D(_DissolveTex, i.uv);
                //Dissolve画像の色を白黒(GrayScale)に変える。黒色に近いほど0に近い値をとる。 
                //dissolve.a = 0.3*dissolve.r + 0.6*dissolve.g + 0.1*dissolve.b;
                float Threshold = 0.3*dissolve.r + 0.6*dissolve.g + 0.1*dissolve.b;
                clip(Threshold - i.uv.z);
                return col * i.color;
            }
            ENDCG
        }
    }
}
