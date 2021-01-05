
void ColorSplit_float(float4 TintColor, out float3 ColorRGB, out float ColorA)
{
    #if SHADERGRAPH_PREVIEW

    ColorRGB = TintColor.rgb;
    ColorA = TintColor.a;

    #else

    ColorRGB = TintColor.rgb;
    ColorA = TintColor.a;

    #endif
}