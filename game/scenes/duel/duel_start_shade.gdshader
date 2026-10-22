shader_type canvas_item;
render_mode unshaded;
uniform int progress = 0;
void fragment() {
	int y = int(floor(UV.y * 600.0));
	int extent = (300 * progress) / 256;
	int weight = clamp(min(y - (300 - extent - 32), 300 + extent + 32 - y) * 8, 0, 256);
	if (progress >= 256) weight = 256;
	if (progress < 0) weight = 0;
	COLOR = vec4(0.0, 0.0, 0.0, 0.5 * float(weight) / 256.0);
}
