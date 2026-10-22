extends Node2D
## Escenas11 (créditos) y1 (vídeo), con recursos provisionales autorizados.
## Yugi43f0a0: fondos envueltos a600, velocidades1/2 y3/2 por tick nativo.
## El vídeo provisional dura 360 ticks (12 segundos a 30 Hz); no representa la duración de test.avi.
signal finished

const VIDEO_TICKS := 360
var game: String
var mode: String
var ticks := 0
var _fraction := 0.0
var _blend := NativeBlend.new()
var _done := false
var _font := ThemeDB.fallback_font
var _logo: Texture2D

func _init(game_id: String, scene_mode := "credits") -> void:
	game = game_id
	mode = scene_mode

func _ready() -> void:
	Audio.stop_all()
	_logo = TitleArt.logo_texture(game)
	queue_redraw()

func _process(delta: float) -> void:
	if _done: return
	_fraction += NativeClock.ticks(delta)
	var steps := int(_fraction)
	_fraction -= steps
	for _i in steps: _blend.tick()
	_blend.fraction = _fraction
	advance(steps)
	queue_redraw()

func advance(steps: int) -> void:
	if _done: return
	ticks += maxi(0, steps)
	if mode == "video" and ticks >= VIDEO_TICKS: complete()
	queue_redraw()

func complete() -> void:
	if _done: return
	_done = true
	finished.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		complete()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		complete()
		get_viewport().set_input_as_handled()

func _center(text: String, y: float, font_size: int, color := Color.WHITE) -> void:
	var width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(_font, Vector2((800 - width) / 2, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw() -> void:
	draw_rect(Rect2(0,0,800,600), Color("101527"))
	if mode == "credits":
		# Los recursos originales faltan: composición temporal, sin nombres inventados.
		# Se mezcla la posicion sin envolver: las copias a +-600 tapan el salto.
		var slow := fposmod(_blend.at("slow", ticks / 2), 600.0)
		var fast := fposmod(_blend.at("fast", ticks * 3 / 2), 600.0)
		for copy in [-600, 0, 600]:
			draw_rect(Rect2(0,slow + copy,800,100), Color("19213b"))
			draw_line(Vector2(0,fast + copy), Vector2(800,fast + copy), Color("354260"), 2)
		_center("CRÉDITOS", 165, 38)
		_center(Game.TITLES[game], 330, 26)
		_center("Recursos provisionales", 390, 20, Color("c9cedb"))
	else:
		_center("VÍDEO PROVISIONAL", 175, 34)
		var progress := minf(1.0, _blend.at("video", float(ticks)) / VIDEO_TICKS)
		draw_rect(Rect2(170,410,460,4), Color("354260"))
		draw_rect(Rect2(170,410,460 * progress,4), Color("dec887"))
	if _logo != null:
		var size := _logo.get_size()
		var fit := minf(360.0 / size.x, 110.0 / size.y)
		var target := size * fit
		draw_texture_rect(_logo, Rect2(Vector2(400,250) - target / 2, target), false)
	_center("Pulsa una tecla o haz clic para volver", 545, 18, Color("c9cedb"))
