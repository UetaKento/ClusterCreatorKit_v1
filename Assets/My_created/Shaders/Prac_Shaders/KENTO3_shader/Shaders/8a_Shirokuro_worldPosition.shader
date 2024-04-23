Shader "Unlit/Shirokuro_worldPosition"
{
    Properties
    {
        //_Color("MainColor",Color) = (0,0,1,0)
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
                float3 worldPos : WORLD_POS;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            //float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //step(edge, x)は「x < edge」の時に0を、それ以外で1を返す。
                //「0<i.worldPos.x」の時に(0,0,0,0)つまり黒色を返し、それ以外の時には(1,1,1,0)つまり白色を返す。
                //fixed4 monokuro = (step(i.worldPos.x, 0), step(i.worldPos.x, 0), step(i.worldPos.x, 0), 0);
                //だと上手くいかないので、ちゃんと「fixed4(step(i.worldPos.x, 0), step(i.worldPos.x, 0), step(i.worldPos.x, 0), 0);」とする。 
                fixed4 monokuro = fixed4(step(i.worldPos.x, 0), step(i.worldPos.x, 0), step(i.worldPos.x, 0), 0); 
                return monokuro;
                //return fixed4(step(i.worldPos.x, 0), step(i.worldPos.x, 0), step(i.worldPos.x, 0), 0);
            }
            ENDCG
        }
    }
}
