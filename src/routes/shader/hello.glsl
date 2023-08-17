#version 100
precision highp float;
uniform vec2 u_resolution; // Width & height of the shader
uniform float u_time; // Time elapsed
uniform float time;

// Constants
#define PI 3.1415925359
#define TWO_PI 6.2831852
#define MAX_STEPS 500 // Mar Raymarching steps
#define MAX_DIST 100. // Max Raymarching distance
#define SURF_DIST .01 // Surface Distance

float calc_dist(vec3 p)
{
  vec4 s = vec4(0,1,6,1); //Sphere xyz is position w is radius
  float sphereDist = length(p-s.xyz) - s.w;
  float planeDist  = p.y;
  float d = min(sphereDist,planeDist);
  return d;
}

float rm(vec3 ro, vec3 rd)
{
  float dO = 0.; //Distane Origin
  for(int i=0;i<MAX_STEPS;i++)
  {
    vec3 p = ro + rd * dO;
    float ds = calc_dist(p); // ds is Distance Scene
    dO += ds;
    if(dO > MAX_DIST || ds < SURF_DIST)
      break;
  }
  return dO;
}

vec3 normal(vec3 p)
{
    float d = calc_dist(p); // Distance
    vec2 e = vec2(.01,0); // Epsilon
    vec3 n = d - vec3(
    calc_dist(p-e.xyy),
    calc_dist(p-e.yxy),
    calc_dist(p-e.yyx));

    return normalize(n);
}
float light(vec3 p)
{
    // Directional light
    vec3 lightPos = vec3(5.*sin(u_time),5.,5.0*cos(u_time)); // Light Position
    vec3 l = normalize(lightPos-p); // Light Vector
    vec3 n = normal(p); // Normal Vector

    float dif = dot(n,l); // Diffuse light
    dif = clamp(dif,0.,1.); // Clamp so it doesnt go below 0

    // Shadows
    float d = rm(p+n*SURF_DIST*2., l);

    if(d<length(lightPos-p)) dif *= .1;

    return dif;
}

float dither8x8(vec2 position, float brightness) {
    int x = int(mod(position.x, 8.0));
    int y = int(mod(position.y, 8.0));
    int index = x + y * 8;
    float limit = 0.0;

    if (x < 8) {
        if (index == 0) limit = 0.015625;
        if (index == 1) limit = 0.515625;
        if (index == 2) limit = 0.140625;
        if (index == 3) limit = 0.640625;
        if (index == 4) limit = 0.046875;
        if (index == 5) limit = 0.546875;
        if (index == 6) limit = 0.171875;
        if (index == 7) limit = 0.671875;
        if (index == 8) limit = 0.765625;
        if (index == 9) limit = 0.265625;
        if (index == 10) limit = 0.890625;
        if (index == 11) limit = 0.390625;
        if (index == 12) limit = 0.796875;
        if (index == 13) limit = 0.296875;
        if (index == 14) limit = 0.921875;
        if (index == 15) limit = 0.421875;
        if (index == 16) limit = 0.203125;
        if (index == 17) limit = 0.703125;
        if (index == 18) limit = 0.078125;
        if (index == 19) limit = 0.578125;
        if (index == 20) limit = 0.234375;
        if (index == 21) limit = 0.734375;
        if (index == 22) limit = 0.109375;
        if (index == 23) limit = 0.609375;
        if (index == 24) limit = 0.953125;
        if (index == 25) limit = 0.453125;
        if (index == 26) limit = 0.828125;
        if (index == 27) limit = 0.328125;
        if (index == 28) limit = 0.984375;
        if (index == 29) limit = 0.484375;
        if (index == 30) limit = 0.859375;
        if (index == 31) limit = 0.359375;
        if (index == 32) limit = 0.0625;
        if (index == 33) limit = 0.5625;
        if (index == 34) limit = 0.1875;
        if (index == 35) limit = 0.6875;
        if (index == 36) limit = 0.03125;
        if (index == 37) limit = 0.53125;
        if (index == 38) limit = 0.15625;
        if (index == 39) limit = 0.65625;
        if (index == 40) limit = 0.8125;
        if (index == 41) limit = 0.3125;
        if (index == 42) limit = 0.9375;
        if (index == 43) limit = 0.4375;
        if (index == 44) limit = 0.78125;
        if (index == 45) limit = 0.28125;
        if (index == 46) limit = 0.90625;
        if (index == 47) limit = 0.40625;
        if (index == 48) limit = 0.25;
        if (index == 49) limit = 0.75;
        if (index == 50) limit = 0.125;
        if (index == 51) limit = 0.625;
        if (index == 52) limit = 0.21875;
        if (index == 53) limit = 0.71875;
        if (index == 54) limit = 0.09375;
        if (index == 55) limit = 0.59375;
        if (index == 56) limit = 1.0;
        if (index == 57) limit = 0.5;
        if (index == 58) limit = 0.875;
        if (index == 59) limit = 0.375;
        if (index == 60) limit = 0.96875;
        if (index == 61) limit = 0.46875;
        if (index == 62) limit = 0.84375;
        if (index == 63) limit = 0.34375;
    }

    return brightness < limit ? 0.0 : 1.0;
}

void main()
{
    gl_FragColor = vec4(u_time,u_resolution,1.0);
    vec2 uv = (((gl_FragCoord.xy)-.5*u_resolution.xy)/u_resolution.x) 1. * .5;

    vec3 ro = vec3(0,1,0); // Ray Origin/Camera
    vec3 rd = normalize(vec3(uv.x,uv.y,1)); // Ray Direction

    float d = rm(ro,rd); // Distance

    vec3 p = ro + rd * d;
    float dif = light(p); // Diffuse lighting
    d*= .2;
    vec3 color = vec3(dif);
    //color += normal(p);
    //float color = light(p);

    // Set the output color
    gl_FragColor = vec4(.0, .0, dither8x8(glFragCoord.xy, color.r), 1.0);
}

//precision mediump float;
//void main() {
//    vec2 fragmentPosition = 2.0*gl_FragCoord - 1.0;
//    float distance = length(fragmentPosition);
//    float distanceSqrd = distance * distance;
//    gl_FragColor = vec4(
//    0.2/distanceSqrd,
//    0.1/distanceSqrd,
//    0.0, 1.0);
//}
