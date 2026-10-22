extends Node2D
## Escena 6 de la fabrica 0x464220 (vtable 0x59c95c): Yugi antes y despues del duelo.
## 0x40fc60 crea el objeto segun DAT_005af6f8: 0 = entrada (0x40fb10 -> 0x40f410,
## bust_up/start.txt), 1 = salida (0x40fb70 -> 0x40f620, win/lose/draw.txt segun 0x437400).
## La actualiza 0x40fbd0 cada fotograma; cuando el objeto acaba (+4 = 0) llama a 0x532390 y
## pasa a la escena DAT_005af6f4 (el menu pone 7 antes del duelo y 0x435410 pone 2 despues).
##
## El original compone en dos superficies de pantalla (0x40a140(1) y (2)) y en la imagen del
## fondo; aqui se recuerda que contiene cada una y se redibuja igual en cada fotograma.
## Contador +0x14 (entrada) / +0x10 (salida): +4 por fotograma; primero se actualiza y despues
## se dibuja con el contador ya sumado.
## 464490: la mascara compartida en modo3 pone su contador a256 y no dibuja fundido.
## PENDIENTE: transicion general532390(4b,16,0,256) entre escenas; es un barrido,
## independiente de esta mascara y no un fundido desde negro.

signal finished

const MOUTH := [0, 5, 6, 5]        # DAT_0059aac8 (entrada)
const END_MOUTH := [0, 6, 7, 6]    # DAT_0059aae8 (salida)

var game := "yugi"
var _dir := "yugi/bust_up/"
var ending := false
var winner := 0                    # 1 jugador, 2 CPU, 3 empate (0x437400)
var _layout: Layout
var _counter := 0
var _random := 0
var _voice := ""
var _voice_start := -1
var _frame := 0
var _clock := 0.0
var _done := false
## Deslizamientos y cortinillas mezclados entre ticks.
var _blend := NativeBlend.new()
var _cursor = preload("res://scenes/duel/duel_cursor_visual.gd").new()
# Contenido de las superficies del original.
var _screen2 := ""                 # superficie 2: lo que se copia a pantalla cada fotograma
var _back_has_yugi := false        # la imagen del fondo ya lleva lo compuesto en 0x80 / 4
var _fill: Variant = null           # color del pixel (0, 0) del fondo de la salida


## `end_winner` = 0 para la entrada; 1/2/3 para la salida tras el duelo.
func _init(game_id: String, end_winner := 0) -> void:
	game = game_id
	_dir = game + "/bust_up/"
	ending = end_winner != 0
	winner = end_winner


func _ready() -> void:
	add_child(_cursor)
	_cursor.update(get_local_mouse_position(), false)
	if ending:
		# 0x40f620: lose.txt si gana la CPU (Yugi celebra), draw.txt en empate, win.txt si no.
		var script: String = {2: "lose", 3: "draw"}.get(winner, "win")
		_layout = Assets.layout(_dir + script + ".txt")
		var base: int = {2: 0x10000052, 3: 0x10000055}.get(winner, 0x10000056)
		var count := _raw(0) % 1000
		_random = UiRandom.draw_mod(count)   # 0x40f708
		_voice = _end_voice_path(base)
	else:
		_layout = Assets.layout(_dir + "start.txt")
		_random = UiRandom.draw() % 3     # 0x40f410: FUN_00531140() % 3
		_voice = _start_voice_path()
	if _layout == null or _layout.items.is_empty():
		_done = true


## Tabla de sonidos 0x5ad3d0: id 0x1000001e + n = Yugi_(n + 1).wav.
static func _voice_path(id: int) -> String:
	return "yugi/voice/internal/yugi_%02d.wav" % (id - 0x1000001e + 1)


func _start_voice_path() -> String:
	return _voice_path(0x1000001e + _random)


func _end_voice_path(base: int) -> String:
	return _voice_path(base + _random)


func _raw(i: int) -> int:
	var v: Variant = _layout.value(i) if i < _layout.items.size() else null
	return 0 if v == null else str(v).to_int()


func _pos(i: int) -> Vector2:
	var v := _raw(i)
	return Vector2(v / 1000, v % 1000)


func _tex(i: int) -> Texture2D:
	return Assets.texture(_dir + _layout.resource(i))


func _process(delta: float) -> void:
	_cursor.advance(delta)
	# Tope de 4 pasos por fotograma: la carga de las imagenes no debe comerse la entrada.
	_clock = minf(_clock + NativeClock.ticks(delta), 4.0)
	while _clock >= 1.0 and not _done:
		_clock -= 1.0
		if ending:
			_update_end()
		else:
			_update_start()
		_frame += 1
		_blend.tick()
		# 0x40def0 / 0x40e5c0 dan el objeto por terminado al dibujar con este contador.
		_done = _counter > (0x1007f if ending else 0x100ff)
	_blend.fraction = _clock
	queue_redraw()
	if _done:
		set_process(false)
		finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var pos: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
		_cursor.update(pos, false, -1, PlatformInput.mouse_pressed(MOUSE_BUTTON_LEFT))
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_cursor.update(pos, false, -1, event.pressed)
			if event.pressed:
				_cursor.click(pos)
	get_viewport().set_input_as_handled()


func _voice_over() -> bool:
	# 40dc90/40e440 consultan583ed0: fin real del canal, no ticks de la animacion.
	return _voice_start >= 0 and Audio.sfx_finished(_voice)


func _play_voice() -> void:
	_voice_start = _frame
	Audio.play_sfx(_voice)


# --- entrada (0x40dc90 / 0x40def0) ---------------------------------------------------------

func _update_start() -> void:
	var c := _counter
	if c == 0:
		_screen2 = "bg"                        # superficie 2 <- start_0
	if c == 0x80:
		# Superficie 1: fondo + start_1 + Yugi + bocadillo; el fondo y la 2: sin start_1.
		_back_has_yugi = true
		_screen2 = "back"
		_play_voice()
	if c < 0x10000:
		if c > 0x180 and _voice_over():
			_counter = 0x10000
			return
	elif (c & 0xf) == 0:
		# Parpadeo de start_1: la superficie 2 alterna entre el fondo y la superficie 1.
		_screen2 = "back" if (c & 0x10) != 0 else "flash"
	_counter += 4


func _draw_start() -> void:
	var c := _counter
	var yugi := _pos(2)
	var speech := 7 + _random
	_draw_tex(_tex(0), Vector2.ZERO)
	if _screen2 == "flash":
		_draw_tex(_tex(1), Vector2.ZERO)
	if _screen2 in ["back", "flash"]:
		_draw_tex(_tex(2), yugi)
		_draw_tex(_tex(speech), Vector2.ZERO)
	var x: float = _blend.at("yugi", yugi.x + maxi(0, (0x60 - c) * 0x10))
	var origin := Vector2(x, yugi.y)
	if c <= 0x80:
		_draw_tex(_tex(2), origin)
	if c >= 0x80:
		var eyes := 3 if c == 0x80 else 4
		_draw_tex(_tex(eyes), origin + _pos(eyes))
	var mouth: int = MOUTH[(c >> 3) & 3]
	if mouth != 0 and c < 0x10000:
		_draw_tex(_tex(mouth), origin + _pos(mouth))


# --- salida (0x40e440 / 0x40e5c0) ----------------------------------------------------------

func _update_end() -> void:
	var c := _counter
	if c == 4:
		_screen2 = "back"                      # superficie 2 <- fondo; despues fondo += YUGI
	if c == 0x40:
		_back_has_yugi = true
		_screen2 = "back"                      # ahora con el rotulo YUGI compuesto
	if c == 0x60:
		_screen2 = "all"                       # superficie 2 <- ALL + bocadillo
		_play_voice()
	if c > 0x1e0 and c < 0x10000 and _voice_over():
		_counter = 0x10000
	_counter += 4


func _draw_end() -> void:
	var c := _counter
	var back := _tex(0)
	if c == 4:
		# 0x4835e0(0, 0): se rellena la pantalla con el color del pixel (0, 0) del fondo.
		draw_rect(Rect2(0, 0, 800, 600), _corner_color(back))
		return
	_draw_surface2()
	var mask := _tex(1)
	var mask_pos := _pos(1)
	var h := mask.get_height() if mask != null else 0
	var shift := (c - 4) * 0x10
	if c <= 0x20:
		# Cortinilla: franja rellena a la izquierda de la mascara, que barre hacia la izquierda.
		var x: float = _blend.at("curtain", int(mask_pos.x) - 2 * shift)
		if x + 1 > 0:
			draw_rect(Rect2(0, mask_pos.y, x + 1, h), _corner_color(back))
		_draw_tex(mask, Vector2(x, mask_pos.y))
	if c <= 0x40:
		var off: float = _blend.at("off", mini(0, shift - 800))
		var top := Rect2(0, 0, 800, mask_pos.y)
		var mid := Rect2(0, mask_pos.y, 800, h)
		var bottom := Rect2(0, mask_pos.y + h, 800, 600 - mask_pos.y - h)
		_draw_back_part(top, off)
		_draw_part(_tex(2), mid, off)
		_draw_back_part(bottom, off)
	var yugi := Vector2.ZERO
	if c >= 0x40:
		yugi = _blend.at("yugi_end", _pos(3) + Vector2(mini(0, (c - 0x40) * 0x10 - 0x1f4), 0))
		if c <= 0x60:
			_draw_tex(_tex(3), yugi)
	if c >= 0x60:
		var eyes := 4 + int(c != 0x60)
		_draw_tex(_tex(eyes), yugi + _pos(eyes))
		var mouth: int = END_MOUTH[(c >> 3) & 3]
		if mouth != 0 and c < 0x10000:
			_draw_tex(_tex(mouth), yugi + _pos(mouth))


func _draw_surface2() -> void:
	match _screen2:
		"back":
			_draw_tex(_tex(0), Vector2.ZERO)
			if _back_has_yugi:
				_draw_tex(_tex(2), Vector2.ZERO)
		"all":
			_draw_tex(_tex(8), Vector2.ZERO)
			_draw_tex(_tex(9 + _random), _pos(9 + _random))


## Parte `rect` del fondo (con el rotulo si ya esta compuesto) desplazada `off` en x.
func _draw_back_part(rect: Rect2, off: float) -> void:
	_draw_part(_tex(0), rect, off)
	if _back_has_yugi or _counter > 4:
		_draw_part(_tex(2), rect, off)


func _draw_part(tex: Texture2D, rect: Rect2, off: float) -> void:
	if tex == null or rect.size.x <= 0 or rect.size.y <= 0:
		return
	draw_texture_rect_region(tex, Rect2(rect.position + Vector2(off, 0), rect.size), rect)


func _corner_color(tex: Texture2D) -> Color:
	if _fill == null:
		_fill = tex.get_image().get_pixel(0, 0) if tex != null else Color.BLACK
	return _fill


func _draw_tex(tex: Texture2D, pos: Vector2) -> void:
	if tex != null:
		draw_texture(tex, pos)


func _draw() -> void:
	if _layout == null or _layout.items.is_empty():
		return
	if ending:
		_draw_end()
	else:
		_draw_start()
