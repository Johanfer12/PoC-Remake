class_name JoeyPortW
extends JoeyPortV
## Cadena Joey: formato nativo de entradas y maquina de activacion/resolucion.

func _jw_clear_window() -> void:
	m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffd)

func _jw_end_window() -> void:
	_jw_clear_window()
	m.set_u8(0xa57809, 0)

func f59fd30() -> int:
	f5ad960((m.u16(0xa5780a) >> 8) & 1, m.u8(0xa5780c))
	_jw_clear_window()
	return 0

func f59fd60(active: int, chain: int, effect: int) -> int:
	var step := m.u8(0xa57809)
	if step < 2:
		if step == 0:
			m.set_u8(0xa5780d, f5796c0((m.u16(0xa5780a) >> 8) & 1, m.u8(0xa5780c), active))
		m.set_u8(0xa57809, m.u8(0xa57809) + 1)
		return 0
	if active != 0:
		var entry := (((m.u16(0xa5780a) >> 8) << 23) | (m.u32(0xa5780c) & 0x1f00)) << 8 | m.u16(0xa57802)
		if chain != 0:
			f5ba6b0(entry, m.u8(0xa5780e), effect, 1)
		elif effect != 0:
			f5ba4d0(entry, m.u8(0xa5780e), 1)
		else:
			f5ba860(entry, m.u8(0xa5780e))
	_jw_clear_window()
	return 0

func f59ff00(kind: int) -> int:
	if kind & 0xffff > 4 and kind & 0xffff < 7:
		f575210((m.u16(0xa5780a) >> 8) & 1, m.u8(0xa5780c), 0, 0, 1)
	_jw_clear_window()
	return 0

func f59ff50(a: int, b: int, c: int) -> int:
	var entry := f59ff90(a, b, c)
	if entry != 0:
		f5ba490(entry, 0, 0)
	_jw_clear_window()
	return 0

func f59ff90(_unused: int, p: int, kind: int) -> int:
	for i in range(_s32(m.u32(0x5efa64))):
		var at := 0x5efa44 + i * 6
		if kind == m.u16(at + 2):
			var entry := (f402460(m.u16(at)) & 0xffff) | (p << 31) | 0x5f0000
			if f57ee80(entry, 0, 0) != 0:
				return entry & 0xffffffff
	return 0

func f5a0010(p: int, kind: int) -> int:
	match kind:
		0xe, 0xf: return 0x1000
		0xd:
			if f547ce0() == 0:
				return 0
		0xc: pass
		_: return 0
	if p == (~m.u8(JoeyMem.MODE)) & 1 and f547ce0() == 0:
		return 0
	return 0x1000

func f5a0070(a: int, b: int, c: int) -> int:
	return 8 if f59ff90(a, b, c) != 0 else 0

func f5b8c00() -> int:
	if m.u16(0xa57804) & 4 == 0:
		return 0
	f5b8c60()
	if m.u16(0xa57804) & 2 == 0:
		m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffb)
		if m.u8(JoeyMem.TURN) & 0xe == 4 and m.u8(0xa57804) & 0x78 != 0x60:
			f579930(m.u8(JoeyMem.TURN) & 1, 0x13, 1)
	return 1

func f5b8c60() -> int:
	var p := (m.u16(0xa5780a) >> 8) & 1
	var kind := m.u16(0xa5780a) >> 9
	var card := m.u16(0xa57802)
	var z := m.u8(0xa5780c)
	var arg := m.u8(0xa5780e)
	match (m.u16(0xa57804) >> 3) & 15:
		0:
			f59df40(1, 0, 1)
			return 0
		1:
			if kind == 0:
				f59fd30()
				return 0
		2:
			_jw_end_window()
			m.set_u16(0xa57840, (m.u16(0xa57840) & 0xf8ff) | ((z & 7) << 8))
			m.set_u32(0xa577fc, (m.u32(0xa577fc) & 0xffffff02) | 2)
			return 0
		3:
			match kind:
				0:
					f5ba860(((((m.u16(0xa5780a) >> 8) ^ m.u16(JoeyMem.TURN)) & 1) << 24) | ((m.u16(0xa5780a) >> 8) << 31) | ((z & 31) << 16) | card | 0x200000, arg)
				5, 10:
					var slot := z + kind
					var face := int(m.u8(JoeyMem.zone(p, slot) + 6) & 2 != 0)
					if face == 0:
						f5b9170(_jq_op(p, 0x91), slot, 0, 0)
					f5ba860((((((int(p != m.u8(JoeyMem.TURN) & 1) | (p << 7)) << 3) | face) << 5) | (slot & 31)) << 16 | card, arg)
				11:
					if f4025d0(card) & 0xffff > 20:
						f59fd60(1, 0, 0)
						return 0
					var id := s16(f4022e0(card))
					if id == 0x47:
						f579930(p, 0x11, 1)
						f59fd60(1, 0, 0)
						return 0
					if id == 0x1a8:
						m.set_u8(0xa55c95, m.u8(0xa55c95) | 0x80)
						f59d040(p)
						f575a10(p, z)
						f5ba860((p << 31) | card | 0x4e0000, arg)
				13, 14: f59ff50(0, p, kind)
		4:
			if kind == 11:
				if f4025d0(card) & 0xffff > 20:
					f59fd60(0, 0, 0)
				else:
					f59df40(0, 0, 1)
				return 0
		5, 6:
			if kind == 0:
				f59ff00((m.u16(0xa57804) >> 3) & 15)
				return 0
		7:
			_jw_end_window()
			m.set_u16(0xa577fe, m.u16(0xa577fe) + 0x100)
			return 0
		8:
			if m.u8(0xa57809) == 0:
				f5bf800(6)
				f5bf9a0(1, 0)
				m.set_u8(0xa57809, m.u8(0xa57809) + 1)
				return 0
			if m.u8(0xa57809) != 1:
				return 0
			if m.u16(0xa558b4) != 0:
				f5b9170((m.u16(0xa5780a) & 0xff00) << 7 | 0x40, 1, 0, 0)
		10:
			f59df40(1, 1, 0)
			return 0
		11:
			f59df40(0, 1, 0)
			return 0
		12:
			f41cea0(p, kind)
			f40c940(p, kind - 11, 0xffffffff, kind)
			f44ef40(1)
	_jw_end_window()
	return 0

func f5ba230(at: int, top: int) -> int:
	var count := m.u16(at + 0x140)
	if top == 0:
		for i in range(count):
			var ref := m.u16(at + 2 + i * 20)
			f5b9170((ref << 15) | 10, (ref >> 1) & 31, i + 1, 0)
	else:
		var ref := m.u16(at - 0x12 + count * 20)
		f5b9170((ref << 15) | 11, (ref >> 1) & 31, count, 0)
	return 0

func f5ba2c0() -> int:
	return int(f41f570() == 0)

func f5ba2d0(at: int) -> int:
	if m.u8(JoeyMem.TURN) & 0x10 == 0:
		return 0
	var ref := m.u16(at + 2)
	return ((ref >> 14) ^ ref ^ m.u16(JoeyMem.MODE)) & 1

func _jw_mark(at: int) -> void:
	var ref := m.u16(at + 2)
	if ref & 0x3e < 0x15 and ref & 0x3000 == 0:
		f579990(ref & 1, (ref >> 1) & 31, 1, 1)

func f5ba310(chain: int, entry: int, arg: int, extra: int) -> int:
	entry &= 0xffffffff
	if entry & 0xffff == 0:
		return 0
	if m.u8(JoeyMem.TURN) & 0x10 and ((~m.u32(JoeyMem.MODE) ^ m.u8(JoeyMem.TURN)) & 1) == 0:
		var packet := m.local(12)
		m.set_u16(packet, chain)
		m.set_u32(packet + 2, entry)
		m.set_u32(packet + 6, extra)
		m.set_u16(packet + 10, arg)
		f5bd090(0xf072, packet, 12)
		return 0
	var counter := 0xa55c84 if chain == 0 else 0xa55c80
	var at := (0xa558c0 if chain == 0 else 0xa55b40) + m.u16(counter) * 20
	f5bddf0(at, 20)
	m.set_u16(at, entry)
	var ref := (((((entry >> 24) & 1) << 2) | ((entry >> 21) & 3)) << 6 | ((entry >> 25) & 63)) << 5 | ((entry >> 16) & 31)
	m.set_u16(at + 2, (ref << 1) | ((entry >> 31) & 1))
	m.set_u16(at + 4, (arg & 255) << 5)
	m.set_u32(at + 16, extra)
	m.set_u16(counter, m.u16(counter) + 1)
	_jw_mark(at)
	return 0

func f5ba490(entry: int, arg: int, extra: int) -> int:
	entry &= 0xffffffff
	if f57ee80(entry, arg, extra) != 0:
		f5ba310(0, entry, arg, extra)
		return 1
	return 0

func _jw_candidate(entry: int, arg: int) -> int:
	var at := m.local(20)
	m.set_u16(at, entry)
	m.set_u16(at + 2, ((((((entry >> 24) & 1) << 2) | ((entry >> 21) & 3)) << 11) | ((entry >> 16) & 31)) << 1 | ((entry >> 31) & 1))
	m.set_u16(at + 4, (arg & 255) << 5)
	return at

func _jw_entry(at: int, targets: bool) -> int:
	var ref := m.u16(at + 2)
	var bits := (((ref & 0xfc0) | (ref << 12)) << 4) | (ref & 0x3e) if targets else (ref & 0x3e) | (m.u32(at + 2) << 16)
	return (((((bits << 5) | (ref & 0x4000)) << 1) | (ref & 0x3000)) << 9 | m.u16(at)) & 0xffffffff

func _jw_choose(at: int, effect: int, mode: int) -> int:
	var count := (m.u32(0xa55c94) >> 8) & 127
	if count == 0:
		return int(f59dd90(at, effect, mode) != 0)
	for i in range(count):
		m.set_u16(at + 2, ((m.u8(0xa55c96 + i) & 63) << 6) | (m.u16(at + 2) & 0xf03f))
		m.set_u32(at + 16, m.u32(0xa55ca8 + i * 4))
		if f59dd90(at, effect, mode) != 0:
			return i + 2
	return 0

func f5ba4d0(entry: int, arg: int, mode: int) -> int:
	var at := _jw_candidate(entry, arg)
	var chosen := _jw_choose(at, 0, mode)
	if chosen != 0:
		f5ba310(0, _jw_entry(at, chosen > 1), arg, m.u32(0xa55ca8 + (chosen - 2) * 4) if chosen > 1 else 0)
	return 0

func f5ba6b0(entry: int, arg: int, effect: int, mode: int) -> int:
	var at := _jw_candidate(entry, arg)
	var chosen := _jw_choose(at, effect, mode)
	if chosen != 0:
		f5ba310(1, _jw_entry(at, chosen > 1), arg, m.u32(0xa55ca8 + (chosen - 2) * 4) if chosen > 1 else 0)
	return 0

func f5ba860(entry: int, arg: int) -> int:
	return f5ba310(0, entry, arg, 0)

func f5ba880(at: int, effect: int, mode: int) -> int:
	if _jw_choose(at, effect, mode) != 0:
		f5bd090(0xf056 if m.u8(0xa55cea) & 0x80 else 0xf053, at, 20)
	return 0

func f5ba960(chain: int, source: int) -> int:
	var counter := 0xa55c84 if chain == 0 else 0xa55c80
	var at := (0xa558c0 if chain == 0 else 0xa55b40) + m.u16(counter) * 20
	f5bde10(at, source, 20)
	m.set_u16(at + 2, m.u16(at + 2) & 0x7fff)
	m.set_u16(at + 4, m.u16(at + 4) & 0xffe0)
	m.set_u16(counter, m.u16(counter) + 1)
	_jw_mark(at)
	return 0

func f5baa00(effect: int, p: int, kind: int, z: int) -> int:
	match kind:
		0, 5: return 8 if f57e2b0(effect, m.u16(JoeyMem.MODE) & 1, p, kind + z) != 0 else 0
		11: return 8 if f57e3c0(effect, p, z) != 0 else 0
		12, 13, 14, 15: return f5a0010(p, kind)
	return 0

func f5bbda0(at: int) -> int:
	if m.u16(at + 2) & 0x3000 != 0x2000:
		if m.u8(at + 4) & 8:
			return 1
		var index := m.u16(at)
		if f4025d0(index) & 0xffff > 20:
			var kind := f402700(index) & 0xffff
			if kind < 2 or kind > 4:
				return int(f4022e0(index) & 0xffff not in [0x28a, 0x47, 0x15b, 0x291, 0x4ce])
	return 0

func f5bbe40() -> int:
	if m.u32(0xa55c84) & 0x10000:
		return f5bafd0()
	if m.u8(0xa55c88) & 1:
		return f5bb720()
	if m.u16(0xa55c84) == 0:
		if m.u32(0xa55ce8) & 0x2000 == 0:
			return 0
		if f597e90() != 0:
			m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xffffdfff)
		return 1
	m.set_u16(0xa55c80, 0)
	var moved := 0
	while moved < m.u16(0xa55c84):
		f5bde10(0xa55b40 + moved * 20, 0xa558c0 + moved * 20, 20)
		m.set_u16(0xa55c80, m.u16(0xa55c80) + 1)
		if m.u16(0xa55c80) > 15:
			break
		moved += 1
	var left := m.u16(0xa55c84) - moved
	for i in range(left):
		f5bde10(0xa558c0 + i * 20, 0xa558c0 + (moved + i) * 20, 20)
	m.set_u32(0xa55c84, (left & 0xffff) | (int(m.u16(0xa55c80) != 0) << 16))
	return 1

func _jw_step(at: int, mask: int, amount: int = 1) -> void:
	var value := m.u16(at)
	var unit := mask & -mask
	m.set_u16(at, (value & ~mask) | ((value + amount * unit) & mask))

func _jw_state(at: int, mask: int, value: int) -> void:
	m.set_u32(at, (m.u32(at) & ~mask) | value)

func f5baab0(at: int, p: int) -> int:
	var phase := m.u32(0xa55ce8) & 31
	if phase == 0:
		_jw_step(0xa55ce8, 31)
		phase = 1
	match phase:
		1:
			if not _jv_ai(p):
				if m.u8(JoeyMem.TURN) & 0x10 and p == (~m.u8(JoeyMem.MODE)) & 1:
					_jw_state(0xa55ce8, 0xb, 0x14)
					return 0
				var text := m.local(256)
				f5bdf40(text, 7 if f4025d0(m.u16(at)) & 0xffff < 21 else 8, f402290(m.u16(at)))
				f5bf800(text)
				f5bf9a0(1, 0)
				_jw_step(0xa55ce8, 31)
				return 0
			if f5b3b90(p, at) != 0:
				_jw_state(0xa55ce8, 0x14, 11)
				return 0
		2:
			if m.u16(0xa558b4) != 0:
				m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffc)
				_jw_state(0xa55ce8, 0x15, 10)
				return 0
		10:
			if f5beed0() == 0 or m.u32(0xa54e54) & 2:
				m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffe)
				m.set_u16(0xa57808, m.u16(0xa57808) & 0xff00)
				f5bf4b0()
				if m.u32(0xa54e54) & 0x102:
					_jw_state(0xa55ce8, 30, 1)
				return 0
			var changed := f5b88d0()
			var owner := m.u32(0xa55044)
			var kind := m.u32(0xa55048)
			var z := m.u32(0xa5504c)
			if changed != 0 or m.u16(0xa57804) & 1 == 0:
				var choose := kind in [12, 13, 14, 15]
				if kind in [0, 5, 10, 11]:
					choose = s16(f5beeb0()) != 0 and f5beed0() != 0
				if choose:
					m.set_u16(0xa57808, m.u16(0xa57808) & 0xff00)
					m.set_u16(0xa57806, f5baa00(at, owner, kind, z))
					m.set_u16(0xa57804, (m.u16(0xa57804) & 0xfffe) | int(m.u16(0xa57806) != 0))
				f5b88a0()
				if m.u16(0xa57804) & 1 == 0:
					m.set_u16(0xa57808, m.u16(0xa57808) & 0xff00)
					f5bf4b0()
					if m.u16(0xa57804) & 2:
						_jw_step(0xa55ce8, 31)
					return 0
			f5b8910()
			if m.u16(0xa57804) & 2:
				_jw_step(0xa55ce8, 31)
			return 0
		11:
			var p1 := (m.u16(0xa5780a) >> 8) & 1
			var kind := m.u16(0xa5780a) >> 9
			if m.u8(0xa57804) & 0x78 == 0x60:
				f41cea0(p1, kind)
				f40c940(p1, kind - 11, 0xffffffff, kind)
				_jw_clear_window()
				_jw_step(0xa55ce8, 31, -1)
				return 0
			if kind == 0 or kind == 5:
				_jw_clear_window()
				var z := m.u8(0xa5780c) + kind
				var face := int(m.u8(JoeyMem.zone(p1, z) + 6) & 2 != 0)
				if face == 0:
					f5b9170((m.u16(0xa5780a) & 0xff01) << 7 | 0x91, z, 0, 0)
				f5ba6b0(((z & 31) << 16) | ((((m.u16(0xa5780a) >> 8) << 10) | face) << 21) | m.u16(0xa57802), m.u8(0xa5780e), at, 0)
			elif kind == 11:
				f59fd60(1, 1, at)
				if m.u16(0xa57804) & 2:
					return 0
			_jw_state(0xa55ce8, 0x2000, 0x4000)
		20:
			f5bd090(0xf054, at, 20)
			_jw_state(0xa55ce8, 0x4000, 0)
			_jw_state(0xa58260, 0x400, 0)
			_jw_step(0xa55ce8, 31)
			return 0
		21: return (m.u32(0xa58260) >> 10) & 1
	return 1

func _jw_filter_step(delta: int = 1) -> void:
	_jw_step(0xa55c86, 0xfe, delta)

func _jw_filter_finish() -> int:
	m.set_u32(0xa55c94, m.u32(0xa55c94) & 0xffff00ff)
	m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xffffdfff)
	m.set_u16(0xa55c86, m.u16(0xa55c86) & 0xfffe)
	m.set_u16(0xa55c88, 1)
	m.set_u32(0xa55c80, m.u16(0xa55c80) * 0x10001)
	return 1

func _jw_pair_packet(at: int, prev: int, opcode: int, prefix: bool = false) -> void:
	var packet := m.local(44)
	var start := int(prefix) * 2
	if prefix:
		m.set_u16(packet, m.u16(0xa55c80))
	f5bde10(packet + start, at, 20)
	if prev != 0:
		f5bde10(packet + start + 20, prev, 20)
	f5bd090(opcode, packet, start + (40 if prev != 0 else 20))

func f5bafd0() -> int:
	var index := m.u8(0xa55c87)
	var at := 0xa55b40 + index * 20
	var prev := at - 20 if index != 0 else 0
	var last := 0xa55b2c + m.u16(0xa55c80) * 20
	if m.u16(0xa55c80) == 0:
		m.set_u16(0xa55c88, m.u16(0xa55c88) & 0xfffe)
		m.set_u32(0xa55c94, m.u32(0xa55c94) & 0xffff7fff)
		m.set_u16(0xa55c86, m.u16(0xa55c86) & 0xfffe)
		return 1
	var phase := (m.u16(0xa55c86) & 0xfe) >> 1
	if phase == 0:
		m.set_u32(0xa55c94, m.u32(0xa55c94) | 0x8000)
		m.set_u16(0xa55c86, m.u16(0xa55c86) & 0xff)
		if f5bc050() != 0:
			return 1
		if m.u8(JoeyMem.TURN) & 0x10:
			var count := (m.u32(0xa55c94) >> 8) & 127
			var packet := m.local(1 + count * 5)
			m.set_u8(packet, count)
			for i in range(count):
				m.set_u8(packet + 1 + i * 5, m.u8(0xa55c96 + i))
				m.set_u32(packet + 2 + i * 5, m.u32(0xa55ca8 + i * 4))
			f5bd090(0xf059, packet, 1 + count * 5)
		_jw_filter_step()
		phase = 1
	if phase == 1:
		var ref := m.u16(at + 2)
		f5783c0(ref & 1, (ref >> 1) & 31, m.u16(at), (m.u16(at + 4) & 0x1fe0) >> 5)
		m.set_u16(0xa55c8c, m.u16(0xa55c8c) & 0xff)
		m.set_u32(0xa58260, m.u32(0xa58260) & 0xfffaffff)
		m.set_u16(0xa55c8e, m.u16(0xa55c8e) & 0xff00)
		_jw_filter_step()
		return 1
	if phase in [2, 4]:
		var effect := _s32(f59dbe0(m.u16(at)))
		var flags := m.u16(at + (2 if phase == 2 else 4))
		var mask := 0x8000 if phase == 2 else 1
		if flags & mask or effect == -1 or m.u32(0x5ed0b8 + effect * 24 + (0 if phase == 2 else 4)) == 0:
			m.set_u16(at + (2 if phase == 2 else 4), flags | mask)
			_jw_filter_step(2)
			return 1
		if f5ba2d0(at) != 0:
			_jw_pair_packet(at, prev, 0xf091 if phase == 2 else 0xf081)
		_jw_filter_step()
		m.set_u16(0xa55c8e, m.u16(0xa55c8e) & 0xff)
		phase += 1
	if phase in [3, 5]:
		var mask := 0x40000 if phase == 3 else 0x10000
		if f5ba2d0(at) == 0:
			var result := _s32(f59de30(at, prev) if phase == 3 else f59de70(at, prev))
			if result != 0:
				var off := 2 if phase == 3 else 4
				var flag := 0x8000 if phase == 3 else 1
				m.set_u16(at + off, (m.u16(at + off) & ~flag) | (flag if result > 0 else 0))
				m.set_u32(0xa58260, m.u32(0xa58260) | mask)
		if m.u32(0xa58260) & mask == 0:
			return 1
		var rejected := m.u16(at + 2) & 0x8000 if phase == 3 else m.u16(at + 4) & 1
		if rejected == 0:
			_jw_state(0xa55c86, 0xf2, 12)
		else:
			_jw_filter_step()
		return 1
	if phase == 6:
		var ref := m.u16(at + 2)
		if ref & 0x8000 == 0 or m.u8(at + 4) & 1 == 0:
			if ref & 0x3e < 21:
				f579990(ref & 1, (ref >> 1) & 31, 1, 0)
			m.set_u16(0xa55c80, m.u16(0xa55c80) - 1)
			if m.u16(0xa55c80) == 0 and m.u32(0xa55c94) & 0x7f00:
				_jw_state(0xa55ce8, 0x4000, 0x2000)
			for i in range(index, m.u16(0xa55c80)):
				f5bde10(0xa55b40 + i * 20, 0xa55b40 + (i + 1) * 20, 20)
		else:
			m.set_u8(0xa55c87, m.u8(0xa55c87) + 1)
		if m.u8(0xa55c87) < m.u16(0xa55c80):
			_jw_state(0xa55c86, 0xfc, 2)
			return 1
		_jw_filter_step()
		phase = 7
	match phase:
		7:
			if f5ba060() != 0 or f5bc050() != 0:
				return 1
			if m.u16(0xa55c80) < 2:
				_jw_state(0xa55c86, 0xe8, 22)
				return 1
		8: f5ba230(0xa55b40, 0)
		9:
			if f5ba2c0() != 0:
				_jw_filter_step()
			return 1
		10:
			_jw_filter_step()
			phase = 11
		12, 14:
			var owner := m.u8(last + 2) & 1
			if f5baab0(last, 1 - owner if phase == 12 else owner) == 0:
				return 1
			if m.u32(0xa55ce8) & 0x4000:
				_jw_state(0xa55c86, 0xfc, 2)
				return 1
		13:
			if f57ef90(last, m.u8(last + 2) & 1) == 0:
				_jw_filter_step()
			else:
				m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xffffbfe0)
		_:
			if phase != 11:
				return _jw_filter_finish()
	if phase == 11:
		if m.u16(0xa55c80) > 15:
			return _jw_filter_finish()
		if f57ef90(last, 1 - (m.u8(last + 2) & 1)) == 0:
			_jw_filter_step()
		else:
			m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xffffbfe0)
	_jw_filter_step()
	return 1

func _jw_resolve_step() -> void:
	_jw_step(0xa55c88, 0xfe)

func _jw_resolve_end() -> int:
	_jw_state(0xa55c88, 0x36, 200)
	return 1

func f5bb720() -> int:
	var n := m.u16(0xa55c80)
	var at := 0xa55b2c + n * 20
	var prev := at - 20 if n >= 2 else 0
	var phase := (m.u32(0xa55c88) >> 1) & 127
	match phase:
		0:
			m.set_u16(0xa55c94, m.u16(0xa55c94) & 0x80ff)
			m.set_u16(0xa55ce8, m.u16(0xa55ce8) & 0xdfff)
			if n < 2:
				_jw_state(0xa55c88, 0xf6, 8)
				return 1
		1: f5ba230(0xa55b40, 1)
		2:
			if f5ba2c0() != 0:
				_jw_resolve_step()
			return 1
		3: pass
		4:
			var ref := m.u16(at + 2)
			var card := m.u16(at)
			var flags := m.u16(at + 4)
			if f402690(card) == 0:
				if ref & 0x3000 != 0x2000 and (flags & 4 or f598c40(ref & 1, (ref >> 1) & 31, card) != 0):
					f5b9170(ref << 15 | 0xb1, (ref >> 1) & 31, 1, 0)
					m.set_u16(at + 4, m.u16(at + 4) | 4)
			elif f567620(card, 0) != 0 and (f5699c0(0x5fa) != 0 or flags & 4):
				f5b9170(ref << 15 | 0xb1, (ref >> 1) & 31, 1, 0)
				return _jw_resolve_end()
			ref = m.u16(at + 2)
			if ref & 0x3000 != 0x2000 and m.u8(at + 4) & 2:
				f5778b0(0xa55b40 + m.u16(0xa55c80) * 20, ref & 1, (ref >> 1) & 31)
				return _jw_resolve_end()
			m.set_u32(0xa55c88, 0x800000 | m.u16(0xa55c88))
		5:
			var effect := _s32(f59dbe0(m.u16(at)))
			if effect < 0 or m.u32(0x5ed0ac + effect * 24) == 0:
				m.set_u32(0xa58260, m.u32(0xa58260) | 0x100000)
				_jw_state(0xa55c88, 0xf0, 14)
				return 1
			if f5ba2d0(at) != 0:
				_jw_pair_packet(at, prev, 0xf071, true)
			m.set_u32(0xa58260, m.u32(0xa58260) & 0xffefffff)
		6:
			if f5ba2d0(at) != 0:
				_jw_resolve_step()
				return 1
			m.set_u8(0xa55c8a, f59deb0(at, prev))
			if m.u8(0xa55c8a) != 0:
				return 1
			m.set_u32(0xa58260, m.u32(0xa58260) | 0x100000)
		7:
			if m.u32(0xa58260) & 0x100000:
				var ref := m.u16(at + 2)
				if f5bbda0(at) != 0:
					f579990(ref & 1, (ref >> 1) & 31, 2, 1)
				if m.u16(at + 4) & 2 == 0 and ref & 0x3e < 21 and ref & 0x3000 == 0:
					if f570c70(ref & 1, (m.u16(at + 4) & 0x1fe0) >> 5) != 0:
						f578400(m.u8(at + 2) & 1, f402460(0x443))
						f5784e0(m.u8(at + 2) & 1, 2000)
				return _jw_resolve_end()
			return 1
		100:
			var ref := m.u16(at + 2)
			if ref & 0x3e < 21:
				var z := (ref >> 1) & 31
				if m.u8(JoeyMem.zone(ref & 1, z) + 0x8c) & 2:
					f579990(ref & 1, z, 1, 0)
					return 1
			if f5ba060() != 0:
				return 1
		101:
			f5bc050()
			m.set_u16(0xa55c80, m.u16(0xa55c80) - 1)
			if m.u16(0xa55c80) != 0:
				m.set_u16(0xa55c94, m.u16(0xa55c94) & 0x80ff)
				m.set_u16(0xa55ce8, m.u16(0xa55ce8) & 0xdfff)
				_jw_state(0xa55c88, 0xfc, 2)
				return 1
			_jw_resolve_step()
			phase = 102
		102: pass
		103:
			if f5ba060() == 0:
				m.set_u16(0xa55c94, m.u16(0xa55c94) & 0x7fff)
				_jw_resolve_step()
			return 1
		_:
			m.set_u32(0xa55c88, m.u32(0xa55c88) & 0xfffffffe)
			return 1
	if phase == 102:
		m.set_u16(0xa55c94, m.u16(0xa55c94) | 0x8000)
		for i in range((m.u32(0xa55c80) >> 16) - 1, -1, -1):
			var entry := 0xa55b40 + i * 20
			var ref := m.u16(entry + 2)
			if ref & 0x3e < 21:
				var obj := JoeyMem.zone(ref & 1, (ref >> 1) & 31)
				if m.u32(obj) & 0xfff and m.u8(obj + 0x8c) & 4:
					f577c60(entry, ref & 1, (ref >> 1) & 31)
	_jw_resolve_step()
	return 1

## Productores de peticiones (bloque NET por direccion; son trabajo local del motor).
func f5bcc70(p: int, kind: int, arg: int, extra: int) -> int:
	m.set_u16(0xa57814, extra)
	m.set_u32(0xa57810, ((arg & 0xffff) << 16) | (((kind & 63) << 1 | (p & 1)) << 2) | (m.u16(0xa57810) & 0xfe03))
	return f5bccc0()

func f5bccc0() -> int:
	var old := m.u32(0xa57810)
	var flags := old & 0x1fc
	m.set_u32(0xa57810, (old & 0xffff0000) | flags | 2)
	if ((~m.u32(JoeyMem.MODE)) & 1) == ((flags >> 2) & 1) and m.u8(JoeyMem.TURN) & 0x10 and old & 0x1f8 != 0x18:
		var packet := m.local(20)
		m.set_u16(packet, (flags >> 3) & 63)
		f5bde10(packet + 2, 0xa57812, 16)
		f5bd090(0xf0a1, packet, 18)
		m.set_u32(0xa58260, m.u32(0xa58260) & 0xffffbfff)
		m.set_u32(0xa57810, m.u32(0xa57810) | 1)
	return 0

func f5bcd60(p: int, kind: int, source: int, count: int) -> int:
	count = mini(_s32(count), 8)
	m.set_u16(0xa57810, (((kind & 63) << 1 | (p & 1)) << 2) | (m.u16(0xa57810) & 0xfe03))
	f5bde10(0xa57812, source, count * 2)
	return f5bccc0()

func f5bcdc0(p: int, count: int, a: int, b: int) -> int:
	if count != 0:
		f5bcc70(p, 1, count, int(a != 0) | (int(b != 0) << 1))
	return 0

func f5bce00(p: int, count: int, a: int, b: int) -> int:
	return f5bcc70(p, 2, count, int(a != 0) | (int(_s32(f5699c0(0x49c)) > 0) << 2) | (int(b != 0) << 3) | 0x10)

func f5bce50(p: int, arg: int, count: int) -> int:
	var request := m.u32(0xa57810)
	if request & 2 and ((request >> 2) & 1) == p and request & 0x1f8 == 0x18:
		m.set_u16(0xa57814, m.u16(0xa57814) + count)
		return 0
	return f5bcc70(p, 3, arg, count)

func f5bcea0(p: int, count: int) -> int:
	return f5bcc70(p, 4, 0, count)

func f5bcec0(p: int) -> int:
	return f5bcc70(p, 5, 0, 0)

func f5bcee0(p: int, arg: int) -> int:
	return f5bcc70(p, 6, arg, 0)

func f5bcf00(p: int, arg: int, count: int) -> int:
	return f5bcc70(p, 8, arg, count)

func f5bcf20(p: int) -> int:
	return f5bcc70(p, 7, 0, 0)

func f5bcf40(p: int, arg: int) -> int:
	return f5bcc70(p, 13, arg, 0)

func f5bcf60(p: int, arg: int, extra: int) -> int:
	return f5bcc70(p, 13, arg, extra)

func f5bcf80(p: int, count: int, mask: int) -> int:
	return f5bcc70(p, 10, ((mask & 255) << 8) | (count & 255), 0)

func f5bcfa0(p: int, arg: int) -> int:
	return f5bcc70(p, 9, arg, 0)

func f5bcfc0(p: int, arg: int, extra: int) -> int:
	return f5bcc70(p, 12, arg, extra)

func f5bcfe0(p: int, arg: int, source: int, count: int) -> int:
	var packet := m.local(maxi(16, 2 + _s32(count) * 2))
	m.set_u16(packet, arg)
	if _s32(count) > 0:
		f5bde10(packet + 2, source, count * 2)
	return f5bcd60(p, 11, packet, count + 1)

func f5bd030(arg: int) -> int:
	return f5bcc70(m.u8(JoeyMem.TURN) & 1, 14, arg, 0)

func f5bd050(opcode: int, a: int, b: int, c: int) -> int:
	var packet := m.local(6)
	m.set_u16(packet, a)
	m.set_u16(packet + 2, b)
	m.set_u16(packet + 4, c)
	f5bd090(opcode, packet, 6)
	return 0
