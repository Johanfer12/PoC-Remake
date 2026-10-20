class_name JoeyPortZF
extends JoeyPortZE
## IA Joey, prioridades de cartas y maquinas de decision de 5efb50/5efb78.
## Fuente: re/out/joey/funcs/005b4860.c..005b7bd0.c, con operandos x86 de 32bits.

func _jzf_p(at: int) -> int:
	return m.u8(at + 2) & 1

func _jzf_lp(p: int) -> int:
	return m.u16(JoeyMem.pl(p) + 4)

func _jzf_stats(p: int, z: int) -> Array[int]:
	var at := m.local(12)
	f56dd30(p, z, at)
	return [_s32(m.u32(at + 4)), _s32(m.u32(at + 8))]

func _jzf_max(p: int) -> Array[int]:
	var at := m.local(8)
	f5aff10(p, at, at + 4, 1)
	return [_s32(m.u32(at)), _s32(m.u32(at + 4))]

func _jzf_pred(fn: int, at: int) -> int:
	var args := [at, 0] if fn in [0x5b4c90,0x5b4df0,0x5b4ec0,0x5b4f70,0x5b5040,0x5b5ab0] else [at]
	# These PE predicates never read the extra context pushed by the dispatcher.
	if fn in [0x547ce0,0x57fa90,0x57fac0,0x581040,0x581740,0x581b80,
		0x581de0,0x582080,0x582200,0x5826b0,0x582be0,0x583120]:
		args = []
	return int(callv("f%06x" % fn, args))

func f5b4860(at: int) -> int:
	return int(_s32(f59dd20(at, 1 - _jzf_p(at))) > 0)

func f5b4890(at: int) -> int:
	var n := _s32(f569c50(_jzf_p(at), f4022e0(m.u16(at))))
	return int(n <= int(m.u8(at + 2) & 0x3e < 21))

func f5b48d0(at: int) -> int:
	return f5aef10(_jzf_p(at))

func f5b48f0(at: int) -> int:
	return int(_s32(f5afe90(_jzf_p(at))) > 0)

func f5b4910(at: int) -> int:
	var p := _jzf_p(at)
	return int(_jzf_lp(1 - p) < _jzf_lp(p) + 500)

func f5b4970(at: int) -> int:
	return int(_s32(f56a320(1 - _jzf_p(at), 0, 0, 1)) > 1)

func f5b49a0(at: int) -> int:
	return int(_s32(f56a320(1 - _jzf_p(at), 1, 0, 1)) > 0)

func f5b49d0(at: int) -> int:
	var p := _jzf_p(at)
	if _s32(f569720(p, 0x488)) >= 0:
		return 1
	if f569d50(1 - p) == 0 and f569d50(p) != 0 and _s32(f56a320(1 - p, 0, 0, 1)) > 0:
		return 1
	var z := _s32(f569720(p, 0x447))
	if z >= 0:
		var ref := s16(f56b250(p, z))
		if ref == -1:
			return 1
		var card := s16(f4022e0(m.u16(JoeyMem.zone(ref & 1, (ref >> 8) & 255)) & 0xfff))
		if card in [0x2f, 0x23d]:
			return 1
	return 0

func f5b4ae0(at: int) -> int:
	var p := _jzf_p(at)
	var rival := _s32(f56a320(1 - p, 0, 0, 1))
	return int(_s32(f56a320(p, 0, 0, 1)) < rival)

func f5b4b30(at: int) -> int:
	return int(_s32(f59dd20(at, _jzf_p(at))) > 1)

func f5b4b50(at: int) -> int:
	return int(m.u8(JoeyMem.pl(1 - _jzf_p(at)) + 10) > 4)

func f5b4b90(at: int) -> int:
	var p := _jzf_p(at)
	var best := _jzf_max(p)[0]
	for z in range(5):
		var obj := JoeyMem.zone(1 - p, z)
		if m.u32(obj) & 0xfff and m.u8(obj + 6) & 2:
			var stats := _jzf_stats(1 - p, z)
			var first := stats[1] if m.u8(obj + 6) & 1 else stats[0]
			var second := stats[0] if m.u8(obj + 6) & 1 else stats[1]
			if best < first and second < best:
				return 1
	return 0

func f5b4c90(at: int, _unused: int) -> int:
	if f5b4890(at) != 0:
		var p := _jzf_p(at)
		for z in range(m.u8(JoeyMem.pl(p) + 8)):
			if f5675f0(m.u16(0xa56434 + p * 0xd44 + z * 4) & 0xfff) != 0:
				return 1
	return 0

func f5b4d40(at: int) -> int:
	var p := _jzf_p(at)
	if f5709d0(1 - p, 0x3ca) == 0:
		var best := _s32(f5affd0(p, p, 0xffffffff, 1, 0))
		for z in range(5):
			var obj := JoeyMem.zone(1 - p, z)
			if m.u32(obj) & 0xfff and m.u8(obj + 6) & 1 == 0:
				if _s32(f56f690(1 - p, z)) < best:
					return 1
	return 0

func f5b4df0(at: int, _unused: int) -> int:
	return int(f5b4890(at) != 0 and _s32(f569d90(1 - _jzf_p(at), 0, 1)) > 0)

func f5b4e30(at: int) -> int:
	return int(_s32(f56a000(1 - _jzf_p(at))) > 1)

func f5b4e60(at: int) -> int:
	var p := _jzf_p(at)
	return int(_jzf_lp(1 - p) < 501 or _jzf_lp(p) > 1500)

func f5b4ec0(at: int, _unused: int) -> int:
	return int(f5b4890(at) != 0 and m.u8(JoeyMem.pl(_jzf_p(at)) + 8) > 5)

func f5b4f10(at: int) -> int:
	var p := _jzf_p(at)
	var n := _s32(f569c50(p, 0x4ce)) + _s32(f569c50(p, 0x15b))
	if n >= int(m.u8(at + 2) & 0x3e < 21):
		return 0
	return int(_s32(f5afe90(p)) < 0)

func f5b4f70(at: int, _unused: int) -> int:
	return int(f5b4890(at) != 0 and _s32(f569bf0(1 - _jzf_p(at), 10)) > 0)

func f5b4fb0(at: int) -> int:
	return int(_s32(f599e30(_jzf_p(at), f4022e0(m.u16(at)), 0)) > 0)

func f5b4fe0(at: int) -> int:
	return (m.u32(0xa56430 + _jzf_p(at) * 0xd44) >> 24) & 1

func f5b5010(at: int) -> int:
	return int(m.u32(0xa56314 + _jzf_p(at) * 0xd44) & 0xfff == 0)

func f5b5040(at: int, _unused: int) -> int:
	return f5b5010(at) if m.u8(at + 3) & 0x30 == 0 else 1

func f5b5060(at: int) -> int:
	var p := _jzf_p(at)
	return int(f5b3d30(p) != 0 or _s32(f5afe90(p)) < 0)

func f5b50a0(at: int) -> int:
	var p := _jzf_p(at)
	return int(f5b3d30(p) != 0 or _s32(f5afe90(p)) < 0 or _s32(f569d50(1 - p)) > 2)

func f5b5100(at: int) -> int:
	return int(_s32(f5afe90(_jzf_p(at))) < 0)

func f5b5120(at: int) -> int:
	var p := _jzf_p(at)
	if _s32(f56a200(1 - p, 0xffffffff)) > 0 and m.u32(0xa56430 + p * 0xd44) & 0x20000 == 0:
		for z in range(m.u8(JoeyMem.pl(p) + 8)):
			var index := m.u16(0xa56434 + p * 0xd44 + z * 4) & 0xfff
			if f402690(index) != 0 and f567a00(index) == 0 and f4026c0(index) & 0xffff > 4:
				if f4026c0(index) & 0xffff < 7 or f569d50(p) != 0:
					return 1
	return 0

func f5b5230(at: int) -> int:
	var p := _jzf_p(at)
	var other := _s32(f569d50(1 - p))
	return int(other < _s32(f569d50(p)))

func f5b5270(at: int) -> int:
	return int(_s32(f569d50(_jzf_p(at))) > 1)

func f5b5290(at: int) -> int:
	var p := _jzf_p(at)
	for z in range(5):
		var obj := JoeyMem.zone(1 - p, z)
		if m.u32(obj) & 0xfff and m.u8(obj + 6) & 2 and _s32(f56f690(1 - p, z)) > 0x707:
			return 1
	return 0

func _jzf_choose(at: int, inclusive: bool) -> int:
	var p := _jzf_p(at)
	if _s32(f5af5a0(p, m.u16(at), 0)) < 0:
		return 0
	var chosen := m.u32(f40cab0()) & 0xfff
	var other := _jzf_max(1 - p)
	if f4027b0(chosen) & 0xffff > 0x6a4:
		var best := maxi(other[0], other[1])
		var attack := f4027b0(chosen) & 0xffff
		if best <= attack if inclusive else best < attack:
			return 1
	return int(s16(f402740(chosen)) == 1 and f567620(chosen, 0xffffffff) == 0)

func f5b5300(at: int) -> int:
	var p := _jzf_p(at)
	if _s32(f5af5a0(p, m.u16(at), 0)) < 0:
		return 0
	var entry := m.u32(f40cab0())
	var index := entry & 0xfff
	var other := _jzf_max(1 - p)
	var accepted := false
	if f4027b0(index) & 0xffff > 0x6a4:
		accepted = maxi(other[0], other[1]) < f4027b0(index) & 0xffff
	if not accepted and (s16(f402740(index)) != 1 or f567620(index, 0xffffffff) != 0):
		return 0
	return int(p == ((entry >> 12) & 1) or f5ae8f0(index) == 0)

func f5b53e0(at: int) -> int:
	return _jzf_choose(at, false)

func f5b5490(at: int) -> int:
	var p := _jzf_p(at)
	var best := 0
	if _s32(f5af5a0(1 - p, m.u16(at), 0)) >= 0:
		var selected := m.u32(f40cab0()) & 0xfff
		var defense := f402800(selected) & 0xffff
		var attack := f4027b0(selected) & 0xffff
		best = (f4027b0(selected) if defense < attack else f402800(selected)) & 0xffff
	if _s32(f5af5a0(p, m.u16(at), 0)) >= 0:
		var index := m.u32(f40cab0()) & 0xfff
		var other := _jzf_max(1 - p)
		if best <= maxi(other[0], other[1]):
			best = maxi(other[0], other[1])
		if f4027b0(index) & 0xffff > 0x6a4 and best <= f402800(index) & 0xffff:
			return 1
		if s16(f402740(index)) == 1:
			return 1
	return 0

func f5b55a0(at: int) -> int:
	return _jzf_choose(at, true)

func f5b5650(at: int) -> int:
	var local := m.local(20)
	m.copy(local, at, 20)
	if _jzf_lp(_jzf_p(at)) > 2000:
		var table := 0x5dd4c0
		while true:
			m.set_u16(local, f402460(m.u16(table)))
			if s16(f4025d0(m.u32(local))) == 0x16 and f56cbd0(1 - _jzf_p(at), f4022e0(m.u32(local))) != 0:
				if _jzf_pred(m.u32(table + 4), local) != 0:
					m.set_u16(0xa579a4, m.u16(local))
					return 1
			table += 8
			if s16(m.u16(table)) == 0x443:
				break
	return 0

func f5b5720(at: int) -> int:
	var p := _jzf_p(at)
	if _s32(f569d50(1 - p)) > 0:
		var best := 0
		for z in range(5):
			var obj := JoeyMem.zone(p, z)
			if m.u32(obj) & 0xfff and m.u8(obj + 6) & 1 == 0:
				if best <= _s32(f56f690(p, z)):
					best = _s32(f56f690(p, z))
		for z in range(5):
			var obj := JoeyMem.zone(1 - p, z)
			if m.u32(obj) & 0xfff and m.u8(obj + 6) & 1 == 0:
				var stats := _jzf_stats(1 - p, z)
				if best <= stats[0] and stats[1] < best:
					return 1
	return 0

func f5b5830(at: int) -> int:
	var p := _jzf_p(at)
	var other := _jzf_max(1 - p)
	var own := _jzf_max(p)
	var best := maxi(other[0], other[1])
	return int(best >= own[0] and best < own[1])

func f5b58b0(at: int) -> int:
	var p := _jzf_p(at)
	return int(m.u8(JoeyMem.pl(1 - p) + 8) >= 2 and (_s32(f5b0420(1 - p)) >= 0 or f5699a0(p, 0x40e) != 0))

func f5b5920(at: int) -> int:
	return int(_s32(f5b0420(1 - _jzf_p(at))) >= 0)

func f5b5950(at: int) -> int:
	var p := _jzf_p(at)
	if _jzf_lp(1 - p) <= _jzf_lp(p):
		return 0
	var z := _s32(f5b0150(at, p, 0xffffffff, 0))
	if f56d660(p, z, 0x290) != 0:
		z = _s32(f5b0150(at, p, z, 0))
	return int(z >= 0 and _s32(f56f690(p, z)) > 0x5db)

func f5b5a00(at: int) -> int:
	return int(_s32(f5699a0(_jzf_p(at), 0x51)) > 0)

func f5b5a20(at: int) -> int:
	var p := _jzf_p(at)
	var z := _s32(f5b0150(at, p, 0xffffffff, 0))
	return int(z >= 0 and _s32(f56f690(p, z)) > 0x513)

func f5b5a60(at: int) -> int:
	var p := 1 - _jzf_p(at)
	var z := _s32(f5b0150(at, p, 0xffffffff, 0))
	return int(z >= 0 and _s32(f56f690(p, z)) > 0x513)

func f5b5ab0(at: int, _unused: int) -> int:
	return int(f5b4890(at) != 0 and f5b5a20(at) != 0)

func f5b5af0(at: int) -> int:
	var p := _jzf_p(at)
	return int(_jzf_lp(1 - p) <= _s32(f569d50(p)) * 500 or _s32(f5ae9c0(p, 0xffffffff, 0)) >= 0)

func f5b5b60(at: int) -> int:
	return int(_s32(f5afe90(_jzf_p(at))) < 1)

func f5b5b80(at: int) -> int:
	return int(f59dd20(at, _jzf_p(at)) == 0)

func f5b5ba0(at: int) -> int:
	var p := _jzf_p(at)
	return int(_jzf_lp(1 - p) < 0x4b1 or _s32(f569d50(p)) > 2)

func f5b5bf0(at: int) -> int:
	var p := _jzf_p(at)
	if _s32(f569d50(p)) > 1 and _s32(f5af5a0(p, m.u16(at), 0)) >= 0:
		var index := m.u32(f40cab0()) & 0xfff
		return int(f567990(index) != 0 and index != m.u16(at))
	return 0

func f5b5c60(at: int) -> int:
	var p := _jzf_p(at)
	if f5a0dd0(p) != 0 and f56b730(p, (m.u16(at + 2) >> 1) & 31, 1) != 0:
		for z in range(5):
			var obj := JoeyMem.zone(1 - p, z)
			if m.u32(obj) & 0xfff:
				var stats := _jzf_stats(1 - p, z)
				var value := stats[1] if m.u8(obj + 6) & 1 else stats[0]
				if value > 999 and value < 2000:
					return 1
	return 0

func f5b5d60(at: int) -> int:
	var p := _jzf_p(at)
	return int(f5a0dd0(p) != 0 and f569d50(1 - p) == 0)

func f5b5da0(at: int) -> int:
	var p := _jzf_p(at)
	return int(f5a0dd0(p) != 0 and (f569d50(1 - p) == 0 or _s32(f5afe90(p)) < 0))

func _jzf_ai_next() -> void:
	m.set_u8(0xa579a2, m.u8(0xa579a2) + 1)

func _jzf_select(index: int, p: int, z: int, kind: int, operation: int, identity: int) -> void:
	m.set_u16(0xa57808, m.u16(0xa57808) & 0xff)
	m.set_u16(0xa57802, index)
	m.set_u8(0xa5780e, identity)
	m.set_u16(0xa5780a, m.u8(0xa5780a) | ((p & 255) << 8) | ((kind & 127) << 9))
	m.set_u8(0xa5780c, z)
	m.set_u32(0xa57804, (m.u32(0xa57804) & 0xffffff9f) | operation)

func f5b5e00(p: int, row: int) -> int:
	var index := f402460(m.u16(row)) & 0xffff
	if f598c40(p, 5, index) != 0:
		return 0
	var monster := f402690(index) != 0
	var local := m.local(20)
	var zones := range(5) if monster else range(5, 11)
	for z in zones:
		var obj := JoeyMem.zone(p, z)
		var entry := m.u32(obj)
		if entry & 0xfff != index or (monster and m.u8(obj + 6) & 2 == 0):
			continue
		m.clear(local, 20)
		m.set_u16(local, index)
		m.set_u16(local + 2, (p & 1) | ((z & 31) << 1) | (0x1000 if monster else 0))
		m.set_u16(local + 4, JoeyMem.ident(entry) << 5)
		var valid := f57e490(local, 0) if monster else f57e160(local, p, p, z)
		if valid != 0 and _jzf_pred(m.u32(row + 4), local) != 0:
			_jzf_select(index, p, z % 5, (z / 5) * 5, 0x1e, JoeyMem.ident(m.u32(obj)))
			return 1
	if not monster:
		var z := _s32(f56d340(p, m.u16(row)))
		if z >= 0:
			var entry := m.u32(0xa56434 + (p & 1) * 0xd44 + z * 4)
			m.clear(local, 20)
			m.set_u16(local, index)
			m.set_u16(local + 2, (p & 1) | 0x16)
			m.set_u16(local + 4, JoeyMem.ident(entry) << 5)
			if f57e220(local, p, z) != 0 and _jzf_pred(m.u32(row + 4), local) != 0:
				_jzf_select(index, p & 1, z, 11, 0x1e, JoeyMem.ident(m.u32(0xa56434 + (p & 1) * 0xd44 + z * 4)))
				return 1
	return 0

func _jzf_scan(p: int, first: int, last: int) -> int:
	var table := first
	while table < last:
		if f5b5e00(p, table) != 0:
			return 1
		table += 8
	return 0

func _jzf_place_hand(p: int, hand: int, index: int, defense: bool, operation: int = 6) -> void:
	var entry := m.u32(0xa56434 + (p & 1) * 0xd44 + hand * 4)
	m.set_u16(0xa57808, m.u16(0xa57808) & 0xff)
	m.set_u16(0xa57802, index)
	m.set_u8(0xa5780e, JoeyMem.ident(entry))
	m.set_u8(0xa5780c, hand)
	m.set_u16(0xa5780a, m.u8(0xa5780a) | ((p & 255) << 8) | 0x1600)
	m.set_u16(0xa57804, (m.u16(0xa57804) & 0xff87) | ((10 + int(defense)) * 8) | operation)

func f5b62f0() -> int:
	var turn := m.u8(JoeyMem.TURN)
	var p := turn & 1
	var step := m.u8(0xa579a2)
	if step == 0:
		if _jzf_scan(p, 0x5dd3c8, 0x5dd4c0) != 0:
			return 0
		_jzf_ai_next()
	elif step != 1 and step != 2:
		return 1
	if step in [0, 1]:
		if f570a10(p, f402460(0x1a8)) != 0 and f56d2c0(p, 0x1a8) != 0 and _s32(f599e30(p, 0x1a8, 0)) > 0:
			var hand := _s32(f56d340(p, 0x1a8))
			m.set_u8(0xa55c95, m.u8(0xa55c95) | 0x80)
			f59d040(p)
			f575a10(p, hand)
			# El segundo argumento de ba860 sigue en la pila tras el getter de IntID.
			var identity := JoeyMem.ident(m.u32(0xa56434 + p * 0xd44 + hand * 4))
			f5ba860((f402460(0x1a8) & 0xffff) | (turn << 31) | 0x4e0000, identity)
			m.set_u8(0xa579a2, 0)
			return 0
		_jzf_ai_next()
	for hand in range(m.u8(JoeyMem.pl(p) + 8)):
		var index := m.u32(0xa56434 + p * 0xd44 + hand * 4) & 0xfff
		var id := f4022e0(index) & 0xffff
		var special := id in [0x546,0x17a,0x34d] or (id > 0x5e9 and (id < 0x5f0 or (id == 0x5f0 and f56cdc0(1 - p) == 0)))
		if special:
			var options := f5aae00(p, index)
			if options != 0:
				var defense := 1
				if options & 0x400:
					defense = 0 if options & 0x800 == 0 else f5ae270(p, index, 1, 0)
				_jzf_place_hand(p, hand, index, defense != 0)
				return 0
	_jzf_ai_next()
	return 1

func f5b6630(p: int) -> int:
	return _jzf_scan(p, 0x5dd4c0, 0x5dd850)

func f5b6660(p: int) -> int:
	return _jzf_scan(p, 0x5dd850, 0x5dd858)

func f5b6690(p: int) -> int:
	if _jzf_scan(p, 0x5dd858, 0x5dd8d0) != 0:
		return 1
	for z in range(5):
		var obj := JoeyMem.zone(p, z)
		var index := m.u32(obj) & 0xfff
		if f56b5a0(p, z) == 0:
			continue
		if m.u16(obj + 6) & 2 == 0 and f570a70(p) != 0:
			var id := f4022e0(index) & 0xffff
			var flip := false
			match id:
				0x231, 0x2fa: flip = true
				0x21c, 500, 0x259, 0x280: flip = _s32(f569d50(1 - p)) > 0
				0x53, 0xdf: flip = _s32(f56aa50(1 - p, 0)) + _s32(f56a880(1 - p)) > 0
				0x249, 0x5f1: flip = _s32(f56a320(1 - p, 0, 0, 1)) > 1
				0x24e: flip = m.u8(JoeyMem.pl(p) + 8) < 5
				0x48b, 0x452: flip = _s32(f5afe90(p)) < 0
				0x4e7: flip = _s32(f569bf0(1 - p, 7)) > 0
				0x53a:
					for other in range(5):
						var rival := JoeyMem.zone(1 - p, other)
						if m.u32(rival) & 0xfff and m.u8(rival + 6) & 2 and s16(f4026c0(m.u16(rival) & 0xfff)) == 4:
							flip = true
			if flip:
				f5ad960(p, z)
				return 1
		if m.u16(obj + 6) & 2:
			var id := s16(f4022e0(index))
			if (m.u16(obj + 6) & 1 and id == 0x5e) or (m.u16(obj + 6) & 1 == 0 and id == 0x77):
				if f569d50(1 - p) != 0:
					f575210(p, z, 0, 0, 1)
					return 1
	return 0

func f5b69d0() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	var step := m.u8(0xa579a2)
	if step == 0:
		if _jzf_scan(p, 0x5dd8d0, 0x5dd980) != 0:
			return 0
		_jzf_ai_next()
	elif step != 1:
		if step == 2:
			for hand in range(m.u8(JoeyMem.pl(p) + 8)):
				var index := m.u32(0xa56434 + p * 0xd44 + hand * 4) & 0xfff
				var id := f4022e0(index) & 0xffff
				if id > 0x2d5 and (id < 0x2d9 or id == 0x2fe) and f5aee70(p, index, 1) != 0:
					var options := f5aae00(p, index)
					if options != 0:
						var defense := 1
						if options & 0x400:
							defense = 0 if options & 0x800 == 0 else f5ae270(p, index, 1, 0)
						_jzf_place_hand(p, hand, index, defense != 0)
						return 0
			_jzf_ai_next()
		return 1
	while m.u8(0xa579a1) < m.u8(JoeyMem.pl(p) + 8):
		var hand := m.u8(0xa579a1)
		var index := m.u16(0xa56434 + p * 0xd44 + hand * 4) & 0xfff
		if f570a10(p, index) != 0 and f5b0380(p, index) != 0 and f5685c0(index) == 0:
			var kind := s16(f4025d0(index))
			var accepted := kind == 21 or (kind == 22 and (s16(f402700(index)) == 5 or f5699c0(0x49c) != 0))
			if ((m.u32(0xa56434 + p * 0xd44 + hand * 4) >> 12) & 1) != p:
				accepted = false
			var id := s16(f4022e0(index))
			if id == 0x136 or (id != 0x49b and accepted):
				m.set_u16(0xa57808, m.u16(0xa57808) & 0xff)
				m.set_u16(0xa57802, index)
				m.set_u8(0xa5780e, JoeyMem.ident(m.u32(0xa56434 + p * 0xd44 + hand * 4)))
				m.set_u16(0xa5780a, m.u8(0xa5780a) | (p << 8) | 0x1600)
				m.set_u8(0xa5780c, hand)
				m.set_u32(0xa57804, (m.u32(0xa57804) & 0xffffffa7) | 0x26)
				return 0
		m.set_u8(0xa579a1, m.u8(0xa579a1) + 1)
	_jzf_ai_next()
	return 0

func f5b6e10() -> int:
	f5b9170((m.u16(JoeyMem.TURN) << 15) | 0x52, 0, 0, 0)
	return 1

func f5b6e40(z: int) -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	if f56b5a0(p, z) == 0 or f570a70(p) == 0:
		return 0
	var obj := JoeyMem.zone(p, z)
	var index := m.u32(obj) & 0xfff
	if m.u8(obj + 6) & 2 or f567620(index, 0) == 0:
		return 0
	var id := f4022e0(index) & 0xffff
	match id:
		0x24e: return int(m.u8(JoeyMem.pl(p) + 8) < 6)
		0x53, 0xdf: return int(_s32(f56aa50(1 - p, 0)) + _s32(f56a880(1 - p)) != 0)
		0x249: return int(_s32(f56a320(1 - p, 0, 0, 1)) > 1)
		500, 0x21c, 0x259, 0x280: return int(f569d50(1 - p) != 0)
		0x48b, 0x452: return int(_s32(f5afe90(p)) < 0)
	return 1

func f5b6ff0(p: int, hand: int, defense: int) -> int:
	var index := m.u16(0xa56434 + (p & 1) * 0xd44 + hand * 4) & 0xfff
	if f570a70(p) == 0:
		defense = 1
	var level := f4026c0(index) & 0xffff
	if level == 0:
		return 1
	var tribute := 0
	var dest: int
	if level <= 4:
		dest = f56a030(p)
	elif level <= 6:
		var ref := f5aece0(p, 0xffffffff, index, 0) & 0xffffffff
		if ref == 0xffffffff:
			return 1
		var owner := ref & 255
		var z := (ref >> 8) & 255
		if owner == p and f5b6e40(z) != 0:
			f5ad960(p, z)
			return 0
		dest = z if owner == p and f569e10(p, z) != 0 else f56a030(p)
		if _s32(dest) < 0:
			return 1
		tribute = ((owner << 4) | z | 0x80) & 0xffffffff
	else:
		var ref := f5aece0(p, 0xffffffff, index, 0) & 0xffffffff
		var ref2 := f5aece0(p, ref, index, 0) & 0xffffffff
		if ref == 0xffffffff or ref2 == 0xffffffff:
			return 1
		var owner := ref & 255
		var z := (ref >> 8) & 255
		var owner2 := ref2 & 255
		var z2 := (ref2 >> 8) & 255
		if owner == p and f5b6e40(z) != 0:
			f5ad960(owner, z)
			return 0
		if owner2 == p and f5b6e40(z2) != 0:
			f5ad960(owner2, z2)
			return 0
		if owner == p and f569e10(p, z) != 0:
			dest = z
		elif owner2 == p and f569e10(p, z2) != 0:
			dest = z2
		else:
			dest = f56a030(p)
		if _s32(dest) < 0:
			return 1
		tribute = (((((ref2 & 255) | 0xf8) << 4 | z2) & 255) << 8) | ((((ref & 255) | 0xf8) << 4) & 255) | z
	f5ad740(p, hand, dest, tribute, int(defense == 0))
	f579930(p, 0x11, 1)
	return 1

func _jzf_can_summon(p: int) -> bool:
	return f5ae390(p) != 0 and m.u32(0xa56430 + (p & 1) * 0xd44) & 0x20000 == 0 and (f570a70(p) != 0 or f570ac0(p) != 0)

func f5b72a0() -> int:
	var p := m.u32(JoeyMem.TURN) & 1
	match m.u8(0xa579a2):
		0:
			if m.u16(0xa577f8) == 0:
				return 1
			if not _jzf_can_summon(p) or _s32(f569820(1 - p, 0x15b, 0xffffffff)) > 0:
				_jzf_ai_next()
				return 0
			var hand: int
			if _s32(f5ae9c0(p, 0xffffffff, 1)) < 0:
				hand = _s32(f5b1360(p, 0)) if f5b08b0(p) != 0 else _s32(f5b1360(p, 0xffffffff))
				if hand == -1:
					hand = _s32(f5b1360(p, 0xffffffff))
			else:
				hand = _s32(f5b1360(p, 1))
				if hand == -1:
					hand = _s32(f5b1360(p, 0xffffffff))
			if hand >= 0 and f5b6ff0(p, hand, 0) == 0:
				return 0
		1:
			if f5b08b0(p) != 0:
				return 1
			m.set_u16(0xa579a0, m.u16(0xa579a0) & 0xff)
		2:
			if f5b6690(p) != 0:
				m.set_u16(0xa579a2, m.u16(0xa579a2) & 0xff00)
				return 0
		3:
			if f5b6630(p) != 0:
				m.set_u16(0xa579a2, m.u16(0xa579a2) & 0xff00)
				return 0
		4:
			if not _jzf_can_summon(p):
				_jzf_ai_next()
				return 0
			var hand := _s32(f5b16c0(p))
			if hand < 0:
				return 1
			var index := m.u32(0xa56434 + p * 0xd44 + hand * 4) & 0xfff
			if f5ae270(p, index, 0, 0) != 0:
				return 1
			if f5b6ff0(p, hand, 0) == 0:
				return 0
			m.set_u16(0xa579a2, (m.u16(0xa579a2) & 0xff01) | 1)
			return 0
		_: return 1
	_jzf_ai_next()
	return 0

func f5b75a0() -> int:
	var p := m.u32(JoeyMem.TURN) & 1
	if m.u8(0xa579a2) != 0:
		return 1
	if _jzf_can_summon(p):
		var hand := _s32(f5b16c0(p))
		if hand < 0:
			_jzf_ai_next()
			return 0
		var index := m.u32(0xa56434 + p * 0xd44 + hand * 4) & 0xfff
		if f5b6ff0(p, hand, f5ae270(p, index, 0, 0)) == 0:
			return 0
	_jzf_ai_next()
	return 0

func f5b76c0() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	match m.u8(0xa579a2):
		0:
			if f5b6690(p) == 0:
				m.set_u32(0xa579a0, m.u32(0xa579a0) & 0xffff00ff)
				_jzf_ai_next()
		1:
			while m.u8(0xa579a1) < 5:
				if f5b77f0(p, m.u8(0xa579a1), 0) != 0:
					return 0
				m.set_u8(0xa579a1, m.u8(0xa579a1) + 1)
			_jzf_ai_next()
		2:
			if f5b6690(p) == 0:
				_jzf_ai_next()
		_: return 1
	return 0

func f5b77f0(p: int, z: int, use_rules: int) -> int:
	var turn := m.u8(JoeyMem.TURN) & 1
	var mode: int
	if use_rules == 0:
		f5b08b0(turn)
		mode = int((m.u16(0xa579ac) >> (z & 31)) & 1 != 0) - 1
	else:
		mode = _s32(f5adec0(p, z))
	if f56b5a0(p, z) != 0:
		var flags := m.u16(JoeyMem.zone(turn, z) + 6)
		if mode == 0:
			if flags & 2 == 0:
				if f570a70(turn) != 0 and (f5675f0(m.u16(JoeyMem.zone(turn, z)) & 0xfff) == 0 or (f570b40(turn) != 0 and f569cb0(turn) != 0)):
					f5ad960(turn, z)
					return 1
			elif flags & 1:
				f575210(turn, z, 0, 0, 1)
				return 1
		elif mode == 1 and flags & 1 == 0:
			f575210(turn, z, 0, 0, 1)
			return 1
	return 0

func f5b7960() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	match m.u8(0xa579a2):
		0:
			if f5b6690(p) == 0:
				m.set_u32(0xa579a0, m.u32(0xa579a0) & 0xffff00ff)
				_jzf_ai_next()
			return 0
		1:
			while m.u8(0xa579a1) < 5:
				if f5b77f0(p, m.u8(0xa579a1), 1) != 0:
					return 0
				m.set_u8(0xa579a1, m.u8(0xa579a1) + 1)
			_jzf_ai_next()
			return 0
	return 1

func f5b7a50() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	match m.u8(0xa579a2):
		0:
			m.set_u16(0xa55d70 + p * 0xd44, 0)
			if f5a0dd0(p) == 0 or f5b1310(p) == 0:
				return 1
			if f5b6660(p) != 0:
				return 0
			m.set_u16(JoeyMem.TURN, m.u16(JoeyMem.TURN) & 0xff)
			m.set_u16(0xa577fc, m.u16(0xa577fc) & 0xff00)
		1:
			if f5a4090(p) == 0:
				return 0
		2:
			f5b9170((m.u16(JoeyMem.TURN) << 15) | 0x54, 0, 0, 0)
			return 1
		_: return 0
	_jzf_ai_next()
	return 0

func f5b7b50() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	var handler := m.u32(0x5efb50 + m.u8(0xa579a0) * 4)
	if m.u32(0xa56430 + p * 0xd44) & 0x800000 or handler == 0:
		return 1
	if int(callv("f%06x" % handler, [])) != 0:
		m.set_u32(0xa579a0, m.u32(0xa579a0) & 0xff0000ff)
		m.set_u8(0xa579a0, m.u8(0xa579a0) + 1)
	return 0

func f5b7bd0() -> int:
	if m.u16(0xa577fe) == 0:
		f5bddf0(0xa579a0, 0x5b4)
	var handler := m.u32(0x5efb78 + m.u8(0xa577fe) * 4)
	if handler != 0:
		if int(callv("f%06x" % handler, [])) != 0:
			m.set_u32(0xa577fe, m.u32(0xa577fe) & 0xffff00ff)
			m.set_u8(0xa577fe, m.u8(0xa577fe) + 1)
		return 0
	m.set_u32(0xa577fe, m.u32(0xa577fe) & 0xffffff00)
	return 1
