#language slang 2026

import kitty_custom_shader_types;

// Trail lifetime in seconds.
static const float DURATION = 0.5;

// Rainbow movement speed.
// Increase for faster color cycling.
static const float RAINBOW_SPEED = 0.35;

// How many hue rotations appear along the trail.
static const float RAINBOW_DENSITY = 1.0;

// pow(1 - x, 10) via repeated squaring - branchless ease-out.
static float
ease_out10(float x) {
    float y = 1.0 - x;
    float y2 = y * y;
    float y4 = y2 * y2;
    return y4 * y4 * y2;
}

// Smooth blend curve for the progress value.
static float
blend_smooth(float t) {
    float s = t * t;
    return s / (2.0 * (s - t) + 1.0);
}

static float
sdBox(float2 p, float2 center, float2 hext) {
    float2 d = abs(p - center) - hext;
    return length(max(d, float2(0.0))) + min(max(d.x, d.y), 0.0);
}

static float
seg(float2 p, float2 a, float2 b, inout float s, float d) {
    float2 e = b - a;
    float2 w = p - a;
    float2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    d = min(d, dot(p - proj, p - proj));

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);

    s *= lerp(1.0, -1.0, step(0.5, allCond + noneCond));
    return d;
}

static float
sdQuad(float2 p, float2 v0, float2 v1, float2 v2, float2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

static float
movementVertexFactor(float2 a, float2 b) {
    float c1 = step(b.x, a.x) * step(a.y, b.y);
    float c2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(c1, c2);
}

// HSV -> RGB.
// h, s, v are expected in the 0..1 range.
static float3
hsv2rgb(float3 c) {
    float3 p = abs(frac(c.xxx + float3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);

    return c.z * lerp(
        float3(1.0),
        clamp(p - 1.0, 0.0, 1.0),
        c.y
    );
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    if (d.cursor_trail_color.a <= 0.0) return color;

    float age = clamp(
        (d.timestamp - d.cursor_trail_change_time) / DURATION,
        0.0,
        1.0
    );

    if (age >= 1.0) return color;

    float easedProgress = ease_out10(blend_smooth(age));
    if (easedProgress <= 0.0) return color;

    // Work in pixel space for correct aspect-ratio distance measurements.
    float2 pixelDims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float2 px = t.pos * pixelDims;

    // Current cursor.
    float curLeft = d.cursor_trail_edge.x * pixelDims.x;
    float curRight = d.cursor_trail_edge.y * pixelDims.x;
    float curTop = d.cursor_trail_edge.z * pixelDims.y;
    float curBottom = d.cursor_trail_edge.w * pixelDims.y;

    float curWidth = curRight - curLeft;
    float curHeight = curTop - curBottom;

    float2 curCenter = float2(
        (curLeft + curRight) * 0.5,
        (curTop + curBottom) * 0.5
    );

    // Previous cursor.
    float prevLeft = d.cursor_trail_prev_edge.x * pixelDims.x;
    float prevTop = d.cursor_trail_prev_edge.z * pixelDims.y;
    float prevBottom = d.cursor_trail_prev_edge.w * pixelDims.y;

    float2 prevCenter = float2(
        (d.cursor_trail_prev_edge.x + d.cursor_trail_prev_edge.y) * 0.5 * pixelDims.x,
        (d.cursor_trail_prev_edge.z + d.cursor_trail_prev_edge.w) * 0.5 * pixelDims.y
    );

    float2 trailVector = curCenter - prevCenter;
    float lineLength = length(trailVector);

    if (lineLength <= 0.001) return color;

    // 0 = previous cursor, 1 = current cursor.
    float trailPos = clamp(
        dot(px - prevCenter, trailVector) /
        dot(trailVector, trailVector),
        0.0,
        1.0
    );

    // Original Blaze fade behavior.
    float alphaModifier = min(
        length(px - curCenter) / (lineLength * easedProgress),
        1.0
    );

    // Build parallelogram vertices.
    float vf = movementVertexFactor(curCenter, prevCenter);
    float ivf = 1.0 - vf;

    float2 v0 = float2(lerp(curLeft, curRight, vf), curBottom);
    float2 v1 = float2(lerp(curLeft, curRight, ivf), curTop);
    float2 v2 = float2(prevLeft + curWidth * ivf, prevTop);
    float2 v3 = float2(prevLeft + curWidth * vf, prevBottom);

    float sdfCursor = sdBox(
        px,
        curCenter,
        float2(curWidth, curHeight) * 0.5
    );

    float sdfTrail = sdQuad(px, v0, v1, v2, v3);

    // Rainbow hue:
    //
    // - trailPos produces a rainbow along the trail
    // - timestamp continuously shifts the rainbow
    //
    float hue = frac(
        trailPos * RAINBOW_DENSITY +
        d.timestamp * RAINBOW_SPEED
    );

    float3 rainbow = hsv2rgb(float3(hue, 1.0, 1.0));

    // A slightly brighter / shifted accent for the Blaze border.
    float accentHue = frac(hue + 0.08);
    float3 rainbowAccent = hsv2rgb(
        float3(accentHue, 1.0, 1.0)
    );

    float4 trailColor = float4(rainbow, 1.0);
    float4 trailAccent = float4(rainbowAccent, 1.0);

    float aaRange = 2.0;
    float4 newColor = color;

    // Same inner-border treatment as Blaze.
    newColor = lerp(
        newColor,
        trailAccent,
        1.0 - smoothstep(
            sdfTrail,
            -aaRange,
            aaRange * 0.05
        )
    );

    // Rainbow fill.
    newColor = lerp(
        newColor,
        trailColor,
        1.0 - smoothstep(
            0.0,
            aaRange,
            sdfTrail
        )
    );

    // Same fade toward the previous cursor position.
    newColor = lerp(
        color,
        newColor,
        1.0 - alphaModifier
    );

    // Don't paint over the cursor itself.
    return lerp(
        newColor,
        color,
        step(sdfCursor, 0.0)
    );
}
