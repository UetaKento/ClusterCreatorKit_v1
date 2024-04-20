Shader "Unlit/13_MouseRayHitPoint"
{
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            //C#側でいじる変数
            float4 _MousePosition;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //unity_ObjectToWorldはモデル行列と同じ意味で、ここではモデル変換をしてワールド空間を算出している。
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //ベースカラー白
                half4 baseColor = (1,1,1,1);
                
                /*"マウスから出たRayとオブジェクトの衝突箇所(ワールド座標)"と
                 　"描画しようとしているピクセルのワールド座標"の距離を求める*/
                float dist = distance( _MousePosition, i.worldPos);
                
                //求めた距離が任意の距離以下なら描画しようとしているピクセルの色を変える
                if( dist < 0.1)
                {
                    //赤色乗算代入 
                    baseColor *= half4(1,0,0,0);
                }
                
                return baseColor;
            }
            ENDCG
        }
    }
}
