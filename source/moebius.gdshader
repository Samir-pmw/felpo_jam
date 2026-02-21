shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled, depth_draw_never;

uniform sampler2D depth_texture  : hint_depth_texture,           filter_nearest;
uniform sampler2D normal_texture : hint_normal_roughness_texture, filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture,          filter_linear;

// --- Outline ---
uniform vec4  outline_color    : source_color = vec4(0.08, 0.05, 0.03, 1.0);
uniform float outline_width    : hint_range(0.5, 5.0)  = 1.5;
uniform float depth_threshold  : hint_range(0.0, 0.05) = 0.005;
uniform float normal_threshold : hint_range(0.0, 1.0)  = 0.3;

// --- Hatching ---
uniform float hatch_scale    : hint_range(1.0, 20.0) = 7.0;
uniform float hatch_strength : hint_range(0.0, 1.0)  = 0.55;
uniform vec4  hatch_color    : source_color = vec4(0.05, 0.03, 0.02, 1.0);

void fragment() {
	vec2 uv    = SCREEN_UV;
	vec2 texel = outline_width / vec2(textureSize(screen_texture, 0));
	vec4 base  = texture(screen_texture, uv);

	// --- Edge detection (Roberts cross on depth + normals) ---
	float d0 = texture(depth_texture, uv + vec2( texel.x,  texel.y)).r;
	float d1 = texture(depth_texture, uv + vec2(-texel.x, -texel.y)).r;
	float d2 = texture(depth_texture, uv + vec2(-texel.x,  texel.y)).r;
	float d3 = texture(depth_texture, uv + vec2( texel.x, -texel.y)).r;
	float depth_edge = sqrt(pow(d0 - d1, 2.0) + pow(d2 - d3, 2.0));

	vec3 n0 = texture(normal_texture, uv + vec2( texel.x,  texel.y)).rgb;
	vec3 n1 = texture(normal_texture, uv + vec2(-texel.x, -texel.y)).rgb;
	vec3 n2 = texture(normal_texture, uv + vec2(-texel.x,  texel.y)).rgb;
	vec3 n3 = texture(normal_texture, uv + vec2( texel.x, -texel.y)).rgb;
	float normal_edge = length(n0 - n1) + length(n2 - n3);

	float edge = clamp(
		step(depth_threshold,  depth_edge) +
		step(normal_threshold, normal_edge),
		0.0, 1.0
	);

	// --- Cross-hatching based on luminance ---
	float luma = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	vec2  px   = uv * vec2(textureSize(screen_texture, 0));

	float hatch = 0.0;
	if (luma < 0.90) { hatch += step(0.85, mod((px.x + px.y) / hatch_scale, 1.0)); }
	if (luma < 0.70) { hatch += step(0.85, mod((px.x - px.y) / hatch_scale, 1.0)); }
	if (luma < 0.50) { hatch += step(0.85, mod( px.y          / hatch_scale, 1.0)); }
	if (luma < 0.30) { hatch += step(0.85, mod( px.x          / hatch_scale, 1.0)); }
	hatch = clamp(hatch * hatch_strength, 0.0, 1.0);

	// --- Combine: hatching first, then outline on top ---
	vec3 result = mix(base.rgb, hatch_color.rgb, hatch);
	result      = mix(result,   outline_color.rgb, edge);

	ALBEDO = result;
	ALPHA  = 1.0;
}