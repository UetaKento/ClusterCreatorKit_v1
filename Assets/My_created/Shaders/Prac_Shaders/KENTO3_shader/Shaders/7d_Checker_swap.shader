Shader "Unlit/Checker_swap"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _MaskTex1("MaskTexture1", 2D) = "white" {}
        _MaskTex2("MaskTexture2", 2D) = "white" {}
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

            sampler2D _MainTex;
            sampler2D _MaskTex1;
            sampler2D _MaskTex2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //のこぎり波によって増え続ける_Time.yのinputに対して、0->1->0->1...というoutputが出せる。 
                half nokogiriWave = _Time.y - floor(_Time.y);
                fixed4 mask1 = tex2D(_MaskTex1, i.uv);
                fixed4 mask2 = tex2D(_MaskTex2, i.uv);
                //step(edge, x)は「x < edge」の時に0を、それ以外で1を返す。
                //「0.5 < nokogiriWave」の時に「0」なので、逆に「nokogiriWave < 0.5」の時に「1」になる。
                //「nokogiriWave < 0.5」の時に「0」なので、逆に「0.5 < nokogiriWave」の時に「1」になる。
                fixed4 mask3 = step(nokogiriWave, 0.5)*mask1 + step(0.5, nokogiriWave)*mask2;
                //マスク用画像の色を白黒(GrayScale)に変える。黒色に近いほど0に近い値をとる。 
                mask3.a = 0.3*mask3.r + 0.6*mask3.g + 0.1*mask3.b;
                clip(mask3.a-0.5);
                fixed4 col = tex2D(_MainTex, i.uv);
                return col*mask3;
            }
            ENDCG
        }
    }
}
