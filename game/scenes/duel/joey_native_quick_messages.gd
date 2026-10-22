extends Node2D
## Joey48da50/48dcd0: globos LAN con nombre azul, 32 ticks y cierre inmediato.
## El mismo popup48c1b0/48c5b0 del tutorial: Arial24GDI, ancho-64,
## x260/y500 local, x260/y100 remoto, colas popup.txt9/8 centradas abajo/arriba.
const DIR := "joey/tutorial/"
var timers := [0, 0]
var _labels: Array[RichTextLabel] = []
var _layout: Layout
var _bubble := [0, 0]
var _top := [0.0, 0.0]
var _clock := 0.0
func _ready() -> void:
	z_index = 86
	_layout = Assets.layout(DIR + "popup.txt")
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial"])
	for side in 2:
		var text := RichTextLabel.new()
		text.bbcode_enabled = true
		text.size.x = Assets.texture(DIR + _layout.resource(0)).get_width() - 64
		text.fit_content = true
		text.scroll_active = false
		text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text.add_theme_font_override("normal_font", font)
		text.add_theme_font_size_override("normal_font_size", 21)
		text.add_theme_constant_override("line_separation", 2)
		text.add_theme_color_override("default_color", Color("080808"))
		text.hide()
		add_child(text)
		_labels.append(text)
func show_message(side: int, message_id: int, player_name: String) -> void:
	if side not in [0, 1]: return
	var dialogs: Variant = Assets.dialog_texts()
	if dialogs is not Array or message_id < 0 or message_id >= dialogs.size(): return
	# Names are literal text, never BBCode markup.
	var name := player_name.replace("[", "[lb]")
	var body := str(dialogs[message_id]).replace("<BR>", "\n")
	body = RegEx.create_from_string("@[0-9]|<[^>]+>").sub(body, "", true).replace("[", "[lb]")
	_labels[side].text = "[color=#0000ff]" + name + "[/color]\n" + body
	_labels[side].visible_characters = 0
	_labels[side].show()
	timers[side] = 32
	_layout_message.call_deferred(side)
func _layout_message(side: int) -> void:
	var height := _labels[side].get_content_height()
	_bubble[side] = int(height > int(_layout.value(0))) + int(height > int(_layout.value(1)))
	var tex := Assets.texture(DIR + _layout.resource(_bubble[side]))
	var center := 500 if side == 0 else 100
	_top[side] = center - tex.get_height() / 2.0
	_labels[side].position = Vector2(292, center - height / 2.0)
	queue_redraw()
func advance_tick() -> void:
	for side in 2:
		if timers[side] == 0: continue
		timers[side] -= 1
		_labels[side].visible_characters += 4
		if timers[side] == 0: _labels[side].hide()
	queue_redraw()
func busy(side: int) -> bool:
	return side in [0, 1] and timers[side] > 0
func _process(delta: float) -> void:
	_clock += NativeClock.ticks(delta)
	while _clock >= 1:
		_clock -= 1
		advance_tick()
func _draw() -> void:
	if _layout == null: return
	for side in 2:
		if timers[side] == 0: continue
		var tex := Assets.texture(DIR + _layout.resource(_bubble[side]))
		var tail := Assets.texture(DIR + _layout.resource(9 if side == 0 else 8))
		draw_texture(tex, Vector2(260, _top[side]))
		draw_texture(tail, Vector2(260 + (tex.get_width() - tail.get_width()) / 2.0,
			_top[side] + (tex.get_height() - 2 if side == 0 else 2 - tail.get_height())))
