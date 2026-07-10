// Retro CRT pass inspired by hackr-sh/ghostty-shaders/retro-terminal.glsl.
// The source shader notes its original Shadertoy license as CC BY-NC-SA 3.0.

const float WARP = 0.26;
const float SCANLINE_STRENGTH = 0.56;
const float VIGNETTE_STRENGTH = 0.58;
const vec3 PHOSPHOR = vec3(0.08, 1.18, 0.42);

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 centered = uv - 0.5;
    vec2 curve = centered * centered;

    uv.x = centered.x * (1.0 + curve.y * WARP) + 0.5;
    uv.y = centered.y * (1.0 + curve.x * WARP) + 0.5;

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 color = texture(iChannel0, uv).rgb;
    float scanline = 1.0 - SCANLINE_STRENGTH * pow(abs(sin(fragCoord.y * 1.35)), 1.7);
    float grille = 0.86 + 0.14 * sin(fragCoord.x * 2.094);
    float vignette = 1.0 - VIGNETTE_STRENGTH * dot(centered, centered);
    float brightness = max(max(color.r, color.g), color.b);

    color = mix(color * PHOSPHOR, PHOSPHOR * brightness, 0.48);
    color *= scanline * grille * vignette;
    color += color * color * 0.32;

    fragColor = vec4(color, 1.0);
}
