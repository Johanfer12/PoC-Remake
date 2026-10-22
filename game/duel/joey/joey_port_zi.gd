class_name JoeyPortZI
extends JoeyPortZH
## Acciones disponibles del cursor humano. Fuentes nativas5a0090..5a0c90.


func f5a0090() -> int:
	if f5a00c0() & 0xffff == 0:
		m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffe)
		m.set_u16(0xa57808, m.u16(0xa57808) & 0xff00)
		m.set_u16(0xa57806, 0)
	return 0


func f5a00c0() -> int:
	var location := m.u32(0xa55048)
	var card := f5beeb0()
	if location not in [0, 5, 10, 11, 12, 13, 14, 15]:
		return 0
	if location in [0, 5, 10, 11] and card & 0xffff == 0:
		return 0
	m.set_u16(0xa57808, m.u16(0xa57808) & 0xff00)
	var actions := f5a0140() & 0xffff
	m.set_u16(0xa57804, (m.u16(0xa57804) & 0xfffe) | int(actions != 0))
	m.set_u16(0xa57806, actions)
	return m.u16(0xa57804) & 1


func f5a0140() -> int:
	return f5a0150(f5beeb0())


func f5a0150(card: int) -> int:
	var p := m.u32(0xa55044)
	var location := m.u32(0xa55048)
	var index := m.u32(0xa5504c)
	match location:
		0:
			return card if card & 0xffff == 0 else f5a0530(card, p, index)
		5:
			return card if card & 0xffff == 0 else f5a08f0(card, p, index)
		10:
			return card if card & 0xffff == 0 else f5a08f0(card, p, 5)
		11:
			return card if card & 0xffff == 0 else f5a02a0(card, p, index)
		12, 13, 14, 15:
			var result := (f5a0010(p, location) | f5a0070(0, p, location)) & 0xffff
			if p == (m.u16(JoeyMem.MODE) & 1) and location == 13 and (result != 0 or f5aa480() != 0):
				result |= 0x100
			return result
	return 0


func _zi_effect(card: int, p: int, z: int, bits: int) -> int:
	var desc := m.local(20)
	m.set_u16(desc, card)
	m.set_u16(desc + 2, (p & 1) | ((z & 31) << 1) | bits)
	m.set_u16(desc + 4, _zi_identity(p, z) * 32)
	f45e240(4)
	return f57e490(desc, 0)


func f5a0800(card: int, p: int, z: int) -> int:
	if f402690(card) != 0 and f568030(card & 0xffff) != 0:
		return _zi_effect(card, p, z, 0x1000)
	return 0


func f5a0530(card: int, p: int, z: int) -> int:
	var at := JoeyMem.zone(p, z)
	var flags := m.u16(at + 6)
	if p == (~m.u8(JoeyMem.MODE) & 1):
		if f402690(card) == 0 or flags & 2 == 0 or f568310(card & 0xffff) == 0:
			return 0
		return 8 if _zi_effect(card, p, z, 0x5000) != 0 else 0
	var phase := (m.u8(JoeyMem.TURN) >> 1) & 7
	if phase == 1:
		if flags & 2 == 0 or f4022e0(card) not in [0x1a0, 0x243]:
			return 0
		return 8 if f57ec70(p, z, card & 0xffff) != 0 else 0
	var actions := 0
	if phase in [2, 4]:
		if f56b440(card & 0xffff, _zi_identity(p, z)) == 0:
			if f56b5a0(p, z) != 0:
				if flags & 2 == 0:
					if flags & 1 == 0:
						actions = 0x20
					if f570a70(p) != 0:
						var can_flip := f5675f0(card)
						actions |= 2
						if can_flip != 0 and (f570b40(p) == 0 or f569cb0(p) == 0):
							actions &= ~2
				else:
					actions = 0x40 if flags & 1 else 0x20
		elif p == (m.u16(JoeyMem.MODE) & 1):
			f45e240(16)
		if flags & 2 and f5a0800(card, p, z) != 0:
			actions |= 8
	elif phase == 3:
		if (m.u16(JoeyMem.pl(p) + 0x10) & (1 << (z & 31))) == 0:
			f45e240(7)
			if f56b730(p, z, 1) != 0:
				return 4
		else:
			f45e240(8)
	return actions


func f5a02a0(card: int, p: int, hand: int) -> int:
	if p == (~m.u8(JoeyMem.MODE) & 1):
		return 0
	var local := p == (m.u16(JoeyMem.MODE) & 1)
	if f56b440(card & 0xffff, 0xffffffff) != 0:
		if local:
			f45e240(16)
		return 0
	if f570a10(p, card & 0xffff) == 0:
		if local:
			f45e240(23)
		return 0
	var phase := (m.u8(JoeyMem.TURN) >> 1) & 7
	var kind := f4025d0(card) & 0xffff
	var actions := 0
	if phase in [2, 4]:
		if kind == 21:
			if f56a430(p, card) != 0:
				actions = 16
			else:
				f45e240(12)
		elif kind == 22:
			if f56a430(p, card) != 0:
				actions = 8 if f57edd0(p, hand, card & 0xffff) != 0 else 0
				if f5685c0(card & 0xffff) == 0:
					actions |= 16
			else:
				f45e240(12)
		else:
			if f567a00(card) == 0:
				if m.u32(JoeyMem.pl(p) + 0x6d0) & 0x20000:
					f45e240(2)
					actions = f5aae00(p, card)
				else:
					actions = f5aab90(p, card) | f5aae00(p, card)
			else:
				f45e240(13)
				actions = f5aae00(p, card)
			if f5682d0(card & 0xffff) != 0 and f57edd0(p, hand, card & 0xffff) != 0:
				actions |= 8
	elif phase == 3:
		if kind == 21:
			f45e240(15)
		elif kind == 22:
			if f402700(card) & 0xffff != 5:
				f45e240(5)
		else:
			f45e240(6)
	if local and kind == 22 and f402700(card) & 0xffff == 5 and f56a430(p, card) != 0 and f57edd0(p, hand, card & 0xffff) != 0:
		actions |= 8
	if kind == 22 and actions & 8 and f5699c0(0x49c) != 0:
		actions &= 0xfff7
	if f402690(card) == 0 and f5709d0(p, 0x520) != 0:
		actions &= 0xffe7
	return actions & 0xffff


func f5a08f0(card: int, p: int, z: int) -> int:
	var at := JoeyMem.zone(p, z + 5)
	var flags := m.u16(at + 6)
	if m.u32(0xa55048) < 11 and f56b440(card & 0xffff, _zi_identity(p, z + 5)) != 0:
		if p == (m.u16(JoeyMem.MODE) & 1):
			f45e240(16)
		return 0
	if p == (~m.u8(JoeyMem.MODE) & 1):
		if f402690(card) == 0 and flags & 2 and f568310(card & 0xffff) != 0:
			return 8 if _zi_effect(card, p, z + 5, 0x5000) != 0 else 0
		return 0
	var result := 0
	var kind := f4025d0(card) & 0xffff
	var valid := 0
	if kind == 21:
		if flags & 2 == 0:
			f45e240(4)
			if flags & 0x400:
				valid = f57ed20(p, z + 5, card & 0xffff)
			else:
				f45e240(1)
		elif f402690(card) == 0 and f568030(card & 0xffff) != 0:
			valid = _zi_effect(card, p, z + 5, 0x1000)
	elif kind == 22:
		if flags & 2:
			if f402690(card) == 0 and f568030(card & 0xffff) != 0:
				f45e240(4)
				valid = f57ec70(p, z + 5, card & 0xffff)
		else:
			f45e240(4)
			if flags & 0x400:
				var phase := m.u16(JoeyMem.TURN) & 14
				var allowed := f402700(card) & 0xffff == 5 or (phase in [4, 8] and (m.u8(JoeyMem.TURN) ^ m.u8(JoeyMem.MODE)) & 1 == 0)
				if (phase == 2 and f4022e0(card) == 0x428) or allowed:
					if f402700(card) & 0xffff == 3:
						f45e240(10)
					valid = f57ed20(p, z + 5, card & 0xffff)
				elif phase == 6:
					f45e240(5)
	if valid != 0:
		result = 8
	if f402690(card) == 0 and f56db30(p, 11, 0x520) != 0:
		result = 0
	return result


func _zi_identity(p: int, z: int) -> int:
	var entry := m.u32(JoeyMem.zone(p, z))
	return ((entry >> 12) & 1) + ((entry >> 24) & 127) * 2


func f57edd0(p: int, hand: int, card: int) -> int:
	var descriptor := m.local(20)
	var entry := m.u32(JoeyMem.pl(p) + 0x6d4 + hand * 4)
	m.set_u16(descriptor, card)
	m.set_u16(descriptor + 2, (p & 1) | 0x16)
	m.set_u16(descriptor + 4, (((entry >> 12) & 1) + ((entry >> 24) & 127) * 2) * 32)
	return f57e650(descriptor, 0)


func f59def0(card: int) -> int:
	match f4022e0(card) & 0xffff:
		0x5ea: return 3
		0x5eb: return 2
		0x5ec, 0x5ed, 0x5ee, 0x5ef: return 1
	return 0


func f40ccb0(index: int) -> int:
	for i in range(m.u16(0xa585a4)):
		if index == m.u16(0xa584a4 + i * 2) >> 8:
			m.set_u16(0xa582a2, i)
			return 0
	m.set_u16(0xa582a2, 0xffff)
	return 0
