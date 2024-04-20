Shader "Unlit/Change_size_by_vertex"
{
    SubShader 
    {
		Pass
		{
			Tags { "RenderType"="Opaque" }
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				//メッシュの頂点座標を0.75倍して、vertに代入。
                //float4 vert = v.vertex * 0.75;
				//メッシュの頂点座標を時間経過に応じてSin関数で変化させている。
				//_Timeで時間が取得でき、_Time.(x|y|z|w)で時間の流れる速さを選べる。[x:1/20、y:1、z:2、w:3] 
				float4 vert = float4(v.vertex.xyz * sin(_Time.x), v.vertex.w);
				//そのvertをもとに「3Dの世界での座標は2D(スクリーン)においてはこの位置になりますよ」という変換を行う。
				o.pos = UnityObjectToClipPos(vert);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				return half4(1,	0.5, 0, 1);
			}
			ENDCG
		}
	}
}
