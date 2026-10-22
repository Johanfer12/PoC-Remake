extends PocDialog
## Y454b60/450700 y Ka456600/452170/44fd60: aviso con vista y control propios.
var _body := RichTextLabel.new()
var _scroll: NativeScrollBar
var _height := -1
var _contents: PackedStringArray
var _game := "yugi"
var _view_height := 102

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
	_scroll.scrolled.connect(func(value: int) -> void: _body.position.y = -value)
	add_child(_scroll)

func _process(_delta: float) -> void:
	var height := _body.get_content_height()
	if height != _height:
		_height = height
		_scroll.set_range(height - _view_height)

func _unhandled_input(event: InputEvent) -> void:
	if not native_accepts_input():
		get_viewport().set_input_as_handled()
		return
	if _game in ["kaiba", "joey"] and event is InputEventKey and event.pressed:
		var step: int = {KEY_UP: -1, KEY_DOWN: 1, KEY_PAGEUP: -_scroll.step, KEY_PAGEDOWN: _scroll.step}.get(event.keycode, 0)
		if step != 0:
			_scroll.set_value(_scroll.value + step)
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		_scroll.set_value(_scroll.value + (-_scroll.step if event.button_index == MOUSE_BUTTON_WHEEL_UP else _scroll.step))
		get_viewport().set_input_as_handled()
		return
	if _scroll.handle(event):
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)
