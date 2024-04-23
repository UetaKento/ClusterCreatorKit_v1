Shader "Unlit/14a_UseCameraDistance"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags{
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
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
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //unity_ObjectToWorldはモデル行列と同じ意味で、ここではモデル変換をしてワールド空間を算出している。
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float cameraDistance = distance(_WorldSpaceCameraPos, i.worldPos);
                //カメラとの距離が0ならば、透明度は1。カメラとの距離が10ならば、透明度は0になるようにした。
                col.a = 1 - (cameraDistance / 10);
                //float clampCameraDis1_10 = clamp(cameraDistance, 1, 10);
                //col.a = 1 - ((clampCameraDis1_10 - 1) / 9);
                clip(col.a-0.01);
                return col;
            }
            ENDCG
        }
    }
}
