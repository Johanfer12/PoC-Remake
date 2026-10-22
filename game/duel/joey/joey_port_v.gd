class_name JoeyPortV
extends JoeyPortU
## Peticiones interactivas del motor Joey; subfase de nueve bits en a57810.
## 5a9bbd es el cuerpo interno del case 1 de 5a9b50, no una entrada independiente.

func _jv_next() -> void:
	m.set_u16(0xa57810, m.u16(0xa57810) + 0x200)

func _jv_back() -> void:
	m.set_u16(0xa57810, m.u16(0xa57810) - 0x200)

func _jv_ai(p: int) -> bool:
	return ((m.u32(JoeyMem.MODE) >> 1) >> (p & 31)) & 1 != 0

func _jv_count() -> void:
	m.set_u8(0xa55d3c, m.u8(0xa55d3c) - 1)

func f5a40f0(p: int, announce: int) -> int:
	match m.u16(0xa57810) >> 9:
		0:
			m.set_u8(0xa577fb, 6)
			m.set_u16(0xa577fc, (m.u16(0xa577fc) & 0xff00) | 1)
			f5798f0(0, 1)
			var battle := m.u32(0xa57840)
			if announce != 0:
				f5b9170((battle << 15) | 0x35, (battle >> 8) & 7, 1, 0)
			m.set_u32(0xa57840, m.u32(0xa57840) | 0x40)
			_jv_next()
		1:
			f5a4090(p)
			return int(m.u16(0xa577fa) & 0xff00 == 0x900)
	return 0

func f5a90e0(p: int, count: int, kind: int, arg: int) -> int:
	if m.u8(JoeyMem.pl(p) + 8) == 0:
		return 1
	match m.u16(0xa57810) >> 9:
		0: m.set_u8(0xa55d3c, count)
		1:
			if not _jv_ai(p):
				f5bdbd0(p, 0xb, 0)
				f5bf800(0xeb)
				f5bf9a0(8, 0)
			elif m.u8(0xa55d3c) != 0:
				f575970(p, f5af450(p, kind, 0, 0), arg)
				_jv_count()
				return 0
		_: return 1
	_jv_next()
	return 0

func f5a91f0(p: int, count: int, a: int, b: int, c: int) -> int:
	match m.u16(0xa57810) >> 9:
		0: m.set_u8(0xa55d3c, count)
		1:
			if not _jv_ai(p):
				f5bdbd0(p, 0xb, 0)
				f5bf800(0xeb)
				f5bf9a0(8, 0)
			elif m.u8(0xa55d3c) != 0:
				f575a10(p, f5af450(p, a, b, c))
				_jv_count()
				return 0
		_: return 1
	_jv_next()
	return 0

func f5a92d0(p: int, arg: int, count: int) -> int:
	var n := m.u8(JoeyMem.pl(p) + 8)
	if n == 0:
		return 1
	if m.u16(0xa57810) & 0xfe00 == 0:
		m.set_u8(0xa55d3c, count)
		_jv_next()
		return 0
	if m.u8(0xa55d3c) != 0:
		var z := f5bddb0(n)
		f5b9170(_jq_op(p, 0x21), 0, 0, 0)
		f5b9170(_jq_op(p, 8), p, ((z & 0xff) << 8) | 0xb, 0)
		f575970(p, z, arg)
		_jv_count()
		return 0
	return 1

func f5a93c0(p: int, arg: int, count: int) -> int:
	var n := m.u8(JoeyMem.pl(p) + 8)
	if n == 0:
		return 1
	if m.u16(0xa57810) & 0xfe00 == 0:
		m.set_u8(0xa55d3c, count + int(count == 0))
		_jv_next()
		return 0
	if m.u8(0xa55d3c) != 0:
		var z := f5bddb0(n)
		f5b9170(_jq_op(p, 0x21), 0, 0, 0)
		f5b9170(_jq_op(p, 8), p, ((z & 0xff) << 8) | 0xb, 0)
		if count != 0:
			f575a80(p, 0xa56434 + z * 4 + (p & 1) * 0xd44, int(arg != 0))
			_jv_count()
			return 0
		m.set_u16(0xa57822, z)
	return 1

func f5a9500(p: int, excluded: int, count: int) -> int:
	match m.u16(0xa57810) >> 9:
		0:
			if f56a290(p, excluded) == 0:
				return 1
			m.set_u8(0xa55d3c, count)
		1:
			if not _jv_ai(p):
				f5bf800(0xec)
		2:
			if not _jv_ai(p):
				f5929d0()
				if f5aa440(0xf000f0) != 0:
					var owner := m.u32(0xa55044)
					var z := m.u32(0xa5504c) + m.u32(0xa55048)
					if f56a140(p, owner, z) != 0:
						var ref := ((z & 0xff) << 8) | (owner & 0xff)
						if ref != excluded and f5aa480() != 0:
							m.set_u16(0xa57822, ref)
							_jv_next()
				if m.u32(0xa54e54) & 0x102:
					_jv_back()
				return 0
			m.set_u16(0xa57822, f5aed60(p, excluded, 0))
		3:
			if count != 0:
				f577b30(m.u8(0xa57822), m.u8(0xa57823))
			if m.u8(0xa55d3c) < 2:
				return 1
			_jv_count()
			_jv_back()
			return 0
		_: return 0
	_jv_next()
	return 0

func _jv_list_result(mask: int = 0xffff) -> int:
	var at := f40cab0()
	m.set_u16(0xa57822, m.u16(at) & mask)
	return at

func f5a9750(p: int, index: int, arg: int) -> int:
	var step := m.u16(0xa57810) >> 9
	if step > 1 or (step == 0 and _jv_ai(p)):
		if step == 0:
			f5af5a0(p, index, arg)
		var at := _jv_list_result()
		m.set_u16(0xa57824, m.u16(at + 2))
		return 1
	if step == 1:
		f40c940(p, 6, f4022e0(index), arg & 0xffff)
	else:
		var card := s16(f4022e0(index))
		if card != 0x45c and card != 0x487 and card != 0x5f0:
			return 1
		f5bf800(0xef if card == 0x487 else 0xf0)
	_jv_next()
	return 0

func f5a9870(p: int, index: int) -> int:
	if m.u16(0xa57810) & 0xfe00:
		m.set_u16(0xa57822, m.u16(0xa558b4))
		return 1
	if not _jv_ai(p):
		f5bf800(0xf1)
		f5bf9a0(4, 0)
	else:
		var result := 0
		var card := s16(f4022e0(index))
		if card == 0x479:
			if f5b0540(p, 0x548) != 0:
				result = 10
			if f5b0540(p, 0x4e5) != 0:
				result = 15
			m.set_u16(0xa558b4, result - 1)
		elif card == 0x47a:
			var z := _s32(f5b0090(p, 1 - p, 0xffffffff, 1, 0))
			if z >= 0:
				result = s16(f4025d0(m.u16(JoeyMem.zone(1 - p, z)) & 0xfff))
			m.set_u16(0xa558b4, result - 1)
	_jv_next()
	return 0

func f5a99c0(p: int, options: int) -> int:
	if not _jv_ai(p):
		if m.u16(0xa57810) & 0xfe00 == 0:
			f5bf800(0xf2)
			f5bf9a0(5, options)
			_jv_next()
			return 0
		m.set_u16(0xa57822, m.u16(0xa558b4))
		return 1
	var available := (options >> 8) & 0xff
	var count := options & 0xff
	var z := -1
	m.set_u16(0xa558b4, 0)
	for _i in range(2):
		z = _s32(f5b0090(p, 1 - p, z, 1, 0))
		if z >= 0:
			var attr := f402650(m.u16(JoeyMem.zone(1 - p, z)) & 0xfff) & 0xffff
			if attr > 0 and attr < 7:
				var bit := 1 << ((attr - 1) & 31)
				if available & bit and count != 0:
					m.set_u16(0xa558b4, m.u16(0xa558b4) | bit)
					available ^= bit
					count -= 1
	while count > 0:
		var start := _s32(f5bddb0(6))
		for i in range(6):
			var bit := 1 << (((start + i) % 6) & 31)
			if available & bit:
				m.set_u16(0xa558b4, m.u16(0xa558b4) | bit)
				available ^= bit
				break
		count -= 1
	m.set_u16(0xa57822, m.u16(0xa558b4))
	return 1

func f5a9b50(p: int) -> int:
	match m.u16(0xa57810) >> 9:
		0:
			if not _jv_ai(p):
				f5bf800(0xf4)
			_jv_next()
		1:
			f579930(1 - p, 3, 1)
			f579930(1 - p, 4, 1)
			f5929d0()
			if _jv_ai(p):
				m.set_u16(0xa57822, f5b04f0(p))
				_jv_next()
			elif f5aa440(0x10000) == 0:
				if m.u32(0xa54e54) & 0x102:
					_jv_back()
			elif f5aa480() != 0:
				f44ef40(1)
				m.set_u16(0xa57822, m.u16(0xa5504c))
				_jv_next()
		2:
			f5b9170(_jq_op(p, 8), 1 - p, (m.u8(0xa57822) << 8) | 0xb, 0)
			_jv_next()
		3:
			f579930(1 - p, 3, f56d3f0(p))
			return 1
		_: return 1
	return 0

func f5a9d20(p: int, index: int) -> int:
	var step := m.u16(0xa57810) >> 9
	if step == 0:
		if not _jv_ai(p):
			var card := s16(f4022e0(index))
			if card == 0x435 or card == 0x446:
				f5bf800(0x1f if card == 0x435 else 0x2e)
		_jv_next()
		m.set_u16(0xa57822, 0)
		return 0
	if step != 1:
		return 1
	var z: int
	if not _jv_ai(p):
		f5929d0()
		if m.u32(0xa54e54) & 0x102:
			_jv_back()
			return 0
		if f5aa440(1) == 0:
			return 0
		z = m.u16(0xa5504c)
	else:
		z = f5bddb0(m.u8(JoeyMem.pl(p) + 8)) & 0xffff
	var chosen := m.u32(0xa56434 + z * 4 + (p & 1) * 0xd44) & 0xfff
	m.set_u16(0xa57822, z)
	var card := s16(f4022e0(index))
	if card != 0x435:
		if card == 0x446:
			if f402690(chosen) != 0 or f5685c0(chosen) != 0:
				return 0
		elif card == 0x47d:
			if f402690(chosen) == 0 or f4026c0(chosen) & 0xffff > 4 or f567a00(chosen) != 0:
				return 0
		else:
			return 0
	if not _jv_ai(p) and f5aa480() == 0:
		return 0
	f5b9170(_jq_op(p, 8), p, (m.u8(0xa57822) << 8) | 0xb, 0)
	return 1

func f5a9f50(p: int) -> int:
	if _jv_ai(p) or m.u8(JoeyMem.pl(1 - p) + 9) == 0:
		return 1
	match m.u16(0xa57810) >> 9:
		0: f5bf800(0xf9)
		1: f40c940(1 - p, 2, 0xffffffff, 0xd)
		_: return 1
	_jv_next()
	return 0

func f5aa020(p: int, index: int) -> int:
	if _jv_ai(p):
		var card := s16(f4022e0(index))
		if card == 0x439 or card == 0x586:
			var z := f5bddb0(5 if card == 0x439 else 3)
			m.set_u16(0xa57822, m.u16(0xa57814 + z * 2))
		return 1
	match m.u16(0xa57810) >> 9:
		0: f5bf800(0xf6)
		1:
			var card := s16(f4022e0(index))
			if card == 0x439 or card == 0x586:
				f40c940(p, 6 if card == 0x439 else 0x29, f4022e0(index), int(card == 0x439))
		_:
			_jv_list_result(0xfff)
			return 1
	_jv_next()
	return 0

func f5bc7d0(p: int, index: int, arg: int) -> int:
	match m.u16(0xa57810) >> 9:
		0:
			if _jv_ai(p):
				m.set_u16(0xa57822, int(index & 0xffff in [0x39, 0x529, 0x5f0]))
				return 1
		1:
			var text := m.local(256)
			var confirm := true
			match index & 0xffff:
				0x48a:
					f5bdf40(text, 0x106, f402290(arg))
					confirm = false
				0x47d:
					f5bde30(text, 0xed)
					confirm = false
				0x529: f5bde30(text, 0xb)
				_:
					var id := index & 0xffff
					f5bdf40(text, 0xe3 if id == 0x39 else (0xe if id == 0x5f0 else 0xfa), f402290(f402460(index)))
			f5bf800(text)
			if confirm:
				f5bf9a0(1, 0)
		_:
			m.set_u16(0xa57822, m.u16(0xa558b4))
			return 1
	_jv_next()
	return 0

func f5bc9b0() -> int:
	var request := m.u32(0xa57810)
	if request & 2 == 0:
		return 0
	var p := (request >> 2) & 1
	var done := 0
	if request & 1 == 0 or ((~m.u32(JoeyMem.MODE)) & 1) != p:
		var arg := request >> 16
		var extra := m.u32(0xa57814)
		match (request >> 3) & 0x3f:
			1: done = f5a90e0(p, arg, extra & 1, extra & 2)
			2: done = f5a91f0(p, arg, extra & 1, extra & 4, extra & 8)
			3: done = f5a92d0(p, arg, extra & 0xffff)
			4: done = f5a93c0(p, arg, extra & 0xffff)
			5: done = f5a9b50(p)
			6: done = f5a9d20(p, arg)
			7: done = f5a9f50(p)
			8: done = f5a9500(p, arg, extra & 0xffff)
			9: done = f5a9870(p, arg)
			10: done = f5a99c0(p, arg)
			11: done = f5aa020(p, arg)
			12: done = f5a9750(p, arg, extra & 0xffff)
			13: done = f5bc7d0(p, arg, extra & 0xffff)
			14: done = f5a40f0(p, arg)
			_: return 0
	else:
		done = (m.u32(0xa58260) >> 14) & 1
	if done != 0:
		if m.u32(0xa57810) & 1 and p == m.u32(JoeyMem.MODE) & 1:
			f5bd090(0xf0a2, 0xa57822, 0x10)
		m.set_u32(0xa57810, m.u32(0xa57810) & 0xfffffffd)
	return 1
