class_name JoeyPortT
extends JoeyPortS
## Etapa 4, bloque B. Flujo y registros de combate del ejecutable de Joey.
## Fuentes: re/out/joey/funcs/005a1200.c..005a4090.c y 005b7c50.c/005b8210.c.

const _JT_B := 0xa57840
const _JT_STEP := 0xa577fc


func f5be070(value: int) -> int:
	return _cdiv(_s32(value * 5 + 4), 10) & 0xffffffff


func _jt_next() -> void:
	m.set_u8(_JT_STEP, m.u8(_JT_STEP) + 1)


func _jt_step(n: int) -> void:
	m.set_u8(_JT_STEP, n)


func _jt_turn(n: int) -> void:
	m.set_u8(JoeyMem.TURN + 1, n)


func _jt_ai(p: int) -> bool:
	return ((m.u32(JoeyMem.MODE) >> 1 & 3) >> (p & 31) & 1) != 0


func _jt_atk() -> int:
	return m.u32(_JT_B) >> 8 & 7


func _jt_def() -> int:
	return m.u32(_JT_B) >> 11 & 7


func _jt_other() -> int:
	return m.u32(_JT_B) >> 1 & 1


func _jt_pair() -> int:
	return (_jt_def() << 8 | _jt_other()) << 16 | _jt_atk() << 8 | m.u8(_JT_B) & 1


func f5a1200(p: int) -> int:
	var flag := 0x8000 if p != 0 else 0
	f5b9170(flag | 0x32, 1, 0, 0)
	f5b9170(flag | 0x53, 0, 0, 0)
	return 1


func f5a1240(p: int) -> int:
	m.set_u16(_JT_B, m.u16(_JT_B) ^ ((m.u8(_JT_B) ^ p) & 1))
	var work := m.u16(_JT_B)
	match m.u8(_JT_STEP):
		0:
			f5798f0(0, 0)
			f5a0d60(0xa55d64, p, 0, 0)
			m.set_u16(_JT_B, m.u16(_JT_B) & 0xff9b)
			if p == (m.u32(JoeyMem.MODE) & 1):
				f5bdbd0(p, 0, 0)
			f5b9170(0x56, m.u16(JoeyMem.pl(p) + 0xe), 0, 0)
			_jt_next()
		1:
			if _jt_ai(p):
				if f5b1310(p) == 0:
					_jt_step(0)
					_jt_turn(12)
					return 0
				m.set_u16(_JT_B, (m.u8(0xa579a6) & 0x70) << 4 | m.u16(_JT_B) & 0xf8e7)
				return 1
			if f5a0cd0() != 0:
				return 0
			var input := _s32(f481a10())
			var action := 0
			if input >= 1 and f5709d0(p, 0x246) != 0:
				action = 2
			elif input == 4 or input == 5:
				f44ef40(1)
				m.set_u16(0xa558b4, input - 4)
				_jt_step(10)
				return 0
			if m.u32(0xa54e54) & 0x102:
				action = f5709d0(p, 0x246) + 1
			if action == 0:
				return 0
			f5bf800(0xdc if action == 2 else 0xdd)
			f5bf9a0(3, 2)
			_jt_step(10)
		10:
			var answer := m.u16(0xa558b4)
			if answer == 2:
				_jt_step(1)
				return 0
			var card := f5709d0(p, 0x246)
			var delta := answer - card
			if delta < -1 or delta > 1:
				return 0
			_jt_step(0)
			m.set_u16(0xa57800, (m.u16(0xa57800) | 0x8000) if delta == 1 else (m.u16(0xa57800) & 0x7fff))
			_jt_turn(12)
			if delta == 0:
				f5797c0(p, 0x246, 1)
		_:
			m.set_u32(_JT_B, m.u32(_JT_B) & 0xffffff67)
			f413af0(work >> 8 & 7)
			return 1
	return 0


func f5a1580(p: int) -> int:
	m.set_u16(_JT_B, m.u16(_JT_B) ^ (((p + 1) * -2 ^ m.u8(_JT_B)) & 2))
	match m.u8(_JT_STEP):
		0:
			if f56bf20(p, _jt_atk()) != 0:
				m.set_u32(_JT_B, m.u32(_JT_B) | 4)
				_jt_step(4)
				return 0
			if f56c460(p, _jt_atk()) == 0:
				var other := 1 - p
				var n := _s32(f56dcc0(other, 0x422))
				if n > 0:
					f5b9170(_jq_op(other, 0x1e), 0x422, 0, 0)
					if f56dcc0(other, 0x422) == 1:
						var z := 0
						while z < 5 and f56d740(other, z, 0x422) == 0:
							z += 1
						m.set_u16(_JT_B, (z & 7) << 11 | m.u16(_JT_B) & 0xc7ff)
						_jt_step(4)
						return 0
					_jt_step(2)
					return 0
			if f56bfd0(p, _jt_atk()) == 0:
				_jt_step(2)
			elif not _jt_ai(p):
				f5bf800(0xdf)
				f5bf9a0(1, 0)
				_jt_step(1)
			else:
				m.set_u32(_JT_B, m.u32(_JT_B) | 4)
				_jt_step(4)
		1:
			if m.u16(0xa558b4) != 0:
				m.set_u32(_JT_B, m.u32(_JT_B) | 4)
				_jt_step(4)
			else:
				_jt_next()
		2:
			if not _jt_ai(p):
				f413b20()
				_jt_next()
				return 0
			if f5b1320(p, _jt_atk()) == 0:
				f5b9170(_jq_op(p, 0x35), _jt_atk(), 1, 0)
				_jt_step(0)
				_jt_turn(1)
				return 0
			if m.u16(0xa579a6) & 2:
				m.set_u32(_JT_B, m.u32(_JT_B) | 4)
				_jt_step(4)
				return 0
			m.set_u16(_JT_B, (m.u16(0xa579a6) & 0x380) << 4 | m.u16(_JT_B) & 0xc7ff)
			f5b9170(_jq_op(p, 0x33), _jt_atk(), _jt_def(), _jt_other() + 1)
			return 1
		3:
			f5929d0()
			if f5aa440(0xf00000) == 0 or f56bd80(p, _jt_atk(), m.u32(0xa55044), m.u32(0xa5504c)) == 0 or f5aa480() == 0:
				if m.u32(0xa54e54) & 0x102:
					f44ef40(2)
					f5bdbd0(p, 0, _jt_atk())
					_jt_step(0)
					_jt_turn(1)
					if m.u32(_JT_B) & 0x80:
						f5b9170(m.u32(_JT_B) << 15 | 0x35, _jt_atk(), 1, 0)
				return 0
			m.set_u16(_JT_B, (m.u32(0xa5504c) & 7) << 11 | m.u16(_JT_B) & 0xc7ff)
			_jt_next()
		4:
			if m.u32(_JT_B) & 4:
				f5b9170(_jq_op(p, 0x34), _jt_atk(), 1, 0)
				m.set_u32(_JT_B, m.u32(_JT_B) & 0xffffefff | 0x2800)
			else:
				f5b9170(_jq_op(p, 0x33), _jt_atk(), _jt_def(), _jt_other() + 1)
			return 1
		_: return 1
	return 0


func f5a1a00(p: int) -> int:
	var entry := m.u16(JoeyMem.zone(p, _jt_atk()))
	match m.u8(_JT_STEP):
		0:
			if m.u32(_JT_B) & 8:
				return 1
			if f56b730(p, _jt_atk(), 1) == 0:
				f5b9170(_jq_op(p, 0x35), _jt_atk(), 1, 0)
				_jt_turn(1)
				return 0
			f5a0e30()
			m.set_u32(_JT_B, m.u32(_JT_B) | 8)
			var card := f4022e0(entry & 0xfff) & 0xffff
			if card == 0x2e8 or card == 0x2f9:
				if not _jt_ai(p):
					f5bf800(0xe0)
					_jt_step(100)
					return 0
				var target := _s32(f5aed60(p, (_jt_atk() << 8 | p & 0xff) & 0x7ff, 0))
				if target >= 0:
					f577b30(target & 0xff, target >> 8 & 0xff)
					return 1
				f5b9170(m.u32(_JT_B) << 15 | 0x35, _jt_atk(), 1, 0)
				_jt_step(0)
				_jt_turn(1)
				return 0
			if card == 0x226:
				f578460(p, 1000)
			elif card in [0x2d6, 0x2d7, 0x2d8, 0x2fe]:
				f578460(p, 500)
			elif card == 0x16e:
				if not _jt_ai(p):
					f5bf800(0x38)
					f5bf9a0(7, 0)
				else:
					m.set_u16(0xa558b4, 0)
				_jt_step(200)
				return 0
		100:
			if f5aa440(0xf000f0) != 0:
				var q := m.u32(0xa55044)
				var z := (m.u32(0xa5504c) + m.u32(0xa55048)) & 0xffffffff
				if f56a140(p, q, z) != 0 and (q != p or z != _jt_atk()) and f5aa480() != 0:
					f577b30(q, z)
					_jt_next()
			return 0
		101: return int(f5a0f00() == 0)
		200:
			var result := f5bddb0(2)
			f5b9170(_jq_op(p, 0xe0), m.u16(0xa558b4), result, _jt_atk())
			if result != m.u16(0xa558b4):
				f578460(p, f5be070(m.u16(JoeyMem.pl(p) + 4)))
	return 1


func f5a1f30(p: int) -> int:
	var other := _jt_other()
	match m.u8(_JT_STEP):
		0: f5a0e30()
		1:
			if f5699c0(0x602) != 0:
				f579790(p, f402460(0x602), (JoeyMem.ident(m.u32(JoeyMem.zone(p, _jt_atk()))) & 0xff) << 8 | 3)
		2:
			var q := 1 - p
			for z in range(5, 10):
				var a := JoeyMem.zone(q, z)
				var state := m.u32(a + 0x8c)
				if f4022e0(m.u16(a) & 0xfff) == 1099 and (m.u8(a + 6) >> 1 & ~(state >> 5) & ~(state >> 1) & 1) != 0 and _s32(f56dc10(p, _jt_atk(), q, z)) < 0:
					f578390(q, m.u16(a) & 0xfff, z)
					f5747e0(q, z << 8 | q & 0xff, (_jt_atk() << 8 | p & 0xff) & 0x7ff, 6)
		3:
			if f5a0f00() != 0:
				return 0
			f5798f0(1, 1)
			if f5699a0(other, 0x590) != 0:
				for z in range(5, 10):
					var a := JoeyMem.zone(other, z)
					var entry := m.u32(a)
					var state := m.u32(a + 0x8c)
					if f4022e0(entry & 0xfff) == 0x590 and (m.u8(a + 6) >> 1 & ~(state >> 5) & ~(state >> 1) & 1) != 0:
						f5ba490(((z & 31 | other << 15 | 0x2420) << 16 | entry & 0xfff) & 0xffffffff, JoeyMem.ident(entry), _jt_pair())
			f598590(m.u8(JoeyMem.TURN) & 1, 0x12, _jt_pair())
		_: return int(f5a0f00() == 0)
	_jt_next()
	return 0


func f5a22c0() -> int:
	var work := m.u32(_JT_B)
	var pair := _jt_pair()
	var attack := m.u32(JoeyMem.zone(work & 1, _jt_atk()))
	var other := _jt_other()
	var defense := m.u32(JoeyMem.zone(other, _jt_def()))
	match m.u8(_JT_STEP):
		0:
			f5798f0(0, 1)
			f5b9170(m.u32(_JT_B) << 15 | 0x35, _jt_atk(), 1, 0)
		1:
			m.set_u32(_JT_B, m.u32(_JT_B) & 0xffff)
			if (work & 4) == 0 and (m.u8(JoeyMem.zone(other, _jt_def()) + 6) & 2) == 0:
				f574f70(other, _jt_def(), 0, 0)
				f578430(_jt_other(), m.u16(JoeyMem.zone(_jt_other(), _jt_def())) & 0xfff)
				m.set_u32(_JT_B, (m.u16(JoeyMem.zone(_jt_other(), _jt_def())) << 16 | m.u16(_JT_B)) & 0xfffffff)
		2:
			if f56b440(attack & 0xfff, JoeyMem.ident(attack)) == 0 and f4022e0(attack & 0xfff) == 0x540:
				f5b9170(m.u32(_JT_B) << 15 | 0x94, _jt_atk(), 0, 0)
			if (m.u32(_JT_B) & 4) == 0 and f56b440(defense & 0xfff, JoeyMem.ident(m.u32(JoeyMem.zone(_jt_other(), _jt_def())))) == 0 and f4022e0(defense & 0xfff) == 0x4b1:
				if m.u8(JoeyMem.zone(_jt_other(), _jt_def()) + 6) & 1:
					f5747e0(_jt_other(), m.u16(JoeyMem.zone(_jt_other(), _jt_def())) & 0xfff, (_jt_def() << 8 | m.u8(_JT_B) >> 1) & 0x701, 3)
			if m.u32(_JT_B) & 0x40:
				return 1
		3:
			if (m.u32(_JT_B) & 4) == 0 and ((other ^ m.u8(_JT_B)) & 1) != 0:
				var card := f4022e0(m.u16(JoeyMem.zone(other, _jt_def())) & 0xfff) & 0xffff
				if card == 0x5f2 or (card in [0x4db, 0x2df, 0x492] and m.u16(_JT_B + 2) != 0):
					var z := _jt_def()
					var entry := m.u32(JoeyMem.zone(_jt_other(), z))
					f5ba490((((m.u32(_JT_B) & 0xfffe) << 14 | z | 0x2620) << 16 | entry & 0xfff) & 0xffffffff, JoeyMem.ident(entry), pair)
			f598590(m.u8(JoeyMem.TURN) & 1, 0x13, pair)
		_: return 1
	_jt_next()
	return 0


func _jt_flags(a: int) -> int:
	var f := m.u8(a)
	return (((((f >> 7) << 1 | f >> 6 & 1) << 1 | int(m.u32(a + 12) != 0)) << 1 | f >> 4 & 1) << 1 | f >> 5 & 1) & 0xff


func f5a2740(p: int) -> int:
	match m.u8(_JT_STEP):
		0:
			f5b9170(m.u32(_JT_B) << 15 | 0x30, m.u16(0xa57846), m.u16(0xa57856), 0)
			f5b7c50(1)
			if (m.u32(_JT_B) & 0x40) == 0:
				var a := 0xa57858 if (m.u8(0xa57854 - p * 16) & 0x20) == 0 else 0xa5785c
				f598590(m.u8(JoeyMem.TURN) & 1, 13, (m.u32(a - p * 16) << 16 | m.u32(0xa57848 + p * 16) & 0xffff) & 0xffffffff)
		1: f5b8210(1)
		2:
			f5b9170(m.u32(_JT_B) << 15 | 0x31, mini(m.u32(0xa57850), 0xffff), mini(m.u32(0xa57860), 0xffff), _jt_flags(0xa57854) << 8 | _jt_flags(0xa57844))
		3:
			var player := m.u32(_JT_B) & 1
			if m.u8(0xa57844 + player * 16) & 0x10:
				f5b9170(m.u32(_JT_B) << 15 | 0x3c, _jt_atk(), 0, 0)
			if m.u8(0xa57854 - player * 16) & 0x10:
				f5b9170((m.u32(_JT_B) & 0xfffe) << 14 | 0x3c, _jt_def(), 1, 0)
			return 1
		_: return 1
	_jt_next()
	return 0


func f5a2990(p: int) -> int:
	var a := 0xa57844 + p * 16
	var b := 0xa57854 - p * 16
	var other := _jt_other()
	match m.u8(_JT_STEP):
		0:
			if (m.u32(_JT_B) & 0x40) == 0 and (m.u8(b) >> 6 & 1 ^ other) == 1 - p and m.u32(b + 12) != 0:
				var q := (-p - 1) & 1
				for i in range(m.u8(JoeyMem.pl(q) + 8)):
					var entry := m.u32(JoeyMem.pl(q) + 0x6d4 + i * 4)
					if f4022e0(entry & 0xfff) == 0x39 or f4022e0(entry & 0xfff) == 0x76d:
						var local := m.local(20)
						m.set_u16(local, entry & 0xfff)
						m.set_u16(local + 2, q | 0x356)
						m.set_u16(local + 4, JoeyMem.ident(entry) * 0x20)
						if f57eac0(local, 0) != 0:
							_jt_step(10)
							return 0
		1:
			f579810()
			f578540(m.u8(a) >> 6 & 1 ^ p, m.u32(a + 12), b, a)
			f578540(m.u8(b) >> 6 & 1 ^ other, m.u32(b + 12), a, b)
			f579890()
		2: f59d090()
		10: f5bcf40(other, 0x39)
		11:
			if m.u16(0xa57822) != 0:
				for i in range(m.u8(JoeyMem.pl(other) + 8)):
					var entry := m.u32(JoeyMem.pl(other) + 0x6d4 + i * 4)
					var index := entry & 0xfff
					if f4022e0(index) == 0x39 or f4022e0(index) == 0x76d:
						f5783c0(other, 11, index, JoeyMem.ident(entry))
						m.set_u32(b + 12, 0)
						f5b9170(_jq_op(other, 0xea), 0, 0, 0)
						f575a10(other, i)
						f59d040(other)
						break
			_jt_step(1)
			return 0
		_: return 1
	_jt_next()
	return 0


func f5a1e50(p: int) -> int:
	var other := _jt_other()
	if m.u32(_JT_B) & 0x10:
		return 1
	m.set_u32(_JT_B, m.u32(_JT_B) | 0x10)
	if f56c460(p, _jt_atk()) == 0:
		var n := _s32(f5699a0(other, 0x427))
		if n > 0:
			f5b9170(_jq_op(other, 0x1e), 0x427, 0, 0)
			f578bb0(p, n, 1)
		n = _s32(f5699c0(0x42a))
		if n > 0:
			f5b9170(_jq_op(p, 0x1e), 0x42a, 1, 0)
			f578460(p, n * 500)
	return 1


func f5a0e30() -> int:
	var n := 0
	for z in range(5):
		if f56bd80(m.u32(_JT_B) & 1, _jt_atk(), _jt_other(), z) != 0:
			n += 1
	var count := f569d50(_jt_other())
	m.set_u16(0xa57984, n << 8 | count & 0xff)
	m.set_u16(0xa57986, JoeyMem.ident(m.u32(JoeyMem.zone(m.u32(_JT_B) & 1, _jt_atk()))))
	m.set_u16(0xa57988, JoeyMem.ident(m.u32(JoeyMem.zone(_jt_other(), _jt_def()))))
	return 0


func _jt_cancel() -> int:
	m.set_u32(_JT_B, m.u32(_JT_B) & 0xfffffffb)
	m.set_u16(_JT_STEP, m.u16(_JT_STEP) & 0xff00)
	_jt_turn(1)
	return 1


func _jt_replay() -> int:
	var work := m.u32(_JT_B)
	m.set_u16(_JT_STEP, m.u16(_JT_STEP) & 0xff00)
	m.set_u32(_JT_B, work & 0xfffffffb | 0x80)
	_jt_turn(2)
	f413af0(work >> 8 & 7)
	f579990(m.u32(_JT_B) & 1, _jt_atk(), 0x11, 1)
	return 1


func f5a0f00() -> int:
	var p := m.u32(_JT_B) & 1
	if m.u32(0xa57984) >> 16 != JoeyMem.ident(m.u32(JoeyMem.zone(p, _jt_atk()))):
		return _jt_cancel()
	if f56b730(p, _jt_atk(), 0) == 0:
		f5b9170(m.u32(_JT_B) << 15 | 0x35, _jt_atk(), 1, 0)
		return _jt_cancel()
	var n := 0
	for z in range(5):
		if f56bd80(p, _jt_atk(), _jt_other(), z) != 0:
			n += 1
	var count := f569d50(_jt_other())
	var old := m.u32(0xa57984)
	if (m.u32(_JT_B) & 4) == 0:
		var other := _jt_other()
		var target := _jt_def()
		var entry := m.u32(JoeyMem.zone(other, target))
		if (entry & 0xfff) == 0 or m.u16(0xa57988) != JoeyMem.ident(entry):
			return _jt_replay()
		if f56d740(other, target, 0x422) == 0:
			for z in range(5):
				if z != _jt_def() and (m.u32(JoeyMem.zone(_jt_other(), z)) & 0xfff) != 0 and f56d740(_jt_other(), z, 0x422) != 0:
					return _jt_replay()
	elif _s32(f569d50(_jt_other())) > 0 and f56bf20(m.u32(_JT_B) & 1, _jt_atk()) == 0 and f56bfd0(m.u32(_JT_B) & 1, _jt_atk()) == 0:
		return _jt_replay()
	if n == (old >> 8 & 0xff) and count == (old & 0xff):
		return 0
	return _jt_replay()


func f5a2d60(p: int) -> int:
	if m.u32(_JT_B) & 4:
		return 1
	var a := 0xa57844 + p * 16
	var b := 0xa57854 - p * 16
	var other := _jt_other()
	if f56b440(m.u16(a + 2), m.u16(a) >> 8) == 0:
		var card := f4022e0(m.u16(a + 2)) & 0xffff
		if card == 0x18e or card == 0x188:
			f578390(p, m.u16(a + 2), _jt_atk())
			f5b9170(_jq_op(other, 0x97), _jt_def(), 5, 0)
		elif card == 0xff:
			f5ba490((((m.u32(_JT_B) & 0x700 | p << 23 | 0x282000) << 8) | m.u16(a + 2)) & 0xffffffff, m.u8(a + 1), 0)
		elif card == 0x5f3 and (m.u16(b) & 0x10) != 0 and (m.u32(JoeyMem.zone(p, _jt_atk())) & 0xfff) != 0:
			f578390(p, m.u16(a + 2), _jt_atk())
			f5747e0(p, f402460(0x5f3), (_jt_atk() << 8 | p & 0xff) & 0x7ff, 11)
	if f56b440(m.u16(b + 2), m.u16(b) >> 8) != 0:
		return 1
	var packed := (((m.u32(_JT_B) & 0x3800 | other << 26 | 0x1410000) << 5) | m.u16(b + 2)) & 0xffffffff
	var card := f4022e0(m.u16(b + 2)) & 0xffff
	if card == 0x261:
		if (f56f6d0(p, _jt_atk()) & 0xffff) != 2:
			f578390(other, m.u16(b + 2), _jt_def())
			f5747e0(m.u32(_JT_B) & 1, m.u16(b + 2), m.u32(_JT_B) & 0x701, 0x23)
	elif card == 0xff or card == 0x419:
		f5ba490(packed, m.u8(b + 1), 0)
	elif card == 0x189:
		if (f56f6d0(p, _jt_atk()) & 0xffff) != 7:
			f578390(other, m.u16(b + 2), _jt_def())
			f5b9170(_jq_op(p, 0x97), _jt_atk(), 3, 0)
	elif card == 0x5f3 and (m.u8(a) & 0x10) != 0 and (m.u32(JoeyMem.zone(other, _jt_def())) & 0xfff) != 0:
		f578390(other, m.u16(b + 2), _jt_def())
		f5747e0(other, f402460(0x5f3), (_jt_def() << 8 | other) & 0x7ff, 11)
	if m.u16(_JT_B + 2) != 0 and f567620(m.u16(_JT_B + 2), 1) != 0:
		var ident := m.u8(b + 1)
		var arg := ((m.u8(b) & 0x2e | other) << 8 | ident | 0x4000 | p & 0xc000) & 0xffff
		if f57ee80(packed, ident, arg) != 0:
			f5b9170(_jq_op(other, 0xad), f4022e0(m.u16(_JT_B + 2)), 1, 0)
			f5ba490(packed, m.u8(b + 1), arg)
	return 1


func f5a3a10(p: int) -> int:
	var other := _jt_other()
	if f56db30(other, _jt_def(), 0x4b1) != 0:
		f574900(other, _jt_def(), 0x4b1, 0)
		if m.u8(JoeyMem.zone(other, _jt_def()) + 6) & 1:
			f578390(other, m.u16(0xa57856 - p * 16), _jt_def())
			f575190(other, _jt_def(), 0, 0, 0)
	f5798f0(0, 0)
	m.set_u16(_JT_STEP, m.u16(_JT_STEP) & 0xff00)
	_jt_turn(1)
	return 0


func f5a4010(p: int) -> int:
	for q in range(2):
		for z in range(5, 10):
			if f4022e0(m.u16(JoeyMem.zone(q, z)) & 0xfff) == 0x590:
				f574b50(q, z)
	f579930(p, 0x12, 1)
	return 1


func f5a4090(p: int) -> int:
	var target := m.u32(0x5efa68 + (m.u16(JoeyMem.TURN) >> 8) * 4)
	if target == 0:
		return 1
	# 5a22c0 no lee el argumento sobrante que la tabla cdecl le pasa por pila.
	var result := f5a22c0() if target == 0x5a22c0 else int(callv("f%06x" % target, [p]))
	if result != 0:
		m.set_u16(_JT_STEP, m.u16(_JT_STEP) & 0xff00)
		m.set_u16(JoeyMem.TURN, ((m.u16(JoeyMem.TURN) & 0xff00) + 0x100) ^ m.u16(JoeyMem.TURN) & 0xff)
	return 0


func f5a3af0(p: int) -> int:
	var phase := m.u8(_JT_STEP)
	match phase:
		0: f598590(m.u8(JoeyMem.TURN) & 1, 0x16, 0)
		1:
			for order in range(2):
				var q := (m.u8(JoeyMem.TURN) & 1) ^ order
				for z in range(5):
					var a := JoeyMem.zone(q, z)
					var entry := m.u16(a)
					if f569790(q, z, 0x540) != 0 and (m.u16(a + 6) & 0x201) == 0:
						f578390(q, entry & 0xfff, z)
						f575190(q, z, 0, 0, 0)
						f574900(q, z, 0x540, 1)
						f5747e0(q, entry & 0xfff, z << 8 | q & 0xff, 0x2c)
		2:
			for order in range(2):
				var q := (m.u8(JoeyMem.TURN) & 1) ^ order
				for z in range(5):
					if f56db30(q, z, 0x49e) != 0:
						f578400(q, f402460(0x49e))
						f577840(q, z, 1, f402460(0x49e) & 0xffff)
		3:
			for q in range(2):
				for z in range(5):
					var a := JoeyMem.zone(q, z)
					var entry := m.u16(a)
					if f4022e0(entry & 0xfff) == 0x52f and (m.u8(a + 6) & 2) != 0:
						var link := _s32(f56da10(q, z, 0x52f))
						if link >= 0:
							var ref := m.u16(a + 0x4c + link * 2)
							var ident := ref >> 8
							var owner := ref >> 4 & 15
							var free := _s32(f56a400(owner))
							var card := f5687d0(ident)
							if free >= 0 and (card >> 8 & 0xff) == 14:
								f578390(q, entry & 0xfff, z)
								f576110(card & 0xff, 14, ident, owner, free, 1, 0)
								f5749b0(owner, (free & 0xff) << 8 | owner & 0xff, z << 8 | q, 4)
								f574900(q, z, 0x52f, 0)
								return 0
		4:
			for q in range(2):
				if f5709d0(q, 0x53c) != 0:
					var card := f402460(0x53c)
					if f5ba490(card & 0xffff | q << 31 | 0x5f0000, 0, 0) != 0:
						return 0
					f5797c0(q, 0x53c, 0)
					return 0
		5:
			for order in range(2):
				var q := (m.u8(JoeyMem.TURN) & 1) ^ order
				for z in range(5):
					if m.u32(JoeyMem.zone(q, z)) & 0xfff:
						f574900(q, z, 0x3de, 1)
		6:
			var mask := 0
			for order in range(2):
				var q := (m.u8(JoeyMem.TURN) & 1) ^ order
				for z in range(5):
					if (m.u32(JoeyMem.zone(q, z)) & 0xfff) != 0 and f56db30(q, z, 0x3b1) != 0:
						mask |= 1 << ((q << 4) + z & 31)
			f5777f0(1 - p, 0, mask)
		_:
			f5797c0(p, 0x602, 1)
			if f5709d0(p, 0x246) != 0:
				f5797c0(p, 0x246, 1)
				m.set_u16(JoeyMem.TURN, m.u16(JoeyMem.TURN) & 0xff)
				_jt_step(0)
				return 0
			return 1
	_jt_next()
	return 0


func f5a31a0(p: int) -> int:
	var a := 0xa57844 + p * 16
	var b := 0xa57854 - p * 16
	var fa := m.u16(a)
	var fb := m.u16(b)
	var other := _jt_other()
	var za := fa >> 1 & 7
	var zb := fb >> 1 & 7
	var src := JoeyMem.zone(p, za) if (fa & 0x10) == 0 else 0xa57864
	var dst := JoeyMem.zone(other, zb) if (fb & 0x10) == 0 else 0xa578f4
	var dead_a := (fa & 0x10) != 0 and (m.u32(0xa57864) & 0xfff) != 0
	var dead_b := (fb & 0x10) != 0 and (m.u32(0xa578f4) & 0xfff) != 0
	var valid_a := JoeyMem.ident(m.u32(JoeyMem.zone(p, za))) == fa >> 8
	var valid_b := JoeyMem.ident(m.u32(JoeyMem.zone(other, zb))) == fb >> 8
	if m.u32(_JT_B) & 4:
		return 1
	match m.u8(_JT_STEP):
		0:
			if dead_a:
				if f56b440(m.u16(a + 2), fa >> 8) == 0:
					var card := f4022e0(m.u16(a + 2)) & 0xffff
					if card > 0x4e5 and card < 0x4e9 and valid_b:
						f578390(p, m.u16(a + 2), _jt_atk())
						f5747e0(p, m.u16(a + 2), (_jt_def() << 8 | other) & 0x7ff, 11)
				if f56b440(m.u16(b + 2), m.u16(b) >> 8) == 0:
					var card := f4022e0(m.u16(b + 2)) & 0xffff
					if card == 0x2f9 and valid_b:
						f5747e0(other, m.u16(b + 2), (_jt_def() << 8 | other) & 0x7ff, 3)
					elif card == 0x52f and valid_b and f402690(m.u16(a + 2)) != 0:
						f5747e0(other, f402460(0x52f), (_jt_def() << 8 | other) & 0x7ff, m.u8(a + 1) << 8 | (other << 4) | 11)
					elif card == 0x53c:
						f579790(other, f402460(0x53c), (JoeyMem.ident(m.u32(src)) & 0xff) << 8 | 3)
			if dead_b:
				if f56b440(m.u16(b + 2), m.u16(b) >> 8) == 0:
					var card := f4022e0(m.u16(b + 2)) & 0xffff
					if card > 0x4e5 and card < 0x4e9 and valid_a:
						f578390(other, m.u16(b + 2), _jt_def())
						f5747e0(other, m.u16(b + 2), (_jt_atk() << 8 | p & 0xff) & 0x7ff, 11)
				if f56b440(m.u16(a + 2), m.u16(a) >> 8) == 0:
					var card := f4022e0(m.u16(a + 2)) & 0xffff
					if card == 0x2f9 and valid_a:
						f5747e0(p, m.u16(a + 2), (_jt_atk() << 8 | p & 0xff) & 0x7ff, 3)
					elif card == 0x52f and valid_a and f402690(m.u16(b + 2)) != 0:
						var arg := m.u8(b + 1) << 8 | (p << 4) | 11
						f5747e0(p, f402460(0x52f), (_jt_atk() << 8 | p & 0xff) & 0x7ff, arg)
					elif card == 0x53c:
						f579790(p, f402460(0x53c), (JoeyMem.ident(m.u32(dst)) & 0xff) << 8 | 3)
		1:
			f579810()
			fa = m.u16(a)
			if fa & 0x10:
				var card := f4022e0(m.u16(a + 2)) & 0xffff
				var kind := 15 if (card >= 0x780 and card <= 0x783) or _s32(f5699c0(0x453)) > 0 else 14
				f577cf0(p & 1, fa >> 1 & 7, src, int(p != other), (kind << 18 | (other << 9 | fa & 0x2e | p & 1 | 0x1c0) << 8 | fa >> 8) & 0xffffffff)
			fb = m.u16(b)
			if fb & 0x10:
				var card := f4022e0(m.u16(b + 2)) & 0xffff
				var kind := 15 if (card >= 0x780 and card <= 0x783) or _s32(f5699c0(0x453)) > 0 else 14
				f577cf0(other, fb >> 1 & 7, dst, int(p != other), (kind << 18 | (fb & 0x2e | (p & 1) << 9 | other | 0x1c0) << 8 | fb >> 8) & 0xffffffff)
			if f56db30(p, _jt_atk(), 0x2da) != 0 and (f56d560(p, _jt_atk()) & 0xffff) != 0xffff:
				f574eb0(p, _jt_atk())
			if f56db30(other, _jt_def(), 0x2da) != 0 and (f56d560(other, _jt_def()) & 0xffff) != 0xffff:
				f574eb0(other, _jt_def())
			if f56db30(other, _jt_def(), 0x5ff) != 0 and valid_a:
				f578400(other, f402460(0x5ff))
				f577840(p, _jt_atk(), 1, f402460(0x5ff) & 0xffff)
			if f56db30(other, _jt_def(), 0x199) != 0 and valid_b:
				f578390(p, m.u16(a + 2), _jt_atk())
				f577840(other, _jt_def(), 1, m.u16(a + 2))
			f579890()
		_: return 1
	_jt_next()
	return 0


func _jt_half_n(value: int, n: int) -> int:
	while _s32(n) > 0:
		value = f5be050(value)
		n -= 1
	return _s32(value)


func f5b7c50(announce: int) -> int:
	var attacker := m.u32(_JT_B) & 1
	var defender := _jt_other()
	var stats := m.local(24)
	for q in range(2):
		var p := attacker if q == attacker else defender
		var z := _jt_atk() if q == attacker else _jt_def()
		var a := 0xa57844 + q * 16
		var zone := JoeyMem.zone(p, z)
		var entry := m.u32(zone)
		m.set_u16(a, (((m.u8(zone + 6) & 1) << 4 | z) << 1 | p) ^ JoeyMem.ident(entry) * 0x100)
		m.set_u16(a + 2, m.u16(zone) & 0xfff)
		m.set_u32(a + 4, 0)
		m.set_u32(a + 8, 0)
		m.set_u32(a + 12, 0)
		f56dd30(p, z, stats + q * 12)
	var a := 0xa57844 + attacker * 16
	var b := 0xa57854 - attacker * 16
	if m.u32(_JT_B) & 4:
		m.set_u16(b + 2, 0)
		m.set_u32(b + 4, 0)
		m.set_u32(b + 8, 0)
	else:
		if f56b440(m.u16(a + 2), m.u16(a) >> 8) == 0:
			var halves := f56d740(attacker, _jt_atk(), 1099)
			var card := f4022e0(m.u16(a + 2)) & 0xffff
			if card == 0x1dd and (f56f9e0(defender, _jt_def()) & 0xffff) == 6:
				var value := _jt_half_n(-1000 if m.u32(0xa577ec) & 0x100000 else 1000, halves)
				m.set_u32(stats + attacker * 12 + 4, m.u32(stats + attacker * 12 + 4) + value)
				if announce != 0:
					f578390(attacker, m.u16(a + 2), _jt_atk())
			elif card == 0x4e5 and (f56f6d0(defender, _jt_def()) & 0xffff) == 15:
				var value := _jt_half_n(-2000 if m.u32(0xa577ec) & 0x100000 else 2000, halves)
				m.set_u32(stats + attacker * 12 + 4, m.u32(stats + attacker * 12 + 4) + value)
				m.set_u32(stats + attacker * 12 + 8, m.u32(stats + attacker * 12 + 8) + value)
				if announce != 0:
					f578390(attacker, m.u16(a + 2), _jt_atk())
		if f56b440(m.u16(b + 2), m.u16(b) >> 8) == 0:
			var halves := f56d740(defender, _jt_def(), 1099)
			var card := f4022e0(m.u16(b + 2)) & 0xffff
			if card == 0x11f and (f56f9e0(attacker, _jt_atk()) & 0xffff) == 1:
				m.set_u32(stats + defender * 12 + 8, f5be050(m.u32(stats + defender * 12 + 8)))
				if announce != 0:
					f578390(defender, m.u16(b + 2), _jt_def())
			elif card == 0x4e5 and (f56f6d0(attacker, _jt_atk()) & 0xffff) == 15:
				var value := _jt_half_n(-2000 if m.u32(0xa577ec) & 0x100000 else 2000, halves)
				m.set_u32(stats + defender * 12 + 4, m.u32(stats + defender * 12 + 4) + value)
				m.set_u32(stats + defender * 12 + 8, m.u32(stats + defender * 12 + 8) + value)
				if announce != 0:
					f578390(defender, m.u16(b + 2), _jt_def())
		var halves := f56d740(attacker, _jt_atk(), 1099)
		var equips := f56d790(attacker, _jt_atk(), 0x291)
		var value := _jt_half_n((equips * f5be050(m.u32(stats + defender * 12 + 4))) & 0xffffffff, halves)
		m.set_u32(stats + attacker * 12 + 4, m.u32(stats + attacker * 12 + 4) + value)
		if announce != 0:
			var i := 0
			while i < m.u16(JoeyMem.zone(attacker, _jt_atk()) + 10):
				var zone := JoeyMem.zone(attacker, _jt_atk())
				var ref := m.u16(zone + 12 + i * 2)
				if (m.u16(zone + 0x4c + i * 2) & 15) == 1 and f569790(ref & 0xff, ref >> 8, 0x291) != 0:
					f578390(ref & 0xff, m.u16(JoeyMem.zone(ref & 0xff, ref >> 8)) & 0xfff, ref >> 8)
				i += 1
	for q in range(2):
		m.set_u32(0xa57848 + q * 16, maxi(_s32(m.u32(stats + q * 12 + 4)), 0))
		m.set_u32(0xa5784c + q * 16, maxi(_s32(m.u32(stats + q * 12 + 8)), 0))
	return 0


func _jt_survive(a: int, p: int, z: int, opponent: int, opposite_record: int, announce: int, attacking: bool) -> void:
	var card := f4022e0(m.u16(a + 2)) & 0xffff
	if card == 0x4cf:
		if (m.u8(JoeyMem.TURN) & 1) == p and (m.u8(JoeyMem.TURN) & 14) == 6:
			m.set_u16(a, m.u16(a) & 0xffef)
			if (m.u8(a) & 0xc0) == 0:
				m.set_u32(a + 12, 0)
			if attacking and announce != 0:
				f578390(p, m.u16(a + 2), _jt_atk())
				f5747e0(p, m.u16(a + 2), (_jt_def() << 8 | opponent) & 0x7ff, 12)
	elif attacking and card == 0x199:
		if (f56f9e0(opponent, _jt_def()) & 0xffff) == 2 and announce != 0:
			f5747e0(opponent, m.u16(a + 2), _jt_def() << 8 | opponent, 3)
	elif card == 0x4e3:
		if m.u32(opposite_record + 4) > 0x76b:
			m.set_u16(a, m.u16(a) & 0xffef)
	elif card == 0x2da or card == 0x536:
		if (m.u16(a) & 0x10) != 0 and (f56d560(p, z) & 0xffff) != 0xffff:
			m.set_u16(a, m.u16(a) & 0xffef)
			if announce != 0:
				f5747e0(p, f402460(0x2da), (z << 8 | p) & 0x7ff, 3)


func f5b8210(announce: int) -> int:
	var attacker := m.u32(_JT_B) & 1
	var defender := _jt_other()
	var a := 0xa57844 + attacker * 16
	var b := 0xa57854 - attacker * 16
	var blocked_a := f56b440(m.u16(a + 2), m.u16(a) >> 8)
	var blocked_b := 0
	if (m.u32(_JT_B) & 4) == 0:
		blocked_b = f56b440(m.u16(b + 2), m.u16(b) >> 8)
	if m.u32(_JT_B) & 0x20:
		m.set_u32(a + 4, 0)
	for record in [0xa57844, 0xa57854]:
		m.set_u16(record, m.u16(record) & 0xff2f)
		m.set_u32(record + 12, 0)
	var attack := _s32(m.u32(a + 4))
	if (m.u32(_JT_B) & 4) == 0:
		var in_defense := (m.u16(b) & 0x20) != 0
		var defense := _s32(m.u32(b + 8 if in_defense else b + 4))
		if attack == defense:
			if not in_defense and attack > 0:
				m.set_u16(a, m.u16(a) | 0x10)
				m.set_u16(b, m.u16(b) | 0x10)
		elif defense < attack:
			var damage := attack - defense
			if not in_defense:
				m.set_u8(b, m.u8(b) | 0x10)
				m.set_u32(b + 12, damage)
			else:
				if (blocked_a == 0 and f4022e0(m.u16(a + 2)) == 0x53d) or f56d8d0(attacker, _jt_atk(), 0x521, attacker) != 0 or f56d8d0(attacker, _jt_atk(), 0x604, attacker) != 0:
					m.set_u32(b + 12, damage)
					m.set_u16(b, int(attacker == defender) << 6 | m.u16(b) & 0xffbf)
				if f56d8d0(attacker, _jt_atk(), 0x521, 1 - attacker) != 0 or f56d8d0(attacker, _jt_atk(), 0x604, 1 - attacker) != 0:
					m.set_u8(a, m.u8(a) | 0x80)
					m.set_u32(a + 12, damage)
				m.set_u8(b, m.u8(b) | 0x10)
		else:
			m.set_u32(a + 12, defense - attack)
			if not in_defense:
				m.set_u16(a, m.u16(a) | 0x10)
	else:
		m.set_u32(b + 12, attack)
	m.set_u32(a + 12, mini(m.u32(a + 12), 0xffff))
	m.set_u32(b + 12, mini(m.u32(b + 12), 0xffff))
	if attacker != defender:
		if m.u32(0xa56430 + defender * 0xd44) & 0x400000:
			m.set_u16(b, m.u16(b) & 0xffef)
			m.set_u32(b + 12, 0)
		if m.u32(0xa56430 + attacker * 0xd44) & 0x400000:
			m.set_u16(a, m.u16(a) & 0xffef)
			m.set_u32(a + 12, 0)
	if f56b220(0x14d) != 0:
		if m.u32(b + 12) != 0 and _s32(f5699a0(m.u8(b) >> 6 & 1 ^ defender, 0x58f)) > 0:
			m.set_u32(b + 12, 0)
		if m.u32(a + 12) != 0 and _s32(f5699a0(m.u8(a) >> 6 & 1 ^ attacker, 0x58f)) > 0:
			m.set_u32(a + 12, 0)
	if m.u32(_JT_B) & 4:
		return 0
	if blocked_a == 0:
		_jt_survive(a, attacker, _jt_atk(), defender, b, announce, true)
	if blocked_b == 0:
		_jt_survive(b, defender, _jt_def(), attacker, a, announce, false)
	if announce != 0:
		if f56d790(attacker, _jt_atk(), 0x49e) != 0 and (f56f6d0(defender, _jt_def()) & 0xffff) == 1:
			f5747e0(defender, f402460(0x49e), (_jt_def() << 8 | defender) & 0x7ff, 3)
		if f56d790(defender, _jt_def(), 0x49e) != 0 and (f56f6d0(attacker, _jt_atk()) & 0xffff) == 1:
			f5747e0(attacker, f402460(0x49e), (_jt_atk() << 8 | attacker) & 0x7ff, 3)
	return 0
