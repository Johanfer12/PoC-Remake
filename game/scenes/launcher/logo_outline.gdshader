shader_type canvas_item;
uniform float emphasis = 0.0;
uniform float reveal = 0.0;
varying vec4 sprite_tint;
void vertex() {
	sprite_tint = COLOR;
}
void fragment() {
	vec4 tint = sprite_tint;
	vec4 logo = texture(TEXTURE, UV);
	float edge = 0.0;
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			edge = max(edge, texture(TEXTURE, UV + vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE).a);
		}
	}
	vec3 gold = vec3(1.0, 0.82, 0.3);
	vec3 rgb = mix(gold, logo.rgb * (1.0 - reveal * 0.42), logo.a);
	COLOR = vec4(rgb, max(logo.a, edge * (0.35 + emphasis * 0.65))) * tint;
}
