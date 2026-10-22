class_name JoeyPortZB
extends JoeyPortZA
## Avisos nativos: produccion, ventana de respuesta y consumo sin candidatos.

func f57e160(at: int, p: int, owner: int, z: int) -> int:
	var obj := JoeyMem.zone(owner, z)
	var entry := m.u32(obj)
	m.set_u16(at, entry & 0xfff)
	m.set_u16(at + 2, (((int(p != owner) << 13) | (z & 31)) << 1) | ((m.u16(at + 2) & 0xbfc0) ^ (owner & 1)))
	m.set_u16(at + 4, (m.u16(at + 4) & 0xe01f) | (JoeyMem.ident(entry) << 5))
	return f57e490(at, 0) if m.u8(obj + 6) & 2 else f57e650(at, 0)

func f57e220(at: int, p: int, z: int) -> int:
	var entry := m.u32(0xa56434 + (p & 1) * 0xd44 + z * 4)
	m.set_u16(at, entry & 0xfff)
	m.set_u16(at + 2, ((m.u16(at + 2) & 0xbfd6) ^ (p & 1)) | 0x16)
	m.set_u16(at + 4, (m.u16(at + 4) & 0xe01f) | (JoeyMem.ident(entry) << 5))
	return f57e650(at, 0)

func f5975c0(at: int, p: int, kind: int, z: int) -> int:
	match kind:
		0, 5: return 8 if f57e160(at, m.u16(JoeyMem.MODE) & 1, p, kind + z) != 0 else 0
		11:
			var index := m.u16(0xa56434 + (p & 1) * 0xd44 + z * 4) & 0xfff
			if _s32(f57e0c0(index)) > 0:
				f45e240(4)
				if _s32(f57e0c0(index)) > 1 and f57e220(at, p, z) != 0:
					return 8
		12, 13, 14, 15: return f5a0010(p, kind) | f5a0070(at, m.u32(0xa55044), m.u32(0xa55048))
	return 0

func f5976f0(p: int, index: int, event: int) -> int:
	match event:
		1:
			if _jv_ai(p):
				return 1
			return int(p != m.u8(JoeyMem.TURN) & 1 and s16(f4025d0(index)) == 21)
		3: return 1 if _jv_ai(p) else int(p != m.u8(JoeyMem.TURN) & 1)
		5, 6, 7:
			var card := f4022e0(index) & 0xffff
			if (event in [5, 6] and card in [0x3c9, 0x2a8, 0x2a9, 0x3ea, 0x591]) or (event == 7 and card in [0x3c9, 0x52d, 0x591]):
				return 1
			return int(f402690(index) != 0)
		8: return int(s16(f4022e0(index)) == 0x52d)
		13, 14, 19, 20, 21: return f5683f0(index, event)
		16: return int(s16(f4022e0(index)) in [0x474, 0x518])
		18: return 1
		22: return int(p != m.u8(JoeyMem.TURN) & 1 and s16(f4022e0(index)) == 0x3f9)
		26: return int(s16(f4022e0(index)) == 0x470)
		27: return int(s16(f4022e0(index)) == 0x475)
		28: return int(f4022e0(index) & 0xffff in [0x46e, 0x46f, 0x47d, 0x515])
		30: return int(s16(f4022e0(index)) == 0x476)
	return 0

func f597a00(p: int) -> int:
	var at := m.local(20)
	for owner in range(2):
		for z in range(10):
			var index := m.u16(JoeyMem.zone(owner, z)) & 0xfff
			if index != 0 and f57e160(at, p, owner, z) != 0 and f5976f0(p, index, (m.u32(at + 2) >> 6) & 63) != 0:
				return 1
	if p == m.u8(JoeyMem.TURN) & 1:
		for z in range(m.u8(JoeyMem.pl(p) + 8)):
			var index := m.u16(0xa56434 + (p & 1) * 0xd44 + z * 4) & 0xfff
			if index != 0 and f57e220(at, p, z) != 0 and f5976f0(p, index, (m.u32(at + 2) >> 6) & 63) != 0:
				return 1
	return 0

func f597b50(text: int) -> int:
	m.set_u8(text, 0)
	var count := (m.u32(0xa55c94) >> 8) & 127
	if count != 0:
		var event := m.u8(0xa55c95 + count)
		var data := m.u32(0xa55ca4 + count * 4)
		var message := -1
		match event:
			1: message = 0x102
			3: message = 0xfb
			5, 6, 7, 8:
				message = {5: 0xfc, 6: 0xfe, 7: 0x100, 8: 0xaf}[event] + (((data >> 8) & 1) ^ (m.u16(JoeyMem.MODE) & 1))
			10: message = 0xb2
			11: message = 0xb3
			12: message = 0xb4
			13:
				if m.u32(0xa57840) & 0x3800 < 0x2001:
					var temp := m.local(256)
					f5bdfc0(temp, 0x10a, data & 0xffff)
					f5bdfc0(text, temp, data >> 16)
			14: message = 0xba - int(((~m.u8(JoeyMem.MODE)) & 1) != ((data >> 24) & 15))
			16: message = 0xbd + int(((data >> 16) & 255) == (~m.u32(JoeyMem.MODE)) & 1)
			18: message = 0xb6 + ((m.u32(JoeyMem.MODE) ^ m.u32(0xa57840)) & 1)
			19:
				var battle := m.u32(0xa57840)
				if battle & 0x3800 < 0x2001:
					var obj := JoeyMem.zone((battle >> 1) & 1, (battle >> 11) & 7)
					if m.u16(obj) & 0xfff and m.u8(obj + 6) & 2:
						f5bdf40(text, 0xb1, f402290(m.u16(obj) & 0xfff))
			21: message = 0xb8
			22: message = 0x110
			23, 24, 25, 26: message = 0xc1 + event - 23
			27: message = 0xc5 + int((data & 255) == (~m.u32(JoeyMem.MODE)) & 1)
			28:
				if data & 0x4000:
					message = 0x10b
				elif (data >> 18) & 15 == 11:
					message = 199
				elif (data >> 18) & 15 == 14:
					message = 0x10c
			29: message = 200
			30: message = 0xc9 + int((data & 255) == (~m.u32(JoeyMem.MODE)) & 1)
		if message >= 0:
			f5bde30(text, message)
		f5bde70(text, 0x5eb5d8)
	f5bde70(text, 0x10d)
	return 0

func f598590(p: int, event: int, data: int) -> int:
	if m.u8(JoeyMem.TURN) & 0x10 and ((~m.u32(JoeyMem.MODE) ^ m.u8(JoeyMem.TURN)) & 1) == 0:
		var packet := m.local(8)
		m.set_u16(packet, p)
		m.set_u16(packet + 2, event)
		m.set_u32(packet + 4, data)
		f5bd090(0xf057, packet, 8)
		return 0
	if m.u32(0xa55c94) & 0x8000 == 0:
		if m.u32(0xa55c94) & 255 == 0:
			m.set_u32(0xa55c94, ((m.u32(0xa55c94) & 0xff0081ff) | ((event & 255) << 16) | 0x100))
			m.set_u32(0xa55ca8, data)
		else:
			var i := mini((m.u32(0xa55c94) >> 8) & 127, 15)
			m.set_u8(0xa55c96 + i, event)
			m.set_u32(0xa55ca8 + i * 4, data)
			_jw_step(0xa55c94, 0x7f00)
		m.set_u16(0xa55ce8, ((((p & 1) | 2) << 1 | (p & 1)) << 11) | (m.u16(0xa55ce8) & 0xa01f))
	return 0

func _jzb_select(at: int, chain: bool, repeat_hover: bool = false) -> void:
	var changed := f5b88d0()
	var p := m.u32(0xa55044)
	var kind := m.u32(0xa55048)
	var z := m.u32(0xa5504c)
	if changed != 0 or m.u16(0xa57804) & 1 == 0:
		var select := kind in [12, 13, 14, 15]
		var hover := s16(f5beeb0()) if repeat_hover else 0
		if kind in [0, 5, 10, 11]:
			if not repeat_hover:
				hover = s16(f5beeb0())
			select = hover != 0 and (s16(f5beeb0()) != 0 if repeat_hover else f5beed0() != 0)
		if select:
			m.set_u16(0xa57808, m.u16(0xa57808) & 0xff00)
			m.set_u16(0xa57806, f5baa00(at, p, kind, z) if chain else f5975c0(at, p, kind, z))
			m.set_u16(0xa57804, (m.u16(0xa57804) & 0xfffe) | int(m.u16(0xa57806) != 0))
		f5b88a0()
		if m.u16(0xa57804) & 1 == 0:
			m.set_u16(0xa57808, m.u16(0xa57808) & 0xff00)
			f5bf4b0()
			return
	f5b8910()

func _jzb_reset_selection() -> void:
	m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffe)
	m.set_u16(0xa57808, m.u16(0xa57808) & 0xff00)
	f5bf4b0()

func _jzb_packet() -> void:
	var count := (m.u32(0xa55c94) >> 8) & 127
	var packet := m.local(1 + count * 5)
	m.set_u8(packet, count)
	for i in range(count):
		m.set_u8(packet + 1 + i * 5, m.u8(0xa55c96 + i))
		m.set_u32(packet + 2 + i * 5, m.u32(0xa55ca8 + i * 4))
	f5bd090(0xf059, packet, 1 + count * 5)

func f597e90() -> int:
	var step := (m.u32(0xa55ce8) >> 5) & 63
	if step == 0:
		if f5bc050() != 0:
			return 1
		m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xffffbfff)
		f5bddf0(0xa55d00, 20)
		m.set_u16(0xa55d02, (m.u16(0xa55d02) & 0xfffe) | ((m.u32(0xa55ce8) >> 11) & 1))
		if f597a00((m.u32(0xa55ce8) >> 11) & 1) == 0:
			_jw_state(0xa55ce8, 0x1a0, 0x640)
			return 0
		_jw_step(0xa55ce8, 0x7e0)
		step = 1
	match step:
		1:
			var p := (m.u32(0xa55ce8) >> 11) & 1
			if _jv_ai(p):
				if f5b3b50(p) == 0:
					_jw_state(0xa55ce8, 0x1a0, 0x640)
				else:
					_jw_state(0xa55ce8, 0x680, 0x160)
				return 0
			if m.u8(JoeyMem.TURN) & 0x10 and p == (~m.u8(JoeyMem.MODE)) & 1:
				_jw_state(0xa55ce8, 0x560, 0x280)
				return 0
			var text := m.local(256)
			f597b50(text)
			f5bf800(text)
			f5bf9a0(1, 0)
			_jw_step(0xa55ce8, 0x7e0)
			return 0
		2:
			if m.u16(0xa558b4) != 0:
				m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffc)
				_jw_state(0xa55ce8, 0x6a0, 0x140)
				return 0
		10:
			if f5beed0() == 0 or m.u32(0xa54e54) & 2:
				_jzb_reset_selection()
				if m.u32(0xa54e54) & 0x102:
					_jw_state(0xa55ce8, 0x7c0, 0x20)
				return 0
			_jzb_select(0xa55d00, false)
			if m.u16(0xa57804) & 2:
				_jw_step(0xa55ce8, 0x7e0)
			return 0
		11:
			var p := (m.u16(0xa5780a) >> 8) & 1
			var kind := m.u16(0xa5780a) >> 9
			if m.u8(0xa57804) & 0x78 == 0x60:
				f41cea0(p, kind)
				f40c940(p, kind - 11, 0xffffffff, kind)
				_jw_clear_window()
				_jw_step(0xa55ce8, 0x7e0, -1)
				return 0
			match kind:
				0, 5:
					_jw_clear_window()
					var z := m.u8(0xa5780c) + kind
					var obj := JoeyMem.zone(p, z)
					var face := int(m.u8(obj + 6) & 2 != 0)
					if face == 0:
						f5b9170((m.u16(0xa5780a) & 0xff01) << 7 | 0x91, z, 0, 0)
					f5ba4d0(((((m.u16(0xa5780a) >> 8) << 10) | face) << 21) | ((z & 31) << 16) | m.u16(0xa57802), JoeyMem.ident(m.u32(obj)), 0)
				11:
					f59fd60(1, 0, 0xa55d00)
					if m.u16(0xa57804) & 2:
						return 0
				13, 14: f59ff50(0, p, kind)
			_jw_state(0xa55ce8, 0x2000, 0x4000)
			return 1
		20:
			_jzb_packet()
			f5bd090(0xf051, 0, 0)
			m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xffffbfff)
			m.set_u32(0xa58260, m.u32(0xa58260) & 0xfffffbff)
			_jw_step(0xa55ce8, 0x7e0)
			return 0
		21:
			if m.u32(0xa58260) & 0x400 == 0:
				return 0
			if m.u32(0xa55ce8) & 0x4000:
				m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xffffdfff)
				return 1
		50:
			# Alterna primero al otro jugador y compara con el jugador de inicio (bit12).
			m.set_u16(0xa55ce8, m.u16(0xa55ce8) ^ 0x800)
			if ((m.u16(0xa55ce8) >> 1) & 0x800) != m.u16(0xa55ce8) & 0x800:
				m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xfffff81f)
				return 0
			m.set_u32(0xa55c94, m.u32(0xa55c94) & 0xffff80ff)
			m.set_u32(0xa55ce8, m.u32(0xa55ce8) & 0xffffdfff)
			return 1
		_: return 1
	_jw_state(0xa55ce8, 0x1a0, 0x640)
	return 0

func f5986a0() -> int:
	var chain := m.u8(0xa55cea) & 0x80 != 0
	var at := 0xa55d28 if chain else 0
	match m.u8(0xa55cea) & 127:
		0:
			var text := m.local(256)
			if chain:
				f5bdf40(text, 7 if f4025d0(m.u16(at)) & 0xffff < 21 else 8, f402290(m.u16(at)))
			else:
				f597b50(text)
			f5bf800(text)
			f5bf9a0(1, 0)
		1:
			if m.u16(0xa558b4) != 0:
				m.set_u16(0xa57804, m.u16(0xa57804) & 0xfffc)
			else:
				f5bd050(0xf055, 0, 0, 0)
				return 1
		2:
			if f5beed0() == 0 or m.u32(0xa54e54) & 2:
				_jzb_reset_selection()
				if m.u32(0xa54e54) & 0x102:
					m.set_u32(0xa55cea, m.u32(0xa55cea) & 0xffffff80)
				return 0
			_jzb_select(at if chain else 0xa55d14, chain, true)
			if m.u16(0xa57804) & 2 == 0:
				return 0
		3:
			var p := (m.u16(0xa5780a) >> 8) & 1
			var kind := m.u16(0xa5780a) >> 9
			if m.u8(0xa57804) & 0x78 == 0x60:
				f41cea0(p, kind)
				f40c940(p, kind - 11, 0xffffffff, kind)
				_jw_clear_window()
				_jw_step(0xa55cea, 127, -1)
				return 0
			_jw_clear_window()
			if chain:
				f5b9170((m.u16(0xa5780a) & 0xff00) << 7 | 7, 0, 0, 0)
			f5bddf0(0xa55d14, 20)
			var ref := ((p & 1) | (((m.u8(0xa5780b) & 0xfe) + m.u8(0xa5780c) * 2) & 0x3e))
			var obj := JoeyMem.zone(ref & 1, (ref >> 1) & 31)
			m.set_u32(0xa55d14, m.u16(obj) & 0xfff)
			m.set_u16(0xa55d16, (ref & 0xdfff) | 0x1000)
			m.set_u16(0xa55d18, (m.u16(0xa55d18) & 0xe01f) | (JoeyMem.ident(m.u32(obj)) << 5))
			if m.u8(JoeyMem.zone(p, m.u8(0xa5780c) + kind) + 6) & 2 == 0:
				m.set_u16(0xa55d16, ref & 0xcfff)
				f5b9170((m.u16(0xa5780a) & 0xff01) << 7 | 0x91, m.u8(0xa5780c) + kind, 0, 0)
		4:
			f5ba880(0xa55d14, at, 0)
			return 1
		_: return 1
	_jw_step(0xa55cea, 127)
	return 0
