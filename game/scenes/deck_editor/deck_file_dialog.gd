extends PocDialog
## Ventana de Exportar / Importar mazo (deck_c/export.txt, import.txt).
## Lista de mazos guardados arriba, campo para el nombre abajo, y los botones del script
## dlg_export_ok/dlg_import_ok (137,187) y dlg_*_cancel (222,187), relativos a la ventana.
## Geometria interior medida sobre w_export_?.bmp de cada juego.
##
## Los mazos se guardan como .ydc (el formato del original) en saves/decks/, junto al
## ejecutable, para que la partida siga siendo portable.

## Lista y campo de nombre por juego: [lista, nombre]
const RECTS := {
	"yugi": [Rect2(68, 43, 228, 119), Rect2(68, 158, 228, 15)],
	"kaiba": [Rect2(76, 46, 212, 100), Rect2(76, 158, 224, 18)],
	"joey": [Rect2(52, 74, 222, 96), Rect2(50, 187, 232, 18)],
}
const ROW_H := 16.0
const MAX_NAME := 24

var mode := "export"          # "export" o "import"
var chosen_name := ""
var keep_after_confirm := false
var confirming := false
var _files: PackedStringArray = []
var _row := -1
var _scroll := 0
var _select_on: Texture2D
var _select_off: Texture2D
var _name := LineEdit.new()
var _list_rect: Rect2
var _name_rect: Rect2
var _text_offset := 10.0
var _text := Color.WHITE
var _text_selected := Color(1, 1, 0.6)


## Cuadro de 0x4587d0 desde sus scripts de deck_c: `kind` 3 = cargar repeticion
## (replay_load, dlg_replay_load_?, dlg_replay_cancel_?), 4 = guardar repeticion (replay_save,
## dlg_replay_save_?, dlg_replay_cancel_?). Cargar no deja escribir el nombre.
static func for_replay(game: String, kind: int, files: PackedStringArray) -> PocDialog:
	var dir := "%s/deck_c/" % game
	var bg_layout := Assets.layout(dir + ("replay_load.txt" if kind == 3 else "replay_save.txt"))
	var tex := func(layout: Layout, i: int) -> Texture2D: return Assets.texture(dir + layout.resource(i))
	var script: GDScript = load("res://scenes/deck_editor/deck_file_dialog.gd")
	var d: PocDialog = script.new(tex.call(bg_layout, 0), "import" if kind == 3 else "export", files,
			tex.call(bg_layout, 1), tex.call(bg_layout, 2), game)
	var ok := Assets.layout(dir + ("dlg_replay_load_?.txt" if kind == 3 else "dlg_replay_save_?.txt"))
	var cancel := Assets.layout(dir + "dlg_replay_cancel_?.txt")
	d.add_button("ok", Vector2(ok.position(0)), tex.call(ok, 0), tex.call(ok, 1))
	d.add_button("cancel", Vector2(cancel.position(0)), tex.call(cancel, 0), tex.call(cancel, 1))
	return d


func _init(bg: Texture2D, mode_id: String, files: PackedStringArray, select_on: Texture2D,
		select_off: Texture2D, game: String) -> void:
	super(bg)
	_list_rect = RECTS[game][0]
	_name_rect = RECTS[game][1]
	if game == "joey":   # ventanas de papel blanco
		_text = Color8(24, 24, 24)
		_text_selected = Color8(16, 16, 16)
	_text_offset = 8.0 if game == "kaiba" else 10.0
	mode = mode_id
	_files = files
	_select_on = select_on
	_select_off = select_off


func _ready() -> void:
	# sin margenes: el campo debe medir lo mismo que el recuadro del original (18 px); si
	# crece, invade los botones y se queda con sus clics
	var empty := StyleBoxEmpty.new()
	empty.set_content_margin_all(0)
	for style in ["normal", "focus", "read_only"]:
		_name.add_theme_stylebox_override(style, empty)
	_name.add_theme_font_override("font", _font)
	_name.add_theme_font_size_override("font_size", 12)
	_name.add_theme_color_override("font_color", _text)
	_name.add_theme_color_override("caret_color", _text)
	_name.position = _name_rect.position + Vector2(4, 0)
	_name.size = _name_rect.size - Vector2(8, 0)
	_name.max_length = MAX_NAME
	_name.editable = mode == "export"
	_name.text_submitted.connect(func(_t: String) -> void: _confirm())
	add_child(_name)
	# LineEdit no baja de la altura de su fuente: se centra a mano en el recuadro
	_name.size = Vector2(_name_rect.size.x - 8, 0)
	_name.position.y = _name_rect.get_center().y - _name.get_combined_minimum_size().y / 2.0
	if mode == "export":
		_name.grab_focus()


func _draw() -> void:
	super()
	if not native_accepts_input(): return
	for i in range(_scroll, mini(_files.size(), _scroll + _visible_rows())):
		var y := _list_rect.position.y + (i - _scroll) * ROW_H
		var active := i == _row
		if active:
			var marker := _select_on if not _name.has_focus() else _select_off
			var half := marker.get_width() / 2.0
			var text_width := _font.get_string_size(_files[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
			draw_texture_rect_region(marker, Rect2(_list_rect.position.x + 2, y + 1, half, marker.get_height()), Rect2(0,0,half,marker.get_height()))
			draw_texture_rect_region(marker, Rect2(_list_rect.position.x + _text_offset + text_width + 2, y + 1, half, marker.get_height()), Rect2(half,0,half,marker.get_height()))
		draw_string(_font, Vector2(_list_rect.position.x + _text_offset, y + 13), _files[i],
				HORIZONTAL_ALIGNMENT_LEFT, _list_rect.size.x - _text_offset - 4, 12,
				_text_selected if active else _text)



func _visible_rows() -> int:
	return int(_list_rect.size.y / ROW_H)


func _select_row(i: int) -> void:
	_row = clampi(i, 0, _files.size() - 1)
	if _row < _scroll:
		_scroll = _row
	elif _row >= _scroll + _visible_rows():
		_scroll = _row - _visible_rows() + 1
	_name.text = _files[_row]
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if confirming:
		get_viewport().set_input_as_handled()
		return
	if not native_accepts_input():
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_up") and not _files.is_empty():
		_select_row(_row - 1 if _row > 0 else 0)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_down") and not _files.is_empty():
		_select_row(_row + 1)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed:
		var local: Vector2 = event.position - position
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var step := -1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1
			_scroll = clampi(_scroll + step, 0, maxi(0, _files.size() - _visible_rows()))
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
		if event.button_index == MOUSE_BUTTON_LEFT and _list_rect.has_point(local):
			var i := _scroll + int((local.y - _list_rect.position.y) / ROW_H)
			if i < _files.size():
				if i == _row and event.double_click:
					_confirm()
				else:
					_select_row(i)
			get_viewport().set_input_as_handled()
			return
	super(event)


func _close(index: int) -> void:
	if buttons[index]["id"] == "ok":
		_confirm()
	else:
		super(index)


func _confirm() -> void:
	chosen_name = _clean(_name.text)
	if chosen_name == "":
		return
	if keep_after_confirm:
		confirming = true
		_name.release_focus()
		_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
		closed.emit("ok")
		return
	if native_editor:
		_begin_native_close("ok")
		return
	closed.emit("ok")
	queue_free()


## Solo letras, numeros, espacio, guion y guion bajo: el nombre es el del archivo.
static func _clean(text: String) -> String:
	var out := ""
	for ch in text.strip_edges():
		if ch.is_valid_identifier() or ch.is_valid_int() or ch in " -_":
			out += ch
	return out.strip_edges()
