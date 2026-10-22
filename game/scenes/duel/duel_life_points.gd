class_name DuelLifePoints
extends Node2D
## Indicador de vida del original (duel/life/lifepoint.txt). Cada juego dibuja el suyo.
##
## Yugi (objeto de 0x45dc60; dibujo FUN_0045d890, fotograma FUN_0045d750). Por jugador:
## - Cristal lp_crystal con su esquina superior izquierda en (28, 13) para la CPU y (28, 549)
##   para el humano ("028013549": X, Y2P, Y1P).
## - Dentro, el agua: recorte de 48 x 43 de lp_water (lp_water2, roja, con LP < 2501). El
##   nivel es min(LP / 200, 40) - 23; la ola desplaza el recorte (contador +0x38, 0-127, que
##   avanza 1 por fotograma o 2 si el agua se agita) y al cambiar los LP el agua se agita 31
##   fotogramas (+0x3c), que eligen la franja de 64 px de la textura.
## - Los LP con la fuente lp_123 (cifras de 22 px), borde derecho en x = 222 y arriba en
##   y = 26 / 563 ("222026563").
## - Solo en match (0x4373c0, parte final de 0x45d890): casillas de los 3 duelos de
##   duel/life/match.txt en x = 99, y = 551 (jugador) / 14 (rival), franjas [0, 12, 24, 38]
##   de la imagen elegida: 0 sin jugar, 1/2 el duelo en curso alternando cada 16 pasos
##   (DAT_005aed18 >> 4), p + 1 + 2 * resultado para los ya decididos.
##
## Kaiba (Kaiba_Pc.exe: constructor 0x438d10, objeto 0x45fa40 con vtable 0x59f85c; dibujo
## 0x45f560, fotograma 0x45f430). Las coordenadas del .txt son las del jugador 2 y el 1 las
## desplaza Y1P - Y2P de LP_123 (561 - 23). Los LP se cuentan en tramos de 250 redondeando
## hacia arriba, (LP + 249) / 250, que recorren una U:
## - Tramos 1-12: barra inferior (lp_b_bo, o lp_r_bo con LP <= 2500) en (28, 51), 10 px por
##   tramo, recortada por la izquierda.
## - Tramos 13-20: curva izquierda lp_b_cir1..8 en (5, 2).
## - Tramos 21-32: barra superior lp_b_up en (28, 2), recortada por la derecha.
## - Triangulo en (148, 15): lp_tri2 (oscuridad) con el contador +0x38 < 64 y lp_tri1 (luz)
##   con el resto, con alfa min(cos((+0x38 & 63) * 4 - 128) >> 8, 255) (metodo 0x18).
##   El contador avanza siempre 1 por fotograma (sin el 2 de la agitacion de Yugi).
## - Cifras con LP_123 (19 px), borde derecho en x = 143 y arriba en y = 23 / 561.

const CRYSTAL := Vector2(28, 0)
const CRYSTAL_Y := [549, 13]
const DIGITS_RIGHT := 222
const DIGITS_Y := [563, 26]

var _game := "yugi"
var _crystal: Texture2D
var _water: Array[Texture2D] = []
var _digits: Texture2D
## Kaiba: recursos de lifepoint.txt por indice (0 LP_123 ... 13 lp_tri2) y sus coordenadas.
var _res: Array[Texture2D] = []
var _pos: Array[PackedInt32Array] = []
## +0x38 (ola), +0x3c (agitacion) y LP mostrados por jugador.
var _wave := [0, 0]
var _shake := [0, 0]
var _shown := [-1, -1]
var _lp := [8000, 8000]
var _match_res: Array[Texture2D] = []
var _match_xy := PackedInt32Array([99, 14, 551])
var _match_steps := PackedInt32Array([0, 12, 24, 38])
var _frame := 0   # DAT_005aed18
var _blend := NativeBlend.new()   # destello de la barra de Kaiba entre ticks


func setup(game: String) -> void:
	_game = game
	_shown = [-1, -1]
	_res.clear()
	_pos.clear()
	if game in ["kaiba", "joey"]:
		for item in Assets.layout("%s/duel/life/lifepoint.txt" % game).items:
			_res.append(Assets.texture("%s/duel/life/%s.png" % [game, String(item["resource"]).get_basename().to_lower()]))
			_pos.append(Layout.groups(item["value"]))
		_digits = _res[0]
	else:
		_crystal = _tex(game, "lp_crystal")
		_water = [_tex(game, "lp_water"), _tex(game, "lp_water2")]
		_digits = _tex(game, "lp_123")
	_match_res.clear()
	var match_layout = Assets.layout("%s/duel/life/match.txt" % game)
	for item in match_layout.items:
		_match_res.append(Assets.texture("%s/duel/life/%s" % [game, item["resource"]]))
	if match_layout.items.size() >= 2:
		_match_xy = Layout.groups(match_layout.items[0]["value"])
		var bands := int(match_layout.items[1]["value"])
		_match_steps = PackedInt32Array([0, bands / 10000, (bands / 100) % 100, bands % 100])
	queue_redraw()


func _tex(game: String, name: String) -> Texture2D:
	var path := "%s/duel/life/%s.png" % [game, name]
	return Assets.texture(path if Assets.exists(path) else "yugi/duel/life/%s.png" % name)


## Un tick nativo (NativeClock.HZ) con los LP que debe mostrar cada jugador.
func step(lp: Array) -> void:
	_frame += 1
	_blend.tick()
	for p in 2:
		var value := maxi(int(lp[p]), 0)
		if _shown[p] >= 0 and value != _shown[p]:
			# 0x45d750 / 0x45f430: cuando cambia la cantidad mostrada el agua se agita (0x1f).
			_shake[p] = 0x1f
		_shown[p] = value
		var speed := 1 if _game == "kaiba" else 1 + int(_shake[p] != 0)
		_wave[p] = (_wave[p] + speed) & 0x7f
		_shake[p] -= int(_shake[p] > 0)
		_lp[p] = value
	queue_redraw()


## Quien lo avanza dibuja entre ticks con lo que le queda en su reloj.
func show_between(fraction: float) -> void:
	_blend.fraction = fraction
	if _game == "kaiba": queue_redraw()


func _draw() -> void:
	if _game == "kaiba":
		_draw_kaiba()
		return
	if _game == "joey":
		_draw_joey()
		return
	if _crystal == null:
		return
	for p in 2:
		var lp: int = _lp[p]
		var top: int = CRYSTAL_Y[p]
		var water: Texture2D = _water[1 if lp < 0x9c5 else 0]
		var level := mini(lp / 200, 0x28) - 0x17
		var x0: int = _wave[p] / 2
		var y0: int = (_shake[p] / 8) * 0x40
		if water != null:
			if level < 0:
				var h := 0x2b + level
				if h > 0:
					draw_texture_rect_region(water, Rect2(CRYSTAL.x, top - level, 0x30, h), Rect2(x0, y0, 0x30, h))
			else:
				draw_texture_rect_region(water, Rect2(CRYSTAL.x, top, 0x30, 0x2b), Rect2(x0, y0 + level, 0x30, 0x2b))
		draw_texture(_crystal, Vector2(CRYSTAL.x, top))
		_draw_digits(lp, DIGITS_RIGHT, DIGITS_Y[p])
		if Game.duel_mode == 1:
			_draw_match_marks(p)


func _draw_match_marks(p: int) -> void:
	if _match_res.size() < 9:
		return
	var y: int = _match_xy[2] if p == 0 else _match_xy[1]
	for i in 3:
		var r: int = Game.match_results[i]
		var index := 0
		if i < Game.match_duel:
			index = ((_frame >> 4) & 1) + 1 if i == Game.match_duel - 1 and r == 0 else p + 1 + 2 * r
		var tex := _match_res[index]
		if tex == null:
			continue
		var band := Rect2(0, _match_steps[i], tex.get_width(), _match_steps[i + 1] - _match_steps[i])
		draw_texture_rect_region(tex, Rect2(Vector2(_match_xy[0], y + _match_steps[i]), band.size), band)


## 0x45f560 (sin el numero del cambio de LP, que dibuja duel_presentation, ni las casillas
## del match).
func _draw_kaiba() -> void:
	if _res.size() < 14:
		return
	var digits: PackedInt32Array = _pos[0]
	for p in 2:
		var lp: int = _lp[p]
		var dy: int = digits[2] - digits[1] if p == 0 else 0
		var segments := (lp + 0xf9) / 250
		if segments > 0:
			var bar := 1 + int(lp > 0x9c4)
			var left := (12 - segments) * 10 if segments < 12 else 0
			_blit(bar, left, dy, left, -1)
		segments -= 12
		if segments > 0:
			_blit(3 + mini(segments, 8), 0, dy)
		segments -= 8
		if segments > 0:
			_blit(3, 0, dy, 0, segments * 10 if segments < 12 else -1)
		var c: int = _wave[p]
		var alpha: float = _blend.at([p, c < 0x40], mini(DuelVisualMath.cos_fx((c & 0x3f) * 4 - 0x80) >> 8, 0xff))
		_blit(12 + int(c < 0x40), 0, dy, 0, -1, alpha)
		_draw_digits(lp, digits[0], digits[2] if p == 0 else digits[1])
		if Game.duel_mode == 1: _draw_match_marks(p)


## Jo47c660: medidor propio/rival, recorte horizontal min(LP,8000)/8000,
## cifras con limite derecho de lifepoint.txt y marco rengame dibujado al final.
func _draw_joey() -> void:
	if _res.size() < 7: return
	var digits := _pos[0]
	for p in 2:
		var side := 1 if p == 1 else 0
		_blit(3 + side, 0, 0)
		var fill := _res[5 + side]
		if fill != null:
			var width := mini(_lp[p], 8000) * fill.get_width() / 8000
			_blit(5 + side, 0, 0, 0, width)
		_draw_digits(_lp[p], digits[0], digits[2] if p == 0 else digits[1])
		if Game.duel_mode == 1: _draw_match_marks(p)
		_blit(1 + side, 0, 0)


## Metodo 8 (o 0x18 con alfa) del dibujante con la coordenada del recurso `index`: recorte
## horizontal [left, right) de la textura (right < 0: hasta el final), desplazado `dx`.
func _blit(index: int, dx: int, dy: int, left := 0, right := -1, alpha := 255.0) -> void:
	var tex := _res[index]
	if tex == null:
		return
	var xy: PackedInt32Array = _pos[index]
	var w := tex.get_width() if right < 0 else right
	if w <= left:
		return
	var h := tex.get_height()
	draw_texture_rect_region(tex, Rect2(xy[0] + dx, xy[1] + dy, w - left, h), Rect2(left, 0, w - left, h), Color(1, 1, 1, alpha / 255.0))


## 0x4604f0 (Yugi) / 0x462670 (Kaiba): cifras de derecha a izquierda desde `right`, con el
## ancho de la fuente entre 10.
func _draw_digits(value: int, right: int, top: int) -> void:
	if _digits == null:
		return
	var glyph := _digits.get_width() / 10
	var h := _digits.get_height()
	var x := right
	while true:
		x -= glyph
		draw_texture_rect_region(_digits, Rect2(x, top, glyph, h), Rect2((value % 10) * glyph, 0, glyph, h))
		value /= 10
		if value == 0:
			break
