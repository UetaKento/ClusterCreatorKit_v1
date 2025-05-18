Shader "Unlit/ParticleVertexIDColor"
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
                float vertexID : TEXCOORD1;   // VertexID���󂯎��
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

                // VertexID��float�Ȃ̂Ő�����
                int id = (int)floor(v.vertexID + 0.5);

                // ���_ID�ɂ���ĐF��ς����
                if (id == 0)
                    o.color = float4(1, 0, 0, 1); // ��
                else if (id == 1)
                    o.color = float4(0, 1, 0, 1); // ��
                else if (id == 2)
                    o.color = float4(0, 0, 1, 1); // ��
                else
                    o.color = float4(1, 1, 1, 1); // ���i���̑��j

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // �e�N�X�`���ƒ��_�F����Z
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                return col;
            }
            ENDCG
        }
    }
}
