class_name JoeyPortZA
extends JoeyPortZ
## Acuses de recibo de a5506a: estado del trabajo grafico, sin temporizadores inventados.

func _jza_ack() -> void:
	m.set_u16(0xa5506a, m.u16(0xa5506a) & 0xfffe)

func _jza_next() -> void:
	m.set_u8(0xa5506b, m.u8(0xa5506b) + 1)

func _jza_ref(value: int) -> int:
	var at := m.local(4)
	m.set_u16(at, value)
	return at

func _jza_object(ref: int) -> int:
	return f41cee0(ref & 1, (ref >> 1) & 31, (ref >> 6) & 255)

func _jza_pile(ref: int, flags: int) -> void:
	var kind := (ref >> 1) & 31
	if (kind == 12 and ref & 0x3fc0 == 0) or (kind == 13 and ref & 0x3fc0 != 0):
		var object := f41cf60(ref & 1, kind)
		# El objeto es presentacion. Sin pantalla no existe; el estado del motor no cambia.
		if object != 0:
			m.set_u32(object + 12, flags)

func f40cf20() -> int:
	var flags := m.u8(0xa5506a)
	if flags & 1:
		match flags >> 1:
			1, 2: f40cfa0()
			3: f40d070()
			4: f40d550()
			5: f40d840()
			6: f40d900()
			_: return 0
		return 1
	return 0

func f40cfa0() -> int:
	if m.u8(0xa5506b) == 0:
		m.set_u16(0xa5506a, m.u8(0xa5506a) | 0x100)
		f44ef40(6)
		var extra := m.u16(0xa5506e)
		var at := m.local(8)
		m.set_u16(at, ((((extra & 1) | ((extra >> 8) * 2)) << 13 | (m.u8(0xa5506d) & 31)) << 1) | (m.u8(0xa5506c) & 1))
		m.set_u32(at + 4, m.u8(0xa5506c))
		f41d580(m.u32(0x5f300c), at)
	elif f41d0c0(m.u32(0x5f300c)) & 255 == 0:
		_jza_ack()
	return 0

func f40d070() -> int:
	var index := m.u32(0xa5506c)
	var step := m.u8(0xa5506b)
	var source := m.u16(0xa55070)
	var target := m.u16(0xa55072)
	if step == 0:
		if source & 0x3e == 0x1c:
			var different: bool
			if _s32(f44baa0()) < 1001:
				var object := f41cf60(source & 1, (source >> 1) & 31)
				different = object != 0 and m.u32(object + 16) != index
			else:
				different = m.u8(0xa55d6a + (source & 1) * 0xd44) != ((source >> 6) & 255)
			if different:
				f44ef40(7)
				# Tercer argumento de 41cf60 es un sobrante de pila; el objeto se consulta con dos.
				var object := f41cf60(source & 1, (source >> 1) & 31)
				f43c730(object, index)
				_jza_next()
				return 0
		m.set_u8(0xa5506b, 16)
	elif step != 16:
		if step != 17:
			_jza_next()
			return 0
		if f41d0c0(m.u32(0x5f300c)) & 255:
			return 0
		_jza_pile(target, 0x100)
		_jza_ack()
		return 0
	if f41d0c0(m.u32(0x5f300c)) & 255:
		return 0
	_jza_pile(target, 0x810)
	var kind := (source >> 1) & 31
	if kind < 12 or kind > 15:
		if _jza_object(source) == 0:
			_jza_ack()
			return 0
	else:
		f41d160(m.u32(0x5f300c), index, _jza_ref(source))
	var card := f4022e0(index) & 0xffff
	if card > 0x77f and card < 0x784 and ((target >> 1) & 31) > 11 and ((target >> 1) & 31) < 16:
		f41d3f0(m.u32(0x5f300c), _jza_ref(source))
		return 0
	f44ef40(7)
	f41d6c0(m.u32(0x5f300c), _jza_ref(source), _jza_ref(target))
	_jza_next()
	return 0

func f40d550() -> int:
	if m.u8(0xa5506b) != 0:
		if f41d0c0(m.u32(0x5f300c)) & 255 == 0:
			_jza_ack()
		return 0
	m.set_u16(0xa5506a, m.u8(0xa5506a) | 0x100)
	var index := m.u32(0xa5506c)
	var source := m.u16(0xa55070)
	var target := m.u16(0xa55072)
	var kind := (source >> 1) & 31
	if kind < 12 or kind > 15:
		if _jza_object(source) == 0:
			_jza_ack()
			return 0
		index = m.u32(_jza_object(source) + 16)
	else:
		f41d160(m.u32(0x5f300c), index, _jza_ref(source))
	var card := f4022e0(index) & 0xffff
	if card >= 0x780 and card <= 0x783 and ((target >> 1) & 31) > 11 and ((target >> 1) & 31) < 16:
		f41d3f0(m.u32(0x5f300c), _jza_ref(source))
		return 0
	f41df00(m.u32(0x5f300c), _jza_ref(source), _jza_ref(target))
	return 0

func f40d840() -> int:
	if m.u8(0xa5506b) == 0:
		m.set_u16(0xa5506a, m.u8(0xa5506a) | 0x100)
		f41d160(m.u32(0x5f300c), m.u32(0xa5506c), _jza_ref(m.u16(0xa55072)))
	elif f41d0c0(m.u32(0x5f300c)) & 255 == 0:
		_jza_ack()
	return 0

func f40d900() -> int:
	if m.u8(0xa5506b) == 0:
		m.set_u8(0xa5506b, 1)
		var source := m.u16(0xa55070)
		var target := m.u16(0xa55072)
		if _jza_object(source) != 0 and _jza_object(target) != 0:
			f41db40(m.u32(0x5f300c), _jza_ref(source), _jza_ref(target))
	elif f41d0c0(m.u32(0x5f300c)) & 255 == 0:
		_jza_ack()
	return 0
