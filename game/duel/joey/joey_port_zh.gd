class_name JoeyPortZH
extends JoeyPortZG
## Selector de invocación nativo Joey 59df40; estados y aritmética cotejados con ASM.

func _jh_state(value: int) -> int:
	m.set_u8(0xa57809, value)
	return 0

func _jh_next() -> int:
	return _jh_state(m.u8(0xa57809) + 1)

func _jh_done(result: int = 0) -> int:
	m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffd)
	return result

func _jh_cpu() -> bool:
	return ((m.u32(0xa54e5c) >> 1) >> (m.u8(0xa5780b) & 1)) & 1 != 0

func _jh_cancel() -> bool:
	return (m.u32(0xa54e54) & 0x102) != 0

func _jh_pick(slot: int, p: int, z: int) -> void:
	var masks := [0xeff8ffff, 0xdfc7ffff, 0xbe3fffff]
	var shifts := [16, 19, 22]
	var owner := [12, 10, 8]
	var present := [0x200, 0x80, 0x20]
	m.set_u32(0xa55080, (m.u32(0xa55080) & masks[slot]) | (((p & 1) << owner[slot] | (z & 7) | present[slot]) << shifts[slot]))

func _jh_accept(slot: int, z: int) -> int:
	f44ef40(1)
	f486ca0(m.u32(0xa55044), z)
	_jh_pick(slot, m.u32(0xa55044), m.u32(0xa5504c))
	return _jh_state(15)

func _jh_special_locked(p: int, ordinal: int, table: bool) -> bool:
	if f56a000(p):
		return false
	var locked := true
	for n in range(ordinal + 1, 3):
		var index := f402460(m.u16(0x5dd004 + n * 4) if table else n + 0x172) & 0xffff
		for z in range(5):
			if (m.u32(JoeyMem.zone(p, z)) & 0xfff) == index and f56a140(p, p, z) and f569e10(p, z):
				locked = false
				break
	return locked

func f59df40(face: int, set_card: int, announce: int) -> int:
	var state := m.u8(0xa57809)
	var p := m.u8(0xa5780b) & 1
	var hand := m.u8(0xa5780c)
	var index := m.u16(0xa57802)
	var first := m.local(256)
	var second := m.local(256)
	match state:
		0:
			m.set_u16(0xa5780a, m.u16(0xa5780a) & 0xff00)
			m.set_u32(0xa55080, m.u32(0xa55080) & 0xf1ffffff)
			var id := f4022e0(index) & 0xffff
			var special := {0x4e2: 0x5a, 0x175: 0x1e, 0x37: 0x14, 0x38: 0x14, 0x42: 0x14, 0x34d: 0x28, 0x4e9: 0x50}
			if special.has(id):
				return _jh_state(special[id])
			var kind := (m.u32(0xa57804) >> 3) & 15
			if id == 0x546 and kind in [10, 11]:
				f5adbf0(p, hand, f56a030(p), 0, face)
				return _jh_done(1)
			if id >= 0x5ea and id <= 0x5ef:
				return _jh_state(0x32)
			var level := f4026c0(index) & 0xffff
			if level <= 4:
				var dest := f56a030(p)
				if set_card:
					f5adbf0(p, hand, dest, 0, face)
				else:
					f5ad740(p, hand, dest, 0, face)
					if announce:
						f579930(p, 0x11, 1)
				if (f4022e0(m.u16(0xa57802)) & 0xffff) == 0x5f0 and ((m.u32(0xa57804) >> 3) & 15) in [10, 11]:
					if f599e30(1-p, 0x5f0, 0) and _s32(f56a000(1-p)) > 0 and f570b40(1-p):
						var z := f56a030(p)
						f5ba860((((p << 15 | (z & 255)) & 0xffffff1f | 0x20) << 16) | m.u16(0xa57802), m.u8(0xa5780e))
				return _jh_done(1)
			return _jh_state(10 if level in [5, 6] else 1)
		1:
			if not _jh_cpu():
				f5bf800(m.u32(0x5efa34))
				f5bf9a0(1, 0)
				return _jh_next()
			var a := f5aed60(p, 0xffffffff, int(set_card == 0))
			var b := f5aed60(p, a, int(set_card == 0))
			if _s32(a) != -1 and _s32(b) != -1:
				m.set_u32(0xa55080, (((((b & 1) << 1 | (a & 1)) << 9 | ((b >> 8) & 255)) & 0xffffff07 | 0xc0) << 3 | ((a >> 8) & 7)) << 16 | (m.u32(0xa55080) & 0xcfc0ffff))
				return _jh_state(15)
			return _jh_done()
		2:
			if m.u16(0xa558b4) == 0:
				return _jh_done()
			_jh_next()
			return _jh_select_tribute(3, p, set_card)
		3, 4, 5, 11:
			if state == 4:
				_jh_next()
			return _jh_select_tribute(5 if state == 4 else state, p, set_card)
		10:
			if _jh_cpu():
				var chosen := f5aed60(p, 0xffffffff, int(set_card == 0))
				if _s32(chosen) == -1:
					return _jh_done()
				_jh_pick(0, chosen & 1, (chosen >> 8) & 7)
				return _jh_state(15)
			f5bf800(m.u32(0x5efa30))
			f5bf9a0(1, 0)
			return _jh_next()
		15:
			var picks := m.u32(0xa55080)
			var dest := 0xffffffff
			for n in range(3):
				var z := (picks >> (16 + n * 3)) & 7
				if (picks & (0x2000000 << n)) and ((picks >> (28 + n)) & 1) == p and f569e10(p, z):
					dest = z
					break
			if dest == 0xffffffff:
				dest = f56a030(p)
			if _s32(dest) < 0:
				f486d20()
				return _jh_done(1)
			var tributes := ((picks >> 4) & 0x800000) + ((picks >> 10) & 0x100000) + ((picks >> 6) & 0x70000)
			tributes |= ((picks >> 17) & 0x1000) + ((picks >> 11) & 0x700) + ((picks >> 11) & 0x8000)
			tributes |= ((picks >> 24) & 0x10) + ((picks >> 16) & 7) + ((picks >> 18) & 0x80)
			if set_card:
				f5adbf0(p, hand, dest, tributes, face)
				return _jh_done(1)
			f5ad740(p, hand, dest, tributes, face)
			if announce:
				f579930(p, 0x11, 1)
			return _jh_done(1)
		0x14:
			f5bdf40(first, 0xd1, f402290(index))
			f5bdf40(second, first, f402290(f402460(0x115)))
			f5bf800(second)
			return _jh_next()
		0x15:
			if _jh_cancel():
				f44ef40(2)
				return _jh_done()
			if f5aa440(0xf000f0) == 0:
				return 0
			var effect := m.local(20)
			m.set_u16(effect, index)
			m.set_u32(effect + 2, p)
			if f579a00(effect, ((m.u32(0xa5504c) & 255) << 8) | (m.u32(0xa55044) & 255)) == 0 or f5aa480() == 0:
				return 0
			return _jh_accept(0, m.u32(0xa55048) + m.u32(0xa5504c))
		0x1e:
			f5bdf40(second, 0xd2, f402290(f402460(m.u8(0xa5780a) + 0x172)))
			f5bf800(second)
			return _jh_next()
		0x1f:
			return _jh_sequential(p, false)
		0x28:
			if not _jh_cpu():
				f5bdf40(second, 0xd3, f402290(f402460(m.u16(0x5dcff8 + m.u8(0xa5780a) * 4))))
				f5bf800(second)
			return _jh_next()
		0x29:
			return _jh_sequential(p, true)
		0x2a, 0x35:
			if state == 0x35 or f56a000(p):
				f5adbf0(p, hand, f56a030(p), 0, face)
			return _jh_done(1)
		0x32:
			var count := _s32(f59def0(index))
			var messages := {0x5ea: 0x1f7, 0x5eb: 0x213, 0x5ec: 0x216, 0x5ed: 0x215, 0x5ee: 0x217, 0x5ef: 0x218}
			var text_id: int = messages.get(f4022e0(index) & 0xffff, 0)
			m.set_u8(0xa5780a, count)
			var own := f5709d0(p, 0x60f) != 0
			if count < 2:
				f5bdf40(second, 0xd8 if own else 0xd9, text_id)
			else:
				f5bdf40(first, 0xd6 if own else 0xd7, text_id)
				f5bdfc0(second, first, count)
			if own:
				_jh_state(0x37)
			else:
				_jh_next()
			if not _jh_cpu():
				f5bf800(second)
			return 0
		0x33:
			if not _jh_cpu():
				f40c940(p, m.u8(0xa5780a) + 6, f4022e0(index), 0)
			_jh_next()
			m.set_u8(0xa5780a, 0)
			return 0
		0x34:
			var count := _s32(f59def0(index))
			m.set_u8(0xa5780a, m.u8(0xa5780a) + 1)
			if m.u8(0xa5780a) <= count:
				if _jh_cpu():
					if _s32(f5af5a0(p, index, 0)) < 0:
						return _jh_done()
				else:
					f40ccb0(m.u8(0xa5780a))
				f575fe0(p, f40cab0(), 0)
				return 0
			return _jh_next()
		0x37:
			if _jh_cpu():
				m.set_u32(0xa55044, p)
				m.set_u32(0xa5504c, f5bddb0(5))
			elif f5aa440(0xf0) == 0:
				return 0
			var q := m.u32(0xa55044)
			var z := m.u32(0xa5504c)
			if (f4022e0(index) & 0xffff) == 0x5ea:
				if (f56f6d0(q, z) & 0xffff) != 3:
					return 0
			elif (f56f9e0(q, z) & 0xffff) != (f402650(index) & 0xffff):
				return 0
			if not _jh_cpu() and f5aa480() == 0:
				return 0
			f5778f0(q, z, 0)
			m.set_u8(0xa5780a, m.u8(0xa5780a) - 1)
			return _jh_state(0x35) if m.u8(0xa5780a) == 0 else 0
		0x50:
			f5bdf40(first, 0xda, f402290(f402460(0x582)))
			f5bdf40(second, first, f402290(f402460(0x584)))
			f5bf800(second)
			return _jh_next()
		0x51, 0x53:
			if _jh_cancel():
				_jh_state(0x50)
				f486d20()
				return 0
			if f5aa440(0xf000f0) == 0:
				return 0
			var q := m.u32(0xa55044)
			var z := m.u32(0xa55048) + m.u32(0xa5504c)
			if state == 0x53 and q == ((m.u32(0xa55080) >> 28) & 1) and z == ((m.u32(0xa55080) >> 16) & 7):
				return 0
			if f56a140(p, q, z) == 0:
				return 0
			if state == 0x51 and (f4022e0(m.u16(JoeyMem.zone(q, z)) & 0xfff) & 0xffff) not in [0x582, 0x584]:
				return 0
			if f5aa480() == 0:
				return 0
			_jh_accept(0 if state == 0x51 else 1, z)
			return _jh_state(0x52 if state == 0x51 else 15)
		0x52:
			f5bf800(m.u32(0x5efa3c))
			return _jh_next()
		0x5a:
			if face == 0 or m.u8(JoeyMem.pl(p) + 8) != 1 or f56a000(p) == 0:
				m.set_u16(0xa558b4, 0)
			elif _s32(f56a200(p, 0xffffffff)) < 2:
				m.set_u16(0xa558b4, 1)
			else:
				f5bdf40(second, 0x72, f402290(index))
				f5bf800(second)
				f5bf9a0(1, 0)
			return _jh_next()
		0x5b:
			if m.u16(0xa558b4) == 0:
				return _jh_state(1)
			f5ad740(p, hand, f56a030(p), 0, 1)
			if announce:
				f579930(p, 0x11, 1)
			return _jh_done(1)
	return _jh_done()


func _jh_select_tribute(state: int, p: int, set_card: int) -> int:
	if state == 11 and m.u16(0xa558b4) == 0:
		return _jh_done()
	if _jh_cancel():
		f486d20()
		return _jh_state(10 if state == 11 else 1)
	if f5aa440(0xf000f0) == 0:
		return 0
	var q := m.u32(0xa55044)
	var z := m.u32(0xa5504c)
	if state == 5 and q == ((m.u32(0xa55080) >> 28) & 1) and z == ((m.u32(0xa55080) >> 16) & 7):
		return 0
	if f56a0d0(p, q, z) == 0 and (set_card == 0 or f56a140(p, q, z) == 0):
		return 0
	if state != 5 and f56a000(p) == 0 and (q != p or f569e10(q, z) == 0):
		return 0
	if f5aa480() == 0:
		return 0
	f44ef40(1)
	f486ca0(q, m.u32(0xa55048) + z)
	_jh_pick(1 if state == 5 else 0, q, z)
	return _jh_next() if state == 3 else _jh_state(15)


func _jh_sequential(p: int, table: bool) -> int:
	var ordinal := m.u8(0xa5780a)
	var locked := _jh_special_locked(p, ordinal, table)
	var q := m.u32(0xa55044)
	var z := m.u32(0xa5504c)
	var area := m.u32(0xa55048)
	if not table:
		if _jh_cancel():
			f486d20()
			return _jh_done()
		if f5aa440(0xf000f0) == 0:
			return 0
		q = m.u32(0xa55044)
		z = m.u32(0xa5504c)
		# Las zonas nativas ocupan 0x90 bytes; el C tipa DAT_a55d7a como ushort.
		if (f4022e0(m.u16(JoeyMem.zone(q, z)) & 0xfff) & 0xffff) != ordinal + 0x172:
			return 0
		if f56a140(p, q, z) == 0:
			return 0
		if locked:
			if q != p or f569e10(q, z) == 0:
				return 0
		elif q != p and (m.u8(JoeyMem.zone(q, z) + 6) & 2) == 0:
			return 0
		if f5aa480() == 0:
			return 0
		f486ca0(q, z)
		if ordinal < 3:
			_jh_pick(ordinal, q, z)
		m.set_u8(0xa5780a, ordinal + 1)
		return _jh_state(0x1e if m.u8(0xa5780a) < 3 else 15)
	var desired := f402460(m.u16(0x5dd004 + ordinal * 4)) & 0xffff
	var found := false
	if _jh_cpu():
		if not locked:
			for i in range(m.u8(JoeyMem.pl(p) + 8)):
				if (m.u32(JoeyMem.pl(p) + 0x6d4 + i * 4) & 0xfff) == desired:
					q = p
					z = i
					area = 11
					found = true
					break
		if not found:
			for side in [1-p, p]:
				for slot in range(5):
					var entry := JoeyMem.zone(side, slot)
					if (m.u32(entry) & 0xfff) == desired and f56a140(p, side, slot) and (side == p or (m.u8(entry + 6) & 2)):
						q = side
						z = slot
						area = 0
						found = true
						break
				if found:
					break
		if not found:
			return 0
	else:
		if _jh_cancel():
			return _jh_state(0x28)
		if f5aa440(0xf100f1) == 0:
			return 0
		q = m.u32(0xa55044)
		z = m.u32(0xa5504c)
		area = m.u32(0xa55048)
		if (f570230(q, area, z) & 0xffff) != desired:
			return 0
		if locked or q != p or area != 11:
			if area > 4 or f56a140(p, q, area + z) == 0:
				return 0
			if locked:
				if q != p or f569e10(q, area + z) == 0:
					return 0
			elif q != p and (m.u8(JoeyMem.zone(q, area + z) + 6) & 2) == 0:
				return 0
		if f5aa480() == 0:
			return 0
	if area == 11:
		if z < m.u8(0xa5780c):
			m.set_u8(0xa5780c, m.u8(0xa5780c) - 1)
		f575af0(q, f5700f0(q, 11, z), 0)
	else:
		f577b30(q, z + area)
	m.set_u8(0xa5780a, ordinal + 1)
	return _jh_state(0x2a if m.u8(0xa5780a) > 2 else 0x28)
