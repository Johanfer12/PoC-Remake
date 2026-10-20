class_name JoeyPortZK
extends JoeyPortZJ
## Cursor vertical nativo. EAX de 45c140/45c280 contiene X; EDX/Y no interviene
## en 5bf330. En modo UI la escena proporciona sus puntos y desplazamientos.
var ui_geometry_ready: Array[bool] = [false, false]
var ui_geometry_hands: Array[PackedInt32Array] = [PackedInt32Array(), PackedInt32Array()]
var ui_geometry_fields: Array[PackedInt32Array] = [PackedInt32Array(), PackedInt32Array()]
var ui_geometry_scroll: Array[Vector2i] = [Vector2i.ZERO, Vector2i.ZERO]


## Consultas a objetos del renderer original. La tabla visual es propiedad de
## la presentacion; sin proveedor conservan el contrato historico sin objeto.
func f41cee0(player: int, area: int, index: int) -> int:
	var object := _visual_object_from_renderer("card", player, area, index)
	return _frontier(0x41cee0, [player, area, index], object)


func f41cf60(player: int, area: int) -> int:
	var object := _visual_object_from_renderer("pile", player, area, 0)
	return _frontier(0x41cf60, [player, area], object)


## ASM418b50: EAX=out; copia u16[this+24] a [out]; ret4.
func f418b50(this_: int, out: int) -> int:
	if not visual_object_query.is_valid():
		return _frontier(0x418b50, [this_, out], 0)
	_frontier(0x418b50, [this_, out], 0)
	m.set_u16(out, m.u16(this_ + 0x24))
	return out


## 481a10 -> 481a20: la consulta UI recalcula elegibilidad de ataque al
## apuntar a Batalla. Esa llamada a reglas debe ejecutarse tambien sin clic.
func f481a10() -> int:
	if not visual_phase_hover_query.is_valid():
		return super.f481a10()
	var input: Dictionary = visual_phase_hover_query.call()
	_frontier(0x481a10, [], phase_choice)
	var mode := int(input.get("mode", -1))
	var hover := int(input.get("hover", -1))
	var selection := -1
	if mode == 2 and hover == 3:
		if f5a0dd0(m.u32(JoeyMem.MODE) & 1) != 0:
			selection = 3
	if mode == 3 and hover == 4:
		selection = 4
	elif hover == 5:
		selection = 5
	return selection if bool(input.get("pressed", false)) else -1


func _jzk_s32(addr: int) -> int:
	return _s32(m.u32(addr))


func _frontier_empty_text(out: int, flag: int) -> void:
	m.set_u8(out, flag)
	m.clear(out + 4, 12)


func f5be130() -> int:
	return m.u16(0x5efbc8)


func f5be150() -> int:
	return int(m.u16(0x5efbc8) == 0)


## Coordenadas X del renderer, antes de aplicar el scroll de la mano. field_x
## indexa áreas 0..15 (11 usa hand_x); un array vacío conserva las tablas PE.
## scroll_x/y son la traslación real del renderer, en píxeles y con su signo.
func ui_set_geometry(player: int, hand_x: PackedInt32Array, field_x: PackedInt32Array = PackedInt32Array(), scroll_x: int = 0, scroll_y: int = 0) -> void:
	var p := player & 1
	ui_geometry_hands[p] = hand_x.duplicate()
	ui_geometry_fields[p] = field_x.duplicate()
	ui_geometry_scroll[p] = Vector2i(scroll_x, scroll_y)
	ui_geometry_ready[p] = true


func _jzk_ui_x(p: int, area: int, index: int) -> int:
	if area == 11:
		if index < ui_geometry_hands[p].size():
			return ui_geometry_hands[p][index]
		return _jzk_s32(0x5db608 + int(p == ((~m.u8(JoeyMem.MODE)) & 1)) * 8)
	if area + index < 11:
		area += index
	if area >= 0 and area < ui_geometry_fields[p].size():
		return ui_geometry_fields[p][area]
	return f45c280(p, area, 0)


func f45c280(p: int, area: int, index: int) -> int:
	var side := int(p == ((~m.u8(JoeyMem.MODE)) & 1))
	if _s32(area + index) < 11:
		area = _s32(area + index)
		index = 0
	if ui_enabled and ui_geometry_ready[p] and area != 11 and area >= 0 and area < ui_geometry_fields[p].size():
		return ui_geometry_fields[p][area]
	if area >= 0 and area < 5:
		return _jzk_s32(0x5db560 + (area + side * 5) * 8)
	if area >= 5 and area < 10:
		return _jzk_s32(0x5db4e8 + (area + side * 5) * 8)
	match area:
		10: return _jzk_s32(0x5db5e0 + side * 8)
		11:
			if ui_enabled and ui_geometry_ready[p]:
				return _jzk_ui_x(p, area, index)
			if _s32(index) < _jzk_s32(0x5f32c8 + p * 4):
				return _jzk_s32(m.u32(0x5f32ac + p * 16) + index * 8)
			return _jzk_s32(0x5db608 + side * 8)
		12: return _jzk_s32(0x5db5d0 + side * 8)
		13: return _jzk_s32(0x5db5b0 + side * 8)
		14: return _jzk_s32(0x5db5c0 + side * 8)
		15: return _jzk_s32(0x5db5f0 + side * 8)
	return 525


func f45c140(p: int, area: int, index: int) -> int:
	if ui_enabled and ui_geometry_ready[p]:
		return _jzk_ui_x(p, area, index)
	var side := int(p == ((~m.u8(JoeyMem.MODE)) & 1))
	match area:
		11:
			if _s32(index) < _jzk_s32(0x5f32c8 + p * 4):
				return _jzk_s32(m.u32(0x5f32ac + p * 16) + index * 8)
			return _jzk_s32(0x5db608 + side * 8)
		12:
			if index == 0:
				return f45c280(p, area, 0)
			var offset := _jzk_s32(0x5f32e8 + p * 4)
			return _s32(_jzk_s32(0x5db5d0 + side * 8) + (-offset if p == (m.u8(JoeyMem.MODE) & 1) else offset))
		13:
			if index != 0:
				return f45c280(p, area, index)
			var offset := _jzk_s32(0x5f32d8 + p * 4)
			return _s32(_jzk_s32(0x5db5b0 + side * 8) + (-offset if p != (m.u8(JoeyMem.MODE) & 1) else offset))
		14:
			if index == 0:
				return f45c280(p, area, 0)
			var offset := _jzk_s32(0x5f32e0 + p * 4)
			return _s32(_jzk_s32(0x5db5c0 + side * 8) + (-offset if p != (m.u8(JoeyMem.MODE) & 1) else offset))
	return f45c280(p, area, index)


func f5bf1c0(out: int, p: int) -> int:
	if ui_enabled and ui_geometry_ready[p]:
		m.set_u32(out, ui_geometry_scroll[p].x)
		m.set_u32(out + 4, ui_geometry_scroll[p].y)
		return out
	var sign := 1
	var adjust := -1
	if p == (m.u8(JoeyMem.MODE) & 1):
		sign = -1
		adjust = 0
	m.set_u32(out, (_cdiv(_jzk_s32(0x5f2ffc), 4) + adjust) * sign)
	m.set_u32(out + 4, (_cdiv(_jzk_s32(0x5f3000), 4) + adjust) * sign)
	return out


func f5bf300(p: int, area: int, index: int, target_p: int, target_area: int) -> int:
	return f5bf330(p, area, index, target_p, target_area)


func f5bf330(p: int, area: int, index: int, target_p: int, target_area: int) -> int:
	if area == target_area and p == target_p:
		return index
	var x := f45c140(p, area, index)
	var translation := m.local(8)
	if area == 11:
		f5bf1c0(translation, p)
		x = _s32(x + _jzk_s32(translation))
	var count := target_p
	var target_shift := 0
	if target_area >= 0 and target_area < 10:
		count = 5
	elif target_area in [10, 12, 13, 14, 15]:
		count = 1
	elif target_area == 11:
		if ui_enabled and ui_geometry_ready[target_p]:
			count = ui_geometry_hands[target_p].size()
		else:
			var hands := m.u32(0x5f300c)
			var a := hands + target_p * 0x460
			# Sin renderer no existe el vector UI; el ensayo nativo tiene
			# esta página a cero. No leer la dirección nula como JoeyMem.
			var begin := 0 if hands == 0 else m.u32(a + 4)
			count = 0 if begin == 0 else _s32(m.u32(a + 8) - begin) >> 4
		f5bf1c0(translation, target_p)
		target_shift = _jzk_s32(translation)
	var result := 0
	var best := 9999
	for i in range(maxi(0, count)):
		var delta := _s32(f45c140(target_p, target_area, i) - x + target_shift)
		var distance := _s32(absi(delta))
		if distance < best:
			best = distance
			result = i
	return result
