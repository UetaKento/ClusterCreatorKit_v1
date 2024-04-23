Shader "Unlit/12_UVScroll"
{
    Properties
    {
        _StripeColor1("StripeColor1",Color) = (1,0,0,0)
        _StripeColor2("StripeColor2",Color) = (0,1,0,0)
        //スライスされる間隔
        _SliceSpace("SliceSpace",Range(0,1)) = 0.5
        //uv座標にかける係数
        _uvScaleUp("UVScaleUP",Range(0,10)) = 1
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            half4 _StripeColor1;
            half4 _StripeColor2;
            half _SliceSpace;
            half _uvScaleUp;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv.y = v.uv.y + _Time.x;だけの記述だとおかしくなるので、
                //o.uv.x = v.uv.x;もちゃんと書く。　
                o.uv.y = v.uv.y + _Time.x;
                o.uv.x = v.uv.x;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {               
                //step(edge, x)は「x < edge」の時に0を、それ以外で1を返す。
                //例えば、_uvScaleUp=15で今の画素がuv座標が(0.3, 0.5)の場合、i.uv.y * 15によってi.uv.y=7.5になり
                //frac(i.uv.y * 15)によって「0.5」の値がででくる。
                //この時、_SliceSpaceが0.5より小さかったら0を、そうでなければ1を返す。
                half interpolation = step(frac(i.uv.y * _uvScaleUp), _SliceSpace);

                //本来lerp(a,b,x)は、xが0に近ければaの影響を強く、1に近ければbの影響を強くするような補完の機能。
                //今回はinterpolationが0と1の値しか取らないので、_StripeColor1か_StripeColor2を返す。
                //frac()は小数点しか取らないので、_SliceSpaceが1に向けて大きくなると、_StripeColor2の色の範囲が増える。
                half4 color = lerp(_StripeColor1,_StripeColor2, interpolation);
                return color;
            }
            ENDCG
        }
    }
}
