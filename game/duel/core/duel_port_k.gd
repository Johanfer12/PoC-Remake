class_name DuelPortK
extends DuelPortJ
## Efectos originales de cartas, lote K; descriptores y memoria del ejecutable.

func _k_player(e: int) -> int:
	return m.u8(e + 2) & 1

func _k_origin(e: int) -> int:
	var v := m.u16(e + 2)
	return (((v >> 4) & 0x3f) << 8) | (v & 1)

func _k_opcode(e: int, opcode: int) -> int:
	return (m.u16(e + 2) << 15) | opcode

func _k_zone(p: int, z: int) -> int:
	return 0xa1195c + (p & 1) * 0xd54 + z * 0x94

func _k_selected_command(e: int, opcode: int, p: int) -> void:
	var entry := f4073b0()
	issue((0x8000 if p != 0 else 0) | opcode, m.u16(entry), m.u16(entry + 2), 0)

## FUN_005620d0: sustituye equipo asociado, marcando descriptor si objetivo desapareció.
func f5620d0(e: int) -> int:
	if not (m.u32(_k_zone(m.u8(e + 12), m.u8(e + 13))) & 0xfff):
		m.set_u8(e + 4, m.u8(e + 4) | 8)
		return 0
	if (m.u8(e + 10) & 7) == 2:
		issue(_k_opcode(e, 0x88), (m.u16(e + 2) >> 4) & 0x3f, m.u16(e + 14), 0)
		f54e730(_k_player(e), _k_origin(e), m.u16(e + 16))
	return 0

## FUN_00562170: elimina monstruos con bandera especial, iterando ambas partes.
func f562170(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var state := m.u8(0xa15fe0)
	if state == 0x80:
		m.set_u8(0xa15fe1, 1 - _k_player(e))
		m.set_u8(0xa15fe0, state - 1)
	elif state != 0x7f:
		return _k_finish_49(e)
	var p := m.u8(0xa15fe1)
	for z in range(5):
		if f551100(e, (z << 8) | p):
			f555570(p, z)
			f56e3b0(_k_player(e), p, z)
			return 0x7f
	p = 1 - p
	m.set_u8(0xa15fe1, p)
	return 0x7f if p == _k_player(e) else _k_finish_49(e)

func _k_finish_49(e: int) -> int:
	var p := _k_player(e)
	issue(_k_opcode(e, 0x49), (m.u16(0xa1194a + p * 0xd54) >> 11) & 1, 1, 0)
	issue((0x8000 if p == 0 else 0) | 0x49, (m.u16(0xa1194a + (1 - p) * 0xd54) >> 11) & 1, 1, 0)
	return 0

## FUN_005622b0: selección opcional de hasta dos cartas del efecto5e7.
func f5622b0(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := _k_player(e)
	match m.u8(0xa15fe0):
		0x7c:
			_k_selected_command(e, 0xd4, 1 - p)
			m.set_u8(0xa15fe1, m.u8(0xa15fe1) - 1)
			return 0x7f
		0x7d:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7c
		0x7e:
			# Respuesta del cuadro Si/No (mensaje 0x4f/0x50).
			if m.u16(0xa16178) == 0:
				return 0
			f5417e0(0x51)
			return 0x7d
		0x7f:
			if m.u8(0xa15fe1) == 0:
				return 0
		0x80:
			m.set_u16(0xa15fe0, 0x27f)
		_:
			return 0
	if f56ba50(p, 0x5e7, 0):
		f5417e0(0x4f + int(m.u8(0xa15fe1) != 2))
		f540d60(1, 0)
		return 0x7e
	return 0

## FUN_00562400: tributa otro monstruo y trae carta del mazo de fusión.
func f562400(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := _k_player(e)
	match m.u8(0xa15fe0):
		0x7a:
			f54c860(p, m.u16(e), (((m.u32(0xa15be0) >> 1) & 31) << 8) | p, 3)
			return 0x78
		0x7b:
			f57cc50(p, f4073b0(), 1, 0, 12, 0)
			return 0x7a
		0x7c:
			_k_selected_command(e, 0xdc, p)
			return 0x7b
		0x7d:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7c
		0x7e:
			f5417e0(0x1a)
			return 0x7d
		0x7f:
			if f57a060(0xf0):
				var z := m.u32(0xa161ac)
				if z != ((m.u16(e + 2) >> 4) & 0x3f) and f543390(p, z) != 0 and f579890():
					f54ea40(p, z)
					return 0x7e
			return 0x7f
		0x80:
			if p == 0 and f56ba50(p, 0x5e8, 0) != 0 and f543400(p, (m.u16(e + 2) >> 4) & 0x3f) != 0:
				f5417e0(0x52)
				return 0x7f
	return 0

## FUN_005625d0: descarta hasta tres candidatos y registra cuántos se descartaron.
func f5625d0(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := _k_player(e)
	var state := m.u8(0xa15fe0)
	match state:
		0x78:
			if m.u8(0xa15fe2):
				f54c860(p, m.u16(e), _k_origin(e), (m.u8(0xa15fe2) << 8) | 11)
			issue(_k_opcode(e, 0x94), (m.u16(e + 2) >> 4) & 0x3f, 0, 0)
			return 0
		0x7c:
			var entry := f4073b0()
			issue((m.u32(entry) >> 12 << 15) | 0xd4, m.u16(entry), m.u16(entry + 2), 0)
			m.set_u8(0xa15fe1, m.u8(0xa15fe1) - 1)
			m.set_u8(0xa15fe2, m.u8(0xa15fe2) + 1)
			return 0x7f if m.u8(0xa15fe1) != 0 else 0x78
		0x7d:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7c
		0x7e:
			# Respuesta del cuadro Si/No (mensaje 0x55/0x26).
			if m.u16(0xa16178) != 0:

				f5417e0(0x25)
				return 0x7d
		0x80:
			m.set_u8(0xa15fe0, 0x7f)
			m.set_u8(0xa15fe1, 3)
			m.set_u8(0xa15fe2, 0)
		0x7f:
			pass
		_:
			issue(_k_opcode(e, 0x94), (m.u16(e + 2) >> 4) & 0x3f, 0, 0)
			return 0
	if state != 0x7e and f56ba50(p, f401a70(m.u16(e)), 0) > 0:
		f5417e0(0x55 if m.u8(0xa15fe2) == 0 else 0x26)
		f540d60(1, 0)
		return 0x7e
	return 0x78

## FUN_005627b0: invoca carta5ea de mano y la asocia al objetivo contrario.
func f5627b0(e: int) -> int:
	var p := _k_player(e)
	if f544a00(p, 0x5ea) != 0 and f543570(p) != -1 and f543360(p) != -1 and (m.u8(e + 10) & 7) == 1:
		var q := m.u8(e + 12)
		var target := m.u8(e + 13)
		var a := _k_zone(q, target)
		if q != p and (m.u32(a) & 0xfff) and (m.u8(a + 6) & 2):
			var z := f543570(p)
			f544950(p, m.u16(e), 0xa1614c)
			issue(_k_opcode(e, 0xd3), m.u16(0xa1614c), m.u16(0xa1614e), 0)
			issue(_k_opcode(e, 0x77), (z & 0xff) | 0x100, m.u16(0xa1614c), m.u16(0xa1614e))
			f54e730(p, ((z & 0xff) << 8) | p, m.u16(e + 12))
	return 0

## FUN_00562920: humano elige objetivo contrario para retirar con avisoa3.
func f562920(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	match m.u8(0xa15fe0):
		0x7f:
			if f57a060(0xe00000) and f579890():
				var z := m.u32(0xa161ac)
				issue((0x8000 if _k_player(e) == 0 else 0) | 0xa3, z, 1, 0)
				f54e660(1 - _k_player(e), z, 0, 0)
				return 0x7e
		0x80:
			f5417e0(0x57)
		_:
			return 0
	return 0x7f

## FUN_005629d0: invocación en campo contrario con propietario adaptado al modo red.
func f5629d0(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := 1 - _k_player(e)
	match m.u8(0xa15fe0):
		0x7e:
			var entry := m.u16(0xa13428) | (m.u16(0xa1342a) << 16)
			var remote := (m.u8(0xa16181) & 1) != 0 and (m.u8(0xa133f2) & 1) != 0
			if remote:
				entry ^= 0x1000
			issue((0x8000 if p != 0 else 0) | 0xd3, entry, entry >> 16, 0)
			if remote:
				entry ^= 0x1000
			var tmp := m.local(4)
			m.set_u32(tmp, entry)
			f57cc50(p, tmp, 1, 0x20, 12, 0)
			return 0x7d
		0x7f:
			if m.u16(0xa13428):
				f53e760(p, 14, m.u16(e), 0)
				return 0x7e
		0x80:
			if f56ba50(p, 0x447, 0) != 0 and f543330(p) != 0 and f56e660(p) != 0:
				f53e760(p, 0x13, 0, 0)
				return 0x7f
	return 0

## FUN_00562b80: retira los dos objetivos indicados por descriptor.
func f562b80(e: int) -> int:
	if not (m.u8(e + 4) & 4) and (m.u16(e + 10) & 7) == 2:
		for i in range(2):
			var p := m.u8(e + 12 + i * 2)
			var z := m.u8(e + 13 + i * 2)
			if m.u32(_k_zone(p, z)) & 0xfff:
				f54e420(p, z, 1)
	return 0

## FUN_00562bf0: devuelve hasta dos cartas seleccionadas a mano.
func f562bf0(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := _k_player(e)
	match m.u8(0xa15fe0):
		0x7d:
			_k_selected_command(e, 0xd2, p)
			m.set_u8(0xa15fe1, m.u8(0xa15fe1) - 1)
			return 0x7f if m.u8(0xa15fe1) else 10
		0x7e:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7d
		0x80:
			var n := f56ba50(p, 0x5f4, 0) & 0xff
			m.set_u8(0xa15fe1, n)
			if n <= 1:
				return 0
			m.set_u16(0xa15fe0, 0x27f)
		0x7f:
			pass
		_:
			return 0
	f5417e0(0x58)
	return 0x7e

## FUN_00562cf0: tributa fuente y cancela magia si no existe bloqueo58a.
func f562cf0(e: int, other: int) -> int:
	if f542f30(0, 0x58a) < 1 and f542f30(1, 0x58a) < 1:
		f54ea40(_k_player(e), (m.u16(e + 2) >> 4) & 0x3f)
		if other != 0 and ctype(m.u16(other)) == 22:
			issue(_k_opcode(e, 0xb0), 1, 0, 0)
	return 0

## FUN_00562d80: cambia equipos visibles al nuevo objetivo o los destruye si no son válidos.
func f562d80(e: int) -> int:
	if not (m.u8(e + 4) & 4) and (m.u8(e + 10) & 7) == 1:
		for p in range(2):
			for z in range(5, 10):
				var a := _k_zone(p, z)
				var idx := m.u16(a) & 0xfff
				if idx != 0 and (m.u8(a + 6) & 2) and ctype(idx) > 20 and ctype(idx) < 23 and csub(idx) == 3:
					var loc := (z << 8) | p
					var valid := f550b10(e, loc)
					if f545fb0(p, z, m.u8(e + 12), m.u8(e + 13)) == 0 or valid == 0:
						f54e250(p, z, 1)
					else:
						f54e850(loc, m.u16(e + 12))
	return 0

## FUN_00562ec0: progresa las cartas605 a608 desde mazo o mano según contador de zona.
func f562ec0(e: int) -> int:
	var p := _k_player(e)
	var z := (m.u16(e + 2) >> 4) & 0x3f
	var free := f543570(p)
	var a := _k_zone(p, z)
	var stage := (m.u8(a + 6) & 0x3c) >> 2
	if not (m.u32(a) & 0xfff) or (m.u8(e + 4) & 4):
		return 0
	if (m.u16(e + 2) & 0xfc00) != 0x1000:
		issue(_k_opcode(e, 0xe5), 0, z, 0)
		return 0
	if stage > 3:
		return 0
	var id := 0x605 + stage
	var flag := 0x8000 if p else 0
	for i in range(m.u8(0xa11947 + p * 0xd54)):
		if s16(f401a70(m.u16(0xa120f8 + p * 0xd54 + i * 4) & 0xfff)) == id:
			issue(flag | 0x8b, z, 1, 0)
			f54f7d0(p, id, free)
			issue(flag | 0xe5, stage + 1, free, 0)
			issue(flag | 0x60, 0, 0, 0)
			return 0
	for i in range(m.u8(0xa11946 + p * 0xd54)):
		var idx := m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff
		if s16(f401a70(idx)) == id:
			issue(flag | 0x8b, z, 1, 0)
			issue(flag | 0xc5, f401a70(idx), ((free & 15) | ((i & 15) << 4)) | 0x100, 1)
			issue(flag | 0xe5, stage + 1, free, 0)
			return 0
	return 0

## FUN_00563170: sustituye objetivo de batalla y retira defensa seleccionada.
func f563170(e: int) -> int:
	if not (m.u8(e + 4) & 4) and (m.u8(e + 10) & 7) == 1:
		var p := m.u8(e + 12)
		var z := m.u8(e + 13)
		var a := _k_zone(p, z)
		if (m.u8(a + 6) & 2) and (m.u32(a) & 0xfff):
			issue((0x8000 if m.u8(e + 6) != 0 else 0) | 0x35, m.u8(e + 7), 1, 0)
			issue(_k_opcode(e, 8), p, z << 8, 0)
			if m.u8(a + 6) & 1:
				f54e660(p, z, 0, 0)
			issue(_k_opcode(e, 0x39), m.u16(e + 12), 1, 0)
	return 0

## FUN_00563250: destruye objetivo visible si su nivel coincide con el declarado.
func f563250(e: int) -> int:
	if not (m.u8(e + 4) & 4) and (m.u8(e + 10) & 7) == 2:
		var p := m.u8(e + 12)
		var z := m.u8(e + 13)
		var a := _k_zone(p, z)
		var idx := m.u16(a) & 0xfff
		if (m.u8(a + 6) & 2) and idx != 0 and ((f401a20(idx) >> 25) & 15) == m.u16(e + 14):
			f555570(p, z)
			f56e3b0(_k_player(e), p, z)
	return 0

## FUN_005632e0: destruye objetivo empaquetado en byte8 del descriptor.
func f5632e0(e: int) -> int:
	var v := m.u8(e + 8)
	var p := v & 15
	var z := v >> 4
	if not (m.u8(e + 4) & 4) and (m.u32(_k_zone(p, z)) & 0xfff):
		f555570(p, z)
		f56e3b0(_k_player(e), p, z)
	return 0

## FUN_00563340: retira objetivo contrario seleccionado.
func f563340(e: int) -> int:
	if (m.u8(e + 10) & 7) == 1:
		var p := m.u8(e + 12)
		var z := m.u8(e + 13)
		if (m.u16(_k_zone(p, z)) & 0xfff) and p != _k_player(e):
			f54e420(p, z, 1)
	return 0

## FUN_005633a0: revela trampa seleccionada; la activa si corresponde o la destruye.
func f5633a0(e: int) -> int:
	var p := m.u8(e + 12)
	var z := m.u8(e + 13)
	var a := _k_zone(p, z)
	var idx := m.u16(a) & 0xfff
	if m.u8(e + 4) & 4:
		f54e250(_k_player(e), (m.u16(e + 2) >> 4) & 0x3f, 1)
		return 0
	if idx != 0 and not (m.u8(a + 6) & 2):
		f54e640(p, z, 0)
		if ctype(idx) != 21:
			f54ef60(p, idx)
			f54e640(p, z, 0)
		else:
			var excluded := [0x431, 0x3de, 0x3ea, 0x3fb, 0x3fd, 0x3fe, 0x404, 0x405, 0x406, 0x407, 0x40e, 0x420, 0x426, 0x3b1, 0x2a8, 0x2a9, 0x2ad, 0x2b1, 0x3b6, 0x3c0, 0x3c9, 0x525, 0x44a, 0x46e, 0x46f, 0x470, 0x471, 0x472, 0x473, 0x474, 0x475, 0x476, 0x47d, 0x4be, 0x4df, 0x515, 0x518, 0x529, 0x52d, 0x590, 0x591, 0x594, 0x5f9, 0x5fb, 0x5ff]
			var activate := false
			if not (f401a70(idx) in excluded):
				var tmp := m.local(20)
				m.clear(tmp, 20)
				m.set_u16(tmp, idx)
				m.set_u32(tmp + 2, ((z & 0x3f) << 4) | (p & 1))
				activate = f551a40(tmp, 0, 0) != 0
			if activate:
				f54eed0(p, idx, z)
				f53baa0((((z & 31) | (p << 15) | 0x20) << 16) | idx, 0)
			else:
				f54e250(p, z, 1)
	f54e510(_k_player(e), (m.u16(e + 2) >> 4) & 0x3f)
	issue(_k_opcode(e, 0x60), 1, 0, 0)
	return 0

## FUN_00563820: deshace fusión y vuelve a invocar sus materiales del cementerio.
func f563820(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := _k_player(e)
	match m.u8(0xa15fe0):
		0x7c:
			var at := 0xa11624 + m.u8(0xa15fe1) * 4
			m.set_u32(at, m.u32(at) & 0xffefffff)
			f57cc50(p, at, 1, 0x20, 14, p)
			return 0x7d
		0x7d:
			if m.u8(0xa15fe1):
				m.set_u8(0xa15fe1, m.u8(0xa15fe1) - 1)
				var at := 0xa11624 + m.u8(0xa15fe1) * 4
				issue(_k_opcode(e, 0xd3), m.u16(at), m.u16(at + 2), 0)
				return 0x7c
		0x7e:
			# Respuesta del cuadro Si/No pedido en 0x7f.
			if m.u16(0xa16178) != 0:

				m.set_u8(0xa15fe1, f56ba50(p, 0x60a, m.u16(0xa16148)))
				return 0x7d
		0x7f:
			f5417e0(0x59)
			f540d60(1, 0)
			return 0x7e
		0x80:
			if (m.u8(e + 10) & 7) == 1 and f5511a0(e, m.u16(e + 12)) != 0:
				var q := m.u8(e + 12)
				var z := m.u16(e + 12) >> 8
				f54e510(q, z)
				m.set_u16(0xa16148, m.u16(_k_zone(q, z)) & 0xfff)
				var free := f543330(p)
				var count := f56ba50(p, 0x60a, m.u16(0xa16148))
				if count != 0 and count <= free:
					return 0 if p else 0x7f
	return 0

## FUN_00563a00: selecciona hasta tres candidatos para comando de.
func f563a00(e: int, _unused: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := _k_player(e)
	match m.u8(0xa15fe0):
		0x7d:
			_k_selected_command(e, 0xde, p)
			m.set_u8(0xa15fe1, m.u8(0xa15fe1) - 1)
			return 0x7f if m.u8(0xa15fe1) else 10
		0x7e:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7d
		0x80:
			if f555520(e) == 0:
				return 0
			m.set_u16(0xa15fe0, 0x37f)
		0x7f:
			pass
		_:
			return 0
	if f56ba50(p, 0x60d, 0):
		f5417e0(0x5a)
		return 0x7e
	return 0

## FUN_00563b10: permite requisitos de espíritus desde campo en vez de cementerio.
func f563b10(e: int) -> int:
	var a := 0xa11957 + _k_player(e) * 0xd54
	m.set_u8(a, m.u8(a) | 2)
	return 0

func _k_normal_id(idx: int) -> int:
	var id := f401a70(idx) & 0xffff
	return id - 2000 if id > 1999 else id

## FUN_005640f0: busca material seleccionado, tratando arte alternativo como mismo ID.
func f5640f0(idx: int) -> int:
	for i in range(m.u8(0xa16106) & 3):
		var material := m.u16(0xa16108 + i * 2)
		if material and _k_normal_id(material) == _k_normal_id(idx):
			return 1
	return 0

## FUN_00564170: consume material exacto o sustituto en la lista de materiales.
func f564170(idx: int) -> int:
	var n := m.u8(0xa16106) & 3
	for i in range(n):
		var material := m.u16(0xa16108 + i * 2)
		if material and _k_normal_id(material) == _k_normal_id(idx):
			m.set_u16(0xa16108 + i * 2, 0)
			return 0
	if f563b40(f401a70(idx)):
		for i in range(n):
			var material := m.u16(0xa16108 + i * 2)
			if material and f563b40(f401a70(material)):
				m.set_u16(0xa16108 + i * 2, 0)
				return 0
	return 0


## FUN_00564250: fusión con selección exacta de dos o tres materiales y un sustituto máximo.
func f564250(e: int, _unused: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := _k_player(e)
	var state := m.u8(0xa15fe0)
	match state:
		0x62:
			issue(_k_opcode(e, 0xe8), f401a70(m.u16(0xa0fb0c)), f401a70(m.u16(0xa0fb10)), f401a70(m.u16(0xa0fb14)) if (m.u8(0xa16106) & 3) == 3 else f401a70(0))
			issue(_k_opcode(e, 0xe9), f401a70(m.u16(0xa16104)), 0, 0)
			f57cc50(p, f4073b0(), 1, 1, 12, 0)
			return 0x61
		99:
			issue(_k_opcode(e, 0xca), 0, 0, 0)
			_k_selected_command(e, 0xdc, p)
			return 0x62
		100:
			return _k_fusion_consume(e)
		0x7e:
			m.set_u16(0xa16104, m.u16(f4073b0()) & 0xfff)
			if f563e50(p, m.u16(0xa16104), 0xa1610e) == 0:
				return 0
			var id := f401a70(m.u16(0xa16104))
			var three := [0x17b, 0x1b9, 0x234]
			var two := [0x1d2, 0xde, 0xe, 0x1d, 0x24, 0x2a, 0x44, 0x55, 0x5b, 0x72, 0x84, 0xa7, 0xbc, 0xd6, 0xd8, 0xe5, 0x10f, 0x125, 0x171, 0x180, 0x184, 0x198, 0x1aa, 0x1b4, 0x1c9, 0x1d0, 0x251, 0x1d6, 0x1d8, 0x1e1, 0x1e6, 0x1ee, 0x1fb, 0x1fc, 0x208, 0x212, 0x214, 0x220, 0x233, 0x23b, 0x4d9, 0x264, 0x268, 0x269, 0x27e, 0x2c2, 0x2c8, 0x32c, 0x5f6, 0x536, 0x57c, 0x5a5, 0x7de, 0x814]
			var v := m.u32(0xa16104)
			if id in three:
				v |= 0x30000
			elif id in two:
				v = (v & 0xfffeffff) | 0x20000
			v &= 0xff0fffff
			v ^= ((v * 4) ^ v) & 0xc0000
			m.set_u32(0xa16104, v)
			if p:
				return 100
			var n := m.u8(0xa16106) & 3
			if n == 2 or n == 3:
				f5417e0(0x5c if n == 2 else 0x5d)
			for i in range(n):
				var loc := m.u16(0xa1610e + i * 2)
				var idx := 0
				if loc & 0x8000:
					idx = m.u16(0xa11fb8 + p * 0xd54 + (loc & 0xff) * 4) & 0xfff
				if loc & 0x4000:
					idx = m.u16(_k_zone(p, loc & 0xff)) & 0xfff
				m.set_u16(0xa16108 + i * 2, idx)
			_k_fusion_set_cursor(((m.u32(0xa16104) >> 18) & 3) - 1)
			return 0x7d
		0x7f:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7e
		0x80:
			if f552e00(e) == 0:
				return 0
			if p:
				var choice := f57d330(m.u16(e))
				if choice < 0:
					return 0
				f4073a0(choice)
				return 0x7e
			f5417e0(0x5b)
			return 0x7f
		0x7d:
			return _k_fusion_pick(e)
	return 0

func _k_fusion_set_cursor(value: int) -> void:
	var v := m.u32(0xa16104)
	m.set_u32(0xa16104, v ^ (((value << 18) ^ v) & 0xc0000))

func _k_fusion_consume(e: int) -> int:
	var p := _k_player(e)
	var v := m.u32(0xa16104)
	var n := m.u8(0xa16106) & 3
	var cursor := (v >> 18) & 3
	if cursor == n:
		for i in range(n - 1, -1, -1):
			var loc := m.u16(0xa1610e + i * 2)
			issue(_k_opcode(e, 0x59), 11 if loc & 0x8000 else 0, s8(loc & 0xff), 0)
		v = m.u32(0xa16104)
		cursor = (v >> 18) & 3
	if cursor == 0:
		return 99
	_k_fusion_set_cursor(cursor - 1)
	cursor = (m.u32(0xa16104) >> 18) & 3
	var loc := m.u16(0xa1610e + cursor * 2)
	var i := loc & 0xff
	if loc & 0x8000:
		for j in range(cursor):
			var prev := m.u16(0xa1610e + j * 2)
			if (prev & 0x8000) and i < (prev & 0xff):
				m.set_u16(0xa1610e + j * 2, prev - 1)
		issue(_k_opcode(e, 0x5a), 11, i, 0)
		f56e0b0(p)
		m.set_u32(0xa0fb0c + cursor * 4, m.u32(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff)
		f54d930(p, i, f5419b0(p, 11, i), 0, 1, 1)
	elif loc & 0x4000:
		issue(_k_opcode(e, 0x5a), 0, i, 0)
		m.set_u32(0xa0fb0c + cursor * 4, m.u32(_k_zone(p, i)) & 0xfff)
		if s16(f401a70(m.u16(e))) == 0x60b:
			f54e340(p, i, 1)
		else:
			f54ec80(p, i)
	return 100

func _k_fusion_pick(e: int) -> int:
	if m.u32(0xa114a8) & 0x102:
		f464d20()  # FUN_00464d20: apaga los marcadores.
		return 0x7e
	var ready := f57a060(0xf1)
	var p := _k_player(e)
	var location := m.u32(0xa161a8)
	var i := m.u32(0xa161ac)
	var idx := 0
	if location == 0:
		idx = m.u16(_k_zone(p, i)) & 0xfff
	elif location == 11:
		idx = m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff
	if idx == 0:
		return 0x7d
	var valid := f5640f0(idx) != 0
	var substitute := f563b40(f401a70(idx)) != 0
	var v := m.u32(0xa16104)
	if substitute:
		valid = (m.u8(0xa16106) & 0xf0) == 0
	var cursor := (v >> 18) & 3
	if location == 0 or location == 11:
		m.set_u16(0xa1610e + cursor * 2, i | (0x4000 if location == 0 else 0x8000))
	var n := m.u8(0xa16106) & 3
	for j in range(cursor + 1, n):
		if m.u16(0xa1610e + j * 2) == m.u16(0xa1610e + cursor * 2):
			valid = false
	var free := f543360(p)
	if free < 0 and location == 11 and cursor == n - 1:
		valid = false
	if valid and ready != 0 and f579890():
		f564170(idx)
		if f563b40(f401a70(idx)):
			m.set_u8(0xa16106, (m.u8(0xa16106) & 15) | ((m.u8(0xa16106) + 16) & 0xf0))
		# 0x564250: FUN_00465760(jugador, a161a8, a161ac), marcador de material de fusion.
		f465760(p, m.u32(0xa161a8), m.u32(0xa161ac))
		v = m.u32(0xa16104)
		if (m.u8(0xa16106) & 12) == 0:
			# El código copia el número total de materiales a los bits del cursor.
			_k_fusion_set_cursor(m.u8(0xa16106) & 3)
			return 100
		_k_fusion_set_cursor(((v >> 18) & 3) - 1)
	return 0x7d


## FUN_00564e20: muestra indicador de navegación para ubicaciones del campo/mano.
func f564e20() -> int:
	var location := _s32c(m.u32(0xa161a8))
	if location >= 0 and location < 12:
		f4437a0(9)  # FUN_004437a0: ayuda del original.
	return 0

## FUN_00564e40: registros EAX/DX originales; añade una palabra al descriptor de objetivos.
func f564e40(e: int, loc: int) -> int:
	if e:
		var n := m.u8(e + 10) & 7
		m.set_u16(e + 12 + n * 2, loc)
		m.set_u16(e + 10, (m.u16(e + 10) & 0xfff8) | ((n + 1) & 7))
	return 0

## FUN_00564e70: ESI=descriptor, EBX=zona; anuncia y añade el objetivo.
func f564e70(e: int, p: int, z: int) -> int:
	var location := 0
	var index := z
	if z > 4:
		location = 5
		index = z - 5
	if z == 10:
		location = 10
		index = 0
	issue(_k_opcode(e, 8), p, ((index & 0xff) << 8) | location, 0)
	f564e40(e, ((z & 0xff) << 8) | (p & 0xff))
	return 0

## FUN_00564ef0: ECX=descriptor, EDI=participante, EAX=zona; valida inmunidad y confirmación.
func f564ef0(e: int, p: int, z: int) -> int:
	if f54f910(m.u16(e), p, z) == 0:
		return 0
	if _k_player(e) == 0 and f579890() == 0:
		return 0
	f564e70(e, p, z)
	return 1

## FUN_00564f30: elige objetivo por mayor/menor ATK o DEF y filtro de la tabla original.
func f564f30(e: int, p: int, atk: int, defense: int, exclude: int) -> int:
	var row := f56e540(m.u16(e))
	var selected := -1
	var best := -1
	var tmp := m.local(12)
	for z in range(5):
		if z == exclude or not (m.u32(_k_zone(p, z)) & 0xfff):
			continue
		if row >= 0:
			var target_fn := effect_column(row, 0x8)
			if target_fn and invoke_original(target_fn, [e, (z << 8) | (p & 0xff)]) == 0:
				continue
		f546470(p, z, tmp)
		var attack_value := _s32c(m.u32(tmp + 4))
		var defense_value := _s32c(m.u32(tmp + 8))
		var value := 0
		if atk == 0:
			if defense != 0:
				value = defense_value
		else:
			value = maxi(attack_value, defense_value) if defense != 0 else attack_value
		if best < 0:
			best = value
			selected = z
		else:
			var better := (atk > 0 and best < value) or (atk < 0 and value < best) or (defense > 0 and best < value) or (defense < 0 and value < best)
			if better:
				if (atk > 0 and best < value) or (atk < 0 and value < best) or (defense > 0 and best < value) or (defense < 0 and value < best):
					best = value
				selected = z
	return selected

## FUN_005650a0: selecciona carta de una lista y registra entrada junto a ubicación.
func f5650a0(e: int) -> int:
	var p := _k_player(e)
	var entry := 0
	if p == 0:
		var state := m.u8(0xa15fe5)
		if state == 0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
			if f56ba50(p, f401a70(m.u16(e)), 0):
				f5417e0(0x5e)
				m.set_u8(0xa15fe5, 1)
				return 0
		elif state == 1:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			m.set_u8(0xa15fe5, 2)
			return 0
		else:
			entry = m.u32(f4073b0())
	else:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		var choice := f57d330(m.u16(e))
		if choice >= 0:
			entry = m.u32(0xa11624 + choice * 4)
	if entry:
		issue(((entry >> 12) << 15) | 0xdf, f401a70(entry & 0xfff), 0, 0)
		f564e40(e, entry & 0xffff)
		f564e40(e, entry >> 16)
	return 1

func _k_human_zone(e: int, message: int, mask: int) -> int:
	if m.u8(0xa15fe5) == 0:
		f5417e0(message)
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		m.set_u8(0xa15fe5, 1)
		return 0
	if m.u32(0xa114a8) & 0x102:
		m.set_u8(0xa15fe5, 0)
		return 0
	f564e20()
	if f57a060(mask):
		return f564ef0(e, m.u32(0xa161a4), m.u32(0xa161a8) + m.u32(0xa161ac))
	return 0

## FUN_00565220: CPU prioriza trampa visible y luego carta oculta; humano elige.
func f565220(e: int) -> int:
	if _k_player(e) == 0:
		return _k_human_zone(e, 0x5f, 0xa000a)
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	for p in range(2):
		for z in range(5, 10):
			var a := _k_zone(p, z)
			var idx := m.u16(a) & 0xfff
			if idx and (m.u8(a + 6) & 2) and ctype(idx) == 21 and f564ef0(e, p, z):
				return 1
		for z in range(5, 10):
			var a := _k_zone(p, z)
			if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 2) and f564ef0(e, p, z):
				return 1
	return 1

## FUN_00565380: selecciona tributo propio con prioridad CPU o máscara humana.
func f565380(e: int) -> int:
	if _k_player(e) == 0:
		return _k_human_zone(e, 0x60, 0xf0)
	var z := f57d110(-1)
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	if z >= 0:
		f564ef0(e, 1, z)
	return 1

## FUN_00565430: selecciona monstruo contrario, por máximo ATK o atacante específico.
func f565430(e: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if f5431b0(0) > 0:
			var z := m.u8(e + 7) if m.u8(e + 6) == 0 else m.u8(e + 9)
			if s16(f401a70(m.u16(e))) != 0x15c:
				z = f564f30(e, 0, 1, 0, -1)
			if z >= 0:
				f564ef0(e, 0, z)
		return 1
	if m.u8(0xa15fe5):
		return _k_human_zone(e, 0, 0xf00000)
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	if f5431b0(1 - _k_player(e)) == 0:
		return 1
	var message := 100
	match f401a70(m.u16(e)):
		0x2da, 0x536:
			message = 99
		0x5e:
			message = 0x61
		0x77, 0x2e6:
			message = 0x62
	f5417e0(message)
	m.set_u8(0xa15fe5, 1)
	return 0

## FUN_00565580: objetivo de destrucción con elección de campo y evaluación CPU.
func f565580(e: int) -> int:
	if (m.u16(e + 2) & 14) == 6:
		return 1
	if _k_player(e) == 0:
		if m.u8(0xa15fe5) == 0:
			return _k_human_zone(e, 0x65, 0xe000e0)
		if m.u32(0xa114a8) & 0x102:
			m.set_u8(0xa15fe5, 0)
			return 0
		f564e20()
		if f57a060(0xe000e0):
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			if f54fc80(e, (z << 8) | p):
				return f564ef0(e, p, z)
		return 0
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	var p := _k_player(e)
	var id := f401a70(m.u16(e))
	if id == 0x290:
		if m.u16(0xa11944 + (1 - p) * 0xd54) < m.u16(0xa11944 + p * 0xd54):
			p = 1 - p
	elif id in [0x58b, 0x416, 0x417, 0x60c]:
		p = 1 - p
	var z := f57d8b0(e, p, -1)
	if z >= 0 and f564ef0(e, p, z):
		return 1
	var best := -1
	var chosen_p := -1
	var chosen_z := -1
	for pass_index in range(2):
		for target in range(5):
			if f54fc80(e, (target << 8) | p):
				var score := f547c60(p, target)
				if (m.u16(_k_zone(p, target)) & 0xfff) == f401ad0(0x1ec):
					score += 500
				if best <= score:
					best = score
					chosen_p = p
					chosen_z = target
		if best >= 0 and chosen_p >= 0 and chosen_z >= 0 and f564ef0(e, chosen_p, chosen_z):
			return 1
		p = 1 - p
	return 1

## FUN_00565800: selección humana de carta contraria con máscara b00000.
func f565800(e: int) -> int:
	return _k_human_zone(e, 0x66, 0xb00000)

## FUN_00565880: solicita tipo mediante diálogo2 y lo añade al descriptor.
func f565880(e: int) -> int:
	if _k_player(e) == 0:
		if m.u8(0xa15fe5) == 0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
			f5417e0(0x67)
			f540d60(2, 0)
			m.set_u8(0xa15fe5, 1)
			return 0
		if m.u8(0xa15fe5) == 1:
			# Boton elegido en el cuadro: el ASM pasa en EDX el dword de 0xa16178.
			f564e40(e, m.u32(0xa16178))
			m.set_u8(0xa15fe5, 2)
			return 0

	else:
		f564e40(e, 0)
	return 1

## FUN_005658e0: objetivo propio para curacion. ASM5658e0 pasa descriptor de pila
## en EAX y cero en EDX a564e40; devuelve1 sin esperar seleccion humana/CPU.
func f5658e0(e: int) -> int:
	f564e40(e, 0)
	return 1

## FUN_00565900: elige dos monstruos distintos con filtro550400.
func f565900(e: int) -> int:
	var state := m.u8(0xa15fe5)
	match state:
		0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
			m.set_u16(e + 2, (m.u16(e + 2) & 0x3ff) | 0x800)
			if f5524b0(e, 0, 0) == 0:
				return 1
		1, 3:
			f5417e0(0x69 if state == 1 else 0x6a)
		2, 4:
			if m.u32(0xa114a8) & 0x102:
				m.set_u8(0xa15fe5, 0)
				return 0
			f564e20()
			if not f57a060(0xe000e0):
				return 0
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			var loc := (z << 8) | p
			if state == 4 and s16(m.u16(e + 12)) == s16(loc):
				return 0
			if f550400(e, loc) == 0 or f564ef0(e, p, z) == 0:
				return 0
			if state == 4 or f5431b0(1) + f5431b0(0) == 1:
				return 1
		_:
			return 0
	m.set_u8(0xa15fe5, state + 1)
	return 0


## FUN_00565aa0: selecciona magia visible o carta oculta mediante filtro550490.
func f565aa0(e: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		for p in range(2):
			for z in range(5, 11):
				var a := _k_zone(p, z)
				var idx := m.u16(a) & 0xfff
				if idx and (m.u8(a + 6) & 2) and ctype(idx) == 22 and f550490(e, (z << 8) | p) != 0 and f564ef0(e, p, z):
					return 1
			for z in range(5, 11):
				var a := _k_zone(p, z)
				if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 2) and f550490(e, (z << 8) | p) != 0 and f564ef0(e, p, z):
					return 1
		return 1
	if m.u8(0xa15fe5) == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if f543480(0, 0, 0, 1) == 0 and f543480(1, 0, 0, 1) == 0:
			return 1
		f5417e0(0x6b)
		m.set_u8(0xa15fe5, 1)
		return 0
	return _k_filtered_human(e, 0x60006, 0x550490)

func _k_filtered_human(e: int, mask: int, filter_fn: int) -> int:
	if m.u32(0xa114a8) & 0x102:
		m.set_u8(0xa15fe5, 0)
		return 0
	f564e20()
	if f57a060(mask):
		var p := m.u32(0xa161a4)
		var z := m.u32(0xa161ac) + m.u32(0xa161a8)
		if filter_fn == 0 or invoke_original(filter_fn, [e, (z << 8) | p]) != 0:
			return f564ef0(e, p, z)
	return 0

func _k_cpu_strength_choice(e: int) -> int:
	var p := 0
	var z := f564f30(e, p, 1, 1, -1)
	if z < 0:
		p = 1
		z = f564f30(e, p, -1, -1, -1)
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	if z >= 0:
		f564ef0(e, p, z)
	return 1

## FUN_00565c80: selecciona monstruo sujeto al filtro550530.
func f565c80(e: int) -> int:
	if _k_player(e):
		return _k_cpu_strength_choice(e)
	if m.u8(0xa15fe5):
		return _k_filtered_human(e, 0xe000e0, 0x550530)
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	for p in range(2):
		for z in range(5):
			if f550530(e, (z << 8) | p):
				dialog_format(0x6c, [{"msg": 0x1f5}])
				m.set_u8(0xa15fe5, 1)
				return 0
	return 1

## FUN_00565df0: selección de objetivo de magia/equipo con tabla de efectos.
func f565df0(e: int, other: int) -> int:
	if _k_player(e):
		return _k_cpu_strength_choice(e)
	if m.u8(0xa15fe5):
		if m.u32(0xa114a8) & 0x102:
			m.set_u8(0xa15fe5, 0)
			return 0
		f564e20()
		if f57a060(0xf000f0):
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			if f56e5b0(e, p, z):
				return f564ef0(e, p, z)
		return 0
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	if f551a40(e, other, 0) == 0 and s16(f401a70(m.u16(e))) != 0x3ff:
		return 1
	var message := 0x6f
	match f401a70(m.u16(e)):
		0x3ff, 500, 0x4bb:
			message = 0x6d
		0x21c:
			message = 0x6e
	f5417e0(message)
	m.set_u8(0xa15fe5, 1)
	return 0

## FUN_00565f40: selección humana mediante máscara d20000.
func f565f40(e: int) -> int:
	return _k_human_zone(e, 0x70, 0xd20000)

## FUN_00565fc0: selecciona dos cartas ocultas distintas, en CPU o humano.
func f565fc0(e: int, _unused: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		var count := 0
		for p in range(2):
			for z in range(5, 10):
				var a := _k_zone(p, z)
				if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 2):
					f564ef0(e, p, z)
					count += 1
					if count == 2:
						return 1
		return 1
	var state := m.u8(0xa15fe5)
	match state:
		0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
			if f552650() == 0:
				return 1
			f5417e0(0x71)
		2:
			f5417e0(0x72)
		1, 3:
			if m.u32(0xa114a8) & 0x102:
				m.set_u8(0xa15fe5, 0)
				return 0
			f564e20()
			if not f57a060(0x20002):
				return 0
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			if state == 3 and s16(m.u16(e + 12)) == s16((z << 8) | p):
				return 0
			if not f564ef0(e, p, z):
				return 0
			if state == 3:
				return 1
		_:
			return 0
	m.set_u8(0xa15fe5, state + 1)
	return 0

func f5666a0(e: int) -> int:
	if m.u8(0xa15fe5) == 0 and f5431f0(_k_player(e), 1, 0) == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		return 1
	return _k_human_zone(e, 0x79, 0xe0)

func f566740(e: int) -> int:
	if _k_player(e):
		return _k_cpu_strength_choice(e)
	return _k_human_zone(e, 0x7a, 0x900090)

func f566810(e: int) -> int:
	if _k_player(e):
		var p := 0
		var z := f564f30(e, p, 1, 0, -1)
		if z < 0:
			p = 1
			z = f564f30(e, p, 1, 0, -1)
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if z >= 0:
			f564ef0(e, p, z)
		return 1
	var id := s16(f401a70(m.u16(e)))
	return _k_human_zone(e, 0x7b if id == 0x3ab or id == 0x5ab else 0x6f, 0xe000e0)

func f566900(e: int) -> int:
	var state := m.u8(0xa15fe5)
	if state == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		var id := s16(f401a70(m.u16(e)))
		if id in [0x3b1, 0x524, 0x527]:
			f5417e0({0x3b1: 0x7c, 0x524: 0x7d, 0x527: 0x7e}[id])
		m.set_u8(0xa15fe5, 1)
		return 0
	if state != 1:
		return 0
	if m.u32(0xa114a8) & 0x102:
		m.set_u8(0xa15fe5, 0)
		return 0
	f564e20()
	if f57a060(0xf0):
		var p := m.u32(0xa161a4)
		var z := m.u32(0xa161ac) + m.u32(0xa161a8)
		if f56e5b0(e, p, z):
			return f564ef0(e, p, z)
	return 0

func f566be0(e: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		for p in range(2):
			for z in range(5, 11):
				if f564ef0(e, p, z):
					return 1
		return 1
	return _k_human_zone(e, 0x81, 0x80008)

func f566cb0(e: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		var z := f564f30(e, 1, -1, -1, -1)
		if z >= 0 and f564ef0(e, 1, z):
			z = f564f30(e, 1, -1, -1, z)
			if z >= 0 and f564ef0(e, 1, z):
				z = f564f30(e, 0, 1, 0, -1)
				if z >= 0:
					f564ef0(e, 0, z)
		return 1
	var state := m.u8(0xa15fe5)
	if state in [0, 2, 4]:
		f5417e0(0x82 + state / 2)
		if state == 0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		m.set_u8(0xa15fe5, state + 1)
		return 0
	if state not in [1, 3, 5]:
		return 1
	if m.u32(0xa114a8) & 0x102:
		m.set_u8(0xa15fe5, 0)
		return 0
	f564e20()
	if f57a060(0xf00000 if state == 5 else 0xf0):
		var p := m.u32(0xa161a4)
		var z := m.u32(0xa161ac) + m.u32(0xa161a8)
		if state == 3 and m.u16(e + 12) == ((z << 8) | p):
			return 0
		if f564ef0(e, p, z):
			if state == 5:
				return 1
			m.set_u8(0xa15fe5, state + 1)
	return 0

func f567720(e: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		for p in range(2):
			for z in range(5, 11):
				var a := _k_zone(p, z)
				if (m.u32(a) & 0xfff) and (m.u8(a + 6) & 2) and f550c80(e, (z << 8) | p):
					f564ef0(e, p, z)
					return 1
			for z in range(5, 11):
				if f550c80(e, (z << 8) | p) and f564ef0(e, p, z):
					return 1
		return 1
	if m.u8(0xa15fe5) == 0:
		f5417e0(0x8d)
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		m.set_u8(0xa15fe5, 1)
		return 0
	return _k_filtered_human(e, 0xe000e, 0x550c80)

func f5678b0(e: int) -> int:
	return _k_human_zone(e, 0x8e, 0xe0000)

func f567940(e: int) -> int:
	var state := m.u8(0xa15fe5)
	if state == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		f53e760(_k_player(e), 10, 0, 0)
	elif state == 5:
		f53e760(1 - _k_player(e), 11, m.u16(0xa13428), m.u16(0xa1342a))
	elif state > 5:
		f564e40(e, m.u32(0xa13428) + 1)
		return 1
	m.set_u8(0xa15fe5, state + 1)
	return 0

func f5679f0(e: int) -> int:
	var state := m.u8(0xa15fe5)
	if state == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		f53e760(_k_player(e), 8, 0, 0)
	elif state == 1:
		f564e40(e, m.u32(0xa13428) + 1)
	else:
		return 1
	m.set_u8(0xa15fe5, state + 1)
	return 0

func f567a50(e: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		for p in range(2):
			for z in range(5):
				var a := _k_zone(p, z)
				if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 2) and f564ef0(e, p, z):
					return 1
		return 0
	return _k_human_zone(e, 0x8f, 0xd000d0)

func f567b30(e: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		for p in range(2):
			for z in range(5, 11):
				if (m.u32(_k_zone(p, z)) & 0xfff) and f56e5b0(e, p, z) and f564ef0(e, p, z):
					return 1
		return 0
	if m.u8(0xa15fe5) == 0:
		f5417e0(0x90)
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		m.set_u8(0xa15fe5, 1)
		return 0
	if m.u32(0xa114a8) & 0x102:
		m.set_u8(0xa15fe5, 0)
		return 0
	f564e20()
	if f57a060(0x20002):
		var p := m.u32(0xa161a4)
		var z := m.u32(0xa161ac) + m.u32(0xa161a8)
		if f56e5b0(e, p, z):
			return f564ef0(e, p, z)
	return 0

func f567e20(e: int) -> int:
	var state := m.u8(0xa15fe5)
	if state == 0 or state == 2:
		if state == 0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		f5417e0(0x94 if state == 0 else 0x95)
		m.set_u8(0xa15fe5, state + 1)
		return 0
	if state != 1 and state != 3:
		return 1
	if m.u32(0xa114a8) & 0x102:
		m.set_u8(0xa15fe5, 0)
		return 0
	f564e20()
	if f57a060(0xf00000 if state == 1 else 0xf0):
		if f564ef0(e, m.u32(0xa161a4), m.u32(0xa161ac) + m.u32(0xa161a8)):
			m.set_u8(0xa15fe5, state + 1)
	return 0

func f5669d0(e: int) -> int:
	var state := m.u8(0xa15fe5)
	match state:
		0:
			f5417e0(0x65)
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		1:
			if m.u32(0xa114a8) & 0x102:
				m.set_u8(0xa15fe5, 0)
				return 0
			f564e20()
			if not f57a060(0xe000e0):
				return 0
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			if not f54fc80(e, (z << 8) | p) or not f564ef0(e, p, z):
				return 0
		2:
			f5417e0(0x7f)
			f540d60(2, 0)
		3:
			# Boton elegido en el cuadro de 2: EDX = dword de 0xa16178 + 1 (ASM 0x566ab2).
			f564e40(e, m.u32(0xa16178) + 1)
			return 1

		_:
			return 0
	m.set_u8(0xa15fe5, state + 1)
	return 0

func f566ae0(e: int) -> int:
	var p := 1 - _k_player(e)
	if m.u8(0xa15fe5) == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if _k_player(e):
			for z in range(5):
				if f550970(e, (z << 8) | p) and f564ef0(e, p, z):
					return 1
			return 1
		f5417e0(0x80)
		m.set_u8(0xa15fe5, 1)
	else:
		f564e20()
		if f57a060(0xe00000):
			var z := m.u32(0xa161ac)
			if f550970(e, (z << 8) | p):
				return f564ef0(e, p, z)
	return 0

func f567210(e: int) -> int:
	if m.u8(0xa15fe5) == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		f5417e0(0x89)
		m.set_u8(0xa15fe5, 1)
	else:
		f564e20()
		if f57a060(0xe000e0):
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			var id := f401a70(m.u32(_k_zone(p, z)) & 0xfff)
			if id > 0x77f and id < 2000:
				return 0
			return f564ef0(e, p, z)
	return 0

func f567c40(e: int) -> int:
	var state := m.u8(0xa15fe5)
	match state:
		0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
			f5417e0(0x91)
		1:
			m.set_u8(0xa15fe6, 0)
			m.set_u8(0xa15fe7, 0)
		2, 3:
			pass
		4:
			return f567c8c(e)
		_:
			return 1
	m.set_u8(0xa15fe5, state + 1)
	return 0

func f567c8c(e: int) -> int:
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	f54ef30(_k_player(e), m.u16(0xa114b2))
	f564e40(e, m.u16(0xa114b2))
	m.set_u8(0xa15fe5, m.u8(0xa15fe5) + 1)
	return 1

func f567ce0(e: int) -> int:
	var state := m.u8(0xa15fe5)
	if state == 0:
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if not invoke_original(0x554130, [e, 0, 0]):
			return 1
		f5417e0(0x92)
		m.set_u8(0xa15fe5, 1)
		return 0
	if state == 2:
		f5417e0(0x93)
		m.set_u8(0xa15fe5, 3)
		return 0
	if state not in [1, 3]:
		return 1
	if m.u32(0xa114a8) & 0x102:
		m.set_u8(0xa15fe5, 0)
		return 0
	f564e20()
	if f57a060(0xe000e0):
		var p := m.u32(0xa161a4)
		var z := m.u32(0xa161ac) + m.u32(0xa161a8)
		if state == 3 and m.u16(e + 12) == ((z << 8) | p):
			return 0
		if f564ef0(e, p, z):
			if state == 3:
				return 1
			m.set_u8(0xa15fe5, 2)
	return 0

func f5672e0(e: int, other: int) -> int:
	var id := s16(f401a70(m.u16(e)))
	var state := m.u8(0xa15fe5)
	if id == 0x525 and (m.u16(e + 2) & 0xfc00) == 0x4000:
		if state:
			f564ef0(e, _k_player(e), m.u16(0xa13428))
			return 1
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		f53e760(_k_player(e), 20, m.u8(e + 9), 0)
	elif state:
		if id not in [0x431, 0x525]:
			return _unported(0x5672e0)
		f564e20()
		if not f57a060(0xf000f0 if id == 0x431 else 0xf0):
			return 0
		var p := m.u32(0xa161a4)
		var z := m.u32(0xa161ac) + m.u32(0xa161a8)
		if f554b30(id, other, p, z):
			return f564ef0(e, p, z)
		return 0
	else:
		dialog_format(0x8a, [{"card": m.u16(other)}])
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	m.set_u8(0xa15fe5, state + 1)
	return 0

func f566ef0(e: int) -> int:
	var id := s16(f401a70(m.u16(e)))
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if id in [0x3f7, 0x433, 0x5fe]:
			var z := m.u8(e + 7) if m.u8(e + 6) == 1 else m.u8(e + 9)
			var flags := m.u8(_k_zone(1, z) + 6)
			if (flags & 2) and not (flags & 1) and f564ef0(e, 1, z):
				return 1
		for p in [1, 0]:
			for z in range(5):
				if (m.u8(_k_zone(p, z) + 6) & 2) and f564ef0(e, p, z):
					return 1
		return 0
	if m.u8(0xa15fe5):
		f564e20()
		if f57a060(0xe000e0):
			return f564ef0(e, m.u32(0xa161a4), m.u32(0xa161ac) + m.u32(0xa161a8))
		return 0
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	var message := 0
	if id in [0x3f7, 0x433, 0x5fe]:
		message = 0x85
	elif id in [0x3f8, 0x434]:
		message = 0x86
	elif id == 0x43a:
		message = 0x87
	else:
		return 1
	f5417e0(message)
	m.set_u8(0xa15fe5, 1)
	return 0

func f566440(e: int) -> int:
	if _k_player(e):
		var z := f564f30(e, 0, 1, 1, -1)
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if z >= 0:
			f564ef0(e, 0, z)
		return 1
	var id := f401a70(m.u16(e))
	if m.u8(0xa15fe5):
		var mask := e
		if id in [0x280, 0x403]:
			mask = 0xf00000
		elif id in [0x42c, 0x4dc, 0x5ea]:
			mask = 0xe00000
		f564e20()
		if f57a060(mask):
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			if f54f910(m.u16(e), p, z) and (id not in [0x42c, 0x4dc] or (m.u8(_k_zone(p, z) + 6) & 2)):
				return f564ef0(e, p, z)
		return 0
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	var p := 1 - _k_player(e)
	var message := 100
	if id in [0x42c, 0x5ea]:
		if not f5431f0(p, 1, 0):
			return 1
		message = 0x78
	else:
		if id == 0x280:
			var a := _k_zone(_k_player(e), (m.u16(e + 2) >> 4) & 0x3f)
			if not (m.u32(a) & 0xfff) or not (m.u8(a + 6) & 2):
				return 1
		if not f5431f0(p, 0, 0):
			return 1
		if id == 0x280:
			message = 0x76
		elif id == 0x403:
			message = 0x77
	f5417e0(message)
	m.set_u8(0xa15fe5, 1)
	return 0

func f567060(e: int) -> int:
	if not _k_player(e):
		return _k_human_zone(e, 0x88, 0x700000)
	var best := 0
	for z in range(5):
		var a := _k_zone(1, z)
		if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 1):
			var atk := f547c60(1, z)
			if best <= atk:
				best = f547c60(1, z)
	if best == 0:
		best = f57d6f0(1, -1, 1, 0)
	m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
	var out := m.local(12)
	for z in range(5):
		var a := _k_zone(0, z)
		if not (m.u32(a) & 0xfff) or (m.u8(a + 6) & 1):
			continue
		f546470(0, z, out)
		if _k_s32(m.u32(out + 4)) >= best and best > _k_s32(m.u32(out + 8)) and f564ef0(e, 0, z):
			return 1
	for z in range(5):
		var a := _k_zone(0, z)
		if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 1) and f564ef0(e, 0, z):
			return 1
	return 1

func f567450(e: int) -> int:
	var state := m.u8(0xa15fe5)
	if state == 0:
		f5417e0(0x8b)
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		m.set_u8(0xa15fe5, 1)
		return 0
	if state == 1:
		f564e20()
		if f57a060(0xff00ff):
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			var loc := ((z & 0xff) << 8) | (p & 0xff)
			if f550b10(e, loc) and f579890():
				pass  # FUN_00438b90(1): sin sonido ni efecto.
				issue(_k_opcode(e, 8), p & 0xffff, ((m.u32(0xa161ac) & 0xff) << 8) | (m.u32(0xa161a8) & 0xff), 0)
				f564e40(e, loc)
				m.set_u8(0xa15fe5, 2)
		return 0
	if state == 2:
		dialog_format(0x8c, [{"card": m.u32(_k_zone(m.u8(e + 12), m.u8(e + 13))) & 0xfff}])
		m.set_u8(0xa15fe5, 3)
		return 0
	if state != 3:
		return 1
	f564e20()
	if not f57a060(0xe000e0):
		return 0
	var p := m.u32(0xa161a4)
	var z := m.u32(0xa161ac) + m.u32(0xa161a8)
	var sp := m.u8(e + 12)
	var sz := m.u8(e + 13)
	if not f545fb0(sp, sz, p, z):
		return 0
	var loc := (z << 8) | p
	if not (m.u8(_k_zone(sp, sz) + 0x90) & 1):
		if s16(f546020(sp, sz)) == s16(loc) or not f564ef0(e, p, z):
			return 0
	else:
		var found := false
		for i in range(maxi(0, _k_s32(m.u32(0xa15fc0) - 1))):
			var a := 0xa15e82 + i * 20
			if (m.u16(a) & 1) == sp and ((m.u16(a) >> 4) & 0x3f) == sz and m.u16(a + 10) != loc and f564ef0(e, p, z):
				found = true
				break
		if not found:
			return 0
	m.set_u8(0xa15fe5, 4)
	return 0

func f566170(e: int, other: int) -> int:
	if _k_player(e):
		m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
		if not f551a40(e, other, 0) or f5431b0(0) < 1:
			return 1
		for attempt in range(2):
			var loc := 0xffff
			if m.u32(0xa16184) & 0x200:
				for z in range(5):
					var id := f401a70(m.u32(_k_zone(1, z)) & 0xfff)
					if (m.u32(_k_zone(1, attempt)) & 0xfff) and id >= 16 and id <= 20 and (attempt == 0 or m.u16(e + 12) != ((z << 8) | 1)):
						loc = (z << 8) | 1
						break
			if loc == 0xffff:
				var z := f57d7d0(0, -1 if attempt == 0 else 0, 1, 1)
				if z >= 0:
					loc = (z & 0xff) << 8
			if loc == 0xffff or (attempt == 1 and loc == m.u16(e + 12)):
				return 1
			f564ef0(e, loc & 0xff, loc >> 8)
		return 1
	var state := m.u8(0xa15fe5)
	match state:
		0:
			m.set_u8(e + 10, m.u8(e + 10) & 0xf8)
			if not f551a40(e, other, 0) or f5431b0(1) + f5431b0(0) == 0:
				return 1
			f5417e0(0x73)
			f540d60(1, 0)
		1, 4:
			# Respuesta del cuadro Si/No (mensaje 0x73 o 0x75).
			if m.u16(0xa16178) == 0:
				return 1
			f5417e0(0x74)

		2, 5:
			if m.u32(0xa114a8) & 0x102:
				m.set_u8(0xa15fe5, 0)
				return 0
			f564e20()
			if not f57a060(0xf000f0):
				return 0
			var p := m.u32(0xa161a4)
			var z := m.u32(0xa161ac) + m.u32(0xa161a8)
			if state == 5 and m.u16(e + 12) == ((z << 8) | p):
				return 0
			if not f564ef0(e, p, z):
				return 0
			if state == 5 or f5431b0(1) + f5431b0(0) == 1:
				return 1
		3:
			f5417e0(0x75)
			f540d60(1, 0)
		_:
			return 0
	m.set_u8(0xa15fe5, state + 1)
	return 0

func _k_s32(v: int) -> int:
	v &= 0xffffffff
	return v - 0x100000000 if v & 0x80000000 else v


