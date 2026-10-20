class_name DuelAffect
extends Node2D
## Iconos de vinculo sobre las cartas (objeto de FUN_00409420 dentro del campo DAT_005af738,
## duel/effect/affect.txt: loop_blue, ico_equip, ico_conti, ico_field y, en Kaiba/Joey,
## ico_rusi/ico_kousoku e ico_power). Con el cursor sobre una carta del campo marca las cartas
## que la afectan o a las que afecta.
## FUN_00407f80 (cada fotograma): +0x10 sube 8 (& 0xff); vuelve a 0 al cambiar el objeto
## senalado (DAT_005af708, +0x13c).
## FUN_00408360 (dibujo): recorre los vinculos de la zona senalada (+0x08 destino p | z << 8,
## +0x48 tipo, +0x88 cuantos) y los de todas las zonas que apuntan a ella, mas FUN_00547ba0,
## FUN_00545c40 (carta 0x148) y FUN_00545a70 (campo); ver _collect.
## FUN_004082f0: compone el icono (FUN_004081e0) y lo dibuja centrado en FUN_00442130 con alfa
## (T[+0x10 - 0x80] >> 8) * 7 / 8.
## FUN_004081e0: superficie del tamano del icono rellena con loop_blue desplazado
## (+0x10 / 8) % alto en vertical (dos tramos si da la vuelta) y recortada por el alfa del icono.

const RESOURCES := ["loop_blue", "ico_equip", "ico_conti", "ico_field"]

var _game := "yugi"
var _duel: Duel
var _counter := 0
var _hovered := {}
var _blend := NativeBlend.new()   # pulso de los iconos entre ticks
var _marks: Array = []
var _cache := {}


func setup(duel: Duel, game: String) -> void:
	_duel = duel
	_game = game
	_counter = 0
	_hovered = {}
	_marks = []
	z_index = 1


## Un tick nativo (NativeClock.HZ). `hover`: {p, loc, i} de la carta bajo el cursor (vacio si no hay).
func step(hover: Dictionary) -> void:
	var key := {}
	if not hover.is_empty():
		key = {"p": int(hover["p"]), "loc": int(hover["loc"]), "i": int(hover["i"])}
	# FUN_00407f80
	_blend.tick()
	_counter = (_counter + 8) & 0xff
	if key.is_empty():
		_hovered = {}
	elif key != _hovered:
		_hovered = key
		_counter = 0
	_marks = _collect() if _duel != null and not _hovered.is_empty() else []
	queue_redraw()


## Quien lo avanza dibuja entre ticks con lo que le queda en su reloj.
func show_between(fraction: float) -> void:
	_blend.fraction = fraction
	queue_redraw()


func _zone(p: int, z: int) -> int:
	return 0xa1195c + (p & 1) * 0xd54 + z * 0x94


func _card(p: int, z: int) -> int:
	return _duel.m.u32(_zone(p, z)) & 0xfff


## Icono por defecto con la carta senalada en un monstruo: 2, o 5/4 para las cartas 0x52/0x534.
func _kind_for(id: int) -> int:
	if id == 0x52:
		return 5
	if id == 0x534:
		return 4
	return 2


## FUN_00408360: lista de [p, z, icono] en el orden en que el original dibuja.
func _collect() -> Array:
	var out := []
	var group: int = _hovered["loc"]
	var hp: int = _hovered["p"] & 1
	var hz: int = int(_hovered["i"]) + group
	if hz >= 0xb or _card(hp, hz) == 0:
		return out
	var m := _duel.m
	var base := _zone(hp, hz)
	if group == 0:
		for l in m.u16(base + 0x88):
			var target := m.u16(base + 8 + l * 2)
			var tp := target & 1
			var tz := (target >> 8) & 0xff
			if _card(tp, tz) == 0:
				continue
			var icon := 2
			if hz < 5:
				icon = _kind_for(_duel.f401a70(_card(tp, tz)))
			match m.u8(base + 0x48 + l * 2):
				1, 5, 10:
					out.append([tp, tz, 1 if tz > 4 else icon])
				2, 7:
					out.append([tp, tz, 2 if tz > 4 else icon])
		for p in 2:
			for z in 5:
				if _duel.f547ba0(hp, hz, p, z) != 0:
					out.append([p, z, 5])
		if (m.u8(base + 6) & 2) != 0 and (_duel.f545c40(hp, hz) & 0xffff) == 1:
			for p in 2:
				for z in range(5, 0xb):
					var a := _zone(p, z)
					if (_duel.f401a70(m.u16(a) & 0xfff) & 0xffff) == 0x148 and (m.u8(a + 6) & 2) != 0 and (m.u8(a + 0x8f) & 4) == 0:
						out.append([p, z, 2])
		var field := _duel._s32(_duel.f545a70(hp, hz))
		if field >= 0:
			out.append([field, 10, 3])
	elif group == 10:
		for p in 2:
			for z in 5:
				var a := _zone(p, z)
				if (m.u32(a) & 0xfff) != 0 and (m.u8(a + 6) & 2) != 0 and _duel._s32(_duel.f545a70(p, z)) >= 0:
					out.append([p, z, 3])
	var own := (hz << 8) | hp
	var icon_default := 2
	if hz < 5:
		icon_default = _kind_for(_duel.f401a70(m.u32(base) & 0xfff))
	for p in 2:
		for z in 0xb:
			var a := _zone(p, z)
			if (m.u32(a) & 0xfff) == 0:
				continue
			for l in m.u16(a + 0x88):
				if m.u16(a + 8 + l * 2) != own:
					continue
				match m.u8(a + 0x48 + l * 2):
					1, 5, 10:
						out.append([p, z, 1 if hz > 4 else icon_default])
					2, 7:
						out.append([p, z, 2 if hz > 4 else icon_default])
			if (m.u8(a + 6) & 2) != 0 and (_duel.f545c40(p, z) & 0xffff) == 1:
				if (_duel.f401a70(m.u32(base) & 0xfff) & 0xffff) == 0x148 and (m.u8(base + 6) & 2) != 0 and (m.u8(base + 0x8f) & 4) == 0:
					out.append([p, z, 2])
			if _duel.f547ba0(p, z, hp, hz) != 0:
				out.append([p, z, 5])
	return out


func _resource(index: int) -> String:
	var names := RESOURCES.duplicate()
	# Kaiba y Joey anaden dos lineas a affect.txt (4: ico_rusi / ico_kousoku, 5: ico_power).
	names.append("ico_rusi" if _game == "kaiba" else "ico_kousoku")
	names.append("ico_power")
	return names[index] if index < names.size() else ""


## FUN_004081e0: icono relleno con loop_blue desplazado (cacheado por icono y desplazamiento).
func _composed(icon: int) -> Texture2D:
	var path := "%s/duel/effect/%s.png" % [_game, _resource(icon)]
	var loop_path := "%s/duel/effect/loop_blue.png" % _game
	if not Assets.exists(path) or not Assets.exists(loop_path):
		return null
	var loop_tex := Assets.texture(loop_path)
	var loop_h := int(loop_tex.get_height())
	var offset := (_counter / 8) % loop_h
	var key := "%d/%d" % [icon, offset]
	if _cache.has(key):
		return _cache[key]
	var mask := Assets.texture(path).get_image()
	var loop := loop_tex.get_image()
	mask.decompress()
	loop.decompress()
	loop.convert(Image.FORMAT_RGBA8)
	var w := mask.get_width()
	var h := mask.get_height()
	var out := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		var src_y := (offset + y) % loop_h
		for x in w:
			var a := mask.get_pixel(x, y).a
			if a <= 0.0:
				continue
			var c := loop.get_pixel(mini(x, loop.get_width() - 1), src_y)
			c.a = a
			out.set_pixel(x, y, c)
	var tex := ImageTexture.create_from_image(out)
	_cache[key] = tex
	return tex


func _draw() -> void:
	if _marks.is_empty():
		return
	var alpha: float = _blend.at(str(_hovered), ((DuelVisualMath.cos_fx(_counter - 0x80) >> 8) * 7) / 8)
	for mark in _marks:
		var tex := _composed(mark[2])
		if tex == null:
			continue
		var center := DuelGeometry.zone(mark[0], mark[1])
		var size := tex.get_size()
		draw_texture(tex, Vector2(int(center.x) - int(size.x) / 2, int(center.y) - int(size.y) / 2), Color(1, 1, 1, alpha / 255.0))
