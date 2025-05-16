Shader "Unlit/SheetAnimation"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Main Color",Color) = (1,1,1,1)
        _Row("Row",int) = 4
        _Column("Column",int) = 4
        _Speed("Speed",float) = 1
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;

            uint _Row;
            uint _Column;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //全てのコマ数を計算
                uint cells = _Row * _Column;
                //時間にSpeedを掛けて小数点以下だけを返すことで0～1を生成
                fixed process = frac(_Time.y * _Speed);
                //index=どのコマを指しているか
                uint index = process * cells;

                //1コマ当たりのUVサイズを計算
                float invRow = 1.0 / (float)_Row;
                float invColumn = 1.0 / (float)_Column;

                float2 tiling = float2(invRow,invColumn);

                //indexからどのコマに当たるかを計算する
                half x = (index % _Row) * invRow;
                //画像の左上からコマが始まるのでひっくり返している
                half y = 1 - (((index / _Row) +1) * invColumn);

                float2 offset = float2(x,y);

                //テクスチャのオフセットを適用する
                fixed4 col = tex2D(_MainTex, (i.uv * tiling) + offset);
                //色を変えられるようにする
                col *= _MainColor;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
