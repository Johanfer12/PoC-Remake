class_name JoeyPortZE
extends JoeyPortZD
## Etapa 5: IA central 5b1610..5b3fa0. Fuentes C y ASM del ejecutable Joey.
## Los predicados leen el descriptor nativo de 20 bytes; no sustituyen efectos E.


func _je_p(at: int) -> int:
	return m.u8(at + 2) & 1


func _je_local(index: int, p: int, z: int, entry: int) -> int:
	var at := m.local(20)
	m.set_u16(at, index)
	m.set_u16(at + 2, (p & 1) | ((z & 0x1f) << 1))
	m.set_u16(at + 4, JoeyMem.ident(entry) << 5)
	return at


func _je_chosen(p: int, z: int, index: int, entry: int, hand: bool = false) -> void:
	m.set_u16(0xa57808, m.u16(0xa57808) & 0xff)
	m.set_u16(0xa57802, index)
	m.set_u8(0xa5780e, JoeyMem.ident(entry))
	var high := 0x1600 if hand else (z / 5) * 0xa00
	m.set_u16(0xa5780a, (m.u16(0xa5780a) & 0xff | ((p & 1) << 8)) ^ high)
	m.set_u8(0xa5780c, z if hand else z % 5)
	m.set_u32(0xa57804, (m.u32(0xa57804) & 0xffffff9f) | 0x1a)


func f5b1610(p: int, index: int, count: int, refs: int) -> int:
	for i in range(maxi(0, count)):
		m.clear(JoeyMem.zone(m.u8(refs + i * 2), m.u8(refs + i * 2 + 1)), 0x90)
	var z := _s32(f56a030(p))
	var at := JoeyMem.zone(p, z)
	m.set_u32(at, m.u32(at) ^ ((m.u32(at) ^ index) & 0xfff))
	m.set_u16(at + 6, (m.u16(at + 6) & 0xfffe) | 2)
	return z


func f5b16c0(p: int) -> int:
	var best_field := _s32(f5ae9c0(p, 0xffffffff, 1))
	if best_field == -1 and f56a000(p):
		var q := 1 - p
		if _s32(f569d50(q)) > 0:
			for id in [500, 0x21c]:
				var hand := f56d340(p, id)
				if _s32(hand) >= 0:
					return hand
		for pair in [[0x16, 0x1ab], [0x15, 0x65]]:
			if _s32(f56a8e0(p, pair[0])) > 0:
				var hand := f56d340(p, pair[1])
				if _s32(hand) >= 0:
					return hand
		var own_hand := m.u8(JoeyMem.pl(p) + 8)
		if own_hand < 3 or own_hand + 2 < m.u8(JoeyMem.pl(q) + 8):
			for id in [0x21b, 0x24e]:
				var hand := f56d340(p, id)
				if _s32(hand) >= 0:
					return hand
		for pair in [[0x15b, 0x246], [0x148, 0x27]]:
			if _s32(f5699a0(q, pair[0])) > 0:
				var hand := f56d340(p, pair[1])
				if _s32(hand) >= 0:
					return hand
		if _s32(f56a320(q, 0, 0, 1)) > 1:
			var hand := f56d340(p, 0x109)
			if _s32(hand) >= 0:
				return hand
		if _s32(f56aa50(q, 0)) > 1:
			var hand := f56d340(p, 0x249)
			if _s32(hand) >= 0:
				return hand
		if _s32(f56aa50(q, 0)) > 0:
			var hand := f56d340(p, 0xdf)
			if _s32(hand) >= 0:
				return hand
		if _s32(f5afe90(p)) < 0:
			for id in [0x48b, 0x452]:
				var hand := f56d340(p, id)
				if _s32(hand) >= 0:
					return hand
	var opponent := 0
	for z in range(5):
		opponent = maxi(opponent, _s32(f56f690(1 - p, z)))
	var best := _s32(f5affd0(p, p, 0xffffffff, 1, 0))
	var chosen := -1
	for i in range(m.u8(JoeyMem.pl(p) + 8)):
		var index := m.u16(JoeyMem.pl(p) + 0x6d4 + i * 4) & 0xfff
		var value := maxi(f402800(index) & 0xffff, f4027b0(index) & 0xffff)
		if f5aab90(p, index) and f5ae3e0(p, 2, f4022e0(index)) == 0:
			if (best < value and opponent <= value) or (best_field != -1 and (f4026c0(index) & 0xffff) > 4):
				if ((f4026c0(index) & 0xffff) > 4 or f56a000(p)) and f5aee70(p, index, 0):
					chosen = i
					best = value
	if chosen >= 0:
		return chosen
	if f56a000(p):
		var danger := f5b3d30(p)
		for i in range(m.u8(JoeyMem.pl(p) + 8)):
			var index := m.u16(JoeyMem.pl(p) + 0x6d4 + i * 4) & 0xfff
			if (f4026c0(index) & 0xffff) < 5 and f5aab90(p, index):
				if f5ae3e0(p, 2 - int(danger != 0), f4022e0(index)) == 0:
					return i
	return 0xffffffff


func f5b1b50(at: int) -> int:
	return (m.u16(at + 2) ^ m.u16(JoeyMem.TURN)) & 1


func f5b1b70(at: int) -> int:
	return int(m.u16(JoeyMem.pl(1 - _je_p(at)) + 4) <= m.u16(at + 0x12) or m.u16(at + 0x12) <= m.u16(at + 0x10))


func f5b1bb0(at: int) -> int:
	var q := 1 - _je_p(at)
	for z in range(5, 10):
		var card := m.u32(JoeyMem.zone(q, z)) & 0xfff
		if card and m.u8(JoeyMem.zone(q, z) + 6) & 2 and f598b50(q, z, card):
			return 1
	return 0


func f5b1c30(at: int) -> int:
	for i in range((m.u32(0xa55c94) >> 8) & 0x7f):
		var event := m.u32(0xa55ca8 + i * 4)
		if m.u8(0xa55c96 + i) == 0x15:
			var ref := f5687d0(event & 0xff)
			if ref != 0x1000:
				var card := m.u32(f5700f0(ref & 0xff, (ref >> 8) & 0xff, ref >> 16))
				if (event >> 8) & 1 == _je_p(at) and (f4026c0(card & 0xfff) & 0xffff) > 4:
					return 1
				if s16(f4022e0(card & 0xfff)) in [0x2f, 0x23d] and (card >> 12) & 1 == _je_p(at):
					return 1
	return 0


func f5b1d30(at: int) -> int:
	return int(_s32(f569d50(1 - _je_p(at))) > 0)


func f5b1d60(at: int) -> int:
	var attribute := 0
	var q := 1 - _je_p(at)
	for z in range(5):
		var card := m.u32(JoeyMem.zone(q, z)) & 0xfff
		if card and m.u8(JoeyMem.zone(q, z) + 6) & 2:
			var value := f402650(card) & 0xffff
			if value != attribute and value < 7:
				if attribute != 0:
					return 1
				attribute = value
	return 0


func f5b1e00(at: int) -> int:
	var p := _je_p(at)
	return int(not (_s32(f5aef10(p)) < 2 and m.u16(JoeyMem.pl(p) + 4) > 1000 and m.u16(at + 0x10) < 1500))


func f5b1e50(at: int) -> int:
	var p := _je_p(at)
	if m.u8(JoeyMem.TURN) & 1 == 1 - p and m.u8(JoeyMem.TURN) & 0xe == 0:
		if _s32(f5afe90(p)) < 1 and f569d90(1 - p, 1, 1):
			return 1
	return 0


func f5b1eb0(at: int) -> int:
	return int(_s32(f569d50(_je_p(at))) < _s32(f569d50(1 - _je_p(at))))


func f5b1ef0(at: int) -> int:
	return f56ce40(1 - _je_p(at), 1)


func f5b1f10(at: int) -> int:
	if m.u8(JoeyMem.TURN) & 0xe == 10:
		for z in range(5, 11):
			var zone := JoeyMem.zone(1 - _je_p(at), z)
			if m.u32(zone) & 0xfff and m.u8(zone + 7) & 4 == 0:
				return 1
	return 0


func f5b1f70(at: int) -> int:
	var p := _je_p(at)
	var out := m.local(8)
	f5aff10(1 - p, out, out + 4, 1)
	var score := _s32(m.u32(out))
	var life := m.u16(JoeyMem.pl(p) + 4)
	var enemy := m.u16(JoeyMem.pl(1 - p) + 4)
	if score >= 0 and score < life:
		if enemy <= score or (score > 1499 and enemy - score < life):
			return 1
	f5aff10(p, out, out + 4, 1)
	score = _s32(m.u32(out))
	return int(score >= 0 and score < life and enemy <= score)


func f5b2090(at: int) -> int:
	var p := _je_p(at)
	if m.u16(JoeyMem.pl(1 - p) + 4) <= _s32(f569d50(1 - p)) * 500:
		return 1
	return int(_s32(f569d50(1 - p)) > 1)


func f5b2110(at: int) -> int:
	var p := _je_p(at)
	if _s32(f569d90(1 - p, 0, 0)) + _s32(f569d90(p, 0, 0)) > 2:
		return f5aef10(p)
	return 0


func f5b2160(at: int) -> int:
	var count := 0
	for p in range(2):
		for z in range(5):
			var card := m.u32(JoeyMem.zone(p, z)) & 0xfff
			if card and f567990(card):
				count += 1
	var p := _je_p(at)
	if m.u16(JoeyMem.pl(1 - p) + 4) <= count * 500:
		return 1
	count = 0
	for z in range(5):
		var enemy := JoeyMem.zone(1 - p, z)
		if m.u32(enemy) & 0xfff and m.u8(enemy + 6) & 2 == 0:
			count += 1
		var own := JoeyMem.zone(p, z)
		if m.u32(own) & 0xfff and m.u8(own + 6) & 2 == 0 and f567620(m.u16(own) & 0xfff, 0xffffffff):
			return 0
	return int(count > 0)


func f5b22a0(at: int) -> int:
	var p := _je_p(at)
	for z in range(5):
		var zone := JoeyMem.zone(p, z)
		if m.u32(zone) & 0xfff and m.u8(zone + 6) & 2 and _s32(f56aa70(p, z)) > 0:
			return 1
	return 0


func f5b2310(at: int) -> int:
	for i in range((m.u32(0xa55c94) >> 8) & 0x7f):
		var kind := m.u8(0xa55c96 + i)
		var ref := m.u16(0xa55ca8 + i * 4)
		var p := (ref >> 8) & 1
		var z := (ref >> 9) & 15
		if kind > 4 and kind < 8 and p != _je_p(at):
			if m.u8(JoeyMem.zone(p, z) + 6) & 2 and f56c510(p, z):
				if _s32(f56f690(p, z)) < 2001 and f569300(p, f4022e0(m.u16(JoeyMem.zone(p, z)) & 0xfff)):
					return 1
	return 0


func f5b2450(at: int) -> int:
	for i in range((m.u32(0xa55c94) >> 8) & 0x7f):
		var kind := m.u8(0xa55c96 + i)
		if kind > 4 and kind < 8 and _je_p(at) == m.u8(0xa55ca9 + i * 4) & 1:
			return 0
	return int(_s32(f5afe90(_je_p(at))) < 0)


func f5b24c0(at: int) -> int:
	var p := _je_p(at)
	var maximum := 0
	for z in range(5):
		maximum = maxi(maximum, _s32(f56f690(p, z)))
		maximum = maxi(maximum, _s32(f56f6b0(p, z)))
	for z in range(5):
		if m.u8(JoeyMem.zone(1 - p, z) + 6) & 2 and maximum < _s32(f56f690(1 - p, z)):
			return 1
	return 0


func f5b2580(at: int) -> int:
	var p := _je_p(at)
	var count := _s32(f56cdc0(p))
	if count:
		for z in range(5):
			var zone := JoeyMem.zone(1 - p, z)
			var card := m.u16(zone) & 0xfff
			if card and m.u8(zone + 6) & 2:
				var level := f4026c0(card) & 0xffff
				if level != 0 and level <= count:
					return 1
	return 0


func f5b2620(at: int) -> int:
	return ((~m.u16(at + 2)) & 1) ^ (m.u8(JoeyMem.TURN) & 1)


func f5b2640(at: int) -> int:
	if m.u16(at + 2) & 0xfc0 != 0x480:
		return 0
	var p := _je_p(at)
	var battle := m.u16(JoeyMem.BATTLE)
	var attacker := battle & 1
	var defender := (battle >> 1) & 1
	var az := (battle >> 8) & 7
	var dz := (battle >> 11) & 7
	var direct := dz > 4
	var attack := _s32(f56f690(attacker, az))
	var defense := 0
	if not direct:
		defense = _s32(f56f6b0(defender, dz) if m.u8(JoeyMem.zone(defender, dz) + 6) & 1 else f56f690(defender, dz))
	var id := f4022e0(m.u16(at)) & 0xffff
	var enemy_attacking := attacker == 1 - p
	match id:
		0x2ad, 0x3de:
			return int(enemy_attacking)
		0x3c0:
			if not enemy_attacking:
				return 0
			return int((m.u16(JoeyMem.pl(p) + 4) <= attack if direct else defense <= attack) or attack >= 1500)
		0x3b1:
			if not enemy_attacking or direct:
				return 0
			if f567620(m.u32(JoeyMem.zone(defender, dz)) & 0xfff, 0xffffffff) == 0:
				return int(attack >= defense and defense >= 1800)
			return (m.u8(JoeyMem.zone(defender, dz) + 6) >> 1) & 1
		0x28a:
			return int(enemy_attacking and not direct and attack >= defense and f569d90(p, 1, 0) != 0)
		0x15c, 0x44a:
			if id == 0x44a and f5aef10(p) == 0:
				return 0
			if not enemy_attacking:
				return 0
			if f5699a0(p, 0x15c):
				return 1
			if direct:
				return int(attack >= m.u16(JoeyMem.pl(p) + 4))
			var local := m.local(8)
			f5aff10(1 - p, local, local + 4, 1)
			return int(attack == _s32(m.u32(local)))
		0x52b:
			return int(enemy_attacking and (f4026c0(m.u16(JoeyMem.zone(attacker, az)) & 0xfff) & 0xffff) > 3)
		0x4be:
			if enemy_attacking:
				if m.u16(JoeyMem.pl(1 - p) + 4) <= attack or attack > 1499:
					return 1
				return int(m.u16(JoeyMem.pl(p) + 4) <= attack if direct else defense <= attack)
		0x447, 0x4dd, 0x76e:
			return int(enemy_attacking and direct and f569d50(p) == 0)
		0x525:
			if enemy_attacking and not direct and defense <= attack:
				for z in range(5):
					var zone := JoeyMem.zone(p, z)
					if z != dz and m.u32(zone) & 0xfff and m.u8(zone + 6) & 1 == 0 and attack < _s32(f56f690(p, z)):
						return 1
		0x5f9:
			if not enemy_attacking or direct or attack < defense:
				return 0
			for z in range(5):
				var zone := JoeyMem.zone(1 - p, z)
				if z != az and m.u32(zone) & 0xfff and m.u8(zone + 6) & 2 and _s32(f56f690(1 - p, z)) < defense:
					return 1
		0x41f, 0x420, 1099, 0x590:
			if enemy_attacking:
				if direct:
					if m.u16(JoeyMem.pl(p) + 4) <= attack:
						return 1
					if attack < 1500:
						f569d90(1 - p, 1, 1)
					return 1
				if defense <= attack or f5b3d30(p):
					return 1
	return 0


func f5b2e60(at: int) -> int:
	if m.u16(at + 2) & 0xfc0 != 0x4c0:
		return 0
	var p := _je_p(at)
	var battle := m.u16(JoeyMem.BATTLE)
	var ap := battle & 1
	var dp := (battle >> 1) & 1
	var az := (battle >> 8) & 7
	var dz := (battle >> 11) & 7
	f56f690(ap, az)
	if dz < 5:
		if m.u8(JoeyMem.zone(dp, dz) + 6) & 1:
			f56f6b0(dp, dz)
		else:
			f56f690(dp, dz)
	var attack_bonus := 0
	var defense_bonus := 0
	match f4022e0(m.u16(at)) & 0xffff:
		0x3f7: attack_bonus = 500
		0x3f8: defense_bonus = 500
		0x433: attack_bonus = 700
		0x434: defense_bonus = 700
		0x43a: defense_bonus = -500
		0x587: attack_bonus = -700
		0x4b3:
			attack_bonus = 400
			defense_bonus = 400
		0x4b4:
			attack_bonus = -400
			defense_bonus = -400
		0x5fe: attack_bonus = _s32(f56cdc0(p))
	if dz < 5:
		if ap != dp and (attack_bonus != 0 or defense_bonus != 0):
			if p == dp:
				var position := m.u8(JoeyMem.zone(p, dz) + 6) & 1
				var other := _s32(f56f690(1 - p, az))
				var own := _s32(f56f6b0(p, dz) if position else f56f690(p, dz))
				var reduction := maxi(0, -attack_bonus)
				var increase := maxi(0, defense_bonus if position else attack_bonus)
				return int(own < other and other <= _s32(reduction + increase + own))
			var position := m.u8(JoeyMem.zone(1 - p, dz) + 6) & 1
			var own := _s32(f56f690(p, az))
			var other := _s32(f56f6b0(1 - p, dz) if position else f56f690(1 - p, dz))
			if position == 0:
				defense_bonus = attack_bonus
			return int(own <= other and _s32(maxi(0, -defense_bonus) + maxi(0, attack_bonus) + other) < own)
	else:
		var count := 0
		for z in range(5):
			count = _s32(count + f56b730(ap, z, 1))
		if count > 1:
			var id := s16(f4022e0(m.u16(at)))
			if id == 0x4b3:
				return int(p == ap)
			if id == 0x4b4:
				return int(p == dp)
	return 0


func f5b3210(at: int, target: int) -> int:
	if target and (_je_p(at) ^ _je_p(target)):
		var kind := f402700(m.u16(target)) & 0xffff
		return int(kind > 1 and kind < 5)
	return 0


func f5b3250(at: int, target: int) -> int:
	if target and (_je_p(at) ^ _je_p(target)) and s16(f4022e0(m.u16(target))) == 0x1ab:
		m.set_u16(0xa579a4, m.u16(target + 6) & 0xfff)
		return 1
	return 0


func f5b32a0(at: int, target: int) -> int:
	if target == 0 or _je_p(at) == _je_p(target):
		return 0
	var id := f4022e0(m.u16(target)) & 0xffff
	if id in [0x3ec, 0x3f1, 0x437, 0x446, 0x46e, 0x46f, 0x486, 0x609]:
		var ref := f583440(target, 0)
		var card := s16(f4022e0(m.u16(JoeyMem.zone(ref & 1, (ref >> 8) & 0xff)) & 0xfff))
		return int(card not in [0x136, 0x405])
	if id in [0x151, 0x152, 0x153, 0x154, 0x155, 0x3ee]:
		return 0
	if id in [0x156, 0x157, 0x158, 0x159, 0x15a, 0x3ef, 0x40f]:
		return int(m.u16(JoeyMem.pl(_je_p(at)) + 4) <= 1000)
	return 1


func f5b3400(at: int, target: int) -> int:
	return f5b32a0(at, target) if target and s16(f4025d0(m.u16(target))) == 0x16 else 0


func f5b3440(at: int, target: int) -> int:
	return f5b32a0(at, target) if target and s16(f4025d0(m.u16(target))) == 0x15 else 0


func f5b3480(at: int, target: int) -> int:
	if target == 0:
		return 0
	var id := f4022e0(m.u16(target)) & 0xffff
	if id in [0x425, 0x426, 0x29f, 0x42b]:
		return 1
	if id == 0x249:
		for i in range(2):
			var ref := f583440(target, i)
			if ref & 0xff == _je_p(at) and (ref >> 8) & 0xff == (m.u16(at + 2) >> 1) & 0x1f:
				return 1
		return 0
	if id in [0x53, 0xdf, 0x1d4, 0x3ec, 0x3f1, 0x437, 0x446, 0x46e, 0x46f, 0x486, 0x609]:
		var ref := f583440(target, 0)
		return int(ref & 0xff == _je_p(at) and (ref >> 8) & 0xff == (m.u16(at + 2) >> 1) & 0x1f)
	return 0


func f5b35a0(at: int, target: int) -> int:
	return f5b3480(at, target) if target and f59dd20(at, _je_p(at)) else 0


func f5b35e0(at: int, target: int) -> int:
	return f5b3480(at, target) if target and f59dd20(at, 1 - _je_p(at)) else 0


func f5b3620(p: int, row: int, target: int) -> int:
	var index := f402460(m.u16(row)) & 0xffff
	if f598c40(p, 5, index):
		return 0
	for i in range(m.u16(0xa55c80)):
		if m.u8(0xa55b42 + i * 20) & 1 == p and m.u16(0xa55b40 + i * 20) == index:
			return 0
	var predicate := m.u32(row + 4)
	if f402690(index) == 0:
		for z in range(5, 11):
			var zone := JoeyMem.zone(p, z)
			var entry := m.u32(zone)
			if entry & 0xfff == index:
				var local := _je_local(index, p, z, entry)
				var allowed := f57e490(local, target) if m.u8(zone + 6) & 2 else f57e650(local, target)
				if allowed and _jy_effect(predicate, [local, target]):
					_je_chosen(p, z, index, m.u32(zone))
					return 1
		var hand := _s32(f56d340(p, m.u16(row)))
		if hand >= 0:
			var zone := JoeyMem.pl(p) + 0x6d4 + hand * 4
			var local := _je_local(index, p, 11, m.u32(zone))
			if f57e650(local, target) and _jy_effect(predicate, [local, target]):
				_je_chosen(p, hand, index, m.u32(zone), true)
				return 1
	else:
		for z in range(5):
			var zone := JoeyMem.zone(p, z)
			var entry := m.u32(zone)
			if entry & 0xfff == index and m.u8(zone + 6) & 2:
				var local := _je_local(index, p, z, entry)
				if f57e490(local, target) and _jy_effect(predicate, [local, target]):
					_je_chosen(p, z, index, m.u32(zone))
					return 1
	return 0


func f5b3b50(p: int) -> int:
	for row in range(0x5dd0a8, 0x5dd308, 8):
		if f5b3620(p, row, 0):
			return 1
	return 0


func f5b3b90(p: int, target: int) -> int:
	var bits := m.u16(target + 2)
	if (((bits >> 14) & 1) ^ (bits & 1)) == p and f402690(m.u16(target)) == 0 and s16(f4022e0(m.u16(target))) != 0x590:
		return 0
	for row in range(0x5dd308, 0x5dd3c8, 8):
		if f5b3620(p, row, target):
			return 1
	for row in range(0x5dd0a8, 0x5dd308, 8):
		if f5b3620(p, row, target):
			return 1
	return 0


func f5b3c30(p: int, id: int) -> int:
	for z in range(5, 10):
		var entry := m.u32(JoeyMem.zone(p, z))
		if entry & 0xfff:
			var local := _je_local(entry & 0xfff, p, 0, entry)
			if s16(f4022e0(entry & 0xfff)) == s16(id) and f57e160(local, p, p, z):
				return 1
	return 0


func f5b3d30(p: int) -> int:
	var own := _s32(f5b0330(p, p))
	var other := _s32(f5b0330(p, 1 - p))
	return int(m.u16(JoeyMem.pl(p) + 4) <= _s32(other - own))


func f5b3d80(at: int, p: int, attack: int, defense: int, exclude: int) -> int:
	attack = _s32(attack)
	defense = _s32(defense)
	exclude = _s32(exclude)
	var row := _s32(f59dbe0(m.u16(at)))
	var value := -1
	var chosen := -1
	var out := m.local(12)
	for z in range(5):
		if z == exclude or m.u32(JoeyMem.zone(p, z)) & 0xfff == 0:
			continue
		if row >= 0:
			var callback := m.u32(0x5ed0b0 + row * 24)
			if callback and _jy_effect(callback, [at, ((z & 0xff) << 8) | (p & 0xff)]) == 0:
				continue
		f56dd30(p, z, out)
		var score := _s32(m.u32(out + 8)) if defense != 0 else 0
		if attack != 0:
			score = _s32(m.u32(out + 4)) if defense == 0 else maxi(_s32(m.u32(out + 4)), _s32(m.u32(out + 8)))
		if value < 0:
			value = score
			chosen = z
		else:
			if (attack > 0 and value < score) or (attack < 0 and score < value) or (defense > 0 and value < score) or (defense < 0 and score < value):
				if (attack > 0 and value < score) or (attack < 0 and score < value) or (defense > 0 and value < score):
					value = score
				chosen = z
				if defense < 0 and score < value:
					value = score
	return chosen


func f5b3ef0(at: int, p: int) -> int:
	var zones: Array[int] = []
	for z in range(11):
		zones.append(z)
	for i in range(10, 0, -1):
		var j := f5bddb0(i + 1)
		var temp := zones[i]
		zones[i] = zones[j]
		zones[j] = temp
	for side in range(2):
		for z in zones:
			if f59dc50(at, p, z):
				f592a90(at, p, z)
				return 1
		p ^= 1
	return 0


func _je_target(at: int, p: int, z: int) -> int:
	f592a90(at, p, z)
	return 1


func f5b3fa0(at: int, _target: int, mode: int) -> int:
	m.set_u16(at + 4, m.u16(at + 4) & 0x1fff)
	if f59dca0(at) == 0:
		return 1
	mode = _s32(mode)
	var p := _je_p(at)
	var q := 1 - p
	if mode == 0x4de:
		var value := -1
		var chosen := -1
		for z in range(5):
			var index := m.u32(JoeyMem.zone(q, z)) & 0xfff
			if index and f59dc50(at, q, z):
				var stat := f4027b0(index) & 0xffff
				if value < stat:
					value = stat
					chosen = z
		if chosen >= 0:
			return _je_target(at, q, chosen)
	elif mode == 0x413:
		var maximum := 0
		for z in range(5):
			var zone := JoeyMem.zone(p, z)
			if m.u32(zone) & 0xfff and m.u8(zone + 6) & 1 == 0:
				var stat := _s32(f56f690(p, z))
				if maximum <= stat:
					maximum = _s32(f56f690(p, z))
		if maximum == 0:
			maximum = _s32(f5affd0(p, p, 0xffffffff, 1, 0))
		m.set_u16(at + 4, m.u16(at + 4) & 0x1fff)
		var out := m.local(12)
		for z in range(5):
			if f59dc50(at, q, z):
				f56dd30(q, z, out)
				if maximum <= _s32(m.u32(out + 4)) and _s32(m.u32(out + 8)) < maximum:
					return _je_target(at, q, z)
	elif mode == 0x430:
		return f5b3ef0(at, p)
	elif mode == 0x5f9:
		var chosen := _s32(f5b3d80(at, q, 0xffffffff, 1, 0xffffffff))
		if chosen >= 0:
			return _je_target(at, q, chosen)
	elif mode == 0x3f7:
		var id := f4022e0(m.u16(at)) & 0xffff
		if id in [0x3f7, 0x433, 0x5fe, 0x3f8, 0x434]:
			var chosen := m.u8(at + 0x11) if m.u8(at + 0x10) == p else m.u8(at + 0x13)
			var defense := m.u8(JoeyMem.zone(p, chosen) + 6) & 1 != 0
			if defense == (id in [0x3f8, 0x434]) and f59dc50(at, p, chosen):
				return _je_target(at, p, chosen)
			return f5b3ef0(at, p)
		if id == 0x43a:
			var chosen := m.u8(at + 0x11) if m.u8(at + 0x10) == q else m.u8(at + 0x13)
			if m.u8(JoeyMem.zone(q, chosen) + 6) & 1 and f59dc50(at, q, chosen):
				return _je_target(at, q, chosen)
	elif mode == 500:
		var side := q
		var chosen := _s32(f5b3d80(at, side, 1, 1, 0xffffffff))
		if chosen < 0:
			side = 1 - side
			chosen = _s32(f5b3d80(at, side, 0xffffffff, 0xffffffff, 0xffffffff))
		if chosen >= 0:
			return _je_target(at, side, chosen)
	elif mode == 0x3ab:
		var side := q
		var chosen := _s32(f5b3d80(at, side, 1, 0, 0xffffffff))
		if chosen < 0:
			side = 1 - side
			chosen = _s32(f5b3d80(at, side, 1, 0, 0xffffffff))
		if chosen >= 0:
			return _je_target(at, side, chosen)
	elif mode == 0x1d4:
		for priority in range(3):
			for z in range(5, 11):
				var zone := JoeyMem.zone(q, z)
				var index := m.u32(zone) & 0xfff
				if index == 0:
					continue
				var flags := m.u16(zone + 6)
				var status := m.u8(zone + 0x8c)
				var eligible := false
				if priority == 0 and status & 2:
					var kind := f402700(index) & 0xffff
					eligible = kind > 1 and kind < 5
				elif priority == 1:
					eligible = flags & 2 != 0 and status & 2 == 0
				elif priority == 2 and flags & 2 == 0:
					eligible = flags & 0x400 == 0 or _s32(f57e0c0(index)) < 2
				if eligible and f59dc50(at, q, z):
					return _je_target(at, q, z)
	elif mode == 0x5e:
		var chosen := -1
		if s16(f4022e0(m.u16(at))) == 0x15c:
			chosen = m.u8(at + 0x13) if p == m.u8(at + 0x10) else m.u8(at + 0x11)
		else:
			chosen = _s32(f5b3d80(at, q, 1, 0, 0xffffffff))
		if chosen >= 0:
			return _je_target(at, q, chosen)
	elif mode == 300:
		var side := p
		var id := f4022e0(m.u16(at)) & 0xffff
		if id in [0x4e9, 0x4ea, 0x416, 0x417, 0x58b, 0x60c]:
			side = q
		elif id == 0x290 and m.u16(JoeyMem.pl(p) + 4) > m.u16(JoeyMem.pl(q) + 4):
			side = q
		var chosen := _s32(f5b0150(at, side, 0xffffffff, 1))
		if chosen >= 0:
			return _je_target(at, side, chosen)
		chosen = _s32(f5b0150(at, 1 - side, 0xffffffff, 1))
		if chosen >= 0:
			return _je_target(at, 1 - side, chosen)
	return f5b3ef0(at, q)
