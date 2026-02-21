shader_type canvas_item;

// The SubViewport texture is passed in from the TextureRect
uniform sampler2D viewport_texture : filter_linear;
uniform vec4  outline_color   : source_color = vec4(0.1, 0.07, 0.05, 1.0);
uniform float outline_width   : hint_range(0.5, 6.0) = 1.5;
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec2 uv    = UV;
	vec2 texel = outline_width / vec2(textureSize(viewport_texture, 0));

	float a  = texture(viewport_texture, uv).a;
	float aN = texture(viewport_texture, uv + vec2( 0.0,  texel.y)).a;
	float aS = texture(viewport_texture, uv + vec2( 0.0, -texel.y)).a;
	float aE = texture(viewport_texture, uv + vec2( texel.x,  0.0)).a;
	float aW = texture(viewport_texture, uv + vec2(-texel.x,  0.0)).a;

	float neighbour_max = max(max(aN, aS), max(aE, aW));
	float is_outline    = step(alpha_threshold, neighbour_max - a);

	vec4 base = texture(viewport_texture, uv);
	COLOR = mix(base, outline_color, is_outline * outline_color.a);
}