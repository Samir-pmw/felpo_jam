shader_type spatial;
render_mode unshaded, cull_disabled, world_vertex_coords;

uniform vec4  color_a    : source_color = vec4(0.17, 0.17, 0.19, 1.0);
uniform vec4  color_b    : source_color = vec4(0.22, 0.22, 0.25, 1.0);
uniform float tile_size  : hint_range(0.1, 10.0) = 1.5;

void fragment() {
	vec2  coord   = floor(VERTEX.xz / tile_size);
	float checker = mod(coord.x + coord.y, 2.0);
	ALBEDO = mix(color_a.rgb, color_b.rgb, checker);
}