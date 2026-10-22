class_name JoeyPortZS
extends JoeyPortZR
## Protocolo LAN de Joey, con índices de jugador absolutos como 5b93f0.
## El transporte implementa send/receive/players/close e is_host (Lan o tubería).
var network_transport: Object


func f479b30() -> int:
	if visual_busy_query.is_valid(): return int(visual_busy("modifier_shift"))
	return super.f479b30()


## Alias nativo de la entrada de diálogos; no pertenece al cable de red.
func f5bdc40() -> int:
	return f40cf20()


func f48dd20(player: int) -> int:
	if not visual_busy_query.is_valid(): return super.f48dd20(player)
	return int(f44b980() != 0 and visual_busy("quick_message", player))


func f443e40(source: int, size: int) -> int:
	if network_transport == null:
		return super.f443e40(source, size)
	var packet := PackedByteArray()
	for i in size: packet.append(m.u8(source + i))
	return int(network_transport.send(packet))


func f444140(target: int) -> int:
	if network_transport == null: return 0
	var packet: PackedByteArray = network_transport.receive()
	for i in packet.size(): m.set_u8(target + i, packet[i])
	return packet.size()


func f444210() -> int:
	return int(network_transport != null and network_transport.is_host)


func f444220() -> int:
	return int(network_transport != null and network_transport.players() == 2)


func f444230() -> int:
	if network_transport != null: network_transport.close()
	return 0


func f44b9c0() -> int:
	return m.u32(0x5f3290)


func f44b9d0(seed: int) -> int:
	m.set_u32(0x5f3290, seed)
	return 0


func f5bd210() -> int:
	var main_count := m.u16(0xa54f3c)
	var fusion_count := m.u16(0xa54f40)
	m.set_u16(0xa58160, 0xf004)
	m.set_u16(0xa58162, ((fusion_count & 255) << 8) | (main_count & 255))
	m.copy(0xa58164, 0xa54e60, main_count * 2)
	m.copy(0xa58164 + main_count * 2, 0xa54f1e, fusion_count * 2)
	f443e40(0xa58160, (main_count + fusion_count + 2) * 2)
	return 0


func f5bd2a0() -> int:
	var seed := f44b9c0()
	m.set_u16(0xa58160, 0xf005)
	m.set_u16(0xa58162, seed)
	m.set_u16(0xa58164, seed >> 16)
	f443e40(0xa58160, 6)
	return 0


func f5bdac0() -> int:
	return (m.u8(JoeyMem.TURN) & 0x20) >> 5


func f5bdad0() -> int:
	if m.u32(JoeyMem.CMD_STATE) & 0x4000: return 0
	var remote := int(m.u8(JoeyMem.TURN) & 0x10 != 0 and ((~m.u32(JoeyMem.MODE) ^ m.u8(JoeyMem.TURN)) & 1) == 0)
	var pending := _s32(m.u32(0xa58260) << 7) >> 28
	return int(pending + remote > 0)


func f5bdb20() -> int:
	m.clear(0xa57f60, 0x33c)
	m.set_u16(JoeyMem.TURN, m.u16(JoeyMem.TURN) & 0xffdf)
	return 0


func f5bdb40() -> int:
	if f5bd2d0() == 0: return 1
	match m.u32(0xa58260) & 7:
		0: f5bd210()
		1:
			if m.u32(0xa58260) & 8 == 0: return 0
		2:
			if f444210() != 0: f5bd2a0()
			elif m.u32(0xa58260) & 16 == 0: return 0
		_: return 1
	var flags := m.u32(0xa58260)
	m.set_u32(0xa58260, flags ^ ((flags + 1 ^ flags) & 7))
	return 0


func f5bd2d0() -> int:
	if m.u32(0xa58260) & 0x20:
		f444230()
		return 1
	m.set_u16(0xa57f60, 0xf000)
	var size := f444140(0xa57f60)
	if size == 0:
		if f444220() != 0 and f5bdac0() == 0: return 1
		m.set_u16(JoeyMem.TURN, m.u16(JoeyMem.TURN) | 0x20)
		return 0
	var op := m.u16(0xa57f60)
	var data := 0xa57f62
	var value := m.u16(data)
	f5bd0f0(op, 0)
	match op:
		0xf000: pass
		0xf002:
			m.set_u32(0xa58260, m.u32(0xa58260) | 0x20)
			var result := 3 - value if value < 3 else 3
			m.set_u16(JoeyMem.TURN, ((result & 3) << 6) | (m.u16(JoeyMem.TURN) & 0xff3f))
			f44b9e0(result & 3)
			f5bd050(0xf003, 0, 0, 0)
		0xf003: m.set_u32(0xa58260, m.u32(0xa58260) | 0x20)
		0xf004:
			var main_count := m.u8(data)
			var fusion_count := m.u8(data + 1)
			m.set_u16(0xa5501e, main_count)
			m.set_u16(0xa55020, 0)
			m.set_u16(0xa55022, fusion_count)
			m.copy(0xa54f42, data + 2, main_count * 2)
			m.copy(0xa55000, data + 2 + main_count * 2, fusion_count * 2)
			m.set_u32(0xa58260, m.u32(0xa58260) | 8)
		0xf005:
			f44b9d0(value | (m.u16(data + 2) << 16))
			m.set_u32(0xa58260, m.u32(0xa58260) | 16)
		0xf006: f48dd00(1, f402560(value + 0x9c4))
		0xf041: f5b93f0(value, m.u16(data + 2), m.u16(data + 4), m.u16(data + 6))
		0xf042: m.set_u32(0xa58260, m.u32(0xa58260) | 0x100)
		0xf051:
			m.set_u8(0xa55cea, 0)
			m.set_u32(0xa58260, m.u32(0xa58260) | 0x200)
		0xf052, 0xf055: m.set_u32(0xa58260, m.u32(0xa58260) | 0x400)
		0xf053, 0xf056:
			f5ba960(int(op == 0xf056), data)
			m.set_u8(0xa55ce9, m.u8(0xa55ce9) | 0x40)
			m.set_u32(0xa58260, m.u32(0xa58260) | 0x400)
		0xf054:
			m.copy(0xa55d28, data, 20)
			m.set_u8(0xa55cea, 0x80)
			m.set_u32(0xa58260, m.u32(0xa58260) | 0x200)
		0xf057: f598590(value, m.u16(data + 2), m.u16(data + 4) | (m.u16(data + 6) << 16))
		0xf058:
			if value == 0: f579890()
			elif value == 1: f579810()
		0xf059:
			var count := m.u8(data)
			m.set_u16(0xa55c94, ((count & 127) << 8) | (m.u16(0xa55c94) & 0x80ff))
			for i in count:
				m.set_u8(0xa55c96 + i, m.u8(data + 1 + i * 5))
				m.set_u32(0xa55ca8 + i * 4, m.u32(data + 2 + i * 5))
		0xf05a:
			m.copy(0xa55080, data, 20)
			f5ad710()
		0xf05b: m.set_u32(0xa58260, m.u32(0xa58260) | 0x40)
		0xf071:
			var bits := (m.u8(data) & 127) << 1
			var old := m.u16(0xa58298)
			m.set_u16(0xa58298, (bits | (old & 0xff01)) ^ (int((bits & 255) > 2) ^ (old & 1)))
			m.copy(0xa58264, data + 2, 40)
			m.set_u8(0xa58297, 0)
			m.set_u32(0xa58260, m.u32(0xa58260) | 0x80000)
		0xf072: f5ba310(value, m.u32(data + 2), m.u16(data + 10), m.u32(data + 6))
		0xf073:
			m.set_u32(0xa58260, m.u32(0xa58260) | 0x100000)
			var count := m.u16(0xa55c80)
			m.copy(0xa55b2c + count * 20, data, 20)
			if count > 1: m.copy(0xa55b18 + count * 20, data + 20, 20)
		0xf081, 0xf091:
			m.set_u32(0xa58278, 0)
			m.copy(0xa58264, data, size)
			m.set_u8(0xa58296 if op == 0xf081 else 0xa58295, 0)
			m.set_u32(0xa58260, m.u32(0xa58260) | (0x8000 if op == 0xf081 else 0x20000))
		0xf082, 0xf092:
			m.set_u32(0xa58260, m.u32(0xa58260) | (0x10000 if op == 0xf082 else 0x40000))
			m.copy(0xa55b40 + m.u8(0xa55c87) * 20, data, 20)
		0xf0a1:
			f5bcd60(m.u32(JoeyMem.MODE) & 1, value, data + 2, 8)
			m.set_u8(0xa57810, m.u8(0xa57810) | 1)
		0xf0a2:
			m.copy(0xa57822, data, 16)
			m.set_u32(0xa58260, m.u32(0xa58260) | 0x4000)
		_:
			if op != 0xef00: f5bd050(0xef00, 0, 0, 0)
			m.set_u16(JoeyMem.TURN, m.u16(JoeyMem.TURN) | 0x20)
			return 0
	return 1
