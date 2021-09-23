#define PROCESSING_COLOR_SHADER

#ifdef GL_ES
precision highp float;
#endif

uniform vec2 origin;
uniform vec2 dir;
uniform vec2 normal;
uniform float radius;
uniform vec4 color;

void main(void) {
    vec2 relCoord = gl_FragCoord.xy - origin;

    float delta = dot(relCoord, normal);
    vec2 plumbPoint = origin + (delta * dir);

    float dist = distance(relCoord, plumbPoint) / 1000;
    float alpha = max(0.0, min(1.0, 1.0 - (dist / radius)));
    gl_FragColor = color;
    gl_FragColor.w *= alpha * alpha;
}
