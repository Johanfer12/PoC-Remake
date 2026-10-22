extends Node2D
## Menu del tutorial de Yugi: 469550 (entrada), 469140 (raton), 469040 (teclado),
## 469290 (dibujo), 4695c0 (eleccion). Cuatro lecciones, seguidas del boton END.
## Retrato: 468070/4688b0; globo de ayuda: 468470/468570, mensajes 105e..1061.
## Textos progresivos compartidos con las lecciones (467fd0/45d580).

const DIR := "yugi/tutorial/"
var selected := -1
var ticks := 0
var _clock := 0.0
var _layout: Layout
var _text: RichTextLabel
var _overlay: Node2D
var _cursor: Node2D
var _mouse := Vector2(-1, -1)

func _ready() -> void:
	_layout = Assets.layout(DIR + "menu.txt")
	_overlay = preload("res://scenes/duel/tutorial_overlay.gd").new()
	add_child(_overlay)
	_overlay.talking_enabled = false # Solo4682c0 (scene9) enlaza la boca con el texto.
	_text = _overlay._text
	_overlay.event({"kind": "tutorial_portrait", "side": 0, "visible": true})
	_cursor = preload("res://scenes/duel/duel_cursor_visual.gd").new()
	_cursor.z_index = 4000
	add_child(_cursor)
	_mouse = get_local_mouse_position()
	_cursor.update(_mouse, false, -1, false)
	Audio.play_music("yugi/voice/stream/tutomenu.wav")
	_warp(0) # 469550 -> 469000(0): primer boton con offset 64,32, solo con el teclado.
	queue_redraw()

func button_rect(index: int) -> Rect2:
	var item := index + 5
	return Rect2(Vector2(_layout.position(item)), Assets.texture(DIR + _layout.resource(item)).get_size())

func _hit(pos: Vector2) -> int:
	for i in 5:
		if button_rect(i).has_point(pos): return i
	return -1

## 469000 -> 4600f0: el puntero va al boton solo si se esta usando el teclado; el boton se
## elige en el tick siguiente por el destino (469140).
func _warp(index: int) -> void:
	PointerGlide.request(_mouse, Vector2(_layout.position(index + 5)) + Vector2(64, 32))

func _select(index: int) -> void:
	if selected == index: return
	selected = index
	if index in [0, 1, 2, 3]:
		_overlay.event({"kind": "tutorial_bubble", "text": 0x105e + index, "position": 0 if index < 2 else 1, "manual": false})
		_overlay._tail = -1 if index < 2 else 1
	else:
		_overlay.event({"kind": "tutorial_bubble_close"})
	queue_redraw()

func _process(delta: float) -> void:
	_clock += NativeClock.ticks(delta)
	while _clock >= 1:
		_clock -= 1
		ticks += 1
		var moved := PointerGlide.step(self, _mouse)
		if moved != _mouse:
			_mouse = moved
			_cursor.update(_mouse, selected >= 0, -1, false)
		# 469140, con DAT_005aed18 > 0xf: boton bajo el puntero o bajo su destino.
		if ticks > 15:
			_select(_hit(PointerGlide.hover(_mouse)))
	_overlay.advance(delta)
	_cursor.advance(delta)
	queue_redraw()

func _draw() -> void:
	if _layout == null: return
	_image(_layout, 0, Vector2.ZERO)
	for i in 4: _image(_layout, i + 1, Vector2(_layout.position(i + 1)))
	if selected >= 0: _image(_layout, selected + 5, Vector2(_layout.position(selected + 5)))

func _image(layout: Layout, index: int, pos: Vector2) -> void:
	draw_texture(Assets.texture(DIR + layout.resource(index)), pos)

func _activate() -> void:
	if selected < 0 or ticks <= 15 or _overlay.busy(): return
	Audio.stop_music()
	if selected == 4:
		Game.open_title("yugi", "tutorial")
	else:
		Game.open_duel_replay("yugi", "lesson:%d" % (selected + 1))

func _unhandled_input(event: InputEvent) -> void:
	if ticks <= 15: return
	if event is InputEventMouseMotion:
		_mouse = event.position
		_select(_hit(PointerGlide.hover(_mouse)))
		_cursor.update(event.position, selected >= 0, -1, false)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse = event.position
		_select(_hit(PointerGlide.hover(_mouse)))
		_cursor.update(event.position, selected >= 0, -1, event.pressed)
		if event.pressed:
			_cursor.click(event.position)
			_activate()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		_warp(maxi(0, selected - 1))
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		_warp(mini(4, selected + 1))
	elif event.is_action_pressed("ui_accept"):
		if selected < 0: _warp(0)
		else: _activate()
