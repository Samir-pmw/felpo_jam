// Based on https://godotshaders.com/shader/3d-outline/
shader_type spatial;
render_mode cull_front, unshaded, shadows_disabled, depth_draw_never;

uniform vec4  albedo      : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 3.0;
uniform bool  use_scale    = false;

void vertex() {
	vec3 normal = normalize(NORMAL);
	vec4 clip_pos = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * normal);

	vec2 offset = vec2(0.0);
	if (use_scale) {
		offset = normalize(clip_normal.xy) * (outline_width / 1000.0) * clip_pos.w;
	} else {
		// Screen-space pixel offset — stays consistent regardless of distance
		offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * outline_width * 2.0 * clip_pos.w;
	}
	clip_pos.xy += offset;
	POSITION = clip_pos;
}

void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA  = albedo.a;
}