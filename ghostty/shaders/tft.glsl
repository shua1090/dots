// Subtle pixel grille pass for Ghostty custom shaders.

const float CELL_SIZE = 4.0;
const float GRILLE_STRENGTH = 0.18;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture(iChannel0, uv).rgb;

    vec2 cell = mod(fragCoord.xy, vec2(CELL_SIZE)) / CELL_SIZE;
    float vertical = smoothstep(0.18, 0.28, cell.x) * (1.0 - smoothstep(0.72, 0.82, cell.x));
    float horizontal = smoothstep(0.12, 0.22, cell.y);
    float mask = mix(1.0 - GRILLE_STRENGTH, 1.0, vertical * horizontal);

    fragColor = vec4(color * mask, 1.0);
}
