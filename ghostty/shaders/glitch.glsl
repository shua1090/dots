// Random-looking horizontal glitch artifacts every few seconds.

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float hash2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 base = texture(iChannel0, uv);
    float cycle = floor(iTime / 3.5);
    float cycle_pos = fract(iTime / 3.5);

    float band_start = 0.14 + hash(cycle * 17.31) * 0.50;
    float tear_start = 0.24 + hash(cycle * 29.73) * 0.46;
    float chroma_start = 0.34 + hash(cycle * 41.11) * 0.42;
    float static_start = 0.10 + hash(cycle * 53.77) * 0.62;

    float band_burst = smoothstep(band_start, band_start + 0.015, cycle_pos) *
        (1.0 - smoothstep(band_start + 0.11, band_start + 0.16, cycle_pos));
    float tear_burst = smoothstep(tear_start, tear_start + 0.010, cycle_pos) *
        (1.0 - smoothstep(tear_start + 0.055, tear_start + 0.090, cycle_pos));
    float chroma_burst = smoothstep(chroma_start, chroma_start + 0.020, cycle_pos) *
        (1.0 - smoothstep(chroma_start + 0.16, chroma_start + 0.22, cycle_pos));
    float static_burst = smoothstep(static_start, static_start + 0.025, cycle_pos) *
        (1.0 - smoothstep(static_start + 0.10, static_start + 0.15, cycle_pos));

    float glitch_on = max(max(band_burst, tear_burst), max(chroma_burst, static_burst));
    if (glitch_on <= 0.001) {
        fragColor = base;
        return;
    }

    float line = floor(fragCoord.y / 5.0);
    float band_seed = hash(line + cycle * 101.9);
    float band = step(0.70, band_seed);
    float band_gate = step(0.30, hash2(vec2(line, cycle)));
    float jitter = (hash(line * 19.19 + cycle * 7.7) - 0.5) * 0.040 * band_burst * band * band_gate;
    float fine_noise = (hash2(floor(fragCoord.xy / vec2(18.0, 3.0)) + cycle) - 0.5) * 0.006 * static_burst;
    float tear = (hash(cycle * 5.13) - 0.5) * 0.032 * tear_burst *
        smoothstep(0.44, 0.52, uv.y) * (1.0 - smoothstep(0.58, 0.66, uv.y));

    vec2 shifted = uv + vec2(jitter + fine_noise + tear, 0.0);
    shifted = clamp(shifted, vec2(0.0), vec2(1.0));

    float chroma = 0.0055 * chroma_burst;
    vec3 color;
    color.r = texture(iChannel0, clamp(shifted + vec2(chroma, 0.0), vec2(0.0), vec2(1.0))).r;
    color.g = texture(iChannel0, shifted).g;
    color.b = texture(iChannel0, clamp(shifted - vec2(chroma, 0.0), vec2(0.0), vec2(1.0))).b;

    float static_noise = (hash2(fragCoord.xy + vec2(iTime * 120.0, cycle)) - 0.5) * 0.15 * static_burst;
    color += static_noise;

    fragColor = vec4(color, 1.0);
}
