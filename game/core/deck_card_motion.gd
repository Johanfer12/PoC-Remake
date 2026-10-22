class_name DeckCardMotion
extends RefCounted
## Y447420/4474a0, Ka448470/4484f0, Jo46ae80: estados1/2 de carta del editor.

static func gather(from: Vector2, to: Vector2) -> Dictionary:
	# 447420: dos llamadas MT, primero signo y despues magnitud de giro.
	var sign := 1 if UiRandom.draw() & 1 else -1
	var rotation := sign * (UiRandom.draw() & 127)
	return {"mode": 2, "from": from, "to": to, "v": 0, "radius": int(from.distance_to(to)),
		"angle": atan2(to.y - from.y, to.x - from.x), "rotation": rotation,
		"draw_rotation": 0, "scale": 65536, "center": from, "done": false}

static func settle(from: Vector2, to: Vector2) -> Dictionary:
	var out := {"mode": 1, "from": from, "to": to, "v": 0, "center": from, "done": false}
	overshoot(out)
	return out

static func overshoot(a: Dictionary) -> void:
	var p: Vector2 = a.center
	var d: Vector2 = a.to - p
	a.from = p
	a.beyond = p + Vector2(int(d.x) * 12 / 10, int(d.y) * 12 / 10)
	a.v = 0

static func tick(a: Dictionary) -> void:
	if a.done:
		return
	if a.mode == 1:
		a.v += 32
		if a.v == 256:
			var d: Vector2 = a.to - a.center
			if abs(d.x) < 4 and abs(d.y) < 4:
				a.center = a.to
				a.done = true
				return
			overshoot(a)
		a.center = DuelVisualMath.interpolate_fx(a.from, a.beyond,
			DuelVisualMath.cos_fx(int(a.v) / 2 - 128))
		return
	a.v += 8
	if a.v == 256:
		a.center = a.to
		a.draw_rotation = a.rotation
		a.done = true
		return
	# ASM4474fe: atan/pi*256 + v*2; radio se multiplica por T[v/2] cada tick.
	a.radius = (int(a.radius) * DuelVisualMath.cos_fx(int(a.v) / 2)) >> 16
	var angle := int(float(a.angle) / PI * 256.0 + int(a.v) * 2)
	a.center = a.to - Vector2((DuelVisualMath.cos_fx(angle) * int(a.radius)) >> 16,
		(DuelVisualMath.sin_fx(angle) * int(a.radius)) >> 16)
	var weight := DuelVisualMath.cos_fx(int(a.v) / 2 - 128)
	a.draw_rotation = (int(a.rotation) * (65536 - weight)) >> 16
	var scale_delta := 2048 - 65536
	a.scale = (((scale_delta >> 8) * weight) >> 8) + 65536
