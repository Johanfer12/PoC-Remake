extends "res://scenes/duel/bust_up_scene.gd"
## Kaiba: 40efe0/40d950/40da70, vtable59dbfc. Joey:4152d0/415580/415840,
## vtable5da800. Salidas: Kaiba40f280/40e280/40e340(vtable59dc0c),
## Joey415c90/416050/416260(vtable5da820).

var _scene_textures: Array[Texture2D] = []


func _ready() -> void:
	super._ready()
	if _done:
		return
	# Cargar y decodificar antes de animar. El fondo compuesto y los cuadros de boca
	# aparecen despues: cargarlos desde _draw interrumpia el movimiento a 60 Hz.
	for i in _layout.items.size():
		_scene_textures.append(super._tex(i))


func _tex(i: int) -> Texture2D:
	return _scene_textures[i] if i < _scene_textures.size() else super._tex(i)


func _start_voice_path() -> String:
	return ("kaiba/voice/internal/ka%02d.wav" if game == "kaiba" else "joey/voice/internal/joey_%02d.wav") % (_random + 1)


func _end_voice_path(_base: int) -> String:
	# Kaiba ids55/58/59, Joey59/5c/5d: voces53/56/57, mas variante.
	var n: int = {2: 53, 3: 56}.get(winner, 57) + _random
	return ("kaiba/voice/internal/ka%02d.wav" if game == "kaiba" else "joey/voice/internal/joey_%02d.wav") % n


func _update_start() -> void:
	if _counter == 0:
		_screen2 = "bg"
	if _counter == 128:
		_screen2 = "back"
		_play_voice()
	if _counter > 384 and _counter < 65536 and _voice_over():
		_counter = 65536
		return
	_counter += 4


func _body_origin() -> Vector2:
	var origin := _pos(2)
	if game == "kaiba":
		origin.x += maxi(0, (96 - _counter) * 16)
	else:
		var body := _tex(2)
		var width := body.get_width() if body != null else 0
		# El original solo limita por arriba: antes de64 queda fuera de pantalla.
		origin.x += ((mini(_counter - 64, 32) * width) >> 5) - width
	return origin


func _draw_start() -> void:
	_draw_tex(_tex(0), Vector2.ZERO)
	if _screen2 == "back":
		if game == "joey":
			_draw_tex(_tex(1), _pos(1))
		_draw_tex(_tex(2), _pos(2))
		_draw_tex(_tex(7 + _random), _pos(7 + _random) if game == "joey" else Vector2.ZERO)
	var origin: Vector2 = _blend.at("body", _body_origin())
	if _counter <= 128:
		_draw_tex(_tex(2), origin)
	if _counter >= 128:
		var blink := (_counter & 0xffff) == 128 if game == "kaiba" else _counter == 128
		var eyes := 3 if blink else 4
		if _raw(eyes) != 0:
			_draw_tex(_tex(eyes), origin + _pos(eyes))
	var mouth: int = MOUTH[(_counter >> 3) & 3]
	if mouth != 0 and _counter < 65536:
		_draw_tex(_tex(mouth), origin + _pos(mouth))
	if game == "kaiba":
		_draw_ready_font()


func _draw_ready_font() -> void:
	# 40dbb6..40dcd1: cuatro glifos progresivos y quinto glifo intermitente.
	var tex := _tex(10)
	if tex == null:
		return
	var step := clampi((_counter - 65536) >> 4, 0, 4)
	var width := int(tex.get_width() / 5)
	var pos := _pos(10)
	if step != 0:
		var rect := Rect2(0, 0, width * step, tex.get_height())
		draw_texture_rect_region(tex, Rect2(pos, rect.size), rect)
	if (_counter & 32) != 0:
		var rect := Rect2(width * 4, 0, width, tex.get_height())
		draw_texture_rect_region(tex, Rect2(pos + Vector2(width * step, 0), rect.size), rect)


func _update_end() -> void:
	if _counter == 0:
		_screen2 = "bg"
	if _counter == 96:
		_screen2 = "all"
		_play_voice()
	if _counter > 480 and _counter < 65536 and _voice_over():
		_counter = 65536
	_counter += 4


func _end_origin() -> Vector2:
	var origin := _pos(3)
	var tex := _tex(3)
	var width := tex.get_width() if tex != null else 0
	var shift := ((mini(_counter - 64, 32) * width) >> 5) - width
	origin.x += shift if (_raw(0) / 1000 & 1) == 0 else -shift
	return origin


func _result_origin() -> Vector2:
	var tex := _tex(2)
	if tex == null:
		return Vector2.ZERO
	var width := tex.get_width()
	var height := tex.get_height()
	var corner := _raw(2)
	var origin := Vector2(800 - width if corner in [2, 4] else 0, 600 - height if corner in [3, 4] else 0)
	var weight := DuelVisualMath.cos_fx(mini(_counter - 96, 64) * 2 - 128)
	var shift := ((weight * width) >> 16) - width
	origin.x += shift if origin.x + width / 2 < 400 else -shift
	return origin


func _draw_end() -> void:
	if game == "kaiba" and _screen2 == "all":
		_draw_tex(_tex(8), Vector2.ZERO)
	else:
		_draw_tex(_tex(0), Vector2.ZERO)
	if game == "joey" and _screen2 == "all":
		_draw_tex(_tex(1), _pos(1))
		_draw_tex(_tex(8 + _random), _pos(8 + _random))
	if game == "kaiba" and _counter > 4:
		var noise := _tex(1)
		if noise != null:
			var fall: float = Game.native_blend.at([self, "noise"], Game.native_tick << 3)
			_draw_tex(noise, Vector2(0, fposmod(fall, noise.get_height() + 600) - noise.get_height()))
	if _counter >= 64:
		var origin: Vector2 = _blend.at("end", _end_origin())
		_draw_tex(_tex(3), origin)
		if game == "joey":
			var phase := (_counter >> 3) & 3
			if phase != 0:
				var offset: int = [-1, 0, 1, 0][phase]
				if ((_counter >> 5) & 7) == 0 and _raw(4 + offset) != 0:
					_draw_tex(_tex(4 + offset), origin + _pos(4 + offset))
				if _counter < 65536 and _raw(6 + offset) != 0:
					_draw_tex(_tex(6 + offset), origin + _pos(6 + offset))
		else:
			for i in [4, 6]:
				var mode := _raw(i + 1)
				var index: int = i
				if mode == 1:
					var phase := (_counter >> 3) & 3
					if _counter < 96 or phase == 0 or _counter >= 65536: continue
					index += [-1, 0, 1, 0][phase]
				elif mode == 2:
					index += [0, 1, 2, 3, 2, 1][(_counter >> 2) % 6] if _counter < 65536 else 0
				elif mode != 3:
					continue
				_draw_tex(_tex(index), origin + _pos(i))
	if _counter > 96:
		if game == "kaiba":
			_draw_tex(_tex(9 + _random), _pos(9 + _random))
		_draw_tex(_tex(2), _blend.at("result", _result_origin()))
