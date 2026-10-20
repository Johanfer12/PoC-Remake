extends Node2D
## Botones propios del selector: ajustes y sonido abajo a la izquierda, salir a la derecha.
## Medallones dorados. La
## configuracion abre un panel con el volumen y el silencio de la musica del selector.
## La eleccion se guarda en la partida (SaveData.data["launcher"]) y se recupera al abrir.

signal changed
signal exit_requested

const RADIUS := 24.0
const MARGIN := 18.0
const ICON_SIZE := 22.0
const GOLD := Color(1.0, 0.82, 0.3)
const GOLD_LIGHT := Color(1.0, 0.95, 0.7)
const GOLD_DARK := Color(0.42, 0.27, 0.06)
const BRONZE := Color(0.62, 0.43, 0.12)
const STONE := Color(0.07, 0.05, 0.04)
const OUTLINE := Color(0.35, 0.08, 0.02)
const PANEL_SIZE := Vector2(430, 236)
const SLIDER_W := 200.0
const KEY_STEP := 0.05

# Iconos de linea estilo Feather (viewBox 24), trazo blanco para tintarlos al dibujar.
const SVG_HEAD := "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='#ffffff' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>"
const SVG_SOUND := SVG_HEAD + "<polygon points='11 5 6 9 2 9 2 15 6 15 11 19 11 5'/><path d='M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07'/></svg>"
const SVG_MUTED := SVG_HEAD + "<polygon points='11 5 6 9 2 9 2 15 6 15 11 19 11 5'/><line x1='23' y1='9' x2='17' y2='15'/><line x1='17' y1='9' x2='23' y2='15'/></svg>"
const SVG_GEAR := SVG_HEAD + "<circle cx='12' cy='12' r='3'/><path d='M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z'/></svg>"
const SVG_CLOSE := SVG_HEAD + "<line x1='18' y1='6' x2='6' y2='18'/><line x1='6' y1='6' x2='18' y2='18'/></svg>"
const SVG_CHECK := SVG_HEAD + "<polyline points='20 6 9 17 4 12'/></svg>"
const SVG_EXIT := SVG_HEAD + "<path d='M18.36 6.64a9 9 0 1 1-12.73 0'/><line x1='12' y1='2' x2='12' y2='12'/></svg>"

const DEFAULT_VOLUME := 0.5
var volume := DEFAULT_VOLUME
var muted := false
var panel_open := false

var _icons := {}             # nombre -> {tex, offset} (offset = centrado optico medido)
var _hover := ""             # "sound", "settings", "close", "slider", "mute"
var _dragging := false
var _time := 0.0
var _font := ThemeDB.fallback_font


func _ready() -> void:
	z_index = 10
	var saved: Dictionary = SaveData.data.get("launcher", {})
	volume = clampf(float(saved.get("music_volume", DEFAULT_VOLUME)), 0.0, 1.0)
	muted = bool(saved.get("music_muted", false))
	for pair in [["sound", SVG_SOUND], ["muted", SVG_MUTED], ["gear", SVG_GEAR],
			["close", SVG_CLOSE], ["check", SVG_CHECK], ["exit", SVG_EXIT]]:
		_icons[pair[0]] = _rasterize(pair[1])


## Volumen efectivo de la musica (0..1).
func level() -> float:
	return 0.0 if muted else volume


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


# --- geometria -----------------------------------------------------------------------------

## Pantalla visible: el selector se estira al ancho del monitor (aspecto EXPAND), asi que los
## botones van a las esquinas reales y el panel al centro real.
func _screen() -> Vector2:
	return get_viewport_rect().size


func _sound_center() -> Vector2:
	return _settings_center() + Vector2(RADIUS * 2.0 + 14.0, 0)


func _exit_center() -> Vector2:
	return Vector2(_screen().x - MARGIN - RADIUS, _screen().y - MARGIN - RADIUS)


func _settings_center() -> Vector2:
	return Vector2(MARGIN + RADIUS, _screen().y - MARGIN - RADIUS)


func _panel_rect() -> Rect2:
	return Rect2((_screen() - PANEL_SIZE) / 2.0, PANEL_SIZE)


func _close_center() -> Vector2:
	var r := _panel_rect()
	return Vector2(r.end.x - 22, r.position.y + 22)


func _slider_rect() -> Rect2:
	var r := _panel_rect()
	return Rect2(r.position.x + 140, r.position.y + 92, SLIDER_W, 8)


func _mute_rect() -> Rect2:
	var r := _panel_rect()
	return Rect2(r.position.x + 140, r.position.y + 136, 22, 22)


func _language_rect() -> Rect2:
	var r := _panel_rect()
	return Rect2(r.position + Vector2(140, 182), Vector2(220, 30))


func _hit(pos: Vector2) -> String:
	if panel_open:
		if pos.distance_to(_close_center()) <= 16:
			return "close"
		if _slider_rect().grow_individual(8, 12, 8, 12).has_point(pos):
			return "slider"
		if _mute_rect().grow(4).has_point(pos):
			return "mute"
		if _language_rect().has_point(pos):
			return "language"
		return "panel" if _panel_rect().has_point(pos) else "outside"
	if pos.distance_to(_sound_center()) <= RADIUS:
		return "sound"
	if pos.distance_to(_settings_center()) <= RADIUS:
		return "settings"
	if pos.distance_to(_exit_center()) <= RADIUS:
		return "exit"
	return ""


# --- entrada -------------------------------------------------------------------------------

## _input: va antes que el _unhandled_input del selector, que asi no mueve la seleccion
## ni abre un juego mientras se usan estos botones o el panel.
func _input(event: InputEvent) -> void:
	var local_pos := Vector2.ZERO
	if event is InputEventMouse:
		local_pos = get_global_transform_with_canvas().affine_inverse() * event.position
	if event is InputEventMouseMotion:
		_hover = _hit(local_pos)
		if _dragging:
			_set_volume_from(local_pos.x)
		if panel_open or _hover != "":
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			if _dragging:
				_dragging = false
				_save()
			if panel_open:
				get_viewport().set_input_as_handled()
			return
		match _hit(local_pos):
			"sound":
				_toggle_mute()
			"settings":
				_open_panel(true)
			"exit":
				exit_requested.emit()
			"close", "outside":
				_open_panel(false)
			"slider":
				_dragging = true
				_set_volume_from(local_pos.x)
			"mute":
				_toggle_mute()
			"language":
				_cycle_language()
			"panel":
				pass
			_:
				return
		get_viewport().set_input_as_handled()
		return
	if not panel_open:
		return
	# Con el panel abierto se consume todo el teclado.
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		_open_panel(false)
	elif event.is_action_pressed("ui_left"):
		_set_volume(volume - KEY_STEP)
		_save()
	elif event.is_action_pressed("ui_right"):
		_set_volume(volume + KEY_STEP)
		_save()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_L:
		_cycle_language()
	get_viewport().set_input_as_handled()


func _cycle_language() -> void:
	var languages := Assets.LANGUAGES.keys()
	var next := (languages.find(Assets.lang) + 1) % languages.size()
	Assets.remember_language(languages[next])
	changed.emit()
	queue_redraw()


func _open_panel(open: bool) -> void:
	panel_open = open
	_dragging = false
	_hover = ""


func _toggle_mute() -> void:
	muted = not muted
	_save()


func _set_volume_from(x: float) -> void:
	var r := _slider_rect()
	_set_volume((x - r.position.x) / r.size.x)


func _set_volume(v: float) -> void:
	volume = snappedf(clampf(v, 0.0, 1.0), 0.01)
	# Subir el volumen desde el panel quita el silencio, como en cualquier mezclador.
	if volume > 0.0 and muted:
		muted = false
	changed.emit()


func _save() -> void:
	SaveData.data["launcher"] = {"music_volume": volume, "music_muted": muted}
	if Paths.has_data():
		SaveData.save()
	changed.emit()


# --- dibujo --------------------------------------------------------------------------------

func _draw() -> void:
	_medallion(_settings_center(), RADIUS, "gear", _hover == "settings" or panel_open)
	_medallion(_sound_center(), RADIUS, "muted" if muted else "sound", _hover == "sound")
	_medallion(_exit_center(), RADIUS, "exit", _hover == "exit")
	if _hover == "exit" and not panel_open:
		var text: String = {"s": "Salir", "e": "Exit", "g": "Beenden", "f": "Quitter", "i": "Esci", "j": "終了"}.get(Assets.lang, "Exit")
		var width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
		_label(text, _exit_center() + Vector2(-width / 2.0, -RADIUS - 10))
	if panel_open:
		_draw_panel()


## Medallon dorado: sombra, aro de oro con bisel y brillo superior, fondo de piedra oscura.
func _medallion(c: Vector2, r: float, icon: String, hot: bool) -> void:
	var s := r * (1.08 if hot else 1.0)
	if hot:
		for k in 4:
			draw_circle(c, s + 10 - k * 2.5, Color(GOLD, 0.06 + k * 0.04))
	draw_circle(c + Vector2(2, 3), s, Color(0, 0, 0, 0.55))
	draw_circle(c, s, GOLD_DARK)
	draw_circle(c, s - 1.5, GOLD if hot else BRONZE.lerp(GOLD, 0.6))
	draw_circle(c, s - 4.5, GOLD_DARK)
	draw_circle(c, s - 6.0, STONE)
	draw_arc(c, s - 3.0, PI * 1.15, PI * 1.85, 16, Color(GOLD_LIGHT, 0.85), 1.5, true)
	draw_arc(c, s - 8.5, PI * 0.15, PI * 0.85, 16, Color(GOLD, 0.18), 3.0, true)
	_draw_icon(icon, c, ICON_SIZE * (1.08 if hot else 1.0), GOLD_LIGHT if hot else GOLD)


func _draw_icon(name: String, center: Vector2, size: float, color: Color) -> void:
	var icon: Dictionary = _icons[name]
	var tex: Texture2D = icon["tex"]
	var k := size / tex.get_width()
	var rect := Rect2(center - tex.get_size() * k / 2.0 + icon["offset"] * size, tex.get_size() * k)
	draw_texture_rect(tex, rect, false, color)


func _draw_panel() -> void:
	draw_rect(Rect2(Vector2.ZERO, _screen()), Color(0, 0, 0, 0.55))
	var r := _panel_rect()
	draw_rect(Rect2(r.position + Vector2(4, 6), r.size), Color(0, 0, 0, 0.5))
	draw_rect(r, GOLD_DARK)
	draw_rect(r.grow(-2), GOLD)
	draw_rect(r.grow(-4), GOLD_DARK)
	draw_rect(r.grow(-5), STONE)
	draw_rect(r.grow(-10), Color(GOLD, 0.25), false, 1.0)
	for corner in [r.position + Vector2(10, 10), Vector2(r.end.x - 10, r.position.y + 10),
			Vector2(r.position.x + 10, r.end.y - 10), r.end - Vector2(10, 10)]:
		_diamond(corner, 4.0, GOLD)
	_title_text(Assets.port_label(1), Vector2(r.get_center().x, r.position.y + 44), 24)
	var line_y := r.position.y + 58
	draw_line(Vector2(r.position.x + 40, line_y), Vector2(r.end.x - 40, line_y), Color(GOLD, 0.5), 1.0)
	_label(Assets.port_label(2), Vector2(r.position.x + 34, _slider_rect().get_center().y + 6))
	_draw_slider()
	_label(Assets.port_label(3), Vector2(r.position.x + 34, _mute_rect().get_center().y + 6))
	_draw_checkbox()
	_label(Assets.port_label(4), Vector2(r.position.x + 34, _language_rect().get_center().y + 6))
	var language_rect := _language_rect()
	draw_rect(language_rect, GOLD_DARK)
	draw_rect(language_rect.grow(-1), STONE)
	_label(str(Assets.LANGUAGES[Assets.lang]) + "  >", language_rect.position + Vector2(8, 21))
	_medallion(_close_center(), 14.0, "close", _hover == "close")


func _draw_slider() -> void:
	var t := _slider_rect()
	var on := not muted
	draw_rect(t.grow(1), GOLD_DARK)
	draw_rect(t, Color(0.02, 0.015, 0.01))
	var fill := Rect2(t.position, Vector2(t.size.x * volume, t.size.y))
	draw_rect(fill, GOLD if on else Color(0.4, 0.35, 0.3))
	var knob := Vector2(t.position.x + t.size.x * volume, t.get_center().y)
	var hot := _hover == "slider" or _dragging
	draw_circle(knob + Vector2(1, 2), 9, Color(0, 0, 0, 0.5))
	draw_circle(knob, 9 if hot else 8, GOLD_DARK)
	draw_circle(knob, (9 if hot else 8) - 1.5, GOLD_LIGHT if hot else GOLD)
	draw_circle(knob, 3, GOLD_DARK)
	_label("%d%%" % roundi(volume * 100), Vector2(t.end.x + 16, t.get_center().y + 6))


func _draw_checkbox() -> void:
	var b := _mute_rect()
	var hot := _hover == "mute"
	draw_rect(b.grow(1), GOLD_DARK)
	draw_rect(b, GOLD_LIGHT if hot else GOLD)
	draw_rect(b.grow(-2), STONE)
	if muted:
		_draw_icon("check", b.get_center(), 18, GOLD_LIGHT)


func _label(text: String, pos: Vector2) -> void:
	draw_string_outline(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 4, Color(0, 0, 0, 0.8))
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, GOLD_LIGHT)


func _title_text(text: String, center: Vector2, size: int) -> void:
	var w := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var pos := Vector2(center.x - w / 2.0, center.y)
	draw_string_outline(_font, pos + Vector2(2, 3), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 6, Color(0, 0, 0, 0.6))
	draw_string_outline(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 6, OUTLINE)
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, GOLD)


func _diamond(c: Vector2, d: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0),
			c + Vector2(0, d), c + Vector2(-d, 0)]), color)


## Rasteriza el SVG a 4x y mide su centroide de alfa: `offset` (en fracciones del tamano)
## desplaza el icono para que su centro visual, no su caja, quede en el centro del medallon.
static func _rasterize(svg: String) -> Dictionary:
	var image := Image.new()
	image.load_svg_from_string(svg, 4.0)
	var sum := Vector2.ZERO
	var total := 0.0
	for y in image.get_height():
		for x in image.get_width():
			var a := image.get_pixel(x, y).a
			if a > 0.0:
				sum += Vector2(x + 0.5, y + 0.5) * a
				total += a
	var size := Vector2(image.get_size())
	var centroid := sum / total if total > 0.0 else size / 2.0
	return {"tex": ImageTexture.create_from_image(image), "offset": (size / 2.0 - centroid) / size.x}
