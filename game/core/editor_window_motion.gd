extends RefCounted
## Y44a810 / Ka44bd70 / Jo461c40: escalado y alfa de la ventana del editor.
static func frame(size: Vector2i, phase: int, counter: int) -> Dictionary:
	var cosine := DuelVisualMath.cos_fx(mini(counter, 128) - 128 if phase == 1 else mini(counter, 128) if phase == 3 else -mini(counter, 128))
	var fade := 65536 - cosine
	var sx := int(fade * size.x * 2 / 10)
	var sy := int(fade * size.y * 2 / 10)
	if phase == 3:
		return {"size": Vector2(size.x - (sx >> 16), size.y - (sy >> 16)), "offset": Vector2(sx >> 17, sy >> 17), "alpha": ((256 - fade) >> 8) & 255}
	return {"size": Vector2(size.x + (sx >> 16), size.y + (sy >> 16)), "offset": Vector2(-(sx >> 17), -(sy >> 17)), "alpha": mini(255, cosine >> 8)}
