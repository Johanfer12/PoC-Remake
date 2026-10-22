class_name JoeyPortS
extends JoeyPortR
## Etapa 4, bloque T: turno, fases, fin de duelo y bucle nativo.
## Fuentes: re/out/joey/funcs/005a41c0.c..005bc700.c; anchos comprobados en ASM.
## Cotejo aislado: re/scripts/joey_specs/port_s.py. Las dependencias sin portar se
## declaran en joey_frontier.py, nunca se sustituyen por reglas del motor de Yugi.

const _JS_PHASE := 0xa577fe
const _JS_WORK := 0xa57800


func _js_next_phase() -> void:
	m.set_u16(_JS_PHASE, m.u16(_JS_PHASE) + 0x100)


func _js_phase(value: int) -> void:
	m.set_u8(_JS_PHASE + 1, value)


func _js_next_zone() -> void:
	var work := m.u16(_JS_WORK)
	m.set_u16(_JS_WORK, work ^ (((work & 0xff00) + 0x100 ^ work) & 0x7f00))


func _js_table(table: int, index: int, args: Array = []) -> int:
	return int(callv("f%06x" % m.u32(table + index * 4), args))


## Robo: comprobacion de bloqueo, Precinto del Tiempo, robo y aviso de fase.
func f5a41c0() -> int:
	var p := m.u32(JoeyMem.TURN) & 1
	match m.u16(_JS_PHASE) >> 8:
		0:
			if m.u32(JoeyMem.pl(p) + 0x6d0) & 0x800002:
				f579930(p, 1, 0)
				return 1
			f5b9170(_jq_op(p, 0x50), 0, 0, 0)
		1:
			var z := _s32(f5709f0(p, 0x520))
			if z >= 0:
				var stamp := m.u8(0xa563f1 + p * 0xd44 + z * 2)
				if p == stamp & 0x80000001 and stamp / 2 <= m.u16(0xa577f8):
					f5797c0(0, 0x520, 0)
					f5797c0(1, 0x520, 0)
					return 0
		2: f578b60(p, 1)
		3: f598590(p, 1, 0)
		_: return 1
	_js_next_phase()
	return 0


## Fin de turno: contadores, equipos, destrucciones y descarte por limite de mano.
func f5a5120() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	var skipped := (m.u32(JoeyMem.pl(p) + 0x6d0) >> 23) & 1
	var phase := m.u16(_JS_PHASE) >> 8
	if phase == 0:
		if skipped == 0:
			f5b9170(_jq_op(p, 0x55), 0, 0, 0)
			f598590(p, 3, 0)
		m.set_u16(_JS_WORK, m.u16(_JS_WORK) & 0x8000)
		_js_phase(2)
		return 0
	if phase == 2:
		if f5a46b0(p) == 0:
			return 0
		_js_next_phase()
		m.set_u16(_JS_WORK, (m.u16(_JS_WORK) & 0x85ff) | 0x500)
		phase = 3
	if phase == 3:
		while m.u16(_JS_WORK) & 0x7f00 < 0xa00:
			var z := (m.u32(_JS_WORK) >> 8) & 0x7f
			var at := JoeyMem.zone(p, z)
			if m.u32(at) & 0xfff and m.u8(at + 6) & 2:
				if f4022e0(m.u16(at) & 0xfff) == 0x47 and m.u8(at + 0x8c) & 0x20 == 0 and m.u32(0xa577ec) & 0x10010 == 0:
					f5b9170(_jq_op(p, 0x8b), z, 1, 0)
					_js_next_zone()
					return 0
			_js_next_zone()
		_js_next_phase()
		m.set_u16(_JS_WORK, (m.u16(_JS_WORK) & 0x85ff) | 0x500)
		phase = 4
	if phase == 4:
		var q := 1 - p
		while m.u16(_JS_WORK) & 0x7f00 < 0xa00:
			var z := (m.u32(_JS_WORK) >> 8) & 0x7f
			var at := JoeyMem.zone(q, z)
			if m.u32(at) & 0xfff and m.u8(at + 6) & 2:
				var id := s16(f4022e0(m.u16(at) & 0xfff))
				if id == 0x15b or id == 0x4ce:
					f5b9170(_jq_op(q, 0x8b), z, 1, 0)
					if skipped == 0 and m.u8(at + 6) & 0x3c == (8 if id == 0x15b else 4):
						f577840(q, z, 0, 0)
					_js_next_zone()
					return 0
			_js_next_zone()
		_js_next_phase()
		return 0
	if phase == 5:
		for k in 2:
			var q := k ^ p
			for z in range(5, 10):
				var at := JoeyMem.zone(q, z)
				if m.u16(at) & 0xfff == f402460(0x60c) & 0xffff and m.u8(at + 6) & 2:
					var ref := f56fb40(q, z)
					var owner := ref & 0xff
					if owner == p:
						f5b9170(_jq_op(q, 0x8b), z, 1, 0)
						if skipped == 0 and m.u32(at + 0x8c) & 0x20 == 0 and m.u8(at + 6) & 0x3c == 4:
							f578390(q, m.u16(at) & 0xfff, z)
							m.set_u32(at, m.u32(at) & 0xfffff000)
							var done := f577840(owner, (ref >> 8) & 0xff, int(q != owner), f402460(0x60c))
							m.set_u32(at, (f402460(0x60c) & 0xfff) | (m.u32(at) & 0xfffff000))
							if done != 0:
								f5779d0(q, z, 0, 0)
		_js_next_phase()
		return 0
	if phase == 6:
		for k in 2:
			var q := k ^ p
			for z in 5:
				var at := JoeyMem.zone(q, z)
				if m.u16(at) & 0xfff:
					var linked := f56c460(q, z)
					var destroy := false
					var reason := 0
					var count := (m.u16(at + 6) & 0x1c0) >> 6
					if q == p and count != 0:
						f5b9170(_jq_op(q, 0x97), z, count - 1, 0)
						if skipped == 0 and count == 1:
							destroy = true
							reason = 1
					if f56db30(q, z, 0x458) != 0:
						destroy = true
					if linked == 0 and f56dbe0(q, z, 0x8000) != 0:
						destroy = true
					if f56db30(q, z, 0x5e8) != 0 or destroy:
						f577840(q, z, reason, 0)
		_js_next_phase()
		return 0
	if phase == 7:
		if skipped != 0:
			return 1
		_js_phase(10)
		phase = 10
	if phase == 10:
		_js_next_phase()
		m.set_u16(_JS_WORK, m.u16(_JS_WORK) & 0x8000)
		phase = 11
	if phase == 11:
		while m.u8(_JS_WORK) <= 9:
			if _js_table(0x5dd010, m.u8(_JS_WORK), [p]) == 0:
				return 0
			m.set_u16(_JS_WORK, m.u16(_JS_WORK) & 0x80ff)
			m.set_u8(_JS_WORK, m.u8(_JS_WORK) + 1)
		_js_phase(100)
		return 0
	if phase == 100:
		var n := m.u8(JoeyMem.pl(p) + 8)
		if f5699c0(0x593) == 0 and n > 6:
			f5bcdc0(p, n - 6, 0, 0)
			return 0
		_js_next_phase()
		return 0
	return 1


func f5a59b0() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	var phase := m.u16(_JS_PHASE) >> 8
	if phase != 0:
		if phase == 1 and f5709d0(p, 0x517) != 0:
			f579930(p, 0x17, 1)
		return 1
	f5b9170(_jq_op(p, 1), 0, 0, 0)
	_js_next_phase()
	return 0


func f5a5a40() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	match m.u16(_JS_PHASE) >> 8:
		0:
			if m.u32(JoeyMem.pl(p) + 0x6d0) & 0x800000:
				return 1
			f5b9170((m.u16(JoeyMem.TURN) << 15) | 0x52, 0, 0, 0)
			m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffc)
			_js_next_phase()
		10:
			if f5a0dd0(p) != 0:
				f5bf800(0xe5)
				f5bf9a0(3, 2)
				_js_phase(20)
			else:
				f5bf800(0xe6)
				f5bf9a0(1, 0)
				_js_next_phase()
		11:
			if m.u16(0xa558b4) != 0:
				return 1
			_js_phase(1)
		20:
			match m.u16(0xa558b4):
				0:
					m.set_u16(_JS_WORK, m.u16(_JS_WORK) & 0x7fff)
					m.set_u16(JoeyMem.TURN, m.u16(JoeyMem.TURN) & 0xff)
					_js_next_phase()
				1: return 1
				_: _js_phase(1)
		21:
			if f5a4090(p) != 0:
				if m.u32(_JS_WORK) & 0x8000:
					return 1
				f5b9170((m.u16(JoeyMem.TURN) << 15) | 0x54, 0, 0, 0)
				_js_phase(1)
		_:
			if f5a0cd0() == 0:
				if m.u32(0xa54e54) & 0x102:
					_js_phase(10)
				var choice := f481a10()
				if choice == 3:
					f44ef40(1)
					m.set_u16(_JS_WORK, m.u16(_JS_WORK) & 0x7fff)
					m.set_u16(JoeyMem.TURN, m.u16(JoeyMem.TURN) & 0xff)
					_js_phase(21)
				elif choice == 5:
					f44ef40(1)
					return 1
	return 0


func f5a8040(card_id: int) -> int:
	match card_id & 0xffff:
		0x482: return 700
		1099: return 2000
		0x46b: return 100
		0x58c: return 1000
		0x590: return 500
	return 0


func f5a8090() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	var skipped := m.u32(JoeyMem.pl(p) + 0x6d0) & 0x800004 != 0
	var phase := m.u16(_JS_PHASE) >> 8
	if phase == 0:
		if skipped:
			_js_phase(200)
		else:
			f5b9170(_jq_op(p, 0x51), 0, 0, 0)
			m.set_u16(_JS_WORK, m.u16(_JS_WORK) & 0x8000)
			_js_next_phase()
		return 0
	if phase == 1:
		while m.u8(_JS_WORK) <= 0x1a:
			if _js_table(0x5dd038, m.u8(_JS_WORK), [p]) == 0:
				return 0
			m.set_u16(_JS_WORK, m.u16(_JS_WORK) & 0x80ff)
			m.set_u8(_JS_WORK, m.u8(_JS_WORK) + 1)
		_js_phase(100)
		return 0
	if phase == 100:
		m.set_u16(_JS_WORK, m.u16(_JS_WORK) & 0x80ff)
		_js_next_phase()
		phase = 101
	if phase == 101:
		while m.u16(_JS_WORK) & 0x7f00 < 0xa00:
			var z := (m.u32(_JS_WORK) >> 8) & 0x7f
			var at := JoeyMem.zone(p, z)
			var index := m.u16(at) & 0xfff
			if index != 0 and m.u8(at + 6) & 2:
				var id := f4022e0(index) & 0xffff
				if id in [0x482, 1099, 0x46b, 0x58c, 0x590]:
					if f5a8040(f4022e0(index)) < m.u16(JoeyMem.pl(p) + 4):
						_js_phase(110)
						return 0
					f577840(p, z, 0, index)
				elif id == 0x47a or id == 0x597:
					if _s32(f56a290(p, (z << 8) | p)) > 0:
						_js_phase(120)
						return 0
					f577840(p, z, 0, index)
			_js_next_zone()
		_js_phase(200)
		return 0
	var z := (m.u32(_JS_WORK) >> 8) & 0x7f
	var index := m.u32(JoeyMem.zone(p, z)) & 0xfff
	match phase:
		110:
			if (m.u8(JoeyMem.MODE) >> 1) & 3 & (1 << p) == 0:
				var prefix := m.local(0x80)
				var text := m.local(0x100)
				f5bdf40(prefix, 0xe8, f402290(index))
				f5bdfc0(text, prefix, f5a8040(f4022e0(index)))
				f5bf800(text)
				f5bf9a0(1, 0)
			else:
				m.set_u16(0xa558b4, 1)
				var id := s16(f4022e0(index))
				if id == 1099:
					m.set_u16(0xa558b4, int(m.u16(JoeyMem.pl(p) + 4) > 6000))
				elif id == 0x482:
					m.set_u16(0xa558b4, int(_s32(f5afe90(p)) < 1))
			f578390(p, index, z)
			_js_next_phase()
		111:
			if m.u16(0xa558b4) == 0:
				f577840(p, z, 0, index)
			else:
				f578460(p, f5a8040(f4022e0(index)))
			_js_next_zone()
			_js_phase(101)
		120:
			if (m.u8(JoeyMem.MODE) >> 1) & 3 & (1 << p) == 0:
				var text := m.local(0x100)
				f5bdf40(text, 0xe9, f402290(index))
				f5bf800(text)
				f5bf9a0(1, 0)
			else:
				m.set_u16(0xa558b4, 0)
			_js_next_phase()
		121:
			if m.u16(0xa558b4) == 0:
				f577840(p, z, 0, index)
				_js_next_zone()
				_js_phase(101)
			else:
				_js_next_phase()
		122:
			if m.u32(0xa54e54) & 0x102:
				_js_phase(120)
				return 0
			if f5aa440(0xf000f0) == 0:
				return 0
			var q := m.u32(0xa55044)
			var target := (m.u32(0xa5504c) + m.u32(0xa55048)) & 0xffffffff
			if f56a140(p, q, target) == 0 or (q == p and target == z):
				return 0
			if f5aa480() == 0:
				return 0
			f577b30(m.u32(0xa55044), m.u32(0xa5504c))
			_js_next_zone()
			_js_phase(101)
		200:
			for zz in 5:
				var at := JoeyMem.zone(p, zz)
				if m.u32(at) & 0xfff and m.u8(at + 6) & 2 and s16(f4022e0(m.u16(at) & 0xfff)) == 0x52:
					f59c8d0(p, zz)
			f59ca20(p)
			for zz in range(5, 10):
				var at := JoeyMem.zone(p, zz)
				if m.u32(at) & 0xfff and m.u8(at + 6) & 2 and s16(f4022e0(m.u16(at) & 0xfff)) in [0x416, 0x424]:
					f5b9170(_jq_op(p, 0x8b), zz, 1, 0)
			for zz in range(5, 10):
				var at := JoeyMem.zone(1 - p, zz)
				if m.u32(at) & 0xfff and m.u8(at + 6) & 2 and s16(f4022e0(m.u16(at) & 0xfff)) == 0x2df:
					var ref := f56fb40(1 - p, zz)
					var target := (ref & 0xffff) >> 8
					if ref & 0xffff != 0xffff:
						var link := f56dc10(ref & 0xff, target, 1 - p, zz)
						if m.u16(0xa55dc0 + target * 0x90 + (ref & 1) * 0xd44 + link * 2) & 0xf == 1:
							f5b9170(_jq_op(1 - p, 0x8b), zz, 1, 0)
			f579930(p, 2, 0)
			_js_next_phase()
		_: return 1
	return 0


func f5a8a50() -> int:
	var phase := m.u16(_JS_PHASE) >> 8
	if phase < 2:
		f5b9170(_jq_op(m.u8(JoeyMem.TURN) & 1, 2 + phase), 0, 0, 0)
		_js_next_phase()
	return 0


func f5a8b00() -> int:
	var extra := 0xa58278 if m.u16(0xa58278) != 0 else 0
	var phase := m.u16(0xa58294) >> 8
	if phase == 0:
		m.set_u16(0xa55c8c, m.u16(0xa55c8c) & 0xff)
		m.set_u16(0xa55c8e, m.u16(0xa55c8e) & 0xff)
		m.set_u16(0xa58294, m.u16(0xa58294) + 0x100)
	elif phase != 1:
		if phase == 2:
			f5bd090(0xf092, 0xa58264, 0x14)
		return 1
	var result := _s32(f59de30(0xa58264, extra))
	if result != 0:
		m.set_u16(0xa58266, (int(result > 0) << 15) | (m.u16(0xa58266) & 0x7fff))
		m.set_u16(0xa58294, m.u16(0xa58294) + 0x100)
	return 0


func f5a8be0() -> int:
	var extra := 0xa58278 if m.u16(0xa58278) != 0 else 0
	var phase := m.u8(0xa58296)
	if phase == 0:
		m.set_u16(0xa55c8e, 0)
		m.set_u16(0xa58296, m.u16(0xa58296) ^ 1)
	elif phase != 1:
		if phase == 2:
			f5bd090(0xf082, 0xa58264, 0x14)
		return 1
	var result := _s32(f59de70(0xa58264, extra))
	if result != 0:
		m.set_u16(0xa58268, m.u16(0xa58268) ^ ((int(result > 0) ^ m.u8(0xa58268)) & 1))
		m.set_u8(0xa58296, m.u8(0xa58296) + 1)
	return 0


func f5a8c90() -> int:
	var phase := m.u16(0xa58296) >> 8
	if phase == 0:
		m.set_u16(0xa58296, m.u16(0xa58296) + 0x100)
		m.set_u16(0xa55c8a, 0x80)
	elif phase != 1:
		if phase == 2:
			f5bd090(0xf073, 0xa58264, ((m.u32(0xa58298) & 1) + 1) * 0x14)
		return 1
	var result := f59deb0(0xa58264, 0xa58278 if m.u8(0xa58298) & 1 else 0) & 0xff
	m.set_u16(0xa55c8a, m.u16(0xa55c8a) ^ (result ^ m.u8(0xa55c8a)))
	if m.u8(0xa55c8a) == 0:
		m.set_u16(0xa58296, m.u16(0xa58296) + 0x100)
	return 0


func f5a8d70() -> int:
	for pair in [[0x20000, 0x5a8b00], [0x8000, 0x5a8be0], [0x200, 0x5986a0], [0x80000, 0x5a8c90]]:
		if m.u32(0xa58260) & pair[0]:
			if int(call("f%06x" % pair[1])) != 0:
				m.set_u32(0xa58260, m.u32(0xa58260) & ~int(pair[0]))
			return 1
	return 0


func f5a8e00() -> int:
	f5a8d70()
	return 0


func f5b9f50() -> int:
	var old := m.u16(JoeyMem.TURN)
	m.set_u16(0xa577f4, m.u16(0xa577f4) & 0xffef)
	m.set_u16(JoeyMem.TURN, ((m.u8(JoeyMem.MODE) >> 3) & 1) | (old & 0xfffe))
	if m.u32(JoeyMem.MODE) & 0x180 == 0x80:
		m.set_u16(JoeyMem.MODE, m.u16(JoeyMem.MODE) & 0xfdff)
		f5bc580(0)
		return 1
	if (old & 0x10 == 0 or (~m.u8(JoeyMem.MODE) ^ m.u8(JoeyMem.TURN)) & 1) and m.u8(_JS_PHASE + 1) == 0:
		f5b9170(0x14, 0, 0, 0)
		f5b9170(0x10, 0, 0, 0)
		f5b9170((m.u16(JoeyMem.TURN) << 15) | 0x61, 0, 5, 0)
		f5b9170(_jq_op(1 - (m.u8(JoeyMem.TURN) & 1), 0x61), 0, 5, 0)
		_js_next_phase()
		return 0
	return 1


func f5bbf70(p: int) -> int:
	for id in range(0x10, 0x15):
		if f56d2c0(p, id) == 0:
			return 0
	return 1


func f5bbfd0(p: int) -> int:
	if f5699a0(p, 0x5f8) == 0:
		return 0
	for id in range(0x605, 0x609):
		if _s32(f569720(p, id)) < 0:
			return 0
	return 1


func f5bc050() -> int:
	var local := m.u32(JoeyMem.MODE) & 1
	var other := 1 - local
	var turn := m.u16(JoeyMem.TURN)
	if turn & 0x10 and (~m.u8(JoeyMem.MODE) ^ turn) & 1 == 0:
		return 0
	var a := JoeyMem.pl(local) + 0xc
	var b := JoeyMem.pl(other) + 0xc
	var result := turn | 0xc0
	if (m.u16(a) | m.u16(b)) & 0x100:
		if m.u16(a) & 0x100 == 0:
			result = (result & 0xff7f) | 0x40
		if m.u16(b) & 0x100 == 0:
			result = (result & 0xffbf) | 0x80
	else:
		m.set_u16(a, ((f5bbf70(local) & 1) << 9) | (m.u16(a) & 0xfdff))
		m.set_u16(b, ((f5bbf70(other) & 1) << 9) | (m.u16(b) & 0xfdff))
		var bit := 0x200
		if (m.u16(a) | m.u16(b)) & bit == 0:
			m.set_u16(a, ((f5bbfd0(local) & 1) << 10) | (m.u16(a) & 0xfbff))
			m.set_u16(b, ((f5bbfd0(other) & 1) << 10) | (m.u16(b) & 0xfbff))
			bit = 0x400
		if (m.u16(a) | m.u16(b)) & bit:
			if m.u16(b) & bit == 0:
				result = (result & 0xff7f) | 0x40
			if m.u16(a) & bit == 0:
				result = (result & 0xffbf) | 0x80
		else:
			var lp_a := m.u16(JoeyMem.pl(local) + 4)
			var lp_b := m.u16(JoeyMem.pl(other) + 4)
			if lp_a != 0 and lp_b != 0:
				return 0
			if lp_b < lp_a:
				result = (result & 0xff7f) | 0x40
			if lp_a < lp_b:
				result = (result & 0xffbf) | 0x80
	m.set_u16(JoeyMem.TURN, result)
	m.set_u8(0xa577f4, m.u8(0xa577f4) | 0x10)
	return 1


func f5bc3c0() -> int:
	if m.u16(JoeyMem.TURN) & 0x10 and m.u8(0xa58260) & 0x20:
		return 1
	var phase := m.u16(_JS_PHASE) >> 8
	if phase == 0:
		var local := m.u32(JoeyMem.MODE) & 1
		for pair in [[0x200, 5], [0x400, 6]]:
			if (m.u16(JoeyMem.pl(0) + 0xc) | m.u16(JoeyMem.pl(1) + 0xc)) & pair[0]:
				var p := local if m.u16(JoeyMem.pl(local) + 0xc) & pair[0] else 1 - local
				f5b9170(_jq_op(p, pair[1]), 0, 0, 0)
		var result := m.u8(JoeyMem.TURN) >> 6
		f44b9e0(result)
		if result in [1, 2, 3]:
			f5b9170((m.u32(JoeyMem.MODE) << 15) | 4, result - 1, 0, 0)
	elif phase == 1:
		if m.u16(JoeyMem.QUEUE_COUNT) != 0:
			return 0
		if m.u16(JoeyMem.TURN) & 0x10 == 0:
			return 1
		f5bd050(0xf002, m.u8(JoeyMem.TURN) >> 6, 0, 0)
	else:
		return 0
	_js_next_phase()
	return 0


func f5bc580(all_commands: int) -> int:
	while true:
		if f449e20() != 0:
			m.set_u8(0xa54e5d, m.u8(0xa54e5d) | 2)
			return 0
		var at := f449df0()
		f5b9370(m.u16(at), m.u16(at + 2), m.u16(at + 4), m.u16(at + 6))
		f449e00()
		if all_commands == 0:
			return 0
	return 0


func f5bc5d0() -> int:
	var at := 0x5efb94 + m.u8(_JS_PHASE) * 4
	if m.u32(at) == 0:
		return 1
	if _js_table(0x5efb94, m.u8(_JS_PHASE)) != 0:
		m.set_u16(_JS_PHASE, (m.u8(_JS_PHASE) + 1) & 0xff)
	return 0


func f5bc620() -> int:
	var p := m.u8(JoeyMem.TURN) & 1
	var mode := m.u32(JoeyMem.MODE)
	if mode & 0x180 == 0x80:
		return (mode >> 9) & 1
	if (m.u8(JoeyMem.TURN) & 0x10 and m.u8(0xa58260) & 0x20) or m.u8(0xa577f4) & 0x10:
		return 1
	if f5bf9c0() != 0 or f5bc9b0() != 0 or f5ab820() != 0 or f5b8c00() != 0 or f5bbe40() != 0 or f5ba060() != 0:
		return 0
	if f5bc050() != 0:
		return 1
	if ((m.u8(JoeyMem.MODE) >> 1) & 3) & (1 << p):
		f5b7bd0()
	elif m.u8(JoeyMem.TURN) & 0x10 and p == (~m.u8(JoeyMem.MODE) & 1):
		f5a8e00()
	else:
		f5bc5d0()
	return 0


func f5bc700() -> int:
	var index := m.u16(0xa577fc) >> 8
	if m.u32(0x5efbb0 + index * 4) == 0:
		m.set_u16(JoeyMem.MODE, ((m.u8(JoeyMem.TURN) >> 2) & 0x30) | (m.u16(JoeyMem.MODE) & 0xfe4f))
		return 1
	if m.u8(JoeyMem.TURN) & 0x10 and f5bd2d0() == 0:
		return 1
	if f40ca70() == 0:
		f5aa490()
	if f40cf20() == 0 and f5b9ca0() == 0 and _js_table(0x5efbb0, m.u16(0xa577fc) >> 8) != 0:
		m.set_u16(0xa577fc, m.u16(0xa577fc) + 0x100)
		m.set_u16(_JS_PHASE, m.u16(_JS_PHASE) & 0xff)
	f569fc0()
	return 0
