extends Node2D
## Ka46b730/46b960, entrada46b500, dibujo46b420, raton46b7c0 y teclado46b320.
const DIR := "kaiba/tutorial/"
var selected := -1
var ticks := 0
var _intro_c := 0
var _clock := 0.0
var _blend := NativeBlend.new()   # contornos de la entrada entre ticks
var _layout: Layout
var _overlay: Node2D
var _text: RichTextLabel
var _cursor: Node2D
var _mouse := Vector2(-1, -1)

func _ready() -> void:
	_layout = Assets.layout(DIR + "menu.txt")
	_overlay = preload("res://scenes/duel/tutorial_overlay_kaiba.gd").new()
	add_child(_overlay)
	_text = _overlay._text
	_overlay.event({"kind": "tutorial_portrait", "side": 0, "visible": true})
	_help(0x10ae)
	_cursor = preload("res://scenes/duel/duel_cursor_visual.gd").new()
	_cursor.z_index = 4000
	add_child(_cursor)
	_mouse = get_local_mouse_position()
	_cursor.update(_mouse, false, -1, false)
	Audio.play_music("kaiba/voice/stream/m_tutome.wav")

func _help(id: int) -> void:
	_overlay.event({"kind": "tutorial_bubble", "text": id, "position": 0, "manual": false})
	_overlay._at = Vector2(200, 484)
	_overlay._tail = 0
	_overlay._layout_bubble.call_deferred()

func button_rect(index: int) -> Rect2:
	var item := index + 4
	return Rect2(Vector2(_layout.position(item)), Assets.texture(DIR + _layout.resource(item)).get_size())

func _hit(pos: Vector2) -> int:
	for i in 7:
		if button_rect(i).has_point(pos): return i
	return -1

func _select(index: int) -> void:
	if selected == index: return
	selected = index
	if index in range(6): _help(0x10b0 + index)
	queue_redraw()

## Ka46b2b0 -> 462270 (= Yugi 4600f0): al centro del boton solo si se esta usando el
## teclado; el boton se elige en el tick siguiente por el destino (46b7c0).
func _warp(index: int) -> void:
	PointerGlide.request(_mouse, button_rect(index).get_center().floor())

func _process(delta: float) -> void:
	_clock += NativeClock.ticks(delta)
	while _clock >= 1:
		_clock -= 1
		ticks += 1
		var moved := PointerGlide.step(self, _mouse)
		if moved != _mouse:
			_mouse = moved
			_cursor.update(_mouse, selected >= 0, -1, false)
		# 46b7c0, con DAT_005b1d38 > 0xf: boton bajo el puntero o bajo su destino.
		if _intro_c == 256 and ticks > 15:
			_select(_hit(PointerGlide.hover(_mouse)))
		_blend.tick()
		if _intro_c < 128: _intro_c += 8
		elif _intro_c == 128:
			_intro_c = 256
			_warp(0)
	_blend.fraction = _clock
	_overlay.advance(delta)
	_cursor.advance(delta)
	queue_redraw()

func _image(index: int, pos: Vector2) -> void:
	draw_texture(Assets.texture(DIR + _layout.resource(index)), pos)

func _outline(start: Rect2, end: Rect2, t: float) -> void:
	# Ka416490 interpola los cuatro bordes, divide256 truncando hacia cero.
	var left := int((start.position.x * (256 - t) + end.position.x * t) / 256)
	var top := int((start.position.y * (256 - t) + end.position.y * t) / 256)
	var right := int((start.end.x * (256 - t) + end.end.x * t) / 256)
	var bottom := int((start.end.y * (256 - t) + end.end.y * t) / 256)
	draw_rect(Rect2(left, top, right - left, 1), Color.WHITE)
	draw_rect(Rect2(left, bottom - 1, right - left, 1), Color.WHITE)
	draw_rect(Rect2(left, top, 1, bottom - top), Color.WHITE)
	draw_rect(Rect2(right - 1, top, 1, bottom - top), Color.WHITE)

func _draw() -> void:
	if _layout == null: return
	_image(0, Vector2.ZERO)
	if _intro_c < 256:
		_image(10, Vector2(_layout.position(10)))
		if (_intro_c & 16) != 0: _image(2, Vector2(_layout.position(2)))
		if _intro_c > 64:
			var from := Rect2(Vector2(_layout.position(2)), Assets.texture(DIR + _layout.resource(2)).get_size())
			var to := Rect2(Vector2(_layout.position(1)), Assets.texture(DIR + _layout.resource(1)).get_size())
			var t: float = _blend.at("outline", _intro_c * 4 - 256)
			_outline(from, to, t)
			if t > 32: _outline(from, to, t - 32)
			if t > 64: _outline(from, to, t - 64)
		if _intro_c == 128: _image(1, Vector2(_layout.position(1)))
		return
	_image(1, Vector2(_layout.position(1)))
	if selected in range(6):
		_image(3, Vector2(_layout.position(selected + 4) - _layout.position(3)))
	for i in 6: _image(i + 4, Vector2(_layout.position(i + 4)))
	_image(11 if selected == 6 else 10, Vector2(_layout.position(10)))

func _activate() -> void:
	if _intro_c != 256 or selected < 0: return
	if selected == 6:
		Game.open_title("kaiba", "tutorial")
	elif not _overlay.busy():
		Game.open_duel_replay("kaiba", "lesson:%d" % (selected + 1))

func _unhandled_input(event: InputEvent) -> void:
	if _intro_c != 256: return
	if event is InputEventMouseMotion:
		_mouse = event.position
		_select(_hit(PointerGlide.hover(_mouse)))
		_cursor.update(_mouse, selected >= 0, -1, false)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse = event.position
		_select(_hit(PointerGlide.hover(_mouse)))
		_cursor.update(_mouse, selected >= 0, -1, event.pressed)
		if event.pressed:
			_cursor.click(_mouse)
			if _overlay.busy(): _overlay.accept()
			_activate()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		_warp(maxi(0, selected - 1))
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		_warp(mini(6, selected + 1))
	elif event.is_action_pressed("ui_accept"):
		if selected < 0: _warp(0)
		elif _overlay.busy(): _overlay.accept()
		else: _activate()
	get_viewport().set_input_as_handled()
