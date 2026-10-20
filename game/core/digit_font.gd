class_name DigitFont
extends RefCounted
## Fuente de mapa de bits del original: una tira con "0123456789" de ancho fijo y, opcional,
## otra tira de simbolos con anchos propios. En los scripts los anchos de los simbolos van
## "de 2 en 2 digitos": get_symbol "110520" con "/.%" = anchos 11, 05 y 20.

var digits: Texture2D
var symbols: Texture2D
var symbol_chars := ""
var symbol_widths := PackedInt32Array()
var glyph_width := 0.0


## `pitch`: ancho de cada glifo. Si no se da, se detecta: unas tiras tienen 10 huecos y otras
## 11 (el ultimo vacio: font_small de 99 px = 11 x 9, font_big de 110 px = 11 x 10).
func _init(digits_tex: Texture2D, symbols_tex: Texture2D = null, chars := "",
		widths_value: Variant = null, pitch := 0.0) -> void:
	digits = digits_tex
	glyph_width = pitch if pitch > 0.0 else detect_pitch(digits_tex)
	symbols = symbols_tex
	symbol_chars = chars
	if widths_value != null:
		symbol_widths = Layout.groups(widths_value, 2)


## Elige entre ancho/10 y ancho/11 el paso que deja menos tinta en las fronteras entre
## cifras (las cifras pueden tocarse, pero nunca mas en la frontera que dentro del glifo).
static func detect_pitch(tex: Texture2D) -> float:
	var img := tex.get_image()
	var w := img.get_width()
	var h := img.get_height()
	var bg := img.get_pixel(0, 0)
	var ink := PackedInt32Array()
	ink.resize(w)
	for x in w:
		for y in h:
			var c := img.get_pixel(x, y)
			if c.a > 0.5 and (bg.a < 0.5 or absf(c.r - bg.r) + absf(c.g - bg.g) + absf(c.b - bg.b) > 0.45):
				ink[x] += 1
	var best := w / 10.0
	var best_score := INF
	for slots in [10, 11]:
		var p := w / float(slots)
		var score := 0.0
		for k in range(1, 10):
			score += ink[mini(w - 1, roundi(k * p))]
		if score < best_score:
			best_score = score
			best = p
	return best


func height() -> float:
	return digits.get_height()


func text_width(text: String) -> float:
	var w := 0.0
	for ch in text:
		w += _char_width(ch)
	return w


## Dibuja con la esquina superior izquierda en `pos`.
func draw(canvas: CanvasItem, text: String, pos: Vector2, modulate := Color.WHITE) -> void:
	var x := pos.x
	for ch in text:
		if ch.is_valid_int():
			var src := Rect2(ch.to_int() * glyph_width, 0, glyph_width, digits.get_height())
			canvas.draw_texture_rect_region(digits, Rect2(Vector2(x, pos.y), src.size), src, modulate)
		elif symbols != null and symbol_chars.contains(ch):
			var i := symbol_chars.find(ch)
			var sx := 0.0
			for k in i:
				sx += symbol_widths[k]
			var src := Rect2(sx, 0, symbol_widths[i], symbols.get_height())
			canvas.draw_texture_rect_region(symbols, Rect2(Vector2(x, pos.y), src.size), src, modulate)
		x += _char_width(ch)


func draw_centered(canvas: CanvasItem, text: String, center: Vector2) -> void:
	draw(canvas, text, center - Vector2(text_width(text), height()) / 2.0)


func draw_right(canvas: CanvasItem, text: String, top_right: Vector2) -> void:
	draw(canvas, text, top_right - Vector2(text_width(text), 0))


func _char_width(ch: String) -> float:
	if ch.is_valid_int():
		return glyph_width
	var i := symbol_chars.find(ch)
	if i != -1 and i < symbol_widths.size():
		return symbol_widths[i]
	return glyph_width / 2.0   # espacio u otro caracter sin glifo
