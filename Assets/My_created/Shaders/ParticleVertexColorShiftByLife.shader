Shader "Unlit/ParticleVertexColorShiftByLife"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
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

            struct appdata
            {
                float4 vertex : POSITION;
                float vertexID : TEXCOORD1;    // ���_ID
                float lifePercent : TEXCOORD2; // �������� 0->1
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
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                uint id = (int)floor(v.vertexID + 0.5);
                float4 colFrom;
                // ���_ID�ɂ���ĐF��ς����
                if (id == 0)
                    colFrom = float4(1, 0, 0, 1); ///��
                else if (id == 1)
                    colFrom = float4(0, 1, 0, 1); // ��
                else if (id == 2)
                    colFrom = float4(0, 0, 1, 1); // ��
                else
                    colFrom = float4(1, 1, 1, 1); // ���i���̑��j


                uint nextID = (id + 1) % 4;
                float4 colTo;
                if (nextID == 0)
                    colTo = float4(1, 0, 0, 1);
                else if (nextID == 1)
                    colTo = float4(0, 1, 0, 1); 
                else if (nextID == 2)
                    colTo = float4(0, 0, 1, 1); 
                else
                    colTo = float4(1, 1, 1, 1);

                // lifePercent 0->1 �� colFrom->colTo �ɐ��`���
                fixed4 finalColor = lerp(colFrom, colTo, v.lifePercent);
                o.color = finalColor;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texCol = tex2D(_MainTex, i.uv);
                return texCol * i.color;
            }
            ENDCG
        }
    }
}
