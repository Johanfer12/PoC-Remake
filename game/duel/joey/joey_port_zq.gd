class_name JoeyPortZQ
extends JoeyPortZP
## Etapa 6: resoluciones y selecciÃ³n nativa de efectos (590000-597fff).


func _zq_owner(e: int) -> int:
	return m.u8(e + 2) & 1


func _zq_cpu(e: int) -> bool:
	return ((m.u32(0xa54e5c) >> (1 + _zq_owner(e))) & 1) != 0


func _zq_zone(e: int) -> int:
	var ref := m.u16(e + 2)
	return JoeyMem.zone(ref & 1, (ref >> 1) & 31)


func _zq_live(target: int, face: int = -1) -> bool:
	var at := JoeyMem.zone(target & 1, (target >> 8) & 255)
	return (m.u32(at) & 0xfff) != 0 and (face < 0 or ((m.u8(at + 6) >> 1) & 1) == face)


func _zq_choose(e: int, target: int, card: int) -> int:
	if _zq_cpu(e): return f5b3fa0(e, target, card)
	return f593440(e, target)


func f590010(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0:
		var ref := m.u16(e + 2)
		if (m.u32(_zq_zone(e)) & 0xfff) == m.u16(e) and (ref & 0x3000) == 0x1000:
			f578b60(ref & 1, 1)
	return 0


func f590410(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0: return 0
	var mask := 0
	for order in 2:
		var p := (m.u8(0xa577fa) & 1) ^ order
		for z in 5:
			if f57c2b0(e, (z << 8) | p) != 0: mask |= 1 << (p * 16 + z)
	f576940(e, mask)
	return 0


func f590640(e: int) -> int:
	var ref := m.u16(e + 2)
	if (m.u32(_zq_zone(e)) & 0xfff) == m.u16(e):
		f5747e0(ref & 1, m.u16(e), (ref & 1) | (((ref >> 1) & 31) << 8), (m.u8(e + 6) << 8) | 0x1c)
	return 0


func f5906b0(e: int) -> int:
	var p := _zq_owner(e)
	var slot := (m.u16(e + 4) >> 5) & 255
	if _s32(f568ad0(p, slot)) < 0 or _s32(f56a400(p)) == -1: return 0
	if f583470(e, 0, 0) != 0:
		var target := f583440(e, 0)
		if (target & 255) != p and _zq_live(target, 1):
			var dest := f56a400(p)
			f576110(p, 14, slot, p, dest, 1, 0)
			f574990(p, ((dest & 255) << 8) | p, target & 0xffff)
	return 0


func f5907d0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0: return 0
	if f583470(e, 0, 0) != 0:
		var target := f583440(e, 0)
		if _zq_live(target, 1):
			f579990(target & 255, (target >> 8) & 255, 17, 1)
			f5751e0(e, target & 255, (target >> 8) & 255, 0, 0)
	return 0


func f5909a0(e: int) -> int:
	var flags := m.u16(e + 4)
	if (flags & 4) == 0 and (flags & 0xe000) == 0x4000:
		var mask := 0
		var i := 0
		while i < (m.u16(e + 4) >> 13):
			var target := f583440(e, i)
			if f583470(e, i, 0) != 0: mask |= 1 << ((((target >> 8) & 255) + (target << 4)) & 31)
			i += 1
		f577a40(e, mask)
	return 0


func f590b60(e: int) -> int:
	var ref := m.u16(e + 2)
	var shift := (ref & 1) * 16
	f576940(e, (~(1 << (((ref >> 1) & 31) + shift))) & (31 << shift))
	return 0


func f591210(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0: return 0
	if f583470(e, 0, 0) != 0:
		var target := f583440(e, 0)
		if _zq_live(target, 1):
			var counter := f56cdc0(_zq_owner(e))
			f5747e0(_zq_owner(e), m.u16(e), target, ((counter & 255) << 8) | 12)
	return 0


func f5912b0(e: int) -> int:
	if f583470(e, 0, 0) != 0:
		var target := f583440(e, 0)
		f577990(e, target & 255, (target >> 8) & 255)
	return 0


func f5916e0(e: int, target: int) -> int:
	if (m.u16(e + 2) & 0x3000) != 0x1000: return f584a90(e)
	if (m.u32(_zq_zone(e)) & 0xfff) != m.u16(e): return 0
	return f5921c0(e, target)


func f591890(e: int) -> int:
	if (m.u8(e + 4) & 4) == 0: f579790(_zq_owner(e), m.u16(e), 3)
	return 0


func f592040(card: int) -> int:
	var i := 0
	while i < ((m.u32(0xa55d3c) >> 24) & 3):
		var used := m.u16(0xa55d40 + i * 2)
		if used != 0:
			var id1 := f4022e0(used) & 0xffff
			var id2 := f4022e0(card) & 0xffff
			if id1 > 1999: id1 -= 2000
			if id2 > 1999: id2 -= 2000
			if id1 == id2: return 1
		i += 1
	return 0


func f5920d0(card: int) -> int:
	var i := 0
	while i < ((m.u32(0xa55d3c) >> 24) & 3):
		var used := m.u16(0xa55d40 + i * 2)
		if used != 0:
			var id1 := f4022e0(used) & 0xffff
			var id2 := f4022e0(card) & 0xffff
			if id1 > 1999: id1 -= 2000
			if id2 > 1999: id2 -= 2000
			if id1 == id2:
				m.set_u16(0xa55d40 + i * 2, 0)
				return 0
		i += 1
	if f568580(card & 0xffff) != 0:
		i = 0
		while i < ((m.u32(0xa55d3c) >> 24) & 3):
			var used := m.u16(0xa55d40 + i * 2)
			if used != 0 and f568580(used) != 0:
				m.set_u16(0xa55d40 + i * 2, 0)
				return 0
			i += 1
	return 0


func f592b00(e: int, p: int, z: int) -> int:
	if not _zq_cpu(e) and f5aa480() == 0: return 0
	f592a90(e, p, z)
	return 1


func f592b50(e: int, p: int, z: int) -> int:
	var i := 0
	while i < (m.u16(e + 4) >> 13):
		if f583440(e, i) == (((z & 255) << 8) | (p & 255)): return 1
		i += 1
	return 0


func f593440(e: int, target: int) -> int:
	var step := m.u8(0xa55c8e)
	if step == 0:
		m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
		if f59dca0(e) == 0: return 1
		f592bb0(e)
		m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
	elif step == 1:
		f5929d0()
		if f5beed0() != 0 and m.u32(0xa55048) < 11:
			var p := m.u32(0xa55044)
			var z := m.u32(0xa5504c) + m.u32(0xa55048)
			if f59dc50(e, p, z) != 0 and f592b00(e, p, z) != 0: return 1
		if (m.u32(0xa54e54) & 0x102) != 0:
			m.set_u8(0xa55c8e, m.u8(0xa55c8e) - 1)
			return 0
	else: return 1
	return 0


func f593ba0(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x13f)


func f593ca0(e: int) -> int:
	f592a50(e, _zq_owner(e))
	return 1


func f593cc0(e: int) -> int:
	f592a50(e, 1 - _zq_owner(e))
	return 1


func f5944d0(e: int, target: int) -> int:
	return _zq_choose(e, target, 500)


func f594780(e: int, target: int) -> int:
	var ref := m.u16(e + 2)
	if (ref & 0x3000) != 0x1000: return f593a20(e, target)
	var linked := f56fb40(ref & 1, (ref >> 1) & 31) & 0xffff
	f577b30(_zq_owner(e), (m.u16(e + 2) >> 1) & 31)
	f577b30(linked & 255, _zq_s8(linked >> 8))
	return 1


func _zq_s8(value: int) -> int:
	return (value & 127) - (value & 128)


func f594810(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x3ab)


func f594860(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x4de)


func f594b70(e: int, target: int) -> int:
	return _zq_choose(e, target, 0)


func f594bb0(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x3ec)


func f5952c0(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x3f7)


func f595310(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x413)


func f595a90(e: int, target: int) -> int:
	if (m.u16(e + 2) & 0x3000) != 0x2000: return 1
	return f595ac0(e)


func f596ba0(e: int, target: int) -> int:
	m.set_u16(e + 2, (m.u16(e + 2) & 0xdfff) | 0x1000)
	var result := f593a20(e, target)
	m.set_u16(e + 2, (m.u16(e + 2) & 0xefff) | 0x2000)
	return result


func f5974d0(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x430)


func f597520(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x5f9)


func f597570(e: int, target: int) -> int:
	return _zq_choose(e, target, 0x1d4)


func f590080(e: int) -> int:
	var p := _zq_owner(e)
	if (m.u8(0xa577fa) & 14) != 10:
		if (m.u8(e + 4) & 4) == 0: f579790(p, m.u16(e), 3)
		return 0
	match m.u8(0xa55c8a):
		126:
			f575d50(e, p, f40cab0())
			return 120
		127:
			f40c940(p, 6, f4022e0(m.u16(e)) & 0xffff, 0)
			return 126
		128:
			if f599e30(p, f4022e0(m.u16(e)), 0) == 0: return 0
			if _zq_cpu(e):
				f5af5a0(p, m.u16(e), 0)
				return 126
			f5bf800(0x4d)
			return 127
	return 0


func f5901a0(e: int) -> int:
	var ref := m.u16(e + 2)
	var p := ref & 1
	if (ref & 0x3000) != 0x2000:
		p ^= (ref >> 14) & 1
		f579790(p, m.u16(e), 3)
		if ((m.u32(0xa54e5c) >> (1 + p)) & 1) == 0: f5bf800(0x9c)
		return 0
	var card := f4022e0(m.u16(e)) & 0xffff
	match m.u8(0xa55c8a):
		126:
			if card in [0x596, 0x599, 0x59f]:
				var entry := m.u32(f40cab0())
				var second := m.u32(f40cab0())
				f575900(p, ((second >> 12) & 1) + ((entry >> 24) & 127) * 2, int(card == 0x596))
			elif card == 0x5a4: f575d50(e, p, f40cab0())
		127:
			f40c940(p, 6, card, 0)
			return 126
		128:
			if f599e30(p, card, 0) == 0: return 0
			if _zq_cpu(e):
				f5af5a0(p, m.u16(e), 0)
				return 126
			if card in [0x596, 0x599]: f5bf800(0x4c)
			elif card == 0x59f: f5bf800(0x4e)
			elif card == 0x5a4: f5bf800(0x4d)
			return 127
	return 0


func f5904b0(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0: return 0
	var p := _zq_owner(e)
	match m.u8(0xa55c8a):
		122:
			f5747e0(p, m.u16(e), (m.u8(0xa55c8b) << 8) | p, 12)
			return 120
		123, 124:
			m.set_u8(0xa55c8b, f56a030(p))
			f5adb10(p, f40cab0(), 1, 0, 12, p)
			return 122
		125:
			f40c940(p, 6, f4022e0(m.u16(e)) & 0xffff, 0)
			return 124
		128:
			if f570b40(p) == 0 or f56a000(p) == 0 or f599e30(p, f4022e0(m.u16(e)), 0) == 0: return 0
			if _zq_cpu(e):
				f5af5a0(p, m.u16(e), 0)
				return 124
			f5bf800(0x1a)
			return 125
	return 0


func f590870(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0: return 0
	var p := 1 - _zq_owner(e)
	match m.u8(0xa55c8a):
		126:
			var at := m.local(4)
			m.set_u32(at, m.u16(0xa57822) | (m.u16(0xa57824) << 16))
			f5adb10(p, at, 1, 0x20, 14, p)
			return 125
		127:
			if m.u16(0xa57822) != 0:
				f5bcfc0(p, m.u16(e), 0)
				return 126
		128:
			if f599e30(p, 0x5f0, 0) == 0 or f56a000(p) == 0 or f570b40(p) == 0: return 0
			f5bcf40(p, 0x5f0)
			return 127
	return 0


func f590a20(e: int) -> int:
	if (m.u8(e + 4) & 4) != 0: return 0
	var p := _zq_owner(e)
	var step := m.u8(0xa55c8a)
	match step:
		124, 125:
			if _zq_cpu(e): f5af5a0(p, m.u16(e), 0)
			else: f40ccb0(2 if step == 124 else 1)
			f575d50(e, p, f40cab0())
			return m.u8(0xa55c8a) - 1
		126:
			f40c940(p, 8, f4022e0(m.u16(e)) & 0xffff, 0)
			return 125
		127:
			if not _zq_cpu(e):
				f5bf800(0x58)
				return 126
			return 125
		128:
			return 127 if f599e30(p, 0x5f4, 0) > 1 else 0
	return 0


func f5938d0(e: int) -> int:
	match m.u8(0xa55c8e):
		0:
			f5bcf00(_zq_owner(e), 0xffff, 0)
			m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
		1:
			var target := m.u16(0xa57822)
			var p := target & 255
			var z := (target >> 8) & 255
			var side := f5be050(f56f690(p, z))
			f577b30(p, z)
			m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
			f592a50(e, side)
			return 1
	return 0


func f593970(e: int, target: int) -> int:
	var card := f4022e0(m.u16(e)) & 0xffff
	if card in [0x534, 0x15c, 0x2d9, 0x2da, 0x536] and (m.u32(_zq_zone(e)) & 0xfff) == 0: return 1
	return _zq_choose(e, target, 0x5e)


func f595690(e: int, other: int, target: int) -> int:
	var z := (target >> 8) & 255
	var source := f583440(e, 0)
	var source_z := (f583440(e, 0) >> 8) & 255
	var link := f56fb40(source & 255, source_z) & 0xffff
	if f56c510(target & 255, z) == 0: return 0
	if (m.u8(JoeyMem.zone(source & 1, source_z) + 0x8c) & 2) == 0 or link != 0xffff:
		if link == (target & 0xffff): return 0
	elif f583440(other, 0) == (target & 0xffff): return 0
	return int(f56fc50(source & 255, source_z, target & 255, z) != 0)


func f595ce0(e: int) -> int:
	var step := m.u8(0xa55c8e)
	if step == 0:
		m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
		f5bcfa0(_zq_owner(e), m.u16(e))
	elif step == 1:
		f5b9170(((m.u16(e + 2) << 15) | 0x88) & 0xffffffff, (m.u8(e + 2) >> 1) & 31, m.u16(0xa57822) + 1, 0)
	else: return 1
	m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
	return 0


func f593bf0(e: int) -> int:
	if _zq_cpu(e):
		f592a50(e, 0)
		return 1
	match m.u8(0xa55c8e):
		0:
			m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
			f5bf800(0x67)
			f5bf9a0(2, 0)
		1:
			f592a50(e, _zq_owner(e) ^ m.u16(0xa558b4))
		_: return 1
	m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
	return 0


func f595ac0(e: int) -> int:
	var owner := _zq_owner(e) ^ m.u8(0xa55c8f)
	match m.u8(0xa55c8e):
		0:
			m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
			m.set_u8(0xa55c8f, 0)
		1:
			var slot := (m.u16(e + 4) >> 5) & 255
			if f56a000(owner) != 0 and f570b40(owner) != 0 and f599e30(owner, f4022e0(m.u16(e)), slot) != 0:
				f5bcfc0(owner, m.u16(e), slot)
				m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
				return 0
			m.set_u16(0xa57824, 0)
			m.set_u16(0xa57822, 0)
			m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 2)
			return 0
		2:
			var entry := m.u16(0xa57822) | (m.u16(0xa57824) << 16)
			var instance := ((entry >> 12) & 1) + ((entry >> 24) & 127) * 2
			f5b9170((0x8000 if owner != 0 else 0) | 0xdf, f4022e0(entry & 0xfff), instance, 0)
			f5b9170((0x8000 if owner != 0 else 0) | 8, owner, 14, 0)
		3:
			m.set_u16(e + owner * 4 + 6, m.u16(0xa57822))
			m.set_u16(e + owner * 4 + 8, m.u16(0xa57824))
			m.set_u16(e + 4, (m.u16(e + 4) & 0x1fff) | 0x8000)
			var next_owner := (m.u8(0xa55c8f) + 1) & 255
			m.set_u8(0xa55c8f, next_owner)
			m.set_u8(0xa55c8e, 1 if next_owner < 2 else m.u8(0xa55c8e) + 1)
			return 0
		_: return 1
	m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
	return 0


func f595d60(e: int) -> int:
	match m.u8(0xa55c8e):
		0:
			m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
			if f599e30(_zq_owner(e), 0x47b, 0) == 0: return 1
		1:
			if not _zq_cpu(e): f5bf800(0x37)
		2:
			f40c940(_zq_owner(e), 26, 0x47b, 0)
			m.set_u16(0xa55c8e, (m.u8(0xa55c8e) + 1) & 255)
			return 0
		3:
			var index := m.u8(0xa55c8f)
			m.set_u8(0xa55c8f, index + 1)
			if index < m.u16(0xa558b4):
				var entry := m.u32(f40cd00(index + 1))
				var instance := ((entry >> 12) & 1) + ((entry >> 24) & 127) * 2
				f5b9170((m.u16(e + 2) << 15) | 0xdf, f4022e0(entry & 0xfff), instance, 0)
				f5b9170((m.u16(e + 2) << 15) | 8, _zq_owner(e), 14, 0)
				f592a50(e, instance)
				return 0
		_: return 1
	m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
	return 0


func _zq_signed(value: int, bits: int) -> int:
	var sign_bit: int = 1 << (bits - 1)
	return ((value & ((1 << bits) - 1)) ^ sign_bit) - sign_bit


func f590ba0(param_1: int, param_2: int) -> int:
	var puVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var pbVar7: int = 0
	var local_8: int = 0
	var _pc: int = 40
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f579890()
				_pc = 1
			3:
				var _v1: int = f576940(param_1, m.u32((((((((param_1) & 0xffffffff) + ((8) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)))
				_pc = 2
			4:
				return ((0x7f) & 0xffffffff)
			5:
				var _v2: int = f579810()
				_pc = 4
			6:
				m.set_u16((((((((param_1) & 0xffffffff) + ((10) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((0) & 0xffff))
				_pc = 5
			7:
				m.set_u16((((((((param_1) & 0xffffffff) + ((8) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((0) & 0xffff))
				_pc = 6
			8:
				_pc = 7 if (int(_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zq_signed(0x80, 32))) != 0 else 1
			9:
				return ((0x7e) & 0xffffffff)
			10:
				_pc = 31 if (int(_zq_signed(_zq_signed(local_8, 32), 32) < _zq_signed(2, 32))) != 0 else 9
			11:
				local_8 = (((((((local_8) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 10
			12:
				_pc = 28 if (int(_zq_signed(_zq_signed(param_1, 32), 32) < _zq_signed(10, 32))) != 0 else 11
			13:
				param_1 = (((((((param_1) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			14:
				pbVar7 = (((pbVar7 + (0x90) * 1)) & 0xffffffff)
				_pc = 13
			15:
				m.set_u16(puVar1, ((_zq_signed((_zq_signed(m.u16(puVar1), 32) | _zq_signed(((_zq_signed((_zq_signed(1, 32) << ((_zq_signed((_zq_signed(((param_1) & 0xff), 32) & _zq_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffff), 32)), 32)) & 0xffff))
				_pc = 14
			16:
				puVar1 = (((((((((_zq_signed((_zq_signed(iVar2, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff) + (((((((uVar6) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				m.set_u16(((_zq_signed((_zq_signed(param_2, 32) + _zq_signed(6, 32)), 32)) & 0xffffffff), ((m.u16(((_zq_signed((_zq_signed(iVar2, 32) + _zq_signed(6, 32)), 32)) & 0xffffffff))) & 0xffff))
				_pc = 14
			18:
				_pc = 17 if (int((int(((uVar6) & 0xffffffff) == ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_2, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff))) != 0 and (int(((param_1) & 0xffffffff) == ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_2, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x3e, 32)), 32), 32) >> ((1) & 31)), 32)) & 0xffffffff))) != 0)) != 0 else 14
			19:
				return ((0x7f) & 0xffffffff)
			20:
				var _v3: int = f574ac0((((((param_1) & 0xff)) << 8) | ((_zq_signed(uVar6, 8)) & 0xff)), uVar4)
				_pc = 19
			21:
				_pc = 20 if (int(_zq_signed(_zq_signed((_zq_signed(m.u8(pbVar7), 32) & _zq_signed(2, 32)), 32), 32) == _zq_signed(0, 32))) != 0 else 18
			22:
				_pc = 16 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 21
			23:
				var _v4: int = f56fc50(uVar6, param_1, (((((uVar4) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar5)
				iVar3 = _zq_signed(_v4, 32)
				_pc = 22
			24:
				_pc = 23 if (int(_zq_signed(iVar3, 32) < _zq_signed(0, 32))) != 0 else 14
			25:
				var _v5: int = f56dc10((((((uVar4) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar5, uVar6, param_1)
				iVar3 = _zq_signed(_v5, 32)
				_pc = 24
			26:
				_pc = 25 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 14
			27:
				var _v6: int = f598b50(uVar6, param_1, _zq_signed((_zq_signed(m.u16((((pbVar7 + (_zq_signed((-(0x8c)), 32)) * 1)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32))
				iVar3 = _zq_signed(_v6, 32)
				_pc = 26
			28:
				_pc = 27 if (int(_zq_signed(_zq_signed((_zq_signed(m.u16((((pbVar7 + (_zq_signed((-(0x8c)), 32)) * 1)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 14
			29:
				pbVar7 = (((((0xa560d0 + (((((((((((uVar6) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)) & 0xffffffff)
				_pc = 28
			30:
				uVar6 = (((((((_zq_signed((_zq_signed(m.u16(0xa577fa), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff) ^ ((local_8) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 29
			31:
				param_1 = ((5) & 0xffffffff)
				_pc = 30
			32:
				local_8 = ((0) & 0xffffffff)
				_pc = 31
			33:
				_pc = 32 if (int(_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zq_signed(127, 32))) != 0 else 8
			34:
				_pc = 3 if (int(_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zq_signed(126, 32))) != 0 else 33
			35:
				uVar5 = ((((((((((((uVar4) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 34
			36:
				var _v7: int = f583440(param_1, 0)
				uVar4 = ((_v7) & 0xffffffff)
				_pc = 35
			37:
				_pc = 36 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 1
			38:
				var _v8: int = f583470(param_1, 0, 0)
				iVar3 = _zq_signed(_v8, 32)
				_pc = 37
			39:
				_pc = 38 if (int(_zq_signed(_zq_signed((_zq_signed(m.u8((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zq_signed(4, 32)), 32), 32) == _zq_signed(0, 32))) != 0 else 1
			40:
				iVar2 = _zq_signed(param_1, 32)
				_pc = 39
	return 0


func f590d80(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var sVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var iVar7: int = 0
	var uVar8: int = 0
	var uVar9: int = 0
	var uVar10: int = 0
	var uVar11: int = 0
	var local_10: int = 0
	var _pc: int = 51
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar6) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5784e0(uVar11, 2000)
				uVar6 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f578400(uVar11, uVar5)
				_pc = 2
			4:
				var _v2: int = f402460(0x443)
				uVar5 = ((_v2) & 0xffffffff)
				_pc = 3
			5:
				_pc = 4 if (int(_zq_signed(iVar7, 32) != _zq_signed(0, 32))) != 0 else 1
			6:
				uVar6 = ((0) & 0xffffffff)
				_pc = 5
			7:
				var _v3: int = f570c70(uVar11, (((((((((((((((uVar6) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((uVar6) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff))
				iVar7 = _zq_signed(_v3, 32)
				_pc = 6
			8:
				uVar6 = ((m.u32((0xa56434 + ((((((iVar7) & 0xffffffff) + (((((((uVar11) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)
				_pc = 7
			9:
				var _v4: int = f5b9170((((((uVar10) & 0xffffffff) | ((0xe5) & 0xffffffff))) & 0xffffffff), (((((uVar8) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff), uVar5, 0)
				_pc = 8
			10:
				var _v5: int = f576110(uVar11, 0xb, (((((((((((((((uVar6) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((uVar6) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), uVar11, uVar5, 1, 0)
				_pc = 9
			11:
				uVar6 = ((m.u32((0xa56434 + ((((((iVar7) & 0xffffffff) + (((((((uVar11) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)
				_pc = 10
			12:
				var _v6: int = f5b9170((((_zq_signed((((((uVar10) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((0x8b) & 0xff)), uVar4, 1, 0)
				_pc = 11
			13:
				uVar10 = ((((((((((-(((int(_zq_signed(_zq_signed((_zq_signed(uVar1, 32) & _zq_signed(1, 32)), 32), 32) != _zq_signed(0, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			14:
				var _v7: int = f4022e0(_zq_signed((_zq_signed(m.u16(local_10), 32) & _zq_signed(0xfff, 32)), 32))
				uVar6 = ((_v7) & 0xffffffff)
				_pc = 18 if (int(_zq_signed(_zq_signed(uVar6, 16), 32) != _zq_signed(sVar3, 32))) != 0 else 13
			15:
				return (((((((uVar6) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			16:
				_pc = 15 if (int(_zq_signed(_zq_signed(((m.u8((((0xa55d68 + ((((((uVar11) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffffffff), 32), 32) <= _zq_signed(iVar7, 32))) != 0 else 14
			17:
				local_10 = (((local_10 + (2) * 2)) & 0xffffffff)
				_pc = 16
			18:
				iVar7 = _zq_signed(_zq_signed((_zq_signed(iVar7, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 17
			19:
				local_10 = (((((0xa56434 + ((((((uVar11) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)) & 0xffffffff)
				_pc = 14
			20:
				_pc = 19 if (int(_zq_signed(_zq_signed(m.u8((((0xa55d68 + ((((((uVar11) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 8), 32) != _zq_signed(0, 32))) != 0 else 1
			21:
				uVar6 = ((0) & 0xffffffff)
				_pc = 20
			22:
				iVar7 = _zq_signed(0, 32)
				_pc = 21
			23:
				return (((((((uVar6) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			24:
				var _v8: int = f5b9170((((((uVar6) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				uVar6 = ((_v8) & 0xffffffff)
				_pc = 23
			25:
				var _v9: int = f5b9170((((uVar9) << 8) | ((0xe5) & 0xff)), (((((uVar8) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff), uVar5, 0)
				_pc = 24
			26:
				var _v10: int = f5791d0(uVar11, sVar3, uVar5)
				_pc = 25
			27:
				var _v11: int = f5b9170((((uVar9) << 8) | ((0x8b) & 0xff)), uVar4, 1, 0)
				_pc = 26
			28:
				uVar9 = (((((((((uVar6) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff)) & 0xffffff)
				_pc = 27
			29:
				uVar6 = ((((((((((-(((int(_zq_signed(_zq_signed((_zq_signed(uVar1, 32) & _zq_signed(1, 32)), 32), 32) != _zq_signed(0, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 28
			30:
				_pc = 29 if (int(_zq_signed(iVar7, 32) != _zq_signed(0, 32))) != 0 else 22
			31:
				var _v12: int = f569300(uVar11, sVar3)
				iVar7 = _zq_signed(_v12, 32)
				_pc = 30
			32:
				_pc = 1
			33:
				sVar3 = _zq_signed(0x608, 16)
				_pc = 31
			34:
				sVar3 = _zq_signed(0x607, 16)
				_pc = 31
			35:
				sVar3 = _zq_signed(0x606, 16)
				_pc = 31
			36:
				sVar3 = _zq_signed(0x605, 16)
				_pc = 31
			37:
				var _v13: int = uVar8
				_pc = 32
				if _v13 == 3: _pc = 33
				if _v13 == 2: _pc = 34
				if _v13 == 1: _pc = 35
				if _v13 == 0: _pc = 36
			38:
				uVar6 = ((((uVar2) & 0xffffffff)) & 0xffffffff)
				_pc = 37
			39:
				return (((((((uVar6) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			40:
				var _v14: int = f5b9170(((((((((((((uVar2) & 0xffffffff)) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xe5) & 0xffffffff))) & 0xffffffff), 0, _zq_signed((_zq_signed(_zq_signed((_zq_signed(uVar2, 32) & _zq_signed(0x3e, 32)), 32), 32) >> ((1) & 31)), 32), 0)
				uVar6 = ((_v14) & 0xffffffff)
				_pc = 39
			41:
				_pc = 40 if (int(_zq_signed(_zq_signed((_zq_signed(uVar2, 32) & _zq_signed(0x3000, 32)), 32), 32) == _zq_signed(0, 32))) != 0 else 38
			42:
				_pc = 41 if (int(_zq_signed(_zq_signed((_zq_signed(((m.u32((0xa55d74 + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(uVar2, 32) >> ((1) & 31)), 32), 32) & _zq_signed(0x1f, 32)), 32), 32) * _zq_signed(0x24, 32)), 32), 32) + _zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(uVar2, 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffff), 32) & _zq_signed(0xfff, 32)), 32), 32) == _zq_signed(m.u16(param_1), 32))) != 0 else 1
			43:
				uVar6 = ((_zq_signed((_zq_signed(uVar2, 32) & _zq_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 42
			44:
				uVar2 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 43
			45:
				_pc = 44 if (int(_zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(4, 32)), 32), 32) == _zq_signed(0, 32))) != 0 else 1
			46:
				uVar6 = ((0) & 0xffffffff)
				_pc = 45
			47:
				uVar8 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(((((0xa55d7a + ((((((uVar4) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar11) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zq_signed(0x3c, 32)), 32), 32) >> ((2) & 31)), 32)) & 0xffffffff)
				_pc = 46
			48:
				var _v15: int = f56a400(uVar11)
				uVar5 = ((_v15) & 0xffffffff)
				_pc = 47
			49:
				uVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zq_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 48
			50:
				uVar11 = ((_zq_signed((_zq_signed(uVar1, 32) & _zq_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 49
			51:
				uVar1 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 50
	return 0


func f591040(param_1: int) -> int:
	var uVar1: int = 0
	var in_EAX: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var iVar4: int = 0
	var extraout_var: int = 0
	var uVar5: int = 0
	var bVar6: int = 0
	var extraout_var_00: int = 0
	var extraout_var_01: int = 0
	var _pc: int = 48
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((uVar5) << 16) | ((0x7f) & 0xffff))) & 0xffffffff)
			2:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			3:
				var _v0: int = f577880(param_1, uVar1, iVar3)
				uVar2 = ((_v0) & 0xffffffff)
				_pc = 2
			4:
				var _v1: int = f5b9170(((((((((uVar5) << 16) | ((_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), (((extraout_var_01) << 16) | ((((m.u32(0xa55044)) & 0xffff)) & 0xffff)), (((((((((((((((m.u32(0xa5504c)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | (((((uVar5) << 16) | ((((((m.u32(0xa55048)) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 3
			5:
				uVar5 = (((((((((((iVar4) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 4
			6:
				_pc = 5 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 1
			7:
				uVar5 = ((0) & 0xffff)
				_pc = 6
			8:
				var _v2: int = f5aa480()
				iVar4 = _zq_signed(_v2, 32)
				_pc = 7
			9:
				_pc = 8 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 1
			10:
				uVar5 = ((0) & 0xffff)
				_pc = 9
			11:
				var _v3: int = f57c1c0(param_1, (((_zq_signed(iVar3, 8)) << 8) | ((_zq_signed(m.u32(0xa55044), 8)) & 0xff)))
				iVar4 = _zq_signed(_v3, 32)
				_pc = 10
			12:
				iVar3 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 11
			13:
				_pc = 12 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 1
			14:
				uVar5 = ((0) & 0xffff)
				_pc = 13
			15:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 14
			16:
				var _v4: int = f5aa440(0xe000e0)
				iVar3 = _zq_signed(_v4, 32)
				_pc = 15
			17:
				var _v5: int = f5929d0()
				_pc = 16
			18:
				return ((0x80) & 0xffffffff)
			19:
				_pc = 18 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 17
			20:
				uVar5 = ((extraout_var) & 0xffff)
				_pc = 1
			21:
				var _v6: int = f5bf800(0x6d)
				_pc = 20
			22:
				return ((0) & 0xffffffff)
			23:
				_pc = 33 if (int(_zq_signed(iVar3, 32) < _zq_signed(2, 32))) != 0 else 22
			24:
				iVar3 = _zq_signed(_zq_signed((_zq_signed(iVar3, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 23
			25:
				_pc = 31 if (int(_zq_signed(_zq_signed(uVar2, 32), 32) < _zq_signed(5, 32))) != 0 else 24
			26:
				uVar2 = (((((((uVar2) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 25
			27:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			28:
				var _v7: int = f577880(param_1, bVar6, uVar2)
				uVar2 = ((_v7) & 0xffffffff)
				_pc = 27
			29:
				var _v8: int = f5b9170(((((((((extraout_var_00) << 16) | ((_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), bVar6, ((((((((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff), 0)
				_pc = 28
			30:
				_pc = 29 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 26
			31:
				var _v9: int = f59dc50(param_1, bVar6, uVar2)
				iVar4 = _zq_signed(_v9, 32)
				_pc = 30
			32:
				uVar2 = ((0) & 0xffffffff)
				_pc = 31
			33:
				bVar6 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32), 32) ^ _zq_signed(int(_zq_signed(iVar3, 32) == _zq_signed(0, 32)), 32)), 32)) & 0xff)
				_pc = 32
			34:
				iVar3 = _zq_signed(0, 32)
				_pc = 33
			35:
				_pc = 34 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 21
			36:
				return ((0) & 0xffffffff)
			37:
				_pc = 36 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 35
			38:
				var _v10: int = f59dca0(param_1)
				iVar3 = _zq_signed(_v10, 32)
				_pc = 37
			39:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			40:
				_pc = 39 if (int(((uVar2) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 38
			41:
				uVar2 = ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zq_signed(0x80, 32)), 32)) & 0xffffffff)
				_pc = 40
			42:
				_pc = 19 if (int(_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zq_signed(0x7f, 32))) != 0 else 41
			43:
				return ((0) & 0xffffffff)
			44:
				_pc = 43 if (int(_zq_signed(m.u16((param_1 + (3) * 2)), 32) == _zq_signed(0, 32))) != 0 else 42
			45:
				return ((0) & 0xffffffff)
			46:
				_pc = 45 if (int(_zq_signed(_zq_signed((_zq_signed(((m.u32((0xa55d74 + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zq_signed(0x1f, 32)), 32), 32) * _zq_signed(0x24, 32)), 32), 32) + _zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffff), 32) & _zq_signed(0xfff, 32)), 32), 32) != _zq_signed(m.u16(param_1), 32))) != 0 else 44
			47:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			48:
				_pc = 47 if (int(_zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(4, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 46
	return 0


func f5912f0(param_1: int) -> int:
	var sVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var _pc: int = 29
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5b9170((((((((((((((-(((int(((((((((((((uVar4) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f577a60(param_1, uVar5, uVar3)
				_pc = 2
			4:
				_pc = 3 if (int((((((((uVar4) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 1
			5:
				uVar4 = ((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)
				_pc = 4
			6:
				uVar3 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((1) & 31)), 32), 32) & _zq_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 5
			7:
				uVar5 = ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 6
			8:
				var _v2: int = f577880(param_1, uVar7, uVar5)
				_pc = 7
			9:
				var _v3: int = f5ba860((((((((((((((((((((((((((uVar3) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x1f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | (((((((uVar7) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((0x10) & 31))) & 0xffffffff)) & 0xffffffff) | ((uVar6) & 0xffffffff))) & 0xffffffff), (((((((((((((((((m.u32((0xa55d74 + (((((((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((((m.u32((0xa55d74 + (((((((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff))
				_pc = 7
			10:
				var _v4: int = f578390(uVar7, uVar6, uVar5)
				_pc = 9
			11:
				_pc = 8 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 10
			12:
				var _v5: int = f57ed20(uVar7, uVar5, uVar6)
				iVar2 = _zq_signed(_v5, 32)
				_pc = 11
			13:
				var _v6: int = f574f40(param_1, uVar7, uVar5, 0)
				_pc = 7
			14:
				_pc = 12 if (int((int(_zq_signed(sVar1, 32) == _zq_signed(0x15, 32))) != 0 and (int(_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x10, 32)), 32), 32) == _zq_signed(0, 32))) != 0)) != 0 else 13
			15:
				var _v7: int = f4025d0(uVar6)
				sVar1 = _zq_signed(_v7, 16)
				_pc = 14
			16:
				var _v8: int = f5b9170(((((((((extraout_var) << 16) | ((_zq_signed((_zq_signed(_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0xf1) & 0xffffffff))) & 0xffffffff), 0xf, 0, 0)
				_pc = 15
			17:
				var _v9: int = f578430(uVar7, uVar6)
				_pc = 16
			18:
				var _v10: int = f574f40(param_1, uVar7, uVar5, 0)
				_pc = 17
			19:
				_pc = 18 if (int((int(_zq_signed(_zq_signed(uVar6, 16), 32) != _zq_signed(0, 32))) != 0 and (int(_zq_signed(_zq_signed((_zq_signed(m.u8(((((0xa55d7a + ((((((uVar4) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zq_signed(2, 32)), 32), 32) == _zq_signed(0, 32))) != 0)) != 0 else 7
			20:
				uVar6 = ((_zq_signed((_zq_signed(m.u16(((((0xa55d74 + ((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32)) & 0xffffffff)
				_pc = 19
			21:
				uVar4 = (((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 20
			22:
				uVar5 = ((((((((((((uVar3) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 21
			23:
				uVar7 = (((((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 22
			24:
				var _v11: int = f583440(param_1, 0)
				uVar3 = ((_v11) & 0xffffffff)
				_pc = 23
			25:
				_pc = 24 if (int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0 else 1
			26:
				uVar3 = ((0) & 0xffffffff)
				_pc = 25
			27:
				var _v12: int = f583470(param_1, 0, 0)
				iVar2 = _zq_signed(_v12, 32)
				_pc = 26
			28:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			29:
				_pc = 28 if (int(_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(4, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 27
	return 0


func f5914a0(param_1: int) -> int:
	var uVar1: int = 0
	var bVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var iVar6: int = 0
	var _pc: int = 32
	while true:
		match _pc:
			0:
				return ((0) & 0xff)
			1:
				return ((0) & 0xff)
			2:
				return ((_zq_signed((_zq_signed(_zq_signed((-(int(_zq_signed(iVar5, 32) != _zq_signed(0, 32)))), 32), 32) & _zq_signed(0x7f, 32)), 32)) & 0xff)
			3:
				var _v0: int = f568bd0(((0xa55d74 + ((((((uVar4) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + (((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4))
				iVar5 = _zq_signed(_v0, 32)
				_pc = 2
			4:
				_pc = 3 if (int(((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff) == ((((((((((((((m.u32((0xa55d74 + (((((((((((uVar4) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) != 0 else 1
			5:
				var _v1: int = f577a60(param_1, (((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar4)
				_pc = 4
			6:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((((0xa55d74 + ((((((uVar4) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + (((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32)) & 0xffff))
				_pc = 5
			7:
				var _v3: int = int((int(_zq_signed(iVar5, 32) != _zq_signed(0, 32))) != 0)
				if _v3 != 0:
					var _v2: int = f57c3b0(param_1, uVar3)
					iVar5 = _zq_signed(_v2, 32)
					_v3 = int((int(_zq_signed(iVar5, 32) != _zq_signed(0, 32))) != 0)
				_pc = 6 if (_v3) != 0 else 1
			8:
				var _v4: int = f583470(param_1, 0, 0)
				iVar5 = _zq_signed(_v4, 32)
				_pc = 7
			9:
				return ((0x7e) & 0xff)
			10:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 9
			11:
				return ((0x7e) & 0xff)
			12:
				var _v5: int = f5bf9a0(1, 0)
				_pc = 11
			13:
				var _v6: int = f5bf800(0x59)
				_pc = 12
			14:
				_pc = 13 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 10
			15:
				var _v8: int = int((int(_zq_signed(iVar6, 32) != _zq_signed(0, 32))) != 0)
				if _v8 != 0:
					var _v7: int = f56a000(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32))
					iVar6 = _zq_signed(_v7, 32)
					_v8 = int((int(_zq_signed(iVar5, 32) <= _zq_signed(iVar6, 32))) != 0)
				var _v10: int = int((_v8) != 0)
				if _v10 != 0:
					var _v9: int = f599e30(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 0x60a, m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff)))
					iVar6 = _zq_signed(_v9, 32)
					_v10 = int((int(_zq_signed(iVar6, 32) == _zq_signed(iVar5, 32))) != 0)
				_pc = 14 if (_v10) != 0 else 1
			16:
				var _v11: int = f570b40(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32))
				iVar6 = _zq_signed(_v11, 32)
				_pc = 15
			17:
				var _v12: int = f5919b0(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff)))
				iVar5 = _zq_signed(_v12, 32)
				_pc = 16
			18:
				return ((0x7d) & 0xff)
			19:
				var _v13: int = f579810()
				_pc = 18
			20:
				m.set_u16(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0xff, 32)), 32)) & 0xffff))
				_pc = 19
			21:
				_pc = 20 if (int(_zq_signed(m.u16(0xa558b4), 32) != _zq_signed(0, 32))) != 0 else 1
			22:
				return ((_zq_signed((_zq_signed(int(_zq_signed(_zq_signed(((_zq_signed((_zq_signed(uVar1, 32) >> ((8) & 31)), 32)) & 0xffffffff), 32), 32) < _zq_signed(iVar5, 32)), 32) + _zq_signed(0x7c, 32)), 32)) & 0xff)
			23:
				m.set_u16(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(uVar1, 32) ^ _zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 22
			24:
				uVar1 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0xff00, 32)), 32), 32) + _zq_signed(0x100, 32)), 32)) & 0xffff)
				_pc = 23
			25:
				var _v14: int = f5adb10(bVar2, (0xa582a4 + ((((((((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) * 2), 1, 0x20, 0xe, bVar2)
				_pc = 24
			26:
				bVar2 = ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 25
			27:
				var _v15: int = f5919b0(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff)))
				iVar5 = _zq_signed(_v15, 32)
				_pc = 26
			28:
				var _v16: int = f579890()
				_pc = 1
			29:
				var _v17: int = m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v17 == 0x80: _pc = 8
				if _v17 == 0x7f: _pc = 17
				if _v17 == 0x7e: _pc = 21
				if _v17 == 0x7d: _pc = 27
				if _v17 == 0x7c: _pc = 28
			30:
				_pc = 29 if (int(_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(4, 32)), 32), 32) == _zq_signed(0, 32))) != 0 else 1
			31:
				uVar4 = ((((((((((((uVar3) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 30
			32:
				var _v18: int = f583440(param_1, 0)
				uVar3 = ((_v18) & 0xffffffff)
				_pc = 31
	return 0


func f591760(param_1: int, param_2: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var puVar3: int = 0
	var _pc: int = 20
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7e) & 0xffffffff)
			3:
				var _v0: int = f5bf800(0x5a)
				_pc = 2
			4:
				_pc = 3 if (int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0 else 1
			5:
				var _v1: int = f599e30(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 0x60d, 0)
				iVar2 = _zq_signed(_v1, 32)
				_pc = 4
			6:
				m.set_u16(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 5
			7:
				return ((0) & 0xffffffff)
			8:
				_pc = 7 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 6
			9:
				var _v2: int = f583400(param_1)
				iVar2 = _zq_signed(_v2, 32)
				_pc = 8
			10:
				return ((0x7d) & 0xffffffff)
			11:
				var _v3: int = f40c940(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 9, uVar1, 0)
				_pc = 10
			12:
				var _v4: int = f4022e0(m.u16(param_1))
				uVar1 = ((_v4) & 0xffff)
				_pc = 11
			13:
				return ((0) & 0xffffffff)
			14:
				_pc = 17 if (int(_zq_signed(iVar2, 32) < _zq_signed(3, 32))) != 0 else 13
			15:
				var _v5: int = f5b9170(0x8e, (((((((((((((_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((((((m.u32(puVar3)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff), 8), 32) * _zq_signed(2, 32)), 32), 32) + _zq_signed(_zq_signed((_zq_signed((((((((m.u32(puVar3)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xff), 32) & _zq_signed(1, 32)), 32), 32)), 32)) << 8) | ((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0xff01) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x1e) & 0xffffffff))) & 0xffffffff), (((((((((((((_zq_signed((((((((puVar3) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x11c) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 14
			16:
				var _v6: int = f40cd00(iVar2)
				puVar3 = ((((_v6) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				iVar2 = _zq_signed(_zq_signed((_zq_signed(iVar2, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 16
			18:
				iVar2 = _zq_signed(0, 32)
				_pc = 17
			19:
				var _v7: int = m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v7 == 0x7f: _pc = 5
				if _v7 == 0x80: _pc = 9
				if _v7 == 0x7e: _pc = 12
				if _v7 == 0x7d: _pc = 18
			20:
				_pc = 19 if (int(_zq_signed(_zq_signed((_zq_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zq_signed(4, 32)), 32), 32) == _zq_signed(0, 32))) != 0 else 1
	return 0


func f5921c0(param_1: int, param_2: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var sVar3: int = 0
	var iVar4: int = 0
	var puVar5: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var extraout_var: int = 0
	var uVar8: int = 0
	var psVar9: int = 0
	var extraout_var_00: int = 0
	var extraout_var_01: int = 0
	var uVar10: int = 0
	var uVar11: int = 0
	var puVar12: int = 0
	var bVar13: int = 0
	var uVar14: int = 0
	var _pc: int = 168
	while true:
		match _pc:
			0:
				return ((0) & 0xff)
			1:
				return ((0x7d) & 0xff)
			2:
				m.set_u32(0xa55d3c, (((((((m.u32(0xa55d3c)) & 0xffffffff) ^ ((((((((((((((((((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xfc000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) ^ ((m.u32(0xa55d3c)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((0xc000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 1
			3:
				_pc = 12 if (int(_zq_signed(iVar4, 32) < _zq_signed(_zq_signed(((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff), 32), 32))) != 0 else 2
			4:
				puVar12 = (((puVar12 + (1) * 2)) & 0xffffffff)
				_pc = 3
			5:
				iVar4 = _zq_signed(_zq_signed((_zq_signed(iVar4, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 4
			6:
				m.set_u16((puVar12 + (_zq_signed((-(3)), 32)) * 2), ((uVar2) & 0xffff))
				_pc = 5
			7:
				uVar2 = ((_zq_signed((_zq_signed(m.u16(((((0xa55d74 + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0xff, 32)), 32), 32) * _zq_signed(0x24, 32)), 32)) * 4) + ((((((uVar10) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 6
			8:
				_pc = 7 if (int(_zq_signed(_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0x4000, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 6
			9:
				uVar2 = ((_zq_signed((_zq_signed(m.u16(((((0xa56434 + ((((((uVar10) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + (_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0xff, 32)), 32)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 8
			10:
				_pc = 9 if (int(_zq_signed(_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0x8000, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 8
			11:
				uVar2 = ((0) & 0xffff)
				_pc = 10
			12:
				uVar11 = ((m.u16(puVar12)) & 0xffff)
				_pc = 11
			13:
				puVar12 = ((((_zq_signed((_zq_signed(_zq_signed(0xa55d44, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			14:
				_pc = 13 if (int(((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 2
			15:
				iVar4 = _zq_signed(0, 32)
				_pc = 14
			16:
				var _v0: int = f5bf800(uVar14)
				_pc = 15
			17:
				uVar14 = ((0x5c) & 0xffffffff)
				_pc = 16
			18:
				_pc = 16
			19:
				uVar14 = ((0x5d) & 0xffffffff)
				_pc = 18
			20:
				_pc = 19 if (int(((uVar6) & 0xffffffff) == ((3) & 0xffffffff))) != 0 else 15
			21:
				_pc = 17 if (int(((uVar6) & 0xffffffff) == ((2) & 0xffffffff))) != 0 else 20
			22:
				return ((100) & 0xff)
			23:
				_pc = 22 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed(uVar10, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 21
			24:
				m.set_u32(0xa55d3c, (((((((((((((((((uVar6) & 0xffffffff) << ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) | (((((((uVar6) & 0xffffffff) << ((0x18) & 31))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | (((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xffffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 23
			25:
				uVar6 = (((((((uVar6) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 24
			26:
				var _v1: int = f5919b0((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff))
				uVar6 = ((_v1) & 0xffffffff)
				_pc = 25
			27:
				return ((0) & 0xff)
			28:
				_pc = 27 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 26
			29:
				var _v2: int = f591d10(uVar10, (((((m.u32(0xa55d3c)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 0xa55d46)
				iVar4 = _zq_signed(_v2, 32)
				_pc = 28
			30:
				m.set_u32(0xa55d3c, (((((((((((((((((m.u32(puVar5)) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | (((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xff0000ff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 29
			31:
				var _v3: int = f40cab0()
				puVar5 = ((((_v3) & 0xffffffff)) & 0xffffffff)
				_pc = 30
			32:
				return ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(int(_zq_signed(iVar4, 32) < _zq_signed(0, 32)), 32) - _zq_signed(1, 32)), 32), 32) & _zq_signed(0x7e, 32)), 32)) & 0xff)
			33:
				var _v4: int = f5af5a0(uVar10, (((extraout_var) << 16) | ((m.u16(param_1)) & 0xffff)), 0)
				iVar4 = _zq_signed(_v4, 32)
				_pc = 32
			34:
				return ((0x7f) & 0xff)
			35:
				var _v5: int = f5bf800(0x5b)
				_pc = 34
			36:
				_pc = 35 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed(uVar10, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 33
			37:
				return ((0) & 0xff)
			38:
				_pc = 37 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 36
			39:
				var _v6: int = f580600(param_1)
				iVar4 = _zq_signed(_v6, 32)
				_pc = 38
			40:
				return ((0x7e) & 0xff)
			41:
				var _v7: int = f40c940(uVar10, 6, uVar1, 0)
				_pc = 40
			42:
				var _v8: int = f4022e0((((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zq_signed(0x62, 32)), 32), 32) >> ((0x10) & 31)), 32), 16)) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar1 = ((_v8) & 0xffff)
				_pc = 41
			43:
				_pc = 2
			44:
				return ((100) & 0xff)
			45:
				m.set_u32(0xa55d3c, (((((((((((((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0x3000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((2) & 31))) & 0xffffffff)) & 0xffffffff) | (((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xf3ffffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 44
			46:
				_pc = 45 if (int((((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xc000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 43
			47:
				var _v9: int = f486ce0(uVar10, m.u32(0xa55048), m.u32(0xa5504c))
				_pc = 46
			48:
				m.set_u32(0xa55d3c, (((((((((((((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xf0000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((0x10000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) ^ (((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xfffffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 47
			49:
				_pc = 48 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 47
			50:
				var _v10: int = f568580(uVar11)
				iVar4 = _zq_signed(_v10, 32)
				_pc = 49
			51:
				var _v11: int = f5920d0(uVar11)
				_pc = 50
			52:
				return ((0x7d) & 0xff)
			53:
				_pc = 52 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 51
			54:
				var _v12: int = f5aa480()
				iVar4 = _zq_signed(_v12, 32)
				_pc = 53
			55:
				return ((0x7d) & 0xff)
			56:
				_pc = 55 if (int((bVar13) == 0)) != 0 else 54
			57:
				return ((0x7d) & 0xff)
			58:
				_pc = 57 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 56
			59:
				var _v13: int = f569e10(m.u32(0xa55044), m.u32(0xa5504c))
				iVar4 = _zq_signed(_v13, 32)
				_pc = 58
			60:
				return ((0x7d) & 0xff)
			61:
				_pc = 60 if (int(((m.u32(0xa55048)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 59
			62:
				_pc = 61 if (int((int(_zq_signed(iVar4, 32) < _zq_signed(0, 32))) != 0 and (int(((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == (((((((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) != 0)) != 0 else 56
			63:
				var _v14: int = f56a030(uVar10)
				iVar4 = _zq_signed(_v14, 32)
				_pc = 62
			64:
				_pc = 68 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 63
			65:
				iVar4 = _zq_signed(_zq_signed((_zq_signed(iVar4, 32) + _zq_signed(_zq_signed((-(1)), 32), 32)), 32), 32)
				_pc = 64
			66:
				psVar9 = (((psVar9 + (1) * 2)) & 0xffffffff)
				_pc = 65
			67:
				bVar13 = ((0) & 0xff)
				_pc = 66
			68:
				_pc = 67 if (int(_zq_signed(_zq_signed(m.u16(psVar9), 16), 32) == _zq_signed(_zq_signed(m.u16(((((((((((((_zq_signed(0xa55d44, 32)) & 0xffffffff) + (((((((uVar8) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 16), 32))) != 0 else 66
			69:
				psVar9 = ((((((((((((((_zq_signed(0xa55d44, 32)) & 0xffffffff) + (((((((uVar6) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 68
			70:
				iVar4 = _zq_signed((((((uVar7) & 0xffffffff) - ((uVar6) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 69
			71:
				_pc = 70 if (int(((uVar6) & 0xffffffff) < ((uVar7) & 0xffffffff))) != 0 else 63
			72:
				uVar7 = ((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 71
			73:
				uVar6 = (((((((uVar8) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 72
			74:
				uVar8 = ((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 73
			75:
				m.set_u16(((((((((((((_zq_signed(0xa55d44, 32)) & 0xffffffff) + (((((((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((_zq_signed((_zq_signed(((m.u32(0xa5504c)) & 0xffff), 32) | _zq_signed(0x4000, 32)), 32)) & 0xffff))
				_pc = 74
			76:
				m.set_u16(((((((((((((_zq_signed(0xa55d44, 32)) & 0xffffffff) + (((((((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((_zq_signed((_zq_signed(((m.u32(0xa5504c)) & 0xffff), 32) | _zq_signed(0x8000, 32)), 32)) & 0xffff))
				_pc = 74
			77:
				_pc = 76 if (int(((m.u32(0xa55048)) & 0xffffffff) == ((0xb) & 0xffffffff))) != 0 else 74
			78:
				_pc = 75 if (int(((m.u32(0xa55048)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 77
			79:
				bVar13 = ((int((((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xf0000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) & 0xff)
				_pc = 78
			80:
				_pc = 79 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 78
			81:
				var _v15: int = f568580(uVar11)
				iVar4 = _zq_signed(_v15, 32)
				_pc = 80
			82:
				bVar13 = ((int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) & 0xff)
				_pc = 81
			83:
				var _v16: int = f592040(uVar11)
				iVar4 = _zq_signed(_v16, 32)
				_pc = 82
			84:
				return ((0x7d) & 0xff)
			85:
				_pc = 84 if (int(_zq_signed(uVar11, 32) == _zq_signed(0, 32))) != 0 else 83
			86:
				return ((0x7d) & 0xff)
			87:
				_pc = 86 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 85
			88:
				var _v17: int = f56b440(uVar11, iVar4)
				iVar4 = _zq_signed(_v17, 32)
				_pc = 87
			89:
				uVar11 = ((_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 88
			90:
				iVar4 = _zq_signed((((((((((((((((((m.u32((0xa55d74 + (((((((((((m.u32(0xa5504c)) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar10) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((((m.u32((0xa55d74 + (((((((((((m.u32(0xa5504c)) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar10) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 89
			91:
				uVar11 = ((m.u16(((((0xa55d74 + ((((((m.u32(0xa5504c)) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar10) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff))) & 0xffff)
				_pc = 90
			92:
				iVar4 = _zq_signed((((((((((((((((((m.u32((0xa56434 + (iVar4) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((((m.u32((0xa56434 + (iVar4) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 89
			93:
				uVar11 = ((m.u16((((0xa56434 + (iVar4) * 4)) & 0xffffffff))) & 0xffff)
				_pc = 92
			94:
				iVar4 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + (((((((uVar10) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 93
			95:
				return ((0x7d) & 0xff)
			96:
				_pc = 95 if (int(((m.u32(0xa55048)) & 0xffffffff) != ((0xb) & 0xffffffff))) != 0 else 94
			97:
				_pc = 91 if (int(((m.u32(0xa55048)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 96
			98:
				return ((0x7d) & 0xff)
			99:
				_pc = 98 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 97
			100:
				var _v18: int = f5aa440(0xf1)
				iVar4 = _zq_signed(_v18, 32)
				_pc = 99
			101:
				return ((0x7e) & 0xff)
			102:
				var _v19: int = f486d20()
				_pc = 101
			103:
				_pc = 102 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 100
			104:
				return ((0) & 0xff)
			105:
				return ((100) & 0xff)
			106:
				var _v20: int = f575af0(uVar10, uVar14, 0x20)
				_pc = 105
			107:
				var _v21: int = f5700f0(uVar10, 0xb, uVar8)
				uVar14 = ((_v21) & 0xffffffff)
				_pc = 106
			108:
				return ((100) & 0xff)
			109:
				var _v22: int = f575a80(uVar10, uVar14, 0x10)
				_pc = 108
			110:
				var _v23: int = f5700f0(uVar10, 0xb, uVar8)
				uVar14 = ((_v23) & 0xffffffff)
				_pc = 109
			111:
				_pc = 110 if (int(_zq_signed(sVar3, 32) == _zq_signed(0x60b, 32))) != 0 else 107
			112:
				var _v24: int = f4022e0(m.u16(param_1))
				sVar3 = _zq_signed(_v24, 16)
				_pc = 111
			113:
				m.set_u16((0xa55d40 + (((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) * 2), ((_zq_signed((_zq_signed(m.u16(((((0xa56434 + (uVar8) * 4) + ((((((uVar10) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32)) & 0xffff))
				_pc = 112
			114:
				var _v25: int = f59d040(uVar10)
				_pc = 113
			115:
				var _v26: int = f5b9170((((((((((((((-(((int(((uVar10) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x5a) & 0xffffffff))) & 0xffffffff), 0xb, uVar8, 0)
				_pc = 114
			116:
				_pc = 122 if (int(_zq_signed(iVar4, 32) < _zq_signed(_zq_signed(((((((((((uVar6) & 0xffffffff) >> ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff), 32), 32))) != 0 else 115
			117:
				puVar12 = (((puVar12 + (1) * 2)) & 0xffffffff)
				_pc = 116
			118:
				iVar4 = _zq_signed(_zq_signed((_zq_signed(iVar4, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 117
			119:
				uVar6 = ((m.u32(0xa55d3c)) & 0xffffffff)
				_pc = 118
			120:
				m.set_u16(puVar12, ((_zq_signed((_zq_signed(uVar11, 32) - _zq_signed(1, 32)), 32)) & 0xffff))
				_pc = 119
			121:
				_pc = 120 if (int((int(_zq_signed(_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0x8000, 32)), 32), 32) != _zq_signed(0, 32))) != 0 and (int(((uVar8) & 0xffffffff) < ((_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0xff, 32)), 32)) & 0xffffffff))) != 0)) != 0 else 118
			122:
				uVar11 = ((m.u16(puVar12)) & 0xffff)
				_pc = 121
			123:
				puVar12 = ((((_zq_signed((_zq_signed(_zq_signed(0xa55d44, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 122
			124:
				_pc = 123 if (int(((uVar7) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 115
			125:
				iVar4 = _zq_signed(0, 32)
				_pc = 124
			126:
				uVar8 = ((_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0xff, 32)), 32)) & 0xffffffff)
				_pc = 125
			127:
				return ((100) & 0xff)
			128:
				var _v27: int = f577950(param_1, uVar10, uVar6, 0x10)
				_pc = 127
			129:
				return ((100) & 0xff)
			130:
				var _v28: int = f577b90(uVar10, uVar6)
				_pc = 129
			131:
				_pc = 130 if (int(_zq_signed(sVar3, 32) != _zq_signed(0x60b, 32))) != 0 else 128
			132:
				var _v29: int = f4022e0(m.u16(param_1))
				sVar3 = _zq_signed(_v29, 16)
				_pc = 131
			133:
				m.set_u16((0xa55d40 + (((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) * 2), ((_zq_signed((_zq_signed(m.u16(((((0xa55d74 + ((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar10) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32)) & 0xffff))
				_pc = 132
			134:
				var _v30: int = f5b9170((((((((((((((-(((int(((uVar10) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x5a) & 0xffffffff))) & 0xffffffff), 0, uVar6, 0)
				_pc = 133
			135:
				uVar6 = ((_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0xff, 32)), 32)) & 0xffffffff)
				_pc = 134
			136:
				_pc = 135 if (int(_zq_signed(_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0x4000, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 127
			137:
				_pc = 136 if (int(_zq_signed(_zq_signed((_zq_signed(uVar11, 32) & _zq_signed(0x8000, 32)), 32), 32) == _zq_signed(0, 32))) != 0 else 126
			138:
				m.set_u32(0xa55d3c, ((uVar6) & 0xffffffff))
				_pc = 137
			139:
				uVar11 = ((m.u16(((((((((((((_zq_signed(0xa55d44, 32)) & 0xffffffff) + (((((((uVar7) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffff)
				_pc = 138
			140:
				uVar7 = ((((((((((((uVar6) & 0xffffffff) >> ((0x1a) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 139
			141:
				uVar6 = (((((((m.u32(0xa55d3c)) & 0xffffffff) ^ ((((((((((((((((((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xfc000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) ^ ((m.u32(0xa55d3c)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((0xc000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 140
			142:
				return ((99) & 0xff)
			143:
				_pc = 142 if (int((((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0xc000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 141
			144:
				_pc = 147 if (int(((uVar6) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 143
			145:
				uVar6 = (((((((uVar6) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 144
			146:
				puVar12 = (((puVar12 + (_zq_signed((-(1)), 32)) * 2)) & 0xffffffff)
				_pc = 145
			147:
				var _v31: int = f5b9170((((((((((((((-(((int(((uVar10) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x59) & 0xffffffff))) & 0xffffffff), _zq_signed((_zq_signed(_zq_signed((-(int(_zq_signed(_zq_signed((_zq_signed(m.u16(puVar12), 32) & _zq_signed(0x8000, 32)), 32), 32) != _zq_signed(0, 32)))), 32), 32) & _zq_signed(0xb, 32)), 32), _zq_signed(m.u16(puVar12), 8), 0)
				_pc = 146
			148:
				puVar12 = ((((((((((((((_zq_signed(0xa55d44, 32)) & 0xffffffff) + ((((((((((((uVar6) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 147
			149:
				_pc = 148 if (int(_zq_signed(_zq_signed((-(1)), 32), 32) < _zq_signed(_zq_signed((((((uVar6) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff), 32), 32))) != 0 else 143
			150:
				uVar6 = ((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 149
			151:
				_pc = 150 if (int(((((((((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((2) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x3000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == (((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0x3000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) != 0 else 143
			152:
				return ((0x61) & 0xff)
			153:
				var _v32: int = f5adb10(uVar10, uVar14, 1, 1, 12, uVar10)
				_pc = 152
			154:
				var _v33: int = f40cab0()
				uVar14 = ((_v33) & 0xffffffff)
				_pc = 153
			155:
				var _v34: int = f5b9170((((((uVar7) & 0xffffffff) | ((0xe9) & 0xffffffff))) & 0xffffffff), uVar14, 0, 0)
				_pc = 154
			156:
				var _v35: int = f4022e0((((((m.u32(0xa55d3c)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff))
				uVar14 = ((_v35) & 0xffffffff)
				_pc = 155
			157:
				var _v36: int = f5b9170((((_zq_signed((((((uVar7) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((0xe8) & 0xff)), uVar14, f4022e0(m.u16(0xa55d42)), f4022e0(uVar6))
				_pc = 156
			158:
				var _v37: int = f4022e0((((extraout_var_01) << 16) | ((m.u16(0xa55d40)) & 0xffff)))
				uVar14 = ((_v37) & 0xffffffff)
				_pc = 157
			159:
				var _v38: int = f4022e0((((extraout_var_00) << 16) | ((m.u16(0xa55d42)) & 0xffff)))
				uVar14 = ((_v38) & 0xffffffff)
				_pc = 158
			160:
				var _v39: int = f4022e0(uVar6)
				uVar14 = ((_v39) & 0xffffffff)
				_pc = 159
			161:
				uVar7 = ((((((((((-(((int(((uVar10) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 160
			162:
				uVar6 = (((((((m.u32(0xa55d44)) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 161
			163:
				uVar6 = ((0) & 0xffffffff)
				_pc = 161
			164:
				_pc = 162 if (int((((((((m.u32(0xa55d3c)) & 0xffffffff) & ((0x3000000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0x3000000) & 0xffffffff))) != 0 else 163
			165:
				var _v40: int = m.u8(((_zq_signed((_zq_signed(_zq_signed(0xa55c88, 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 104
				if _v40 == 0x80: _pc = 39
				if _v40 == 0x7f: _pc = 42
				if _v40 == 0x7e: _pc = 31
				if _v40 == 0x7d: _pc = 103
				if _v40 == 100: _pc = 151
				if _v40 == 99: _pc = 164
				if _v40 == 0x62: _pc = 164
			166:
				return ((0) & 0xff)
			167:
				_pc = 166 if (int(_zq_signed(_zq_signed((_zq_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zq_signed(4, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 165
			168:
				uVar10 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xffff), 32) >> ((0xe) & 31)), 32), 32) & _zq_signed(1, 32)), 32), 32) ^ _zq_signed(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xffff), 32) & _zq_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 167
	return 0


func f592bb0(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var local_200: int = m.local(256)
	var local_100: int = m.local(256)
	var _pc: int = 129
	while true:
		match _pc:
			0:
				return _zq_signed(0, 32)
			1:
				return _zq_signed(0, 32)
			2:
				var _v0: int = f5bf800(0x6f)
				_pc = 1
			3:
				_pc = 39
			4:
				_pc = 3 if (int(_zq_signed(uVar1, 32) == _zq_signed(0x77, 32))) != 0 else 2
			5:
				return _zq_signed(0, 32)
			6:
				var _v1: int = f5bf800(0x61)
				_pc = 5
			7:
				_pc = 6 if (int(_zq_signed(uVar1, 32) == _zq_signed(0x5e, 32))) != 0 else 4
			8:
				return _zq_signed(0, 32)
			9:
				var _v2: int = f5bf800(0x5f)
				_pc = 8
			10:
				_pc = 9 if (int((int(_zq_signed(uVar1, 32) == _zq_signed(0xdf, 32))) != 0 or (int(_zq_signed(uVar1, 32) == _zq_signed(0x53, 32))) != 0)) != 0 else 7
			11:
				_pc = 96
			12:
				_pc = 58
			13:
				return _zq_signed(0, 32)
			14:
				var _v3: int = f5bf800(0x6f)
				_pc = 13
			15:
				_pc = 14 if (int(_zq_signed(uVar1, 32) != _zq_signed(0x1d4, 32))) != 0 else 12
			16:
				_pc = 15 if (int(_zq_signed(uVar1, 32) != _zq_signed(0x15c, 32))) != 0 else 11
			17:
				return _zq_signed(0, 32)
			18:
				var _v4: int = f5bf800(0x66)
				_pc = 17
			19:
				_pc = 18 if (int(_zq_signed(uVar1, 32) == _zq_signed(0x13f, 32))) != 0 else 16
			20:
				_pc = 19 if (int(_zq_signed(0xdf, 32) < _zq_signed(uVar1, 32))) != 0 else 10
			21:
				_pc = 103
			22:
				uVar2 = ((0x6c) & 0xffffffff)
				_pc = 21
			23:
				uVar3 = ((0x1f5) & 0xffffffff)
				_pc = 22
			24:
				_pc = 23 if (int(_zq_signed(uVar1, 32) == _zq_signed(499, 32))) != 0 else 20
			25:
				_pc = 93
			26:
				_pc = 96
			27:
				return _zq_signed(0, 32)
			28:
				var _v5: int = f5bf800(0x7a)
				_pc = 27
			29:
				return _zq_signed(0, 32)
			30:
				var _v6: int = f5bf800(0x76)
				_pc = 29
			31:
				return _zq_signed(0, 32)
			32:
				var _v7: int = f5bf800(0x70)
				_pc = 31
			33:
				return _zq_signed(0, 32)
			34:
				var _v8: int = f5bf800(0x6e)
				_pc = 33
			35:
				_pc = 52
			36:
				var _v9: int = uVar1
				_pc = 2
				if _v9 == 0x2da: _pc = 25
				if _v9 == 0x2d9: _pc = 26
				if _v9 == 0x2ac: _pc = 28
				if _v9 == 0x280: _pc = 30
				if _v9 == 0x243: _pc = 32
				if _v9 == 0x21c: _pc = 34
				if _v9 == 500: _pc = 35
			37:
				_pc = 24 if (int(_zq_signed(uVar1, 32) < _zq_signed(500, 32))) != 0 else 36
			38:
				return _zq_signed(0, 32)
			39:
				var _v10: int = f5bf800(0x62)
				_pc = 38
			40:
				_pc = 39 if (int(_zq_signed(uVar1, 32) == _zq_signed(0x2e6, 32))) != 0 else 37
			41:
				return _zq_signed(0, 32)
			42:
				var _v11: int = f5bf800(0x8d)
				_pc = 41
			43:
				return _zq_signed(0, 32)
			44:
				var _v12: int = f5bf800(0x89)
				_pc = 43
			45:
				return _zq_signed(0, 32)
			46:
				var _v13: int = f5bf800(0x78)
				_pc = 45
			47:
				return _zq_signed(0, 32)
			48:
				var _v14: int = f5bf800(0x88)
				_pc = 47
			49:
				return _zq_signed(0, 32)
			50:
				var _v15: int = f5bf800(0x77)
				_pc = 49
			51:
				return _zq_signed(0, 32)
			52:
				var _v16: int = f5bf800(0x6d)
				_pc = 51
			53:
				return _zq_signed(0, 32)
			54:
				var _v17: int = f5bf800(0x86)
				_pc = 53
			55:
				return _zq_signed(0, 32)
			56:
				var _v18: int = f5bf800(0x85)
				_pc = 55
			57:
				return _zq_signed(0, 32)
			58:
				var _v19: int = f5bf800(0x6b)
				_pc = 57
			59:
				return _zq_signed(0, 32)
			60:
				var _v20: int = f5bf800(0x81)
				_pc = 59
			61:
				return _zq_signed(0, 32)
			62:
				var _v21: int = f5bf800(0x80)
				_pc = 61
			63:
				return _zq_signed(0, 32)
			64:
				var _v22: int = f5bf800(0x7b)
				_pc = 63
			65:
				var _v23: int = uVar1
				_pc = 2
				if _v23 == 0x437: _pc = 42
				if _v23 == 0x430: _pc = 44
				if _v23 == 0x42c: _pc = 46
				if _v23 == 0x413: _pc = 48
				if _v23 == 0x403: _pc = 50
				if _v23 == 0x3ff: _pc = 52
				if _v23 == 0x434: _pc = 54
				if _v23 == 0x3f8: _pc = 54
				if _v23 == 0x433: _pc = 56
				if _v23 == 0x3f7: _pc = 56
				if _v23 == 0x3f1: _pc = 58
				if _v23 == 0x3ec: _pc = 60
				if _v23 == 0x3de: _pc = 62
				if _v23 == 0x3ab: _pc = 64
			66:
				_pc = 40 if (int(_zq_signed(uVar1, 32) < _zq_signed(0x2e7, 32))) != 0 else 65
			67:
				return _zq_signed(0, 32)
			68:
				var _v24: int = f5bf800(0x87)
				_pc = 67
			69:
				_pc = 68 if (int(_zq_signed(uVar1, 32) == _zq_signed(0x43a, 32))) != 0 else 66
			70:
				return _zq_signed(0, 32)
			71:
				var _v25: int = f5bf800(0xa8)
				_pc = 70
			72:
				return _zq_signed(0, 32)
			73:
				var _v26: int = f5bf800(0xa7)
				_pc = 72
			74:
				return _zq_signed(0, 32)
			75:
				var _v27: int = f5bf800(0xa6)
				_pc = 74
			76:
				_pc = 56
			77:
				return _zq_signed(0, 32)
			78:
				var _v28: int = f5bf800(0xa3)
				_pc = 77
			79:
				return _zq_signed(0, 32)
			80:
				var _v29: int = f5bf800(0x57)
				_pc = 79
			81:
				_pc = 46
			82:
				_pc = 64
			83:
				return _zq_signed(0, 32)
			84:
				var _v30: int = f5bf800(local_200)
				_pc = 83
			85:
				var _v31: int = f5bdf40(local_200, 0x99, uVar2)
				_pc = 84
			86:
				var _v32: int = f402290(uVar2)
				uVar2 = ((_v32) & 0xffffffff)
				_pc = 85
			87:
				var _v33: int = f402460(0x57d)
				uVar2 = ((_v33) & 0xffffffff)
				_pc = 86
			88:
				return _zq_signed(0, 32)
			89:
				var _v34: int = f5bf800(0x9e)
				_pc = 88
			90:
				return _zq_signed(0, 32)
			91:
				var _v35: int = f5bf800(0x9d)
				_pc = 90
			92:
				return _zq_signed(0, 32)
			93:
				var _v36: int = f5bf800(99)
				_pc = 92
			94:
				var _v37: int = uVar1
				_pc = 2
				if _v37 == 0x60a: _pc = 71
				if _v37 == 0x609: _pc = 73
				if _v37 == 0x603: _pc = 75
				if _v37 == 0x5fe: _pc = 76
				if _v37 == 0x5f9: _pc = 78
				if _v37 == 0x5ef: _pc = 80
				if _v37 == 0x5ed: _pc = 80
				if _v37 == 0x5ea: _pc = 81
				if _v37 == 0x5ab: _pc = 82
				if _v37 == 0x594: _pc = 87
				if _v37 == 0x589: _pc = 89
				if _v37 == 0x539: _pc = 91
				if _v37 == 0x536: _pc = 93
			95:
				return _zq_signed(0, 32)
			96:
				var _v38: int = f5bf800(100)
				_pc = 95
			97:
				return _zq_signed(0, 32)
			98:
				var _v39: int = f5bf800(0x7e)
				_pc = 97
			99:
				return _zq_signed(0, 32)
			100:
				var _v40: int = f5bf800(0x7d)
				_pc = 99
			101:
				return _zq_signed(0, 32)
			102:
				var _v41: int = f5bf800(local_200)
				_pc = 101
			103:
				var _v42: int = f5bdf40(local_200, uVar2, uVar3)
				_pc = 102
			104:
				uVar2 = ((0x98) & 0xffffffff)
				_pc = 103
			105:
				uVar3 = ((0x1fb) & 0xffffffff)
				_pc = 104
			106:
				return _zq_signed(0, 32)
			107:
				var _v43: int = f5bf800(local_200)
				_pc = 106
			108:
				var _v44: int = f5bdf40(local_200, local_100, 0x207)
				_pc = 107
			109:
				var _v45: int = f5bdf40(local_100, 0x97, uVar2)
				_pc = 108
			110:
				var _v46: int = f402290(uVar2)
				uVar2 = ((_v46) & 0xffffffff)
				_pc = 109
			111:
				var _v47: int = f402460(0x15)
				uVar2 = ((_v47) & 0xffffffff)
				_pc = 110
			112:
				return _zq_signed(0, 32)
			113:
				var _v48: int = f5bf800(0x44)
				_pc = 112
			114:
				return _zq_signed(0, 32)
			115:
				var _v49: int = f5bf800(0x96)
				_pc = 114
			116:
				_pc = 52
			117:
				return _zq_signed(0, 32)
			118:
				var _v50: int = f5bf800(0x90)
				_pc = 117
			119:
				return _zq_signed(0, 32)
			120:
				var _v51: int = f5bf800(0x8f)
				_pc = 119
			121:
				_pc = 42
			122:
				_pc = 2
			123:
				return _zq_signed(0, 32)
			124:
				var _v52: int = f5bf800(0x8e)
				_pc = 123
			125:
				var _v53: int = uVar1
				_pc = 122
				if _v53 == 0x527: _pc = 98
				if _v53 == 0x524: _pc = 100
				if _v53 == 0x4e7: _pc = 105
				if _v53 == 0x4e0: _pc = 111
				if _v53 == 0x4de: _pc = 113
				if _v53 == 0x4dc: _pc = 96
				if _v53 == 0x4c4: _pc = 115
				if _v53 == 0x515: _pc = 116
				if _v53 == 0x4bb: _pc = 116
				if _v53 == 0x486: _pc = 118
				if _v53 == 0x485: _pc = 120
				if _v53 == 0x46f: _pc = 121
				if _v53 == 0x46e: _pc = 121
				if _v53 == 0x446: _pc = 124
			126:
				_pc = 125 if (int(_zq_signed(uVar1, 32) != _zq_signed(0x534, 32))) != 0 else 96
			127:
				_pc = 126 if (int(_zq_signed(uVar1, 32) < _zq_signed(0x535, 32))) != 0 else 94
			128:
				_pc = 69 if (int(_zq_signed(uVar1, 32) < _zq_signed(0x43b, 32))) != 0 else 127
			129:
				var _v54: int = f4022e0(m.u16(param_1))
				uVar1 = ((_v54) & 0xffff)
				_pc = 128
	return 0


func f593530(e: int) -> int:
	var p := _zq_owner(e)
	if _zq_cpu(e):
		m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
		var selected := _s32(f5af5a0(p, m.u16(e), 0))
		if selected >= 0:
			var entry := m.u32(0xa582a4 + selected * 4)
			var owner := (entry >> 12) & 1
			var instance := owner + ((entry >> 24) & 127) * 2
			f5b9170((0x8000 if owner else 0) | 0xdf, f4022e0(entry & 0xfff), instance, 0)
			f5b9170((0x8000 if owner else 0) | 8, owner, 14, 0)
			f592a50(e, entry & 0xffff)
			f592a50(e, entry >> 16)
		return 1
	match m.u8(0xa55c8e):
		0:
			m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
			if f599e30(p, f4022e0(m.u16(e)), 0) == 0: return 1
			f5bf800(0x5e)
		1:
			f40c940(p, 6, f4022e0(m.u16(e)) & 0xffff, 0)
		_:
			var entry := m.u32(f40cab0())
			var owner := (entry >> 12) & 1
			var instance := owner + ((entry >> 24) & 127) * 2
			f5b9170(((entry >> 12) << 15) | 0xdf, f4022e0(entry & 0xfff), instance, 0)
			f5b9170((m.u16(e + 2) << 15) | 8, owner, 14, 0)
			f592a50(e, entry & 0xffff)
			f592a50(e, entry >> 16)
			return 1
	m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
	return 0


func f593740(param_1: int, param_2: int) -> int:
	var cVar1: int = 0
	var bVar2: int = 0
	var bVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var puVar6: int = 0
	var _pc: int = 36
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0xffffffff) & 0xffffffff)
			2:
				var _v0: int = f5bf800(0x107)
				_pc = 1
			3:
				_pc = 2 if (int(_zq_signed(_zq_signed((_zq_signed(_zq_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zq_signed(1, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 1
			4:
				_pc = 25
			5:
				bVar3 = ((m.u8(0xa55c8e)) & 0xff)
				_pc = 4
			6:
				var _v1: int = f5bf9a0(1, 0)
				_pc = 5
			7:
				var _v2: int = f5bf800(0x2f)
				_pc = 6
			8:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 5
			9:
				_pc = 7 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 8
			10:
				_pc = 9 if (bVar2) != 0 else 3
			11:
				_pc = 19 if (int(_zq_signed(iVar4, 32) < _zq_signed(_zq_signed(((((((((((m.u32(0xa55c94)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff), 32), 32))) != 0 else 10
			12:
				puVar6 = (((puVar6 + (1) * 4)) & 0xffffffff)
				_pc = 11
			13:
				iVar4 = _zq_signed(_zq_signed((_zq_signed(iVar4, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 12
			14:
				bVar2 = ((1) & 0xff)
				_pc = 13
			15:
				_pc = 14 if (int(((m.u16(param_1)) & 0xffffffff) == ((uVar5) & 0xffffffff))) != 0 else 13
			16:
				var _v3: int = f568b90((((((m.u32(puVar6)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				uVar5 = ((_v3) & 0xffffffff)
				_pc = 15
			17:
				_pc = 16 if (int((int(_zq_signed(cVar1, 32) == _zq_signed(21, 32))) != 0 or (int(_zq_signed(cVar1, 32) == _zq_signed(28, 32))) != 0)) != 0 else 13
			18:
				cVar1 = _zq_signed(_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed(0xa55c94, 32), 32) + _zq_signed(iVar4, 32)), 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 8), 8)
				_pc = 17
			19:
				m.set_u16((param_1 + (1) * 2), ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed(0xa55c94, 32), 32) + _zq_signed(iVar4, 32)), 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x3f, 32)), 32)) & 0xffff), 32) << ((6) & 31)), 32), 32) | _zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) & _zq_signed(0xf03f, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 18
			20:
				puVar6 = ((((0xa55ca8) & 0xffffffff)) & 0xffffffff)
				_pc = 19
			21:
				_pc = 20 if (int((((((((m.u32(0xa55c94)) & 0xffffffff) & ((0x7f00) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 3
			22:
				iVar4 = _zq_signed(0, 32)
				_pc = 21
			23:
				bVar2 = ((0) & 0xff)
				_pc = 22
			24:
				return ((0) & 0xffffffff)
			25:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(bVar3, 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 24
			26:
				return ((0xffffffff) & 0xffffffff)
			27:
				_pc = 26 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(0, 32))) != 0 else 25
			28:
				bVar3 = ((1) & 0xff)
				_pc = 27
			29:
				return ((0) & 0xffffffff)
			30:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(2, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 29
			31:
				return ((1) & 0xffffffff)
			32:
				_pc = 31 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 30
			33:
				var _v4: int = f593530(param_1)
				iVar4 = _zq_signed(_v4, 32)
				_pc = 32
			34:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(2, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 33
			35:
				_pc = 34 if (int(_zq_signed(m.u8(0xa55c8e), 32) != _zq_signed(1, 32))) != 0 else 28
			36:
				_pc = 35 if (int(_zq_signed(m.u8(0xa55c8e), 32) != _zq_signed(0, 32))) != 0 else 23
	return 0


func f593a20(param_1: int, param_2: int) -> int:
	var sVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var bVar5: int = 0
	var local_100: int = m.local(256)
	var _pc: int = 35
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(_zq_signed((_zq_signed(bVar5, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32), 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 2
			4:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 3
			5:
				var _v0: int = f5bf800(local_100)
				_pc = 4
			6:
				var _v1: int = f5bdf40(local_100, 0x43, uVar3)
				_pc = 5
			7:
				var _v2: int = f402290(uVar3)
				uVar3 = ((_v2) & 0xffffffff)
				_pc = 6
			8:
				var _v3: int = f402460(0x4ea)
				uVar3 = ((_v3) & 0xffffffff)
				_pc = 7
			9:
				var _v4: int = f5bf800(0x65)
				_pc = 4
			10:
				_pc = 8 if (int(_zq_signed(sVar1, 32) == _zq_signed(0x4e9, 32))) != 0 else 9
			11:
				var _v5: int = f4022e0(m.u16(param_1))
				sVar1 = _zq_signed(_v5, 16)
				_pc = 10
			12:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 2
			13:
				return ((1) & 0xffffffff)
			14:
				return ((0) & 0xffffffff)
			15:
				_pc = 14 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 13
			16:
				var _v6: int = f592b00(param_1, uVar3, iVar2)
				iVar2 = _zq_signed(_v6, 32)
				_pc = 15
			17:
				return ((0) & 0xffffffff)
			18:
				_pc = 17 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 16
			19:
				var _v7: int = f57a470(param_1, (((_zq_signed(iVar2, 8)) << 8) | ((_zq_signed(m.u32(0xa55044), 8)) & 0xff)))
				iVar4 = _zq_signed(_v7, 32)
				_pc = 18
			20:
				iVar2 = _zq_signed((((((m.u32(0xa55048)) & 0xffffffff) + ((m.u32(0xa5504c)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 19
			21:
				return ((0) & 0xffffffff)
			22:
				_pc = 21 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 20
			23:
				uVar3 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 22
			24:
				var _v8: int = f5aa440(0xe000e0)
				iVar2 = _zq_signed(_v8, 32)
				_pc = 23
			25:
				var _v9: int = f5929d0()
				_pc = 24
			26:
				_pc = 25 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 12
			27:
				_pc = 11 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(0, 32))) != 0 else 26
			28:
				return ((uVar3) & 0xffffffff)
			29:
				var _v10: int = f5b3fa0(param_1, param_2, 300)
				uVar3 = ((_v10) & 0xffffffff)
				_pc = 28
			30:
				_pc = 29 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 27
			31:
				return ((1) & 0xffffffff)
			32:
				_pc = 31 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 30
			33:
				var _v11: int = f59dca0(param_1)
				iVar2 = _zq_signed(_v11, 32)
				_pc = 32
			34:
				return ((1) & 0xffffffff)
			35:
				_pc = 34 if (int(_zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) & _zq_signed(0x3000, 32)), 32), 32) == _zq_signed(0x2000, 32))) != 0 else 33
	return 0


func f593cf0(param_1: int) -> int:
	var iVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var bVar4: int = 0
	var uVar5: int = 0
	var unaff_EBP: int = 0
	var iVar6: int = 0
	var uVar7: int = 0
	var local_4: int = 0
	var _pc: int = 77
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar4, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar4 = ((_zq_signed((_zq_signed(bVar4, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				bVar4 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 3
			5:
				_pc = 1
			6:
				_pc = 3
			7:
				bVar4 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 6
			8:
				return ((1) & 0xffffffff)
			9:
				return ((0) & 0xffffffff)
			10:
				_pc = 9 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 8
			11:
				var _v0: int = f592b00(param_1, uVar7, iVar2)
				iVar2 = _zq_signed(_v0, 32)
				_pc = 10
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 11
			14:
				var _v1: int = f57a630(param_1, uVar5)
				iVar1 = _zq_signed(_v1, 32)
				_pc = 13
			15:
				return ((0) & 0xffffffff)
			16:
				_pc = 15 if (int(((uVar3) & 0xffffffff) == ((uVar5) & 0xffffffff))) != 0 else 14
			17:
				var _v2: int = f583440(param_1, 0)
				uVar3 = ((_v2) & 0xffffffff)
				_pc = 16
			18:
				uVar5 = (((((((_zq_signed(iVar2, 8)) << 8) | ((_zq_signed(m.u32(0xa55044), 8)) & 0xff))) & 0xffffffff)) & 0xffffffff)
				_pc = 17
			19:
				iVar2 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 18
			20:
				return ((0) & 0xffffffff)
			21:
				_pc = 20 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 19
			22:
				uVar7 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 21
			23:
				var _v3: int = f5aa440(0xe000e0)
				iVar2 = _zq_signed(_v3, 32)
				_pc = 22
			24:
				var _v4: int = f5929d0()
				_pc = 23
			25:
				_pc = 24 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 7
			26:
				return ((0) & 0xffffffff)
			27:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar4, 32)), 32)) & 0xffff))
				_pc = 26
			28:
				bVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 27
			29:
				var _v5: int = f5bf800(uVar7)
				_pc = 28
			30:
				uVar7 = ((0x6a) & 0xffffffff)
				_pc = 29
			31:
				return ((1) & 0xffffffff)
			32:
				_pc = 31 if (int(_zq_signed(_zq_signed((_zq_signed(iVar2, 32) + _zq_signed(iVar1, 32)), 32), 32) == _zq_signed(1, 32))) != 0 else 4
			33:
				var _v6: int = f569d50(0)
				iVar1 = _zq_signed(_v6, 32)
				_pc = 32
			34:
				var _v7: int = f569d50(1)
				iVar2 = _zq_signed(_v7, 32)
				_pc = 33
			35:
				return ((0) & 0xffffffff)
			36:
				_pc = 35 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 34
			37:
				var _v8: int = f592b00(param_1, uVar7, iVar2)
				iVar2 = _zq_signed(_v8, 32)
				_pc = 36
			38:
				return ((0) & 0xffffffff)
			39:
				_pc = 38 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 37
			40:
				var _v9: int = f57a630(param_1, (((_zq_signed(iVar2, 8)) << 8) | ((_zq_signed(m.u32(0xa55044), 8)) & 0xff)))
				iVar1 = _zq_signed(_v9, 32)
				_pc = 39
			41:
				iVar2 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 40
			42:
				return ((0) & 0xffffffff)
			43:
				_pc = 42 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 41
			44:
				uVar7 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 43
			45:
				var _v10: int = f5aa440(0xe000e0)
				iVar2 = _zq_signed(_v10, 32)
				_pc = 44
			46:
				var _v11: int = f5929d0()
				_pc = 45
			47:
				_pc = 7
			48:
				_pc = 47 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 46
			49:
				_pc = 29
			50:
				uVar7 = ((0x69) & 0xffffffff)
				_pc = 49
			51:
				return ((1) & 0xffffffff)
			52:
				_pc = 51 if (int(_zq_signed(iVar2, 32) < _zq_signed(2, 32))) != 0 else 4
			53:
				var _v12: int = f59dca0(param_1)
				iVar2 = _zq_signed(_v12, 32)
				_pc = 52
			54:
				m.set_u16((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 53
			55:
				var _v13: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 5
				if _v13 == 4: _pc = 25
				if _v13 == 3: _pc = 30
				if _v13 == 2: _pc = 48
				if _v13 == 1: _pc = 50
				if _v13 == 0: _pc = 54
			56:
				return ((1) & 0xffffffff)
			57:
				_pc = 69 if (int(_zq_signed(local_4, 32) < _zq_signed(2, 32))) != 0 else 56
			58:
				local_4 = _zq_signed(_zq_signed((_zq_signed(local_4, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 57
			59:
				_pc = 66 if (int(_zq_signed(_zq_signed(param_1, 32), 32) < _zq_signed(5, 32))) != 0 else 58
			60:
				param_1 = (((((((param_1) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 59
			61:
				return ((1) & 0xffffffff)
			62:
				_pc = 61 if (int(_zq_signed(iVar6, 32) == _zq_signed(2, 32))) != 0 else 60
			63:
				iVar6 = _zq_signed(_zq_signed((_zq_signed(iVar6, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 62
			64:
				var _v14: int = f592a90(iVar2, bVar4, param_1)
				_pc = 63
			65:
				_pc = 64 if (int(_zq_signed(iVar1, 32) != _zq_signed(0, 32))) != 0 else 60
			66:
				var _v15: int = f57a630(iVar2, (((((((((((((((param_1) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((unaff_EBP) & 0xffffffff))) & 0xffffffff))
				iVar1 = _zq_signed(_v15, 32)
				_pc = 65
			67:
				unaff_EBP = (((((_zq_signed((((((unaff_EBP) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((bVar4) & 0xffff)) & 0xffff))) & 0xffffffff)
				_pc = 66
			68:
				param_1 = ((0) & 0xffffffff)
				_pc = 67
			69:
				bVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(iVar2, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32) ^ _zq_signed(int(_zq_signed(local_4, 32) == _zq_signed(0, 32)), 32)), 32)) & 0xff)
				_pc = 68
			70:
				local_4 = _zq_signed(0, 32)
				_pc = 69
			71:
				return ((1) & 0xffffffff)
			72:
				_pc = 71 if (int(_zq_signed(iVar1, 32) < _zq_signed(2, 32))) != 0 else 70
			73:
				var _v16: int = f59dca0(param_1)
				iVar1 = _zq_signed(_v16, 32)
				_pc = 72
			74:
				iVar6 = _zq_signed(0, 32)
				_pc = 73
			75:
				m.set_u16((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 74
			76:
				_pc = 75 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8((((((((param_1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 55
			77:
				iVar2 = _zq_signed(param_1, 32)
				_pc = 76
	return 0


func f593f80(param_1: int, param_2: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var iVar5: int = 0
	var local_104: int = 0
	var local_100: int = m.local(256)
	var _pc: int = 65
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 1
			3:
				var _v0: int = f5bf800(local_100)
				_pc = 2
			4:
				var _v1: int = f5bdfc0(local_100, 0x71, 2)
				_pc = 3
			5:
				return ((1) & 0xffffffff)
			6:
				_pc = 5 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 4
			7:
				var _v2: int = f57fa90()
				iVar4 = _zq_signed(_v2, 32)
				_pc = 6
			8:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 7
			9:
				return ((0) & 0xffffffff)
			10:
				_pc = 9 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 2
			11:
				var _v3: int = f592b00(param_1, uVar1, iVar4)
				iVar4 = _zq_signed(_v3, 32)
				_pc = 10
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zq_signed(iVar5, 32) == _zq_signed(0, 32))) != 0 else 11
			14:
				var _v4: int = f59dc50(param_1, uVar1, iVar4)
				iVar5 = _zq_signed(_v4, 32)
				_pc = 13
			15:
				return ((0) & 0xffffffff)
			16:
				_pc = 15 if (int(((uVar3) & 0xffffffff) == (((((_zq_signed(iVar4, 8)) << 8) | ((_zq_signed(uVar1, 8)) & 0xff))) & 0xffffffff))) != 0 else 14
			17:
				var _v5: int = f583440(param_1, 0)
				uVar3 = ((_v5) & 0xffffffff)
				_pc = 16
			18:
				iVar4 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 17
			19:
				return ((0) & 0xffffffff)
			20:
				_pc = 19 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 18
			21:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 20
			22:
				var _v6: int = f5aa440(0x20002)
				iVar4 = _zq_signed(_v6, 32)
				_pc = 21
			23:
				var _v7: int = f5929d0()
				_pc = 22
			24:
				return ((0) & 0xffffffff)
			25:
				_pc = 24 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 23
			26:
				return ((1) & 0xffffffff)
			27:
				_pc = 26 if (int(_zq_signed(m.u8(0xa55c8e), 32) != _zq_signed(2, 32))) != 0 else 25
			28:
				return ((0) & 0xffffffff)
			29:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 28
			30:
				return ((0) & 0xffffffff)
			31:
				_pc = 30 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 29
			32:
				var _v8: int = f592b00(param_1, uVar1, iVar4)
				iVar4 = _zq_signed(_v8, 32)
				_pc = 31
			33:
				return ((0) & 0xffffffff)
			34:
				_pc = 33 if (int(_zq_signed(iVar5, 32) == _zq_signed(0, 32))) != 0 else 32
			35:
				var _v9: int = f59dc50(param_1, m.u32(0xa55044), iVar4)
				iVar5 = _zq_signed(_v9, 32)
				_pc = 34
			36:
				iVar4 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 35
			37:
				return ((0) & 0xffffffff)
			38:
				_pc = 37 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 36
			39:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 38
			40:
				var _v10: int = f5aa440(0x20002)
				iVar4 = _zq_signed(_v10, 32)
				_pc = 39
			41:
				var _v11: int = f5929d0()
				_pc = 40
			42:
				return ((0) & 0xffffffff)
			43:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(1, 32)), 32)) & 0xffff))
				_pc = 42
			44:
				_pc = 43 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 41
			45:
				_pc = 44 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(1, 32))) != 0 else 27
			46:
				_pc = 8 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(0, 32))) != 0 else 45
			47:
				return ((1) & 0xffffffff)
			48:
				_pc = 61 if (int(_zq_signed(local_104, 32) < _zq_signed(2, 32))) != 0 else 47
			49:
				local_104 = _zq_signed(_zq_signed((_zq_signed(local_104, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 48
			50:
				_pc = 57 if (int(_zq_signed(iVar5, 32) < _zq_signed(0xb, 32))) != 0 else 49
			51:
				iVar5 = _zq_signed(_zq_signed((_zq_signed(iVar5, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 50
			52:
				return ((1) & 0xffffffff)
			53:
				_pc = 52 if (int(_zq_signed(iVar4, 32) == _zq_signed(2, 32))) != 0 else 51
			54:
				iVar4 = _zq_signed(_zq_signed((_zq_signed(iVar4, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 53
			55:
				var _v12: int = f592a90(param_1, uVar3, iVar5)
				_pc = 54
			56:
				_pc = 55 if (int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0 else 51
			57:
				var _v13: int = f59dc50(param_1, uVar3, iVar5)
				iVar2 = _zq_signed(_v13, 32)
				_pc = 56
			58:
				iVar5 = _zq_signed(5, 32)
				_pc = 57
			59:
				uVar3 = ((_zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 58
			60:
				uVar3 = ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 58
			61:
				_pc = 59 if (int(_zq_signed(local_104, 32) == _zq_signed(0, 32))) != 0 else 60
			62:
				local_104 = _zq_signed(0, 32)
				_pc = 61
			63:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 62
			64:
				iVar4 = _zq_signed(0, 32)
				_pc = 63
			65:
				_pc = 64 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 46
	return 0


func f594200(param_1: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var bVar5: int = 0
	var iVar6: int = 0
	var bVar7: int = 0
	var uVar8: int = 0
	var _pc: int = 76
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar5, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar5 = ((_zq_signed((_zq_signed(bVar5, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				_pc = 1
			5:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 3
			6:
				return ((1) & 0xffffffff)
			7:
				return ((0) & 0xffffffff)
			8:
				_pc = 7 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 6
			9:
				var _v0: int = f592b00(param_1, uVar8, iVar1)
				iVar1 = _zq_signed(_v0, 32)
				_pc = 8
			10:
				return ((0) & 0xffffffff)
			11:
				_pc = 10 if (int(_zq_signed(iVar6, 32) == _zq_signed(0, 32))) != 0 else 9
			12:
				var _v1: int = f59dc50(param_1, uVar8, iVar1)
				iVar6 = _zq_signed(_v1, 32)
				_pc = 11
			13:
				return ((0) & 0xffffffff)
			14:
				_pc = 13 if (int(((uVar2) & 0xffffffff) == (((((_zq_signed(iVar1, 8)) << 8) | ((_zq_signed(uVar8, 8)) & 0xff))) & 0xffffffff))) != 0 else 12
			15:
				var _v2: int = f583440(param_1, 0)
				uVar2 = ((_v2) & 0xffffffff)
				_pc = 14
			16:
				iVar1 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 15
			17:
				return ((0) & 0xffffffff)
			18:
				_pc = 17 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 16
			19:
				uVar8 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 18
			20:
				var _v3: int = f5aa440(0xf000f0)
				iVar1 = _zq_signed(_v3, 32)
				_pc = 19
			21:
				var _v4: int = f5929d0()
				_pc = 20
			22:
				_pc = 21 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 5
			23:
				return ((1) & 0xffffffff)
			24:
				_pc = 23 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(0, 32))) != 0 else 22
			25:
				return ((0) & 0xffffffff)
			26:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar5, 32)), 32)) & 0xffff))
				_pc = 25
			27:
				bVar5 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 26
			28:
				var _v5: int = f5bf9a0(1, 0)
				_pc = 27
			29:
				var _v6: int = f5bf800(uVar8)
				_pc = 28
			30:
				uVar8 = ((0x75) & 0xffffffff)
				_pc = 29
			31:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 3
			32:
				return ((1) & 0xffffffff)
			33:
				_pc = 32 if (int(_zq_signed(iVar1, 32) == _zq_signed(1, 32))) != 0 else 31
			34:
				var _v7: int = f59dca0(param_1)
				iVar1 = _zq_signed(_v7, 32)
				_pc = 33
			35:
				return ((0) & 0xffffffff)
			36:
				_pc = 35 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 34
			37:
				var _v8: int = f592b00(param_1, uVar8, iVar1)
				iVar1 = _zq_signed(_v8, 32)
				_pc = 36
			38:
				return ((0) & 0xffffffff)
			39:
				_pc = 38 if (int(_zq_signed(iVar6, 32) == _zq_signed(0, 32))) != 0 else 37
			40:
				var _v9: int = f59dc50(param_1, m.u32(0xa55044), iVar1)
				iVar6 = _zq_signed(_v9, 32)
				_pc = 39
			41:
				iVar1 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 40
			42:
				return ((0) & 0xffffffff)
			43:
				_pc = 42 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 41
			44:
				uVar8 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 43
			45:
				var _v10: int = f5aa440(0xf000f0)
				iVar1 = _zq_signed(_v10, 32)
				_pc = 44
			46:
				var _v11: int = f5929d0()
				_pc = 45
			47:
				_pc = 5
			48:
				_pc = 47 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 46
			49:
				return ((0xffffffff) & 0xffffffff)
			50:
				_pc = 49 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(0, 32))) != 0 else 48
			51:
				_pc = 29
			52:
				uVar8 = ((0x73) & 0xffffffff)
				_pc = 51
			53:
				return ((0xffffffff) & 0xffffffff)
			54:
				_pc = 53 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 52
			55:
				var _v12: int = f59dca0(param_1)
				iVar1 = _zq_signed(_v12, 32)
				_pc = 54
			56:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 55
			57:
				var _v13: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 4
				if _v13 == 3: _pc = 24
				if _v13 == 2: _pc = 30
				if _v13 == 1: _pc = 50
				if _v13 == 0: _pc = 56
			58:
				return ((1) & 0xffffffff)
			59:
				_pc = 64 if (int(_zq_signed(iVar1, 32) != _zq_signed(0, 32))) != 0 else 58
			60:
				iVar1 = _zq_signed(_zq_signed((_zq_signed(iVar1, 32) + _zq_signed(_zq_signed((-(1)), 32), 32)), 32), 32)
				_pc = 59
			61:
				var _v14: int = f592a90(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32), 32)), 32), iVar6)
				_pc = 60
			62:
				var _v16: int = int((int(_zq_signed(_zq_signed((-(1)), 32), 32) < _zq_signed(iVar6, 32))) != 0)
				if _v16 != 0:
					var _v15: int = f59dc50(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32), 32)), 32), iVar6)
					iVar3 = _zq_signed(_v15, 32)
					_v16 = int((int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0)
				_pc = 61 if (_v16) != 0 else 60
			63:
				var _v17: int = f5b0090(uVar2, (((((1) & 0xffffffff) - ((uVar2) & 0xffffffff))) & 0xffffffff), iVar6, 1, 1)
				iVar6 = _zq_signed(_v17, 32)
				_pc = 62
			64:
				uVar2 = ((_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 63
			65:
				iVar1 = _zq_signed((((((2) & 0xffffffff) - ((((bVar7) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 64
			66:
				var _v18: int = f592a90(param_1, uVar4, uVar2)
				_pc = 65
			67:
				_pc = 66 if (bVar7) != 0 else 65
			68:
				bVar7 = ((int(_zq_signed(_zq_signed((_zq_signed(((m.u32((0xa55d74 + (((((((((((uVar2) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zq_signed(0xfff, 32)), 32), 32) == _zq_signed(m.u16(param_1), 32))) & 0xff)
				_pc = 67
			69:
				uVar2 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zq_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 68
			70:
				uVar4 = ((_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 69
			71:
				return ((0xffffffff) & 0xffffffff)
			72:
				_pc = 71 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 70
			73:
				var _v19: int = f59dd20(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) & _zq_signed(1, 32)), 32), 32)), 32))
				iVar1 = _zq_signed(_v19, 32)
				_pc = 72
			74:
				iVar6 = _zq_signed(_zq_signed((-(1)), 32), 32)
				_pc = 73
			75:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 74
			76:
				_pc = 75 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 57
	return 0


func f594520(param_1: int) -> int:
	var bVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var bVar6: int = 0
	var _pc: int = 44
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar6, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar6 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				_pc = 1
			5:
				return ((1) & 0xffffffff)
			6:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar6, 32)), 32)) & 0xffff))
				_pc = 5
			7:
				bVar6 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 6
			8:
				var _v1: int = int((int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0)
				if _v1 != 0:
					var _v0: int = f592b00(param_1, uVar2, iVar3)
					iVar3 = _zq_signed(_v0, 32)
					_v1 = int((int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0)
				_pc = 7 if (_v1) != 0 else 4
			9:
				var _v2: int = f59dc50(param_1, m.u32(0xa55044), iVar3)
				iVar4 = _zq_signed(_v2, 32)
				_pc = 8
			10:
				iVar3 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 9
			11:
				_pc = 10 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 4
			12:
				uVar2 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 11
			13:
				var _v3: int = f5aa440(0xe0)
				iVar3 = _zq_signed(_v3, 32)
				_pc = 12
			14:
				var _v4: int = f5929d0()
				_pc = 13
			15:
				return ((0) & 0xffffffff)
			16:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar6, 32)), 32)) & 0xffff))
				_pc = 15
			17:
				bVar6 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 16
			18:
				_pc = 17 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 14
			19:
				var _v5: int = f5bf800(0x79)
				_pc = 3
			20:
				return ((1) & 0xffffffff)
			21:
				var _v6: int = f592a90(param_1, _zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), uVar2)
				_pc = 20
			22:
				var _v7: int = f5b0150(param_1, _zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 0xffffffff, 1)
				uVar2 = ((_v7) & 0xffffffff)
				_pc = 21
			23:
				_pc = 22 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 19
			24:
				return ((1) & 0xffffffff)
			25:
				_pc = 24 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(0, 32))) != 0 else 3
			26:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(10, 32)), 32)) & 0xffffffff), _zq_signed(_zq_signed((_zq_signed(m.u16(0xa558b4), 32) + _zq_signed(1, 32)), 32), 16))
				_pc = 25
			27:
				m.set_u16(0xa558b4, ((0) & 0xffff))
				_pc = 3
			28:
				_pc = 27 if (bVar1) != 0 else 3
			29:
				var _v8: int = f5bf9a0(3, 0xffffffff)
				_pc = 3
			30:
				var _v9: int = f5bf800(0x103)
				_pc = 29
			31:
				m.set_u16(0xa558b4, ((2) & 0xffff))
				_pc = 3
			32:
				_pc = 30 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 31
			33:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 3
			34:
				_pc = 32 if (bVar1) != 0 else 33
			35:
				_pc = 28 if (int(_zq_signed(iVar3, 32) < _zq_signed(1, 32))) != 0 else 34
			36:
				bVar1 = ((1) & 0xff)
				_pc = 35
			37:
				var _v11: int = int((int((int((((((((m.u32((0xa55d74 + ((((((_zq_signed((_zq_signed(_zq_signed((_zq_signed(bVar6, 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x351, 32)), 32)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zq_signed(_zq_signed((_zq_signed(m.u8(((((0xa55d7a + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(bVar6, 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x6a2, 32)), 32)) * 2) + ((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32) == _zq_signed(0, 32))) != 0)) != 0)
				if _v11 != 0:
					var _v10: int = f56c510(bVar6, uVar5)
					iVar4 = _zq_signed(_v10, 32)
					_v11 = int((int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0)
				_pc = 36 if (int((_v11) != 0 and (int(_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32) != _zq_signed(bVar6, 32))) != 0)) != 0 else 35
			38:
				uVar5 = ((((m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(0x11, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 37
			39:
				bVar6 = ((m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(0x10, 32)), 32)) & 0xffffffff))) & 0xff)
				_pc = 38
			40:
				_pc = 39 if (int(_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0xfc0, 32)), 32), 32) == _zq_signed(0x480, 32))) != 0 else 35
			41:
				bVar1 = ((0) & 0xff)
				_pc = 40
			42:
				var _v12: int = f59dca0(param_1)
				iVar3 = _zq_signed(_v12, 32)
				_pc = 41
			43:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 42
			44:
				var _v13: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 4
				if _v13 == 3: _pc = 18
				if _v13 == 2: _pc = 23
				if _v13 == 1: _pc = 26
				if _v13 == 0: _pc = 43
	return 0


func f5948b0(param_1: int, param_2: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var bVar4: int = 0
	var _pc: int = 34
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar4, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				return ((0) & 0xffffffff)
			5:
				return ((1) & 0xffffffff)
			6:
				var _v0: int = f592a50(param_1, _zq_signed((_zq_signed(m.u16(0xa558b4), 32) + _zq_signed(1, 32)), 32))
				_pc = 5
			7:
				var _v1: int = f5bf9a0(2, 0)
				_pc = 3
			8:
				var _v2: int = f5bf800(0x7f)
				_pc = 7
			9:
				return ((0) & 0xffffffff)
			10:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar4, 32)), 32)) & 0xffff))
				_pc = 9
			11:
				bVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 10
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 11
			14:
				var _v3: int = f592b00(param_1, uVar1, iVar2)
				iVar2 = _zq_signed(_v3, 32)
				_pc = 13
			15:
				return ((0) & 0xffffffff)
			16:
				_pc = 15 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 14
			17:
				var _v4: int = f57a470(param_1, (((_zq_signed(iVar2, 8)) << 8) | ((_zq_signed(m.u32(0xa55044), 8)) & 0xff)))
				iVar3 = _zq_signed(_v4, 32)
				_pc = 16
			18:
				iVar2 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 17
			19:
				return ((0) & 0xffffffff)
			20:
				_pc = 19 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 18
			21:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 20
			22:
				var _v5: int = f5aa440(0xe000e0)
				iVar2 = _zq_signed(_v5, 32)
				_pc = 21
			23:
				var _v6: int = f5929d0()
				_pc = 22
			24:
				return ((0) & 0xffffffff)
			25:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar4, 32)), 32)) & 0xffff))
				_pc = 24
			26:
				bVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 25
			27:
				_pc = 26 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 23
			28:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 3
			29:
				var _v7: int = f5bf800(0x65)
				_pc = 28
			30:
				var _v8: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 4
				if _v8 == 3: _pc = 6
				if _v8 == 2: _pc = 8
				if _v8 == 1: _pc = 27
				if _v8 == 0: _pc = 29
			31:
				return ((1) & 0xffffffff)
			32:
				var _v9: int = f592a50(param_1, 1)
				_pc = 31
			33:
				var _v10: int = f5b3fa0(param_1, param_2, 300)
				_pc = 32
			34:
				_pc = 33 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 30
	return 0


func f594a10(param_1: int, param_2: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var _pc: int = 20
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 1
			3:
				var _v0: int = f5bf800(0x10f)
				_pc = 2
			4:
				return ((1) & 0xffffffff)
			5:
				var _v1: int = f592a50(param_1, _zq_signed((_zq_signed(m.u16(((((0xa55d74 + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(0x10, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1e00, 32)), 32), 32) >> ((9) & 31)), 32), 32) * _zq_signed(0x24, 32)), 32)) * 4) + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(0x10, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x351, 32)), 32)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32))
				_pc = 4
			6:
				var _v2: int = f592a90(param_1, _zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(0x10, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x100, 32)), 32), 32) >> ((8) & 31)), 32), _zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(0x10, 32)), 32)) & 0xffffffff)), 32) >> ((9) & 31)), 32), 32) & _zq_signed(0xf, 32)), 32))
				_pc = 5
			7:
				_pc = 6 if (int(_zq_signed(iVar1, 32) < _zq_signed(2, 32))) != 0 else 3
			8:
				var _v3: int = f59dca0(param_1)
				iVar1 = _zq_signed(_v3, 32)
				_pc = 7
			9:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 8
			10:
				_pc = 16
			11:
				var _v4: int = f583440(param_1, 0)
				uVar2 = ((_v4) & 0xffffffff)
				_pc = 10
			12:
				_pc = 11 if (int(_zq_signed(iVar1, 32) != _zq_signed(0, 32))) != 0 else 1
			13:
				var _v5: int = f593440(param_1, param_2)
				iVar1 = _zq_signed(_v5, 32)
				_pc = 12
			14:
				_pc = 9 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(0, 32))) != 0 else 13
			15:
				return ((1) & 0xffffffff)
			16:
				var _v6: int = f592a50(param_1, _zq_signed((_zq_signed(m.u16(((((0xa55d74 + ((((((((((((((((uVar2) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + (((((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32))
				_pc = 15
			17:
				var _v7: int = f583440(param_1, 0)
				uVar2 = ((_v7) & 0xffffffff)
				_pc = 16
			18:
				_pc = 17 if (int(_zq_signed(iVar1, 32) != _zq_signed(0, 32))) != 0 else 1
			19:
				var _v8: int = f5b3fa0(param_1, param_2, 0)
				iVar1 = _zq_signed(_v8, 32)
				_pc = 18
			20:
				_pc = 14 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 19
	return 0


func f594c00(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var bVar5: int = 0
	var _pc: int = 68
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((1) & 0xffffffff)
			2:
				var _v0: int = f592b00(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32)), 32), iVar2)
				_pc = 1
			3:
				var _v2: int = int((int(_zq_signed(_zq_signed((-(1)), 32), 32) < _zq_signed(iVar2, 32))) != 0)
				if _v2 != 0:
					var _v1: int = f592b00(param_1, _zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), iVar2)
					iVar3 = _zq_signed(_v1, 32)
					_v2 = int((int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0)
				var _v4: int = int((_v2) != 0)
				if _v4 != 0:
					var _v3: int = f5b3d80(param_1, _zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 0xffffffff, 0xffffffff, iVar2)
					iVar2 = _zq_signed(_v3, 32)
					_v4 = int((int(_zq_signed(_zq_signed((-(1)), 32), 32) < _zq_signed(iVar2, 32))) != 0)
				var _v8: int = int((_v4) != 0)
				if _v8 != 0:
					var _v5: int = f592b00(param_1, _zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), iVar2)
					iVar2 = _zq_signed(_v5, 32)
					var _v7: int = int((int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0)
					if _v7 != 0:
						var _v6: int = f5b3d80(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32)), 32), 1, 0, 0xffffffff)
						iVar2 = _zq_signed(_v6, 32)
						_v7 = int((int(_zq_signed(_zq_signed((-(1)), 32), 32) < _zq_signed(iVar2, 32))) != 0)
					_v8 = int((_v7) != 0)
				_pc = 2 if (_v8) != 0 else 1
			4:
				var _v9: int = f5b3d80(param_1, _zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 0xffffffff, 0xffffffff, 0xffffffff)
				iVar2 = _zq_signed(_v9, 32)
				_pc = 3
			5:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 4
			6:
				return ((0) & 0xffffffff)
			7:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar5, 32)), 32)) & 0xffff))
				_pc = 6
			8:
				bVar5 = ((_zq_signed((_zq_signed(bVar5, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 7
			9:
				_pc = 1
			10:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 8
			11:
				return ((0) & 0xffffffff)
			12:
				return ((1) & 0xffffffff)
			13:
				var _v11: int = int((int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0)
				if _v11 != 0:
					var _v10: int = f592b00(param_1, uVar1, iVar2)
					iVar2 = _zq_signed(_v10, 32)
					_v11 = int((int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0)
				_pc = 12 if (_v11) != 0 else 11
			14:
				var _v12: int = f59dc50(param_1, m.u32(0xa55044), iVar2)
				iVar3 = _zq_signed(_v12, 32)
				_pc = 13
			15:
				iVar2 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 14
			16:
				_pc = 15 if (int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0 else 11
			17:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 16
			18:
				var _v13: int = f5aa440(0xf00000)
				iVar2 = _zq_signed(_v13, 32)
				_pc = 17
			19:
				var _v14: int = f5929d0()
				_pc = 18
			20:
				_pc = 19 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 10
			21:
				return ((0) & 0xffffffff)
			22:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar5, 32)), 32)) & 0xffff))
				_pc = 21
			23:
				bVar5 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 22
			24:
				var _v15: int = f5bf800(0x84)
				_pc = 23
			25:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 8
			26:
				return ((0) & 0xffffffff)
			27:
				_pc = 26 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 25
			28:
				var _v16: int = f592b00(param_1, uVar1, iVar2)
				iVar2 = _zq_signed(_v16, 32)
				_pc = 27
			29:
				return ((0) & 0xffffffff)
			30:
				_pc = 29 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 28
			31:
				var _v17: int = f59dc50(param_1, uVar1, iVar2)
				iVar3 = _zq_signed(_v17, 32)
				_pc = 30
			32:
				return ((0) & 0xffffffff)
			33:
				_pc = 32 if (int(((uVar4) & 0xffffffff) == (((((_zq_signed(iVar2, 8)) << 8) | ((_zq_signed(uVar1, 8)) & 0xff))) & 0xffffffff))) != 0 else 31
			34:
				var _v18: int = f583440(param_1, 0)
				uVar4 = ((_v18) & 0xffffffff)
				_pc = 33
			35:
				iVar2 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 34
			36:
				return ((0) & 0xffffffff)
			37:
				_pc = 36 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 35
			38:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 37
			39:
				var _v19: int = f5aa440(0xf0)
				iVar2 = _zq_signed(_v19, 32)
				_pc = 38
			40:
				var _v20: int = f5929d0()
				_pc = 39
			41:
				_pc = 47
			42:
				_pc = 41 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 40
			43:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 8
			44:
				var _v21: int = f5bf800(0x83)
				_pc = 43
			45:
				return ((0) & 0xffffffff)
			46:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar5, 32)), 32)) & 0xffff))
				_pc = 45
			47:
				bVar5 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 46
			48:
				return ((0) & 0xffffffff)
			49:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar5, 32)), 32)) & 0xffff))
				_pc = 48
			50:
				bVar5 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 49
			51:
				return ((0) & 0xffffffff)
			52:
				_pc = 51 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 50
			53:
				var _v22: int = f592b00(param_1, uVar1, iVar2)
				iVar2 = _zq_signed(_v22, 32)
				_pc = 52
			54:
				return ((0) & 0xffffffff)
			55:
				_pc = 54 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 53
			56:
				var _v23: int = f59dc50(param_1, m.u32(0xa55044), iVar2)
				iVar3 = _zq_signed(_v23, 32)
				_pc = 55
			57:
				iVar2 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 56
			58:
				return ((0) & 0xffffffff)
			59:
				_pc = 58 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 57
			60:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 59
			61:
				var _v24: int = f5aa440(0xf0)
				iVar2 = _zq_signed(_v24, 32)
				_pc = 60
			62:
				var _v25: int = f5929d0()
				_pc = 61
			63:
				_pc = 62 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 47
			64:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 8
			65:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 64
			66:
				var _v26: int = f5bf800(0x82)
				_pc = 65
			67:
				var _v27: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 9
				if _v27 == 5: _pc = 20
				if _v27 == 4: _pc = 24
				if _v27 == 3: _pc = 42
				if _v27 == 2: _pc = 44
				if _v27 == 1: _pc = 63
				if _v27 == 0: _pc = 66
			68:
				_pc = 67 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 5
	return 0


func f594f00(e: int) -> int:
	var p := _zq_owner(e)
	var has_jinzo := f5709d0(p, 0x60f)
	var id := f4022e0(m.u16(e)) & 0xffff
	var desired := 2 if id in [0x3f3, 0x5e7] else 5 if id == 0x400 else 0
	var step := m.u8(0xa55c8e)
	match step:
		0:
			m.set_u16(e + 4, m.u16(e + 4) & 0x1fff)
			if f570bb0(p) == 0: return 1
			var candidates := f599e30(p, id, 0) if has_jinzo == 0 else f569d50(p)
			if candidates == 0: return 1
			if id == 0x5e7:
				if not _zq_cpu(e):
					f5bf800(0x4f)
					f5bf9a0(1, 0)
				else: m.set_u16(0xa558b4, int(has_jinzo == 0))
			else: m.set_u16(0xa558b4, 1)
		1:
			if m.u16(0xa558b4) == 0: return 1
			m.set_u8(0xa55c8f, 0)
			if has_jinzo != 0:
				f578400(p, f402460(0x60f))
				f5bf800(0x50)
				m.set_u8(0xa55c8e, 10)
				return 0
			if not _zq_cpu(e): f5bf800(0x56)
		2:
			f40c940(p, desired + 23, f4022e0(m.u16(e)) & 0xffff, 0)
		3:
			for i in m.u16(0xa558b4):
				var entry := m.u32(f40cd00(i + 1))
				var owner := (entry >> 12) & 1
				var instance := owner + ((entry >> 24) & 127) * 2
				f5b9170(((entry >> 12) << 15) | 0xdf, f4022e0(entry & 0xfff), instance, 0)
				f5b9170((0x8000 if m.u16(e) != 0 else 0) | 8, owner, 14, 0)
				f592a50(e, instance)
			return 1
		10:
			var enough := (m.u16(e + 4) >> 13) >= f569d50(p)
			var cancelled := (m.u32(0xa54e54) & 0x102) != 0 and (m.u8(0xa55c8f) != 0 or id == 0x5e7)
			if enough or cancelled: return 1
			f5929d0()
			if f5aa440(0xf0) != 0:
				var target_p := m.u32(0xa55044)
				var target_z := m.u32(0xa5504c)
				if (m.u32(JoeyMem.zone(target_p, target_z)) & 0xfff) != 0 and f592b50(e, target_p, target_z) == 0 and f592b00(e, target_p, target_z) != 0:
					m.set_u8(0xa55c8f, m.u8(0xa55c8f) + 1)
					if m.u8(0xa55c8f) == desired: return 1
			return 0
		_: return 1
	m.set_u8(0xa55c8e, m.u8(0xa55c8e) + 1)
	return 0


func f595360(param_1: int, param_2: int) -> int:
	var sVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var bVar5: int = 0
	var in_ECX: int = 0
	var extraout_var: int = 0
	var uVar6: int = 0
	var iVar7: int = 0
	var local_104: int = 0
	var local_100: int = m.local(256)
	var _pc: int = 43
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(_zq_signed((_zq_signed(bVar5, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32), 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 2
			4:
				var _v0: int = f5bf800(local_100)
				_pc = 3
			5:
				var _v1: int = f5bdf40(local_100, 0x8a, uVar4)
				_pc = 4
			6:
				var _v2: int = f402290((((_zq_signed((((((uVar6) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_2)) & 0xffff)))
				uVar4 = ((_v2) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zq_signed(_zq_signed((_zq_signed(_zq_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed(uVar6, 8)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zq_signed(1, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 3
			8:
				uVar6 = ((((((((((_zq_signed((((((((in_ECX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xffff)) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 8
			10:
				bVar5 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 2
			11:
				return ((0) & 0xffffffff)
			12:
				_pc = 11 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 10
			13:
				return ((1) & 0xffffffff)
			14:
				var _v4: int = int((int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0)
				if _v4 != 0:
					var _v3: int = f592b00(param_1, uVar4, iVar7)
					iVar7 = _zq_signed(_v3, 32)
					_v4 = int((int(_zq_signed(iVar7, 32) != _zq_signed(0, 32))) != 0)
				_pc = 13 if (_v4) != 0 else 12
			15:
				var _v5: int = f582520(param_2, m.u32(0xa55044), iVar7)
				iVar3 = _zq_signed(_v5, 32)
				_pc = 14
			16:
				iVar7 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 15
			17:
				_pc = 16 if (int(_zq_signed(iVar7, 32) != _zq_signed(0, 32))) != 0 else 12
			18:
				uVar4 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 17
			19:
				var _v6: int = f5aa440(local_104)
				iVar7 = _zq_signed(_v6, 32)
				_pc = 18
			20:
				var _v7: int = f5929d0()
				_pc = 19
			21:
				return ((1) & 0xffffffff)
			22:
				_pc = 35 if (1) != 0 else 21
			23:
				return ((1) & 0xffffffff)
			24:
				_pc = 23 if (int(_zq_signed(1, 32) < _zq_signed(_zq_signed(uVar6, 32), 32))) != 0 else 22
			25:
				uVar6 = (((((((uVar6) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 24
			26:
				_pc = 21 if (int(_zq_signed(sVar1, 32) == _zq_signed(0x525, 32))) != 0 else 25
			27:
				var _v8: int = f4022e0((((extraout_var) << 16) | ((m.u16(param_1)) & 0xffff)))
				sVar1 = _zq_signed(_v8, 16)
				_pc = 26
			28:
				_pc = 33 if (int(_zq_signed(iVar7, 32) < _zq_signed(5, 32))) != 0 else 27
			29:
				iVar7 = _zq_signed(_zq_signed((_zq_signed(iVar7, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 28
			30:
				return ((1) & 0xffffffff)
			31:
				var _v9: int = f592a90(param_1, uVar2, iVar7)
				_pc = 30
			32:
				_pc = 31 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 29
			33:
				var _v10: int = f582520(param_2, uVar2, iVar7)
				iVar3 = _zq_signed(_v10, 32)
				_pc = 32
			34:
				iVar7 = _zq_signed(0, 32)
				_pc = 33
			35:
				uVar2 = (((((((_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff) ^ ((uVar6) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 34
			36:
				uVar6 = ((0) & 0xffffffff)
				_pc = 22
			37:
				_pc = 36 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 20
			38:
				local_104 = ((0xf000f0) & 0xffffffff)
				_pc = 37
			39:
				local_104 = ((0xf0) & 0xffffffff)
				_pc = 37
			40:
				_pc = 39 if (int(_zq_signed(sVar1, 32) == _zq_signed(0x525, 32))) != 0 else 37
			41:
				_pc = 38 if (int(_zq_signed(sVar1, 32) == _zq_signed(0x431, 32))) != 0 else 40
			42:
				var _v11: int = f4022e0(m.u16(param_1))
				sVar1 = _zq_signed(_v11, 16)
				_pc = 41
			43:
				_pc = 9 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(0, 32))) != 0 else 42
	return 0


func f595530(param_1: int, param_2: int) -> int:
	var bVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var bVar6: int = 0
	var _pc: int = 34
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((uVar5) & 0xffffffff)
			2:
				var _v0: int = f596910(param_1)
				uVar5 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				return ((1) & 0xffffffff)
			4:
				_pc = 3 if (int(_zq_signed(_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff)), 16), 32) != _zq_signed(2, 32))) != 0 else 2
			5:
				return ((uVar5) & 0xffffffff)
			6:
				var _v1: int = f595360(param_1, param_2)
				uVar5 = ((_v1) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zq_signed(_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff)), 16), 32) == _zq_signed(1, 32))) != 0 else 4
			8:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff), ((1) & 0xffff))
				_pc = 7
			9:
				return ((0) & 0xffffffff)
			10:
				m.set_u16(0xa55c8e, ((_zq_signed((((((((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) >> ((8) & 31)), 32)) & 0xff)) & 0xffffff)) << 8) | ((10) & 0xff)), 16)) & 0xffff))
				_pc = 9
			11:
				_pc = 10 if (bVar1) != 0 else 8
			12:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff), ((2) & 0xffff))
				_pc = 7
			13:
				_pc = 11 if (int(_zq_signed(iVar3, 32) == _zq_signed(2, 32))) != 0 else 12
			14:
				bVar1 = ((1) & 0xff)
				_pc = 13
			15:
				_pc = 18
			16:
				_pc = 15 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 14
			17:
				var _v2: int = f59dca0(param_1)
				iVar4 = _zq_signed(_v2, 32)
				_pc = 16
			18:
				bVar1 = ((0) & 0xff)
				_pc = 13
			19:
				var _v3: int = int((int(_zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0xfc0, 32)), 32), 32) == _zq_signed(0x480, 32))) != 0)
				if _v3 != 0:
					uVar2 = ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xffff)
					_v3 = int((int(_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(0x10, 32)), 32)) & 0xffffffff)), 32) != _zq_signed(uVar2, 32))) != 0)
				_pc = 17 if (int((_v3) != 0 and (int(_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(0x12, 32)), 32)) & 0xffffffff)), 32) == _zq_signed(uVar2, 32))) != 0)) != 0 else 18
			20:
				var _v4: int = f582590(param_1, param_2)
				iVar3 = _zq_signed(_v4, 32)
				_pc = 19
			21:
				_pc = 7
			22:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff00, 32)), 32)) & 0xffff))
				_pc = 21
			23:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(8, 32)), 32)) & 0xffffffff), _zq_signed(_zq_signed((_zq_signed(m.u16(0xa558b4), 32) + _zq_signed(1, 32)), 32), 16))
				_pc = 22
			24:
				_pc = 23 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(11, 32))) != 0 else 21
			25:
				return ((0) & 0xffffffff)
			26:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(bVar6, 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(bVar6, 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 25
			27:
				bVar6 = ((m.u8(0xa55c8e)) & 0xff)
				_pc = 26
			28:
				var _v5: int = f5bf9a0(1, 0)
				_pc = 27
			29:
				var _v6: int = f5bf800(0x109)
				_pc = 28
			30:
				bVar6 = ((10) & 0xff)
				_pc = 26
			31:
				m.set_u16(0xa558b4, ((2) & 0xffff))
				_pc = 30
			32:
				_pc = 29 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 31
			33:
				_pc = 32 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(10, 32))) != 0 else 24
			34:
				_pc = 33 if (int(_zq_signed(m.u8(0xa55c8e), 32) != _zq_signed(0, 32))) != 0 else 20
	return 0


func f595780(param_1: int, param_2: int) -> int:
	var extraout_AH: int = 0
	var uVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var iVar4: int = 0
	var bVar5: int = 0
	var uVar6: int = 0
	var unaff_ESI: int = 0
	var local_104: int = 0
	var local_100: int = m.local(256)
	var _pc: int = 70
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar5, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar5 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				return ((0) & 0xffffffff)
			5:
				_pc = 4 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 3
			6:
				var _v0: int = f592b00(param_1, uVar2, iVar3)
				iVar3 = _zq_signed(_v0, 32)
				_pc = 5
			7:
				return ((0) & 0xffffffff)
			8:
				_pc = 7 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 6
			9:
				return ((1) & 0xffffffff)
			10:
				var _v1: int = f595690(param_1, param_2, (((_zq_signed(iVar3, 8)) << 8) | ((_zq_signed(m.u32(0xa55044), 8)) & 0xff)))
				iVar4 = _zq_signed(_v1, 32)
				_pc = 8
			11:
				iVar3 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 10
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 11
			14:
				uVar2 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 13
			15:
				var _v2: int = f5aa440(0xe000e0)
				iVar3 = _zq_signed(_v2, 32)
				_pc = 14
			16:
				var _v3: int = f5929d0()
				_pc = 15
			17:
				_pc = 3
			18:
				var _v4: int = f5bf800(local_100)
				_pc = 17
			19:
				var _v5: int = f5bdf40(local_100, 0x8c, uVar2)
				_pc = 18
			20:
				var _v6: int = f402290(_zq_signed((_zq_signed(m.u16(((((0xa55d74 + ((((((((((_zq_signed((_zq_signed(((uVar1) & 0xffff), 32) >> ((8) & 31)), 32)) & 0xff)) & 0xffffffff)) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(((uVar1) & 0xff), 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x351, 32)), 32)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32))
				uVar2 = ((_v6) & 0xffffffff)
				_pc = 19
			21:
				var _v7: int = f583440(param_1, 0)
				uVar1 = ((_v7) & 0xffff)
				_pc = 20
			22:
				return ((1) & 0xffffffff)
			23:
				_pc = 32 if (int(_zq_signed(iVar3, 32) < _zq_signed(2, 32))) != 0 else 22
			24:
				iVar3 = _zq_signed(_zq_signed((_zq_signed(iVar3, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 23
			25:
				_pc = 30 if (int(_zq_signed(_zq_signed(uVar6, 32), 32) < _zq_signed(5, 32))) != 0 else 24
			26:
				uVar6 = (((((((uVar6) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 25
			27:
				return ((1) & 0xffffffff)
			28:
				var _v8: int = f592a90(param_1, local_104, uVar6)
				_pc = 27
			29:
				_pc = 28 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 26
			30:
				var _v9: int = f595690(param_1, param_2, (((((((((((((((uVar6) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((local_104) & 0xffffffff))) & 0xffffffff))
				iVar4 = _zq_signed(_v9, 32)
				_pc = 29
			31:
				uVar6 = ((0) & 0xffffffff)
				_pc = 30
			32:
				local_104 = (((((((local_104) & 0xffffffff) ^ ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 31
			33:
				iVar3 = _zq_signed(0, 32)
				_pc = 32
			34:
				var _v10: int = f56fb40(local_104, extraout_AH)
				_pc = 33
			35:
				var _v11: int = f583440(param_1, 0)
				_pc = 34
			36:
				local_104 = (((((((local_104) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 35
			37:
				var _v12: int = f583440(param_1, 0)
				local_104 = ((_v12) & 0xffffffff)
				_pc = 36
			38:
				_pc = 37 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 21
			39:
				return ((1) & 0xffffffff)
			40:
				_pc = 39 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 38
			41:
				_pc = 49 if (int(_zq_signed(_zq_signed(local_104, 32), 32) < _zq_signed(2, 32))) != 0 else 40
			42:
				local_104 = (((((((local_104) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 41
			43:
				_pc = 47 if (int(_zq_signed(_zq_signed(uVar6, 32), 32) < _zq_signed(5, 32))) != 0 else 42
			44:
				uVar6 = (((((((uVar6) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 43
			45:
				iVar3 = _zq_signed(_zq_signed((_zq_signed(iVar3, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 44
			46:
				_pc = 45 if (int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0 else 44
			47:
				var _v13: int = f595690(param_1, param_2, (((((((((((((((uVar6) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((unaff_ESI) & 0xffffffff))) & 0xffffffff))
				iVar4 = _zq_signed(_v13, 32)
				_pc = 46
			48:
				uVar6 = ((0) & 0xffffffff)
				_pc = 47
			49:
				unaff_ESI = (((((_zq_signed((((((unaff_ESI) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((((local_104) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff)
				_pc = 48
			50:
				local_104 = ((0) & 0xffffffff)
				_pc = 49
			51:
				iVar3 = _zq_signed(0, 32)
				_pc = 50
			52:
				var _v14: int = f57b3b0(param_1, (((_zq_signed(iVar3, 8)) << 8) | ((_zq_signed(m.u32(0xa55044), 8)) & 0xff)))
				iVar4 = _zq_signed(_v14, 32)
				_pc = 8
			53:
				iVar3 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 52
			54:
				return ((0) & 0xffffffff)
			55:
				_pc = 54 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 53
			56:
				uVar2 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 55
			57:
				var _v15: int = f5aa440(0xff00ff)
				iVar3 = _zq_signed(_v15, 32)
				_pc = 56
			58:
				var _v16: int = f5929d0()
				_pc = 57
			59:
				_pc = 3
			60:
				var _v17: int = f5bf800(0x8b)
				_pc = 59
			61:
				return ((0) & 0xffffffff)
			62:
				m.set_u16(0xa55c8e, ((((((((((((m.u16(0xa55c8e)) & 0xffffffff) & ((0xffffff02) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((2) & 0xffffffff))) & 0xffffffff)) & 0xffff))
				_pc = 61
			63:
				_pc = 62 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 59
			64:
				var _v18: int = f5b3fa0(param_1, param_2, 0)
				iVar3 = _zq_signed(_v18, 32)
				_pc = 63
			65:
				_pc = 60 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 64
			66:
				return ((0) & 0xffffffff)
			67:
				_pc = 66 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 65
			68:
				var _v19: int = f59dca0(param_1)
				iVar3 = _zq_signed(_v19, 32)
				_pc = 67
			69:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 68
			70:
				var _v20: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 9
				if _v20 == 3: _pc = 16
				if _v20 == 2: _pc = 51
				if _v20 == 1: _pc = 58
				if _v20 == 0: _pc = 69
	return 0


func f595f20(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var bVar3: int = 0
	var _pc: int = 43
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar3 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				return ((1) & 0xffffffff)
			5:
				var _v0: int = f5bcf60(_zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32)), 32), 0x48a, m.u16(0xa558b4))
				_pc = 4
			6:
				var _v1: int = f5747e0(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) & _zq_signed(1, 32)), 32), m.u16((param_1 + (3) * 2)), ((((((((_zq_signed((_zq_signed(bVar3, 32) >> ((1) & 31)), 32)) << 8) | ((bVar3) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), 9)
				_pc = 3
			7:
				bVar3 = ((((m.u16((param_1 + (1) * 2))) & 0xff)) & 0xff)
				_pc = 6
			8:
				var _v2: int = f592a50(param_1, m.u16(0xa558b4))
				_pc = 7
			9:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 8
			10:
				var _v3: int = f40c940(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), m.u16((param_1 + (3) * 2)), uVar1, 0)
				_pc = 3
			11:
				var _v4: int = f4022e0(m.u16(param_1))
				uVar1 = ((_v4) & 0xffff)
				_pc = 10
			12:
				return ((0) & 0xffffffff)
			13:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xffff))
				_pc = 12
			14:
				bVar3 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 13
			15:
				m.set_u16((param_1 + (3) * 2), ((0x2a) & 0xffff))
				_pc = 14
			16:
				m.set_u16((param_1 + (3) * 2), ((0x2b) & 0xffff))
				_pc = 14
			17:
				m.set_u16((param_1 + (3) * 2), ((0x2c) & 0xffff))
				_pc = 14
			18:
				_pc = 17 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(2, 32))) != 0 else 14
			19:
				_pc = 16 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(1, 32))) != 0 else 18
			20:
				_pc = 15 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(0, 32))) != 0 else 19
			21:
				var _v5: int = f5bf9a0(3, 0xffffffff)
				_pc = 3
			22:
				var _v6: int = f5bf800(0x105)
				_pc = 21
			23:
				return ((0) & 0xffffffff)
			24:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xffff))
				_pc = 23
			25:
				bVar3 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(2, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 24
			26:
				m.set_u16((param_1 + (3) * 2), ((0x2d) & 0xffff))
				_pc = 25
			27:
				m.set_u16((param_1 + (3) * 2), ((0x2e) & 0xffff))
				_pc = 25
			28:
				_pc = 27 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(2, 32))) != 0 else 25
			29:
				_pc = 26 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(1, 32))) != 0 else 28
			30:
				_pc = 29 if (int(_zq_signed(m.u16(0xa558b4), 32) != _zq_signed(0, 32))) != 0 else 22
			31:
				_pc = 14
			32:
				var _v7: int = f5bf9a0(3, 0xffffffff)
				_pc = 31
			33:
				var _v8: int = f5bf800(0x104)
				_pc = 32
			34:
				var _v9: int = f5bf800(0x91)
				_pc = 3
			35:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 34
			36:
				return ((0) & 0xffffffff)
			37:
				m.set_u16(0xa55c8e, (((((m.u16(0xa55c90)) << 16) | ((_zq_signed((((((((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) >> ((8) & 31)), 32)) & 0xff)) & 0xffffff)) << 8) | ((5) & 0xff)), 16)) & 0xffff))) & 0xffff))
				_pc = 36
			38:
				var _v10: int = f402460(0x3f0)
				m.set_u16(0xa558b4, ((_v10) & 0xffff))
				_pc = 37
			39:
				m.set_u16(0xa558b4, ((_zq_signed((_zq_signed(m.u16(((((0xa56434 + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((-(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32))), 32), 32) - _zq_signed(1, 32)), 32), 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x351, 32)), 32)) * 4) + (iVar2) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32)) & 0xffff))
				_pc = 37
			40:
				var _v11: int = f5bddb0(_zq_signed(m.u8((((0xa55d68 + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((-(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xffff), 32) & _zq_signed(1, 32)), 32))), 32), 32) - _zq_signed(1, 32)), 32), 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 8))
				iVar2 = _zq_signed(_v11, 32)
				_pc = 39
			41:
				_pc = 38 if (int(_zq_signed(_zq_signed(m.u8((((0xa55d68 + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((-(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xffff), 32) & _zq_signed(1, 32)), 32))), 32), 32) - _zq_signed(1, 32)), 32), 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 8), 32) == _zq_signed(0, 32))) != 0 else 40
			42:
				_pc = 41 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 35
			43:
				var _v12: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 4
				if _v12 == 6: _pc = 5
				if _v12 == 5: _pc = 9
				if _v12 == 4: _pc = 11
				if _v12 == 3: _pc = 20
				if _v12 == 2: _pc = 30
				if _v12 == 1: _pc = 33
				if _v12 == 0: _pc = 42
	return 0


func f5961c0(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var bVar6: int = 0
	var iVar7: int = 0
	var _pc: int = 62
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar6, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar6 = ((_zq_signed((_zq_signed(bVar6, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				bVar6 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 3
			5:
				return ((1) & 0xffffffff)
			6:
				return ((0) & 0xffffffff)
			7:
				return ((1) & 0xffffffff)
			8:
				var _v1: int = int((int(((uVar4) & 0xffffffff) != (((((_zq_signed(iVar3, 8)) << 8) | ((_zq_signed(uVar1, 8)) & 0xff))) & 0xffffffff))) != 0)
				if _v1 != 0:
					var _v0: int = f59dc50(param_1, uVar1, iVar3)
					iVar5 = _zq_signed(_v0, 32)
					_v1 = int((int(_zq_signed(iVar5, 32) != _zq_signed(0, 32))) != 0)
				var _v3: int = int((_v1) != 0)
				if _v3 != 0:
					var _v2: int = f592b00(param_1, uVar1, iVar3)
					iVar3 = _zq_signed(_v2, 32)
					_v3 = int((int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0)
				_pc = 7 if (_v3) != 0 else 6
			9:
				var _v4: int = f583440(param_1, 0)
				uVar4 = ((_v4) & 0xffffffff)
				_pc = 8
			10:
				iVar3 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 9
			11:
				_pc = 10 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 6
			12:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 11
			13:
				var _v5: int = f5aa440(0xe000e0)
				iVar3 = _zq_signed(_v5, 32)
				_pc = 12
			14:
				var _v6: int = f5929d0()
				_pc = 13
			15:
				_pc = 14 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 4
			16:
				return ((0) & 0xffffffff)
			17:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar6, 32)), 32)) & 0xffff))
				_pc = 16
			18:
				bVar6 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 17
			19:
				var _v7: int = f5bf800(0x93)
				_pc = 18
			20:
				_pc = 3
			21:
				bVar6 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 20
			22:
				return ((0) & 0xffffffff)
			23:
				_pc = 22 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 21
			24:
				var _v8: int = f592b00(param_1, uVar1, iVar3)
				iVar3 = _zq_signed(_v8, 32)
				_pc = 23
			25:
				return ((0) & 0xffffffff)
			26:
				_pc = 25 if (int(_zq_signed(iVar5, 32) == _zq_signed(0, 32))) != 0 else 24
			27:
				var _v9: int = f59dc50(param_1, m.u32(0xa55044), iVar3)
				iVar5 = _zq_signed(_v9, 32)
				_pc = 26
			28:
				iVar3 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 27
			29:
				return ((0) & 0xffffffff)
			30:
				_pc = 29 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 28
			31:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 30
			32:
				var _v10: int = f5aa440(0xe000e0)
				iVar3 = _zq_signed(_v10, 32)
				_pc = 31
			33:
				var _v11: int = f5929d0()
				_pc = 32
			34:
				_pc = 33 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 4
			35:
				return ((0) & 0xffffffff)
			36:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar6, 32)), 32)) & 0xffff))
				_pc = 35
			37:
				bVar6 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 36
			38:
				var _v12: int = f5bf800(0x92)
				_pc = 37
			39:
				return ((1) & 0xffffffff)
			40:
				_pc = 51 if (int(_zq_signed(param_1, 32) < _zq_signed(2, 32))) != 0 else 39
			41:
				param_1 = _zq_signed(_zq_signed((_zq_signed(param_1, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 40
			42:
				bVar6 = ((_zq_signed((_zq_signed(bVar6, 32) ^ _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 41
			43:
				_pc = 50 if (int(_zq_signed(iVar5, 32) < _zq_signed(5, 32))) != 0 else 42
			44:
				iVar5 = _zq_signed(_zq_signed((_zq_signed(iVar5, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 43
			45:
				return ((1) & 0xffffffff)
			46:
				_pc = 45 if (int(_zq_signed(1, 32) < _zq_signed(iVar7, 32))) != 0 else 44
			47:
				iVar7 = _zq_signed(_zq_signed((_zq_signed(iVar7, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 46
			48:
				var _v13: int = f592a90(iVar3, bVar6, iVar5)
				_pc = 47
			49:
				_pc = 48 if (int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0 else 44
			50:
				var _v14: int = f59dc50(iVar3, bVar6, iVar5)
				iVar2 = _zq_signed(_v14, 32)
				_pc = 49
			51:
				iVar5 = _zq_signed(0, 32)
				_pc = 50
			52:
				param_1 = _zq_signed(0, 32)
				_pc = 51
			53:
				bVar6 = ((_zq_signed((_zq_signed(_zq_signed((~(bVar6)), 32), 32) & _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 52
			54:
				_pc = 53 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(bVar6, 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 38
			55:
				bVar6 = ((((m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff))) & 0xff)) & 0xff)
				_pc = 54
			56:
				return ((1) & 0xffffffff)
			57:
				_pc = 56 if (int(_zq_signed(iVar5, 32) == _zq_signed(0, 32))) != 0 else 55
			58:
				var _v15: int = f581de0()
				iVar5 = _zq_signed(_v15, 32)
				_pc = 57
			59:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 58
			60:
				iVar7 = _zq_signed(0, 32)
				_pc = 59
			61:
				var _v16: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 5
				if _v16 == 3: _pc = 15
				if _v16 == 2: _pc = 19
				if _v16 == 1: _pc = 34
				if _v16 == 0: _pc = 60
			62:
				iVar3 = _zq_signed(param_1, 32)
				_pc = 61
	return 0


func f5963e0(param_1: int, param_2: int) -> int:
	var iVar1: int = 0
	var iVar2: int = 0
	var bVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 56
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar3 = ((_zq_signed((_zq_signed(bVar3, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				bVar3 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 3
			5:
				return ((0) & 0xffffffff)
			6:
				_pc = 5 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 4
			7:
				var _v0: int = f592b00(param_1, uVar4, iVar1)
				iVar1 = _zq_signed(_v0, 32)
				_pc = 6
			8:
				return ((0) & 0xffffffff)
			9:
				_pc = 8 if (int(_zq_signed(iVar2, 32) == _zq_signed(0, 32))) != 0 else 7
			10:
				var _v1: int = f59dc50(param_1, m.u32(0xa55044), iVar1)
				iVar2 = _zq_signed(_v1, 32)
				_pc = 9
			11:
				iVar1 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 10
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 11
			14:
				uVar4 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 13
			15:
				var _v2: int = f5aa440(uVar4)
				iVar1 = _zq_signed(_v2, 32)
				_pc = 14
			16:
				return ((1) & 0xffffffff)
			17:
				uVar4 = ((0xf0) & 0xffffffff)
				_pc = 15
			18:
				var _v3: int = f5929d0()
				_pc = 17
			19:
				_pc = 3
			20:
				bVar3 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 19
			21:
				_pc = 20 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 18
			22:
				return ((0) & 0xffffffff)
			23:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xffff))
				_pc = 22
			24:
				bVar3 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 23
			25:
				var _v4: int = f5bf800(uVar4)
				_pc = 24
			26:
				uVar4 = ((0x95) & 0xffffffff)
				_pc = 25
			27:
				uVar4 = ((0xf00000) & 0xffffffff)
				_pc = 15
			28:
				var _v5: int = f5929d0()
				_pc = 27
			29:
				_pc = 3
			30:
				bVar3 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 29
			31:
				_pc = 30 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 28
			32:
				_pc = 25
			33:
				uVar4 = ((0x94) & 0xffffffff)
				_pc = 32
			34:
				return ((1) & 0xffffffff)
			35:
				var _v6: int = f592a90(param_1, _zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), iVar1)
				_pc = 34
			36:
				_pc = 39 if (int(_zq_signed(iVar1, 32) < _zq_signed(5, 32))) != 0 else 35
			37:
				iVar1 = _zq_signed(_zq_signed((_zq_signed(iVar1, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 36
			38:
				_pc = 35 if (int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0 else 37
			39:
				var _v7: int = f59dc50(param_1, _zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), iVar1)
				iVar2 = _zq_signed(_v7, 32)
				_pc = 38
			40:
				iVar1 = _zq_signed(0, 32)
				_pc = 39
			41:
				_pc = 40 if (int(_zq_signed(iVar1, 32) < _zq_signed(0, 32))) != 0 else 35
			42:
				var _v8: int = f5b3d80(param_1, _zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 0xffffffff, 0xffffffff, 0xffffffff)
				iVar1 = _zq_signed(_v8, 32)
				_pc = 41
			43:
				var _v9: int = f592a90(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32)), 32), iVar1)
				_pc = 42
			44:
				_pc = 47 if (int(_zq_signed(iVar1, 32) < _zq_signed(5, 32))) != 0 else 43
			45:
				iVar1 = _zq_signed(_zq_signed((_zq_signed(iVar1, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 44
			46:
				_pc = 43 if (int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0 else 45
			47:
				var _v10: int = f59dc50(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32)), 32), iVar1)
				iVar2 = _zq_signed(_v10, 32)
				_pc = 46
			48:
				iVar1 = _zq_signed(0, 32)
				_pc = 47
			49:
				_pc = 48 if (int(_zq_signed(iVar1, 32) < _zq_signed(0, 32))) != 0 else 43
			50:
				var _v11: int = f5b3d80(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32)), 32), 1, 1, 0xffffffff)
				iVar1 = _zq_signed(_v11, 32)
				_pc = 49
			51:
				_pc = 50 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 33
			52:
				return ((1) & 0xffffffff)
			53:
				_pc = 52 if (int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) != 0 else 51
			54:
				var _v12: int = f582040(param_1)
				iVar1 = _zq_signed(_v12, 32)
				_pc = 53
			55:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 54
			56:
				var _v13: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 16
				if _v13 == 3: _pc = 21
				if _v13 == 2: _pc = 26
				if _v13 == 1: _pc = 31
				if _v13 == 0: _pc = 55
	return 0


func f5965e0(param_1: int) -> int:
	var bVar1: int = 0
	var sVar2: int = 0
	var iVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var bVar7: int = 0
	var puVar8: int = 0
	var local_100: int = m.local(256)
	var _pc: int = 58
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0xffffffff) & 0xffffffff)
			2:
				var _v0: int = f5bf800(0x107)
				_pc = 1
			3:
				_pc = 2 if (int(_zq_signed(_zq_signed((_zq_signed(_zq_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zq_signed(1, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 1
			4:
				_pc = 28
			5:
				bVar7 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 4
			6:
				return ((0xffffffff) & 0xffffffff)
			7:
				_pc = 6 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 5
			8:
				var _v1: int = f59dca0(param_1)
				iVar3 = _zq_signed(_v1, 32)
				_pc = 7
			9:
				return ((0xffffffff) & 0xffffffff)
			10:
				_pc = 9 if (int(_zq_signed(iVar3, 32) == _zq_signed(_zq_signed((-(1)), 32), 32))) != 0 else 8
			11:
				var _v2: int = f56a400(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32))
				iVar3 = _zq_signed(_v2, 32)
				_pc = 10
			12:
				_pc = 11 if (bVar1) != 0 else 3
			13:
				_pc = 21 if (int(_zq_signed(iVar3, 32) < _zq_signed(_zq_signed(((((((((((m.u32(0xa55c94)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff), 32), 32))) != 0 else 12
			14:
				puVar8 = (((puVar8 + (1) * 4)) & 0xffffffff)
				_pc = 13
			15:
				iVar3 = _zq_signed(_zq_signed((_zq_signed(iVar3, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 14
			16:
				bVar1 = ((1) & 0xff)
				_pc = 15
			17:
				_pc = 16
			18:
				_pc = 17 if (int(((m.u16(param_1)) & 0xffffffff) == ((uVar6) & 0xffffffff))) != 0 else 15
			19:
				var _v3: int = f568b90((((((m.u32(puVar8)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				uVar6 = ((_v3) & 0xffffffff)
				_pc = 18
			20:
				var _v4: int = m.u8(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed(0xa55c94, 32), 32) + _zq_signed(iVar3, 32)), 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 15
				if _v4 == 0x1f: _pc = 16
				if _v4 == 0x1e: _pc = 16
				if _v4 == 0x1d: _pc = 16
				if _v4 == 0x1c: _pc = 19
				if _v4 == 0x15: _pc = 19
			21:
				m.set_u16((param_1 + (1) * 2), ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed(0xa55c94, 32), 32) + _zq_signed(iVar3, 32)), 32), 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x3f, 32)), 32), 32) << ((6) & 31)), 32), 32) | _zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) & _zq_signed(0xf03f, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 20
			22:
				puVar8 = ((((0xa55ca8) & 0xffffffff)) & 0xffffffff)
				_pc = 21
			23:
				_pc = 22 if (int((((((((m.u32(0xa55c94)) & 0xffffffff) & ((0x7f00) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 3
			24:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 23
			25:
				iVar3 = _zq_signed(0, 32)
				_pc = 24
			26:
				bVar1 = ((0) & 0xff)
				_pc = 25
			27:
				return ((0) & 0xffffffff)
			28:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(_zq_signed((_zq_signed(bVar7, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32), 32)), 32)) & 0xffff))
				_pc = 27
			29:
				bVar7 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 28
			30:
				return ((0) & 0xffffffff)
			31:
				_pc = 30 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 29
			32:
				return ((1) & 0xffffffff)
			33:
				var _v5: int = f44ef40(1)
				_pc = 32
			34:
				var _v7: int = int((int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0)
				if _v7 != 0:
					var _v6: int = f592b00(param_1, uVar5, iVar3)
					iVar3 = _zq_signed(_v6, 32)
					_v7 = int((int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0)
				_pc = 33 if (_v7) != 0 else 31
			35:
				var _v8: int = f59dc50(param_1, m.u32(0xa55044), iVar3)
				iVar4 = _zq_signed(_v8, 32)
				_pc = 34
			36:
				iVar3 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 35
			37:
				_pc = 36 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 31
			38:
				uVar5 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 37
			39:
				var _v9: int = f5aa440(0xe000e0)
				iVar3 = _zq_signed(_v9, 32)
				_pc = 38
			40:
				var _v10: int = f5929d0()
				_pc = 39
			41:
				return ((0xffffffff) & 0xffffffff)
			42:
				_pc = 41 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(0, 32))) != 0 else 40
			43:
				return ((1) & 0xffffffff)
			44:
				_pc = 43 if (int(_zq_signed(m.u8(0xa55c8e), 32) != _zq_signed(2, 32))) != 0 else 42
			45:
				return ((0xffffffff) & 0xffffffff)
			46:
				return ((1) & 0xffffffff)
			47:
				var _v11: int = f592a90(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32), 32)), 32), iVar3)
				_pc = 46
			48:
				var _v13: int = int((int(_zq_signed(_zq_signed((-(1)), 32), 32) < _zq_signed(iVar3, 32))) != 0)
				if _v13 != 0:
					var _v12: int = f4022e0(_zq_signed((_zq_signed(m.u16(((((0xa55d74 + (_zq_signed((_zq_signed(iVar3, 32) * _zq_signed(0x24, 32)), 32)) * 4) + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(_zq_signed((-(_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32))), 32), 32) - _zq_signed(1, 32)), 32), 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0x351, 32)), 32)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32))
					sVar2 = _zq_signed(_v12, 16)
					_v13 = int((int(_zq_signed(sVar2, 32) != _zq_signed(0x547, 32))) != 0)
				_pc = 47 if (_v13) != 0 else 45
			49:
				var _v14: int = f5b0150(param_1, _zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u16((param_1 + (1) * 2)), 32) & _zq_signed(1, 32)), 32), 32)), 32), 0xffffffff, 1)
				iVar3 = _zq_signed(_v14, 32)
				_pc = 48
			50:
				return ((0) & 0xffffffff)
			51:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 50
			52:
				var _v15: int = f5bf9a0(1, 0)
				_pc = 51
			53:
				var _v16: int = f5bf800(local_100)
				_pc = 52
			54:
				var _v17: int = f5bdf40(local_100, 0x42, uVar5)
				_pc = 53
			55:
				var _v18: int = f402290(m.u16(param_1))
				uVar5 = ((_v18) & 0xffffffff)
				_pc = 54
			56:
				_pc = 55 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 49
			57:
				_pc = 56 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(1, 32))) != 0 else 44
			58:
				_pc = 57 if (int(_zq_signed(m.u8(0xa55c8e), 32) != _zq_signed(0, 32))) != 0 else 26
	return 0


func f596910(param_1: int) -> int:
	var sVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var iVar5: int = 0
	var bVar6: int = 0
	var extraout_var: int = 0
	var uVar7: int = 0
	var extraout_var_00: int = 0
	var bVar8: int = 0
	var local_100: int = m.local(256)
	var _pc: int = 51
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(_zq_signed((_zq_signed(bVar6, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32), 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar6 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 2
			4:
				var _v0: int = f5bf9a0(1, 0)
				_pc = 3
			5:
				var _v1: int = f5bf800(local_100)
				_pc = 4
			6:
				var _v2: int = f5bdf40(local_100, 0xe2, uVar2)
				_pc = 5
			7:
				var _v3: int = f402290((((_zq_signed((((((uVar7) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v3) & 0xffffffff)
				_pc = 6
			8:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 3
			9:
				_pc = 7 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed(uVar7, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 8
			10:
				uVar7 = ((((((((((extraout_var_00) << 16) | ((((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xffff)) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 3
			12:
				var _v4: int = f5bf800(0xf)
				_pc = 11
			13:
				_pc = 12 if (int(_zq_signed(_zq_signed((_zq_signed(_zq_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zq_signed(1, 32)), 32), 32) != _zq_signed(0, 32))) != 0 else 11
			14:
				_pc = 13 if (int((int(_zq_signed(sVar1, 32) == _zq_signed(0x525, 32))) != 0 or (int(_zq_signed(sVar1, 32) == _zq_signed(0x5f2, 32))) != 0)) != 0 else 3
			15:
				_pc = 10 if (int(_zq_signed(sVar1, 32) == _zq_signed(0x4db, 32))) != 0 else 14
			16:
				var _v5: int = f4022e0(m.u16(param_1))
				sVar1 = _zq_signed(_v5, 16)
				_pc = 15
			17:
				return ((1) & 0xffffffff)
			18:
				var _v6: int = f592a90(param_1, bVar8, iVar4)
				_pc = 17
			19:
				var _v8: int = int((int(_zq_signed(_zq_signed((-(1)), 32), 32) < _zq_signed(iVar4, 32))) != 0)
				if _v8 != 0:
					var _v7: int = f59dc50(param_1, bVar8, iVar4)
					iVar5 = _zq_signed(_v7, 32)
					_v8 = int((int(_zq_signed(iVar5, 32) != _zq_signed(0, 32))) != 0)
				_pc = 18 if (_v8) != 0 else 16
			20:
				var _v9: int = f5b0090(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), bVar8, iVar4, 1, 0)
				iVar4 = _zq_signed(_v9, 32)
				_pc = 19
			21:
				var _v11: int = int((int(_zq_signed(iVar4, 32) < _zq_signed(0, 32))) != 0)
				if _v11 == 0:
					var _v10: int = f59dc50(param_1, bVar8, iVar4)
					iVar5 = _zq_signed(_v10, 32)
					_v11 = int((int(_zq_signed(iVar5, 32) == _zq_signed(0, 32))) != 0)
				_pc = 20 if (_v11) != 0 else 19
			22:
				var _v12: int = f5b0090(_zq_signed((_zq_signed(bVar6, 32) & _zq_signed(1, 32)), 32), bVar8, 0xffffffff, 1, 0)
				iVar4 = _zq_signed(_v12, 32)
				_pc = 21
			23:
				bVar8 = ((_zq_signed((_zq_signed(int(_zq_signed(sVar1, 32) == _zq_signed(0x4db, 32)), 32) ^ _zq_signed(_zq_signed((_zq_signed(bVar6, 32) & _zq_signed(1, 32)), 32), 32)), 32)) & 0xff)
				_pc = 22
			24:
				var _v13: int = f4022e0((((_zq_signed((((((uVar7) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)))
				sVar1 = _zq_signed(_v13, 16)
				_pc = 23
			25:
				bVar6 = ((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xff)
				_pc = 24
			26:
				_pc = 25 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed(uVar7, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 16
			27:
				uVar7 = ((((((((((extraout_var) << 16) | ((((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xffff)) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 26
			28:
				return ((0xffffffff) & 0xffffffff)
			29:
				_pc = 28 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 27
			30:
				var _v14: int = f59dca0(param_1)
				iVar4 = _zq_signed(_v14, 32)
				_pc = 29
			31:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 30
			32:
				return ((1) & 0xffffffff)
			33:
				var _v16: int = int((int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0)
				if _v16 != 0:
					var _v15: int = f592b00(param_1, uVar2, uVar3)
					iVar4 = _zq_signed(_v15, 32)
					_v16 = int((int(_zq_signed(iVar4, 32) != _zq_signed(0, 32))) != 0)
				_pc = 32 if (_v16) != 0 else 1
			34:
				var _v17: int = f59dc50(param_1, uVar2, uVar3)
				iVar4 = _zq_signed(_v17, 32)
				_pc = 33
			35:
				return ((0) & 0xffffffff)
			36:
				_pc = 35 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 34
			37:
				uVar3 = ((m.u32(0xa5504c)) & 0xffffffff)
				_pc = 36
			38:
				uVar2 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 37
			39:
				var _v18: int = f5beed0()
				iVar4 = _zq_signed(_v18, 32)
				_pc = 38
			40:
				_pc = 2
			41:
				bVar6 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 40
			42:
				_pc = 41 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 39
			43:
				var _v19: int = f5929d0()
				_pc = 42
			44:
				var _v20: int = f5bddb0(5)
				uVar3 = ((_v20) & 0xffffffff)
				_pc = 34
			45:
				var _v21: int = f5bddb0(2)
				uVar2 = ((_v21) & 0xffffffff)
				_pc = 44
			46:
				_pc = 43 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 45
			47:
				return ((0xffffffff) & 0xffffffff)
			48:
				_pc = 47 if (int(_zq_signed(m.u16(0xa558b4), 32) == _zq_signed(0, 32))) != 0 else 46
			49:
				return ((1) & 0xffffffff)
			50:
				_pc = 49 if (int(_zq_signed(m.u8(0xa55c8e), 32) != _zq_signed(1, 32))) != 0 else 48
			51:
				_pc = 31 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(0, 32))) != 0 else 50
	return 0


func f596be0(param_1: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var iVar4: int = 0
	var _pc: int = 36
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 1
			3:
				var _v0: int = f5bf800(0x9a)
				_pc = 2
			4:
				_pc = 15 if (1) != 0 else 3
			5:
				return ((1) & 0xffffffff)
			6:
				_pc = 5 if (int(_zq_signed(1, 32) < _zq_signed(iVar1, 32))) != 0 else 4
			7:
				iVar1 = _zq_signed(_zq_signed((_zq_signed(iVar1, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 6
			8:
				_pc = 13 if (int(_zq_signed(iVar4, 32) < _zq_signed(5, 32))) != 0 else 7
			9:
				iVar4 = _zq_signed(_zq_signed((_zq_signed(iVar4, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 8
			10:
				_pc = 21
			11:
				var _v1: int = f577b30(uVar2, iVar4)
				_pc = 10
			12:
				_pc = 11 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 9
			13:
				var _v2: int = f59dc50(param_1, uVar2, iVar4)
				iVar3 = _zq_signed(_v2, 32)
				_pc = 12
			14:
				iVar4 = _zq_signed(0, 32)
				_pc = 13
			15:
				uVar2 = (((((((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff) ^ ((((int(_zq_signed(iVar1, 32) == _zq_signed(0, 32))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 14
			16:
				iVar1 = _zq_signed(0, 32)
				_pc = 15
			17:
				_pc = 16 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 3
			18:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 17
			19:
				return ((1) & 0xffffffff)
			20:
				var _v3: int = f592a50(param_1, _zq_signed((_zq_signed(iVar1, 32) + _zq_signed(1, 32)), 32))
				_pc = 19
			21:
				var _v4: int = f4026c0(_zq_signed((_zq_signed(m.u16(((((0xa55d74 + (_zq_signed((_zq_signed(iVar4, 32) * _zq_signed(0x24, 32)), 32)) * 4) + (((((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zq_signed(0xfff, 32)), 32))
				iVar1 = _zq_signed(_v4, 32)
				_pc = 20
			22:
				var _v5: int = f577b30(uVar2, iVar4)
				_pc = 21
			23:
				_pc = 22 if (int(_zq_signed(iVar1, 32) != _zq_signed(0, 32))) != 0 else 1
			24:
				var _v6: int = f5aa480()
				iVar1 = _zq_signed(_v6, 32)
				_pc = 23
			25:
				_pc = 24 if (int(_zq_signed(iVar1, 32) != _zq_signed(0, 32))) != 0 else 1
			26:
				var _v7: int = f59dc50(param_1, m.u32(0xa55044), iVar4)
				iVar1 = _zq_signed(_v7, 32)
				_pc = 25
			27:
				iVar4 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 26
			28:
				_pc = 27 if (int(_zq_signed(iVar1, 32) != _zq_signed(0, 32))) != 0 else 1
			29:
				uVar2 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 28
			30:
				var _v8: int = f5aa440(0xf000f0)
				iVar1 = _zq_signed(_v8, 32)
				_pc = 29
			31:
				var _v9: int = f5929d0()
				_pc = 30
			32:
				return ((0) & 0xffffffff)
			33:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(1, 32)), 32)) & 0xffff))
				_pc = 32
			34:
				_pc = 33 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 31
			35:
				_pc = 34 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(1, 32))) != 0 else 1
			36:
				_pc = 18 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(0, 32))) != 0 else 35
	return 0


func f596d70(param_1: int) -> int:
	var _stack: int = m.local(264)
	var uVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var extraout_ECX: int = 0
	var extraout_ECX_00: int = 0
	var extraout_var: int = 0
	var bVar4: int = 0
	var unaff_ESI: int = 0
	var uVar6: int = 0
	var uVar5: int = 0
	var unaff_EDI: int = 0
	var uVar7: int = 0
	var _pc: int = 71
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar4, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar4 = ((_zq_signed((_zq_signed(bVar4, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				bVar4 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 3
			5:
				var _v0: int = f592a50(param_1, uVar7)
				_pc = 4
			6:
				return ((1) & 0xffffffff)
			7:
				var _v1: int = f5b9170(((((((((extraout_var) << 16) | ((_zq_signed((_zq_signed(_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), uVar1, uVar5, 1)
				_pc = 5
			8:
				return ((0) & 0xffffffff)
			9:
				_pc = 8 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x201) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 7
			10:
				var _v2: int = f449780(uVar1, iVar2)
				_pc = 9
			11:
				return ((0) & 0xffffffff)
			12:
				_pc = 11 if (int(_zq_signed(_zq_signed(uVar7, 16), 32) == _zq_signed(_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(6, 32)), 32)) & 0xffffffff)), 16), 32))) != 0 else 10
			13:
				uVar7 = ((((((((((_zq_signed((((((((unaff_EDI) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((((uVar1) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff) | ((uVar5) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			14:
				uVar5 = ((((((((((uVar6) << 16) | ((((((iVar2) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff)
				_pc = 13
			15:
				return ((0) & 0xffffffff)
			16:
				_pc = 15 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 14
			17:
				var _v3: int = f569f70(m.u32(0xa55044), iVar2)
				iVar3 = _zq_signed(_v3, 32)
				_pc = 16
			18:
				return ((0) & 0xffffffff)
			19:
				_pc = 18 if (int(_zq_signed(4, 32) < _zq_signed(iVar2, 32))) != 0 else 17
			20:
				iVar2 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 19
			21:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 20
			22:
				var _v4: int = f5929d0()
				_pc = 21
			23:
				return ((0) & 0xffffffff)
			24:
				_pc = 23 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 22
			25:
				return ((0) & 0xffffffff)
			26:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar4, 32)), 32)) & 0xffff))
				_pc = 25
			27:
				bVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 26
			28:
				uVar7 = (((((((((((((((_zq_signed((((((((extraout_ECX_00) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((_zq_signed(uVar1, 8)) & 0xff))) & 0xffffffff) & ((0xffff00ff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((uVar7) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			29:
				var _v5: int = f5b9170(((((((((_zq_signed((((((m.u32(0xa54e54)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zq_signed((_zq_signed(_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), uVar1, uVar7, 1)
				_pc = 28
			30:
				uVar7 = ((((((((((uVar6) << 16) | ((((((_zq_signed(m.u32((_stack + 0)), 32)) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff)
				_pc = 29
			31:
				m.set_u8(((_zq_signed((_zq_signed(_zq_signed((_stack + 0), 32), 32) + _zq_signed(0, 32)), 32)) & 0xffffffff), ((((iVar2) & 0xff)) & 0xff))
				_pc = 30
			32:
				return ((0) & 0xffffffff)
			33:
				_pc = 32 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x201) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 31
			34:
				var _v6: int = f449780(uVar1, iVar2)
				_pc = 33
			35:
				return ((0) & 0xffffffff)
			36:
				_pc = 35 if (int(_zq_signed(iVar3, 32) == _zq_signed(0, 32))) != 0 else 34
			37:
				var _v7: int = f569f70(m.u32(0xa55044), iVar2)
				iVar3 = _zq_signed(_v7, 32)
				_pc = 36
			38:
				return ((0) & 0xffffffff)
			39:
				_pc = 38 if (int(_zq_signed(4, 32) < _zq_signed(iVar2, 32))) != 0 else 37
			40:
				iVar2 = _zq_signed((((((m.u32(0xa55048)) & 0xffffffff) + ((m.u32(0xa5504c)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 39
			41:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 40
			42:
				var _v8: int = f5929d0()
				_pc = 41
			43:
				_pc = 3
			44:
				bVar4 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 43
			45:
				_pc = 44 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 42
			46:
				return ((1) & 0xffffffff)
			47:
				_pc = 60 if (int(_zq_signed(_zq_signed(m.u32((_stack + 0)), 32), 32) < _zq_signed(2, 32))) != 0 else 46
			48:
				m.set_u32((_stack + 0), _zq_signed(_zq_signed((_zq_signed(_zq_signed(m.u32((_stack + 0)), 32), 32) + _zq_signed(1, 32)), 32), 32))
				_pc = 47
			49:
				_pc = 58 if (int(_zq_signed(_zq_signed(m.u32((_stack + 4)), 32), 32) < _zq_signed(5, 32))) != 0 else 48
			50:
				m.set_u32((_stack + 4), _zq_signed(_zq_signed((_zq_signed(_zq_signed(m.u32((_stack + 4)), 32), 32) + _zq_signed(1, 32)), 32), 32))
				_pc = 49
			51:
				return ((1) & 0xffffffff)
			52:
				_pc = 51 if (int(_zq_signed(1, 32) < _zq_signed(iVar2, 32))) != 0 else 50
			53:
				iVar2 = _zq_signed(_zq_signed((_zq_signed(iVar2, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 52
			54:
				var _v9: int = f592a50(param_1, (((((((((((((_zq_signed((((((((extraout_ECX) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((bVar4) & 0xff))) & 0xffffffff) & ((0xffff00ff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((unaff_ESI) & 0xffffffff))) & 0xffffffff))
				_pc = 53
			55:
				var _v10: int = f5b9170(((((((((_zq_signed((((((((iVar3) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zq_signed((_zq_signed(_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), bVar4, unaff_ESI, 1)
				_pc = 54
			56:
				unaff_ESI = ((((((((((_zq_signed((((((unaff_ESI) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((((_zq_signed(m.u32((_stack + 4)), 32)) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff)
				_pc = 55
			57:
				_pc = 56 if (int(_zq_signed(iVar3, 32) != _zq_signed(0, 32))) != 0 else 50
			58:
				var _v11: int = f569f70(bVar4, _zq_signed(m.u32((_stack + 4)), 32))
				iVar3 = _zq_signed(_v11, 32)
				_pc = 57
			59:
				bVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32) ^ _zq_signed(int(_zq_signed(_zq_signed(m.u32((_stack + 0)), 32), 32) == _zq_signed(0, 32)), 32)), 32)) & 0xff)
				_pc = 58
			60:
				m.set_u32((_stack + 4), _zq_signed(0, 32))
				_pc = 59
			61:
				m.set_u32((_stack + 0), _zq_signed(0, 32))
				_pc = 60
			62:
				iVar2 = _zq_signed(0, 32)
				_pc = 61
			63:
				return ((0) & 0xffffffff)
			64:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar4, 32)), 32)) & 0xffff))
				_pc = 63
			65:
				bVar4 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 64
			66:
				var _v12: int = f5bf800((_stack + 8))
				_pc = 65
			67:
				var _v13: int = f5bdfc0((_stack + 8), 0x9b, 2)
				_pc = 66
			68:
				_pc = 67 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 62
			69:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 68
			70:
				var _v14: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 6
				if _v14 == 3: _pc = 24
				if _v14 == 2: _pc = 27
				if _v14 == 1: _pc = 45
				if _v14 == 0: _pc = 69
			71:
				uVar6 = (((((((((unaff_ESI) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 70
	return 0


func f597030(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var puVar5: int = 0
	var extraout_var: int = 0
	var uVar6: int = 0
	var local_100: int = m.local(256)
	var _pc: int = 23
	while true:
		match _pc:
			0:
				return _zq_signed(0, 32)
			1:
				return _zq_signed((((((((((((((-(((int(_zq_signed(m.u16(0xa558b4), 32) != _zq_signed(0, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff), 32)
			2:
				return _zq_signed(1, 32)
			3:
				_pc = 2 if (int(_zq_signed(m.u8(0xa55c8e), 32) != _zq_signed(1, 32))) != 0 else 1
			4:
				return _zq_signed(_zq_signed((-(1)), 32), 32)
			5:
				return _zq_signed(0, 32)
			6:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 5
			7:
				var _v0: int = f5bf9a0(1, 0)
				_pc = 6
			8:
				var _v1: int = f5bf800(local_100)
				_pc = 7
			9:
				var _v2: int = f5bdf40(local_100, 0xd, uVar6)
				_pc = 8
			10:
				var _v3: int = f402290((((((uVar4) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff))
				uVar6 = ((_v3) & 0xffffffff)
				_pc = 9
			11:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 6
			12:
				_pc = 10 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 11
			13:
				var _v4: int = f5797c0(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), uVar2, 0)
				_pc = 12
			14:
				var _v5: int = f4022e0((((extraout_var) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v5) & 0xffff)
				_pc = 13
			15:
				var _v6: int = f592a50(param_1, uVar1)
				_pc = 14
			16:
				uVar4 = ((m.u32(puVar5)) & 0xffffffff)
				_pc = 15
			17:
				var _v7: int = f5700f0((((((uVar4) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), ((((((((((uVar4) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), (((((uVar4) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff))
				puVar5 = ((((_v7) & 0xffffffff)) & 0xffffffff)
				_pc = 16
			18:
				var _v8: int = f5687d0(uVar1)
				uVar4 = ((_v8) & 0xffffffff)
				_pc = 17
			19:
				uVar1 = ((m.u8((0xa563f1 + (_zq_signed((_zq_signed(_zq_signed((_zq_signed(iVar3, 32) * _zq_signed(2, 32)), 32), 32) + _zq_signed(_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32) * _zq_signed(0xd44, 32)), 32), 32)), 32)) * 1))) & 0xff)
				_pc = 18
			20:
				_pc = 19 if (int(_zq_signed(_zq_signed((-(1)), 32), 32) < _zq_signed(iVar3, 32))) != 0 else 4
			21:
				var _v9: int = f5709f0(_zq_signed((_zq_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 0x53c)
				iVar3 = _zq_signed(_v9, 32)
				_pc = 20
			22:
				m.set_u16((param_1 + (2) * 2), ((_zq_signed((_zq_signed(m.u16((param_1 + (2) * 2)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 21
			23:
				_pc = 22 if (int(_zq_signed(m.u8(0xa55c8e), 32) == _zq_signed(0, 32))) != 0 else 3
	return 0


func f5971a0(param_1: int, param_2: int) -> int:
	var cVar1: int = 0
	var uVar2: int = 0
	var bVar3: int = 0
	var iVar4: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xffff))
				_pc = 1
			3:
				bVar3 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 2
			4:
				return ((0) & 0xffffffff)
			5:
				_pc = 4 if (int(_zq_signed(iVar4, 32) == _zq_signed(0, 32))) != 0 else 3
			6:
				var _v0: int = f593a20(param_1, param_2)
				iVar4 = _zq_signed(_v0, 32)
				_pc = 5
			7:
				var _v1: int = f5bcf80(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 1, _zq_signed((_zq_signed(_zq_signed((_zq_signed(1, 32) << ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(cVar1, 32) - _zq_signed(1, 32)), 32), 32) & _zq_signed(0x1f, 32)), 32)) & 31)), 32), 32) ^ _zq_signed(0xff, 32)), 32))
				_pc = 3
			8:
				var _v2: int = f56f9e0((((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), ((((((((((uVar2) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				cVar1 = _zq_signed(_v2, 8)
				_pc = 7
			9:
				var _v3: int = f583440(param_1, 0)
				uVar2 = ((_v3) & 0xffffffff)
				_pc = 8
			10:
				return ((1) & 0xffffffff)
			11:
				var _v4: int = f592a50(param_1, iVar4)
				_pc = 10
			12:
				_pc = 14 if (int((((((((((m.u16(0xa57822)) & 0xffffffff)) & 0xffffffff) & ((_zq_signed((_zq_signed(1, 32) << ((_zq_signed((_zq_signed(bVar3, 32) & _zq_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 11
			13:
				bVar3 = ((_zq_signed((_zq_signed(bVar3, 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 12
			14:
				iVar4 = _zq_signed(_zq_signed((_zq_signed(iVar4, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 13
			15:
				bVar3 = ((0) & 0xff)
				_pc = 14
			16:
				_pc = 15 if (int(_zq_signed(_zq_signed((_zq_signed(m.u16(0xa57822), 32) & _zq_signed(1, 32)), 32), 32) == _zq_signed(0, 32))) != 0 else 11
			17:
				iVar4 = _zq_signed(1, 32)
				_pc = 16
			18:
				_pc = 17 if (int(_zq_signed(_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32), 32) != _zq_signed(2, 32))) != 0 else 9
			19:
				_pc = 6 if (int(_zq_signed(_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32), 32) < _zq_signed(2, 32))) != 0 else 18
	return 0


func f597270(param_1: int, param_2: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var bVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var iVar6: int = 0
	var local_104: int = 0
	var local_100: int = m.local(256)
	var _pc: int = 56
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((1) & 0xffffffff)
			3:
				var _v1: int = int((int(((uVar4) & 0xffffffff) != (((((_zq_signed(iVar5, 8)) << 8) | ((_zq_signed(uVar1, 8)) & 0xff))) & 0xffffffff))) != 0)
				if _v1 != 0:
					var _v0: int = f59dc50(param_1, uVar1, iVar5)
					iVar6 = _zq_signed(_v0, 32)
					_v1 = int((int(_zq_signed(iVar6, 32) != _zq_signed(0, 32))) != 0)
				var _v3: int = int((_v1) != 0)
				if _v3 != 0:
					var _v2: int = f592b00(param_1, uVar1, iVar5)
					iVar5 = _zq_signed(_v2, 32)
					_v3 = int((int(_zq_signed(iVar5, 32) != _zq_signed(0, 32))) != 0)
				_pc = 2 if (_v3) != 0 else 1
			4:
				var _v4: int = f583440(param_1, 0)
				uVar4 = ((_v4) & 0xffffffff)
				_pc = 3
			5:
				iVar5 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 4
			6:
				_pc = 5 if (int(_zq_signed(iVar5, 32) != _zq_signed(0, 32))) != 0 else 1
			7:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 6
			8:
				var _v5: int = f5aa440(0xe000e)
				iVar5 = _zq_signed(_v5, 32)
				_pc = 7
			9:
				var _v6: int = f5929d0()
				_pc = 8
			10:
				_pc = 9 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 1
			11:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xffff))
				_pc = 1
			12:
				bVar3 = ((_zq_signed((_zq_signed(bVar3, 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 11
			13:
				bVar3 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 12
			14:
				return ((0) & 0xffffffff)
			15:
				_pc = 14 if (int(_zq_signed(iVar5, 32) == _zq_signed(0, 32))) != 0 else 13
			16:
				var _v7: int = f592b00(param_1, uVar1, iVar5)
				iVar5 = _zq_signed(_v7, 32)
				_pc = 15
			17:
				return ((0) & 0xffffffff)
			18:
				_pc = 17 if (int(_zq_signed(iVar6, 32) == _zq_signed(0, 32))) != 0 else 16
			19:
				var _v8: int = f59dc50(param_1, m.u32(0xa55044), iVar5)
				iVar6 = _zq_signed(_v8, 32)
				_pc = 18
			20:
				iVar5 = _zq_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 19
			21:
				return ((0) & 0xffffffff)
			22:
				_pc = 21 if (int(_zq_signed(iVar5, 32) == _zq_signed(0, 32))) != 0 else 20
			23:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 22
			24:
				var _v9: int = f5aa440(0xe000e)
				iVar5 = _zq_signed(_v9, 32)
				_pc = 23
			25:
				var _v10: int = f5929d0()
				_pc = 24
			26:
				bVar3 = ((_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) - _zq_signed(1, 32)), 32)) & 0xff)
				_pc = 12
			27:
				_pc = 25 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 26
			28:
				return ((0) & 0xffffffff)
			29:
				m.set_u16(0xa55c8e, ((_zq_signed((_zq_signed(m.u16(0xa55c8e), 32) ^ _zq_signed(bVar3, 32)), 32)) & 0xffff))
				_pc = 28
			30:
				bVar3 = ((_zq_signed((_zq_signed(_zq_signed((_zq_signed(m.u8(0xa55c8e), 32) + _zq_signed(1, 32)), 32), 32) ^ _zq_signed(m.u8(0xa55c8e), 32)), 32)) & 0xff)
				_pc = 29
			31:
				var _v11: int = f5bf800(local_100)
				_pc = 30
			32:
				var _v12: int = f5bdfc0(local_100, 0xa1, 2)
				_pc = 31
			33:
				return ((1) & 0xffffffff)
			34:
				_pc = 33 if (int(_zq_signed(iVar5, 32) == _zq_signed(0, 32))) != 0 else 32
			35:
				var _v13: int = f583120()
				iVar5 = _zq_signed(_v13, 32)
				_pc = 34
			36:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 35
			37:
				var _v14: int = _zq_signed((_zq_signed(m.u16(0xa55c8e), 32) & _zq_signed(0xff, 32)), 32)
				_pc = 1
				if _v14 == 3: _pc = 10
				if _v14 == 1: _pc = 27
				if _v14 == 2: _pc = 30
				if _v14 == 0: _pc = 36
			38:
				return ((1) & 0xffffffff)
			39:
				_pc = 52 if (int(_zq_signed(local_104, 32) < _zq_signed(2, 32))) != 0 else 38
			40:
				local_104 = _zq_signed(_zq_signed((_zq_signed(local_104, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 39
			41:
				_pc = 48 if (int(_zq_signed(iVar6, 32) < _zq_signed(0xb, 32))) != 0 else 40
			42:
				iVar6 = _zq_signed(_zq_signed((_zq_signed(iVar6, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 41
			43:
				return ((1) & 0xffffffff)
			44:
				_pc = 43 if (int(_zq_signed(iVar5, 32) == _zq_signed(2, 32))) != 0 else 42
			45:
				iVar5 = _zq_signed(_zq_signed((_zq_signed(iVar5, 32) + _zq_signed(1, 32)), 32), 32)
				_pc = 44
			46:
				var _v15: int = f592b00(param_1, uVar4, iVar6)
				_pc = 45
			47:
				_pc = 46 if (int(_zq_signed(iVar2, 32) != _zq_signed(0, 32))) != 0 else 42
			48:
				var _v16: int = f59dc50(param_1, uVar4, iVar6)
				iVar2 = _zq_signed(_v16, 32)
				_pc = 47
			49:
				iVar6 = _zq_signed(5, 32)
				_pc = 48
			50:
				uVar4 = ((_zq_signed((_zq_signed(1, 32) - _zq_signed(_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 49
			51:
				uVar4 = ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 49
			52:
				_pc = 50 if (int(_zq_signed(local_104, 32) == _zq_signed(0, 32))) != 0 else 51
			53:
				local_104 = _zq_signed(0, 32)
				_pc = 52
			54:
				m.set_u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff), ((_zq_signed((_zq_signed(m.u16(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(0x1fff, 32)), 32)) & 0xffff))
				_pc = 53
			55:
				iVar5 = _zq_signed(0, 32)
				_pc = 54
			56:
				_pc = 55 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zq_signed((_zq_signed(m.u8(((_zq_signed((_zq_signed(param_1, 32) + _zq_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zq_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 37
	return 0
