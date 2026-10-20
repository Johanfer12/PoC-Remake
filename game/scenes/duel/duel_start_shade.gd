extends RefCounted
## Jo4246f0: copia central del destino y dos bordes de32filas (+8 por fila).
const SHADER := preload("res://scenes/duel/duel_start_shade.gdshader")
static func weight(y: int, progress: int, height := 600) -> int:
	if progress >= 256: return 256
	if progress < 0: return 0
	var half := height / 2
	var extent := half * progress / 256
	return clampi(mini(y - (half - extent - 32), half + extent + 32 - y) * 8, 0, 256)
