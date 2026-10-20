class_name JoeyPortZJ
extends JoeyPortZI
## Entrada humana optativa. Las elecciones alimentan cursores/botones nativos;
## los selectores y comandos del motor siguen siendo los únicos que ejecutan reglas.
var ui_enabled := false
var ui_cursor_ready := false
var ui_busy := false

func ui_set_cursor(player: int, area: int, index: int) -> void:
	m.set_u32(0xa55044, player & 1)
	m.set_u32(0xa55048, area)
	m.set_u32(0xa5504c, index)
	ui_cursor_ready = true

func ui_press(mask: int) -> void:
	m.set_u32(0xa54e54, mask)

func ui_set_choice(value: int) -> void:
	phase_choice = value

func ui_answer(value: int) -> void:
	m.set_u16(0xa558b4, value)


## FUN005bfcc0: respuesta del selector nativo y reconocimiento de su cursor.
func f5bfcc0(value: int) -> int:
	m.set_u16(0xa558b4, value)
	f5bdbd0(m.u32(0xa55044), m.u32(0xa55048), m.u32(0xa5504c))
	return 0

func f5beeb0() -> int:
	if not ui_enabled:
		return super.f5beeb0()
	if not ui_cursor_ready:
		return _frontier(0x5beeb0, [], 0)
	return _frontier(0x5beeb0, [], f570230(m.u32(0xa55044), m.u32(0xa55048), m.u32(0xa5504c)) & 0xffff)

func f5beed0() -> int:
	return _frontier(0x5beed0, [], int(ui_cursor_ready)) if ui_enabled else super.f5beed0()

func f5bee70() -> int:
	return _frontier(0x5bee70, [], int(ui_busy)) if ui_enabled else super.f5bee70()

func f5bf180() -> int:
	return _frontier(0x5bf180, [], int((m.u32(0xa54e54) & 0x201) != 0)) if ui_enabled else super.f5bf180()

func f5bf1a0() -> int:
	return _frontier(0x5bf1a0, [], int((m.u32(0xa54e54) & 0x502) != 0)) if ui_enabled else super.f5bf1a0()

func f4182d0() -> int:
	m.set_u8(0x5f2fe0, 1)
	return 0

func _zj_action(index: int) -> void:
	var n := m.u8(0x5dd980 + index * 4) & 15
	m.set_u16(0xa57804, (m.u16(0xa57804) & 0xff87) | (n << 3))

func _zj_hint() -> void:
	if (m.u8(0xa57804) & 0x78) == 0x60:
		f5bf4b0()
	else:
		f5bf490((m.u32(0xa57804) >> 3) & 15)

func f5b8910() -> int:
	var available := m.u16(0xa57806)
	if available == 0:
		m.set_u32(0xa57804, m.u32(0xa57804) & 0xfffffffe)
		m.set_u32(0xa57808, m.u32(0xa57808) & 0xffffff00)
		f5bf4b0()
		return 0
	var state := m.u8(0xa57808)
	if state == 0:
		m.set_u16(0xa55040, m.u16(0xa55040) & 0xfffe)
		m.set_u32(0xa57804, (m.u32(0xa57804) & 0xffffff87) | 0x10)
		for i in range(13):
			if available & (1 << (m.u8(0x5dd980 + i * 4) & 31)):
				_zj_action(i)
				break
		f5b88a0()
		_zj_hint()
		m.set_u8(0xa57808, m.u8(0xa57808) + 1)
		return 0
	if state != 1:
		m.set_u32(0xa57804, m.u32(0xa57804) & 0xfffffffe)
		m.set_u32(0xa57808, m.u32(0xa57808) & 0xffffff00)
		return 0
	if s16(f5beeb0()) != 0 and (m.u32(0xa54e54) & 0x100):
		m.set_u32(0xa54e54, (m.u32(0xa54e54) & 0xfffffeff) | 0x400)
	if m.u32(0xa54e54) & 0x400:
		var current := (m.u32(0xa57804) >> 3) & 15
		var i := 0
		while i < 13 and current != m.u32(0x5dd980 + i * 4):
			i += 1
		i += 1
		while i < 26:
			if m.u16(0xa57806) & (1 << (m.u8(0x5dd980 + (i % 13) * 4) & 31)):
				_zj_action(i % 13)
				break
			i += 1
		_zj_hint()
		f44ef40(0)
	if f5aa480() == 0:
		return 0
	m.set_u32(0xa57804, m.u32(0xa57804) | 2)
	m.set_u32(0xa57808, m.u32(0xa57808) & 0xffff00ff)
	m.set_u16(0xa57802, f5beeb0())
	var a := f5700f0(m.u32(0xa55044), m.u32(0xa55048), m.u32(0xa5504c))
	var b := f5700f0(m.u32(0xa55044), m.u32(0xa55048), m.u32(0xa5504c))
	m.set_u8(0xa5780e, ((m.u32(b) >> 12) & 1) + ((m.u32(a) >> 24) & 255) * 2)
	m.set_u8(0xa5780c, m.u32(0xa5504c))
	m.set_u8(0xa57808, m.u8(0xa57808) + 1)
	m.set_u8(0xa5780b, (m.u32(0xa55048) << 1) | (m.u32(0xa55044) & 1))
	f44ef40(1)
	f5bf4b0()
	return 1
