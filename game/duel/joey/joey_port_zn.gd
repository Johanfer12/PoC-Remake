class_name JoeyPortZN
extends JoeyPortZM
## Etapa6 L4: validadores compartidos de objetivos y resolución de equipos.


func f579c40(context: int, target: int) -> int:
	var p := target & 0xff
	var z := (target >> 8) & 0xff
	if (m.u8(context + 2) & 1) == p or z > 4: return 0
	if f56c510(p, z) == 0: return 0
	if (f4025d0(m.u16(context)) & 0xffff) == 22 and f56c460(p, z) != 0: return 0
	return int((m.u32(JoeyMem.zone(target & 1, z)) & 0xfff) != 0)


func f579ce0(context: int, target: int) -> int:
	var p := target & 0xff
	var z := (target >> 8) & 0xff
	var source := m.u16(context + 2)
	var at := JoeyMem.zone(target & 1, z)
	var index := m.u16(at) & 0xfff
	var skip := m.u16(JoeyMem.zone(source & 1, (source >> 1) & 0x1f) + 4) if (source & 0x3e) < 21 else 0
	var species := f56f6f0(p, z, skip) & 0xffff
	var attribute := f56f9e0(p, z) & 0xffff
	if z >= 5 or index == 0 or (m.u8(at + 6) & 2) == 0: return 0
	var id := f4022e0(m.u16(context)) & 0xffff
	match id:
		0x47:
			return int((f4022e0(index) & 0xffff) == 0x115 and (source & 1) == p and f56d660(p, z, 0x47) == 0)
		0x12c, 0x49e, 0x58e, 0x60e: return int(species == 15)
		0x12d: return int(attribute == 2)
		0x12e: return int(species == 3)
		0x12f, 0x136, 0x138, 0x139, 0x140, 0x290, 0x291, 0x412, 0x424, 0x4da, 0x4e9, 0x4ea, 0x521, 0x58b, 0x58c, 0x5a8, 0x5a9, 0x5aa, 0x60c: return 1
		0x130, 0x131: return int(species == 10)
		0x132, 0x29b: return int(attribute == 1)
		0x133: return int(species == 11)
		0x134: return int(attribute == 3)
		0x135: return int(species == 13)
		0x137: return int(species == 17)
		0x13a: return int(species == 1)
		0x13b: return int(species == 19)
		0x13c: return int((f4022e0(index) & 0xffff) in [0x3d, 0x3e, 0x4e1])
		0x13e: return int(species == 12)
		0x141: return int(species == 2)
		0x142: return int(species == 18)
		0x143: return int(attribute == 5)
		0x144, 0x3c2: return int(species == 7)
		0x145: return int(species == 9)
		0x146: return int(species == 16)
		0x147: return int(species == 14)
		0x28a, 0x422: return int((source & 1) == p)
		0x28b: return int((f4022e0(index) & 0xffff) == 0x16d)
		0x28d, 0x3f4: return int(attribute == 4)
		0x3f5: return int(attribute == 6)
		0x416, 0x417: return int(species != 7)
		0x42c, 0x5ea: return int((source & 1) != p)
		0x604: return int((f4022e0(index) & 0xffff) == 0x53b)
	return 0


func f57a470(context: int, target: int) -> int:
	if f579ce0(context, target) == 0: return 0
	return int(f56c510(target & 0xff, (target >> 8) & 0xff) != 0)


func f583470(context: int, slot: int, out: int) -> int:
	var ref := m.u16(context + 6 + slot * 2)
	var p := ref & 1
	var z := (ref & 0xff) >> 4
	# El PE escribe la referencia incluso si el contador o la identidad no coinciden.
	if out != 0: m.set_u32(out, (z << 8) | (ref & 0xf))
	if (m.u16(context + 4) >> 13) <= slot: return 0
	var entry := m.u32(JoeyMem.zone(p, z))
	if (entry & 0xfff) == 0: return 0
	return int(((entry >> 12) & 1) + ((entry >> 24) & 0x7f) * 2 == (ref >> 8))


func f583f30() -> int:
	return 0


func f584500(context: int) -> int:
	var source := m.u16(context + 2)
	if (m.u16(JoeyMem.zone(source & 1, (source >> 1) & 0x1f)) & 0xfff) != m.u16(context): return 0
	var out := m.local(4)
	if f583470(context, 0, out) != 0 and f57a470(context, m.u32(out)) != 0:
		if (f4025d0(m.u16(context)) & 0xffff) == 21 and (m.u16(context + 4) & 4) != 0:
			m.set_u16(context + 4, m.u16(context + 4) | 8)
			return 0
		f574990(source & 1, ((source >> 1) & 0x1f) << 8 | (source & 1), m.u32(out))
		if (f4022e0(m.u16(context)) & 0xffff) in [0x3c2, 0x5a8]:
			f5b9170((source << 15) | 0x88, (source >> 1) & 0x1f, m.u16(context + 8), 0)
	else:
		m.set_u8(context + 4, m.u8(context + 4) | 8)
	# Todos los caminos definen AX=0; EAX alto contiene residuos de llamadas.
	return 0
