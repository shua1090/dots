// Retro CRT color pass without screen curvature or side squeeze.

const float SCANLINE_STRENGTH = 0.56;
const float VIGNETTE_STRENGTH = 0.34;
const vec3 PHOSPHOR = vec3(0.08, 1.18, 0.42);

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 centered = uv - 0.5;

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
