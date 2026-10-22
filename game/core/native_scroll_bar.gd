class_name NativeScrollBar
extends Node2D
## Yugi4116f0/464720/464780/4648d0 y44d2f0: barra vertical de mapa de bits.
## Con un script de 10 lineas (list/detail_scroll.txt) dibuja como 45e190: linea 0 = grosor,
## boton, caja y barra en grupos de 2/2/2/3 cifras; lineas 1-3 caja, 4-6 flecha de arriba y
## 7-9 de abajo (normal, senalada, pulsada), cada una con su desplazamiento XXXYYY hacia
## arriba a la izquierda.
signal scrolled(value: int)
var value := 0
var maximum := 0
var track := 80
var step := 30
var _textures: Array[Texture2D] = []
var _button := 14
var _knob := 40
var _hover := 0
var _held := 0
var _held_ticks := 0
var _drag_offset := 0
var _drag_pixels := 0
var _mouse_local := Vector2(-1, -1)
var _clock := 0.0
var _arrow_only := false
var _invisible := false
## Ancho que responde al raton (+0x40); en las barras de deck_c, el del boton.
var _thickness := -1
var _list_offsets: Array[Vector2] = []

func _init(game: String, script: String, arrow_only := false) -> void:
	_arrow_only = arrow_only
	_invisible = game == "joey" and script == "bar_warning"
	if _invisible:
		# Jo41c1e0/54d6a0: control sin imagenes, geometria16/16/128.
		_button = 16
		_knob = 16
		track = 128
		# +60 no se inicializa en el original: no asignar un paso inventado.
		step = 0
		return
	var layout := Assets.layout(game + "/" + script + ".txt" if "/" in script else game + "/deck_c/" + script + ".txt")
	if layout.items.size() >= 10:
		_init_list(game + "/" + script.get_base_dir() + "/", layout)
		return
	for i in 4:
		_textures.append(null if arrow_only and i == 1 else Assets.texture(game + "/deck_c/" + layout.resource(i)))
	_button = _textures[2].get_height()
	_knob = 0 if arrow_only else _textures[0].get_height()

## 45f560: 131451177 -> grosor 13, boton 14, caja 51, barra 177.
func _init_list(dir: String, layout: Layout) -> void:
	var sizes := int(str(layout.value(0)))
	_thickness = sizes / 10000000
	_button = (sizes / 100000) % 100
	_knob = (sizes / 1000) % 100
	track = sizes % 1000
	for i in 10:
		_textures.append(Assets.texture(dir + layout.resource(i)))
		var v := int(str(layout.value(i)))
		_list_offsets.append(Vector2(v / 1000, v % 1000))

func set_range(limit: int) -> void:
	maximum = maxi(0, limit)
	set_value(value)
	queue_redraw()

func set_value(next: int) -> void:
	var clamped := clampi(next, 0, maximum)
	if value != clamped:
		value = clamped
		scrolled.emit(value)
	queue_redraw()

func knob_offset() -> int:
	if maximum == 0: return 0
	if _held == 3: return _drag_pixels
	return (maximum / 2 + (track - _knob) * value) / maximum

func _hit(local: Vector2) -> int:
	if maximum == 0 or local.x < 0 or local.x >= (_thickness if _thickness >= 0 else _button) or local.y < 0 or local.y >= track + 2 * _button: return 0
	if local.y < _button: return -1
	if local.y >= _button + track: return 1
	if local.y < _button + knob_offset(): return -2
	if local.y >= _button + knob_offset() + _knob: return 2
	return 3

func _move_held() -> void:
	if _held in [-1, 1]: set_value(value + _held)
	elif _held in [-2, 2]: set_value(value + (step if _held > 0 else -step))

func handle(event: InputEvent) -> bool:
	if event is InputEventMouseMotion:
		var local: Vector2 = event.position - global_position
		_mouse_local = local
		_hover = _hit(local)
		if _held == 3:
			var offset := clampi(int(local.y) - _button - _drag_offset, 0, track - _knob)
			_drag_pixels = offset
			set_value(((track - _knob) / 2 + maximum * offset) / (track - _knob))
		queue_redraw()
		return _held != 0
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_local = event.position - global_position
		_hover = _hit(_mouse_local)
		if not event.pressed:
			var was_held := _held != 0
			_held = 0
			queue_redraw()
			return was_held
		if _hover == 0: return false
		_drag_pixels = knob_offset()
		_held = _hover
		_held_ticks = 0
		_drag_offset = int(_mouse_local.y) - _button - _drag_pixels
		_move_held()
		queue_redraw()
		return true
	return false

func _process(delta: float) -> void:
	_clock += NativeClock.ticks(delta)
	while _clock >= 1:
		_clock -= 1
		var hover := _hit(_mouse_local)
		if _hover != hover:
			_hover = hover
			queue_redraw()
		if _held != 0 and _held == _hover:
			_held_ticks += 1
			# 4648d0: primer cambio al pulsar, pausa16 ticks y repeticion cada tick.
			if _held_ticks >= 16: _move_held()

func _draw() -> void:
	if _invisible: return
	if not _list_offsets.is_empty():
		_draw_list()
		return
	if _arrow_only:
		# Ka452170/44fd60: dos flechas fijas, sin boton deslizante ni recurso1.
		if maximum == 0: return
		draw_texture(_textures[0], Vector2(5, 2))
		if _hover == -1: draw_texture(_textures[2], Vector2(7, 2))
		elif _hover == 1: draw_texture(_textures[3], Vector2(5, 2 + _button))
		return
	if maximum == 0:
		draw_texture(_textures[1], Vector2(0, _button))
		return
	if _hover == -1: draw_texture(_textures[2], Vector2.ZERO)
	if _hover == 1: draw_texture(_textures[3], Vector2(0, _button + track))
	draw_texture(_textures[0], Vector2(0, _button + knob_offset()))

## 45e190: solo con texto que no cabe (+0x3c). La imagen de cada pieza suma 1 si el raton la
## senala (+0x24) y otro 1 si ademas esta pulsada (+0x28: lo que se mantiene pulsado y sigue
## senalado).
func _draw_list() -> void:
	if maximum == 0: return
	var acting := _held if _held != 0 and _held == _hover else 0
	draw_texture(_textures[0], Vector2(0, _button))
	var up := 4 + int(_hover == -1) + int(acting == -1)
	draw_texture(_textures[up], -_list_offsets[up])
	var down := 7 + int(_hover == 1) + int(acting == 1)
	draw_texture(_textures[down], Vector2(0, track + _button) - _list_offsets[down])
	var box := 1 + int(_hover == 3) + int(acting == 3)
	draw_texture(_textures[box], Vector2(0, _button + knob_offset()) - _list_offsets[box])
