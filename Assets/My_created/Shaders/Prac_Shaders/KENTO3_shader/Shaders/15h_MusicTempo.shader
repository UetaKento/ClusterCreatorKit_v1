Shader "Unlit/15h_MusicTempo"
{
    Properties
    {
        _BPM ("Music BPM", float) = 120
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

            float _BPM;

            //UnityのRandomRangeのまんま
            float randRange(float2 Seed)
            {
                //返値は0.000...~0.999...の値。
                float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
                return randomno;
            }

            float sawWaveByBPM(){
                //_BPMが120の時は、1/2になる。1/2秒でビートを刻むので、1秒で2回、60秒で120回刻む。
                float beatIn1second = 60 / _BPM;

                //のこぎり波の周期を変えている。
                //_BPMが120の場合、1秒で1、2秒で1、3秒で1,...ではなく、
                //0.5秒で1、1秒で1(つまり1秒間に2拍)、1.5秒で1、2秒で1,...のようにしたい。（のこぎり波の周期を変えたい）
                //これは、2*_Time.yで実現でき、この「2」は「60 / _BPM」の逆数になる。
                //return (1/beatIn1second)*_Time.y - floor((1/beatIn1second)*_Time.y);

                //のこぎり波の逆転
                //普通ののこぎり波だと、0.99..から1になった瞬間に値が0になるため、0の色が特徴的に見えてしまう。
                //そのため、1-のこぎり波で、0.99..から1になった瞬間の値を1にして、1の色を特徴的に見せる。
                return 1 - ((1/beatIn1second)*_Time.y - floor((1/beatIn1second)*_Time.y));
            }

            v2f vert (appdata v)
            {
                v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex*(1+periodChangedChainsawWave*0.5));
                o.vertex = UnityObjectToClipPos(v.vertex*(2+sawWaveByBPM()));
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //この2行でランダムに色が変わる実装になっている（はず）。
                //int Zero2Three = floor((1/beatIn1second)*_Time.y);
                //fixed4 zeroOne4 = fixed4(randRange(Zero2Three+5), randRange(Zero2Three+2), randRange(Zero2Three), 1);

                fixed4 zeroOne4 = fixed4(0, 0, sawWaveByBPM(), 1);
                return zeroOne4;
            }
            ENDCG
        }
    }
}
