extends RefCounted
## Jo4246f0: copia central del destino y dos bordes de32filas (+8 por fila).
const SHADER := preload("res://scenes/duel/duel_start_shade.gdshader")
static func weight(y: int, progress: int, height := 600) -> int:
	if progress >= 256: return 256
	if progress < 0: return 0
	var half := height / 2
	var extent := half * progress / 256
	return clampi(mini(y - (half - extent - 32), half + extent + 31 - y) * 8, 0, 256)

## 48639d -> 4f64e0(128): LUT546d70, intensidad8/15 por canal RGB565.
static func darken_word(word: int) -> int:
	return (((word >> 11) * 8 / 15) << 11) | (((((word >> 5) & 63) * 8) / 15) << 5) | ((word & 31) * 8 / 15)

static func blend_word(word: int, intensity: int) -> int:
	var level := mini(15, intensity >> 4)
	var dark := darken_word(word)
	var result := 0
	for part in [[11, 31], [5, 63], [0, 31]]:
		var source: int = (dark >> part[0]) & part[1]
		var target: int = (word >> part[0]) & part[1]
		result |= (source * level / 15 + target * (15 - level) / 15) << part[0]
	return result
