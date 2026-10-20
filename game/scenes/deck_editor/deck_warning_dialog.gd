extends PocDialog
## Y454b60/450700 y Ka456600/452170/44fd60: aviso con vista y control propios.
var _body := RichTextLabel.new()
var _scroll: NativeScrollBar
var _height := -1
var _contents: PackedStringArray
var _game := "yugi"
var _view_height := 102
var _held_keys := 0
var _key_clock := 0.0

func _init(bg: Texture2D, top_left: Vector2, contents: PackedStringArray, game := "yugi") -> void:
	super(bg, top_left)
	_contents = contents
	_game = game
	_view_height = 102 if game == "yugi" else 97

func _ready() -> void:
	var clip := Control.new()
	clip.position = {"yugi": Vector2(53, 45), "kaiba": Vector2(100, 60), "joey": Vector2(103, 98)}[_game]
	clip.size = Vector2({"yugi": 223, "kaiba": 215, "joey": 220}[_game], _view_height)
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(clip)
	_body.custom_minimum_size.x = clip.size.x
	_body.size.x = clip.size.x
	_body.fit_content = true
	_body.scroll_active = false
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_theme_font_override("normal_font", _font)
	_body.add_theme_font_size_override("normal_font_size", 14 if _game == "joey" else 13)
	_body.add_theme_color_override("default_color", Color8(16, 16, 16) if _game == "joey" else text_color)
	_body.text = "\n".join(_contents)
	clip.add_child(_body)
	_scroll = NativeScrollBar.new(_game, "bar_warning", _game == "kaiba")
	_scroll.position = Vector2(309, 54) if _game == "kaiba" else Vector2(283, 41)
	_scroll.track = {"yugi": 80, "kaiba": 0, "joey": 128}[_game]
	# Jo41c1e0 y5be820 no inicializan +60. No propagar bytes indeterminados de heap.
	# El desplazamiento definido de Joey son las flechas verticales de un píxel.
	if _game == "joey": _scroll.step = 0
	_scroll.scrolled.connect(func(value: int) -> void: _body.position.y = -value)
	add_child(_scroll)

func _process(delta: float) -> void:
	var height := _body.get_content_height()
	if height != _height:
		_height = height
		_scroll.set_range(height - _view_height)
	_key_clock += NativeClock.ticks(delta)
	while _key_clock >= 1.0:
		_key_clock -= 1.0
		_scroll_keys() # La lectura de flechas está fuera del bloque de botones/fase2 del PE.


## Y447bd0/Ka4491b0/Jo474fc0: derecha, izquierda, arriba y abajo, en ese orden.
## Se consulta el estado sostenido cada tick, sin depender de la repetición de Windows.
func _scroll_keys() -> void:
	if _scroll.maximum <= 0: return
	if _held_keys & 8: _scroll.set_value(_scroll.value + _scroll.step)
	if _held_keys & 4: _scroll.set_value(_scroll.value - _scroll.step)
	if _held_keys & 1: _scroll.set_value(_scroll.value - 1)
	if _held_keys & 2: _scroll.set_value(_scroll.value + 1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var mask: int = (preload("res://core/duel_input.gd").slots(event, _game) >> 1) & 15
		if mask:
			if event.pressed: _held_keys |= mask
			else: _held_keys &= ~mask
			get_viewport().set_input_as_handled()
			return
	if not native_accepts_input():
		get_viewport().set_input_as_handled()
		return
	if _scroll.handle(event):
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)
