extends Node2D
## Duelo LAN de Joey (D17): pantalla de conexion. Escena del original con constructor 420310
## (lan_duel/connect.txt, musica 0x20000003 = m_kaban.wav), update 4207d0 y dibujo 421630.
## El transporte (DirectPlay en el original) es el autoload Lan (ENet + descubrimiento UDP).
##
## Estados (+0x9c), contador (+0xa4), sentido de la persiana (+0xa0):
##   0 inicio, puntero al campo del nombre (420590(0)).
##   1 nombre: se escribe (44e900); Decidir o clic en el interruptor con nombre -> 2.
##   2 la persiana baja de y=-550 a y=-320 en 32 ticks y el interruptor sube (5dabb8).
##   3 Anfitrion / Invitado (443650 crea la sesion): clic o Decidir -> 4.
##   4 la persiana baja a 0 (o vuelve a -320 si +0xa0 < 0) en 32 ticks -> 5 (o 3).
##   5 anfitrion: 443790 (hospedar) -> 7; invitado: 4437f0 (buscar) -> 6. Fallo -> 4 hacia atras.
##   6 lista de partidas (443840): elegir y unirse (443860) -> 7. Cancelar -> 4 hacia atras.
##   7 espera de rival (444220 == 2), nombres, modo 3 (44bee0) y sincronia de mazos y semilla
##     (5bdb40); despues, escena 7 (janken). Sin sesion -> 8.
##   8 cierra la sesion y vuelve al titulo (escena 4).
## Cancelar en los estados 1 y 3 vuelve al titulo (escena 2).

signal finished(next: String)

const DIR := "joey/lan_duel/"
## 5dabb8: inicio de cada fotograma de switch.bmp (tira de 5) para el estado del interruptor.
const SWITCH_FRAMES := [0, 36, 64, 88, 108]
## 44e900: el nombre admite hasta 0x14 caracteres.
const MAX_NAME := 20
## 5bdb40: pasos de la sincronia en los bits 0-2 de a58260.
enum Sync { SEND_DECK, WAIT_DECK, SEED, DONE }

var game := "joey"
var _layout: Layout
var _tex: Array[Texture2D] = []
var _state := 0          # +0x9c
var _dir := 0            # +0xa0
var _t := 0              # +0xa4
var _shutter := 0        # +0xcc (y de la persiana, negativa)
var _choice := -1        # +0xd4: 1 anfitrion, 0 invitado, -1 ninguno
var _row := -1           # +0xd0 fila de la lista
var _leaving := ""       # +0xd8: escena siguiente
var _sync := Sync.SEND_DECK
var _sync_flags := 0     # a58260: 8 mazo recibido, 0x10 semilla recibida
var _sync_error := false # a577fa & 0x20
var _local_deck := {}
var _rival_deck := {}
var _seed := -1
var _cards: CardTables
var _name := LineEdit.new()
var _font := SystemFont.new()
var _clock := 0.0
var _clicked := false
var _cancel := false
var _keys := {}
var _mouse := Vector2(-1, -1)
var _cursor = preload("res://scenes/duel/duel_cursor_visual.gd").new()


func _init(game_id := "joey") -> void:
	game = game_id


func _ready() -> void:
	_layout = Assets.layout(DIR + "connect.txt")
	for i in _layout.items.size():
		# null.bmp solo lleva coordenadas (persiana, campo del nombre...).
		var resource := _layout.resource(i)
		_tex.append(null if resource.to_lower() == "null.bmp" else Assets.texture(DIR + resource))
	# 420310: +0xcc = -(y de la persiana) => arriba del todo, asomando por abajo.
	_shutter = -_pos(1).y
	_font.font_names = PackedStringArray(["Arial", "Liberation Sans", "Roboto", "sans-serif"])
	_font.font_weight = 700
	_setup_name()
	_mouse = get_local_mouse_position()
	add_child(_cursor)
	_cursor.update(_mouse, false)
	_cards = CardTables.new()
	_cards.load_from(Paths.data_dir)
	Audio.play_music("%s/voice/stream/m_kaban.wav" % game)
	Lan.close()


## Campo del nombre: 44e420/44e900/44ed60 del original. Un LineEdit muestra el teclado en
## pantalla en Android; va sin marco sobre el recuadro blanco de 2p_duel.
func _setup_name() -> void:
	var empty := StyleBoxEmpty.new()
	empty.set_content_margin_all(0)
	for style in ["normal", "focus", "read_only"]:
		_name.add_theme_stylebox_override(style, empty)
	_name.add_theme_font_override("font", _font)
	_name.add_theme_font_size_override("font_size", 16)
	_name.add_theme_color_override("font_color", Color.BLACK)
	_name.add_theme_color_override("caret_color", Color.BLACK)
	_name.add_theme_color_override("font_uneditable_color", Color.BLACK)
	_name.max_length = MAX_NAME
	_name.context_menu_enabled = false
	_name.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
	var at := _pos(4)
	var span := _pos(5)
	_name.position = Vector2(at)
	_name.size = Vector2(span.x, 0)
	_name.position.y = at.y + span.y / 2.0 - _name.get_combined_minimum_size().y / 2.0
	_name.text = str(SaveData.data.get("lan", {}).get("name", ""))
	_name.text_submitted.connect(func(_t: String) -> void: _keys[6] = true)
	add_child(_name)


func _pos(index: int) -> Vector2i:
	return _layout.position(index)


func _size(index: int) -> Vector2i:
	var tex := _tex[index]
	return Vector2i(tex.get_size()) if tex != null else Vector2i.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_mouse = get_global_transform_with_canvas().affine_inverse() * event.position
		_cursor.update(_mouse, false, -1, PlatformInput.mouse_pressed(MOUSE_BUTTON_LEFT))
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_clicked = true
				_cursor.click(_mouse)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_cancel = true
	elif event is InputEventKey and event.pressed and not event.echo:
		# 5664a0: 1 arriba, 2 abajo, 3 izquierda, 4 derecha, 6 decidir, 0x14 cancelar.
		var code: int = {KEY_UP: 1, KEY_DOWN: 2, KEY_LEFT: 3, KEY_RIGHT: 4, KEY_ENTER: 6,
				KEY_KP_ENTER: 6, KEY_SPACE: 6, KEY_ESCAPE: 0x14, KEY_BACKSPACE: 0x14}.get((event as InputEventKey).keycode, 0)
		if code == 0x14 and _name.has_focus():
			return
		if code != 0:
			_keys[code] = true
	get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	# Con el campo enfocado el LineEdit se queda las teclas: las de mover y salir siguen siendo
	# del original.
	if _name.has_focus() and event is InputEventKey and event.pressed and not event.echo:
		var key := (event as InputEventKey).keycode
		if key in [KEY_UP, KEY_DOWN, KEY_ESCAPE]:
			_keys[{KEY_UP: 1, KEY_DOWN: 2, KEY_ESCAPE: 0x14}[key]] = true
			get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed and _name.has_focus() \
			and not Rect2(_name.position, _name.size).has_point(get_local_mouse_position()):
		_name.release_focus()


func _process(delta: float) -> void:
	_cursor.advance(delta)
	_clock = minf(_clock + NativeClock.ticks(delta), 4.0)
	while _clock >= 1.0 and _leaving == "":
		_clock -= 1.0
		_step()
		_clicked = false
		_cancel = false
		_keys.clear()
	_name.editable = _state <= 1
	queue_redraw()


func _key(code: int) -> bool:
	return _keys.has(code)


func _decide() -> bool:
	return _clicked or _key(6)


func _back() -> bool:
	return _cancel or _key(0x14)


func _sound(name: String) -> void:
	Audio.play_sfx("%s/voice/internal/%s.wav" % [game, name])


## 420590: lleva el puntero a una opcion (0 nombre, 1 interruptor, 2/3 anfitrion/invitado,
## 4+ filas de la lista) con el deslizamiento de teclado (47fc80).
func _warp(target: int) -> void:
	var at := Vector2.ZERO
	match target:
		0:
			at = Vector2(_pos(4) + _pos(5))
		1:
			at = Vector2(_pos(6).x + _size(6).x / 2, _pos(6).y + _switch_frame_height(4) / 2 + SWITCH_FRAMES[4])
		2, 3:
			var i := 9 if target == 2 else 10
			at = Vector2(_pos(1).x + _pos(i).x + _size(i).x / 2, _pos(i).y + _shutter + _size(i).y / 2)
		_:
			var row := target - 4
			if row >= Lan.sessions.size():
				return
			at = Vector2(_pos(1).x + _pos(14).x + _size(14).x / 2, _pos(14).y + _shutter + _size(14).y * row + _size(14).y / 2)
	PointerGlide.request(_mouse, at, game)


func _glide_step() -> void:
	var at := PointerGlide.step(self, _mouse)
	if at != _mouse:
		_mouse = at
		_cursor.update(at, false)


func _step() -> void:
	_glide_step()
	var mx := int(_mouse.x)
	var my := int(_mouse.y)
	match _state:
		0:
			_state = 1
			_dir = 0
			_t = 0
			_warp(0)
			# 44e900 escribe en el campo desde el principio (en Android abre el teclado).
			_name.grab_focus()
			_name.caret_column = _name.text.length()
		1:
			if _key(1): _warp(0)
			elif _key(2): _warp(1)
			# Clic en el recuadro: el campo toma el foco (44ecd0 pone el cursor de texto).
			var field := Rect2(Vector2(_pos(4)), Vector2(_pos(5).x, maxf(_pos(5).y, _name.size.y)))
			if _clicked and field.grow(4).has_point(_mouse):
				_name.grab_focus()
				_clicked = false
			var on_switch := Rect2(Vector2(_pos(6)), Vector2(_size(6))).has_point(_mouse)
			if (on_switch and _clicked) or _key(6):
				var text := _name.text.strip_edges()
				if text != "":
					_name.release_focus()
					_name.text = text
					var lan: Dictionary = SaveData.data.get("lan", {})
					lan["name"] = text
					SaveData.data["lan"] = lan
					SaveData.save()
					_state = 2
					_t = 0
					_sound("decide")
			if _back() and not _name.has_focus():
				_leave("title", "return")
		2:
			# Persiana de -550 a -320 con la tabla de cosenos (a52ee8, paso 8 de 512).
			var top := _pos(1).y
			var mid := _pos(7).y
			_shutter = ((0x10000 - DuelVisualMath.cos_fx((_t & 0x3f) * 8)) * (top - mid) >> 17) - top
			_t += 1
			if _t > 0x1f:
				_state = 3
				_t = 0
		3:
			if _t == 0:
				_t = 1
				_warp(2)
			if _key(3): _warp(2); _sound("cursor")
			elif _key(4): _warp(3); _sound("cursor")
			_choice = -1
			for i in 2:
				var index := 9 + i
				var r := Rect2(Vector2(_pos(1).x + _pos(index).x, _pos(index).y + _shutter), Vector2(_size(index)))
				if r.has_point(_mouse):
					_choice = int(i == 0)
					if _decide():
						_state = 4
						_dir = 0
						_t = 0
						_sound("decide")
			if _back() and _state == 3:
				_leave("title", "return")
		4:
			var mid := _pos(7).y
			var bottom := _pos(11).y
			var from := mid if _dir >= 0 else bottom
			var to := bottom if _dir >= 0 else mid
			_shutter = ((0x10000 - DuelVisualMath.cos_fx((_t * 8) & 0x1ff)) * (from - to) >> 17) - from
			_t += 1
			if _t > 0x1f:
				_state = 5 if _dir >= 0 else 3
				_t = 0
				_dir = 0
		5:
			var err := Lan.browse(_name.text, game) if _choice == 0 else Lan.host(_name.text, game)
			if err == OK:
				_state = 6 if _choice == 0 else 7
				_t = 0
				_row = -1
			else:
				push_warning("LAN: no se pudo %s (%s)" % ["buscar partidas" if _choice == 0 else "crear la partida", error_string(err)])
				_reverse()
		6:
			_list_step(mx, my)
		7:
			_wait_step()
		8:
			Lan.close()
			_leave("title", "")


## 4207d0 estado 4 con +0xa0 = -1: la persiana vuelve a -320 (Anfitrion / Invitado).
func _reverse() -> void:
	_state = 4
	_dir = -1
	_t = 0


func _list_step(_mx: int, _my: int) -> void:
	if _back():
		Lan.close()
		_reverse()
		_sound("return")
		return
	_row = -1
	var at := Vector2(_pos(1).x + _pos(14).x, _pos(14).y + _shutter)
	var height := _size(14).y
	for i in Lan.sessions.size():
		if Rect2(at + Vector2(0, height * i), Vector2(_size(14))).has_point(_mouse):
			_row = i
	var count := Lan.sessions.size()
	if _row + 1 < count and _key(2):
		_warp(_row + 5)
		_sound("cursor")
	elif _row - 1 >= 0 and _key(1):
		_warp(_row + 3)
		_sound("cursor")
	if _row >= 0 and _decide():
		var target: Dictionary = Lan.sessions[_row]
		if Lan.join(str(target["address"]), int(target["port"])) == OK:
			_state = 7
			_t = 0
			_sound("decide")


func _wait_step() -> void:
	match _t:
		0:
			# 5bdb20: sincronia a cero.
			_sync = Sync.SEND_DECK
			_sync_flags = 0
			_sync_error = false
			_t = 1
		1:
			if _back():
				Lan.close()
				_reverse()
				_sound("return")
				return
			if Lan.terminated:
				# La conexion del invitado no llego a establecerse.
				_reverse()
				return
			if Lan.players() == 2:
				_t = 2
		2:
			# 44bee0(3, 0): modo de duelo LAN; los nombres quedan en Lan (5f3264/5f3274).
			Game.duel_mode = 3
			_local_deck = _deck_to_send()
			_t = 3
		3:
			if _sync_step():
				_t = 4
			if _sync_error:
				_state = 8
				_t = 0
		4:
			Game.lan_rival_deck = _rival_deck
			Game.lan_seed = _seed
			_leave("janken", "")


## 5bdb40 con la parte de 5bd2d0 que se usa en la sala: 0xf004 mazo, 0xf005 semilla.
## Devuelve true al terminar.
func _sync_step() -> bool:
	if _sync == Sync.DONE:
		return true
	if not _sync_receive():
		return true
	match _sync:
		Sync.SEND_DECK:
			Lan.send(_deck_packet(_local_deck))
			_sync = Sync.WAIT_DECK
		Sync.WAIT_DECK:
			if (_sync_flags & 8) != 0:
				_sync = Sync.SEED
		Sync.SEED:
			if Lan.is_host:
				# 5bd2a0: semilla de la sesion (44b9c0) en dos mitades.
				_seed = randi() & 0x7fffffff
				var payload := PackedByteArray()
				payload.resize(4)
				payload.encode_u16(0, _seed & 0xffff)
				payload.encode_u16(2, (_seed >> 16) & 0xffff)
				Lan.send_message(0xf005, payload)
				_sync = Sync.DONE
			elif (_sync_flags & 0x10) != 0:
				_sync = Sync.DONE
	return false


## 5bd2d0 en la sala: un paquete por tick. false si hay error (sesion perdida o tipo ajeno).
func _sync_receive() -> bool:
	var packet := Lan.receive()
	if packet.size() < 2:
		if Lan.active():
			return true
		_sync_error = true
		return false
	match packet.decode_u16(0):
		0xf000:
			pass
		0xf004:
			_rival_deck = _deck_from_packet(packet)
			_sync_flags |= 8
		0xf005:
			_seed = packet.decode_u16(2) | (packet.decode_u16(4) << 16)
			_sync_flags |= 0x10
		0xef00:
			_sync_error = true
			return false
		_:
			Lan.send_message(0xef00, PackedByteArray([0, 0, 0, 0, 0, 0]))
			_sync_error = true
			return false
	return true


## Mazo propio: el activo si es valido (como normal_duel), si no el inicial del juego.
func _deck_to_send() -> Dictionary:
	var active: Dictionary = SaveData.data.get("decks", {}).get(game, {})
	if active.get("main", []).size() >= 40 and active.get("main", []).size() <= 80:
		return {"main": PackedInt32Array(active.get("main", [])), "fusion": PackedInt32Array(active.get("fusion", []))}
	var original: Variant = Assets.read_json("%s/file/starter_deck.json" % game)
	if original is Dictionary:
		return {"main": PackedInt32Array(original.get("main", [])), "fusion": PackedInt32Array(original.get("fusion", []))}
	return {"main": PackedInt32Array(), "fusion": PackedInt32Array()}


## 5bd210: 0xf004, cuentas (principal en el byte bajo, fusion en el alto) y las cartas como
## las guarda el mazo de la partida (indices de la tabla de cartas).
func _deck_packet(deck: Dictionary) -> PackedByteArray:
	var main: PackedInt32Array = deck.get("main", PackedInt32Array())
	var fusion: PackedInt32Array = deck.get("fusion", PackedInt32Array())
	var n := mini(main.size(), 80)
	var k := mini(fusion.size(), 15)
	var packet := PackedByteArray()
	packet.resize(4 + (n + k) * 2)
	packet.encode_u16(0, 0xf004)
	packet.encode_u16(2, (k << 8) | n)
	for i in n:
		packet.encode_u16(4 + i * 2, _cards.index_of(main[i]))
	for i in k:
		packet.encode_u16(4 + (n + i) * 2, _cards.index_of(fusion[i]))
	return packet


func _deck_from_packet(packet: PackedByteArray) -> Dictionary:
	var n := packet[2]
	var k := packet[3]
	var main := PackedInt32Array()
	var fusion := PackedInt32Array()
	for i in n:
		if 4 + i * 2 + 1 < packet.size():
			main.append(_cards.id_of(packet.decode_u16(4 + i * 2) & 0xfff))
	for i in k:
		if 4 + (n + i) * 2 + 1 < packet.size():
			fusion.append(_cards.id_of(packet.decode_u16(4 + (n + i) * 2) & 0xfff))
	return {"main": main, "side": PackedInt32Array(), "fusion": fusion}


func _leave(next: String, sound: String) -> void:
	if sound != "":
		_sound(sound)
	_leaving = next
	finished.emit(next)


# --- dibujo (421630) -----------------------------------------------------------------------

func _blit(index: int, at: Vector2, source := Rect2()) -> void:
	var tex := _tex[index]
	if tex == null:
		return
	if source.has_area():
		draw_texture_rect_region(tex, Rect2(at, source.size), source)
	else:
		draw_texture(tex, at)


func _switch_frame_height(frame: int) -> int:
	var next: int = SWITCH_FRAMES[frame + 1] if frame + 1 < SWITCH_FRAMES.size() else _size(6).y
	return next - SWITCH_FRAMES[frame]


func _draw() -> void:
	_blit(0, Vector2.ZERO)
	# Persiana (y negativa: baja desde arriba).
	var shutter_x := _pos(1).x
	_blit(1, Vector2(shutter_x, _shutter))
	# Interruptor: fotograma 4 en reposo, 3..0 al confirmar el nombre.
	var frame := 4
	if _state == 2:
		frame = 3 - mini(_t / 2, 3)
	elif _state > 2:
		frame = 0
	var top: int = SWITCH_FRAMES[frame]
	_blit(6, Vector2(_pos(6).x, _pos(6).y + top), Rect2(0, top, _size(6).x, _switch_frame_height(frame)))
	if _choice >= 0:
		var index := 9 if _choice == 1 else 10
		_blit(index, Vector2(shutter_x + _pos(index).x, _pos(index).y + _shutter))
	if _state > 4:
		if _choice == 0:
			_draw_sessions(shutter_x)
		elif _state == 7:
			_blit(12, Vector2(_pos(12)))
	if _state == 1:
		_blit(3, Vector2(_pos(3)))
	elif _state == 3:
		_blit(8, Vector2(_pos(8)))


func _draw_sessions(shutter_x: int) -> void:
	var at := Vector2(shutter_x + _pos(14).x, _pos(14).y + _shutter)
	var row := _size(14)
	if Lan.sessions.is_empty():
		_blit(13, Vector2(_pos(13)))
		return
	for i in Lan.sessions.size():
		var y := at.y + row.y * i
		if i == _row and _state == 6:
			_blit(14, Vector2(at.x, y))
		# 544b20(0x12)/544b70(700): 18 px en negrita, centrado en la fila.
		var text := str(Lan.sessions[i]["name"])
		var width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		var base := y + row.y / 2.0 + _font.get_ascent(18) / 2.0 - 2.0
		draw_string(_font, Vector2(at.x + (row.x - width) / 2.0, base), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
