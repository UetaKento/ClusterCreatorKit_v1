Shader "Unlit/ParticleWithCenterScaling"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleFactor ("Scale Factor", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _ScaleFactor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 center : TEXCOORD1;  // Custom Vertex StreamのCenterを受け取る
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;

                // 頂点位置とパーティクル中心の差分ベクトルを計算
                float3 offset = v.vertex.xyz - v.center;

                // 差分ベクトルにスケールをかけて頂点を拡大・縮小
                float3 scaledPos = v.center + offset * _ScaleFactor;

                // 変換してクリップ空間に
                o.pos = UnityObjectToClipPos(float4(scaledPos, 1.0));

                o.uv = v.uv;
                o.color = v.color;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                return col;
            }
            ENDCG
        }
    }
}
