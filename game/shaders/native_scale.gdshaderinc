// 51c2f0: error=-destino-1; el resto avanza ANTES de muestrear.
ivec2 native_scaled_texel(ivec2 pixel, ivec2 source_size, ivec2 target_size) {
	ivec2 quotient = source_size / target_size;
	ivec2 remainder = source_size % target_size;
	return pixel * quotient + max(ivec2(0), ((pixel + ivec2(1)) * remainder - ivec2(1)) / target_size);
}
