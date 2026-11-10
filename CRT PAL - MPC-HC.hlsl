// $MinimumShaderProfile: ps_3_0
// SPDX-License-Identifier: GPL-3.0-only
// CRT PAL for SDR video in MPC-HC and MPC Video Renderer. Modified on 2026-11-10.
// The screen warp adapts Warp_koko from Koko-AIO by Antonio Orefice (kokoko3k).
// See LICENSE and THIRD_PARTY_NOTICES.md for the license and upstream source.

sampler2D video : register(s0);
float4 dimensions : register(c0);
float4 pixelMetrics : register(c1);

#define outputSize (dimensions.xy)
#define texelSize (pixelMetrics.xy)

static const float Pi = 3.14159265359;
static const float TubeZoom = 0.955;
static const float2 TubeWarp = float2(0.28, 0.32);
static const float MaximumPALRows = 288.0;
static const float MinimumPixelsPerRow = 3.60;
static const float ScanlineContrast = 0.27;
static const float HorizontalSpreadPixels = 1.5;
static const float BrightnessCompensation = 0.04;
static const float PictureBrightness = 1.05;
static const float PictureContrast = 1.05;
static const float3 LumaWeights = float3(0.2126, 0.7152, 0.0722);

// MPCVR binds a point sampler here. Interpolate explicitly for the warped picture.
float3 SampleVideo(float2 uv)
{
    // Clamp once before splitting the bilinear sample into neighboring texels.
    float2 samplePosition = clamp(uv * outputSize - 0.5, 0.0, outputSize - 1.0);
    float2 base = floor(samplePosition);
    float2 next = min(base + 1.0, outputSize - 1.0);
    float2 fraction = samplePosition - base;
    float2 lowUv = (base + 0.5) * texelSize;
    float2 highUv = (next + 0.5) * texelSize;

    float3 a = tex2Dlod(video, float4(lowUv, 0.0, 0.0)).rgb;
    float3 b = tex2Dlod(video, float4(highUv.x, lowUv.y, 0.0, 0.0)).rgb;
    float3 c = tex2Dlod(video, float4(lowUv.x, highUv.y, 0.0, 0.0)).rgb;
    float3 d = tex2Dlod(video, float4(highUv, 0.0, 0.0)).rgb;
    return lerp(lerp(a, b, fraction.x), lerp(c, d, fraction.x), fraction.y);
}

float3 SampleTap(float2 uv)
{
    return tex2Dlod(video, float4(clamp(uv, 0.5 * texelSize, 1.0 - 0.5 * texelSize), 0.0, 0.0)).rgb;
}

float3 GlowEmission(float3 color, float threshold)
{
    // Input taps are already in the required SDR 0-1 range.
    float luminance = dot(color, LumaWeights);
    return color * smoothstep(threshold, 0.90, luminance);
}

float2 Warp(float2 uv)
{
    float2 centered = (uv - 0.5) / TubeZoom;
    return centered / (1.0 + TubeWarp * (0.125 - 0.5 * dot(centered, centered)));
}

float3 TubeColor(float2 uv, float2 outputUv, float spreadMask)
{
    float3 base = SampleVideo(uv);
    float2 narrow = max(1.5, outputSize.y / 420.0) * texelSize * float2(1.0, 0.78);
    float2 wide = max(4.0, outputSize.y / 72.0) * texelSize;

    float3 left = SampleTap(uv - float2(narrow.x, 0.0));
    float3 right = SampleTap(uv + float2(narrow.x, 0.0));
    float3 top = SampleTap(uv - float2(0.0, narrow.y));
    float3 bottom = SampleTap(uv + float2(0.0, narrow.y));

    // Soften the picture before scanlines, using the same taps as the tight glow.
    float3 nearby = 0.25 * (left + right + top + bottom);
    base = lerp(base, nearby, 0.26);
    // One horizontal screen pixel in the post-resize quad's texture coordinates.
    float2 spreadOffset = HorizontalSpreadPixels * ddx(outputUv);
    float2 farOffset = 1.6 * spreadOffset;
    // Map taps through the tube so they stay on the same output row.
    float3 horizontal = 0.30 * (
        SampleVideo(Warp(outputUv - spreadOffset) + 0.5) +
        SampleVideo(Warp(outputUv + spreadOffset) + 0.5)) +
        0.20 * (
        SampleVideo(Warp(outputUv - farOffset) + 0.5) +
        SampleVideo(Warp(outputUv + farOffset) + 0.5));
    base = lerp(base, horizontal, 0.68 * spreadMask);
    float3 phosphorGlow = 0.25 * (
        GlowEmission(left, 0.24) + GlowEmission(right, 0.24) +
        GlowEmission(top, 0.24) + GlowEmission(bottom, 0.24));

    // Use two staggered radii for the wider bloom so highlights scatter softly.
    float3 bloom = 0.125 * (
        GlowEmission(SampleTap(uv + wide * float2( 0.91,  0.24)), 0.41) +
        GlowEmission(SampleTap(uv + wide * float2(-0.91, -0.24)), 0.41) +
        GlowEmission(SampleTap(uv + wide * float2( 0.29, -0.95)), 0.41) +
        GlowEmission(SampleTap(uv + wide * float2(-0.29,  0.95)), 0.41) +
        GlowEmission(SampleTap(uv + wide * float2( 0.37,  0.49)), 0.41) +
        GlowEmission(SampleTap(uv + wide * float2(-0.37, -0.49)), 0.41) +
        GlowEmission(SampleTap(uv + wide * float2( 0.53, -0.31)), 0.41) +
        GlowEmission(SampleTap(uv + wide * float2(-0.53,  0.31)), 0.41));

    float luma = saturate(dot(base, LumaWeights));
    float highlight = smoothstep(0.54, 0.94, luma);
    float3 color = lerp(float3(luma, luma, luma), base, lerp(0.86, 0.97, highlight));
    color *= 1.0 - 0.26 * luma * (1.0 - luma);

    // Keep glow on the darker surroundings and prevent it from washing out bright fills.
    float3 glow = 0.22 * phosphorGlow + 0.37 * bloom;
    color += glow * (1.0 - color) * (1.0 - 0.72 * highlight);
    color *= 1.0 - 0.095 * highlight;

    float2 radius = (uv - 0.5) * 2.0;
    return color * (1.0 - 0.062 * saturate(dot(radius, radius) * 0.55));
}

float3 BezelColor(float2 warped, float distanceOutside)
{
    // Mirror a narrow strip of the video against the lip of the tube.
    float2 edgeDistance = abs(warped) - 0.5;
    float2 edgeUv = 0.5 + sign(warped) * (0.5 - abs(edgeDistance));
    // Keep a sample on the reflected ray so thin highlights cannot fall between taps.
    // A narrow blur in output pixels keeps the reflection soft.
    float2 spread = 2.5 * texelSize;
    float3 reflected = 0.60 * SampleVideo(edgeUv) + 0.20 * (
        SampleTap(edgeUv + spread) + SampleTap(edgeUv - spread));

    float lip = 1.0 - smoothstep(0.001, 0.007, distanceOutside);
    // At corners, account for the distance beyond both edges.
    float cornerDistance = max(min(edgeDistance.x, edgeDistance.y), 0.0);
    float reflectionFalloff = 1.0 - smoothstep(0.0, 0.042, distanceOutside + cornerDistance);
    float3 body = lerp(float3(0.021, 0.023, 0.026), float3(0.040, 0.042, 0.044), lip);
    return body + reflected * reflectionFalloff * lerp(0.20, 0.39, lip);
}

float4 main(float2 uv : TEXCOORD0, float2 position : VPOS) : COLOR
{
    float2 warped = Warp(uv);
    float2 tubeUv = warped + 0.5;
    float outside = max(abs(warped.x), abs(warped.y)) - 0.5;
    float pixelWidth = max(fwidth(outside), 0.00001);
    float coverage = 1.0 - smoothstep(-0.65 * pixelWidth, 0.65 * pixelWidth, outside);

    // The mask is in output coordinates, after curvature and color shaping.
    float tubeHeight = max(outputSize.y * TubeZoom, 1.0);
    float rowCount = min(MaximumPALRows, tubeHeight / MinimumPixelsPerRow);
    float phaseWidth = Pi * rowCount / tubeHeight;
    float phase = ((uv.y - 0.5) * outputSize.y) * phaseWidth;
    // phaseWidth is at most Pi / 3.60. The sinc expansion truncation error is below 1e-8.
    float phaseWidthSquared = phaseWidth * phaseWidth;
    float pixelAverage = 1.0 + phaseWidthSquared * (
        -1.0 / 6.0 + phaseWidthSquared * (
         1.0 / 120.0 + phaseWidthSquared * (
        -1.0 / 5040.0 + phaseWidthSquared / 362880.0)));
    float wave = -cos(2.0 * phase) * pixelAverage;
    // Use destination pixel rows so resizing and cropping cannot stretch the 2+2 mask.
    float outputRow = floor(position.y);
    float spreadMask = 1.0 - step(0.5, frac(outputRow * 0.25));
    float3 color = TubeColor(tubeUv, uv, spreadMask);
    float edge = smoothstep(0.035, 0.16, fwidth(dot(color, LumaWeights)));
    float peak = max(color.r, max(color.g, color.b));
    float headroom = saturate((1.0 - peak) / max(peak, 0.0001));
    color *= 1.0 + headroom *
        (BrightnessCompensation + ScanlineContrast * lerp(1.0, 0.35, edge) * wave);

    // Adjust the finished picture with contrast centered on mid-gray.
    color = saturate(((color - 0.5) * PictureContrast + 0.5) * PictureBrightness);

    float3 bezel = 0.0;
    if (coverage < 1.0)
        bezel = BezelColor(warped, max(outside, 0.0));

    return float4(lerp(bezel, color, coverage), 1.0);
}
