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
var variant := "yugi"
var surface_tick := 0
var meter_state := 1 # 450330 incrementa el contador bajo antes de dibujar el primer tick.
const METER_PATTERNS := [
	[6,7,6,6,7,8,9,8,7,6,7,8,7,6,7,6],
	[6,7,9,13,14,15,14,13,12,11,10,9,8,6,7,6],
	[6,7,8,7,7,8,9,10,11,10,9,8,7,6,7,6],
]
const METER_TIPS := [
	[6,7,7,7,7,8,9,9,8,8,7,7,6,6,6,6],
	[6,7,9,13,14,15,15,14,14,12,12,19,10,7,7,6],
	[6,7,8,8,7,8,9,10,11,11,10,10,9,9,8,8],
]

func _advance_meter() -> void:
	var phase := (meter_state & 255) + 1
	var step := (meter_state >> 8) & 255
	var patterns := meter_state & 0x3ff0000
	if phase == 3:
		phase = 0
		step += 1
		if step == 16:
			step = 0
			patterns = 0
			for i in 5: patterns |= (UiRandom.draw() % 3) << (16 + i*2)
	meter_state = patterns | (step << 8) | phase

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
	for _i in steps:
		blend.tick()
		surface_tick += 1
		if variant == "kaiba": _advance_meter()
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
		var phase := mini(int(counter * 128 / 10), 128) - 128
		var shift := (DuelVisualMath.cos_fx(phase) * width) >> 16
		result.append({"slot": 0, "index": old_index, "position": Vector2(800 - width + shift, 295), "alpha": 255})
	if balance != 0:
		var phase := mini(int(maxi(counter - 15, 0) * 128 / 10), 128) - 128
		var shift := (DuelVisualMath.cos_fx(phase) * width) >> 16
		result.append({"slot": 1, "index": new_index, "position": Vector2(800 - shift, 295), "alpha": 255})
	return result


## 450270/450330 y476e40/476e80: composición interna además de la transición.
func composition(game: String, width: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for layer: Dictionary in layers(game, width):
		var group := "old" if int(layer.slot) == 0 else "new"
		result.append({"kind": "texture", "index": layer.index, "position": layer.position,
			"alpha": layer.alpha, "group": group, "key": group})
		if game == "kaiba":
			var amount := previous_balance if group == "old" else balance
			if amount != 0 and int(layer.index) != 3:
				result.append({"kind": "number", "value": absi(amount), "pitch": 24,
					"position": layer.position + Vector2(68, 125 if int(layer.index) == 2 else 32),
					"alpha": layer.alpha, "group": group, "key": group + "-number"})
	if game == "kaiba":
		if balance == 0 and counter > 16:
			for index in [8, 10, 11]:
				var phase := surface_tick % 78
				if index == 10: phase = (surface_tick * 3 / 2) % 78
				elif index == 11: phase = (surface_tick / 2) % 78
				var height: int = {8: 31, 10: 23, 11: 22}[index]
				result.append({"kind": "texture", "index": index, "alpha": 255,
					"position": Vector2(814-width, 418 if index == 8 else 428),
					"rect": [78-phase, 0, 156-phase, height], "key": "wave%d" % index})
		var step := (meter_state >> 8) & 255
		for row in 5:
			var pattern := (meter_state >> (16 + row*2)) & 3
			var length: int = METER_PATTERNS[pattern][step] * 6
			var tip: int = METER_TIPS[pattern][step] * 6
			result.append({"kind": "texture", "index": 12, "alpha": 255,
				"position": Vector2(698, 25+row*7), "rect": [0, 0, length, 3], "key": "meter%d" % row})
			result.append({"kind": "texture", "index": 12, "alpha": 255,
				"position": Vector2(698+tip-4, 25+row*7), "rect": [tip-4, 0, tip, 3], "key": "meter-tip%d" % row})
	else:
		for index in [9, 10, 11, 8]:
			var at: Vector2 = {9: Vector2(746,313), 10: Vector2(688,318), 11: Vector2(688,480), 8: Vector2(743,318)}[index]
			result.append({"kind": "texture", "index": index, "position": at, "alpha": 255, "rect": [], "key": "joey%d" % index})
		if balance != 0:
			result.append({"kind": "number", "value": absi(balance), "pitch": 26,
				"position": Vector2(757,339), "alpha": 255, "key": "joey-number"})
	return result
