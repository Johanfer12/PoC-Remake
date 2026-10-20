class_name JoeyPortZ
extends JoeyPortY
## Etapa 4: mantenimiento especial de las tablas de fases de Joey.
## Fuentes: re/out/joey/funcs, funciones con la direccion de cada metodo.


func _jz_pos() -> int:
	return m.u32(_JS_WORK) >> 8 & 0x7f


func _jz_shift(delta: int) -> void:
	var w := m.u32(_JS_WORK)
	m.set_u32(_JS_WORK, w ^ (((w & 0xff00) + delta ^ w) & 0x7f00))


func _jz_prompt(index: int, message: int = 0xfa, size: int = 256) -> void:
	var buffer := m.local(size)
	f5bdf40(buffer, message, f402290(index))
	f5bf800(buffer)
	f5bf9a0(1, 0)


func f5a4c00(p: int) -> int:
	if f5709d0(p, 0x58d) != 0:
		f5ba490(f402460(0x58d) & 0xffff | p << 31 | 0x84e0000, 0, 0)
		f5797c0(p, 0x58d, 0)
		return 0
	return 1


func f5a4f00(p: int) -> int:
	var pos := _jz_pos()
	var count := _s32(m.u32(0x5efa64))
	if count <= pos:
		var card := m.u16(0x5efa44 + (pos - count) * 6)
		if m.u16(0xa558b4) == 0:
			f5797c0(p, card, 0)
			_jz_shift(0x100)
		else:
			f5ba490(f402460(card) & 0xffff | p << 31 | 0x85f0000, 0, 0)
		_jz_shift(-(count << 8))
		return int(count <= _jz_pos())
	while true:
		var index := f402460(m.u16(0x5efa44 + pos * 6)) & 0xffff
		if f57ee80(index | p << 31 | 0x85f0000, 0, 0) != 0:
			if _jt_ai(p) or m.s16(0x5efa48 + pos * 6) == 0:
				m.set_u16(0xa558b4, 1)
			else:
				_jz_prompt(index)
			_jz_shift(count << 8)
			return 0
		_jz_shift(0x100)
		pos = _jz_pos()
		if pos >= count:
			return 1
	return 1


func f5a4560(p: int) -> int:
	if _jz_pos() == 0 and f5699c0(0x52a) != 0:
		var mask := 0
		for q in range(2):
			for z in range(5):
				var a := JoeyMem.zone(q, z)
				var entry := m.u16(a) & 0xfff
				if entry != 0 and (m.u8(a + 6) & 2) != 0 and (f4026c0(entry) & 0xffff) < 4 and (m.u32(a + 0x8c) & 0x10000) != 0:
					mask |= 1 << ((q << 4) + z & 31)
		if mask != 0:
			var owner := 1 - p if f5699a0(1 - p, 0x52a) != 0 else p
			f5b9170(_jq_op(owner, 0x1e), 0x52a, 1, 0)
			f5777f0(owner, f402460(0x52a) & 0xffff, mask)
			_jz_shift(0x100)
			return 0
	return 1


func f5a4e00(p: int) -> int:
	while _jz_pos() < 2:
		var q := _jz_pos() ^ p
		var link := _s32(f56da10(q, 11, 0x5ea))
		if link >= 0:
			var ident := m.u8(0xa563f1 + link * 2 + (q & 1) * 0xd44)
			if (f5687d0(ident) >> 8 & 0xff) == 14:
				f5ba490(f402460(0x5ea) & 0xffff | q << 31 | 0x84e0000, ident, 0)
			f5797c0(q, 0x5ea, 0)
			return 0
		_jz_shift(0x100)
	return 1


func f5a4c60(p: int) -> int:
	while _jz_pos() < 2:
		var q := _jz_pos() ^ p
		if f5709d0(q, 0x443) != 0:
			for i in range(m.u8(JoeyMem.pl(q) + 8) - 1, -1, -1):
				var entry := m.u32(JoeyMem.pl(q) + 0x6d4 + i * 4)
				if f570c70(q, JoeyMem.ident(entry)) != 0:
					f578400(q, f402460(0x443))
					f575970(q, i, 0)
			for z in range(5, 11):
				var a := JoeyMem.zone(q, z)
				var entry := m.u32(a)
				if (entry & 0xfff) != 0 and (m.u8(a + 6) & 2) == 0 and f570c70(q, JoeyMem.ident(entry)) != 0:
					f578400(q, f402460(0x443))
					f577bf0(q, z, 0, f402460(0x443) & 0xffff)
			_jz_shift(0x100)
			return 0
		_jz_shift(0x100)
	return 1


func f5a5ea0(p: int) -> int:
	if f5709d0(p, 0x527) != 0:
		var i := 0
		var q := p & 1
		while i < m.u16(0xa563ae + q * 0xd44):
			var a := 0xa563f0 + q * 0xd44 + i * 2
			if (m.u8(a) & 15) == 3 and f4022e0(m.u16(a - 0x40)) == 0x527:
				var ident := m.u8(a + 1)
				var ref := f5687d0(ident)
				if (ref >> 8 & 0xff) == 15 and m.u8(0xa569e8 + (ref >> 16) * 2 + (ref & 1) * 0xd44) == 0x40:
					var flags := m.u8(0xa569e9 + (ref >> 16) * 2 + (ref & 1) * 0xd44)
					q = flags
					var z := flags >> 4
					f578400(p, f402460(0x527))
					f576110(ref & 0xff, 15, ident, flags & 1, z, flags >> 1 & 1, flags >> 2 & 1)
					if (flags & 1) != (ref & 0xff):
						f5b9170(_jq_op(flags & 1, 14), z, 0, 0)
					f5b9170(_jq_op(flags & 1, 14), z, 0x11, 0)
					return 0
			i += 1
	return 1


func f5a7440(p: int) -> int:
	if f5709d0(p, 0x3c4) != 0:
		var q := p & 1
		var i := 0
		while i < m.u16(0xa563ae + q * 0xd44):
			var a := 0xa563f0 + q * 0xd44 + i * 2
			if (m.u8(a) & 15) == 3 and f4022e0(m.u16(a - 0x40)) == 0x3c4 and (m.u8(a) >> 4) == 0:
				var ident := m.u8(a + 1)
				var ref := f5687d0(ident) & 0xffff
				if (ref >> 8 & 0xff) == 15:
					f578400(p, f402460(0x3c4))
					f5b9170(0x8e, (ident << 8 | ref & 0xff) & 0xff01 | 0x1e, (m.u8(JoeyMem.pl(p) + 8) << 8 | p & 0xff) & 0xff01 | 0x16, 0)
			i += 1
	return 1


func f5a6530(p: int) -> int:
	if f56cbd0(p, 0x5a6) != 0:
		var i := 0
		while i < m.u8(JoeyMem.pl(p) + 10):
			var entry := m.u32(JoeyMem.pl(p) + 0x990 + i * 4)
			if f4022e0(entry & 0xfff) == 0x5a6 and f56b440(entry & 0xfff, JoeyMem.ident(entry)) == 0:
				f5783c0(p, 14, f402460(0x5a6), JoeyMem.ident(m.u32(JoeyMem.pl(p) + 0x990 + i * 4)))
				f5787f0(p, 200)
			i += 1
	return 1


func _jz_optional_monster(p: int, card: int, tail_result: bool) -> int:
	if _jt_ai(p):
		return 1
	if _jz_pos() <= 4:
		while _jz_pos() <= 4:
			var z := _jz_pos()
			var entry := m.u32(JoeyMem.zone(p, z))
			if f4022e0(entry & 0xfff) == card and f57ec70(p, z, entry & 0xfff) != 0:
				_jz_prompt(m.u16(JoeyMem.zone(p, z)) & 0xfff)
				_jz_shift(0x500)
				return 0
			_jz_shift(0x100)
		return 1
	var z := _jz_pos() - 5
	if m.u16(0xa558b4) != 0:
		var entry := m.u32(JoeyMem.zone(p, z))
		f5ba860((((p << 15 | z & 31 | 0x20) << 16) | entry & 0xfff) & 0xffffffff, JoeyMem.ident(entry))
	_jz_shift(-0x301)
	return int(_jz_pos() > 4) if tail_result else 0


func f5a7c50(p: int) -> int:
	return _jz_optional_monster(p, 0x243, true)


func f5a7e50(p: int) -> int:
	return _jz_optional_monster(p, 0x1a0, false)


func f5a5ce0(p: int) -> int:
	var count := f569d90(1, 1, 0)
	count += f569d90(0, 1, 0)
	if (count & 0xffffffff) != 0:
		while _jz_pos() < 5:
			var z := _jz_pos() + 5
			var entry := m.u32(JoeyMem.zone(p, z))
			if f569790(p, z, 0x600) != 0:
				var roll := f5bddb0(6)
				f578390(p, entry & 0xfff, z)
				f5b9170(_jq_op(p, 0xe4), roll + 1, z, 0)
				var mask := 0
				for q in range(2):
					for target in range(5):
						var a := JoeyMem.zone(q, target)
						var index := m.u16(a) & 0xfff
						if index != 0 and (m.u8(a + 6) & 2) != 0 and mini(f4026c0(index) & 0xffff, 6) == roll + 1:
							mask |= 1 << ((q << 4) + target & 31)
				f5777f0(p, entry & 0xfff, mask)
			_jz_shift(0x100)
	return 1


func f5a7100(p: int) -> int:
	var pos := _jz_pos()
	if pos == 0 or (pos == 1 and m.u16(0xa558b4) != 0):
		for i in range(m.u8(JoeyMem.pl(p) + 10) - 1, -1, -1):
			var a := JoeyMem.pl(p) + 0x990 + i * 4
			var entry := m.u32(a)
			if f4022e0(entry & 0xfff) == 0x1da and f56b440(entry & 0xfff, JoeyMem.ident(entry)) == 0:
				if pos == 0:
					if not _jt_ai(p):
						_jz_prompt(f402460(0x1da), 0xd0, 128)
					else:
						m.set_u16(0xa558b4, 1)
					_jz_shift(0x100)
				else:
					f5783c0(p, 14, m.u16(a) & 0xfff, JoeyMem.ident(m.u32(a)))
					f575c40(p, a)
					_jz_shift(-1)
				return 0
	return 1


func f5a7350(p: int) -> int:
	var link := _s32(f5709f0(p, 0x57d))
	if link >= 0:
		var ref := m.u16(0xa563f0 + link * 2 + (p & 1) * 0xd44)
		if (ref & 0xff) >> 4 == 0:
			var ident := ref >> 8
			f5797c0(p, 0x57d, 0)
			if f570b40(p) != 0 and f56a000(p) != 0 and _s32(f568ad0(p, ident)) >= 0:
				f5783c0(p, 14, f402460(0x57d), ident)
				var i := _s32(f568ad0(p, ident))
				f5ada20(p, JoeyMem.pl(p) + 0x990 + i * 4, 1, 1, 0x20, 14, p)
			return 0
	return 1


func f5a7550(p: int) -> int:
	var other := 1 - p
	var initial := m.u32(_JS_WORK) >> 8
	var pos := initial & 0x7f
	if pos == 0:
		m.set_u32(_JS_WORK, m.u32(_JS_WORK) & 0xffff85ff | 0x500)
		while true:
			pos = _jz_pos()
			var entry := m.u32(JoeyMem.zone(other, pos))
			if f4022e0(entry & 0xfff) == 0x489 and f57ec70(other, pos, entry & 0xfff) != 0:
				f5bcf40(other, 0x489)
				return 0
			_jz_shift(0x100)
			if _jz_pos() >= 10:
				break
	elif m.u16(0xa57822) != 0:
		var entry := m.u32(JoeyMem.zone(other, pos))
		f5b9170(_jq_op(other, 0x91), pos, 0, 0)
		f5ba860(((initial & 31 | other * 0x8000 | 0x20) << 16 | entry & 0xfff) & 0xffffffff, JoeyMem.ident(m.u32(JoeyMem.zone(other, pos))))
		m.set_u32(_JS_WORK, m.u32(_JS_WORK) & 0xffff80ff)
		return 0
	return 1


func f5a7a50(p: int) -> int:
	var initial := m.u32(_JS_WORK) >> 8
	var pos := initial & 0x7f
	if pos == 0:
		m.set_u32(_JS_WORK, m.u32(_JS_WORK) & 0xffff85ff | 0x500)
		while true:
			pos = _jz_pos()
			var entry := m.u32(JoeyMem.zone(p, pos))
			if f4022e0(entry & 0xfff) == 0x428 and f57ed20(p, pos, entry & 0xfff) != 0:
				if not _jt_ai(p):
					_jz_prompt(m.u16(JoeyMem.zone(p, pos)) & 0xfff)
				else:
					m.set_u16(0xa558b4, 1)
				return 0
			_jz_shift(0x100)
			if _jz_pos() >= 10:
				break
	elif m.u16(0xa558b4) != 0:
		var entry := m.u32(JoeyMem.zone(p, pos))
		f5b9170(_jq_op(p, 0x91), pos, 0, 0)
		f5ba860(((initial & 31 | p << 15) << 16 | entry & 0xfff) & 0xffffffff, JoeyMem.ident(m.u32(JoeyMem.zone(p, pos))))
		m.set_u32(_JS_WORK, m.u32(_JS_WORK) & 0xffff80ff)
		return 0
	return 1


func f5a46b0(p: int) -> int:
	while _jz_pos() <= 4:
		var z := _jz_pos()
		var a := JoeyMem.zone(p, z)
		var index := m.u32(a) & 0xfff
		if index != 0 and (m.u8(a + 6) & 2) != 0 and f4022e0(index) == 0x267:
			var link := _s32(f56da10(p, z, 0x267))
			if link >= 0:
				var flag := m.u8(a + 0x4d + link * 2)
				if (flag & 1) == 0 and flag / 2 < m.u16(0xa577f8):
					if f56b440(index, JoeyMem.ident(m.u32(a))) == 0:
						f578390(p, index, z)
					f5b9170(_jq_op(p, 0x4d), (link & 0xff) << 8 | z & 0xff, f402460(0x267), 0x10b)
					_jz_shift(0x100)
					return 0
		_jz_shift(0x100)
	return 1
