shader_type canvas_item;
render_mode unshaded;
uniform sampler2D background_image : filter_nearest;
uniform ivec2 origin = ivec2(0);
uniform int alpha8 = 0;
void fragment() {
    ivec2 at = ivec2(floor(UV * vec2(textureSize(TEXTURE, 0))));
    ivec3 source = ivec3(floor(texture(TEXTURE, (vec2(at) + 0.5) / vec2(textureSize(TEXTURE, 0))).rgb * 255.0 + 0.01));
    ivec3 dest = ivec3(floor(texture(background_image, (vec2(at + origin) + 0.5) / vec2(800, 600)).rgb * 255.0 + 0.01));
    // Yugi 0x4a2280 / 0x4a2860: signed difference table, truncation toward zero.
    ivec3 value = dest + (source - dest) * alpha8 / 255;
    COLOR = vec4(vec3(value) / 255.0, 1.0);
}
