extends RefCounted
## Ka450150/4501e0/450330; Jo476d20/476db0/476e80 (ASM).
## Las superficies se regeneran al cruzar cero; otro movimiento del mismo
## signo conserva el contador. El contador pertenece al objeto, no al render.
var balance := 0
var previous_balance := 0
var old_index := 3
var new_index := 3
var counter := 256
var _fraction := 0.0
## Cada transicion nueva cambia las claves de la mezcla: arranca sin deslizar desde la anterior.
var generation := 0
var blend := NativeBlend.new()

func set_balance(value: int) -> void:
	if value == balance: return
	if (balance <= 0 and value >= 0 and value > balance) \
			or (balance >= 0 and value <= 0 and value < balance):
		old_index = 2 if balance > 0 else 4 if balance < 0 else 3
		new_index = 2 if value > 0 else 4 if value < 0 else 3
		counter = 0
		_fraction = 0.0
		generation += 1
	previous_balance = balance
	balance = value

func advance(delta: float) -> void:
	_fraction += NativeClock.ticks(delta)
	var steps := int(_fraction)
	_fraction -= steps
	counter = mini(256, counter + steps)
	for _i in steps: blend.tick()
	blend.fraction = _fraction

func layers(game: String, width: int) -> Array[Dictionary]:
	if game == "yugi":
		var phase_a := mini(int(maxi(counter, 0) * 128 / 20), 128) - 128
		var phase_b := mini(int(maxi(counter - 13, 0) * 128 / 10), 128) - 128
		var incoming := (DuelVisualMath.cos_fx(phase_b) * width) >> 16
		var result: Array[Dictionary] = [{"slot": 0, "index": old_index + 3, "position": Vector2(800 - width, 280), "alpha": 255, "kind": "keyed"}]
		if old_index != 3:
			result.append({"slot": 2, "index": 13, "position": Vector2(800 - width + 55, 280 + (45 if previous_balance > 0 else 147)), "alpha": 255, "kind": "number", "value": absi(previous_balance)})
		result.append({"slot": 3, "index": -1, "position": Vector2(800 - width, 280), "alpha": (DuelVisualMath.cos_fx(phase_a) * 80) >> 16, "kind": "alpha"})
		result.append({"slot": 1, "index": new_index, "position": Vector2(800 - incoming, 280), "alpha": 255, "kind": "opaque"})
		if balance != 0:
			result.append({"slot": 4, "index": 12, "position": Vector2(800 - incoming + 53, 280 + (40 if balance > 0 else 151)), "alpha": 255, "kind": "number", "value": absi(balance)})
		return result
	if game == "kaiba":
		var alpha := int(clampi(counter, 0, 16) * 255 / 16)
		return [{"slot": 0, "index": old_index, "position": Vector2(798 - width, 298), "alpha": 255 - alpha},
			{"slot": 1, "index": new_index, "position": Vector2(798 - width, 298), "alpha": alpha}]
	var result: Array[Dictionary] = []
	if previous_balance != 0:
		var phase := mini(int(counter * 128 / 20), 128) - 128
		var shift := (DuelVisualMath.cos_fx(phase) * width) >> 16
		result.append({"slot": 0, "index": old_index, "position": Vector2(800 - width + shift, 295), "alpha": 255})
	if balance != 0:
		var phase := mini(int(maxi(counter - 15, 0) * 128 / 20), 128) - 128
		var shift := (DuelVisualMath.cos_fx(phase) * width) >> 16
		result.append({"slot": 1, "index": new_index, "position": Vector2(800 - shift, 295), "alpha": 255})
	return result
