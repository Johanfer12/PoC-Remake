class_name DuelDemoLabel
extends Node2D
## Rotulo "DEMOSTRACION" de las demostraciones (FUN_0043dbe0, duel/effect/layerfont.txt:
## demo_font_?.bmp), creado por el comando 0x14 solo en el modo de partida 5 (demostracion de
## la pantalla de titulo, 0x467000). Dibujo FUN_0043a880: contador +4 por fotograma (& 0xff);
## alfa T[2c - 0x80] / 256 mientras c < 0x40, opaco hasta 0xc0 y T[2c + 0x80] / 256 despues;
## esquina inferior derecha en (0x314, 0x24c).

var _tex: Texture2D
var _counter := 0
var _clock := 0.0
var _blend := NativeBlend.new()


func setup(game: String) -> void:
	var path := "%s/duel/effect/demo_font_s.png" % game
	_tex = Assets.texture(path if Assets.exists(path) else "yugi/duel/effect/demo_font_s.png")
	z_index = 90


func _process(delta: float) -> void:
	_clock += NativeClock.ticks(delta)
	while _clock >= 1.0:
		_clock -= 1.0
		_counter = (_counter + 4) & 0xff
		_blend.tick()
	_blend.fraction = _clock
	queue_redraw()


func _draw() -> void:
	if _tex == null:
		return
	var alpha := 255
	if _counter < 0x40:
		alpha = mini(DuelVisualMath.cos_fx(_counter * 2 - 0x80) >> 8, 255)
	elif _counter >= 0xc1:
		alpha = mini(DuelVisualMath.cos_fx(_counter * 2 + 0x80) >> 8, 255)
	var top_left := Vector2(0x314, 0x24c) - _tex.get_size()
	draw_texture(_tex, top_left, Color(1, 1, 1, maxf(_blend.at("alpha", alpha), 0) / 255.0))
