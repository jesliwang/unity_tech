void CustomLight_float(out float3 Direction , out float3 Color)
{
    #if SHADERGRAPH_PREVIEW
        Direction = float3(1,1,0);
        Color = float3(0,0,1);
    #else
        Light light = GetMainLight();
        Direction = light.direction;
        Color = light.color;
    #endif
}

void CustomLight_half(out half3 Direction, out half3 Color)
{
    #if SHADERGRAPH_PREVIEW
        Direction = half3(1, 1, 0);
        Color = half3(0, 0, 1);
    #else
        Light light = GetMainLight();
        Direction = light.direction;
        Color = light.color;
    #endif
}
