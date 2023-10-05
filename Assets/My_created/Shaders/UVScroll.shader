Shader "Unlit/UVScroll"
{
    Properties
    {
        [NoScaleOffset]
        _MainTex ("Texture", 2D) = "white" {}
        // UVScrollをずらすための係数。
        _ScrollZurashi("ScrollZurashi", Range(0,1))= 0.83
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
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            half _ScrollZurashi;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.x = v.uv.x;
                // v.uv.zのままだとスクロールが一周して見た目が汚くなるので
                // _ScrollZurashiで調整。
                o.uv.y = v.uv.y + (v.uv.z * _ScrollZurashi);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // パーティクルの色情報を乗算。
                return col * i.color;
            }
            ENDCG
        }
    }
}
