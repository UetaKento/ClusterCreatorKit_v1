Shader "Unlit/11_UVScroll_NoTexture"
{
    Properties
    {
        _Color("MainColor",Color) = (1,0,0.1,0)
        _SliceSpace("SliceSpace",Range(0,30)) = 15
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            half _SliceSpace;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _Time.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float uvSlice = frac(i.uv.y * _SliceSpace);
                //clip(uvSlice - 0.5);
                clip(frac(i.uv.y * _SliceSpace) - 0.5);
                return _Color;
            }
            ENDCG
        }
    }
}
