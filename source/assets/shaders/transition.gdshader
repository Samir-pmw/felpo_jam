shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float noise_scale = 8.0;
uniform float edge_size = 0.1;
uniform vec4 burn_color : source_color = vec4(0.1, 0.05, 0.0, 1.0);

float hash(vec2 p){
    return fract(sin(dot(p ,vec2(127.1,311.7))) * 43758.5453);
}

float noise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0,0.0));
    float c = hash(i + vec2(0.0,1.0));
    float d = hash(i + vec2(1.0,1.0));
    
    vec2 u = f*f*(3.0-2.0*f);
    
    return mix(a, b, u.x) +
           (c - a)* u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

void fragment() {
    vec4 base_tex = texture(TEXTURE, UV);
    
    float n = noise(UV * noise_scale);
    
    float mask = smoothstep(progress - edge_size, progress, n);
    
    // Parte que ainda está visível
    ALBEDO = mix(base_tex.rgb, burn_color.rgb, mask);
    ALPHA = base_tex.a * (1.0 - mask);
}