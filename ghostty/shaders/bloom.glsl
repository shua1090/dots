// Lightweight glow pass for Ghostty custom shaders.

const float BLOOM_RADIUS = 1.6;
const float BLOOM_STRENGTH = 0.22;
const float BLOOM_THRESHOLD = 0.28;

float luma(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 px = BLOOM_RADIUS / iResolution.xy;
    vec3 color = texture(iChannel0, uv).rgb;

    vec3 glow = vec3(0.0);
    glow += texture(iChannel0, uv + vec2( px.x,  0.0)).rgb;
    glow += texture(iChannel0, uv + vec2(-px.x,  0.0)).rgb;
    glow += texture(iChannel0, uv + vec2( 0.0,   px.y)).rgb;
    glow += texture(iChannel0, uv + vec2( 0.0,  -px.y)).rgb;
    glow += texture(iChannel0, uv + vec2( px.x,  px.y)).rgb * 0.5;
    glow += texture(iChannel0, uv + vec2(-px.x,  px.y)).rgb * 0.5;
    glow += texture(iChannel0, uv + vec2( px.x, -px.y)).rgb * 0.5;
    glow += texture(iChannel0, uv + vec2(-px.x, -px.y)).rgb * 0.5;
    glow /= 6.0;

    float amount = smoothstep(BLOOM_THRESHOLD, 1.0, luma(glow));
    fragColor = vec4(color + glow * amount * BLOOM_STRENGTH, 1.0);
}
