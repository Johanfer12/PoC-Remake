class_name DuelPortL
extends DuelPortK

## Texto que forma FUN_00569940 para el cuadro: {"msg": id, "subs": [...]}.
var _response_text := {}


## FUN_00569940: texto de la ventana de respuesta: el mensaje del contexto (o 0xb1 con el
## nombre de la carta), "<BR>" (0x59a59c) y el mensaje 0xcc. Se guarda en _response_text.
func f569940(e: int, text_buffer: int) -> int:
	m.set_u8(text_buffer, 0)
	var context := m.u16(e + 2) >> 10
	var dialog := -1
	var fixed := {1: 0x102, 3: 0xfb, 10: 0xb2, 11: 0xb3, 12: 0xb4, 18: 0xb5, 19: 0xb8, 20: 0xbf, 21: 0xc0, 22: 0xc1, 23: 0xc2, 24: 0xc3, 25: 0xc4, 27: 199, 28: 200, 30: 0xcb}
	if fixed.has(context):
		dialog = fixed[context]
	elif context in [5, 6, 7, 8, 16]:
		var option := m.u8(e + 6)
		if option <= 1:
			dialog = int({5: 0xfc, 6: 0xfe, 7: 0x100, 8: 0xaf, 16: 0xb6}[context]) + option
	elif context in [13, 14]:
		var option := m.u8(e + 8) & 0xf
		if option <= 1:
			dialog = (0xb9 if context == 13 else 0xbb) + option
	elif context in [15, 26]:
		var option := m.u16(e + 8)
		if option <= 1:
			dialog = (0xbd if context == 15 else 0xc5) + option
	elif context == 29:
		if m.u16(e + 6) <= 1:
			dialog = 0xc9 + m.u16(e + 6)
	elif context == 17:
		m.set_u16(text_buffer, 0)
		var a := DuelMem.zone(m.u8(e + 8) & 1, m.u8(e + 9))
		if (m.u16(a) & 0xfff) != 0 and (m.u8(a + 6) & 2) != 0:
			dialog = 0xb1
			_response_text = {"msg": dialog, "subs": [{"card": m.u16(a) & 0xfff}, {"append": 0xcc}]}
			present("dialog_text", {"msg": dialog, "card_id": f401a70(m.u16(a) & 0xfff), "suffix": 0xcc})
			return 0
	# Sin mensaje de contexto el texto empieza directamente por "<BR>" y 0xcc.
	_response_text = {"msg": dialog, "subs": [{"append": 0xcc}]} if dialog >= 0 else {"msg": 0xcc, "subs": [{"prefix_break": true}]}
	present("dialog_text", {"msg": dialog, "suffix": 0xcc})
	return 0

## FUN_0056b290: confirma un material ritual y actualiza los niveles restantes.
func f56b290() -> int:
	var e := 0xa15e6c + m.u16(0xa15fc0) * 0x14
	var p := m.u8(e + 2) & 1
	f56ac20(m.u16(e))
	var mask := 0xf1 if f543360(p) >= 0 else 0xf0
	if f57a060(mask) != 0:
		var loc := m.u32(0xa161a8)
		var index := m.u32(0xa161ac)
		if loc == 0 or loc == 0xb:
			if f56af00(p, loc, index) != 0 and f579890() != 0:
				var card := m.u16(f5419b0(p, loc, index)) & 0xfff
				_l_ritual_level(f4457d0(card))
				if loc == 0:
					f54ea40(p, index)
				else:
					f54e680(p, index, 0, 1)
	return int(m.u8(0xa15fe1) == 0)

func _l_ritual_level(level: int) -> void:
	m.set_u8(0xa15fe1, maxi(0, m.u8(0xa15fe1) - level))
	m.set_u8(0xa15fe2, mini(m.u8(0xa15fe2), level))

## FUN_0056b5f0: estados de invocacion ritual, incluida seleccion de materiales CPU.
func f56b5f0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p := m.u8(e + 2) & 1
	var state := m.u8(0xa15fe0)
	match state:
		99:
			f57cc50(p, 0xa15fe8, 1, 1, 0xb, m.u32(0xa0fb18))
			return 0x62
		100:
			var row := f56ac20(m.u16(e))
			for hand in m.u8(DuelMem.pl(p) + 2):
				var a := DuelMem.pl(p) + 0x674 + hand * 4
				if f401a70(m.u16(a) & 0xfff) == (m.u32(0x5aa9f0 + row * 4) & 0x1fff):
					f541cb0(0xa15fe8, a)
					issue(m.u16(e + 2) << 15 | 0xc2, m.u16(a), m.u16(a + 2), 0)
					m.set_u32(0xa0fb18, hand)
					return 99
			return 0
		0x78:
			if m.u8(0xa15fe1) == 0:
				return 100
			for hand in m.u8(DuelMem.pl(p) + 2):
				var card := m.u16(DuelMem.pl(p) + 0x674 + hand * 4) & 0xfff
				if card != 0 and f56af00(p, 0xb, hand) != 0:
					_l_ritual_level(f4457d0(card))
					f54e680(p, hand, 0, 1)
					return 0x78
			var card := m.u16(DuelMem.zone(p, 0)) & 0xfff
			if card != 0 and f56af00(p, 0, 0) != 0:
				_l_ritual_level(f4457d0(card))
				f54ea40(p, 0)
			return 0x78
		0x80:
			m.set_u8(0xa15fe1, 0)
			if f542f30(0, 0x58a) > 0 or f542f30(1, 0x58a) > 0:
				issue(m.u16(e + 2) << 15 | 0x1e, 0x58a, 1, 0)
				return 0
			if f56b490(e) != 0:
				var row := f56ac20(m.u16(e))
				if row >= 0 and f56ac80(p, row) != 0:
					m.set_u8(0xa15fe2, 0xff)
					m.set_u8(0xa15fe1, m.u32(0x5aa9f0 + row * 4) >> 26)
					m.set_u8(0xa16114, m.u8(0xa15fe1)) # ASM 56b6ba: mov byte ptr
					if p != 0:
						return 0x78
					f5417e0(0xcf)
					f540d60(9, m.u8(0xa15fe1))
					return 100
		_:
			m.set_u8(0xa15fe0, 0)
	return 0

## FUN_005703c0: abre y ejecuta la fusion de la carta 0x60b.
func f5703c0() -> int:
	var step := m.u8(0xa1340d)
	if step == 0:
		m.set_u8(0xa1340d, 1)
		m.set_u8(0xa15fe0, 0x80)
	elif step != 1:
		m.set_u8(0xa13408, m.u8(0xa13408) & 0xfd)
		return 0
	var e := m.local(20)
	m.set_u16(e, f401ad0(0x60b))
	m.set_u8(0xa15fe0, f564250(e, 0))
	if m.u8(0xa15fe0) == 0:
		m.set_u8(0xa1340d, m.u8(0xa1340d) + 1)
	return 0

## FUN_00568d80: devuelve del cementerio tantas cartas como nivel del objetivo.
func f568d80(e: int) -> int:
	var p := m.u8(e + 2) & 1
	match m.u8(0xa15fe5):
		0:
			_l_target_begin(e, 0x6d)
		1:
			if _l_target_cancel():
				return 0
			f564e20()
			if f57a060(0xe000e0) != 0:
				var a := DuelMem.zone(m.u32(0xa161a4) & 1, m.u32(0xa161a8) + m.u32(0xa161ac))
				var level := f4457d0(m.u16(a) & 0xfff)
				if level <= f544b70(p) and _l_target_accept(e) != 0:
					invoke_original(0x564e40, [e, _l_target_location()])
					m.set_u8(0xa15fe6, level)
					m.set_u8(0xa15fe5, 2)
		2:
			# 0x53fb40 + 0x5417e0: mensaje 0xa4 con el numero de cartas.
			dialog_format(0xa4, [{"d": m.u8(0xa15fe6)}])
			m.set_u8(0xa15fe5, 3)
		3:
			# Lista de seleccion (ventana bloqueante); el paso 4 lee la entrada elegida.
			f407580(p, -1, 0x5fc, 0)
			m.set_u8(0xa15fe5, 4)
		4:
			var selected := f4073b0()
			issue(m.u16(e + 2) << 15 | 0xd4, m.u16(selected), m.u16(selected + 2), 0)
			m.set_u8(0xa15fe5, 5)
			m.set_u8(0xa15fe6, m.u8(0xa15fe6) - 1)
		5:
			if m.u8(0xa15fe6) == 0:
				return 1
			dialog_format(0xa5, [{"d": m.u8(0xa15fe6)}])
			m.set_u8(0xa15fe5, 3)
		_:
			return 1
	return 0

## FUN_00567f30: objetivo que puede servir de tributo; CPU usa su selector original.
func f567f30(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if m.u8(0xa15fe5) == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if p != 0:
			var z := f57d7d0(1 - p, -1, 1, 1)
			if f544210(1 - p, z) == 0:
				z = 4
				while z >= 0 and f544210(1 - p, z) == 0:
					z -= 1
			if z >= 0:
				invoke_original(0x564ef0, [e, 1 - p, z])
			return 1
		_l_target_begin(e, 0x96)
		return 0
	if _l_target_cancel():
		return 0
	f564e20()
	if f57a060(0xf00000) == 0:
		return 0
	var owner := m.u32(0xa161a4)
	var z := m.u32(0xa161ac) + m.u32(0xa161a8)
	var valid := 0
	for zone in 5:
		var a := DuelMem.zone(p, zone)
		if (m.u16(a) & 0xfff) != 0 and (m.u8(a + 6) & 2) != 0 and f401a70(m.u16(a) & 0xfff) in [0x58, 0x105, 0x1ff]:
			valid |= f543390(owner, z)
	var a := DuelMem.pl(p)
	if (m.u8(a + 8) & 0x10) == 0:
		for hand in m.u8(a + 2):
			var index := m.u16(a + 0x674 + hand * 4) & 0xfff
			if ctype(index) < 0x15 and f5421c0(index) == 0 and ((f401a20(index) >> 25) & 0xf) > 4:
				valid |= f544210(owner, z)
	if valid != 0:
		return _l_target_accept(e)
	return 0

## FUN_00570450: mascara de acciones de una carta de la mano (indice en EAX).
func f570450(p: int, hand: int, index: int) -> int:
	var phase := (m.u8(0xa133f2) >> 1) & 7
	var kind := (f401a20(index) >> 20) & 0x1f
	var id := f401a70(index)
	var mask := 0
	if phase == 2 or phase == 4:
		if kind == 0x15:
			if f5435a0(p, index) != 0:
				mask = 0x10
			else:
				# Sin zona de magia/trampa libre: ayuda 0xc (help13).
				f4437a0(0xc)
		elif kind == 0x16:
			if f5435a0(p, index) == 0:
				f4437a0(0xc)
			else:
				mask = 0x10 | (8 if f551c40(p, index, 11) != 0 else 0)
				if id == 0x520 and ((m.u8(DuelMem.pl(p & 1) + 0x10) & 2) != 0 or (m.u8(DuelMem.pl(p & 1) + 8) & 0x10) != 0):
					mask = 0x10
				elif id > 0x604 and id < 0x609:
					mask &= ~0x10
		else:
			if f57a490(p, index) == 0:
				# No se puede invocar (p. ej. faltan sacrificios) y es de invocacion especial:
				# ayuda 0xd (help14).
				if f5421c0(index) != 0:
					f4437a0(0xd)
			else:
				if f5421c0(index) == 0:
					if (m.u8(DuelMem.pl(p & 1) + 8) & 0x10) == 0:
						mask = 0x11
					else:
						# Ya invoco este turno: ayuda 2 (help03).
						f4437a0(2)
					if id == 0x17a and f543010(1 - p, 0x4db) + f543010(p, 0x4db) > 0:
						mask |= 0xc00
					elif id == 0x546:
						if f5431b0(0) + 1 < f5431b0(1) and f543330(0) > 0:
							mask |= 0xc00
						if f544280(p, -1) == 0:
							mask &= 0xffee
					elif id == 0x5f0:
						mask |= 0xc00
				elif f56e660(0) == 0:
					f4437a0(0xd)
				else:
					mask = 0xc00
				if f56e660(0) == 0:
					mask &= 0xf3ff
				if f56e600(0) == 0:
					mask &= 0xfffe
			if id == 0x47:
				if f5435a0(p, index) != 0 and f551c40(p, index, 11) != 0 and f543330(p) > 0 and (m.u8(DuelMem.pl(p & 1) + 8) & 0x10) == 0:
					mask |= 8
			elif id == 0x1a8 and f551c40(p, index, 11) != 0:
				mask |= 8
	elif phase == 3:
		# Fase de batalla: trampa 0xf, magia que no sea de velocidad 5 (rapida) 5, monstruo 6.
		if kind == 0x15:
			f4437a0(0xf)
		elif kind == 0x16:
			if f53b880(index) != 5:
				f4437a0(5)
		else:
			f4437a0(6)
	if (m.u8(0xa133f2) & 1) == 0 and kind == 0x16 and ((f401a20(index) >> 17) & 7) == 5 and f5435a0(p, index) != 0 and f551c40(p, index, 11) != 0:
		mask |= 8
	if kind == 0x16 and (mask & 8) != 0 and (f542f30(0, 0x49c) > 0 or f542f30(1, 0x49c) > 0):
		mask &= 0xfff7
	if m.u16(DuelMem.pl(p & 1)) <= (f542f30(1, 0x436) + f542f30(0, 0x436)) * 500:
		mask = 0
	if kind > 0x14 and kind < 0x17 and (m.u8(DuelMem.pl(p & 1) + 7) & 0xc0) != 0:
		mask &= 0xffe7
	return mask

## Preparacion compartida de los selectores: texto en evento, indicadores originales.
func _l_target_begin(e: int, dialog: int) -> bool:
	if m.u8(0xa15fe5) != 0:
		return false
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	f5417e0(dialog)
	m.set_u8(0xa15fe5, 1)
	return true

func _l_target_cancel() -> bool:
	if (m.u32(0xa114a8) & 0x102) == 0:
		return false
	m.set_u8(0xa15fe5, 0)
	return true

func _l_target_location() -> int:
	return ((m.u32(0xa161a8) + m.u32(0xa161ac)) & 0xff) << 8 | (m.u32(0xa161a4) & 0xff)

func _l_target_accept(e: int) -> int:
	return invoke_original(0x564ef0, [e, m.u32(0xa161a4), m.u32(0xa161a8) + m.u32(0xa161ac)])

## FUN_005681f0: objetivo validado por el efecto de carta 0x15.
func f5681f0(e: int) -> int:
	if _l_target_begin(e, 0x97) or _l_target_cancel():
		return 0
	f564e20()
	if f57a060(0xe0) != 0 and f550e00(e, _l_target_location()) != 0:
		return _l_target_accept(e)
	return 0

## FUN_00568470: elige un monstruo 0x57d boca arriba.
func f568470(e: int) -> int:
	if _l_target_begin(e, 0x99):
		return 0
	if f57a060(0xe0) != 0:
		var a := DuelMem.zone(m.u32(0xa161a4) & 1, m.u32(0xa161a8) + m.u32(0xa161ac))
		if (m.u8(a + 6) & 2) != 0 and (m.u16(a) & 0xfff) != 0 and f401a70(m.u16(a) & 0xfff) == 0x57d:
			return _l_target_accept(e)
	return 0

## FUN_00568560: objetivo y aviso de la carta seleccionada.
func f568560(e: int) -> int:
	if _l_target_begin(e, 0x9a):
		return 0
	if m.u8(0xa15fe5) == 1:
		if _l_target_cancel():
			return 0
		f564e20()
		if f57a060(0xf0) != 0 and f550ea0(e, _l_target_location()) != 0 and f579890() != 0:
			f54ea40(m.u32(0xa161a4), _l_target_location())
			invoke_original(0x564e40, [e, _l_target_location()])
			return 1
	return 0

## FUN_005687a0: solo necesita objetivo si el rival tiene defensores boca abajo.
func f5687a0(e: int) -> int:
	if m.u8(0xa15fe5) == 0:
		var other := (-m.u16(e + 2) - 1) & 1
		var found := false
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		for z in 5:
			var a := DuelMem.zone(other, z)
			if (m.u16(a) & 0xfff) != 0 and (m.u16(a + 6) & 3) == 1:
				found = true
		if not found:
			return 1
		_l_target_begin(e, 0x9d)
		return 0
	if m.u8(0xa15fe5) == 1:
		if _l_target_cancel():
			return 0
		f564e20()
		if f57a060(0x900000) != 0:
			return _l_target_accept(e)
	return 0

## FUN_005688f0: excluye la propia carta de sus posibles objetivos.
func f5688f0(e: int) -> int:
	if _l_target_begin(e, 0x9e) or _l_target_cancel():
		return 0
	f564e20()
	if f57a060(0x40004) != 0:
		if m.u32(0xa161a4) != (m.u16(e + 2) & 1) or m.u32(0xa161a8) + m.u32(0xa161ac) != ((m.u16(e + 2) >> 4) & 0x3f):
			return _l_target_accept(e)
	return 0

## FUN_00568cf0: elige un monstruo distinto de la zona de origen.
func f568cf0(e: int) -> int:
	if _l_target_begin(e, 0xa3):
		return 0
	if f57a060(0xe00000) != 0:
		var z := m.u32(0xa161a8) + m.u32(0xa161ac)
		if (m.u32(DuelMem.zone(m.u32(0xa161a4) & 1, z)) & 0xfff) != 0 and m.u8(e + 7) != z:
			return _l_target_accept(e)
	return 0

## FUN_00568fe0: selector general de monstruo rival.
func f568fe0(e: int) -> int:
	if _l_target_begin(e, 0xa6) or _l_target_cancel():
		return 0
	f564e20()
	if f57a060(0xe0000) != 0:
		return _l_target_accept(e)
	return 0

## FUN_00569070: selector general con mascara 0x20002.
func f569070(e: int) -> int:
	if _l_target_begin(e, 0xa7) or _l_target_cancel():
		return 0
	f564e20()
	if f57a060(0x20002) != 0:
		return _l_target_accept(e)
	return 0

## FUN_00569100: selector con validador de control del efecto.
func f569100(e: int) -> int:
	if _l_target_begin(e, 0xa8) or _l_target_cancel():
		return 0
	f564e20()
	if f57a060(0xf000f0) != 0 and f5511a0(e, _l_target_location()) != 0:
		return _l_target_accept(e)
	return 0

## FUN_00568300: seleccion de objetivo tipo 7; CPU busca por ATK/DEF.
func f568300(e: int) -> int:
	if (m.u8(e + 2) & 1) != 0:
		var z := f564f30(e, 0, 1, 1, -1)
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if z >= 0:
			invoke_original(0x564ef0, [e, 0, z])
		return 1
	if m.u8(0xa15fe5) == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		var found := false
		for z in 5:
			var other := 1 - (m.u8(e + 2) & 1)
			var a := DuelMem.zone(other, z)
			if (m.u8(a + 6) & 2) != 0 and (m.u32(a) & 0xfff) != 0 and f545c40(other, z) == 7:
				found = true
		if not found:
			return 1
		_l_target_begin(e, 0x98)
		return 0
	if _l_target_cancel():
		return 0
	f564e20()
	if f57a060(0xe00000) != 0 and f545c40(m.u32(0xa161a4), m.u32(0xa161ac) + m.u32(0xa161a8)) == 7:
		return _l_target_accept(e)
	return 0

## FUN_00568660: selecciona monstruo de origen y despues una zona vacia distinta.
func f568660(e: int) -> int:
	var step := m.u8(0xa15fe5)
	if step == 0 or step == 2:
		if step == 0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		f5417e0(0x9b if step == 0 else 0x9c)
		m.set_u8(0xa15fe5, step + 1)
		return 0
	if step != 1 and step != 3:
		return 1
	if _l_target_cancel():
		return 0
	f564e20()
	if f583e00(m.u16(e)) == 0 or m.u32(0xa161a8) != 0:
		return 0
	var p := m.u32(0xa161a4)
	var z := m.u32(0xa161ac)
	if step == 1:
		if f543260(p, z) == 0:
			return 0
	elif (m.u32(DuelMem.zone(p & 1, z)) & 0xfff) != 0 or _l_target_location() == m.u16(e + 12):
		return 0
	invoke_original(0x564e70, [e, p, z])
	m.set_u8(0xa15fe5, step + 1)
	return 0

## FUN_00568990: dos objetivos distintos con la misma mascara.
func f568990(e: int) -> int:
	return _l_two_targets(e, 0xf0, 0x9f, 0xa0, false)

## FUN_00568bc0: dos objetivos tras comprobar que el primero puede elegirse.
func f568bc0(e: int, option: int) -> int:
	if m.u8(0xa15fe5) == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if invoke_original(0x5551a0, [e, option, 0]) == 0:
			return 1
	return _l_two_targets(e, 0xe000e, 0xa1, 0xa2, true)

func _l_two_targets(e: int, mask: int, first: int, second: int, _checked: bool) -> int:
	var step := m.u8(0xa15fe5)
	if step == 0 or step == 2:
		if step == 0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		f5417e0(first if step == 0 else second)
		m.set_u8(0xa15fe5, step + 1)
		return 0
	if step == 1 or step == 3:
		if _l_target_cancel():
			return 0
		f564e20()
		if f57a060(mask) != 0 and (step == 1 or _l_target_location() != m.u16(e + 12)) and _l_target_accept(e) != 0:
			if step == 3:
				return 1
			m.set_u8(0xa15fe5, step + 1)
	return 0

## FUN_00568ac0: objetivo de la rutina 0x54fc80 despues de abrir accion 9.
func f568ac0(e: int) -> int:
	var step := m.u8(0xa15fe5)
	if step == 0:
		f53e760(m.u8(e + 2) & 1, 9, 0, 0)
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		m.set_u8(0xa15fe5, 1)
		return 0
	if step == 1:
		f5417e0(0x65)
		m.set_u8(0xa15fe5, 2)
		return 0
	if _l_target_cancel():
		return 0
	f564e20()
	if f57a060(0xe000e0) != 0 and f54fc80(e, _l_target_location()) != 0 and _l_target_accept(e) != 0:
		invoke_original(0x564e40, [e, _l_target_location()])
		return 1
	return 0

## FUN_00570040: colocacion o activacion de magia/trampa de la mano.
func f570040(activate: int, chained: int, effect: int) -> int:
	var p := m.u8(0xa1340f) & 1
	var index := m.u32(0xa13404) & 0xffff
	var step := m.u8(0xa1340d)
	if step == 0:
		m.set_u8(0xa13411, f543570(p))
		var prop := f401a20(index)
		if ((prop >> 20) & 0x1f) == 0x16 and ((prop >> 17) & 7) == 2:
			var old := m.u16(DuelMem.zone(p, 10)) & 0xfff
			if old != 0:
				f54e250(p, 10, int(activate == 0))
				if f401a70(old) == 0x14d and (f401a70(index) != 0x14d or activate == 0):
					f54cbb0(0, 0x58f)
					f54cbb0(1, 0x58f)
			m.set_u8(0xa13411, 10)
		f56e0b0(p)
		var packed := (((activate & 0xff) << 8) | (m.u8(0xa13410) << 4) | (m.u8(0xa13411) & 0xf)) & 0x1ff
		issue((m.u16(0xa1340e) & 0xff01) << 7 | 0xc5, f401a70(index), packed, 0)
	elif step != 1:
		var result := 0
		if activate != 0:
			var z := m.u8(0xa13411)
			var owner := (m.u16(0xa1340e) >> 8) & 1
			var entry := m.u32(DuelMem.zone(owner, z))
			if (entry & 0x40000) != 0 and ((entry >> 12) & 1) != owner:
				f54ef00(p, f401ad0(0x443))
				f54ef90(p, 2000)
			var code: int
			var extra := 0
			if effect == 0:
				code = (((m.u16(0xa1340e) & 0xff00) << 7) | (z & 0x1f)) << 16 | index
			else:
				code = ((((m.u16(0xa1340e) & 0xffffff03) << 8 | m.u16(effect + 2)) & 0xfffffc00) | ((z & 0x1f) << 1)) << 15 | index
				extra = m.u32(effect + 6)
			result = f53bac0(code, extra) if chained != 0 else f53baa0(code, extra)
		result = (result & 0xffffff00) | (m.u8(0xa133f2) & 0xe)
		if (result & 0xff) > 2:
			var a := DuelMem.pl(p) + 0x10
			m.set_u8(a, m.u8(a) | 2)
			result = a
		m.set_u8(0xa13408, m.u8(0xa13408) & 0xfd)
		return result
	m.set_u8(0xa1340d, step + 1)
	return 0

## Nivel empleado por las combinaciones originales: magias/trampas 0, tipo24 10.
func _l_level(index: int) -> int:
	var kind := (f401a20(index) >> 20) & 0x1f
	if kind >= 0x15 and kind < 0x18:
		return 0
	if kind == 0x18:
		return 10
	return (f401a20(index) >> 25) & 0xf

## FUN_0056ac80: carta requerida por la tabla en la mano.
func f56ac80(p: int, row: int) -> int:
	var a := DuelMem.pl(p & 1)
	for i in m.u8(a + 2):
		if f401a70(m.u16(a + 0x674 + i * 4) & 0xfff) == (m.u32(0x5aa9f0 + row * 4) & 0x1fff):
			return 1
	return 0

## FUN_0056ad10: suma niveles de la mano omitiendo una copia del indice indicado.
func f56ad10(p: int, excluded: int) -> int:
	var a := DuelMem.pl(p & 1)
	var skipped := false
	var total := 0
	for i in m.u8(a + 2):
		var index := m.u16(a + 0x674 + i * 4) & 0xfff
		if skipped or index != (excluded & 0xffff):
			total += _l_level(index)
		if index == (excluded & 0xffff):
			skipped = true
	return total

## FUN_0056adf0: suma niveles de los monstruos disponibles en el campo.
func f56adf0(p: int) -> int:
	var total := 0
	for z in 5:
		if f543390(p, z) != 0:
			total += _l_level(m.u16(DuelMem.zone(p & 1, z)) & 0xfff)
	return total

## FUN_0056aef0.
func f56aef0() -> int:
	return m.u8(0xa15fe1)

## FUN_0056ac20: fila de ritual por el id del monstruo.
func f56ac20(index: int) -> int:
	var row := 0
	var id := f401a70(index)
	while (m.u32(0x5aa9f0 + row * 4) & 0x3ffe000) != 0:
		if ((m.u32(0x5aa9f0 + row * 4) >> 13) & 0x1fff) == id:
			return row
		row += 1
	return -1

## FUN_0056ae90: busqueda recursiva original de combinaciones de niveles.
func f56ae90(list: int, last: int, required: int, limit: int) -> int:
	while last >= 0:
		var level := _s32c(m.u32(list + last * 4))
		if level < required:
			if last != 0 and f56ae90(list, last - 1, required - level, mini(limit, level)) != 0:
				return 1
		elif level < required + limit:
			return 1
		last -= 1
	return 0

## FUN_0056af00: posibilidad de ritual tras elegir este material.
func f56af00(p: int, location: int, chosen: int) -> int:
	var required := m.u8(0xa15fe1)
	var limit := m.u8(0xa15fe2)
	var current := 0xa15e6c + m.u16(0xa15fc0) * 0x14
	var row := f56ac20(m.u16(current))
	var ritual := m.u32(0x5aa9f0 + row * 4) & 0x1fff
	var index := 0
	if location == 0:
		index = m.u16(DuelMem.zone(p & 1, chosen)) & 0xfff
	elif location == 0xb:
		index = m.u16(DuelMem.pl(p & 1) + 0x674 + chosen * 4) & 0xfff
		if f543360(m.u8(current + 2) & 1) < 0:
			return 0
		if f401a70(index) == ritual and f545060(p, ritual) < 2:
			return 0
	if ((f401a20(index) >> 20) & 0x1f) > 0x14:
		return 0
	var level := _l_level(index)
	if required <= level and level < limit + required:
		return 1
	limit = mini(limit, level)
	var levels: Array[int] = []
	var a := DuelMem.pl(p & 1)
	for i in m.u8(a + 2):
		if location == 0xb and chosen == i:
			continue
		var candidate := m.u16(a + 0x674 + i * 4) & 0xfff
		if f401a70(candidate) == ritual:
			ritual = -1
		else:
			levels.append(_l_level(candidate))
	for z in 5:
		if (location != 0 or chosen != z) and f543390(p, z) != 0:
			levels.append(_l_level(m.u16(DuelMem.zone(p & 1, z)) & 0xfff))
	var list := m.local(maxi(4, levels.size() * 4))
	for i in levels.size():
		m.set_u32(list + i * 4, levels[i])
	return f56ae90(list, levels.size() - 1, required - level, limit)

## FUN_0056b490: comprueba la carta ritual y los materiales del jugador.
func f56b490(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if f56e660(p) == 0:
		return 0
	var row := 0
	while (m.u32(0x5aa9f0 + row * 4) & 0x1fff) != 0:
		var rule := m.u32(0x5aa9f0 + row * 4)
		if ((rule >> 13) & 0x1fff) == f401a70(m.u16(e)):
			if f56ac80(p, row) == 0:
				return 0
			if f543360(p) < 0:
				for z in 5:
					if (m.u32(DuelMem.zone(p, z)) & 0xfff) != 0:
						m.set_u8(0xa15fe2, 0xff)
						m.set_u8(0xa15fe1, rule >> 26)
						if f56af00(p, 0, z) != 0:
							return 1
				return 0
			return int((rule >> 26) <= f56ad10(p, f401ad0(rule & 0x1fff)) + f56adf0(p))
		row += 1
	return 0

## FUN_0056db20: marca y rompe equipos al cambiar el estado de este monstruo.
func f56db20(p: int, z: int) -> int:
	var a := DuelMem.zone(p & 1, z)
	if (m.u16(a + 6) & 0x1000) == 0 and (m.u8(a + 6) & 0x3c) < 0x10:
		f54eed0(p, m.u16(a) & 0xfff, z)
		issue((0x8000 if p != 0 else 0) | 0x8b, z, 1, 0)
		var target := ((z & 0xff) << 8) | (p & 0xff)
		for owner in 2:
			for zone in 5:
				var other := DuelMem.zone(owner, zone)
				if (m.u32(other) & 0xfff) != 0 and (m.u8(other + 6) & 2) != 0 and f545c40(owner, zone) == 2:
					var source := (zone << 8) | owner
					if f543dd0(source, target) != 0:
						f54c860(p, target, source, 2)
	return 0
## Modulo del porte del motor de duelo (ver docs/duel/PORTING.md).


## FUN_0056a430: resuelve la seleccion pendiente antes de continuar el turno.
func f56a430() -> int:
	if (m.u8(0xa16092) & 0x40) == 0:
		return 0
	if f569c30() != 0:
		m.set_u8(0xa16092, m.u8(0xa16092) & 0xbf)
	return 1


## FUN_0056a950: hay una carta que suprime los efectos de magia.
func f56a950() -> int:
	return int(f542f30(0, 0x2ef) != 0 or f542f30(1, 0x2ef) != 0 or f542f30(0, 0x409) != 0 or f542f30(1, 0x409) != 0)


## FUN_0056a9b0: hay una carta que suprime los efectos de trampa.
func f56a9b0() -> int:
	return int(f542f30(0, 0x482) != 0 or f542f30(1, 0x482) != 0)


## FUN_0056a9e0: recalcula supresion de magias/trampas y emite cambios de estado.
## El retorno indica si cambio alguna zona; el llamador Yugi no lo usa.
func f56a9e0() -> int:
	var changed := 0
	m.set_u16(0xa133ec, (m.u16(0xa133ec) & ~0x40) | (f56a950() << 6))
	m.set_u16(0xa133ec, (m.u16(0xa133ec) & 0xff5f) | ((f56a9b0() & 1) << 5))
	if f542f30(0, 0x601) != 0 or f542f30(1, 0x601) != 0:
		m.set_u32(0xa133ec, m.u32(0xa133ec) | 0x80)
	for p in 2:
		for z in range(5, 11):
			var a := DuelMem.zone(p, z)
			var index := m.u16(a) & 0xfff
			if index == 0 or (m.u8(a + 6) & 2) == 0:
				continue
			var prop := f401a20(index)
			var kind := (prop >> 20) & 0x1f
			var flags := m.u32(0xa133ec)
			var suppressed := (flags & (0x40 if kind == 0x15 else 0x20)) != 0
			var subtype := ((prop >> 17) & 7) if kind >= 0x15 and kind <= 0x16 else 0
			match subtype:
				2: suppressed = suppressed or (flags & 0x200) != 0
				3: suppressed = suppressed or (flags & 0x180) != 0
				4:
					if kind == 0x15:
						suppressed = suppressed or (flags & 0x800) != 0
					elif kind == 0x16:
						suppressed = suppressed or (flags & 0x400) != 0
			var id := f401a70(index)
			if id == 0x603:
				suppressed = false
			if id == 0x409 and f542f30(0, 0x2ef) == 0 and f542f30(1, 0x2ef) == 0:
				suppressed = false
			if (m.u16(0xa16180) & 0x100) == 0 or (m.u16(0xa133f2) & 1) == 0:
				if suppressed != ((m.u8(a + 0x8f) & 4) != 0):
					var value := int(suppressed)
					issue((p << 15) | 0xb1, z, value, value)
					changed = 1
	return changed


## FUN_0056e530: efecto continuo sin accion inmediata (p.ej. Regreso seguro).
## El original devuelve0; no debe registrarse como rutina sin portar.
func f56e530() -> int:
	return 0

## FUN_0056e540: busqueda binaria exacta del ID en la tabla de efectos (entradas de 24 bytes).
func f56e540(index: int) -> int:
	var id := f401a70(index) & 0xffff
	var low := 0
	var high := 0x1ad
	var at := 0xd6
	var current := m.u16(0x5abe48)
	while true:
		if id == current:
			return at
		if low == high:
			return -1
		if current < id:
			low = at
		if id < current:
			high = at
		if (high + low) / 2 == at:
			low = high
		at = (high + low) / 2
		current = m.u16(0x5aaa38 + at * 0x18)
	return -1


## FUN_0056dde0: fuerza defensa de monstruos de tipo 1 con la carta 0x148 activa.
## El retorno indica si cambio alguno; el llamador Yugi no lo usa.
func f56dde0(p: int) -> int:
	if f542f30(0, 0x148) <= 0 and f542f30(1, 0x148) <= 0:
		return 0
	var targets: Array[Vector2i] = []
	for owner in 2:
		for z in 5:
			var a := DuelMem.zone(owner, z)
			if (m.u32(a) & 0xfff) != 0 and (m.u16(a + 6) & 3) == 2 and f545c40(owner, z) == 1:
				targets.append(Vector2i(owner, z))
	if not targets.is_empty():
		issue((0x8000 if p != 0 else 0) | 0x1e, 0x148, 1, 0)
		for target in targets:
			f54e660(target.x, target.y, 0, 0)
	return int(not targets.is_empty())


## FUN_0056dc40: efectos continuos de las cartas 0x52 y 0x62 sobre banderas de monstruo.
func f56dc40(p: int) -> int:
	if f543a30(1, 0x52) + f543a30(0, 0x52) <= 0:
		return 0
	for owner in 2:
		for z in 5:
			var a := DuelMem.zone(owner, z)
			var index := m.u16(a) & 0xfff
			var flags := m.u16(a + 6)
			if index != f401ad0(0x62) or (flags & 2) == 0:
				continue
			if (flags & 0x1000) != 0:
				f54eed0(owner, index, z)
				issue((owner << 15) | 0x94, z, 0, 0)
			if owner == p and (flags & 0x3c) < 0x10:
				f54eed0(owner, index, z)
				issue((owner << 15) | 0x8b, z, 1, 0)
	return 0


## FUN_0056e0b0: aplica el coste por invocacion de la carta 0x436.
func f56e0b0(p: int) -> int:
	var count := f542f30(1 - p, 0x436) + f542f30(p, 0x436)
	if count > 0:
		issue((0x8000 if p != 0 else 0) | 0x1e, 0x436, 1, 0)
		issue((0x8000 if p != 0 else 0) | 0x43, count * 500, 1, 0)
	return 0


## FUN_0056e1c0: destruye monstruos equipados cuando la carta 0x464 esta activa.
func f56e1c0(p: int, z: int) -> int:
	if (f543010(0, 0x464) > 0 or f543010(1, 0x464) > 0) and f543cf0(p, z) > 0:
		issue((0x8000 if p != 0 else 0) | 0x1e, 0x464, 1, 0)
		f54e250(p, z, 1)
	return 0


## FUN_0056e280: 0x476 obliga al rival a descartar tras el efecto indicado.
func f56e280(p: int, amount: int) -> int:
	var count := f542f30(p, 0x476)
	if count * amount > 0:
		issue((0x8000 if p != 0 else 0) | 0x1e, 0x476, 0, 0)
		f53e830(1 - p, count * amount, 0, 1)
	return 0


## FUN_0056e460: dano segun monstruos excluidos del rival con la carta 0x5fd.
func f56e460(p: int) -> int:
	var copies := f542f30(p, 0x5fd)
	if copies <= 0:
		return 0
	var other := (~p) & 1
	var count := 0
	# El original usa 0x355 elementos de cuatro bytes para el byte de excluidas.
	for i in m.u8(0xa1194a + other * 0xd54):
		if ctype(m.u16(0xa124b8 + other * 0xd54 + i * 4) & 0xfff) < 0x15:
			count += 1
	if count > 0:
		issue((0x8000 if p != 0 else 0) | 0x1e, 0x5fd, 0, 0)
		f54ef90(1 - p, count * copies * 100)
	return 0


## FUN_0056e600: comprueba bloqueos globales de invocacion especial.
func f56e600(p: int) -> int:
	if (m.u8(0xa1194b + (p & 1) * 0xd54) & 8) != 0:
		return 0
	return int(f542f30(p, 0x592) == 0 and f542f30(0, 0x5f6) == 0 and f542f30(1, 0x5f6) == 0)


## FUN_00569500: restringe las respuestas humanas segun el tipo de accion precedente.
func f569500(p: int, index: int, kind: int) -> int:
	if p != 0:
		return 1
	var id := f401a70(index)
	match kind:
		1: return int((m.u8(0xa133f2) & 1) != 0 and ctype(index) == 0x15)
		3: return m.u8(0xa133f2) & 1
		5, 6: return int(id in [0x3c9, 0x2a8, 0x2a9, 0x3ea, 0x591])
		7: return int(id in [0x3c9, 0x3ea, 0x591])
		8: return int(id == 0x52d)
		13: return int(id in [0x474, 0x49b, 0x518])
		14: return int(id in [0x474, 0x518, 0x5ff])
		15: return int(id in [0x474, 0x518])
		16, 17: return 1
		19: return int(id in [0x3b6, 0x515])
		20: return int(id == 0x46e)
		21: return int(id == 0x46f)
		25: return int(id == 0x470)
		26: return int(id == 0x475)
		27: return int(id == 0x47d)
		29: return int(id == 0x476)
		30: return int(id == 0x515)
	return 0


## FUN_005691b0: valida una respuesta desde el campo y rellena su descriptor.
func f5691b0(entry: int, p: int, z: int) -> int:
	var a := DuelMem.zone(p & 1, z)
	var flags := m.u8(a + 6)
	var index := m.u16(a) & 0xfff
	if index == 0 or ctype(index) < 0x15:
		return 0
	if f401a70(index) not in [0x594, 0x3f9, 0x52c, 0x5fc] and (flags & 2) != 0:
		return 0
	if p == 0:
		f4437a0(4)  # FUN_004437a0: ayuda del original.
	var flags2 := m.u16(a + 0x8e)
	if (flags2 & 0x200) == 0 or (flags2 & 0x400) != 0:
		return 0
	if ctype(index) == 0x15 and (f542f30(0, 0x2ef) != 0 or f542f30(1, 0x2ef) != 0):
		return 0
	if (m.u16(0xa133f2) & 1) != p and f551990(index) <= 1:
		return 0
	if f551990(index) < 2:
		var phase := (m.u16(0xa133f2) >> 1) & 7
		if phase not in [2, 4] or (m.u16(0xa133f2) & 1) != p:
			return 0
	m.set_u16(entry, index)
	m.set_u16(entry + 2, ((z & 0x3f) << 4) | (m.u16(entry + 2) & 0xfc0e) | (p & 1))
	var kind := ctype(index)
	if kind >= 0x15 and kind <= 0x16 and (m.u8(0xa1194b + (p & 1) * 0xd54) & 0xc0) != 0:
		return 0
	return f551a40(entry, 0, 0)


## FUN_00569370: valida una respuesta desde la mano en el turno de su propietario.
func f569370(entry: int, p: int, hand: int) -> int:
	var index := m.u16(0xa11fb8 + (p & 1) * 0xd54 + hand * 4) & 0xfff
	if f5435a0(p, index) == 0 or ctype(index) != 0x16 or (m.u16(0xa133f2) & 1) != p:
		return 0
	m.set_u16(entry, index)
	m.set_u16(entry + 2, (m.u16(entry + 2) & 0xfcbe) | (p & 1) | 0xb0)
	if (m.u8(0xa1194b + (p & 1) * 0xd54) & 0xc0) != 0:
		return 0
	return f551a40(entry, 0, 1)


## FUN_005697e0: hay alguna respuesta rapida valida en campo o mano.
func f5697e0(p: int) -> int:
	for z in range(5, 10):
		var index := m.u16(DuelMem.zone(p & 1, z)) & 0xfff
		if index != 0:
			var speed := f551990(index)
			var valid := f5691b0(0xa160aa, p, z)
			if speed > 1 and valid != 0 and f569500(p, index, m.u16(0xa160ac) >> 10) != 0:
				return 1
	if (m.u16(0xa133f2) & 1) == p:
		for hand in m.u8(0xa11946 + (p & 1) * 0xd54):
			var index := m.u16(0xa11fb8 + (p & 1) * 0xd54 + hand * 4) & 0xfff
			if index != 0:
				var speed := f551990(index)
				var valid := f569370(0xa160aa, p, hand)
				if speed > 1 and valid != 0 and f569500(p, index, m.u16(0xa160ac) >> 10) != 0:
					return 1
	return 0


## FUN_00569440: mascara del menu para una respuesta desde campo o mano.
func f569440(entry: int, p: int, loc: int, index: int) -> int:
	if loc == 5:
		return 8 if f5691b0(entry, p, index + 5) != 0 else 0
	if loc == 0xb:
		var card := m.u16(0xa11fb8 + (p & 1) * 0xd54 + index * 4) & 0xfff
		var speed := f551990(card)
		if speed > 0:
			f4437a0(4)  # FUN_004437a0: ayuda del original.
			if speed > 1:
				return 8 if f569370(entry, p, index) != 0 else 0
		return speed & 0xffff0000
	return loc & 0xffff0000


## FUN_00569c30: ventana de prioridad para respuestas despues de una accion.
func f569c30() -> int:
	var state := m.u8(0xa16091)
	if state == 0:
		m.set_u16(0xa16092, m.u16(0xa16092) & 0xff7f)
		m.set_u16(0xa160aa, 0)
		var p := (m.u8(0xa16092) >> 4) & 1
		m.set_u16(0xa160ac, (m.u16(0xa160ac) & 0x3fe) | p | (m.u16(0xa1608a) << 10))
		m.set_u32(0xa160b0, m.u32(0xa1608c))
		if f5697e0(p) == 0:
			m.set_u8(0xa16091, 0xf0)
			return 0
		m.set_u8(0xa16091, 1)
		state = 1
	if state == 1:
		if (m.u16(0xa16092) & 0x10) != 0:
			m.set_u8(0xa16091, 100 if (m.u16(0xa16180) & 0x100) != 0 else 200)
			return 0
		# FUN_00569940 forma el texto de la pregunta (presentacion); FUN_005417e0 + Si/No.
		f569940(0xa160aa, m.local(256))
		present("response_question", {"effect": 0xa160aa, "context": m.u16(0xa160ac) >> 10})
		dialog_format(int(_response_text["msg"]), _response_text["subs"])
		f540d60(1, 0)
		m.set_u8(0xa16091, 2)
		return 0
	if state == 2:
		if m.u16(0xa16178) == 0:
			m.set_u8(0xa16091, 0xf0)
		else:
			# ASM 569d5b: and byte ptr [0xa13408], 0xfc. La mascara 0xa1340a se conserva
			# (Ghidra lo muestra como escritura de 32 bits). Traza Frida de 2026-10-08.
			m.set_u8(0xa13408, m.u8(0xa13408) & 0xfc)
			m.set_u8(0xa16091, 10)
		return 0
	if state == 10:
		# 569c30 caso 10 (como 53bd50): llama a 57a060 pero decide por el objeto bajo el cursor
		# (5407e0); sin objeto, o con la tecla 2, borra la accion y el clic derecho vuelve a la
		# pregunta Si/No (estado 1).
		f57a060(0xe if (m.u16(0xa133f2) & 1) != 0 else 0xf)
		if f5407e0() != 0 and (m.u32(0xa114a8) & 2) == 0:
			var p := m.u32(0xa161a4)
			var loc := m.u32(0xa161a8)
			var index := m.u32(0xa161ac)
			if f53a160() != 0 or (m.u32(0xa13408) & 1) == 0:
				var hovered := f5407b0()
				m.set_u8(0xa1340c, 0)
				f540bb0()
				if loc in [0, 5, 10, 0xb]:
					if hovered != 0:
						var mask := f569440(0xa160aa, p, loc, index)
						m.set_u16(0xa1340a, mask)
						m.set_u8(0xa13408, (m.u8(0xa13408) & ~1) | int(mask != 0))
				elif loc in [0xc, 0xd, 0xe, 0xf]:
					f571330(p, loc)
			f53a130()
			if (m.u32(0xa13408) & 1) == 0:
				m.set_u8(0xa1340c, 0)
				f540bb0()
			else:
				f53a1a0()
			if (m.u32(0xa13408) & 2) != 0:
				m.set_u8(0xa16091, 11)
			return 0
		m.set_u8(0xa13408, m.u8(0xa13408) & 0xfe)
		m.set_u8(0xa1340c, 0)
		f540bb0()
		if (m.u32(0xa114a8) & 0x102) != 0:
			m.set_u8(0xa16091, 1)
		return 0
	if state == 11:
		var selected := m.u16(0xa1340e)
		var loc := selected >> 9
		if loc == 5:
			m.set_u32(0xa13408, m.u32(0xa13408) & 0xfffffffd)
			var p := (selected >> 8) & 1
			var z := m.u8(0xa13410) + loc
			if (m.u8(DuelMem.zone(p, z) + 6) & 2) == 0:
				issue(((selected & 0xff01) << 7) | 0x91, z, 0, 0)
			var code := ((z & 0x1f) << 16) | (((((selected & 0xffffff03) << 8) | m.u16(0xa160ac)) & 0xfffffc40 | 0x40) << 15) | m.u16(0xa13404)
			f53baa0(code & 0xffffffff, m.u32(0xa160b0))
		elif loc == 0xb:
			f570040(1, 0, 0xa160aa)
			if (m.u32(0xa13408) & 2) != 0:
				return 0
		m.set_u16(0xa16092, (m.u16(0xa16092) & 0xffbf) | 0x80)
		return 1
	if state == 100:
		f53ea40(0xf051, 0xa160aa, 0x14)
		m.set_u16(0xa16092, m.u16(0xa16092) & 0xff7f)
		m.set_u8(0xa16091, 101)
		m.set_u32(0xa15a44, m.u32(0xa15a44) & 0xfffeffff)
		return 0
	if state == 101:
		if ((m.u32(0xa15a44) >> 16) & 1) == 0:
			return 0
		if m.s8(0xa16092) >= 0:
			m.set_u8(0xa16091, 0xf0)
			return 0
		m.set_u16(0xa16092, m.u16(0xa16092) & 0xffbf)
		return 1
	if state == 200:
		var p := (m.u8(0xa16092) >> 4) & 1
		for z in range(5, 10):
			var index := m.u16(DuelMem.zone(p, z)) & 0xfff
			if index != 0:
				var speed := f551990(index)
				var valid := f5691b0(0xa160aa, p, z)
				if speed > 1 and valid != 0 and f57f090(0xa160aa) != 0:
					m.set_u16(0xa16092, (m.u16(0xa16092) & ~0xf) | (z & 0xf))
					m.set_u8(0xa16091, 201)
					return 0
		m.set_u8(0xa16091, 0xf0)
		return 0
	if state == 201:
		var flags := m.u16(0xa16092)
		var p := (flags >> 4) & 1
		var z := flags & 0xf
		if (m.u8(DuelMem.zone(p, z) + 6) & 2) == 0:
			issue(((flags & 0xfff0) << 11) | 0x91, z, 0, 0)
			flags = m.u16(0xa16092)
		var code := ((((flags & 0xfffffff0) << 12) | (m.u16(0xa160ac) & 0xfc40) | (((flags & 0xf) | 0x20) << 1)) << 15) | (m.u32(DuelMem.zone((flags >> 4) & 1, flags & 0xf)) & 0xfff)
		f53baa0(code & 0xffffffff, m.u32(0xa160b0))
		m.set_u16(0xa16092, (m.u16(0xa16092) & 0xffbf) | 0x80)
		return 1
	if state == 240:
		var flags := m.u8(0xa16092)
		flags ^= (((((flags >> 4) & 1) * -0x10) - 1) ^ flags) & 0x10
		m.set_u8(0xa16092, flags)
		if (((flags >> 1) ^ flags) & 0x10) == 0:
			return 1
		m.set_u8(0xa16091, 0)
		return 0
	m.set_u16(0xa16092, m.u16(0xa16092) & 0xffbf)
	return 1


## FUN_0056dd40: recuperacion de LP de ambos jugadores por la carta 0xa5.
func f56dd40(p: int) -> int:
	var own := f543a30(p, 0xa5)
	var other := f543a30(1 - p, 0xa5)
	if own > 0:
		issue((0x8000 if p != 0 else 0) | 0x1e, 0xa5, 0, 0)
		f54f0d0(p, own * 500)
	if other > 0:
		issue((0x8000 if p == 0 else 0) | 0x1e, 0xa5, 0, 0)
		f54f0d0(1 - p, other * 500)
	return 0


## FUN_0056dfd0: suprime magias boca arriba de ambos campos.
func f56dfd0() -> int:
	for p in 2:
		for z in range(5, 10):
			var a := DuelMem.zone(p, z)
			var index := m.u16(a) & 0xfff
			if index != 0 and (m.u8(a + 6) & 2) != 0 and ctype(index) == 0x15:
				issue((p << 15) | 0xb1, z, 1, 0)
	return 0


## FUN_0056e050: dano por cada unidad del efecto de la carta 0x40e.
func f56e050(p: int, amount: int) -> int:
	var count := f542f30(p, 0x40e)
	if count * amount > 0:
		issue((0x8000 if p != 0 else 0) | 0x1e, 0x40e, 0, 0)
		f54ef90(1 - p, count * amount * 500)
	return 0


## FUN_0056e120: destruye todos los monstruos equipados por la carta 0x464.
func f56e120() -> int:
	if f543010(0, 0x464) <= 0 and f543010(1, 0x464) <= 0:
		return 0
	var found := false
	for p in 2:
		for z in 5:
			if f543cf0(p, z) != 0:
				found = true
	if found:
		issue(0x1e, 0x464, 1, 0)
		for p in 2:
			for z in 5:
				if f543cf0(p, z) != 0:
					f54e250(p, z, 1)
	return 0


## FUN_0056e230: roba dos cartas por copia activa de 0x475.
func f56e230(p: int) -> int:
	var count := f542f30(p, 0x475)
	if count > 0:
		issue((0x8000 if p != 0 else 0) | 0x1e, 0x475, 0, 0)
		f54f470(p, count * 2)
	return 0


## FUN_0056e350: emite entrada o salida de exclusion para una carta.
func f56e350(p: int, index: int, mode: int) -> int:
	issue((0x8000 if p != 0 else 0) | (0xd9 if mode != 0 else 0xd8), index, int(mode != 0), 0)
	return 0


## FUN_0056e3b0: una carta 0x5ea cambia de propietario sin 0x453 en ninguno de los campos.
func f56e3b0(p: int, owner: int, z: int) -> int:
	var index := m.u16(DuelMem.zone(owner & 1, z)) & 0xfff
	if f401a70(index) == 0x5ea and p != owner and f543010(0, 0x453) < 1 and f543010(1, 0x453) < 1 and z < 5:
		f54eed0(owner, index, z)
		issue((0x8000 if owner != 0 else 0) | 0x4c, 1, 0, 0)
	return 0


## FUN_0056e660: comprueba las restricciones originales de invocacion.
func f56e660(p: int) -> int:
	if (m.u8(DuelMem.pl(p & 1) + 7) & 0x10) != 0:
		return 0
	if f542f30(p, 0x592) != 0:
		return 0
	for card in [0x5e6, 0x5f6]:
		if f542f30(0, card) != 0 or f542f30(1, card) != 0:
			return 0
	return 1


## FUN_0056def0: recuperacion opcional de la carta 0x1da al comenzar la fase.
func f56def0(p: int) -> int:
	match m.u8(0xa133fe):
		0:
			if f544a00(p, 0x1da) == 0:
				return 1
			if p == 0:
				# Cuadro Si/No 0xd0 con el nombre de la carta 0x1da; se lee en el paso 1.
				dialog_format(0xd0, [{"card": f401ad0(0x1da)}])
				f540d60(1, 0)
			else:
				m.set_u16(0xa16178, 1)
			m.set_u8(0xa133fe, 1)
			return 0
		1:
			if m.u16(0xa16178) != 0:
				f54eed0(p, f401ad0(0x1da), 0xe)
				f54da50(p, 0x1da)
			m.set_u8(0xa133fe, 2)
			return 0
	return 1


## FUN_0056ffe0: cambio de posicion y marca de accion realizada.
func f56ffe0() -> int:
	var p := m.u8(0xa1340f) & 1
	var z := m.u32(0xa13410) & 0xff
	f57cad0(p, z)
	m.set_u8(DuelMem.zone(p, z) + 7, m.u8(DuelMem.zone(p, z) + 7) | 2)
	m.set_u8(0xa13408, m.u8(0xa13408) & 0xfd)
	return DuelMem.zone(p, z) + 6

## Fin de la invocacion de 0x56e6e0: FUN_0057c800 (normal) o FUN_0057cd30 (especial) y
## borra el bit 1 de 0xa13408 (accion terminada).
func _l_summon_done(mode: int, special: bool, zone: int, tributes: int) -> void:
	var p := m.u8(0xa1340f) & 1
	var hand := m.u32(0xa13410) & 0xff
	if special: f57cd30(p, hand, zone, tributes, mode)
	else: f57c800(p, hand, zone, tributes, mode)
	_l_action_end()


func _l_action_end() -> void:
	m.set_u32(0xa13408, m.u32(0xa13408) & 0xfffffffd)


## Paso de 0x56e6e0 en el byte 0xa1340d.
func _l_summon_step(delta := 1) -> void:
	m.set_u8(0xa1340d, m.u8(0xa1340d) + delta)


## Cursor sobre un monstruo propio que se puede sacrificar y clic (0x56eb4a-0x56eb77).
func _l_tribute_pick() -> bool:
	return f57a060(0xf0) != 0 and f544210(m.u32(0xa161a4), m.u32(0xa161ac)) != 0 and f579890() != 0


## Cuadro Si/No de los sacrificios (DAT_005ad288 = mensaje 1, DAT_005ad28c = mensaje 2).
func _l_tribute_question(msg_addr: int, state: int) -> void:
	f5417e0(m.u32(msg_addr))
	f540d60(1, 0)
	m.set_u16(0xa13406, 0)
	m.set_u8(0xa1340d, state)


## Material de la zona del jugador del cursor: el bit 1 de +0x13 del bloque indica que el
## material se toma del campo; si no, del cementerio con la lista de seleccion.
func _l_field_material() -> bool:
	return (m.u8(DuelMem.pl(m.u32(0xa161a4) & 1) + 0x13) & 2) != 0


## FUN_0056e6e0: invocacion humana desde la mano (accion 0 de FUN_0053a400). Paso en
## 0xa1340d; 0xa13406 guarda los sacrificios elegidos; 0xa1340e el contador y las banderas de
## las invocaciones especiales. Las preguntas son cuadros del original (f5417e0/f540d60) y los
## sacrificios se eligen senalando la carta y haciendo clic, con el clic derecho para
## cancelar (0x102 en 0xa114a8), como en el original.
func f56e6e0(mode: int, alternate: int) -> int:
	var p := m.u8(0xa1340f) & 1
	var hand := m.u32(0xa13410) & 0xff
	var index := m.u16(0xa13404)
	var cancel := (m.u32(0xa114a8) & 0x102) != 0
	var cur_p := m.u32(0xa161a4)
	var cur_loc := m.u32(0xa161a8)
	var cur_i := m.u32(0xa161ac)
	var state := m.u8(0xa1340d)
	match state:
		0:
			var id := f401a70(index)
			var special := {0x4e9: 0x50, 0x175: 0x1e, 0x34d: 0x28, 0x5ea: 0x32, 0x5eb: 0x3c,
					0x5ec: 0x46, 0x5ed: 0x46, 0x5ee: 0x46, 0x5ef: 0x46}
			if special.has(id):
				m.set_u16(0xa13406, 0)
				m.set_u8(0xa1340e, 0)
				m.set_u8(0xa1340d, int(special[id]))
				return 0
			if id in [0x37, 0x38, 0x42]:
				# 0xd1 con el nombre de la carta y el de Petit Moth (0x115). Solo mensaje.
				dialog_format(0xd1, [{"card": index}, {"card": f401ad0(0x115)}])
				m.set_u8(0xa1340d, 0x14)
				return 0
			if id == 0x4e2:
				var owner := (m.u16(0xa1340e) & 0x100) >> 8
				if m.u8(0xa11946 + owner * PS) == 1:
					# 0x56e808: f57c800(p, mano, f543360(dueno), 0, 1)
					f57c800(p, hand, f543360(owner), 0, 1)
					_l_action_end()
					return 0
				_l_tribute_question(0x5ad28c, 1)
				return 0
			if id == 0x546 and ((m.u32(0xa13408) >> 2) & 15) in [10, 11]:
				_l_summon_done(mode, true, f543360(p), 0)
				return 0
			# 0x56e92f: el nivel se calcula con el u32 de 0xa13404 en ESI.
			var level := f4457d0(m.u32(0xa13404))
			if level <= 4:
				_l_summon_done(mode, alternate != 0, f543360(p), 0)
				if f401a70(index) == 0x5f0 and ((m.u32(0xa13408) >> 2) & 15) in [10, 11]:
					var other := 1 - p
					if f56ba50(other, 0x447, 0) != 0 and f543330(other) > 0 and f56e660(other) != 0:
						f53baa0(((((m.u32(0xa1340e) & 0xffffff1c) << 7) | ((m.u32(0xa13410) >> 8) & 0x1f) | 0xe40) << 16) | index, 0)
						_l_action_end()
				return 0
			if level <= 6:
				_l_tribute_question(0x5ad288, 10)
				return 0
			_l_tribute_question(0x5ad28c, 1)
			return 0
		1, 2, 3:
			if state == 1:
				if m.u16(0xa16178) == 0:
					_l_action_end()
					return 0
				state = 2
			if state == 2:
				state = 3
			m.set_u8(0xa1340d, state)
			if cancel:
				f464d20()
				_l_tribute_question(0x5ad28c, 1)
				return 0
			if _l_tribute_pick():
				m.set_u16(0xa13406, ((cur_p & 0xff) << 8) | (cur_i & 0xff))
				f465720(cur_p, cur_loc + cur_i)
				_l_summon_step()
			return 0
		4, 5:
			m.set_u8(0xa1340d, 5)
			if cancel:
				f464d20()
				_l_tribute_question(0x5ad28c, 1)
				return 0
			if f57a060(0xf0) == 0:
				return 0
			var first := m.u16(0xa13406)
			if first == (((cur_p & 0xff) << 8) | (cur_i & 0xff)):
				return 0
			if f544210(cur_p, cur_i) == 0 or f579890() == 0:
				return 0
			f465720(cur_p, cur_loc + cur_i)
			_l_summon_step()
			# Byte alto = jugador << 4 | zona del segundo; bajo = el primero igual.
			var hi := (((cur_p << 4) & 0xff) | (cur_i & 0xf)) & 0xff
			var lo := ((((first >> 8) << 4) & 0xff) | (first & 0xf)) & 0xff
			m.set_u16(0xa13406, (hi << 8) | lo)
			return 0
		6:
			var tributes := m.u16(0xa13406)
			_l_summon_done(mode, alternate != 0, tributes & 7, tributes | 0x8080)
			return 0
		10, 11:
			if state == 10:
				if m.u16(0xa16178) == 0:
					_l_action_end()
					return 0
				m.set_u8(0xa1340d, 11)
			if cancel:
				_l_tribute_question(0x5ad288, 10)
				return 0
			if _l_tribute_pick():
				f465720(cur_p, cur_loc + cur_i)
				m.set_u16(0xa13406, (((cur_p << 4) & 0xff) | (cur_i & 0xf)) & 0xff)
				_l_summon_step()
			return 0
		12:
			# Siempre FUN_0057c800, tambien desde la invocacion alternativa.
			var tribute := m.u16(0xa13406)
			_l_summon_done(mode, false, tribute & 7, tribute | 0x80)
			return 0
		0x14:
			if cancel:
				_l_action_end()
				return 0
			if f57a060(0xf0) == 0:
				return 0
			var effect := m.local(0x14)
			m.clear(effect, 0x14)
			m.set_u16(effect, index)
			m.set_u32(effect + 2, (m.u32(0xa1340e) >> 8) & 0xffff0001)
			if f54fa60(effect, ((cur_i & 0xff) << 8) | (cur_p & 0xff)) != 0 and f579890() != 0:
				f57cd30(p, hand, cur_i, cur_i | 0x80, mode)
				_l_action_end()
			return 0
		0x1e:
			dialog_format(0xd2, [{"card": f401ad0((m.u8(0xa1340e) & 15) + 0x172)}])
			_l_summon_step()
			return 0
		0x1f:
			if f57a060(0xe0) == 0:
				return 0
			var owner := cur_p & 1
			var a := DuelMem.zone(owner, cur_i)
			var required := (m.u8(0xa1340e) & 15) + 0x172
			if (m.u16(a) & 0xfff) == 0 or (m.u8(a + 6) & 2) == 0 or f401a70(m.u16(a) & 0xfff) != required or f579890() == 0:
				return 0
			f465720(cur_p, cur_i)
			var old_e := m.u16(0xa1340e)
			var n := old_e & 15
			var desc := m.u32(0xa15be0)
			if n == 0: desc = ((((owner << 12) | (cur_i & 7) | 0x200) << 16) | (desc & 0xeff8ffff)) & 0xffffffff
			elif n == 1: desc = ((((owner << 10) | (cur_i & 7) | 0x80) << 19) | (desc & 0xdfc7ffff)) & 0xffffffff
			elif n == 2: desc = ((((owner << 8) | (cur_i & 7) | 0x20) << 22) | (desc & 0xbe3fffff)) & 0xffffffff
			m.set_u32(0xa15be0, desc)
			m.set_u8(0xa1340e, (m.u8(0xa1340e) & 0xf0) | ((n + 1) & 15))
			if ((n + 1) & 15) > 2:
				var b := (desc >> 24) & 0xff
				var hi := ((((b >> 5) & 1) + 8) * 16 + ((desc >> 19) & 7)) & 0xff
				var lo := ((((b >> 4) & 1) + 8) * 16 + ((desc >> 16) & 7)) & 0xff
				var packed := ((hi << 8) | lo) | (((desc >> 10) & 0x100000) + 0x800000 + ((desc >> 6) & 0x70000))
				f57cd30((old_e >> 8) & 1, hand, cur_i, packed, mode)
				_l_action_end()
				return 0
			_l_summon_step(-1)
			return 0
		0x28:
			var required: int = [0x2e1, 0x2f4, 800][m.u8(0xa1340e) & 15]
			var e := m.u16(0xa1340e) & 0xff0f
			if f542f30(0, 0x58a) == 0 and f542f30(1, 0x58a) == 0 and f543010(0, required) > 0:
				e |= 0x20
			if f545060(0, required) != 0 and ((e & 15) < 2 or f543330(0) > 0):
				e |= 0x10
			m.set_u16(0xa1340e, e)
			if (e & 0xf0) == 0:
				_l_action_end()
				return 0
			var msg := 0xd3 if (e & 0x30) == 0x30 else (0xd4 if (e & 0x10) != 0 else 0xd5)
			dialog_format(msg, [{"card": f401ad0(required)}])
			_l_summon_step()
			return 0
		0x29:
			var required: int = [0x2e1, 0x2f4, 800][m.u8(0xa1340e) & 15]
			var mask := 1 if (m.u8(0xa1340e) & 0x10) != 0 else 0
			if (m.u8(0xa1340e) & 0x20) != 0:
				mask |= 0xe0
			if f57a060(mask) == 0:
				return 0
			var card := f5407b0()
			if (card & 0xffff) == 0 or f401a70(card) != required or f579890() == 0:
				return 0
			if cur_loc == 0:
				f54ea40(cur_p, cur_i)
			elif cur_loc == 0xb:
				if cur_i < hand:
					m.set_u8(0xa13410, hand - 1)
				f54e680(cur_p, cur_i, 0, 1)
			var n := ((m.u8(0xa1340e) & 15) + 1) & 15
			m.set_u8(0xa1340e, (m.u8(0xa1340e) & 0xf0) | n)
			_l_summon_step(-1 if n < 3 else 1)
			return 0
		0x2a, 0x49:
			_l_summon_done(mode, true, f543360(p), 0)
			return 0
		0x32:
			dialog_format(0xd6 if _l_field_material() else 0xd7, [{"msg": 0x1f7}, {"d": 3}])
			_l_summon_step()
			return 0
		0x3c:
			dialog_format(0xd6 if _l_field_material() else 0xd7, [{"msg": 0x213}, {"d": 2}])
			_l_summon_step()
			return 0
		0x35:
			dialog_format(0x2c, [{"d": 2}])
			_l_summon_step()
			return 0
		0x38, 0x3f:
			dialog_format(0x2c, [{"d": 1}])
			_l_summon_step()
			return 0
		0x46:
			var kind: int = {0x5ec: 0x216, 0x5ed: 0x215, 0x5ee: 0x217, 0x5ef: 0x218}.get(f401a70(index), -1)
			if kind >= 0:
				dialog_format(0xd8 if _l_field_material() else 0xd9, [{"msg": kind}])
			else:
				# PENDIENTE: el original pasa un bufer sin inicializar; no ocurre con estos ids.
				f5417e0(0)
			_l_summon_step()
			return 0
		0x33, 0x36, 0x39, 0x3d, 0x40, 0x47:
			if not _l_field_material():
				f407580(cur_p, -1, f401a70(index), 0)
				_l_summon_step()
				return 0
			if f57a060(0xf0) == 0:
				return 0
			var ok := false
			if state in [0x33, 0x36, 0x39]:
				ok = f545c40(cur_p, cur_i) == 3
			elif state in [0x3d, 0x40]:
				ok = f545e70(cur_p, cur_i) == 1
			else:
				ok = f545e70(cur_p, cur_i) == int({0x5ec: 4, 0x5ed: 3, 0x5ee: 5, 0x5ef: 6}.get(f401a70(index), 0))
			if ok and f579890() != 0:
				f54e340(cur_p, cur_i, 0)
				_l_summon_step()
			return 0
		0x34, 0x37, 0x48, 0x3e:
			# La ventana de la lista abierta en el paso anterior ya se cerro (bloqueaba el motor).
			if not _l_field_material():
				f54dba0(cur_p, f4073b0())
			_l_summon_step()
			return 0
		0x3a, 0x41:
			if not _l_field_material():
				f54dba0(cur_p, f4073b0())
			m.set_u8(0xa1340d, 0x49)
			return 0
		0x50:
			var first := f5430d0(p, 0x582)
			var second := f5430d0(p, 0x584)
			if first != 0:
				if second == 0:
					dialog_format(0xdb, [{"card": f401ad0(0x582)}])
				else:
					dialog_format(0xda, [{"card": f401ad0(0x582)}, {"card": f401ad0(0x584)}])
				_l_summon_step()
				return 0
			if second != 0:
				dialog_format(0xdb, [{"card": f401ad0(0x584)}])
				_l_summon_step()
				return 0
			_l_action_end()
			return 0
		0x51:
			if cancel:
				m.set_u8(0xa1340d, 0x50)
				f464d20()
				return 0
			if f57a060(0xf0) == 0 or f544210(cur_p, cur_i) == 0:
				return 0
			# El original indexa el campo con a161a8 & 1, no con el jugador.
			var entry := m.u16(DuelMem.zone(cur_loc & 1, cur_i)) & 0xfff
			if f401a70(entry) not in [0x582, 0x584] or f579890() == 0:
				return 0
			m.set_u16(0xa13406, cur_i & 0xffff)
			f465720(cur_p, cur_loc + cur_i)
			_l_summon_step()
			return 0
		0x52:
			f5417e0(m.u32(0x5ad294))
			_l_summon_step()
			return 0
		0x53:
			if cancel:
				m.set_u8(0xa1340d, 0x50)
				f464d20()
				return 0
			if f57a060(0xf0) == 0 or m.u8(0xa13406) == (cur_i & 0xff) or f544210(cur_p, cur_i) == 0 or f579890() == 0:
				return 0
			f465720(cur_p, cur_loc + cur_i)
			m.set_u16(0xa13406, ((cur_i & 0xff) << 8) | m.u8(0xa13406))
			_l_summon_step()
			return 0
		0x54:
			f54ea40(p, m.u8(0xa13406))
			f54ea40(p, m.u8(0xa13407))
			_l_summon_done(mode, true, m.u8(0xa13406) & 7, 0)
			return 0
	_l_action_end()
	return 0

func _l_remote_advance() -> void:
	var flags := m.u16(0xa16092)
	m.set_u16(0xa16092, (((flags & 0xfe00) + 0x200) ^ (flags & 0x1ff)) & 0xffff)

## FUN_0056a460: respuesta local a la ventana de cadena del rival remoto (duelo en red). Mismas
## piezas que la ventana local 569c30: pregunta Si/No (5417e0 + 540d60), cursor sobre el
## tablero (57a060/5407e0/53a160/5407b0/540bb0/53a1a0) y manejadores de la carta (5aaa48/4c).
## Al terminar manda 0xf053 (efecto) o 0xf056 (respuesta) y, si no responde, 0xf055.
func f56a460() -> int:
	var responding := (m.u8(0xa16094) & 1) != 0
	match m.u16(0xa16092) >> 9:
		0:
			if not responding:
				f569940(0xa160be, m.local(256))
				dialog_format(int(_response_text["msg"]), _response_text["subs"])
			else:
				var template := 7 if ((f401a20(m.u16(0xa160d2)) >> 20) & 31) < 0x15 else 8
				dialog_format(template, [{"card": m.u16(0xa160d2)}])
			f540d60(1, 0)
		1:
			if m.u16(0xa16178) != 0:
				m.set_u8(0xa13408, m.u8(0xa13408) & 0xfc) # ASM 56a542: solo el byte bajo
				_l_remote_advance()
				return 0
			f53ed60(0xf055, 0, 0, 0)
			return 1
		2:
			f57a060(0xee)
			if f5407e0() == 0:
				m.set_u32(0xa13408, m.u32(0xa13408) & 0xfffe)
				m.set_u8(0xa1340c, 0)
				f540bb0()
				# Clic izquierdo o derecho fuera de las cartas: vuelve a la pregunta.
				if (m.u32(0xa114a8) & 0x102) != 0:
					m.set_u16(0xa16092, m.u16(0xa16092) & 0x1ff)
				return 0
			var p := m.u32(0xa161a4)
			var loc := m.u32(0xa161a8)
			var n := m.u32(0xa161ac)
			if f53a160() != 0 or (m.u32(0xa13408) & 1) == 0:
				var hovered := f5407b0()
				m.set_u8(0xa1340c, 0)
				f540bb0()
				match loc:
					0, 5:
						if p == 0 and hovered != 0:
							m.set_u8(0xa1340c, 0)
							var mask := f53bc40(0xa160d2, 0, loc, n) if responding else f569440(0xa160be, 0, loc, n)
							m.set_u16(0xa1340a, mask)
							m.set_u8(0xa13408, (m.u8(0xa13408) & ~1) | int(mask != 0))
					0xc, 0xd, 0xe, 0xf:
						f571330(p, loc)
				if (m.u32(0xa13408) & 1) == 0:
					m.set_u8(0xa1340c, 0)
					f540bb0()
					if (m.u32(0xa13408) & 2) != 0:
						_l_remote_advance()
					return 0
			f53a1a0()
			if (m.u32(0xa13408) & 2) != 0:
				_l_remote_advance()
			return 0
		3:
			m.set_u32(0xa13408, m.u32(0xa13408) & 0xfffd)
			if responding: issue(7, 0, 0, 0)
			var packed := m.u16(0xa1340e)
			var owner := (packed >> 8) & 1
			var z := m.u8(0xa13410) + (packed >> 9)
			if (m.u8(DuelMem.zone(owner, z) + 6) & 2) == 0: issue((((packed & 0xff01) << 7) | 0x91) & 0xffff, z, 0, 0)
			var desc := m.u16(0xa160c0)
			desc ^= (((m.u8(0xa13410) << 4) + (packed >> 5)) ^ desc) & 0x3f0
			m.set_u16(0xa160c0, desc & 0xfffe)
			m.set_u16(0xa160be, m.u16(DuelMem.zone(m.u8(0xa1340f) & 1, (desc & 0x3f0) >> 4)) & 0xfff)
			var entry := f56e540(m.u16(0xa160be))
			m.set_u32(0xa16080, 0 if entry == -1 else effect_column(entry, 0x10))
			m.set_u32(0xa16084, 0 if entry == -1 else effect_column(entry, 0x14))
			m.set_u8(0xa15fe4, 0)
			m.set_u8(0xa15fe5, 0)
		4, 5:
			var handler := m.u32(0xa16080 if (m.u16(0xa16092) >> 9) == 4 else 0xa16084)
			if handler != 0:
				if invoke_original(handler, [0xa160be, 0xa160d2]) == 0:
					return 0
				_l_remote_advance()
				return 0
		_:
			f53ea40(0xf056 if responding else 0xf053, 0xa160be, 0x14)
			return 1
	_l_remote_advance()
	return 0


## FUN_00570350: accion de volteo de una carta ya colocada.
func f570350(action: int) -> int:
	var p := m.u8(0xa1340f) & 1
	var z := m.u32(0xa13410) & 0xff
	if action > 4 and action < 7:
		f54d420(p, z, 0, 0, 1)
	m.set_u8(DuelMem.zone(p, z) + 7, m.u8(DuelMem.zone(p, z) + 7) | 2)
	m.set_u8(0xa13408, m.u8(0xa13408) & 0xfd)
	return DuelMem.zone(p, z) + 6

