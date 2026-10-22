class_name JoeyPortZR
extends JoeyPortZQ
## Auxiliares de presentación que consumen las columnas E nativas.


func f40cac0() -> int:
	return m.u8(0xa584a4 + m.u16(0xa582a2) * 2) & 0x1f


func f40cb50(index: int) -> int:
	var at := 0xa582a4 + index * 4
	var entry := m.u32(at)
	var kind := m.u8(0xa584a4 + index * 2) & 31
	var flags := kind
	if f402690(entry & 0xfff) != 0 and kind in [16, 4]:
		if f568bd0(at) == 0: flags |= 0x40
		var face := (entry >> 19) & 3
		if face == 1: flags |= 0x100
		elif face == 2: flags |= 0x80
	if kind == 16:
		var ref := f5687d0(((entry >> 12) & 1) + ((entry >> 24) & 127) * 2)
		if ((ref >> 8) & 255) == 15:
			var meta := m.u8(0xa569e8 + ((ref >> 16) + (ref & 1) * 0x6a2) * 2)
			if meta == 0x40: flags |= 0x200
			elif meta == 0x80: flags = (flags & 31) | 0x400
	if ((~m.u32(JoeyMem.MODE)) & 1) == ((entry >> 12) & 1): flags |= 0x800
	return flags


func _zr_discard_allowed(index: int, mask: int) -> bool:
	if (index & 0xfff) == 0: return false
	if (mask & 1) != 0 and f402690(index) == 0: return false
	var kind := f4025d0(index) & 0xffff
	return not (((mask & 8) != 0 and kind != 22) or ((mask & 4) != 0 and kind == 22))


func f5a8e10(mask: int) -> int:
	var p := m.u32(JoeyMem.MODE) & 1
	var hand := JoeyMem.pl(p) + JoeyMem.P_HAND
	var count := m.u8(JoeyMem.pl(p) + JoeyMem.P_HAND_N)
	for slot in count:
		var at := hand + slot * 4
		if not _zr_discard_allowed(m.u16(at) & 0xfff, mask) or f570be0(p, at) != 0:
			continue
		if f5aa440(1) != 0:
			var selected := m.u32(0xa5504c)
			at = hand + selected * 4
			if _zr_discard_allowed(m.u16(at) & 0xfff, mask) and f570be0(p, at) == 0 and f5aa480() != 0:
				if (mask & 16) == 0: f575970(p, selected, mask & 2)
				else: f575a10(p, selected)
				return 1
		# El PE sólo busca el primer candidato elegible; espera allí la elección.
		return 0
	return 1


func f5a9050() -> int:
	return m.u8(0xa55d3c)


func f5a9060() -> int:
	if (m.u32(0xa558ac) & 0x4000) != 0 or m.u16(0xa558a8) != 0: return 0
	if m.u8(JoeyMem.pl(m.u32(JoeyMem.MODE) & 1) + JoeyMem.P_HAND_N) == 0 or m.u8(0xa55d3c) == 0:
		return 1
	if f5a8e10(m.u16(0xa57814)) != 0:
		m.set_u8(0xa55d3c, m.u8(0xa55d3c) - 1)
	return 0


## Keep portable presentation operands in metadata; the normalized oracle
## arguments retain their existing pointer masks and the same event identity.
func f5bdf40(out: int, base: int, value: int) -> int:
	_frontier(0x5bdf40, ["*", base, value], 0)
	events[-1]["native_text"] = {"out": out, "base": base, "value": value}
	return 0


func f5bdfc0(out: int, base: int, value: int) -> int:
	_frontier(0x5bdfc0, ["*", "*", value], 0)
	events[-1]["native_text"] = {"out": out, "base": base, "value": value}
	return 0
