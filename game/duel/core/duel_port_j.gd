class_name DuelPortJ
extends DuelPortI
## Modulo del porte del motor de duelo (ver docs/duel/PORTING.md).
## Los efectos que terminan en XOR AX,AX devuelven cero en su contrato ushort;
## los bits altos del registro EAX no forman parte del resultado consumido.

func _j_tribute_location(e: int, second: int = -1) -> int:
	var first: int = (((m.u8(e + 12) | 0xf8) << 4) | m.u8(e + 13)) & 0xff
	if second >= 0:
		first |= (((((m.u8(e + 2) & 1) | 0xf8) << 4) | second) & 0xff) << 8
	return first

func _j_tribute_candidate(p: int, index: int) -> bool:
	if ctype(index) >= 0x15 or f5421c0(index) != 0 or f4457d0(index) < 5:
		return false
	return f543360(p) != -1 if f4457d0(index) < 7 else f544280(p, -1) > 0

func f55f600(e: int, argument: int) -> int:
	var p: int = m.u8(e + 2) & 1
	var block: int = DuelMem.pl(p)
	m.set_u8(block + 0x10, m.u8(block + 0x10) | 1)
	m.set_u8(block + 8, m.u8(block + 8) & 0xbf)
	if (m.u8(e + 4) & 4) != 0:
		return 0
	match m.u8(0xa15fe0):
		0x14:
			m.set_u8(block + 8, m.u8(block + 8) | 0x10)
			for i in range(m.u8(block + 2)):
				var index: int = m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff
				if ctype(index) < 0x15 and f5421c0(index) == 0 and f4457d0(index) > 4:
					if f4457d0(index) < 7:
						if f543360(p) != -1:
							var mode: int = int(f581cd0(index, 0) == 0)
							# ASM: location/mode siguen en pila tras f543360(p).
							f57c800(p, i, f543360(p), _j_tribute_location(e), mode)
							return 1
					else:
						var second: int = f57ceb0(-1, 0)
						if second != -1:
							f57c800(p, i, second, _j_tribute_location(e, second), int(f581cd0(index, 0) == 0))
							return 1
			return 1
		0x62:
			f54eed0(p, m.u16(0xa160e6), (m.u32(0xa160e8) >> 4) & 0x3f)
			var id: int = f401a70(m.u16(0xa160e6)) & 0xffff
			if id == 0x105:
				invoke_original(0x555e60, [0xa160e6, 0])
				return 0x61
			if id == 0x58 or id == 0x1ff:
				invoke_original(0x555b70, [0xa160e6, 0])
				return 0x61
			return 0
		0x76:
			if f57a060(0xf0) != 0 and f544210(p, m.u32(0xa161ac)) != 0 and f579890() != 0:
				var second: int = m.u32(0xa161ac)
				f57c800(p, m.u16(e + 14), second, _j_tribute_location(e, second), int((m.u32(0xa13408) & 0x3c) == 0))
				return 0x6e
			return 0x76
		0x78:
			f540bb0()  # FUN_00540bb0: el cursor deja de mostrar accion.
			if f57a060(0xff) != 0:
				var selected: int = m.u32(0xa161ac)
				if m.u32(0xa161a8) == 0xb:
					var index: int = m.u16(0xa11fb8 + p * 0xd54 + selected * 4) & 0xfff
					if (m.u8(block + 8) & 0x10) == 0 and f544210(m.u8(e + 12), m.u8(e + 13)) != 0 and _j_tribute_candidate(p, index):
						var prior: int = m.u16(0xa1340e)
						if ((prior >> 8) & 1) == m.u32(0xa161a4) and (prior >> 9) == m.u32(0xa161a8) and m.u8(0xa13410) == selected:
							if (m.u32(0xa114a8) & 0x500) != 0:
								var bits: int = 0x10 if (m.u32(0xa13408) & 0x3c) == 0 else 0
								m.set_u32(0xa13408, (m.u32(0xa13408) & ~0x3c) | bits)
						else:
							m.set_u32(0xa13408, m.u32(0xa13408) & 0xffffffc3)
						if f579890() != 0:
							m.set_u8(block + 8, m.u8(block + 8) | 0x10)
							if f4457d0(index) > 6:
								f5417e0(0x3f)
								m.set_u16(e + 14, selected)
								return 0x76
							f57c800(p, selected, f543360(p), _j_tribute_location(e), int((m.u32(0xa13408) & 0x3c) == 0))
							return 0x6e
						f540b90((m.u32(0xa13408) >> 2) & 0xf)  # FUN_00540b90: accion del cursor.
				else:
					var z: int = selected + m.u32(0xa161a8)
					if z <= 4:
						var card: int = DuelMem.zone(m.u32(0xa161a4) & 1, z)
						var index: int = m.u16(card) & 0xfff
						if index != 0 and (m.u8(card + 6) & 2) != 0 and (f401a70(index) & 0xffff) in [0x58, 0x105, 0x1ff]:
							if f579890() != 0:
								m.copy(0xa160e6, e, 20)
								m.set_u16(0xa160e8, (m.u16(0xa160e8) & ~0x3f0) | ((z * 16) & 0x3f0)) # ASM 55fb14: xor word ptr; 0xa160ea se conserva
								m.set_u16(0xa160e6, index)
								return 0x62
							f540b90(3)  # FUN_00540b90: accion del cursor.
			m.set_u8(0xa13410, m.u8(0xa161ac))
			m.set_u8(0xa1340f, (m.u8(0xa161a8) << 1) | (m.u8(0xa161a4) & 1))
			return 0x78
		0x7f:
			var can_summon: bool = false
			if (m.u8(block + 8) & 0x10) == 0:
				for i in range(m.u8(block + 2)):
					var index: int = m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff
					if _j_tribute_candidate(p, index):
						can_summon = true
			if (m.u8(block + 8) & 0x10) != 0 or f544210(m.u8(e + 12), m.u8(e + 13)) == 0:
				can_summon = false
			var can_effect: bool = false
			for z in range(5):
				var card: int = DuelMem.zone(p, z)
				var index: int = m.u16(card) & 0xfff
				if index != 0 and (m.u8(card + 6) & 2) != 0 and (f401a70(index) & 0xffff) in [0x58, 0x105, 0x1ff]:
					can_effect = true
			if f543390(m.u8(e + 12), m.u8(e + 13)) == 0:
				can_effect = false
			if can_summon or can_effect:
				f465720(m.u8(e + 12), m.u8(e + 13))  # FUN_00465720: marcador de sacrificio.
				m.set_u32(0xa13408, m.u32(0xa13408) & 0xffffffc3)
				return 0x78
		0x80:
			if invoke_original(0x5543c0, [e, argument, 0]) != 0:
				return 0x14 if p != 0 else 0x7f
	return 0

func f55ebf0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	var state: int = m.u8(0xa15fe0)
	match state:
		0x60:
			var entry: int = f4073b0()
			if f54dc60(p, f401a70(m.u16(entry) & 0xfff)) != 0:
				issue(m.s16(e + 2) << 15 | 0x60, 0, 0, 0)
			return 10
		0x61:
			f407580(p, -1, 0x4b2, 0)
			return 0x60
		0x62:
			if f56ba50(p, 0x4b2, 0) > 0:
				f5417e0(0x3c)
				return 0x61
		99:
			return 0x62
		100:
			for i in range(m.u16(0xa11924)):
				var kind: int = m.u16(e + 12)
				if (m.u8(0xa11824 + i * 2) & 0x1f) == kind:
					var entry: int = 0xa11624 + i * 4
					if kind == 1:
						var slot: int = f544db0(p, entry)
						issue(m.s16(e + 2) << 15 | 0xc2, m.u16(entry), m.u16(entry + 2), 0)
						f57cc50(p, entry, 1, 1, 0xb, slot)
					elif kind == 2:
						issue(m.s16(e + 2) << 15 | 0x65, m.u16(entry), m.u16(entry + 2), 0)
						f57cc50(p, entry, 1, 1, 0xd, 0)
					return 99
		0x6d:
			if f57a060(0xe0) == 0:
				return state
			var target: int = m.u32(0xa161a4)
			var z: int = m.u32(0xa161ac) + m.u32(0xa161a8)
			var id: int = f401a70(m.u16(DuelMem.zone(target & 1, z)) & 0xfff) & 0xffff
			if id not in [0x22, 0x4ba, 0x7f2] or f579890() == 0:
				return state
			f54ea40(target, z)
			return 100
		0x6e:
			_j_named_dialog(0x13, f401ad0(0x22))
			return 0x6d
		0x76:
			# Boton elegido en el cuadro de dos botones (mensaje 0x3a) pedido en 0x77.
			var choice: int = m.u16(0xa16178)
			m.set_u16(e + 12, 1 if choice == 0 else (2 if choice == 1 else m.u16(e + 12)))
			return 0x6e
		0x77:
			var answer: int = m.u16(0xa16178)
			if answer == 0 or m.u16(0xa11924) == 0:
				return 10
			var hand: bool = false
			var grave: bool = false
			for i in range(m.u16(0xa11924)):
				var kind: int = m.u8(0xa11824 + i * 2) & 0x1f
				hand = hand or kind == 1
				grave = grave or kind == 2
			if not hand:
				if not grave:
					return 10
				m.set_u16(e + 12, 2)
				return 0x6e
			if grave:
				f5417e0(0x3a)
				f540d60(2, 0)
				return 0x76
			m.set_u16(e + 12, 1)
			return 0x6e
		0x78:
			# Dos 53fac0 seguidos: nombres de 0x22 y 0x4b2 en los dos "%s" del mensaje 0x39.
			dialog_format(0x39, [{"card": f401ad0(0x22)}, {"card": f401ad0(0x4b2)}])
			f540d60(1, 0)
			return 0x77
		0x7f:
			var result: int = rng.rand() & 1
			issue(m.u16(e + 2) << 15 | 0xe0, m.u16(0xa16178), result, (m.u16(e + 2) >> 4) & 0x3f)
			if result == m.u16(0xa16178):
				f54cc10(p, 1 - p, 0, 0, 0)
				if f543330(p) > 0 and f56ba50(p, 0xf, 0) > 0 and f542f30(0, 0x58a) == 0 and f542f30(1, 0x58a) == 0 and (f543010(p, 0x22) != 0 or f543010(p, 0x4ba) != 0 or f543010(p, 0x7f2) != 0):
					return 0x78
			else:
				var attack: int = 0
				for z in range(5):
					if (m.u32(DuelMem.zone(p, z)) & 0xfff) != 0:
						attack += f547c60(p, z)
				f54cc10(p, p, 0, 0, 0)
				f54ef90(m.u8(e + 2) & 1, f53fbf0(attack))
		0x80:
			return _j_coin_start(e)
		_:
			issue(m.u16(e + 2) << 15 | 0x94, (m.u16(e + 2) >> 4) & 0x3f, 0, 0)
			return 0
	return 10

func f560150(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7d:
			if f57a060(0xe000e0) != 0 and f579890() != 0:
				var target_player: int = m.u8(0xa161a4)
				var target_zone: int = (m.u8(0xa161ac) + m.u8(0xa161a8)) & 0xff
				var slot: int = f543570(p)
				pass  # FUN_00438b90(1): sin sonido ni efecto.
				issue(m.u16(e + 2) << 15 | 8, m.u16(0xa161a4), m.u8(0xa161ac) << 8 | m.u8(0xa161a8), 0)
				f544950(p, m.u16(e), 0xa1614c)
				issue(m.u16(e + 2) << 15 | 0xd3, m.u16(0xa1614c), m.u16(0xa1614e), 0)
				issue(m.u16(e + 2) << 15 | 0x77, (slot & 0xff) | 0x100, m.u16(0xa1614c), m.u16(0xa1614e))
				f54e730(m.u8(e + 2) & 1, (slot & 0xff) << 8 | (m.u8(e + 2) & 1), target_zone << 8 | target_player)
				return 100
			return 0x7f if (m.u32(0xa114a8) & 0x102) != 0 else 0x7d
		0x7e:
			var answer: int = m.u16(0xa16178)
			if answer != 0:
				_j_named_dialog(0x43, m.u16(e))
				return 0x7d
		0x7f:
			_j_named_dialog(0x42, m.u16(e))
			f540d60(1, 0)
			return 0x7e
		0x80:
			if f544a00(p, 0x4da) != 0 and f543570(p) != -1:
				for target in range(2):
					for z in range(5):
						var card: int = DuelMem.zone(target, z)
						if (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) != 0:
							return 0x7f
	return 0

func f55df90(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7a:
			issue((0x8000 if p != 1 else 0) | 0x60, 1, 0, 0)
			return 1
		0x7b:
			issue(m.u16(e + 2) << 15 | 0x60, 1, 0, 0)
			return 0x7a
		0x7c:
			if m.u8(0xa1269b) != 0:
				f407580(1, 0xd, 0, 0)
			return 0x7b
		0x7d:
			if m.u8(0xa1269b) != 0:
				f5417e0(0xf9)
			return 0x7c
		0x7e:
			f54f750(1 - p, f401a70(m.u16(e + 14)))
			return 0x7d
		0x7f:
			f54f750(p, f401a70(m.u16(e + 14)))
			return 0x7e
		0x80:
			if (m.u8(e + 10) & 7) == 1:
				var target: int = m.u8(e + 12)
				var z: int = m.u8(e + 13)
				var card: int = DuelMem.zone(target & 1, z)
				if (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) == 0:
					m.set_u16(e + 14, m.u16(card) & 0xfff)
					f54e640(target, z, 0)
					f54ef30(target, m.u16(e + 14))
					f54e340(target, z, 0)
					var id: int = f401a70(m.u16(e)) & 0xffff
					if id == 0x485 and ctype(m.u16(e + 14)) < 0x15:
						var selected_id: int = f401a70(m.u16(e + 14))
						if f541d10(selected_id, 1) != 0 or f541d10(selected_id, 0) != 0:
							return 0x7f
					elif id == 0x486 and ctype(m.u16(e + 14)) == 0x15:
						return 0x7f
	return 0

func f560920(e: int) -> int:
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7d:
			var target: int = m.u8(0xa16148)
			var slot: int = f543360(1 - target)
			if slot >= 0:
				f54d570(p, m.u16(0xa16148), ((slot & 0xff) << 8) | ((1 - target) & 0xff))
			issue(m.s16(e + 2) << 15 | 0x60, 1, 0, 0)
			return 0x7c
		0x7e:
			if f57a060(0xe000e0) != 0 and f579890() != 0:
				var slot: int = f543570(p)
				var target: int = m.u8(0xa161a4) | (m.u8(0xa161ac) << 8)
				issue((0x8000 if p != 0 else 0) | 0x77, (slot & 0xff) | 0x100, m.u16(0xa1614c), m.u16(0xa1614e))
				f54e730(m.u8(e + 2) & 1, ((slot & 0xff) << 8) | (m.u8(e + 2) & 1), target)
				m.set_u16(0xa16148, target)
				return 0x7d
			return 0x7e
		0x7f:
			_j_named_dialog(0x43, f401ad0(0x4ea))
			return 0x7e
		0x80:
			if f57d250(p, 0x4ea, 999) != -1 and f5435a0(p, f401ad0(0x4ea)) != 0:
				for target in range(2):
					for z in range(5):
						var card: int = DuelMem.zone(target, z)
						if (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) != 0:
							f54dbd0(p, 0x4ea, 0xa1614c)
							return 0x7f
	return 0

func f561680(e: int, argument: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	var state: int = m.u8(0xa15fe0)
	match state:
		0x78:
			var which: int = m.u8(0xa15fe2)
			if which == 0:
				var hand: int = 0xa11fb8 + p * 0xd54 + m.u16(e + 12) * 4
				f54ef60(p, m.u16(hand) & 0xfff)
				issue(m.s16(e + 2) << 15 | 0xc2, m.u16(hand), m.u16(hand + 2), 0)
				issue(m.s16(e + 2) << 15 | 0xca, 0, 0, 0)
				f57cc50(p, hand, 1, 0, 0xb, m.u16(e + 12))
			else:
				f54e680(p, m.u16(e + 12 + which * 2), 0, 1)
			return 0x77
		0x79:
			for i in range(3):
				if i != m.u8(0xa15fe2):
					f54e680(p, m.u16(e + 12 + i * 2), 0, 0)
			return 0x78
		0x7a:
			var which: int = rng.rand() % 3
			while which == m.u8(0xa15fe2):
				which = rng.rand() % 3
			m.set_u8(0xa15fe2, which)
			issue(m.u16(e + 2) << 15 | 8, p, m.u8(e + 12 + which * 2) << 8 | 0xb, 0)
			return 0x79
		0x7c:
			f5417e0(0x4b)
			return 0x7b
		0x7e:
			f5417e0(0x4a)
			return 0x7d
		0x80:
			if invoke_original(0x554e70, [e, argument, 0]) != 0:
				f5417e0(0x49)
				return 0x7f
			return 0
		0x7b, 0x7d, 0x7f:
			if f57a060(1) == 0:
				return state
			var slot: int = m.u32(0xa161ac)
			var index: int = m.u16(0xa11fb8 + p * 0xd54 + slot * 4) & 0xfff
			if state == 0x7f:
				if ctype(index) > 0x14 or f5421c0(index) != 0:
					return state
			elif ctype(index) < 0x15 or (state == 0x7b and slot == m.u16(e + 14)):
				return state
			if f579890() == 0:
				return state
			issue(m.u16(e + 2) << 15 | 8, p, (slot & 0xff) << 8 | 0xb, 0)
			m.set_u16(e + (12 if state == 0x7f else (14 if state == 0x7d else 16)), slot)
			if state == 0x7b:
				m.set_u8(0xa15fe1, 0x10) # ASM 5618a3: solo el byte alto
				m.set_u8(0xa15fe2, 0)
			return state - 1
	return 0

func f55d3e0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	var state: int = m.u8(0xa15fe0)
	var id: int = f401a70(m.u16(e)) & 0xffff
	match state:
		0x1a, 0x7e:
			var answer: int = m.u16(0xa16178)
			if answer != 0:
				var buffer: int = m.local(4)
				var index: int = f54dbd0(p, id, buffer)
				f541cb0(0xa1614c, DuelMem.pl(p) + 0x7b4 + index * 4)
				return 0x7d
			return 100 if state < 100 else 0
		100:
			issue(m.u16(e + 2) << 15 | 0x60, 1, 0, 0)
			return 1
		0x7d:
			if id == 0x45a:
				f57cb60(p, 0xa1614c, 1, 0, 0, 0xd, 0)
			elif id == 0x45b or id == 0x51b:
				f57cb60(p, 0xa1614c, 0, 1, 0, 0xd, 0)
				if id == 0x51b:
					return 100
			return 0x1b
		0x80:
			if id == 0x45a:
				f54ef90(1 - p, 500)
			elif id == 0x45b:
				f54f0d0(p, 1000)
			return 0x7f
		0x7f:
			if f543330(p) == 0:
				return 0
			if p == 0 and f56ba50(p, id, 0) == 0:
				f5417e0(0x15)
				return 1
		0x1b:
			pass
		_:
			return 0
	if f543330(p) != 0 and f56ba50(p, id, 0) != 0:
		if p != 0:
			m.set_u16(0xa16178, 1)
			return 0x7e
		if id not in [0x45a, 0x45b, 0x51b]:
			return _unported(0x55d3e0)
		_j_named_dialog(0x35 if id == 0x45a else 0x34, m.u16(e))
		f540d60(1, 0)
		return m.u8(0xa15fe0) - 1
	return 100 if m.u8(0xa15fe0) < 100 else 0

func f55d7a0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var id: int = f401a70(m.u16(e)) & 0xffff
	if id == 0x45c and (m.u8(e + 2) & 0xe) != 6:
		issue(m.u16(e + 2) << 15 | 0x94, (m.u16(e + 2) >> 4) & 0x3f, 0, 0)
		return 0
	var p: int = m.u8(0xa15fe1)
	match m.u8(0xa15fe0):
		0x7d:
			p = 1 - p
			m.set_u8(0xa15fe1, p)
			return 100 if p == (m.u8(0xa133f2) & 1) else 0x7f
		0x7e:
			var buffer: int = m.local(4)
			var card: int = m.u32(0xa13428)
			if (m.u8(0xa16181) & 1) != 0 and (m.u8(0xa133f2) & 1) != 0:
				card ^= 0x1000
			m.set_u32(buffer, card)
			var mask: int = 0x8000 if p != 0 else 0
			issue(mask | 0xdf, f401a70(card & 0xfff), 0, 0)
			issue(mask | 0xd3, card & 0xffff, card >> 16, 0)
			if id == 0x45c:
				f57cc50(p, buffer, int(f5421c0(card & 0xfff) != 0), 0x20, 0xe, p)
			elif id == 0x487:
				f57cb60(p, buffer, 0, 1, 0x20, 0xe, p)
			return 0x7d
		0x80:
			m.set_u8(0xa15fe0, m.u8(0xa15fe0) - 1)
			p = m.u8(0xa133f2) & 1
			m.set_u8(0xa15fe1, p)
		0x7f:
			pass
		_:
			return 0
	if f543330(p) > 0 and f56ba50(m.u8(0xa15fe1), id, 0) > 0:
		f53e760(m.u8(0xa15fe1), 0xe, m.u16(e), m.u8(e + 2) & 1)
		return 0x7e
	return 0x7d

func f55e3b0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(0xa15fe1)
	match m.u8(0xa15fe0):
		0x7c:
			f57cb60(p, 0xa15fe8, 0, 1, 0, 0xb, m.u8(DuelMem.pl(p & 1) + 2) - 1)
			return 0x7f
		0x7d:
			f57cb60(1 - p, 0xa15fe8, 0, 1, 0, 0xb, m.u8(DuelMem.pl(p & 1) + 2) - 1)
			return 0x7f
		0x7f:
			if m.u8(DuelMem.pl(p & 1) + 3) != 0 and m.s16(e + 12 + p * 2) != 0:
				var top: int = DuelMem.pl(p & 1) + 0x7b4
				f541cb0(0xa15fe8, top)
				issue((0x8000 if p != 0 else 0) | 0x61, 1, 1, 0)
				f54ef60(m.u8(0xa15fe1), m.u16(top) & 0xfff)
				return 0x7e
			p = 1 - p
			m.set_u8(0xa15fe1, p)
			return 0x78 if p == (m.u8(e + 2) & 1) else 0x7f
		0x80:
			for target in range(2):
				m.set_u16(e + 12 + target * 2, 0)
				for z in range(5):
					var index: int = m.u16(DuelMem.zone(target, z)) & 0xfff
					if index != 0 and ctype(index) < 0x15:
						m.set_u16(e + 12 + target * 2, m.u16(e + 12 + target * 2) + 1)
			f54e5d0(m.u8(e + 2) & 1, 1)
			m.set_u8(0xa15fe1, m.u8(e + 2) & 1)
			return 0x7f
		0x7e:
			pass
		_:
			return 0
	var card: int = m.u32(0xa15fe8)
	if ((card >> 12) & 1) != p and (card & 0x20000) != 0 and (f401a70(card & 0xfff) & 0xffff) == 0x2fa:
		if f543330(1 - p) < 1:
			f54e680(p, m.u8(DuelMem.pl(p & 1) + 2) - 1, 0, 1)
			return 0x7f
		issue((0x8000 if p != 0 else 0) | 0xc2, card & 0xffff, card >> 16, 0)
		return 0x7d
	var index: int = card & 0xfff
	if ctype(index) < 0x15:
		if f4457d0(index) < 5 and f5421c0(index) == 0:
			issue((0x8000 if p != 0 else 0) | 0xc2, card & 0xffff, card >> 16, 0)
			m.set_u16(e + 12 + p * 2, m.u16(e + 12 + p * 2) - 1)
			return 0x7c
		m.set_u16(e + 12 + p * 2, m.u16(e + 12 + p * 2) - 1)
	f54e680(p, m.u8(DuelMem.pl(p & 1) + 2) - 1, int(p != (m.u8(e + 2) & 1)), 1)
	return 0x7f

## 53fac0 con 401010(index) + 5417e0: mensaje `template` con el nombre de la carta en su "%s".
func _j_named_dialog(template: int, index: int) -> void:
	dialog_format(template, [{"card": index}])

func f560060(e: int) -> int:
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7e:
			f54dc60(p, 0x2ea)
			return 0x7d
		0x7f:
			return 0x7e if m.u16(0xa16178) != 0 else 0
		0x80:
			if f56ba50(p, 0x4d8, 0) != 0:
				if p != 0:
					return 0x7e
				_j_named_dialog(0x41, f401ad0(0x2ea))
				f540d60(1, 0)
				return 0x7f
	return 0

func f5612e0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var p: int = m.u8(e + 2) & 1
		if m.u8(0xa15fe0) == 0x80:
			if p != 0:
				m.set_u16(0xa16178, 1)
			else:
				_j_named_dialog(0x47, f401ad0(0x2fa))
				f540d60(1, 0)
			return 0x7f
		if m.u16(0xa16178) != 0 and f54dbd0(p, 0x2fa, 0xa15fe8) != -1:
			issue(m.s16(e + 2) << 15 | 0x60, 1, 0, 0)
			issue(m.s16(e + 2) << 15 | 0x6a, m.u16(0xa15fe8), m.u16(0xa15fea), 0)
	return 0

func f5615d0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		if m.u8(0xa15fe0) == 0x80:
			_j_named_dialog(0x48, f401ad0(0x57d))
			f540d60(1, 0)
			return 0x7f
		# Tambien la CPU pasa por el cuadro: el original no distingue el jugador.
		if m.u16(0xa16178) != 0:

			issue(m.s16(e + 2) << 15 | 0x43, 1000, 1, 0)
			issue(m.s16(e + 2) << 15 | 0x4b, 1, 0, 0)
	return 0

func f55e840(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 2:
		var p: int = m.u8(e + 12)
		var z: int = m.u8(e + 13)
		var first: int = DuelMem.zone(p & 1, z)
		var second: int = DuelMem.zone(m.u8(e + 14) & 1, m.u8(e + 15))
		if (m.u32(first) & 0xfff) != 0 and (m.u8(first + 6) & 2) != 0 and (m.u32(second) & 0xfff) != 0 and (m.u8(second + 6) & 2) != 0:
			issue((0x8000 if p != 0 else 0) | 0x9a, z, 0, 0)
			# ASM: los dos argumentos finales sobreviven en pila a ATK/redondeo.
			f54c860(m.u8(e + 2) & 1, f53fbd0(f547c60(p, z)), m.u16(e + 14), 4)
	return 0

func f561420(e: int) -> int:
	if (m.u8(e + 10) & 7) == 1:
		var p: int = m.u8(e + 12)
		var z: int = m.u8(e + 13)
		var card: int = DuelMem.zone(p & 1, z)
		var index: int = m.u16(card) & 0xfff
		var flags: int = m.u16(card + 6)
		if index != 0 and (flags & 1) != 0 and (flags & 2) == 0:
			f54e640(p, z, 0)
			if f542150(index) != 0:
				m.set_u32(card, m.u32(card) | 0x4000)
				f555570(p, z)
				f56e3b0(m.u8(e + 2) & 1, p, z)
				m.set_u32(card, m.u32(card) & 0xffffbfff)
				return 0
			f54ef60(p, index)
			f54e640(p, z, 0)
	return 0

func f561c70(e: int) -> int:
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7e:
			var id: int = f401a70(m.u16(e)) & 0xffff
			if id not in [0x58d, 0x596, 0x599, 0x5a4]:
				return 0
			var entry: int = f4073b0()
			if id == 0x58d or id == 0x5a4:
				issue(m.u16(e + 2) << 15 | (0xdb if id == 0x58d else 0xd2), m.u16(entry), m.u16(entry + 2), 0)
			else:
				issue(m.u16(e + 2) << 15 | (0xd0 if id == 0x596 else 0xd1), f401a70(m.u16(entry) & 0xfff), 0, 0)
			return 0x78
		0x7f:
			f407580(p, -1, 0x58d, 0)
			return 0x7e
		0x80:
			if f56ba50(p, 0x58d, 0) != 0:
				var id: int = f401a70(m.u16(e)) & 0xffff
				if id == 0x58d or id == 0x5a4:
					f5417e0(0x4d)
					return 0x7f
				if id == 0x596 or id == 0x599:
					f5417e0(0x4c)
					return 0x7f
	return 0

func f561e90(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0 or f542f30(0, 0x58a) >= 1 or f542f30(1, 0x58a) >= 1 or (m.u8(e + 10) & 7) != 2:
		return 0
	for i in range(2):
		var location: int = m.u16(e + 12 + i * 2)
		if (location & 0xff) != (m.u8(e + 2) & 1) or (m.u32(DuelMem.zone(location & 1, location >> 8)) & 0xfff) == 0:
			return 0
	for i in range(2):
		f54ea40(m.u8(e + 12 + i * 2), m.u8(e + 13 + i * 2))
	var id: int = f401a70(m.u16(e)) & 0xffff
	if id == 0x598:
		f54ef90(1 - (m.u8(e + 2) & 1), 1200)
	elif id == 0x5a2:
		f54f0d0(m.u8(e + 2) & 1, 1000)
	return 0

func _j_coin_start(e: int) -> int:
	if (m.u8(e + 2) & 1) == 0:
		f5417e0(0x38)
		f540d60(7, 0)
	else:
		m.set_u16(0xa16178, rng.rand() & 1)
	return 0x7f

func f560bc0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		if m.u8(0xa15fe0) == 0x80:
			return _j_coin_start(e)
		if m.u8(0xa15fe0) == 0x7f:
			var result: int = rng.rand() & 1
			issue(m.u16(e + 2) << 15 | 0xe0, m.u16(0xa16178), result, (m.u16(e + 2) >> 4) & 0x3f)
			if result == m.u16(0xa16178):
				var p: int = m.u8(e + 2) & 1
				var hand: int = m.u8(DuelMem.pl(p) + 2)
				if hand < 5:
					f54f470(p, 5 - hand)
			else:
				issue(m.s16(e + 2) << 15 | 0x46, 1, 0, 0)
			return 10
	return 0

func f561b00(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		if m.u8(0xa15fe0) == 0x80:
			return _j_coin_start(e)
		if m.u8(0xa15fe0) == 0x7f:
			var result: int = rng.rand() & 1
			issue(m.u16(e + 2) << 15 | 0xe0, m.u16(0xa16178), result, (m.u16(e + 2) >> 4) & 0x3f)
			if result == m.u16(0xa16178):
				issue(m.s16(e + 2) << 15 | 0x3a, 0, 0, 0)
			return 10
	return 0

func f560d60(e: int) -> int:
	for z in range(5):
		var p: int = m.u8(e + 2) & 1
		var card: int = DuelMem.zone(p, z)
		if (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) != 0 and (f545c40(p, z) & 0xffff) == 7 and f54f9f0(m.u8(e + 2) & 1, z) != 0:
			f54c860(m.u8(e + 2) & 1, m.u16(e), (z << 8) | (m.u8(e + 2) & 1), 3)
	return 0

func f560e00(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 1:
		var p: int = m.u8(e + 2) & 1
		match m.u8(0xa15fe0):
			0x7e:
				f54f470(p, m.u8(0xa15fe1))
				return 0x7d
			0x7f:
				issue(m.s16(e + 2) << 15 | 0x60, 1, 0, 0)
				return 0x7e
			0x80:
				if (m.u32(DuelMem.zone(m.u8(e + 12) & 1, m.u8(e + 13))) & 0xfff) != 0:
					f54e510(m.u8(e + 12), m.u8(e + 13))
					var count: int = m.u8(DuelMem.pl(m.u8(e + 2) & 1) + 2)
					m.set_u8(0xa15fe1, count)
					for i in range(count):
						f54d900(m.u8(e + 2) & 1, 0, 1)
					return 0x7f
	return 0

func f560f70(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7c:
			issue(m.s16(e + 2) << 15 | 0x60, 0, 0, 0)
			return 100
		0x7d:
			f57cc50(p, f4073b0(), 0, 0x20, 0xd, 0)
			return 0x7c
		0x7e:
			var entry: int = f4073b0()
			issue(m.s16(e + 2) << 15 | 0x65, m.u16(entry), m.u16(entry + 2), 0)
			return 0x7d
		0x7f:
			f407580(p, -1, 0x526, m.u16(e + 12))
			return 0x7e
		0x80:
			if (m.u8(e + 10) & 7) == 1 and f56ba50(p, 0x526, m.u16(e + 12)) != 0:
				f5417e0(0x30)
				return 0x7f
	return 0

func f55ea40(e: int) -> int:
	var value: int = rng.rand() % 6 + 1
	if (m.u8(e + 4) & 4) == 0:
		var id: int = f401a70(m.u16(e)) & 0xffff
		var op: int = e
		var p: int = e
		if id == 0x4b3:
			op = 0xe2
			p = m.u8(e + 2) & 1
		elif id == 0x4b4:
			op = 0xe3
			p = 1 - (m.u8(e + 2) & 1)
		issue(m.u16(e + 2) << 15 | op, value, (m.u16(e + 2) >> 4) & 0x3f, 0)
		for z in range(5):
			var card: int = DuelMem.zone(p & 1, z)
			if (m.u8(card + 6) & 2) != 0 and (m.u32(card) & 0xfff) != 0:
				f54c860(m.u8(e + 2) & 1, m.u16(e), (z << 8) | (p & 0xff), value << 8 | 3)
	return 0

func f55fec0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7d:
			f56e280(1 - p, m.u16(e + 12 + (1 - p) * 2))
			return 0x7c
		0x7e:
			f56e280(p, m.u16(e + 12 + p * 2))
			return 0x7d
		0x7f:
			for side in range(2):
				var target: int = p if side == 0 else 1 - p
				f54f470(target, m.u16(e + 12 + target * 2))
			return 0x7e
		0x80:
			for side in range(2):
				var target: int = p if side == 0 else 1 - p
				var count: int = m.u8(DuelMem.pl(target & 1) + 2)
				m.set_u16(e + 12 + target * 2, count)
				for i in range(count - 1, -1, -1):
					f54e680(target, i, side, 1)
			return 0x7f
	return 0

func f560540(e: int, copied: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	if m.u8(0xa15fe0) == 0x80:
		m.copy(0xa160e6, copied, 20)
		m.set_u8(0xa160e8, m.u8(0xa160e8) ^ 1)
		var table_index: int = f56e540(m.u16(0xa160e6))
		m.set_u32(0xa160fc, effect_column(table_index, 0x4))
	var id: int = f401a70(m.u16(copied)) & 0xffff
	var allowed: bool = id in [0x40f, 0x42e, 0x42f, 0x439, 0x401, 0x3f2, 0x3ee, 0x3ef, 0x3c8] or (id >= 0x151 and id <= 0x159)
	if not allowed:
		return 0
	var state: int = invoke_original(m.u32(0xa160fc), [0xa160e6, 0]) & 0xff
	m.set_u8(0xa15fe0, state)
	if state != 0:
		return state
	issue(m.s16(e + 2) << 15 | 0xb0, 1, 0, 0)
	return 0

func f560690(e: int) -> int:
	var owner: int = m.u8(e + 2) & 1
	m.set_u8(DuelMem.pl(owner) + 0x10, m.u8(DuelMem.pl(owner) + 0x10) | 1)
	m.set_u8(DuelMem.pl(owner) + 8, m.u8(DuelMem.pl(owner) + 8) & 0xbf)
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 1 and f550e00(e, m.u16(e + 12)) != 0:
		var p: int = m.u8(e + 12)
		var attack: int = f547c60(p, m.u8(e + 13))
		for z in range(5):
			var card: int = DuelMem.zone(1 - p, z)
			if (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) != 0 and f547c80(1 - p, z) < attack and f54f9f0(1 - p, z) != 0:
				f555570(1 - p, z)
				f56e3b0(m.u8(e + 2) & 1, 1 - p, z)
	return 0

func f55dd80(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7e, 0x7f:
			var state: int = m.u8(0xa15fe0)
			var target: int = 1 - p if state == 0x7e else p
			var counter: int = e + 12 + target * 2
			if m.s16(counter) != 0 and f53e970(target) != 0:
				m.set_u16(counter, m.u16(counter) - 1)
				return state
			return state - 1
		0x80:
			for target in range(2):
				m.set_u16(e + 12 + target * 2, 0)
				for z in range(5):
					if (m.u32(DuelMem.zone(target, z)) & 0xfff) != 0:
						issue((0x8000 if target != 0 else 0) | 0x81, z, 0, 0)
						m.set_u16(e + 12 + target * 2, m.u16(e + 12 + target * 2) + 1)
			m.set_u8(0xa15fe1, m.u8(e + 2) & 1)
			return 0x7f
	return 0

func f55deb0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		for p in range(2):
			for z in range(5):
				var card: int = DuelMem.zone(p, z)
				var flags: int = m.u16(card + 6)
				if (m.u32(card) & 0xfff) != 0 and (flags & 1) != 0 and (flags & 2) == 0:
					f54e640(p, z, 0)
		var count: int = 0
		for p in range(2):
			for z in range(5):
				var index: int = m.u16(DuelMem.zone(p, z)) & 0xfff
				if index != 0 and f542150(index) != 0:
					count += 1
		if count > 0:
			f54ef90(1 - (m.u8(e + 2) & 1), count * 500)
	return 0

func f55e1f0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var descriptor: int = m.u16(e + 2)
	var p: int = descriptor & 1
	if p == (m.u8(0xa133f2) & 1) or (descriptor & 0xfc00) != 0x800:
		return 0
	var state: int = m.u8(0xa15fe0)
	if state == 0x78:
		issue(descriptor << 15 | 8, 1 - p, m.u8(0xa15fe2) << 8 | 0xb, 0)
		f54eea0(m.u8(e + 2) & 1, m.u16(0xa11fb8 + (1 - (m.u8(e + 2) & 1)) * 0xd54 + m.u8(0xa15fe2) * 4) & 0xfff)
		return 0
	if state == 0x80:
		if (m.u32(DuelMem.zone(p, (descriptor >> 4) & 0x3f)) & 0xfff) == 0:
			return 0
		var count: int = m.u8(DuelMem.pl(1 - p) + 2)
		m.set_u8(0xa15fe1, count << 1)
		if count == 1:
			m.set_u8(0xa15fe2, 0)
			return 0x78
		m.set_u8(0xa15fe0, state - 1)
	elif state != 0x7f:
		return 0
	var hand_count: int = m.u8(DuelMem.pl(1 - (m.u16(e + 2) & 1)) + 2)
	if hand_count == 0:
		return _unported(0x55e1f0)
	m.set_u8(0xa15fe2, rng.rand() % hand_count)
	return 0x78

func f55f250(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var descriptor: int = m.u16(e + 2)
	var p: int = descriptor & 1
	match m.u8(0xa15fe0):
		0x7f:
			# 0xa16178: cara elegida en la ventana de moneda (tipo 7) o al azar por la CPU.
			var result: int = rng.rand() & 1
			issue(descriptor << 15 | 0xe0, m.u16(0xa16178), result, (descriptor >> 4) & 0x3f)
			f54c860(p, m.u16(e), ((((descriptor >> 4) & 0xff) << 8) | (descriptor & 0xff)) & 0x3f01, (0x100 if result == m.u16(0xa16178) else 0) | 3)
			return 10
		0x80:
			if p == 0:
				f5417e0(0x38)
				f540d60(7, 0)
			else:
				m.set_u16(0xa16178, rng.rand() & 1)
			return 0x7f
	issue(descriptor << 15 | 0x94, (descriptor >> 4) & 0x3f, 0, 0)
	return 0

func f55f350(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var bits: int = 0
		var heads: int = 0
		for i in range(3):
			if (rng.rand() & 1) == 0:
				heads += 1
			else:
				bits |= 1 << i
		issue(m.u16(e + 2) << 15 | 0xe1, 0, bits, (m.u16(e + 2) >> 4) & 0x3f)
		if heads > 1:
			f555570(1 - (m.u8(e + 2) & 1), m.u8(e + 13))
			var p: int = m.u8(e + 2) & 1
			f56e3b0(p, 1 - p, m.u8(e + 13))
		var descriptor: int = m.u16(e + 2)
		if (m.u32(DuelMem.zone(descriptor & 1, (descriptor >> 4) & 0x3f)) & 0xfff) != 0:
			issue(descriptor << 15 | 0x94, (descriptor >> 4) & 0x3f, 0, 0)
	return 0

func f55f440(e: int) -> int:
	var flags: int = m.u16(e + 4)
	if (flags & 4) == 0:
		var p: int = m.u8(e + 2) & 1
		if m.u8(0xa15fe0) == 0x7f:
			f57cc50(p, 0xa11624, 1, 0, 0xd, 0)
			return 0x7e
		if m.u8(0xa15fe0) == 0x80:
			if f56ba50(p, f401a70(m.u16(e)), 0) != 0:
				issue(m.u16(e + 2) << 15 | 0x65, m.u16(0xa11624), m.u16(0xa11626), 0)
				return 0x7f
		else:
			issue(m.u16(e + 2) << 15 | 0x49, 1, 1, 0)
	elif (flags & 8) == 0:
		issue(m.u16(e + 2) << 15 | 0x49, 1, 1, 0)
	return 0

func f55f520(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0 or (m.u8(e + 10) & 7) != 2:
		return 0
	var p: int = m.u8(e + 12)
	var z: int = m.u8(e + 13)
	if m.u8(0xa15fe0) == 0x7f:
		f54d570(m.u8(e + 2) & 1, m.u16(e + 14), m.u16(e + 12))
	elif m.u8(0xa15fe0) == 0x80 and (m.u32(DuelMem.zone(p & 1, z)) & 0xfff) != 0 and (m.u32(DuelMem.zone(m.u8(e + 14) & 1, m.u8(e + 15))) & 0xfff) != 0 and p != (m.u8(e + 2) & 1) and m.u8(e + 14) == (m.u8(e + 2) & 1):
		f555570(p, z)
		f56e3b0(m.u8(e + 2) & 1, p, z)
		return 0x7f
	return 0

func f561170(e: int, entry: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var state: int = m.u8(0xa15fe0)
	if state == 0x80:
		var enemy: int = 1 - (m.u8(e + 2) & 1)
		if m.u8(DuelMem.pl(enemy) + 2) != 0:
			f53e760(enemy, 0x11, 0, 0)
			return 0x7f
		return 0x7e
	if state == 0x7f:
		if m.u16(0xa13428) != 0:
			return 0
		m.set_u8(0xa15fe0, state - 1)
	elif state != 0x7e:
		return 0
	if entry == 0:
		return 0
	if ctype(m.u16(entry)) == 0x16:
		issue(m.s16(e + 2) << 15 | 0xb0, 1, 0, 0)
	return 100

func f561260(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u16(e + 2) & 0xfc00) == 0x2000:
		var p: int = m.u8(e + 6)
		var z: int = m.u8(e + 7)
		if p != (m.u16(e + 2) & 1):
			var card: int = DuelMem.zone(p & 1, z)
			var flags: int = m.u16(card + 6)
			if (m.u32(card) & 0xfff) != 0 and (flags & 1) != 0 and (flags & 2) == 0:
				f54e660(p, z, 1, 0)
	return 0

func f561500(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		for z in range(5):
			var p: int = m.u8(e + 2) & 1
			var card: int = DuelMem.zone(1 - p, z)
			var index: int = m.u16(card) & 0xfff
			if (m.u8(card + 6) & 2) != 0 and index != 0:
				var kind: int = ctype(index)
				if (kind < 0x15 or (kind > 0x17 and kind != 0x18)) and ((f401a20(index) >> 25) & 0xf) == 4:
					f555570(1 - p, z)
					p = m.u8(e + 2) & 1
					f56e3b0(p, 1 - p, z)
	return 0

func f561a40(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		if (m.u8(e + 10) & 7) == 1:
			var card: int = DuelMem.zone(m.u8(e + 12) & 1, m.u8(e + 13))
			if (m.u16(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) != 0 and ctype(m.u16(card) & 0xfff) == 0x16:
				var descriptor: int = m.u16(e + 2)
				f54c860(descriptor & 1, ((((descriptor >> 4) & 0xff) << 8) | (descriptor & 0xff)) & 0x3f01, m.u16(e + 12), 2)
				return 0
		f54e250(m.u16(e + 2) & 1, (m.u16(e + 2) >> 4) & 0x3f, 1)
	return 0

func f561bc0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 1:
		var card: int = DuelMem.zone(m.u8(e + 12) & 1, m.u8(e + 13))
		var index: int = m.u16(card) & 0xfff
		if (m.u8(card + 6) & 2) != 0 and index != 0 and (f401a70(index) & 0xffff) == 0x57d:
			issue(m.u16(e + 2) << 15 | 8, m.u8(e + 2) & 1, m.u8(e + 13) << 8, 0)
			issue(m.s16(e + 2) << 15 | 0x38, m.u16(e + 12), 1, 0)
	return 0

func f562020(e: int) -> int:
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7e:
			var entry: int = f4073b0()
			issue(m.s16(e + 2) << 15 | 0xd1, f401a70(m.u16(entry) & 0xfff), 0, 0)
			return 0x78
		0x7f:
			f407580(p, -1, 0x59f, 0)
			return 0x7e
		0x80:
			if f56ba50(p, 0x59f, 0) != 0:
				f5417e0(0x4e)
				return 0x7f
	return 0

func f5603e0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and f543330(m.u8(e + 2) & 1) > 3:
		var count: int = 0
		for z in range(5):
			if count > 3:
				break
			if f543260(m.u8(e + 2) & 1, z) != 0:
				issue(m.u16(e + 2) << 15 | 0xa5, ((((m.u16(e + 2) >> 4) & 0xff) << 8) | z) & 0x3fff, 2, 0)
				count += 1
		issue(m.s16(e + 2) << 15 | 0x49, 1, 1, 0)
	return 0

func f560480(e: int) -> int:
	if m.u8(0xa15fe0) == 0x7f:
		if f57a060(0xe00000) != 0 and f579890() != 0:
			var descriptor: int = m.u16(e + 2)
			var selected: int = DuelMem.zone(m.u32(0xa161a4) & 1, m.u32(0xa161ac))
			f54c860(descriptor & 1, m.u16(selected) & 0xfff, ((((descriptor >> 4) & 0xff) << 8) | (descriptor & 0xff)) & 0x3f01, 8)
			return 0x78
		return 0x7f
	if m.u8(0xa15fe0) == 0x80 and f5431f0(1 - (m.u8(e + 2) & 1), 1, 0) != 0:
		f5417e0(0x44)
		return 0x7f
	return 0

func f5607a0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 1:
		var p: int = m.u8(e + 12)
		var z: int = m.u8(e + 13)
		var card: int = DuelMem.zone(p & 1, z)
		if p != (m.u8(e + 2) & 1) and (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) != 0 and (f545c40(p, z) & 0xffff) == 7:
			var kind: int = 14 if (m.u8(e + 2) & 1) != 0 else 3
			var location: int = z << 8 | p
			f54c880(p, m.u16(e), location, kind)
			f54c860(p, m.u16(e), location, ((m.u8(e + 2) << 8) | kind) & 0x1ff)
	return 0

func f560880(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var p: int = m.u8(e + 2) & 1
		if m.u8(0xa15fe0) == 0x7f:
			if m.u8(DuelMem.pl(1 - p) + 2) != 0:
				f53e830(1 - p, 1, 0, 1)
			return 0x7e
		if m.u8(0xa15fe0) == 0x80:
			if m.u8(DuelMem.pl(p) + 2) != 0:
				f53e830(p, 1, 0, 0)
			return 0x7f
	return 0

func f5610f0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 2:
		for i in range(2):
			var location: int = m.u16(e + 12 + i * 2)
			if (m.u32(DuelMem.zone(location & 1, location >> 8)) & 0xfff) == 0:
				var descriptor: int = m.u16(e + 2)
				f54c860(descriptor & 1, ((((descriptor >> 4) & 0xff) << 8) | (descriptor & 0xff)) & 0x3f01, location, 2)
	return 0

func f55e740(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var protect: bool = f542f30(0, 0x148) != 0 or f542f30(1, 0x148) != 0
		var enemy: int = 1 - (m.u8(e + 2) & 1)
		for z in range(5):
			var card: int = DuelMem.zone(enemy, z)
			var flags: int = m.u16(card + 6)
			if (m.u32(card) & 0xfff) != 0 and (flags & 2) != 0 and (not protect or (flags & 1) == 0 or (f545c40(enemy, z) & 0xffff) != 1):
				f54e660(enemy, z, 0, 0)
	return 0

func f55e910(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		for z in range(11):
			var p: int = m.u8(e + 2) & 1
			var card: int = DuelMem.zone(1 - p, z)
			if (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) == 0:
				issue(m.u16(e + 2) << 15 | 8, 1 - p, z << 8, 0)
				issue((0x8000 if p != 1 else 0) | 0x80, z, 0, 0)
				f54eea0(p, m.u16(card) & 0xfff)
				issue(m.s16(e + 2) << 15 | 0xf1, 0xf, 0, 0)
				issue((0x8000 if (m.u8(e + 2) & 1) != 1 else 0) | 0x80, z, 0, 0)
	return 0

func f55eb40(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var p: int = m.u8(e + 2) & 1
		match m.u8(0xa15fe0):
			0x7e:
				m.set_u16(e + 14, m.u16(0xa13428))
				issue(m.s16(e + 2) << 15 | 199, m.u16(0xa13428), m.u16(e + 12), 0)
				return 100
			0x7f:
				m.set_u16(e + 12, m.u16(0xa13428))
				f53e760(1 - p, 6, 0, 0)
				return 0x7e
			0x80:
				f53e760(p, 6, 0, 0)
				return 0x7f
	return 0

func f55d1b0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7c:
			issue(m.u16(e + 2) << 15 | 0x60, 1, 0, 0)
			return 1
		0x7d:
			var entry: int = f4073b0()
			if f54dc60(p, f401a70(m.u16(entry) & 0xfff)) != 0:
				entry = f4073b0()
				f54ef30(p, m.u16(entry) & 0xfff)
				entry = f4073b0()
				issue(m.u16(e + 2) << 15 | 0x1f, f401a70(m.u16(entry) & 0xfff), m.u8(DuelMem.pl(p) + 2), 0)
			return 0x7c
		0x7e:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7d
		0x7f:
			var answer: int = m.u16(0xa16178)
			if answer > 0:
				f5417e0(0x33)
				return 0x7e
		0x80:
			if f56ba50(p, f401a70(m.u16(e)), 0) != 0:
				if p != 0:
					f57d330(m.u16(e))
					f4073a0(m.u16(0xa14f02))
					return 0x7d
				var id: int = f401a70(m.u16(e)) & 0xffff
				if id != 0x455 and id != 0x462:
					return 0
				f5417e0(0x31 if id == 0x455 else 0x32)
				f540d60(1, 0)
				return 0x7f
			if p == 0:
				f5417e0(0x15)
				return 1
	return 0

func f55dc20(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	var state: int = m.u8(0xa15fe0)
	match state:
		0x7c:
			var entry: int = f4073b0()
			f54da50(p, f401a70(m.u16(entry) & 0xfff))
			f54ef30(p, m.u16(f4073b0()) & 0xfff)
			m.set_u8(0xa15fe1, m.u8(0xa15fe1) - 1)
			return 0x7f if m.u8(0xa15fe1) != 0 else 100
		0x7d:
			f407580(p, -1, 0x47b, 0)
			return 0x7c
		0x7e:
			var answer: int = m.u16(0xa16178)
			if answer > 0:
				f5417e0(0x37)
				return 0x7d
		0x80, 0x7f:
			if state == 0x80:
				m.set_u16(0xa15fe0, 0x37f)
			if f56ba50(p, 0x47b, 0) != 0:
				if p == 0:
					f5417e0(0x36)
					f540d60(1, 0)
					return 0x7e
				f57d330(m.u16(e))
				f4073a0(m.u16(0xa14f02))
				return 0x7c
	return 0

func f55cb70(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(0xa15fe1)
	var mask: int = 0x8000 if p != 0 else 0
	match m.u8(0xa15fe0):
		0x17:
			issue(mask | 0x65, m.u16(0xa1614c), m.u16(0xa1614e), 0)
			return 0x7b
		0x7c, 0x7b:
			if m.u8(0xa15fe0) == 0x7c:
				issue(mask | 0x61, 1, 1, 0)
			m.set_u8(0xa15fe2, m.u8(0xa15fe2) - 1)
			if m.u8(0xa15fe2) != 0:
				return 0x7f
			m.set_u8(0xa15fe1, 1 - p)
			m.set_u8(0xa15fe2, 5)
			return 0x78 if m.u8(0xa15fe1) == (m.u8(0xa133f2) & 1) else 0x7f
		0x7d:
			f57cc50(1 - p, 0xa1614c, 1, 0, 0xd, 0)
			return 0x17
		0x7e:
			f57cc50(p, 0xa1614c, 0, 0, 0xd, 0)
			return 0x17
		0x7f:
			if m.u8(DuelMem.pl(p & 1) + 3) == 0:
				return 0x7b
			var top: int = DuelMem.pl(p & 1) + 0x7b4
			f54ef30(p, m.u16(top) & 0xfff)
			issue(mask | 0x20, f401a70(m.u16(top) & 0xfff), 0xd, 0)
			issue(mask | 0xf1, 0x1e, 0, 0)
			var card: int = m.u32(top)
			if ((card >> 12) & 1) == p or (card & 0x20000) == 0 or (f401a70(card & 0xfff) & 0xffff) != 0x2fa:
				var index: int = card & 0xfff
				if ctype(index) < 0x15 and f4457d0(index) < 5 and f5421c0(index) == 0:
					f541cb0(0xa1614c, top)
					return 0x7e
			else:
				if f543330(1 - p) > 0:
					f541cb0(0xa1614c, top)
					return 0x7d
				f54f4c0(p, 1, 0)
			return 0x7c
		0x80:
			var descriptor: int = m.u16(e + 2)
			var owner: int = descriptor & 1
			var z: int = (descriptor >> 4) & 0x3f
			f54cc10(owner, m.u8(0xa133f2) & 1, 1, 0, 0)
			if (descriptor & 0xfc00) == 0x4800 and (m.u32(DuelMem.zone(owner, z)) & 0xfff) == 0:
				m.set_u8(0xa114c4 + owner * 6, m.u8(0xa114c4 + owner * 6) & 0xf7)
				var zone: int = DuelMem.zone(owner, z)
				m.set_u8(zone + 0x90, m.u8(zone + 0x90) | 4)
				issue(descriptor << 15 | 0x79, z, 1, 0)
				issue(m.s16(e + 2) << 15 | 0x7d, m.u16(0xa114dc + owner * 0x94), m.u16(0xa114de + owner * 0x94), 0)
				f56e2e0(owner, 1)
				f54ca50(owner, z, 1)
			m.set_u8(0xa15fe1, m.u8(0xa133f2) & 1)
			m.set_u8(0xa15fe2, 5)
			issue((0x8000 if m.u8(0xa15fe1) != 0 else 0) | 0xf1, 0x1e, 0, 0)
			return 0x7f
	return 0

func f560cc0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		for p in range(2):
			if (m.u32(DuelMem.zone(p, 10)) & 0xfff) != 0:
				f54e250(p, 10, 1)
	return 0

func f560ef0(e: int, out: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var descriptor: int = m.u16(e + 2)
		if (descriptor & 0xfc00) != 0x4000:
			return f55c030(e, out)
		issue(descriptor << 15 | 8, descriptor & 1, m.u8(e + 13) << 8, 0)
		issue(m.s16(e + 2) << 15 | 0x38, m.u16(e + 12), 1, 0)
	return 0

func f561090(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 1:
		var p: int = m.u8(e + 12)
		var z: int = m.u8(e + 13)
		if (m.u32(DuelMem.zone(p & 1, z)) & 0xfff) != 0:
			issue((0x8000 if p != 0 else 0) | 0xab, z, 1, 0)
	return 0

func f5613d0(e: int) -> int:
	if (m.u8(e + 10) & 7) == 1:
		var p: int = m.u8(e + 12)
		var z: int = m.u8(e + 13)
		if (m.u32(DuelMem.zone(p & 1, z)) & 0xfff) != 0:
			f54e660(p, z, 0, 0)
	return 0

func f561fb0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		f54f490(m.u8(e + 2) & 1, 3)
		f54ef90(1 - (m.u8(e + 2) & 1), 800)
	return 0

func f561ff0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		f54ef90(1 - (m.u8(e + 2) & 1), 800)
	return 0

func f561230(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		f54ef90(1 - (m.u8(e + 2) & 1), 500)
	return 0

func f560b70(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		f54e510(m.u16(e + 2) & 1, (m.u16(e + 2) >> 4) & 0x3f)
		issue(m.s16(e + 2) << 15 | 0x60, 1, 0, 0)
	return 0

func f560d00(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		issue(m.s16(e + 2) << 15 | 0x4a, 2, 0, 0)
		issue((0x8000 if (m.u8(e + 2) & 1) != 1 else 0) | 0x4a, 2, 0, 0)
	return 0

func f560000(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		for z in range(5):
			if f543260(m.u8(e + 2) & 1, z) != 0:
				issue(m.u16(e + 2) << 15 | 0xa5, ((((m.u16(e + 2) >> 4) & 0xff) << 8) | z) & 0x3fff, 1, 0)
	return 0

func f55d9f0(e: int) -> int:
	if m.u8(0xa15fe0) == 0x80 and (m.u8(e + 4) & 4) == 0:
		var op: int = {0x470: 0x15, 0x471: 0x16, 0x472: 0x18, 0x473: 0x17}.get(f401a70(m.u16(e)) & 0xffff, 0)
		if op != 0:
			issue(m.u16(e + 2) << 15 | op, 1, 0, 0)
			return 0x7f
	invoke_original(0x56a9e0, [0])
	return 0

func f55dae0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var id: int = f401a70(m.u16(e)) & 0xffff
		var p: int = m.u8(e + 2) & 1
		if id == 0x474:
			f54f0d0(p, (f544a00(p, id) + 2) * 500)
		elif id == 0x518:
			f54ef90(1 - p, f544a00(p, id) * 300 + 700)
	return 0

func f55db90(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		if m.u8(0xa15fe0) == 0x80:
			if (m.u8(e + 10) & 7) == 1 and m.u16(e + 12) != 0:
				issue(m.u16(e + 2) << 15 | 0x88, (m.u16(e + 2) >> 4) & 0x3f, m.u16(e + 12), 0)
				return 0x7f
		elif (f401a70(m.u16(e)) & 0xffff) == 0x479:
			for p in range(2):
				for z in range(5):
					f545240(p, z)
	return 0

func f55e370(e: int) -> int:
	# El emisor Yugi apunta al no-op4039b0.
	if (m.u8(e + 4) & 4) == 0:
		issue(m.u16(e + 2) << 15 | 0x8f, (m.u16(e + 2) >> 4) & 0x3f, m.u16(e + 12), 0)
	return 0

func f55e810(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		f54f0d0(m.u8(e + 2) & 1, m.u16(e + 6))
	return 0

func f55c080(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0 or (m.u8(e + 10) & 7) != 2:
		return 0
	var p: int = m.u8(e + 12)
	var z: int = m.u8(e + 13)
	var target: int = m.u16(e + 14)
	if f550b10(e, m.u16(e + 12)) == 0 or f545fb0(p, z, target & 0xff, target >> 8) == 0 or (f546020(p, z) & 0xffff) == target:
		return 0
	if (m.u8(DuelMem.zone(p & 1, z) + 0x90) & 1) == 0:
		f54e850(m.u16(e + 12), target)
	else:
		for i in range(m.u16(0xa15fc0) - 1):
			var entry: int = 0xa15e82 + i * 20
			var descriptor: int = m.u16(entry)
			if (descriptor & 1) == p and ((descriptor >> 4) & 0x3f) == z:
				m.set_u16(entry + 10, target)
				break
	return 0

func f55c4e0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 2:
		var index: int = m.u16(e + 12) & 0xfff
		var buffer: int = m.local(4)
		if f544950(1 - (m.u8(e + 2) & 1), index, buffer) != 0:
			issue(m.s16(e + 2) << 15 | 0xd5, f401a70(index), 0, 0)
	return 0

func f55c560(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var count: int = 0
		for p in range(2):
			for z in range(5):
				var card: int = DuelMem.zone(p, z)
				if (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) != 0:
					count += 1
		if count > 0:
			f54f0d0(m.u8(e + 2) & 1, count * 300)
	return 0

func f55cab0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 1:
		var owner: int = m.u8(e + 2) & 1
		for side in range(2):
			var p: int = 1 - owner if side == 0 else owner
			for z in range(5):
				var card: int = DuelMem.zone(p, z)
				if (m.u32(card) & 0xfff) != 0 and (m.u8(card + 6) & 2) != 0 and (f545e70(p, z) & 0xffff) == m.u16(e + 12):
					f555570(p, z)
					f56e3b0(owner, p, z)
	return 0

func f55bcb0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0 and m.u8(0xa15fe0) == 0x80:
		f54f470(m.u8(e + 2) & 1, 1)
		f54f0d0(1 - (m.u8(e + 2) & 1), 1000)
		return 0x7f
	return 0

func f55bd00(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0 or m.u8(0xa15fe0) != 0x80:
		return 0
	var p: int = m.u8(e + 2) & 1
	f54cc10(p, m.u8(0xa133f2) & 1, 1, 0, 1)
	for z in range(5, 11):
		var index: int = m.u32(DuelMem.zone(1 - p, z)) & 0xfff
		if index != 0 and not ((m.u8(e + 4) & 0x10) != 0 and ctype(index) == 0x15):
			f54e250(1 - p, z, 1)
	for z in range(5, 11):
		if (m.u32(DuelMem.zone(p, z)) & 0xfff) != 0:
			f54e250(p, z, 1)
	return 0x7f

func f55be00(e: int) -> int:
	var descriptor: int = m.u16(e + 2)
	var p: int = descriptor & 1
	var z: int = (descriptor >> 4) & 0x3f
	var result: int = p
	if (m.u8(e + 4) & 8) == 0:
		result = 0
		if (m.u32(DuelMem.zone(p, z)) & 0xfff) != 0 and (m.u8(DuelMem.zone(p, z) + 6) & 2) != 0:
			result = f401a70(m.u16(DuelMem.zone(p, z)) & 0xfff)
			if (result & 0xffff) == 0x42c and (m.u8(e + 10) & 7) == 1:
				result = m.u8(e + 12)
				var target: int = DuelMem.zone(result & 1, m.u8(e + 13))
				if result != p and (m.u32(target) & 0xfff) != 0 and (m.u8(target + 6) & 2) != 0:
					return f54e730(p, (((descriptor >> 4) & 0xff) << 8 | (descriptor & 0xff)) & 0x3f01, m.u16(e + 12)) & 0xffff0000
				m.set_u8(e + 4, m.u8(e + 4) | 8)
	return result & 0xffff0000

func f55bf00(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		if m.u8(0xa15fe0) == 0x7f:
			f54e680(1 - (m.u8(e + 2) & 1), m.u16(0xa13428), 1, 1)
			return 100
		if m.u8(0xa15fe0) == 0x80:
			f53e760(m.u8(e + 2) & 1, 6, 0, 0)
			return 0x7f
	return 0

func f55bf70(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		if m.u8(0xa15fe0) == 0x7f:
			f53e830(1 - (m.u8(e + 2) & 1), 1, 0, 1)
			return 0x7e
		if m.u8(0xa15fe0) == 0x80:
			f53e8b0(1 - (m.u8(e + 2) & 1), 1, 1)
			return 0x7f
	return 0

func f55bfe0(e: int) -> int:
	var result: int = e
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 1:
		result = m.u8(e + 13)
		if (m.u8(DuelMem.zone(m.u8(e + 12) & 1, result) + 6) & 2) != 0:
			result = f54e640(m.u8(e + 12), result, 0)
	return result & 0xffff0000

func f55c030(e: int, out: int) -> int:
	var result: int = e
	if (m.u8(e + 4) & 4) == 0 and (m.u8(e + 10) & 7) == 1:
		var location: int = m.u16(e + 12)
		result = 0
		if (m.u32(DuelMem.zone(location & 1, location >> 8)) & 0xfff) != 0:
			m.set_u16(out + 12, location)
	return result & 0xffff0000

func f55c180(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var p: int = m.u8(e + 2) & 1
		if m.u8(0xa15fe0) == 0x7f:
			f54d900(1 - p, m.u16(0xa13428), 1)
			var entry: int = f5419b0(1 - p, 0xb, m.u16(0xa13428))
			issue((m.u32(entry) >> 12) << 15 | 0x60, 1, 0, 0)
			return 100
		if m.u8(0xa15fe0) == 0x80:
			f53e760(p, 6, 0, 0)
			return 0x7f
	return 0

func f55c220(e: int) -> int:
	var result: int = e
	if (m.u8(e + 4) & 4) == 0:
		var p: int = m.u8(e + 2) & 1
		for side in range(2):
			var target: int = 1 - p if side == 0 else p
			result = p if side == 0 else e
			for z in range(5, 11):
				if (m.u32(DuelMem.zone(target, z)) & 0xfff) != 0:
					result = f54e420(target, z, 9)
	return result & 0xffff0000

func f55c2a0(e: int, argument: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		100:
			issue(m.u16(e + 2) << 15 | 0x60, 1, 0, 0)
			return 99
		0x7b:
			f54f4c0(p, 4, 0)
			return 100
		0x7c:
			f54dc60(p, f401a70(m.u16(0xa13428)))
			return 0x7b
		0x7d:
			var buffer: int = m.local(10)
			for i in range(5):
				m.set_u16(buffer + i * 2, m.u16(DuelMem.pl(p) + 0x7b4 + i * 4) & 0xfff)
			f53e7c0(1 - p, 0xc, buffer, 5)
			return 0x7c
		0x7e:
			f542a20(p)
			return 0x7d
		0x7f:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7e
		0x80:
			if invoke_original(0x553ac0, [e, argument, 0]) != 0:
				f5417e0(0x2b)
				return 0x7f
	return 0

func f55c4a0(e: int) -> int:
	var result: int = e
	if (m.u8(e + 4) & 4) == 0:
		result = f53aa70((0x8000 if (m.u8(e + 2) & 1) != 1 else 0) | 0x44, 0, 0, 0)
	return result & 0xffff0000

func f55c610(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7d:
			if f57a060(1) != 0:
				var index: int = m.u16(0xa11fb8 + p * 0xd54 + m.u32(0xa161ac) * 4) & 0xfff
				if ctype(index) > 0x14 and f53b880(index) != 2 and f579890() != 0:
					var slot: int = f543570(p)
					issue(m.u16(e + 2) << 15 | 0xc5, f401a70(index), (slot & 0xf) | (m.u8(0xa161ac) << 4), 0)
					return 100
			return 0x7f if (m.u32(0xa114a8) & 0x102) != 0 else 0x7d
		0x7e:
			var answer: int = m.u16(0xa16178)
			if answer != 0:
				f5417e0(0x2e)
				return 0x7d
		0x7f:
			if m.u8(DuelMem.pl(p) + 2) != 0 and (f544eb0(p) != -1 or f544fb0(p) != -1) and f543570(p) != -1:
				f5417e0(0x2d)
				f540d60(1, 0)
				return 0x7e
		0x80:
			if (m.u8(e + 10) & 7) == 1 and (m.u32(DuelMem.zone(m.u8(e + 12) & 1, m.u8(e + 13))) & 0xfff) != 0:
				f54e250(m.u8(e + 12), m.u8(e + 13), 1)
				return 0x7f
	return 0

func f55c800(e: int) -> int:
	if (m.u16(e + 4) & 0xc) != 0 or (m.u8(e + 10) & 7) != 2:
		m.set_u16(e + 4, m.u16(e + 4) | 8)
		return 0
	var p: int = m.u16(e + 2) & 1
	var location: int = ((m.u16(e + 2) >> 4) & 0x3f) << 8 | p
	if m.u8(0xa15fe0) == 0x7f:
		var id: int = f401a70(m.u16(e)) & 0xffff
		var target: int = ((m.u8(0xa15be0) >> 1) & 0x1f) << 8 | p
		if id == 0x447:
			f54c860(p, location, target, 2)
		elif id == 0x488:
			f54e730(p, location, target)
		return 100
	if m.u8(0xa15fe0) == 0x80 and (m.u32(DuelMem.zone(p, location >> 8)) & 0xfff) != 0:
		var buffer: int = m.local(4)
		m.set_u32(buffer, m.u32(e + 12))
		if f5449b0(p, buffer) != 0:
			issue(m.u16(e + 2) << 15 | 0xd3, m.u16(e + 12), m.u16(e + 14), 0)
			f57cb60(p, buffer, 1, 0, 0x20, 0xe, p)
			m.set_u16(0xa15fe0, m.u8(0xa15fe0))
			for z in range(5):
				var card: int = DuelMem.zone(p, z)
				if (m.u16(card) & 0xfff) == m.u16(e + 12) and (m.u16(card + 6) & 0x4000) != 0:
					m.set_u8(0xa15fe1, m.u8(0xa15fe1) + 1)
			return 0x7f
	return 0

func f55ca80(e: int) -> int:
	var result: int = e
	if (m.u8(e + 4) & 4) == 0:
		result = f53aa70(m.s16(e + 2) << 15 | 0x45, 0, 0, 0)
	return result & 0xffff0000

func f55d3b0(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		issue(m.u16(e + 2) << 15 | 0x94, (m.u16(e + 2) >> 4) & 0x3f, 0, 0)
	return 0

func f55cfe0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0:
		return 0
	var p: int = m.u8(e + 2) & 1
	match m.u8(0xa15fe0):
		0x7b:
			issue(m.u16(e + 2) << 15 | 0x60, 0, 0, 0)
			return 100
		0x7c:
			f57cb60(p, f4073b0(), 1, 0, 0, 0xd, 0)
			return 0x7b
		0x7d:
			var entry: int = f4073b0()
			issue(m.u16(e + 2) << 15 | 0x65, m.u16(entry), m.u16(entry + 2), 0)
			return 0x7c
		0x7e:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7d
		0x7f:
			var answer: int = m.u16(0xa16178)
			if answer > 0:
				f5417e0(0x30)
				return 0x7e
		0x80:
			if f543330(p) != 0 and f56e660(p) != 0:
				if f56ba50(p, f401a70(m.u16(e)), 0) == 0:
					if p == 0:
						f5417e0(0x15)
					return 1
				if p == 0:
					f5417e0(0x2f)
					f540d60(1, 0)
					return 0x7f
				if f57d330(m.u16(e)) >= 0:
					f4073a0(m.u16(0xa14f02))
					return 0x7d
	return 0





