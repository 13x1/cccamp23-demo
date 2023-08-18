#version 100 
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;

float map(vec3 pos) {
    vec3 tmp = vec3(1.0) - abs(pos);
    return min(tmp.x, tmp.y);
}

vec3 color(vec3 pos) {
    vec3 blue = vec3(0.5, 0.5, 1.0);
    vec3 red  = vec3(1.0, 0.5, 0.5);
    return mix(blue, red, step(0.5, fract(pos.z)));
}

vec3 march(vec2 uv, vec3 cam_pos) {
    vec3 pos = cam_pos;
    vec3 dir = normalize(vec3(uv, 1));
    float d;
    for (int i=0; i<100; i++){
        d = map(pos);
        if (d < 0.1) {
            return color(pos)*exp(-(pos.z-cam_pos.z)*.006);
        }
        pos += d*dir;
    }
    return vec3(0.0);
}

void main()
{
    vec2 uv = (-u_resolution.xy + 2.*gl_FragCoord.xy)/u_resolution.xy;
    vec3 cam_pos = vec3(.001, .001, u_time*1.5);
    gl_FragColor = vec4(march(uv, cam_pos), 1.0);
}
