shader_type canvas_item;
#include "res://shaders/native_scale.gdshaderinc"
uniform sampler2D native_rows : filter_nearest, repeat_disable;
varying vec4 draw_color;
varying flat float native_row;
varying vec2 draw_uv;
void vertex() {
	draw_color = COLOR;
	native_row = -1.0;
	draw_uv = UV;
	if (UV.x < 0.0) {
		native_row = round(-UV.x - 1.0);
		// La fracción se decodifica en vértices: evita perderla al interpolar filas altas.
		draw_uv = vec2(UV.y, (-UV.x - 1.0 - native_row) * 4.0);
	}
}
void fragment() {
	vec2 sample_uv = UV;
	if (native_row >= 0.0) {
		int row = int(native_row);
		vec4 a = texelFetch(native_rows, ivec2(0, row), 0);
		vec4 b = texelFetch(native_rows, ivec2(1, row), 0);
		ivec2 source;
		if (a.x == -65536.0) {
			ivec2 target_size = ivec2(a.yz);
			ivec2 pixel = ivec2(floor(draw_uv * vec2(target_size) + vec2(0.001)));
			source = native_scaled_texel(pixel, ivec2(b.zw), target_size);
		} else {
			int du = int(a.z) * 65536 + int(a.w);
			int dv = int(b.x) * 65536 + int(b.y);
			int offset = int(floor(draw_uv.x));
			source = ivec2(int(a.x) + ((offset * du) >> 20), int(a.y) + ((offset * dv) >> 20));
		}
		sample_uv = (vec2(source) + vec2(0.5)) / b.zw;
	}
	COLOR = texture(TEXTURE, sample_uv) * draw_color;
}
