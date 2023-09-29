Shader "Unlit/UVScroll_Wire"
{
    Properties
    {
        //[NoScaleOffset]
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex("MaskTexture", 2D) = "white" {}
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
                float3 uv_mask : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float4 color : COLOR; // パーティクル用の色情報。
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv_mask : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                o.uv_mask.x = v.uv_mask.x;
                o.uv_mask.y = v.uv_mask.y + v.uv_mask.z;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_MaskTex, i.uv_mask);
                i.color = half4(1, 0, 0, 1); //パーティクルの色情報は書き込み可能。
                return col * mask * i.color;
            }
            ENDCG
        }
    }
}
