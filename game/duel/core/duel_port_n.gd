class_name DuelPortN
extends DuelPortM
## Estados de fin de turno y decisiones, confirmados en Yugi.

## FUN_0057aca0: invocacion normal con tributos y respuesta antes de sus efectos.
func f57aca0() -> int:
	var desc := m.u32(0xa15be0)
	var idx := m.u16(0xa15be4)
	var p := desc & 1
	var z := (desc >> 1) & 0x1f
	match (m.u16(0xa15bee) & 0xfe0) >> 5:
		0:
			if (desc & 0x4000) != 0:
				issue((desc << 15) | 0xe6, f401a70(idx), _n_summon_args(desc), ((desc >> 26) & 1) + ((desc >> 25) & 1))
			for i in range(2):
				if (desc & (0x2000000 << i)) != 0: issue((((desc >> (28 + i)) & 1) << 15) | 0x57, (desc >> (16 + i * 3)) & 7, 0, 0)
			for i in range(2):
				if (desc & (0x2000000 << i)) != 0: f54ea40((desc >> (28 + i)) & 1, (desc >> (16 + i * 3)) & 7)
			issue((desc << 15) | 0xc4, f401a70(idx), _n_summon_args(desc), 0)
		1:
			if (desc & 0x4000) != 0:
				issue((desc << 15) | 0x6f, f401a70(idx), z, 0)
				m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xf07f) | 0x60)
			else: m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xf15f) | 0x140)
			return 0
		3, 4, 5, 6, 7: return f57a7c0(0x1f)
		8:
			if (m.u32(DuelMem.zone(p, z)) & 0xfff) == 0: return 1
			issue((desc << 15) | 0x92, z, m.u16(0xa15bec), 0)
			f56dd40(p)
			var id := f401a70(idx)
			if id in [0x4d8, 0x4de, 0x534, 0x462, 0x455, 499]:
				f53baa0((((desc & 0x3e) | (desc << 16) | 0x1480) << 15) | idx, (z << 8) | p)
			elif id == 0x585 or id == 0x45e: f54e250(p, z, 1)
			elif id == 0x31c: f54e660(p, z, 0, 0)
		_: return 1
	_n_next_summon()
	return 0

## FUN_0057b6e0: invocacion por volteo; trampa por nivel y efectos de volteo.
func f57b6e0() -> int:
	var desc := m.u32(0xa15be0)
	var idx := m.u16(0xa15be4)
	var p := desc & 1
	var z := (desc >> 1) & 0x1f
	match (m.u16(0xa15bee) & 0xfe0) >> 5:
		0:
			issue((desc << 15) | 0xe6, f401a70(idx), _n_summon_args(desc), 3)
			var attack := (m.u8(DuelMem.zone(p, z) + 6) & 1) == 0
			issue((desc << 15) | (0x80 if attack else 0x7f), z, 1, 0)
			m.set_u8(0xa15bf2, 0 if attack else 1)
		1: issue((desc << 15) | 0x6f, f401a70(idx), z, 0)
		2:
			var prop := f401a20(idx)
			var kind := (prop >> 20) & 0x1f
			var level := 10 if kind == 0x18 else (0 if kind > 0x14 and kind < 0x18 else ((prop >> 25) & 15))
			if level < 3 and (f542f30(0, 0x2ae) > 0 or f542f30(1, 0x2ae) > 0):
				issue((desc << 15) | 0x1e, 0x2ae, 1, 0)
				f54e250(p, z, 1)
				return 1
		3, 4, 5, 6, 7: return f57a7c0(0x20)
		8:
			issue((desc << 15) | 0x92, z, m.u16(0xa15bec), 0)
			f56dd40(p)
			var id := f401a70(idx)
			var zone := DuelMem.zone(p, z)
			if id == 0x31c: f54e660(p, z, 0, 0)
			elif id in [0x462, 0x455, 499, 0x4d8, 0x4de, 0x534] or (id == 0x5e and m.u8(0xa15bf2) != 0):
				if f551c40(p, m.u16(zone) & 0xfff, z) != 0: f53baa0((((desc & 0x3e) | (desc << 16) | 0x1880) << 15) | idx, (z << 8) | p)
			if f541d10(id, 0) != 0 and f551c40(p, m.u16(zone) & 0xfff, z) != 0 and f542f30(0, 0x5fa) == 0 and f542f30(1, 0x5fa) == 0:
				issue((desc << 15) | 0xad, id, 0, 0)
				f53baa0((((desc & 0x3e) | (desc << 16) | 0x1880) << 15) | idx, (z << 8) | p)
		_: return 1
	_n_next_summon()
	return 0

## FUN_0057c0c0: invocacion especial desde la mano tras hasta tres tributos.
func f57c0c0() -> int:
	var desc := m.u32(0xa15be0)
	var idx := m.u16(0xa15be4)
	var p := desc & 1
	var z := (desc >> 1) & 0x1f
	match (m.u16(0xa15bee) & 0xfe0) >> 5:
		0:
			if (desc & 0x4000) != 0: issue((desc << 15) | 0xe6, f401a70(idx), _n_summon_args(desc), 4)
			for i in range(3):
				if (desc & (0x2000000 << i)) != 0: issue((((desc >> (28 + i)) & 1) << 15) | 0x57, (desc >> (16 + i * 3)) & 7, 0, 0)
			for i in range(3):
				if (desc & (0x2000000 << i)) != 0: f54ea40((desc >> (28 + i)) & 1, (desc >> (16 + i * 3)) & 7)
		1:
			var card := 0xa11fb8 + p * PS + ((desc >> 6) & 0xff) * 4
			issue((desc << 15) | 0xc2, m.u16(card), m.u16(card + 2), 0)
			var dest := (((((desc >> 15) & 1) | ((desc >> 1) << 3)) << 1 | ((desc >> 14) & 1)) << 8) | (((desc >> 6) & 0xff) << 4) | 0xb
			issue((desc << 15) | 0x71, dest & 0xffff, m.u16(card), m.u16(card + 2))
			if f57c050(idx) != 0: m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xf07f) | 0x60)
			else: m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xf11f) | 0x100)
			return 0
		3, 4, 5, 6, 7: return f57a7c0(0x21)
		8:
			issue((desc << 15) | 0x92, z, m.u16(0xa15bec), 0)
			if f401a70(idx) == 0x4de: f53baa0((((desc & 0x3e) | (desc << 16) | 0x1480) << 15) | idx, (z << 8) | p)
		_: return 1
	_n_next_summon()
	return 0

## FUN_0057c050: monstruos especiales que abren una ventana de respuesta.
func f57c050(index: int) -> int:
	var id := f401a70(index)
	if id in [0x2fe, 0x175, 0x37, 0x38, 0x42, 0x546, 0x34d, 0x4e9]: return 1
	if id >= 0x2d6 and id <= 0x2d8: return 1
	if id >= 0x5ea and id < 0x5f1: return 1
	return 0

## FUN_00578340: retira cartas marcadas de ambas manos antes del fin de turno.
func f578340() -> int:
	var p := m.u8(0xa133f2) & 1
	match m.u8(0xa133fc):
		0, 1:
			var q := p if m.u8(0xa133fc) == 0 else 1 - p
			for i in range(m.u8(0xa11946 + q * 0xd54)):
				if m.u32(0xa11fb8 + q * 0xd54 + i * 4) & 0x40000:
					f54ef00(q, f401ad0(0x443))
					f54e680(q, i, 0, 1)
					return 0
			if m.u8(0xa133fc) == 1:
				m.set_u16(0xa133fc, m.u8(0xa133fc) + 1 + p)
				return 0
		3:
			issue((m.u16(0xa133f2) << 15) | 2, 0, 0, 0)
		4:
			issue((m.u16(0xa133f2) << 15) | 3, 0, 0, 0)
		2:
			pass
		_:
			if m.u8(0xa16181) & 1:
				f53ed60(0xf002, 0, 0, 0)
			m.set_u16(0xa133f0, m.u16(0xa133f0) + 1)
			return 1
	m.set_u8(0xa133fc, m.u8(0xa133fc) + 1)
	return 0

## FUN_00578a70: entrega el turno al otro jugador después de vaciar comandos.
func f578a70() -> int:
	if not (m.u8(0xa16181) & 1):
		if f53aa20() == 0:
			return 0
	else:
		if m.u32(0xa15a44) & 0x100:
			m.set_u8(0xa16180, m.u8(0xa16180) + 1)
			return 1
		if m.u32(0xa15a44) & 0x400:
			return 0
		if f5788f0() != 0 or not (m.u32(0xa15a44) & 0x80):
			return 0
		m.set_u32(0xa15a44, m.u32(0xa15a44) & 0xffffff7f)
	if not (m.u32(0xa114b4) & 0x200):
		m.set_u8(0xa16180, m.u8(0xa16180) - 6)
	m.set_u16(0xa133f2, m.u16(0xa133f2) ^ 1)
	m.set_u8(0xa133fd, 0)
	m.set_u8(0xa133fc, 0)
	return 0

## FUN_005786a0: despacha la primera selección de efecto por tabla.
func f5786a0() -> int:
	return _n_effect_selection(0xa15bcb, 0x10, 0xa16080, 0xa15fe4)

## FUN_00578720: despacha la segunda selección de efecto por tabla.
func f578720() -> int:
	return _n_effect_selection(0xa15bcc, 0x14, 0xa16084, 0xa15fe5)

func _n_effect_selection(state: int, column: int, target: int, counter: int) -> int:
	if m.u8(state) == 0:
		var idx := f56e540(m.u16(0xa15b9a))
		m.set_u16(0xa15fd4, idx) # ASM 57876c: mov word ptr
		if idx >= 0:
			m.set_u32(target, effect_column(idx, column))
			if m.u32(target) != 0:
				m.set_u8(state, 1)
				m.set_u8(counter, 0)
				return 0
	elif m.u8(state) == 1:
		if invoke_original(m.u32(target), [0xa15b9a, 0xa15bae]) == 0:
			return 0
		m.set_u8(state, 2)
		return 0
	return 1

## FUN_005787a0: invierte participantes y ejecuta selector de efecto remoto.
func f5787a0() -> int:
	if m.u8(0xa15bcd) == 0:
		for a in [0xa15b9c, 0xa15bb0]:
			m.set_u8(a, m.u8(a) ^ 1)
		for a in [0xa15ba0, 0xa15ba2, 0xa15bb4, 0xa15bb6]:
			m.set_u8(a, 1 - m.u8(a))
		var idx := f56e540(m.u16(0xa15b9a))
		m.set_u16(0xa15fd4, idx) # ASM 57889f: mov word ptr
		if idx >= 0:
			m.set_u32(0xa15fd8, effect_column(idx, 0x4))
			if m.u32(0xa15fd8):
				m.set_u8(0xa15bcd, 1)
				m.set_u16(0xa15fe0, 0x80)
				return 0
	elif m.u8(0xa15bcd) == 1:
		var other := 0xa15bae if m.u8(0xa15bce) & 1 else 0
		var v := invoke_original(m.u32(0xa15fd8), [0xa15b9a, other])
		m.set_u8(0xa15fe0, v)
		if v & 0xff:
			return 0
		m.set_u8(0xa15bcd, 2)
		return 0
	return 1

## FUN_00578bd0: cantidad restante de cartas que seleccionar.
func f578bd0() -> int:
	return m.u8(0xa16101)

## FUN_00578b00: selección humana de descarte con filtros de tipo y banderas.
func f578b00(monster: int, mode: int, no_spell: int) -> int:
	if m.u8(0xa11946) == 0:
		return 1
	if f57a060(1):
		var i := m.u32(0xa161ac)
		var card := m.u32(0xa11fb8 + i * 4)
		var valid := true
		var typ := (f401a20(card & 0xfff) >> 20) & 31
		if monster != 0 and typ > 20:
			valid = false
		if no_spell != 0 and typ == 22:
			valid = false
		if card & 0x20000:
			valid = false
		if not (card & 0x40000) and valid and f579890():
			f54e680(0, i, mode, 1)
			return 1
	return 0

## FUN_00578be0: descarta varias cartas seleccionadas por el humano.
func f578be0() -> int:
	if m.u8(0xa11946) == 0:
		return 1
	match m.u8(0xa1617d):
		0:
			var flags := m.u32(0xa13418)
			if f578b00(flags & 1, flags & 2, flags & 4) == 0:
				return 0
		1:
			pass
		2:
			m.set_u8(0xa16101, m.u8(0xa16101) - 1)
			if m.u8(0xa16101) == 0:
				return 1
			m.set_u8(0xa1617d, 0)
			return 0
		_:
			return 0
	m.set_u8(0xa1617d, m.u8(0xa1617d) + 1)
	return 0

## FUN_00579890: confirma una selección ya validada por la escena.
func f579890() -> int:
	return m.u32(0xa114a8) & 0x201

## FUN_0057a060: el cursor esta sobre un objeto cuya ubicacion admite la mascara. Las rutinas
## que piden elegir una carta o zona comprueban despues el clic con FUN_00579890.
func f57a060(mask: int) -> int:
	if f5407e0() != 0:
		if f579630(m.u32(0xa161a4), m.u32(0xa161a8), m.u32(0xa161ac), mask) != 0:
			return 1
	return 0

## FUN_00579630: filtra zona, orientación y tipo por máscara de selección.
func f579630(p: int, z: int, i: int, mask: int) -> int:
	var shift := (p << 4) & 31
	var a := 0xa1195c + (p & 1) * 0xd54 + (z + i) * 0x94
	var entry := m.u32(a) if z < 10 else 0
	var flags := m.u8(a + 6) if z < 10 else 0
	match z:
		0:
			if (entry & 0xfff) == 0:
				return 0
			var face := ((mask & (0x20 << shift)) != 0 and (flags & 2) != 0) or ((mask & (0x10 << shift)) != 0 and (flags & 2) == 0)
			var pos := ((mask & (0x80 << shift)) != 0 and (flags & 1) != 0) or ((mask & (0x40 << shift)) != 0 and (flags & 1) == 0)
			return int(face and pos)
		5:
			var bits := mask & (0xe << shift)
			if bits == 0 or (entry & 0xfff) == 0:
				return 0
			if not (flags & 2):
				return int((mask & (2 << shift)) != 0)
			if bits != ((2 << shift) & 0xffff):
				var typ := (f401a20(entry & 0xfff) >> 20) & 31
				return int((mask & ((8 if typ == 21 else 4) << shift)) != 0)
		10:
			a = 0xa11f24 + (p & 1) * 0xd54
			if m.u32(a) & 0xfff:
				return int((mask & ((4 if m.u8(a + 6) & 2 else 2) << shift)) != 0)
		11:
			return int((mask & (1 << shift)) != 0 and i < m.u8(0xa11946 + (p & 1) * 0xd54))
	return 0

## FUN_00578500: pregunta asociada a cartas especiales antes de enviar respuesta remota.
## Paso 0: cuadro Si/No con el mensaje de la carta; paso 1: guarda la respuesta en 0xa15b98.
func f578500() -> int:
	var id := f401a70(m.u16(0xa15b92))
	var special := id == 0x4db or id == 0x39 or (id >= 0x172 and id <= 0x174) or id == 0x5f2 or id == 0x76d
	if m.u16(0xa15b90) != 0: # ASM 578500: movzx word
		if m.u16(0xa15b90) == 1:
			if not special:
				return 0
			m.set_u16(0xa15b98, m.u16(0xa16178))
		return 1
	if id == 0x39 or id == 0x76d:
		# Ambas preguntan con el nombre de la carta 0x39 (mensaje 0xe3).
		dialog_format(0xe3, [{"card": f401ad0(0x39)}])
		f540d60(1, 0)
	elif special:
		# 0x4db: mensaje 0xe2; 0x172-0x174: 0xe1; 0x5f2: 0xf8, con el nombre de la carta.
		var msg := 0xe2 if id == 0x4db else (0xf8 if id == 0x5f2 else 0xe1)
		dialog_format(msg, [{"card": m.u16(0xa15b92)}])
		f540d60(1, 0)
	m.set_u16(0xa15b90, m.u16(0xa15b90) + 1) # ASM 578645: inc word ptr
	return 0

## FUN_005788f0: procesa decisiones pendientes del protocolo de duelo remoto.
func f5788f0() -> int:
	var flags := m.u32(0xa15a44)
	if (m.u32(0xa15b8c) & 1) and not (flags & 0x400):
		if f578500() == 0:
			return 1
		m.set_u32(0xa15b8c, m.u32(0xa15b8c) & 0xfffffffe)
		f53ed60(0xf058, m.u16(0xa15b98), m.u16(0xa15b94), m.u16(0xa15b96))
		return 1
	if flags & 0x800000:
		if f5786a0():
			m.set_u8(0xa15b9c, m.u8(0xa15b9c) | 1)
			m.set_u32(0xa15a44, flags & 0xff7fffff)
			f53ea40(0xf092, 0xa15b9a, 0x14)
	elif flags & 0x200000:
		if f578720():
			m.set_u8(0xa15b9c, m.u8(0xa15b9c) | 1)
			m.set_u32(0xa15a44, flags & 0xffdfffff)
			f53ea40(0xf082, 0xa15b9a, 0x14)
	elif (flags & 0x8000) and not (flags & 0x400):
		if f56a460():
			m.set_u32(0xa15a44, flags & 0xffff7fff)
	elif flags & 0x2000000:
		if f5787a0():
			m.set_u32(0xa15a44, flags & 0xfdffffff)
			f53ed60(0xf073, 0, 0, 0)
	elif flags & 0x8000000:
		if anim_busy():
			return 1
		m.set_u32(0xa15a44, flags & 0xf7ffffff)
		f53ed60(0xf065, 0, 0, 0)
	else:
		return 0
	return 1

## FUN_00578da0: descarta de la mano con prioridades originales de la CPU.
func f578da0(p: int, count: int, _unused: int, mode: int) -> int:
	if m.u8(0xa13426) == 0:
		m.set_u8(0xa16100, 0)
		m.set_u8(0xa16101, count)
		m.set_u8(0xa13426, 1)
		return 0
	if m.u8(0xa13426) != 1:
		return 1
	if p == 0:
		# Cursor a la mano y ventana de descarte (tipo 8) con el mensaje 0xeb.
		f53f7e0(0, 0xb, 0)
		f5417e0(0xeb)
		f540d60(8, 0)
		m.set_u8(0xa13426, 2)
		return 0
	if m.u8(0xa16101) == 0 or m.u8(0xa11946 + (p & 1) * 0xd54) == 0:
		m.set_u8(0xa13426, 2)
		return 0
	var i := f57e380()
	if i < 0:
		i = f57de50(0xa11944, 1)
	if mode == 0 and i < 0:
		i = f544f30(1)
	if i < 0:
		i = f544eb0(1)
		if i < 0:
			i = 0 if m.u8(0xa1269a) < 3 else rng.rand() % m.u8(0xa1269a)
	f54e680(p, i, 0, 1)
	m.set_u8(0xa16101, m.u8(0xa16101) - 1)
	return 0

## FUN_00578ee0: descarta aleatoriamente, consumiendo exactamente un rand por carta.
func f578ee0(p: int, mode: int, count: int) -> int:
	return _n_random_hand(p, mode, count, 0)

## FUN_00578fb0: retira aleatoriamente cartas con comando c1.
func f578fb0(p: int, mode: int, count: int) -> int:
	return _n_random_hand(p, mode, count, 0xc1)

## FUN_00579090: consume RNG pero usa el índice seleccionado, comando ce.
func f579090(p: int, mode: int, count: int) -> int:
	return _n_random_hand(p, mode, count, 0xce)

func _n_random_hand(p: int, mode: int, count: int, opcode: int) -> int:
	var n := m.u8(0xa11946 + (p & 1) * 0xd54)
	if n == 0:
		return 1
	if m.u8(0xa13426) == 0:
		m.set_u8(0xa13426, 1)
		m.set_u8(0xa16101, count)
		m.set_u8(0xa16100, 0)
		return 0
	if m.u8(0xa16101) == 0:
		return 1
	var r := rng.rand()
	var i := (m.u32(0xa161ac) & 0xff) if opcode == 0xce else r % n
	var flag := 0x8000 if p != 0 else 0
	issue(flag | 0x21, 0, 0, 0)
	issue(flag | 8, p, (i << 8) | 0xb, 0)
	if opcode == 0:
		f54e680(p, i, mode, 1)
	else:
		issue(flag | opcode, m.u32(0xa161ac) & 0xffff, 1, 0)
	m.set_u8(0xa16101, m.u8(0xa16101) - 1)
	m.set_u8(0xa16100, 0)
	return 0

## FUN_00579460: consulta selección de atributo.
func f579460() -> int:
	return _n_answer(0xf1, 4, 0xa13428)

## FUN_005794a0: consulta selección de tipo.
func f5794a0() -> int:
	return _n_answer(0xf2, 5, 0xa13428)

## Paso 0: cuadro con el mensaje y el tipo `dialog` (4 o 5; en 0x540db0 caen en la rama por
## defecto, la ventana Si/No); paso 1: copia la respuesta de 0xa16178 en `dest`.
func _n_answer(message: int, dialog: int, dest: int) -> int:
	if m.u8(0xa13426) == 0:
		f5417e0(message)
		f540d60(dialog, 0)
		m.set_u8(0xa13426, 1)
		return 0
	m.set_u16(dest, m.u16(0xa16178))
	return 1

## FUN_005794e0: solicita dos tipos sucesivos conservando ambas respuestas.
func f5794e0() -> int:
	var state := m.u8(0xa13426)
	if state > 0:
		# Respuesta del cuadro anterior: primero 0xa13428 y despues 0xa1342a.
		m.set_u16(0xa13428 if state == 1 else 0xa1342a, m.u16(0xa16178))
		if state != 1:
			return 1
	f5417e0(0xf2 if state == 0 else 0xf3)
	f540d60(5, 0)
	m.set_u8(0xa13426, state + 1)
	return 0

## FUN_00579fe0: elige entre cinco valores por RNG o selección humana.
func f579fe0() -> int:
	if m.u16(0xa13412) & 0x400:
		m.set_u16(0xa13428, m.u16(0xa13416 + (rng.rand() % 5) * 2))
		return 1
	if m.u8(0xa13426):
		# La respuesta del cuadro indexa los cinco valores de 0xa13416.
		m.set_u16(0xa13428, m.u16(0xa13416 + m.u16(0xa16178) * 2))
		return 1
	# Tipo 10: en 0x540db0 cae en la rama por defecto (ventana Si/No).
	f5417e0(0xf6)
	f540d60(10, 0)
	m.set_u8(0xa13426, 1)
	return 0


## FUN_0057a0a0: comprueba alternativas de invocación especial y cupo de invocación.
func f57a0a0(p: int) -> int:
	var blocked := f542f30(0, 0x58a) > 0
	blocked = (f542f30(1, 0x58a) > 0) or blocked
	if p != 0 and f545060(p, 0x34d) == 0:
		return 0
	var count := 0
	for id in [0x2e1, 0x2f4, 800]:
		var available := f543010(p, id) != 0 and not blocked
		if available:
			count += 1
		if f545060(p, id) == 0 and not available:
			return 0
	return int(f543330(p) != 0 or count != 0)

## FUN_0057a1d0: comprueba invocación con al menos dos monstruos disponibles.
func f57a1d0(p: int) -> int:
	if f542f30(0, 0x58a) > 0 or f542f30(1, 0x58a) > 0:
		return 0
	var a := f5430d0(p, 0x582)
	var b := f5430d0(p, 0x584)
	return int((a != 0 or b != 0) and f544280(p, 0xffffffff) > 1)

## FUN_0057da00: suma la evaluación de los cinco monstruos.
func f57da00(p: int) -> int:
	var total := 0
	for z in range(5):
		total += f547c60(p, z)
	return total

## FUN_0057dad0: cuenta piezas de Exodia en el campo de la CPU.
func f57dad0() -> int:
	var total := 0
	for z in range(5):
		var idx := m.u16(0xa126b0 + z * 0x94) & 0xfff
		if idx:
			var id := f401a70(idx)
			if id > 15 and id < 21:
				total += 1
	return total

## FUN_0057db20: elige carta de la mano humana por tabla de prioridad, o al azar.
func f57db20() -> int:
	var n := m.u8(0xa11946)
	for priority in range(25):
		var wanted := s16(m.u16(0x5ad368 + priority * 2))
		for i in range(n):
			if s16(f401a70(m.u16(0xa11fb8 + i * 4) & 0xfff)) == wanted:
				return i
	# El original presupone una mano no vacía.
	return rng.rand() % n

## FUN_00578c40: descarte con actualización de prioridad y aviso al terminar.
func f578c40(p: int, count: int, _unused: int, mode: int) -> int:
	if m.u8(0xa11946 + (p & 1) * 0xd54) == 0:
		return 1
	match m.u8(0xa13426):
		0:
			m.set_u8(0xa16100, 0)
			m.set_u8(0xa16101, count)
		1:
			if f5720d0(p):
				# Cursor a la mano y ventana de descarte (tipo 8) con el mensaje 0xeb.
				f53f7e0(p, 0xb, 0)
				f5417e0(0xeb)
				f540d60(8, 0)
				m.set_u8(0xa13426, 2)
				return 0
			if m.u8(0xa16101):
				var i := f57e380()
				if i < 0:
					i = f57de50(0xa11944, 1)
				if i < 0:
					i = f544f30(1)
				if i < 0:
					i = f544eb0(1)
				if i < 0:
					i = 0 if m.u8(0xa1269a) < 3 else rng.rand() % m.u8(0xa1269a)
				f54e680(p, i, mode, 1)
				m.set_u8(0xa16101, m.u8(0xa16101) - 1)
				return 0
		2:
			f56a380(1 - (m.u8(0xa133f2) & 1), 0x1d, p & 0xff)
		_:
			return 1
	m.set_u8(0xa13426, m.u8(0xa13426) + 1)
	return 0

## FUN_00579160: selecciona carta para la rutina de traslado ea40.
func f579160(p: int) -> int:
	if m.u8(0xa13426) == 0:
		if f543400(p, 0xffffffff):
			if p == 0:
				f5417e0(0xec)
				m.set_u8(0xa13426, 1)
				return 0
			var i := f57ceb0(0xffffffff, 1)
			if i >= 0:
				f54ea40(p, i)
		return 1
	if f57a060(0xf0) and f579890():
		var q := m.u32(0xa161a4)
		var z := m.u32(0xa161a8)
		var i := m.u32(0xa161ac)
		if z == 11:
			issue((0x8000 if p != 0 else 0) | 8, q, ((i & 0xff) << 8) | 11, 0)
		f54ea40(q, i + z)
		return 1
	return 0

## FUN_00579540: selecciona carta de la mano contraria y revela la elegida.
func f579540(p: int) -> int:
	if p != 0:
		var i := f57db20()
		m.set_u16(0xa13428, i)
		issue(0x8008, 0, ((i & 0xff) << 8) | 11, 0)
		return 1
	match m.u8(0xa13426):
		0:
			f5417e0(0xf4)
			m.set_u8(0xa13426, 1)
		1:
			m.set_u32(0xa126a4, m.u32(0xa126a4) | 1)
			if f57a060(0x10000) and f579890():
				var i := m.u32(0xa161ac)
				m.set_u16(0xa13428, i)
				issue(8, m.u32(0xa161a4), ((i & 0xff) << 8) | (m.u32(0xa161a8) & 0xff), 0)
				m.set_u8(0xa13426, 2)
		_:
			m.set_u32(0xa126a4, m.u32(0xa126a4) & 0xfffffffe)
			return 1
	return 0

## FUN_0057a250: requisitos de los seis espíritus, cementerio o campo según bandera.
func f57a250(p: int, idx: int) -> int:
	var base := (p & 1) * 0xd54
	var field := (m.u16(0xa11956 + base) & 0x200) != 0
	if f542f30(1 - p, 0x5e7) > 0 and not field:
		return 0
	var id := f401a70(idx)
	var count := 1
	var attr := 0
	match id:
		0x5ea:
			count = 3
		0x5eb:
			count = 2
			attr = 1
		0x5ec:
			attr = 4
		0x5ed:
			attr = 3
		0x5ee:
			attr = 5
		0x5ef:
			attr = 6
	if field:
		for z in range(5):
			if (m.u16(0xa1195c + base + z * 0x94) & 0xfff) == 0:
				continue
			var value := f545c40(p, z) if id == 0x5ea else f545e70(p, z)
			if value == (3 if id == 0x5ea else attr):
				count -= 1
				if count == 0:
					return 1
	else:
		for i in range(m.u8(0xa11948 + base)):
			var prop := f401a20(m.u16(0xa12238 + base + i * 4) & 0xfff)
			var valid := ((prop >> 20) & 31) == 3 if id == 0x5ea else (((prop >> 20) & 31) < 21 and (prop >> 29) == attr)
			if valid:
				count -= 1
				if count == 0:
					return 1
	return 0

## FUN_0057c710: prepara el descriptor de invocación y su notificación remota.
func f57c710() -> int:
	m.set_u16(0xa15bf0, m.u16(0xa15bf0) & 0x8000)
	var p := m.u32(0xa15be0) & 1
	var a := 0xa1194c + p * 0xd54
	m.set_u8(a, m.u8(a) | 0x20)
	m.set_u8(0xa15bf2, 0)
	var bits := m.u16(0xa15bee) & 0xf01d
	m.set_u16(0xa15bee, bits | 1)
	if p != 0 and (m.u8(0xa16181) & 1):
		m.set_u16(0xa15bee, bits | 3)
		f53ea40(0xf05a, 0xa15be0, 0x14)
		m.set_u32(0xa15a44, m.u32(0xa15a44) & 0xffffefff)
	return 0

## FUN_0057c7a0: invierte propietario del descriptor de invocación.
func f57c7a0() -> int:
	m.set_u16(0xa15bf0, m.u16(0xa15bf0) & 0x8000)
	m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xf01f) | 3)
	m.set_u32(0xa15be0, m.u32(0xa15be0) & 0xfffffffe)
	m.set_u8(0xa15bf2, 0)
	m.set_u32(0xa15be8, m.u32(0xa15be8) ^ 0x1000)
	return 0

## FUN_0057cad0: prepara descriptor de carta ya colocada en el campo.
func f57cad0(p: int, z: int) -> int:
	m.set_u32(0xa15be0, (((z & 0xff) | 0x100) << 5 | (z & 0x1f)) << 1 | (m.u32(0xa15be0) & 0xf9c04000) | (p & 1))
	m.set_u16(0xa15be4, m.u16(0xa1195c + (p & 1) * 0xd54 + z * 0x94) & 0xfff)
	m.set_u16(0xa15bec, 3)
	m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xffef) | 0xc)
	f57c710()
	return 0

## FUN_0057cb60: prepara descriptor con dos indicadores de invocación especial.
func f57cb60(p: int, card: int, a: int, b: int, flags: int, lo: int, hi: int) -> int:
	if f542f30(0, 0x47f) != 0 or f542f30(1, 0x47f) != 0:
		a = 1
	var v := m.u32(0xa15be0)
	v = v ^ ((v ^ p) & 1)
	var z := f543360(p)
	m.set_u32(0xa15be0, ((((b & 1) << 1 | (a & 1)) << 13 | (z & 31)) << 1) | (((hi * 16 + lo) & 0xff) << 6) | (v & 0xf9c00001))
	m.set_u16(0xa15bec, flags)
	m.set_u16(0xa15be4, m.u16(card) & 0xfff)
	f541cb0(0xa15be8, card)
	m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xfff3) | 0x10)
	m.set_u16(0xa15bec, flags | 4)
	f57c710()
	return 0

## FUN_0057cc50: prepara descriptor de invocación especial.
func f57cc50(p: int, card: int, a: int, flags: int, lo: int, hi: int) -> int:
	if f542f30(0, 0x47f) != 0 or f542f30(1, 0x47f) != 0:
		a = 1
	var v := m.u32(0xa15be0)
	v = v ^ ((v ^ p) & 1)
	var z := f543360(p)
	m.set_u32(0xa15be0, (((a & 1) << 13 | (z & 31)) << 1) | (((hi * 16 + lo) & 0xff) << 6) | (v & 0xf9c00001))
	m.set_u16(0xa15be4, m.u16(card) & 0xfff)
	f541cb0(0xa15be8, card)
	m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xfff7) | 0x14)
	m.set_u16(0xa15bec, flags | 4)
	f57c710()
	return 0

## FUN_0057ce60: conserva LP estrictamente mayores que el coste de las cartas 436.
func f57ce60(p: int) -> int:
	var count := f542f30(1, 0x436) + f542f30(0, 0x436)
	return int(count * 500 < m.u16(0xa11944 + (p & 1) * 0xd54))

func _n_pack_position(v: int) -> int:
	return ((((((v >> 8) & 0x10) << 1 | (v & 0x10)) << 5 | ((v >> 8) & 0x87)) << 1 | (v & 0x80)) << 2 | (v & 7)) << 16

## FUN_0057c800: descriptor de invocación normal desde la mano.
func f57c800(p: int, hand: int, zone: int, pos: int, mode: int) -> int:
	var location := (((hand & 0xff) << 5) | (zone & 31)) << 1
	var v := location | (m.u32(0xa15be0) & (0xffff8000 if mode == 0 else 0xffff4000)) | (p & 1) | (0x8000 if mode == 0 else 0x4000)
	if f542f30(0, 0x47f) != 0 or f542f30(1, 0x47f) != 0:
		v |= 0x4000
	v = (v & 0xf9c0ffff) if pos == 0 else _n_pack_position(pos) | (v & 0xc9c0ffff)
	m.set_u32(0xa15be0, v)
	m.set_u16(0xa15bec, 3)
	m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xffe7) | 4)
	var idx := m.u16(0xa11fb8 + (p & 1) * 0xd54 + hand * 4) & 0xfff
	m.set_u16(0xa15be4, idx)
	if f541ce0(f401a70(idx)) == 0:
		var a := 0xa1194c + (p & 1) * 0xd54
		m.set_u8(a, m.u8(a) | 0x10)
		m.set_u16(0xa15bec, 2)
	if f541ce0(f401a70(idx)) != 0:
		m.set_u32(0xa15be0, m.u32(0xa15be0) | 0x4000)
	f56e0b0(p)
	f57c710()
	return 0

## FUN_0057c9a0: descriptor de colocación desde la mano.
func f57c9a0(p: int, hand: int, zone: int, pos: int) -> int:
	var v := ((((hand & 0xff) << 5) | (zone & 31)) << 1) | (m.u32(0xa15be0) & 0xffff8000) | (p & 1)
	if f542f30(0, 0x47f) != 0 or f542f30(1, 0x47f) != 0:
		v |= 0x4000
	v = (v & 0xf9c0ffff) if pos == 0 else _n_pack_position(pos) | (v & 0xc9c0ffff)
	m.set_u32(0xa15be0, v)
	m.set_u16(0xa15bec, 3)
	m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xffeb) | 8)
	m.set_u16(0xa15be4, m.u16(0xa11fb8 + (p & 1) * 0xd54 + hand * 4) & 0xfff)
	f56e0b0(p)
	f57c710()
	return 0

## FUN_0057cd30: descriptor de invocación con tres posiciones empaquetadas.
func f57cd30(p: int, hand: int, zone: int, pos: int, mode: int) -> int:
	var loc := (((int(mode == 0) << 9) | (hand & 0xff) | 0x100) << 5 | (zone & 31)) << 1
	var v := m.u32(0xa15be0)
	if pos == 0:
		v = loc | (v & 0xf1ff4000) | (p & 1)
	else:
		var upper := pos >> 16
		var packed := (((upper & 0x10) << 1 | ((pos >> 8) & 0x10)) << 1 | (pos & 0x10))
		packed = (packed << 2) | (upper & 7)
		packed = (packed << 2) | (upper & 0x80)
		packed = (packed << 1) | ((pos >> 8) & 0x87)
		packed = (packed << 1) | (pos & 0x80)
		packed = (packed << 2) | (pos & 7)
		v = (packed << 16) | loc | (v & 0x80004000) | (p & 1)
	m.set_u32(0xa15be0, v)
	m.set_u16(0xa15bec, 5)
	m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xfffb) | 0x18)
	m.set_u16(0xa15be4, m.u16(0xa11fb8 + (p & 1) * 0xd54 + hand * 4) & 0xfff)
	f56e0b0(p)
	f57c710()
	return 0

## FUN_0057d060: exige uno o dos tributos según nivel y tipo.
func f57d060(idx: int) -> int:
	var prop := f401a20(idx)
	var typ := (prop >> 20) & 31
	var level := (prop >> 25) & 15
	if typ > 20 and typ < 24:
		level = 0
	elif typ == 24:
		level = 10
	if level <= 4:
		return 1
	var first := f57ceb0(0xffffffff, 0)
	if level <= 6:
		return int(first != -1)
	var second := f57ceb0(first, 0)
	return int(first != -1 and second != -1)

## FUN_0057d250: busca una carta entre las primeras posiciones del mazo.
func f57d250(p: int, id: int, limit: int) -> int:
	for i in range(m.u8(0xa11947 + (p & 1) * 0xd54)):
		if limit <= i:
			return -1
		if s16(f401a70(m.u16(0xa120f8 + (p & 1) * 0xd54 + i * 4) & 0xfff)) == s16(id):
			return i
	return -1

## FUN_0057d2c0: busca una carta por ID en la mano.
func f57d2c0(p: int, id: int) -> int:
	for i in range(m.u8(0xa11946 + (p & 1) * 0xd54)):
		if s16(f401a70(m.u16(0xa11fb8 + (p & 1) * 0xd54 + i * 4) & 0xfff)) == s16(id):
			return i
	return -1

## FUN_0057d6f0: mayor ATK/DEF disponible, revelando temporalmente cartas ocultas.
func f57d6f0(p: int, exclude: int, atk: int, defense: int) -> int:
	return _n_best_stat(p, exclude, atk, defense, false)

## FUN_0057d7d0: índice de la carta con mayor ATK/DEF disponible.
func f57d7d0(p: int, exclude: int, atk: int, defense: int) -> int:
	return _n_best_stat(p, exclude, atk, defense, true)

func _n_best_stat(p: int, exclude: int, atk: int, defense: int, index_result: bool) -> int:
	var best := -1
	var selected := -1
	var tmp := m.local(12)
	for z in range(5):
		var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
		if z == exclude or not (m.u32(a) & 0xfff):
			continue
		var hidden := not (m.u16(a + 6) & 2)
		if hidden:
			m.set_u16(a + 6, m.u16(a + 6) | 2)
		f546470(p, z, tmp)
		if hidden:
			m.set_u8(a + 6, m.u8(a + 6) & 0xfd)
		var value := 0
		var attack_value := _s32c(m.u32(tmp + 4))
		var defense_value := _s32c(m.u32(tmp + 8))
		if atk != 0 and attack_value >= 0:
			value = attack_value
		if defense != 0 and value <= defense_value:
			value = defense_value
		if best < value:
			best = value
			selected = z
	return selected if index_result else best

## FUN_0057d110: elige tributo, priorizando IDs especiales y luego menor suma ATK/DEF.
func f57d110(exclude: int) -> int:
	for z in range(5):
		var idx := m.u16(0xa126b0 + z * 0x94) & 0xfff
		if idx:
			var id := f401a70(idx)
			if id >= 0x780 and id <= 1999:
				return z
	for wanted in [0x2f, 0x23d]:
		for z in range(5):
			var idx := m.u16(0xa126b0 + z * 0x94) & 0xfff
			if idx and z != exclude and s16(f401a70(idx)) == wanted:
				return z
	var selected := -1
	var best := 99999
	var tmp := m.local(12)
	for z in range(5):
		if (m.u16(0xa126b0 + z * 0x94) & 0xfff) and z != exclude:
			f546470(1, z, tmp)
			var score := _s32c(m.u32(tmp + 4)) + _s32c(m.u32(tmp + 8))
			if score < best:
				best = score
				selected = z
	return selected

## FUN_0057d8b0: elige objetivo boca arriba según legalidad y valor de combate.
func f57d8b0(card: int, p: int, exclude: int) -> int:
	var selected := -1
	var best := -1
	for z in range(5):
		var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
		if z == exclude or not (m.u32(a) & 0xfff) or not (m.u8(a + 6) & 2):
			continue
		if f54fc80(card, (z << 8) | (p & 0xff)) == 0:
			continue
		var score := f547c60(p, z)
		if f545620(p, z, 0x403) != 0:
			continue
		var old := m.u16(a + 6)
		m.set_u16(a + 6, old & 0xfffe)
		var valid := f571810(p, z, 0)
		m.set_u16(a + 6, (m.u16(a + 6) & 0xfffe) | (old & 1))
		if (m.u16(a) & 0xfff) == f401ad0(0x1ec):
			score += 500
		if valid and best < score:
			best = score
			selected = z
	return selected


## FUN_0057ceb0: tributo por prioridad de efectos, después menor DEF + doble ATK.
func f57ceb0(exclude: int, permissive: int) -> int:
	for z in range(5):
		if (m.u16(0xa126b0 + z * 0x94) & 0xfff) and z != exclude and f545620(1, z, 0x403) != 0 and f544210(1, z) != 0:
			return z
	for wanted in [0x2f, 0x23d]:
		for z in range(5):
			var idx := m.u16(0xa126b0 + z * 0x94) & 0xfff
			if idx and z != exclude and s16(f401a70(idx)) == wanted:
				return z
	var best := 32000
	var selected := -1
	var tmp := m.local(12)
	for z in range(5):
		var idx := m.u16(0xa126b0 + z * 0x94) & 0xfff
		if idx == 0 or z == exclude:
			continue
		var special := f542280(idx)
		var legal := f544210(1, z)
		var id := s16(f401a70(idx))
		if (id != 0x2da and id != 0x536 and legal != 0 and special == 0) or permissive != 0:
			f546470(1, z, tmp)
			var score := _s32c(m.u32(tmp + 8)) + _s32c(m.u32(tmp + 4)) * 2
			if score < best:
				best = score
				selected = z
	return selected

## FUN_0057da30: elige defensa según restricciones y evaluación ATK/DEF de CPU.
func f57da30(idx: int, mode: int) -> int:
	var id := f401a70(idx)
	if mode == 0:
		if f541d10(id, 1) != 0 or f541d10(id, 0) != 0:
			return 1
	if s16(id) == 0x16d:
		return 1
	if s16(id) == 0x2da:
		return int(f5431b0(0) < 1)
	return int(f581bf0(f445810(idx), f445850(idx)) != 0)

## FUN_0057c440: ejecuta descriptor de invocación y efectos de cartas al llegar al campo.
func f57c440() -> int:
	var flags := m.u16(0xa15bee)
	if not (flags & 1):
		return 0
	var desc := m.u32(0xa15be0)
	if not (flags & 2) or not (desc & 1):
		var handler: int = [0, 0x57aca0, 0x57b140, 0x57b6e0, 0x57bb60, 0x57bd40, 0x57c0c0][(flags & 0x1c) >> 2]
		if handler and invoke_original(handler) == 0:
			return 1
	elif not (m.u32(0xa15a44) & 0x1000):
		return 1
	m.set_u8(0xa15bee, m.u8(0xa15bee) & 0xfe)
	desc = m.u32(0xa15be0)
	var p := desc & 1
	var z := (desc >> 1) & 31
	var entry := m.u32(0xa1195c + p * 0xd54 + z * 0x94)
	if entry & 0xfff:
		var face := (m.u8(0xa11962 + p * 0xd54 + z * 0x94) & 2) != 0
		var count := 0
		if m.u8(0xa15bec) & 0x20:
			count = f542f30(p, 0x595)
			if count > 0:
				issue((desc << 15) | 0x1e, 0x595, 0, 0)
				f54f470(p, count)
		if face and (f542f30(0, 0x610) != 0 or f542f30(1, 0x610) != 0):
			issue((desc << 15) | 0x1e, 0x610, 1, 0)
			issue((desc << 15) | 0x98, z, 1, 0)
		var id := s16(f401a70(entry & 0xfff))
		if id == 0x2ef:
			if face:
				f54eed0(p, f401ad0(0x2ef), z)
				f56dfd0()
				f56e1c0(p, z)
		else:
			if id == 0x464 and face:
				f56e120()
			if face:
				f56e1c0(p, z)
		var kind := (m.u8(0xa15bee) & 0x1c) >> 2
		var trigger := 7
		if kind > 0 and kind < 3:
			trigger = 5 if desc & 0x4000 else 8
		elif kind == 3:
			trigger = 6
		f56a380(1 - p, trigger, (z << 8) | p)
	if (m.u8(0xa15bee) & 2) and not (m.u32(0xa15be0) & 1):
		f53ed60(0xf05b, 0, 0, 0)
	return m.u8(0xa15bee) & 1

## FUN_00579260: invocación especial seleccionada desde la mano, si hay zona disponible.
func f579260(p: int) -> int:
	if m.u8(0xa13426) == 0:
		f5417e0(0xed)

		m.set_u8(0xa13426, 1)
		return 0
	if m.u8(0xa13426) != 1:
		return 1
	if f57a060(1):
		var hand := m.u32(0xa161ac)
		var idx := m.u16(0xa11fb8 + (p & 1) * 0xd54 + hand * 4) & 0xfff
		if f57a490(p, idx) != 0 and f5421c0(idx) == 0:
			var free := f543360(p)
			if free < 5 and f579890():
				issue((0x8000 if p != 0 else 0) | 0xc4, f401a70(idx), (free & 15) | ((hand & 15) << 4) | 0x200, 0)
				m.set_u8(0xa13426, 2)
	return 0

## FUN_00579370: elige carta objetivo para las tres variantes de efecto.
func f579370(p: int, idx: int, mode: int) -> int:
	var state := m.u8(0xa13426)
	if state != 0:
		if state == 1:
			# El original empuja tres argumentos (el cuarto es lo que haya en la pila).
			f407580(p, -1, f401a70(idx), mode)
			m.set_u8(0xa13426, 2)
			return 0
		# Entrada elegida en la ventana de la lista (FUN_004073b0): carta y ubicacion.
		var entry := f4073b0()
		m.set_u16(0xa1342a, m.u16(entry + 2))
		m.set_u16(0xa13428, m.u16(entry))
		return 1
	if p == 0:
		var id := s16(f401a70(idx))
		var message := 0
		match id:
			0x45c:
				message = 0xee
			0x487:
				message = 0xef
			0x5f0:
				message = 0xf0
			_:
				return 1
		f5417e0(message)
		m.set_u8(0xa13426, 1)
		return 0
	var choice := f57d330(idx)

	m.set_u16(0xa13428, m.u16(0xa11624 + choice * 4))
	m.set_u16(0xa1342a, m.u16(0xa11626 + choice * 4))
	return 1

## FUN_0057a490: comprueba invocación desde mano con excepciones de cartas originales.
func f57a490(p: int, idx: int) -> int:
	if s16(idx) == 0 or f583e00(idx) != 0 or ((f401a20(idx) >> 20) & 31) > 20:
		return 0
	var kind := f541950(idx)
	if kind == 3 or kind == 2:
		return 0
	var id := f401a70(idx) & 0xffff
	if f541ce0(id) != 0 and f542fb0(p) == 0:
		return 0
	match id:
		0x2e5, 0x170, 0x3e, 0x187, 0x4b2:
			return 0
		0x37, 0x38, 0x42:
			if f56e660(p) == 0:
				return 0
			return f551c40(p, idx, 11)
		0x175:
			if f56e660(p) == 0 or f544280(p, 0xffffffff) < 3:
				return 0
			return int(f543010(p, 0x172) != 0 and f543010(p, 0x173) != 0 and f543010(p, 0x174) != 0)
		0x4e9:
			return f57a1d0(p)
		0x34d:
			return f57a0a0(p) if f56e660(p) != 0 else 0
		0x4e2:
			if m.u8(0xa11946 + (p & 1) * 0xd54) == 1 and f543330(p) > 0:
				return 1
			return int(f544280(p, 0xffffffff) > 1)
		0x546:
			var opposing := f5431b0(1 - p)
			if f5431b0(p) + 1 < opposing and f543330(p) > 0:
				return 1
			return int(f544280(p, 0xffffffff) > 0)
	if id > 0x5e9 and id < 0x5f0:
		if f56e660(p) == 0:
			return 0
		if f543330(p) == 0 and not (m.u8(0xa11957 + (p & 1) * 0xd54) & 2):
			return 0
		return f57a250(p, idx)
	var level := (f401a20(idx) >> 25) & 15
	if level <= 4:
		if f543330(p) > 0:
			return 1
		if p == 0:
			f4437a0(11)  # FUN_004437a0: ayuda del original.
		return 0
	var tributes := f544280(p, 0xffffffff)
	if tributes > (0 if level <= 6 else 1):
		return 1
	if p == 0:
		f4437a0(0)  # FUN_004437a0: ayuda del original.
	return 0


func _n_next_summon() -> void:
	var flags := m.u16(0xa15bee)
	m.set_u16(0xa15bee, flags ^ ((((flags & 0xffe0) + 0x20) ^ flags) & 0xfe0))

func _n_summon_args(desc: int) -> int:
	return (((((desc >> 15) & 1) << 1) | ((desc >> 14) & 1)) << 8) | (((desc >> 1) & 15) | (((desc >> 6) & 15) << 4))

## FUN_0057bd40: invocación especial con posición elegida y efectos inmediatos.
func f57bd40() -> int:
	var desc := m.u32(0xa15be0)
	var idx := m.u16(0xa15be4)
	match (m.u16(0xa15bee) & 0xfe0) >> 5:
		0:
			if desc & 1:
				m.set_u16(0xa16178, f57da30(idx, (desc >> 14) & 1))
			else:
				# Ventana de posicion (tipo 6) con el mensaje 0xf7: argumento = id de la carta,
				# con el bit 16 puesto si el bit 14 del descriptor esta a 0.
				f5417e0(0xf7)
				f540d60(6, (f401a70(idx) & 0xffff) | (~((desc >> 14) << 16) & 0x10000))
		1:
			# Posicion elegida en la ventana (o por la CPU con 0x57da30).
			var choice := m.u16(0xa16178)
			desc = desc ^ (((choice << 15) ^ desc) & 0x8000)
			if not (desc & 0x8000):
				desc |= 0x4000
			m.set_u32(0xa15be0, desc)
			if desc & 0x4000:
				issue((desc << 15) | 0xe6, f401a70(idx), _n_summon_args(desc), 4)
		2:
			var packed := (((((desc >> 15) & 1) | (((desc >> 1) & 31) << 3)) << 1) | ((desc >> 14) & 1)) << 8 | ((desc >> 6) & 0xff)
			issue((desc << 15) | 0x71, packed, m.u16(0xa15be8), m.u16(0xa15bea))
		3:
			issue((desc << 15) | 0x92, (desc >> 1) & 31, m.u16(0xa15bec), 0)
			var id := s16(f401a70(idx))
			if id == 0x4de:
				f53baa0((((desc & 0x3e) | (desc << 16) | 0x1880) << 15) | idx, (((desc >> 1) & 31) << 8) | (desc & 1))
			elif id == 0x5f6:
				for z in range(5):
					if z != ((desc >> 1) & 31):
						f54e250(desc & 1, z, 1)
		_:
			return 1
	_n_next_summon()
	return 0

## FUN_005798a0 (cada fotograma, desde FUN_0053dbf0 si no hay ventana): cursor de teclado.
## Parte del objeto bajo el raton (0xa161a4/a8/ac) o, en modo teclado (FUN_005407a0), de la
## posicion guardada (0xa161b0/b4/b8); marca el bit 0 de 0xa161a0 y, segun la tecla de
## 0xa114a8, mueve el cursor con FUN_0053f7e0: 0x10000/0x20000/0x40000 saltan al mazo,
## cementerio o mazo de fusion (al del rival si ya esta en el propio); 0x20/0x10 recorren la
## fila hacia un lado u otro (pasando de la fila a las columnas laterales), 0x40/0x80 cambian
## de fila. FUN_00438b90(0) es un sonido sin caso para 0 (no hace nada).
func f5798a0() -> int:
	var btn := m.u32(0xa114a8)
	var p := m.u32(0xa161a4)
	var loc := m.u32(0xa161a8)
	var i := m.u32(0xa161ac)
	if f5407a0() != 0:
		loc = m.u32(0xa161b4)
		i = m.u32(0xa161b8)
		p = m.u32(0xa161b0)
	m.set_u32(0xa161a0, m.u32(0xa161a0) | 1)
	if (btn & 0x10000) != 0:
		if loc == 0xd: p ^= 1
		f53f7e0(p, 0xd, 0)
		return 0
	if (btn & 0x20000) != 0:
		if loc == 0xe: p ^= 1
		f53f7e0(p, 0xe, 0)
		return 0
	if (btn & 0x40000) != 0:
		if loc == 0xc: p ^= 1
		f53f7e0(p, 0xc, 0)
		return 0
	var hand0 := m.u8(0xa11946)
	var hand1 := m.u8(0xa1269a)
	var go := []
	if (btn & 0x20) != 0 and p in [0, 1]:
		if p == 0:
			match loc:
				0: go = [0, 10, 0] if _s32(i) < 1 else [0, 0, i - 1]
				5: go = [0, 0xc, 0] if _s32(i) < 1 else [0, 5, i - 1]
				10: go = [0, 0xe, 0]
				0xb:
					if hand0 == 0: return 0
					go = [0, 0xb, hand0 - 1 if _s32(i) < 1 else i - 1]
				0xc: go = [0, 0xd, 0]
				0xd: go = [0, 5, 4]
				0xe, 0xf: go = [0, 0, 4]
				_: return 0
		else:
			match loc:
				0: go = [1, 0, i + 1] if _s32(i) < 4 else [1, 0xe, 0]
				5: go = [1, 5, i + 1] if _s32(i) < 4 else [1, 0xd, 0]
				10: go = [1, 0, 0]
				0xb:
					if hand1 == 0: return 0
					go = [1, 0xb, i + 1 if _s32(i) < hand1 - 1 else 0]
				0xc: go = [1, 5, 0]
				0xd: go = [1, 0xc, 0]
				0xe, 0xf: go = [1, 10, 0]
				_: return 0
	elif (btn & 0x10) != 0 and p in [0, 1]:
		if p == 0:
			match loc:
				0: go = [0, 0, i + 1] if _s32(i) < 4 else [0, 0xe, 0]
				5: go = [0, 5, i + 1] if _s32(i) < 4 else [0, 0xd, 0]
				10: go = [0, 0, 0]
				0xb:
					if hand0 == 0: return 0
					go = [0, 0xb, i + 1 if _s32(i) < hand0 - 1 else 0]
				0xc: go = [0, 5, 0]
				0xd: go = [0, 0xc, 0]
				0xe, 0xf: go = [0, 10, 0]
				_: return 0
		else:
			match loc:
				0: go = [1, 10, 0] if _s32(i) < 1 else [1, 0, i - 1]
				5: go = [1, 0xc, 0] if _s32(i) < 1 else [1, 5, i - 1]
				10: go = [1, 0xe, 0]
				0xb:
					if hand1 == 0: return 0
					go = [1, 0xb, hand1 - 1 if _s32(i) < 1 else i - 1]
				0xc: go = [1, 0xd, 0]
				0xd: go = [1, 5, 4]
				0xe, 0xf: go = [1, 0, 4]
				_: return 0
	elif (btn & 0x40) != 0 and p in [0, 1]:
		if p == 0:
			match loc:
				0: go = [1, 0, 4 - i]
				5: go = [0, 0, i]
				10: go = [1, 0xf, 0]
				0xb: go = [0, 5, f540d30(0, 0xb, i, 0, 5)]
				0xc: go = [0, 10, 0]
				0xd: go = [0, 0xe, 0]
				0xe: go = [0, 0xf, 0]
				0xf: go = [1, 10, 0]
				_: return 0
		else:
			match loc:
				0: go = [1, 5, i]
				5: go = [1, 0xb, f540d30(1, 5, i, 1, 0xb)]
				10: go = [1, 0xc, 0]
				0xb: go = [0, 0xb, f540d30(1, 0xb, i, 0, 0xb)]
				0xc: go = [1, 0xb, f540d30(1, 0xc, i, 1, 0xb)]
				0xd: go = [1, 0xb, f540d30(1, 0xd, i, 1, 0xb)]
				0xe: go = [1, 0xd, 0]
				0xf: go = [1, 0xe, 0]
				_: return 0
	elif (btn & 0x80) != 0 and p in [0, 1]:
		if p == 0:
			match loc:
				0: go = [0, 5, i]
				5: go = [0, 0xb, f540d30(0, 5, i, 0, 0xb)]
				10: go = [0, 0xc, 0]
				0xb: go = [1, 0xb, f540d30(0, 0xb, i, 1, 0xb)]
				0xc: go = [0, 0xb, f540d30(0, 0xc, i, 0, 0xb)]
				0xd: go = [0, 0xb, f540d30(0, 0xd, i, 0, 0xb)]
				0xe: go = [0, 0xd, 0]
				0xf: go = [0, 0xe, 0]
				_: return 0
		else:
			match loc:
				0: go = [0, 0, 4 - i]
				5: go = [1, 0, i]
				10: go = [0, 0xf, 0]
				0xb: go = [1, 5, f540d30(1, 0xb, i, 1, 5)]
				0xc: go = [1, 10, 0]
				0xd: go = [1, 0xe, 0]
				0xe: go = [1, 0xf, 0]
				0xf: go = [0, 10, 0]
				_: return 0
	if go.is_empty():
		return 0
	f53f7e0(go[0], go[1], go[2])
	return 0


## FUN_005407a0: byte +0x40 del objeto DAT_005af868 (cursor manejado con el teclado).
func f5407a0() -> int:
	return 1 if ui_key_cursor else 0


## FUN_00540d30: solo reenvia a FUN_00540c00.
func f540d30(p: int, loc: int, i: int, p2: int, loc2: int) -> int:
	return f540c00(p, loc, i, p2, loc2)


## FUN_00540a90: desplazamiento del cursor sobre la mano del jugador p, un cuarto del tamano
## de carta del original (DAT_005af728/72c = 200x290) con el redondeo asimetrico de cada lado.
func f540a90(p: int) -> Vector2i:
	var offset := 0 if p == 0 else -1
	var direction := -1 if p == 0 else 1
	return Vector2i((200 / 4 + offset) * direction, (290 / 4 + offset) * direction)


## FUN_00540c00: indice de la ubicacion (p2, loc2) cuya x en pantalla (FUN_00442130) queda mas
## cerca de la de (p, loc, i). Las zonas tienen 5 posiciones, el campo, mazos, cementerio y
## excluidas 1, la mano tantas como cartas (FUN_00403a30) y cualquier otra ubicacion p (el
## original reutiliza ese argumento como contador). 442130 consulta la posición actual.
func f540c00(p: int, loc: int, i: int, p2: int, loc2: int) -> int:
	if loc == loc2 and p == p2:
		return i
	var x := int(card_screen_position(p, loc, i).x)
	if loc == 11: x += f540a90(p).x
	var count := p
	if loc2 >= 0 and loc2 <= 9:
		count = 5
	elif loc2 == 10 or (loc2 >= 0xc and loc2 <= 0xf):
		count = 1
	elif loc2 == 0xb:
		count = m.u8(DuelMem.pl(p2 & 1) + 2)
	var best := 0
	var best_d := 9999
	for n in count:
		var target := int(card_screen_position(p2, loc2, n).x)
		if loc2 == 11: target += f540a90(p2).x
		var d := absi(target - x)
		if d < best_d:
			best_d = d
			best = n
	return best


## FUN_0057b140: colocación de monstruo con posición, tributos y efectos al invocar.
func f57b140() -> int:
	var desc := m.u32(0xa15be0)
	var idx := m.u16(0xa15be4)
	var state := (m.u16(0xa15bee) & 0xfe0) >> 5
	match state:
		0:
			if desc & 1:
				m.set_u16(0xa16178, f57da30(idx, 0))
			else:
				# Ventana de posicion (tipo 6), como en 0x57bd40.
				f5417e0(0xf7)
				f540d60(6, (f401a70(idx) & 0xffff) | (~((desc >> 14) << 16) & 0x10000))
		1:
			var choice := m.u16(0xa16178)
			desc ^= ((choice << 15) ^ desc) & 0x8000
			desc = (desc & 0xffffbfff) if desc & 0x8000 else desc | 0x4000
			if f542f30(0, 0x47f) != 0 or f542f30(1, 0x47f) != 0:
				desc |= 0x4000
			m.set_u32(0xa15be0, desc)
		2:
			if desc & 0x4000:
				issue((desc << 15) | 0xe6, f401a70(idx), _n_summon_args(desc), ((desc >> 26) & 1) + ((desc >> 25) & 1))
			for b in [25, 26]:
				if desc & (1 << b):
					var sh: int = 16 if b == 25 else 19
					issue(((desc >> (b + 3)) << 15) | 0x57, (desc >> sh) & 7, 0, 0)
			for b in [25, 26]:
				if desc & (1 << b):
					var sh: int = 16 if b == 25 else 19
					f54ea40((desc >> (b + 3)) & 1, (desc >> sh) & 7)
			issue((desc << 15) | 0xc4, f401a70(idx), _n_summon_args(desc), 0)
		3:
			issue((desc << 15) | 0x92, (desc >> 1) & 31, m.u16(0xa15bec), 0)
			if not (desc & 0x4000):
				m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xf15f) | 0x140)
				return 0
			issue((desc << 15) | 0x6f, f401a70(idx), (desc >> 1) & 31, 0)
		4:
			f56dd40(desc & 1)
			var id := f401a70(idx)
			if id in [0x462, 0x455, 499, 0x4d8, 0x4de, 0x534]:
				f53baa0((((desc & 0x3e) | (desc << 16) | 0x1480) << 15) | idx, (((desc >> 1) & 31) << 8) | (desc & 1))
			elif id == 0x31c:
				f54e660(desc & 1, (desc >> 1) & 31, 0, 0)
			elif id == 0x45e or id == 0x585:
				f54e250(desc & 1, (desc >> 1) & 31, 1)
		_:
			return 1
	_n_next_summon()
	return 0

## FUN_0057d330: elige objetivo entre candidatos según prioridades de carta y potencia.
func f57d330(idx: int) -> int:
	var id := s16(f401a70(idx))
	var n := f56ba50(1, id, 0)
	m.set_u16(0xa14f02, 0)
	if n == 0:
		return -1
	if m.u32(0xa16184) & 0x200:
		for i in range(n):
			var target := f401a70(m.u16(0xa11624 + i * 4) & 0xfff)
			var choose := false
			if target == 0x2f or target == 0x23d:
				choose = id == 0x463
			elif target >= 16 and target <= 20:
				choose = id == 0x2f or id == 0x23d or id == 0x47b
			if choose:
				m.set_u16(0xa14f02, i)
				return i & 0xffff
		if id == 0x463:
			return -1
	if id in [0x65, 0x1ab, 0x443]:
		for priority in range(20):
			var wanted := s16(m.u16(0x5ad340 + priority * 2))
			for i in range(n):
				if s16(f401a70(m.u16(0xa11624 + i * 4) & 0xfff)) == wanted:
					m.set_u16(0xa14f02, i)
					return i & 0xffff
		var chosen := rng.rand() % n
		m.set_u16(0xa14f02, chosen)
		return chosen & 0xffff
	if n < 1:
		return -1
	var best := 0
	var chosen := -1
	if id != 0x488:
		var strongest := 0
		var tmp := m.local(12)
		for z in range(5):
			f546470(0, z, tmp)
			strongest = maxi(strongest, _s32c(m.u32(tmp + 4)))
		for i in range(n):
			var target := m.u16(0xa11624 + i * 4) & 0xfff
			var attack := f445810(target)
			var defense := f445850(target)
			if best < attack + defense and (strongest <= attack or attack != 0 or strongest <= defense):
				best = defense + attack
				chosen = i
		if chosen >= 0:
			m.set_u16(0xa14f02, chosen)
			return chosen & 0xffff
	best = 0
	chosen = -1
	for i in range(n):
		var target := m.u16(0xa11624 + i * 4) & 0xfff
		var attack := f445810(target)
		if best < attack:
			best = attack
			chosen = i
	if chosen < 0:
		chosen = rng.rand() % n
	m.set_u16(0xa14f02, chosen)
	return chosen & 0xffff

## FUN_0057bb60: invocación especial con posición predeterminada.
func f57bb60() -> int:
	var desc := m.u32(0xa15be0)
	var idx := m.u16(0xa15be4)
	match (m.u16(0xa15bee) & 0xfe0) >> 5:
		0:
			if desc & 0x4000:
				issue((desc << 15) | 0xe6, f401a70(idx), _n_summon_args(desc), 4)
		1:
			var packed := (((((desc >> 15) & 1) | (((desc >> 1) & 31) << 3)) << 1) | ((desc >> 14) & 1)) << 8 | ((desc >> 6) & 0xff)
			issue((desc << 15) | 0x71, packed, m.u16(0xa15be8), m.u16(0xa15bea))
		2:
			issue((desc << 15) | 0x92, (desc >> 1) & 31, m.u16(0xa15bec), 0)
			if s16(f401a70(idx)) == 0x4de:
				f53baa0((((desc & 0x3e) | (desc << 16) | 0x1880) << 15) | idx, (((desc >> 1) & 31) << 8) | (desc & 1))
		_:
			return 1
	_n_next_summon()
	return 0

## FUN_0057a7c0: ventanas de reacción al invocar para ambas partes (cartas 407/404).
func f57a7c0(reason: int) -> int:
	var state := (m.u16(0xa15bee) & 0xfe0) >> 5
	var desc := m.u32(0xa15be0)
	var v := m.u32(0xa15bf0)
	if state == 3:
		m.set_u16(0xa16178, 0)
		m.set_u16(0xa15bf0, (m.u16(0xa15bf0) & 0xff80) | (1 - (desc & 1)))
		_n_next_summon()
		state = 4
		v = m.u32(0xa15bf0)
	if state == 4 or state == 5:
		if state == 4 and not (m.u32(0xa1195c + (desc & 1) * 0xd54 + ((desc >> 1) & 31) * 0x94) & 0xfff):
			return 1
		# 5: respuesta del cuadro de 0x407 pedido en 4 (la CPU deja 0).
		if state == 5 and m.u16(0xa16178) != 0:
			_n_next_summon()
			return 0
		var p := v & 0x7f
		var id := 0x407 if state == 4 else 0x404
		if f543cd0(p, id) != 0:
			var tmp := m.local(20)
			m.clear(tmp, 20)
			m.set_u16(tmp, f401ad0(id))
			m.set_u32(tmp + 2, (v & 1) | (((f543c60(p, id) & 0x3f) | (reason << 6)) << 4))
			m.set_u32(tmp + 6, ((((desc >> 1) & 0xff) << 8) | (desc & 0xff)) & 0x1f01)
			var eligible := f5535a0(tmp, 0, 0) if state == 4 else f5533d0(tmp, 0, 0)
			if eligible:
				m.set_u32(0xa15bf0, (v & (0xffff8fff if state == 4 else 0xffff8e7f)) | (0xf80 if state == 4 else 0xe00))
				if p == 0:
					# Cuadro Si/No: mensaje 0xfa con el nombre de la carta 0x407/0x404.
					dialog_format(0xfa, [{"card": f401ad0(id)}])
					f540d60(1, 0)
				else:
					m.set_u16(0xa16178, 0)
		_n_next_summon()
		return 0
	if state == 6:
		# Respuesta del cuadro de 0x404 pedido en 5.
		if m.u16(0xa16178):

			var p := v & 0x7f
			var z := f543c60(p, ((v & 0xffff) >> 7 & 0xff) + 1000)
			issue((0x8000 if p != 0 else 0) | 0x91, z, 0, 0)
			var idx := m.u32(0xa1195c + (v & 1) * 0xd54 + z * 0x94) & 0xfff
			f53baa0(((((p << 6) | (reason & 0x3f)) << 9 | (z & 31) | 0x20) << 16) | idx, (((desc >> 1) & 31) << 8) | (desc & 1))
			_n_next_summon()
			return 0
		m.set_u16(0xa15bf0, (m.u16(0xa15bf0) & 0xff80) | ((1 - (v & 0xff)) & 0x7f))
		if (m.u16(0xa15bf0) & 0x7f) != 1 - (desc & 1):
			m.set_u16(0xa15bee, (m.u16(0xa15bee) & 0xf09f) | 0x80)
		else:
			_n_next_summon()
			_n_next_summon()
		return 0
	if state == 7:
		if f53d550() == 0:
			_n_next_summon()
		return 0
	return 1


