shader_type canvas_item;
render_mode unshaded, blend_disabled;
#include "res://shaders/native_scale.gdshaderinc"
uniform sampler2D back : hint_screen_texture, repeat_disable, filter_nearest;
varying vec4 wave_color;
varying vec2 wave_size;
void vertex() {
    wave_color = COLOR;
    wave_size = vec2(length(MODEL_MATRIX[0].xy), length(MODEL_MATRIX[1].xy));
}
void fragment() {
    vec2 source_size = vec2(textureSize(TEXTURE, 0));
    // 51c2f0 / 4b49b0: Bresenham avanza el resto ANTES de muestrear.
    // MODEL_MATRIX sigue NativeBlend y excluye el escalado del viewport.
    ivec2 target_size = max(ivec2(1), ivec2(floor(wave_size * source_size + vec2(0.001))));
    ivec2 pixel = ivec2(floor(UV * vec2(target_size) + vec2(0.001)));
    vec2 at = vec2(native_scaled_texel(pixel, ivec2(source_size), target_size));
    vec4 source = texture(TEXTURE, (at + vec2(0.5)) / source_size);
    ivec3 src = ivec3(floor(source.rgb * 255.0 + vec3(0.5)));
    ivec3 dst = ivec3(floor(texture(back, SCREEN_UV).rgb * 255.0 + vec3(0.5)));
    int alpha = int(floor(source.a * 255.0 + 0.5)) * int(floor(wave_color.a * 255.0 + 0.5)) / 255;
    // Tablas51bbb0 / 4b43f0: división signed de cada canal truncada hacia cero.
    ivec3 result = dst + (src - dst) * alpha / 255;
    COLOR = vec4(vec3(result) / 255.0, 1.0);
}
