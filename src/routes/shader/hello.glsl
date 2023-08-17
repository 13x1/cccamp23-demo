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

void main()
{
    gl_FragColor = vec4(u_time,u_resolution,1.0);
    vec2 uv = (((gl_PointCoord.xy)-.5*u_resolution.xy)/u_resolution.x) * -1. * .5;

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
    gl_FragColor = vec4(color,1.0);
}

//precision mediump float;
//void main() {
//    vec2 fragmentPosition = 2.0*gl_PointCoord - 1.0;
//    float distance = length(fragmentPosition);
//    float distanceSqrd = distance * distance;
//    gl_FragColor = vec4(
//    0.2/distanceSqrd,
//    0.1/distanceSqrd,
//    0.0, 1.0);
//}
