extends Node2D
## Escena 7 de la fabrica 0x464220 (constructor 0x4634a0, vtable 0x59c9ec): piedra-papel-tijera
## antes del duelo. Init 0x4453c0 (janken/janken.txt, musica install.wav 0x20000001) y update
## 0x4449e0, que en cada fotograma avanza la maquina de estados +0xac y dibuja con:
##   0x443cc0 marco (piezas 0-9 y la franja central 7/8),
##   0x443ff0 tiras: arriba las de Yugi (ojos 25/26, se desplazan a la izquierda), abajo las
##            del jugador (manos 10..24, hacia la derecha),
##   0x4442d0 manos grandes (13..24 _4/_5) y GANAS (28) en el hueco central,
##   0x444700 botones Primero / Segundo en jugar (29..32, via 0x444650).
## La CPU elige en 0x443a80(0xfc65) (fuera de red). Al acabar, DAT_005af770 = boton elegido
## (+0xe4) y se pasa a la escena 3 (duelo) con ese valor como opciones (0x5418a0).
## Lo que dibuja el original en orden se guarda como lista de ordenes en el momento exacto del
## update en que lo llama, y _draw la reproduce.
## En match, desde el segundo duelo con el anterior decidido, se salta a los botones y elige
## el perdedor. En red (solo Joey, D17) el rival responde por Lan: ver _net/_net_receive.

signal finished(options: int)
## Duelo LAN (D17): se perdio la sesion durante el janken.
signal lost

## Janken en red (solo Joey tiene red): el rival responde por Lan en vez de la CPU.
var lan := false
var _lan_closed := false

const DIR := "yugi/janken/"
var game := "yugi"
var _dir := DIR
# Geometria fijada en 0x4453c0.
const X0 := 0      # +0xf4
const X1 := 200    # +0xf8
const X2 := 600    # +0xfc
const Y0 := 50     # +0x100
const Y1 := 250    # +0x104
const Y2 := 350    # +0x108
const Y3 := 550    # +0x10c
var W := 200       # Init consulta la ficha 0x19: Joey mide 206×200.
var H := 200

var _layout: Layout
var _tex: Array[Texture2D] = []
var _state := 0        # +0xac
var _t := 0            # +0xb4
var _ready_flag := 0   # +0xb0
var _scroll_me := 0    # +0xb8 (tira del jugador, 24.8)
var _target_me := 0    # +0xbc
var _scroll_cpu := 0   # +0xc0 (tira de Yugi)
var _target_cpu := 0   # +0xc4
var _speed := 0        # +0xc8
var _ease := 0         # +0xcc
var _pick_me := -1     # +0xd0 ficha del jugador
var _pick_cpu := -1    # +0xd4 ficha de Yugi
var _cpu_hand := -1    # +0xd8
var _result := 0       # +0xdc: 0 empate, 1 gana el jugador, 2 gana Yugi
var _rounds := 0       # +0xe0
var _button := -1      # +0xe4: 0 primero, 1 segundo
var _dim_pending := -1 # imagen que el update anterior oscurecio despues de dibujar
var _cmds: Array = []
var _prev_cmds: Array = []
var _cmd_pairs := {}
var _clock := 0.0
var _clicked := false
var _keys := {}
var _done := false
var _mouse := Vector2(-1, -1)   # ultima posicion del raton (0x26c+4), desde los eventos
var _cursor = preload("res://scenes/duel/duel_cursor_visual.gd").new()

func _init(game_id := "yugi") -> void:
	game = game_id
	_dir = game + "/janken/"


func _ready() -> void:
	_layout = Assets.layout(_dir + "janken.txt")
	for i in _layout.items.size():
		_tex.append(Assets.texture(_dir + _layout.resource(i)))
	# Init4453c0 / Joey45e670: vtable+0x38 del recurso25.
	W = _tex[25].get_width()
	H = _tex[25].get_height()
	_mouse = get_local_mouse_position()
	add_child(_cursor)
	_cursor.update(_mouse, false)
	_scroll_me = _initial_scroll()
	_scroll_cpu = W * 0x500
	Audio.play_music("%s/voice/stream/%s.wav" % [game, "install" if game == "yugi" else "m_jyank"])
	# 0x4453c0, match a partir del segundo duelo con el anterior decidido: sin manos; elige el
	# que perdio (resultado 1 -> +0xdc = 2, Yugi elige al azar; 2 -> 1, elige el jugador).
	var previous: int = Game.match_results[Game.match_duel - 2] if Game.duel_mode == 1 and Game.match_duel > 1 else 0
	if previous == 1 or previous == 2:
		_result = int(previous == 1) + 1
		var tiles := (W * 7 - (800 - W) / 2) * 0x100
		_scroll_cpu = tiles
		_scroll_me = tiles
		_pick_cpu = 7
		_pick_me = 7
		_t = 0
		_button = UiRandom.draw() & 1   # 0x445526
		_state = 6


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_mouse = get_global_transform_with_canvas().affine_inverse() * event.position
		_cursor.update(_mouse, false, -1, PlatformInput.mouse_pressed(MOUSE_BUTTON_LEFT))
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_cursor.update(_mouse, false, -1, event.pressed)
			if event.pressed:
				_cursor.click(_mouse)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_clicked = true
	elif event is InputEventKey and event.pressed and not event.echo:
		# 0x538770: 1 arriba, 2 abajo, 3 izquierda, 4 derecha, 6 decidir.
		var code: int = {KEY_UP: 1, KEY_DOWN: 2, KEY_LEFT: 3, KEY_RIGHT: 4, KEY_ENTER: 6,
				KEY_KP_ENTER: 6, KEY_SPACE: 6}.get((event as InputEventKey).keycode, 0)
		if code != 0:
			_keys[code] = true
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	_cursor.advance(delta)
	_clock = minf(_clock + NativeClock.ticks(delta), 4.0)
	var stepped := false
	while _clock >= 1.0 and not _done:
		_clock -= 1.0
		_step()
		_clicked = false
		_keys.clear()
		_net_receive()
		stepped = true
	if stepped: _pair_commands()
	queue_redraw()


func _key(code: int) -> bool:
	return _keys.has(code)


## 0x4600f0 (PointerGlide.request): solo si el teclado se uso despues que el raton lleva el
## puntero a la ficha o al boton. Con el raton la manita se queda donde esta.
func _warp(pos: Vector2) -> void:
	PointerGlide.request(_mouse, pos)


## Un tick del deslizamiento compartido (0x45fff0). El janken elige siempre por el raton
## real (0x26c+4), no por el destino.
func _glide_step() -> void:
	var at := PointerGlide.step(self, _mouse)
	if at != _mouse:
		_mouse = at
		_cursor.update(at, false)


# --- update 0x4449e0 -----------------------------------------------------------------------

func _step() -> void:
	if _dim_pending >= 0:
		_tex[_dim_pending] = _dimmed(_tex[_dim_pending])
		_dim_pending = -1
	_glide_step()
	_prev_cmds = _cmds
	_cmds = []
	var mx := int(_mouse.x)
	var my := int(_mouse.y)
	var over_me := mx >= 0 and mx < 800 and my >= Y2 and my < Y3
	match _state:
		0:
			_frame_draw()
			_speed += 0x10 if _speed < 0x200 else 0
			_scroll_cpu += _speed
			_scroll_me += _speed
			_t += 1
			if _t == 1:
				_net(0xfc64)                  # 0x443a80(0xfc64)
			if _t >= 0x20 and _ready_flag >= 1:
				_warp(Vector2(400, H / 2 + Y2))
				_pick_cpu = -1
				_next()
		1:
			if _t == 0:
				_target_me = 0
			_t += 1 if _t < 8 else 0
			if _target_me == 0:
				_pick_me = ((_scroll_me >> 8) + mx) / W if over_me else -1
			_frame_draw()
			if _target_me == 0:
				if over_me:
					_speed -= 0x10 if _speed > 0 else 0
				else:
					_speed += 0x10 if _speed < 0x200 else 0
				_scroll_me = posmod(_speed + _scroll_me, W * 0x300) + W * 0x300
				if _key(4) or _key(3):
					if _pick_me == -1:
						_warp(Vector2(400, H / 2 + Y2))
					else:
						var x := W * (int(_key(4)) - int(_key(3)) + _pick_me) + W / 2 - (_scroll_me >> 8)
						if x >= 0 and x <= 799:
							_warp(Vector2(x, H / 2 + Y2))
				if over_me and (_clicked or _key(6)):
					_ease = 0
					_target_me = (_pick_me * W - 400 + W / 2) * 0x100
					_net(0xfc65)
					Audio.play_sfx("%s/voice/internal/cursor.wav" % game)   # 0x10000000
			else:
				_ease += 1 if _ease < 0x10 else 0
				_scroll_me = (_scroll_me - _target_me) * (0x10 - _ease) / (0x11 - _ease) + _target_me
				if _cpu_hand >= 0:
					# Ficha de Yugi: la siguiente de su tira con la mano que ha elegido.
					_pick_cpu = (_scroll_cpu >> 8) / W
					while posmod(_pick_cpu, 3) != _cpu_hand % 3:
						_pick_cpu += 1
					_target_cpu = (_pick_cpu * W - 400 + W / 2) * 0x100
					_cpu_hand = -1
					_state += 1
					_t = 0
			_scroll_cpu = posmod(_scroll_cpu + 0x200, W * 0x300) + W * 0x300
		2:
			_ease += 1 if _ease < 0x10 else 0
			_scroll_me = (_scroll_me - _target_me) * (0x10 - _ease) / (0x11 - _ease) + _target_me
			_t += 1 if _t < 0x10 else 0
			_scroll_cpu = (_scroll_cpu - _target_cpu) * (0x10 - _t) / (0x11 - _t) + _target_cpu
			_frame_draw()
			if _t == 0x10:
				_ready_flag = 3
				_next()
		3:
			_t += 0x10
			_hands_draw(Rect2i(X1, Y0, X2 - X1, Y3 - Y0))
			_frame_draw()
			if _t == 0:
				_pick_cpu = -1
				_speed = 0
				_state = 1
				_t = 0
			if _t == 0x100:
				var a := _pick_cpu
				var b := _pick_me
				if a <= b:
					b = (b - a) % 3
					a = 3
				_result = (a - b) % 3
				_next()
		4:
			_hands_draw(Rect2i(X1, Y0, X2 - X1, Y3 - Y0))
			_frame_draw()
			_t += 1
			if _result == 0:
				if _t == 8:
					_state -= 1          # empate: las manos se retiran y se repite
					_t = -0x100
			else:
				if _t == 0x20:
					_next()
				if _t == 8:
					# Gana el jugador: mano de Yugi (+0xd4); si no, la del jugador (+0xd0).
					_dim_pending = posmod(_pick_cpu if _result == 1 else _pick_me, 3) * 5 + 0xd
		5:
			_enter_buttons()
		6:
			if _result != 2:
				_button = -1
				if mx >= X1 and mx < X2:
					if my >= Y0 and my < Y1: _button = 0
					if my >= Y2 and my < Y3: _button = 1
			_buttons_draw()
			_frame_draw()
			if _result == 2:
				if _button >= 0:
					_next()
					Audio.play_sfx("%s/voice/internal/decide.wav" % game)   # 0x10000001
			else:
				if _key(1):
					_warp(Vector2(400, H / 2 + Y0))
				elif _key(2):
					_warp(Vector2(400, H / 2 + Y2))
				if _button >= 0 and (_clicked or _key(6)):
					_net(0xfc66)
					_next()
					Audio.play_sfx("%s/voice/internal/decide.wav" % game)
		7:
			_t += 8
			_buttons_draw()
			_frame_draw()
			if _t == 0x180:
				_net(0xfc67)                       # 0x443a80(0xfc67)
			elif _t > 0x180 and _ready_flag > 6:
				_done = true
				if UiRandom.log_draws: # Cotejo con duel_start.opts de la traza (D29).
					print("janken: opciones %d tras %d rondas, MT %d" % [_button, _rounds, UiRandom.shared_draws])
				finished.emit(_button)


## 443a80 / Joey 461210: fuera de red la CPU responde en el acto; en red se manda al rival
## (0xfc64 listo, 0xfc65 mano, 0xfc66 quien empieza, 0xfc67 salida) y su respuesta llega por
## _net_receive (443bf0 / 461370).
func _net(kind: int) -> void:
	if not lan:
		match kind:
			0xfc64: _ready_flag = 1
			0xfc65: _cpu_choose()
			0xfc67: _ready_flag = 7
		return
	var value := 0
	match kind:
		0xfc65:
			_rounds += 1
			value = posmod(_pick_me, 3)
		0xfc66:
			# Joey manda el jugador que empieza en indices absolutos (5f3288): 1 el anfitrion.
			value = _button ^ _lan_index()
	var payload := PackedByteArray()
	if kind in [0xfc65, 0xfc66]:
		payload.resize(2)
		payload.encode_u16(0, value)
	Lan.send_message(kind, payload)


func _lan_index() -> int:
	return 1 if Lan.is_host else 0


## 443bf0 / Joey 461370: un mensaje del rival por fotograma. Sin sesion, el janken se
## abandona (escena 4: vuelta al titulo).
func _net_receive() -> void:
	if not lan or _lan_closed:
		return
	if not Lan.active():
		Lan.close()
		_done = true
		lost.emit()
		return
	var packet := Lan.receive()
	if packet.size() < 2:
		return
	var value := packet.decode_u16(2) if packet.size() >= 4 else 0
	match packet.decode_u16(0):
		0xfc64:
			_ready_flag = 1
		0xfc65:
			_cpu_hand = value % 3
		0xfc66:
			_button = (value ^ _lan_index()) & 1
		0xfc67:
			_ready_flag = 7
			_lan_closed = true


func _next() -> void:
	_state += 1
	_t = 0


## Estado 4 con +0xb4 == 8 (Yugi 0x4e2db0(0xa0, 0), Kaiba 0x4e51b0, Joey 0x4f64e0): oscurece
## en la propia superficie la imagen _4 del perdedor, que sigue en pantalla mientras el
## ganador pasa a la _5. En 32 bits cada canal pasa por la tabla 0x9eb1d0 de 0x51bbb0,
## fila 0xa0: c * 0xa0 / 255 truncado. La clave de estas imagenes es negra, asi que lo que
## acaba en (0,0,0) deja de verse.
func _dimmed(tex: Texture2D) -> Texture2D:
	if tex == null:
		return null
	var image := tex.get_image()
	image.convert(Image.FORMAT_RGBA8)
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		if data[i + 3] == 0:
			continue
		data[i] = data[i] * 0xa0 / 255
		data[i + 1] = data[i + 1] * 0xa0 / 255
		data[i + 2] = data[i + 2] * 0xa0 / 255
		if data[i] == 0 and data[i + 1] == 0 and data[i + 2] == 0:
			data[i + 3] = 0
	return ImageTexture.create_from_image(Image.create_from_data(image.get_width(),
			image.get_height(), false, Image.FORMAT_RGBA8, data))


func _initial_scroll() -> int:
	return W * 0x500


func _enter_buttons() -> void:
	_t += 0x20
	var close := DuelVisualMath.cos_fx((_t / 2 - 0x80) & 0x1ff) * H >> 16
	_hands_draw(Rect2i(X1, Y0 + close, X2 - X1, Y3 - Y0 - 2 * close))
	_buttons_draw()
	_frame_draw()
	if _t >= 0x100:
		if _result != 2:
			_warp(Vector2(400, H / 2 + Y0))
		_next()


## 0x443a80(0xfc65) fuera de red: mano de Yugi al azar; desde la segunda ronda, si saliera
## empate se vuelve a tirar una vez. Tambien decide su boton si gana.
func _cpu_choose() -> void:
	_cpu_hand = UiRandom.draw() % 3
	var diff := _cpu_hand - _pick_me if _pick_me < _cpu_hand else 3 - (_pick_me - _cpu_hand) % 3
	if _rounds != 0 and diff % 3 == 0:
		_cpu_hand = UiRandom.draw() % 3
	_rounds += 1
	_button = UiRandom.draw() & 1


# --- ordenes de dibujo ---------------------------------------------------------------------

func _blit(index: int, pos: Vector2, alpha := 1.0) -> void:
	_cmds.append(["tex", index, pos, alpha])


## 0x443cc0: marco de fondo; en el estado 7 las piezas centrales 1 y 4 cierran como telon.
func _frame_draw() -> void:
	var slide := 0
	if _state == 7:
		slide = (_tex[1].get_height() - Y0) * clampi(_t - 0x80, 0, 0x80) >> 7
	_blit(0, Vector2(X0, Y0 - _tex[0].get_height()))
	_blit(1, Vector2(X1, slide - _tex[1].get_height() + Y0))
	_blit(2, Vector2(X2, Y0 - _tex[2].get_height()))
	_blit(6, Vector2(X0, Y1))
	_blit(9, Vector2(X2, Y1))
	_blit(3, Vector2(X0, Y3))
	_blit(4, Vector2(X1, Y3 - slide))
	_blit(5, Vector2(X2, Y3))
	var v := 0x100
	if _state == 1:
		v = maxi(0x100, _t * 0x100 / 8 + 0x100)
	if _state == 2:
		v = maxi(0x100, 0x200 - _t * 0x100 / 8)
	if _state == 3:
		v = (0x80 - mini(absi(_t), 0x80)) * 2
	_middle_draw(v)
	_strips_draw()


func _middle_draw(v: int) -> void:
	if _state <= 3:
		# vtable+0x18 (0x470460) replica el alfa en los tres bytes: entre 0x100 y 0x200 lo que
		# se ve es el byte bajo, asi que "Selecciona tu mano" entra en 8 fotogramas.
		if v == 0x200:
			_blit(8, Vector2(X1, Y1))
		elif v == 0x100:
			_blit(7, Vector2(X1, Y1))
		elif v > 0x100:
			_blit(7, Vector2(X1, Y1))
			_blit(8, Vector2(X1, Y1), (v - 0x100) / 256.0)
		elif v > 0:
			_blit(7, Vector2(X1, Y1), v / 256.0)


## 0x443ff0: tiras. La ficha elegida se apaga y las demas se separan (estado 3).
func _strips_draw() -> void:
	var spread := 0
	var alpha := 0x100
	if _state == 3:
		var a := mini(absi(_t), 0x80)
		spread = ((400 - W) / 2) * a * 2 >> 8
		alpha = (0x80 - a) * 2
	if _state > 3:
		spread = (400 - W) / 2
		alpha = 0
	# Yugi (de derecha a izquierda): ojo 25, el suyo 26.
	var k := int((_scroll_cpu >> 8) / W)
	var x := -posmod(_scroll_cpu >> 8, W)
	while x < 800:
		var off := spread if k < _pick_cpu else (-spread if k > _pick_cpu else 0)
		var index := 0x19 + int(k == _pick_cpu)
		var pos := Vector2(off - W - x + 800, Y0)
		if k == _pick_cpu and alpha < 0x100:
			if alpha != 0: _blit(index, pos, alpha / 256.0)
		else:
			_blit(index, pos)
		k += 1
		x += W
	# Jugador: (mano + 2) * 5 = 10, 15, 20; +1 bajo el puntero, +2 elegida.
	k = (_scroll_me >> 8) / W
	x = -posmod(_scroll_me >> 8, W)
	while x <= 799:
		var off := -spread if k < _pick_me else (spread if k > _pick_me else 0)
		var index := (posmod(k, 3) + 2) * 5
		if k == _pick_me:
			index += 1 + int(_state == 2 or (_state == 1 and _target_me != 0))
			if alpha < 0x100:
				if alpha != 0: _blit(index, Vector2(off + x, Y2), alpha / 256.0)
				k += 1
				x += W
				continue
		_blit(index, Vector2(off + x, Y2))
		k += 1
		x += W


## 0x4442d0: hueco central relleno (vtable+0x44) y las dos manos grandes. Entre 0x80 y 0x100
## entran girando (0x415ec0, recortadas al hueco); despues, fijas (Yugi girada 180 grados con
## 0x42d070) y GANAS sobre la mano ganadora.
func _hands_draw(fill: Rect2i) -> void:
	_cmds.append(["fill", fill])
	var v := 0x100 if _state != 3 else absi(_t)
	var shown := _state > 4 or (_state == 4 and _t > 8)
	var me := posmod(_pick_me, 3) * 5 + 0xd
	var cpu := posmod(_pick_cpu, 3) * 5 + 0xd
	var clip := Rect2i(X1, Y0, X2 - X1, Y3 - Y0)
	if v == 0x100:
		var win_y := 0
		var mine := _tex[me + int(shown and _result == 1)]
		_blit(me + int(shown and _result == 1), Vector2(400 - mine.get_width() / 2, Y3 - mine.get_height() + 0x20))
		if _result == 1:
			win_y = Y3 - mine.get_height() / 2 + 0x20
		var yugi := _tex[cpu + int(shown and _result == 2)]
		_cmds.append(["rot", cpu + int(shown and _result == 2), Vector2(400, yugi.get_height() / 2 + Y0 - 0x20), 0x100, Rect2i()])
		if _result == 2:
			win_y = yugi.get_height() / 2 + Y0 - 0x20
		if shown and win_y != 0:
			var label := _tex[0x1c]
			_blit(0x1c, Vector2(400 - label.get_width() / 2, win_y - label.get_height() / 2))
	elif v > 0x80:
		var t := v - 0x80
		var mh := _tex[me].get_height()
		var mine_angle := 0x80 - v / 2
		_cmds.append(["rot", me, Vector2(400, Y3 - (t * mh >> 7) + mh / 2 + 0x20), mine_angle, clip])
		var ch := _tex[cpu].get_height()
		var cpu_angle := 0x180 - v / 2
		_cmds.append(["rot", cpu, Vector2(400, Y0 + (t * ch >> 7) + ch / 2 - ch - 0x20), cpu_angle, clip])


## 0x444700: botones (0x444650: 29 + (elegido) + 2 * (segundo)).
func _buttons_draw() -> void:
	match _state:
		5:
			var c := DuelVisualMath.cos_fx((_t / 2 - 0x80) & 0x1ff) * H >> 16
			_button_blit(0, Vector2(X1, Y0 - H + c), 0x100)
			_blit(7, Vector2(X1, Y1), mini(_t, 0xff) / 256.0)
			_button_blit(1, Vector2(X1, Y3 - c), 0x100)
		6:
			_button_blit(0, Vector2(X1, Y0), 0x100)
			_blit(7, Vector2(X1, Y1))
			_button_blit(1, Vector2(X1, Y2), 0x100)
		7:
			var move := clampi(_t - 0x80, 0, 0x80)
			if _t < 0x100:
				_cmds.append(["fill", Rect2i(X1, Y0, X2 - X1, Y3 - Y0)])
			if _t < 0x80:
				_blit(7, Vector2(X1, Y1), (0x80 - _t) * 2 / 256.0)
			var other := int(_button == 0)
			_button_blit(other, Vector2(X1, Y2 if _button == 0 else Y0), (0x80 - _t) * 2)
			var base := Y0 if _button == 0 else Y2
			# 444700: división con signo trunca a cero (sesgo 127 antes del SAR).
			_button_blit(_button, Vector2(X1, ((300 - H / 2 - base) * move / 128) + base), 0x100)


func _button_blit(which: int, pos: Vector2, alpha: int) -> void:
	var index := 0x1d + int(_button == which) + 2 * int(which != 0)
	if alpha > 0xff:
		_blit(index, pos)
	elif alpha >= 0:
		_blit(index, pos, alpha / 256.0)


## Ordenes del tick anterior que corresponden a las de este (indice actual -> anterior): las
## tiras, manos y botones se dibujan mezclados entre ticks. Las filas al azar de Kaiba no.
func _command_piece(cmd: Array) -> Array:
	return [cmd[0], cmd[1]]


func _pair_commands() -> void:
	_cmd_pairs.clear()
	if not NativeClock.interpolate:
		return
	var items := []
	for cmds: Array in [_prev_cmds, _cmds]:
		var list := []
		for j in cmds.size():
			var cmd: Array = cmds[j]
			match cmd[0]:
				"fill": list.append([j, ["fill"], Vector2(Rect2(cmd[1]).position)])
				"tex", "rot": list.append([j, _command_piece(cmd), Vector2(cmd[2])])
				"scaled": list.append([j, _command_piece(cmd), Vector2(Rect2(cmd[2]).position)])
		items.append(list)
	for pair in NativeBlend.pairs(items[0], items[1]):
		_cmd_pairs[items[1][pair[1]][0]] = items[0][pair[0]][0]


func _draw() -> void:
	draw_rect(Rect2(0, 0, 800, 600), Color.BLACK)
	var t := clampf(_clock, 0.0, 1.0) if NativeClock.interpolate else 1.0
	for j in _cmds.size():
		var cmd: Array = _cmds[j]
		var before: Array = _prev_cmds[_cmd_pairs[j]] if _cmd_pairs.has(j) else cmd
		match cmd[0]:
			"fill":
				draw_rect(NativeBlend.mix(before[1], cmd[1], t), Color.BLACK)
			"tex":
				var tex := _tex[cmd[1]]
				if tex != null:
					draw_texture(tex, Vector2(before[2]).lerp(cmd[2], t), Color(1, 1, 1, lerpf(before[3], cmd[3], t)))
			"rot":
				var turn := wrapf(float(cmd[3]) - float(before[3]), -256.0, 256.0)
				_draw_rotated(_tex[cmd[1]], Vector2(before[2]).lerp(cmd[2], t), float(cmd[3]) - turn * (1.0 - t), cmd[4])
			"region":
				var source: Rect2 = cmd[3]
				draw_texture_rect_region(_tex[cmd[1]], Rect2(cmd[2], source.size), source)
			"scaled":
				draw_texture_rect(_tex[cmd[1]], NativeBlend.mix(Rect2(before[2]), Rect2(cmd[2]), t), false)


## 0x415ec0 / 0x42d070: girada `angle` (512 por vuelta) sobre su centro; con `clip`, solo lo
## que cae dentro del rectangulo.
func _draw_rotated(tex: Texture2D, center: Vector2, angle: float, clip: Rect2i) -> void:
	if tex == null:
		return
	var rot := fposmod(angle, 512.0) * TAU / 512.0
	if clip.size == Vector2i.ZERO:
		draw_set_transform(center, rot)
		draw_texture(tex, -tex.get_size() / 2)
		draw_set_transform(Vector2.ZERO)
		return
	# Recorte: se dibuja como poligono texturizado intersecado con el rectangulo.
	var half := tex.get_size() / 2
	var corners := PackedVector2Array([Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
			Vector2(half.x, half.y), Vector2(-half.x, half.y)])
	var uv := PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	var points := PackedVector2Array()
	for p in corners:
		points.append(center + p.rotated(rot))
	var clip_poly := PackedVector2Array([Vector2(clip.position), Vector2(clip.end.x, clip.position.y),
			Vector2(clip.end), Vector2(clip.position.x, clip.end.y)])
	var inv := Transform2D(rot, center).affine_inverse()
	for poly in Geometry2D.intersect_polygons(points, clip_poly):
		var puv := PackedVector2Array()
		for q in poly:
			puv.append((inv * q + half) / tex.get_size())
		draw_colored_polygon(poly, Color.WHITE, puv, tex)
