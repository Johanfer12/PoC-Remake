class_name JoeyPortZM
extends JoeyPortZL
## Etapa6 L3: listas 599e30 y sus consultas de materiales de fusión.

const _ZM_ENTRIES := 0xa582a4
const _ZM_KINDS := 0xa584a4
const _ZM_COUNT := 0xa585a4


func _zm_fusion_row(index: int) -> Array:
	var id := f4022e0(index) & 0xffff
	if id > 1999: id -= 2000
	for table in [[0x5ecf10, 0x5ed048, 6, 2], [0x5ed048, 0x5ed060, 8, 3]]:
		for at in range(table[0], table[1], table[2]):
			if m.u16(at) == id: return [at, table[3]]
	return []


func f5918c0(index: int, material: int) -> int:
	var row := _zm_fusion_row(index)
	material &= 0xffff
	if not row.is_empty() and material < row[1]:
		return f402460(m.u16(row[0] + 2 + material * 2))
	# ASM591932 sólo borra AX; la mitad alta hereda un puntero de CardTables.
	# El único llamador (599e30 -> 5674e0) consume índices ushort.
	return 0


func f5919b0(index: int) -> int:
	var row := _zm_fusion_row(index)
	return 0 if row.is_empty() else int(row[1])


func f591ca0(player: int, ref: int) -> int:
	if ref & 0x8000: return m.u32(JoeyMem.pl(player) + JoeyMem.P_HAND + (ref & 0xfff) * 4) & 0xfff
	if ref & 0x4000: return m.u32(JoeyMem.zone(player, ref & 0xfff)) & 0xfff
	return ref & 0xffff0000


func f591a10(player: int, card_id: int, exclude_a: int, exclude_b: int) -> int:
	card_id &= 0xffff
	for substitute in 2:
		for hand in 2:
			var count := m.u8(JoeyMem.pl(player) + JoeyMem.P_HAND_N) if hand else 5
			for slot in count:
				var at := JoeyMem.pl(player) + JoeyMem.P_HAND + slot * 4 if hand else JoeyMem.zone(player, slot)
				var entry := m.u32(at)
				var index := entry & 0xfff
				if index == 0: continue
				if not hand and f56c460(player, slot) != 0: continue
				if f56b440(index, JoeyMem.ident(entry)) != 0: continue
				var matches := f568580(index) != 0 if substitute else ((f4022e0(index) & 0xffff) in [card_id, card_id + 2000])
				var ref := slot + (0x8000 if hand else 0x4000)
				if matches and ref != (exclude_a & 0xffff) and ref != (exclude_b & 0xffff): return ref
	return 0xffff


func f591d10(player: int, index: int, out: int) -> int:
	if (f4025d0(index) & 0xffff) >= 21 or (f402740(index) & 0xffff) != 2: return 0
	if f56b440(index & 0xffff, 0xffffffff) != 0: return 0
	var row := _zm_fusion_row(index)
	if row.is_empty(): return 0
	var refs: Array[int] = []
	for i in int(row[1]):
		var ref := f591a10(player, m.u16(row[0] + 2 + i * 2), refs[0] if refs.size() else 0xffff, refs[1] if refs.size() > 1 else 0xffff)
		refs.append(ref & 0xffff)
		m.set_u16(out + (int(row[1]) - i - 1) * 2, ref)
	if refs.has(0xffff): return 0
	var substitutes := 0
	for ref in refs:
		substitutes += int(f568580(f591ca0(player, ref)) != 0)
	if substitutes > 1: return 0
	if _s32(f56a030(player)) >= 0: return 1
	for ref in refs:
		if ref & 0x4000 and f569e10(player, ref & 0xfff) != 0: return 1
	return 0


func _zm_add(entry: int, kind: int) -> void:
	var count := m.u16(_ZM_COUNT)
	m.set_u32(_ZM_ENTRIES + count * 4, entry)
	m.set_u16(_ZM_KINDS + count * 2, kind)
	m.set_u16(_ZM_COUNT, count + int(count < 127))


func _zm_source(player: int, kind: int) -> Array:
	var base := JoeyMem.pl(player)
	match kind:
		1: return [base + JoeyMem.P_HAND, m.u8(base + JoeyMem.P_HAND_N)]
		2: return [base + JoeyMem.P_DECK, m.u8(base + JoeyMem.P_DECK_N)]
		4: return [base + JoeyMem.P_GRAVE, m.u8(base + JoeyMem.P_GRAVE_N)]
		8: return [base + JoeyMem.P_FUSION, m.u8(base + JoeyMem.P_FUSION_N)]
		16: return [base + JoeyMem.P_BANISH, m.u8(base + JoeyMem.P_BANISH_N)]
	return [0, 0]


func _zm_accept(player: int, selector: int, extra: int, side: int, slot: int, at: int) -> bool:
	var entry := m.u32(at)
	var index := entry & 0xfff
	match selector:
		0xaa, 0x3fa, 0x1a3, 0x1f9, 0x5e8, 0x400, 0x439: return true
		0xf: return (f4022e0(index) & 0xffff) == 0x4b2
		0x13d: return (f4022e0(index) & 0xffff) in [0x3d, 0x3e, 0x4e1]
		0x1a8, 0x45a, 0x45b, 0x51b: return (f4022e0(index) & 0xffff) == selector
		0x191, 0x410: return (f4022e0(index) & 0xffff) in [0x3eb, 0x40a]
		0x65: return (f4025d0(index) & 0xffff) == 21
		0x1ab, 0x443, 0x4b2: return (f4025d0(index) & 0xffff) == 22
		0x2f: return (f4025d0(index) & 0xffff) < 21 and (f4027b0(index) & 0xffff) < 1501
		0x23d: return (f4025d0(index) & 0xffff) < 21 and (f402800(index) & 0xffff) < 1501
		0x3b1:
			return f402690(index) == 0 and not ((f4022e0(index) & 0xffff) >= 0x605 and (f4022e0(index) & 0xffff) <= 0x608)
		0x3f3, 0x5e7: return f402690(index) != 0
		0x3f0, 0x447, 0x487, 0x488, 0x5f0:
			return (f4025d0(index) & 0xffff) < 21 and f599e00(side, slot) != 0
		0x3eb, 0x40a, 0x60b: return f591d10(player, index, m.local(8)) != 0
		0x41e:
			return (f4025d0(index) & 0xffff) < 21 and (f4027b0(index) & 0xffff) < 1501 and f570b70(player, index) != 0
		0x455: return (f4025d0(index) & 0xffff) < 21 and (f402740(index) & 0xffff) == 3
		0x45c: return f402690(index) != 0 and f599e00(player, slot) != 0 and JoeyMem.ident(entry) != extra
		0x462: return (f4025d0(index) & 0xffff) == 22 and (f402700(index) & 0xffff) == 6
		0x47b: return f402690(index) != 0 and (f4027b0(index) & 0xffff) < 1501 and f567990(index) == 0
		0x4bc: return (f4022e0(index) & 0xffff) in [0x22, 0x4ba, 0x7f2]
		0x4d8: return (f4022e0(index) & 0xffff) == 0x2ea
		0x4d9: return (f4022e0(index) & 0xffff) in [0x2ea, 0x4d8]
		0x526: return (f4025d0(index) & 0xffff) == 10 and (f4026c0(index) & 0xffff) == extra and f570b70(player, index) != 0
		0x530: return (f4022e0(index) & 0xffff) == 0x2fa and f570be0(player, at) == 0
		0x58d, 0x596, 0x599, 0x5a4: return f402690(index) != 0 and (entry & 0x200000) != 0
		0x59f: return (f4025d0(index) & 0xffff) == 22 and (entry & 0x400000) != 0
		0x5e9, 0x5fc: return (f4025d0(index) & 0xffff) < 21
		0x5ea: return (f4025d0(index) & 0xffff) == 3
		0x5eb, 0x5ec, 0x5ed, 0x5ee, 0x5ef:
			return (f4025d0(index) & 0xffff) < 21 and (f402650(index) & 0xffff) == (f402650(f402460(selector)) & 0xffff)
		0x5f4: return (entry & 0x180000) == 0x100000
		0x60d: return (f4025d0(index) & 0xffff) < 21 and m.u8(JoeyMem.pl(player) + 0xc88 + slot * 2) != 0x80
		0x454, 0x456, 0x45d, 0x45f, 0x460, 0x463:
			var attributes := {0x454: 5, 0x456: 4, 0x45d: 1, 0x45f: 3, 0x460: 6, 0x463: 2}
			return (f4025d0(index) & 0xffff) < 21 and (f4027b0(index) & 0xffff) < 1501 and (f402650(index) & 0xffff) == attributes[selector] and f570b70(player, index) != 0
	return false


func _zm_collect(player: int, selector: int, extra: int, side: int, kind: int, limit: int = 256) -> void:
	var source := _zm_source(side, kind)
	for slot in mini(int(source[1]), limit):
		var at := int(source[0]) + slot * 4
		if _zm_accept(player, selector, extra, side, slot, at): _zm_add(m.u32(at), kind)


func _zm_filter(player: int, allow_toons: bool, keep_top: bool) -> int:
	if m.u16(_ZM_COUNT) != 0 and not allow_toons and f569cb0(player) == 0:
		var i := 0
		while i < m.u16(_ZM_COUNT):
			if f5675f0(m.u16(_ZM_ENTRIES + i * 4) & 0xfff) == 0:
				i += 1
			else:
				for j in range(i, m.u16(_ZM_COUNT) - 1):
					m.set_u32(_ZM_ENTRIES + j * 4, m.u32(_ZM_ENTRIES + (j + 1) * 4))
					m.set_u16(_ZM_KINDS + j * 2, m.u16(_ZM_KINDS + (j + 1) * 2))
				m.set_u16(_ZM_COUNT, m.u16(_ZM_COUNT) - 1)
	if not keep_top:
		var i := 0
		while i < m.u16(_ZM_COUNT):
			if m.u16(_ZM_KINDS + i * 2) == 2 and f570be0(player, _ZM_ENTRIES + i * 4) != 0:
				# El segundo filtro copia también la entrada posterior al final.
				for j in range(i, m.u16(_ZM_COUNT)):
					m.set_u32(_ZM_ENTRIES + j * 4, m.u32(_ZM_ENTRIES + (j + 1) * 4))
					m.set_u16(_ZM_KINDS + j * 2, m.u16(_ZM_KINDS + (j + 1) * 2))
				m.set_u16(_ZM_COUNT, m.u16(_ZM_COUNT) - 1)
			else: i += 1
	return m.u16(_ZM_COUNT)


func f599e30(player: int, code: int, extra: int) -> int:
	var selector := code & 0xffff
	m.set_u16(_ZM_COUNT, 0)
	var own := player & 1
	var opponent := own ^ 1
	if selector == 0xffff:
		var kinds := {12: 8, 13: 2, 14: 4, 15: 16}
		if not kinds.has(extra): return 0
		var kind: int = kinds[extra]
		var source := _zm_source(own, kind)
		m.set_u16(_ZM_COUNT, source[1])
		var i := 0
		while i < m.u16(_ZM_COUNT):
			f5675c0(_ZM_ENTRIES + i * 4, source[0] + i * 4)
			m.set_u16(_ZM_KINDS + i * 2, kind)
			i += 1
		return m.u16(_ZM_COUNT)
	var allow_toons := selector in [0x2f, 0xaa, 0x23d, 0x3f3, 0x3fa, 0x400, 0x439, 0x586, 0x58d, 0x596, 0x599, 0x5a4, 0x5e7, 0x5e9, 0x5ea, 0x5eb, 0x5ec, 0x5ed, 0x5ee, 0x5ef, 0x5fc, 0x60d]
	match selector:
		0xf, 0x13d:
			_zm_collect(player, selector, extra, own, 1)
			_zm_collect(player, selector, extra, own, 2)
		0xaa, 0x3fa:
			_zm_collect(player, selector, extra, opponent if selector == 0x3fa else own, 2, 5)
		0x1a3, 0x1f9, 0x5e8, 0x3eb, 0x40a, 0x60b:
			_zm_collect(player, selector, extra, own, 8)
		0x3f0:
			_zm_collect(player, selector, extra, own, 4)
			_zm_collect(player, selector, extra, opponent, 4)
		0x400:
			_zm_collect(player, selector, extra, opponent, 4)
			_zm_collect(player, selector, extra, own, 4)
		0x3f3, 0x443, 0x5e7:
			_zm_collect(player, selector, extra, opponent, 4)
		0x439:
			if extra == 0: _zm_collect(player, selector, extra, own, 2)
			else:
				var source := _zm_source(opponent, 2)
				for i in 5:
					var slot := 0
					while slot < int(source[1]) and (m.u32(source[0] + slot * 4) & 0xfff) != m.u16(0xa57814 + i * 2): slot += 1
					_zm_add(m.u32(source[0] + slot * 4), 2)
		0x586:
			for i in 3: _zm_add(m.u32(JoeyMem.pl(opponent) + JoeyMem.P_HAND + m.u16(0xa57814 + i * 2) * 4), 1)
		0x60a:
			var substitute_used := false
			var source := _zm_source(own, 4)
			for material in range(f5919b0(extra) - 1, -1, -1):
				var found := false
				for slot in int(source[1]):
					var entry := m.u32(source[0] + slot * 4)
					if f599e00(player, slot) == 0 or (entry & 0x180000) == 0: continue
					if f5674e0(entry & 0xfff, f5918c0(extra, material)) == 0: continue
					var duplicate := false
					for i in m.u16(_ZM_COUNT):
						if m.u32(_ZM_ENTRIES + i * 4) == entry: duplicate = true; break
					if not duplicate: _zm_add(entry, 4); found = true; break
				if not found and not substitute_used:
					for slot in int(source[1]):
						var entry := m.u32(source[0] + slot * 4)
						if f599e00(player, slot) != 0 and (entry & 0x180000) != 0 and f568580(entry & 0xfff) != 0:
							substitute_used = true; _zm_add(entry, 4); break
		0x60d:
			_zm_collect(player, selector, extra, own, 16)
		0x65, 0x191, 0x1ab, 0x447, 0x45c, 0x47b, 0x487, 0x488, 0x4d9, 0x58d, 0x596, 0x599, 0x59f, 0x5a4, 0x5e9, 0x5ea, 0x5eb, 0x5ec, 0x5ed, 0x5ee, 0x5ef, 0x5f0, 0x5f4, 0x5fc:
			_zm_collect(player, selector, extra, own, 4)
		0x2f, 0x1a8, 0x23d, 0x3b1, 0x410, 0x41e, 0x454, 0x455, 0x456, 0x45a, 0x45b, 0x45d, 0x45f, 0x460, 0x462, 0x463, 0x4b2, 0x4bc, 0x4d8, 0x51b, 0x526, 0x530:
			_zm_collect(player, selector, extra, own, 2)
		_: return 0
	return _zm_filter(player, allow_toons, selector in [0xaa, 0x3fa])
