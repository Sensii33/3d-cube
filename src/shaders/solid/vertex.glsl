#define PI 3.1415926535897932384626433832795

uniform float uTime;   // normalized progress time 
uniform float uWidth;  // size of geometry
uniform float uStep;   // number of splits

varying float vMode;   // current mode
varying vec2 vUv;      // UV coordinate


void main()
{
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);

    // order: 0, 1, ..., uStep-1 (a cycle)
    float order = floor(mod(uTime, uStep));
    // mode: 1, 2, 4, ..., 2^(uStep-1) (cell number: mode ^ 3)
    float mode = pow(2.0, order);
    // roundness: 0 (cube) ~ 1 (cell)
    float roundness = (1.0 - cos(2.0 * PI * uTime)) / 2.0;

    vec3 cube = modelPosition.xyz;
    vec3 sphere = normalize(cube) * uWidth / sqrt(2.0);

    vec3 phase = PI * mode * cube / uWidth;
    // surface ups and downs 
    vec3 delta = abs(sin(phase));
    // how mush rising of each cell
    float amp = (0.05 / pow(mode,0.6) );
    // keep the sphere shape when mode = 1 (amp = 0)
    amp *= step(1.01, mode);

    sphere *= 1.0 + amp * (delta.x + delta.y + delta.z);

    // transition between cube and sphere (cells)
    modelPosition.xyz = mix(cube, sphere, roundness);
    
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;

    gl_Position = projectedPosition;

    vMode = mode;
    vUv = uv; 
}