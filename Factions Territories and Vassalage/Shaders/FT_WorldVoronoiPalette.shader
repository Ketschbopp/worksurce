Shader "FactionTerritories/WorldVoronoiPalette"
{
    Properties
    {
        _CellTex ("World Cell Texture", 2D) = "white" {}
        _PaletteTex ("Palette Texture", 2D) = "white" {}
        _PaletteCount ("Palette Count", Float) = 1
        _Alpha ("Alpha", Range(0,1)) = 1
        _EdgeStrength ("Edge Strength", Range(0,1)) = 0.25
    }

    SubShader
    {
        Tags
        {
            "Queue"="Overlay"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _CellTex;
            sampler2D _PaletteTex;

            float _PaletteCount;
            float _Alpha;
            float _EdgeStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 cell = tex2D(_CellTex, i.uv);

                float cellId = cell.r * 255.0;
                float edge = cell.g;

                float idx = fmod(cellId, max(1.0, _PaletteCount));
                float u = (idx + 0.5) / max(1.0, _PaletteCount);

                fixed4 col = tex2D(_PaletteTex, float2(u, 0.5));
                col.a *= _Alpha;

                float edgeDarken = lerp(1.0, 1.0 - _EdgeStrength, saturate(edge));
                col.rgb *= edgeDarken;

                return col;
            }
            ENDCG
        }
    }
}
