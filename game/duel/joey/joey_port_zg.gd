class_name JoeyPortZG
extends JoeyPortZF
## Dependencias comunes de seleccion IA/H, desde los cuerpos de Joey.


func f583440(effect: int, index: int) -> int:
	var value := m.u8(effect + 6 + index * 2)
	return (value & 15) | ((value >> 4) << 8)


func f592a50(effect: int, reference: int) -> int:
	if effect != 0:
		var flags := m.u16(effect + 4)
		m.set_u16(effect + 6 + (flags >> 13) * 2, reference)
		m.set_u16(effect + 4, ((flags & 0xe000) + 0x2000) ^ (flags & 0x1fff))
	return 0


func f5929f0(effect: int, p: int, z: int) -> int:
	var entry := m.u32(JoeyMem.zone(p, z))
	var identity := ((entry >> 12) & 1) + ((entry >> 24) & 127) * 2
	f592a50(effect, (identity << 8) | ((z << 4) & 0xff) | (p & 15))
	return 0


func f592a90(effect: int, p: int, z: int) -> int:
	if (m.u8(JoeyMem.MODE) ^ m.u8(effect + 2)) & 1 == 0:
		f44ef40(1)
	var quotient := _cdiv(_s32(z), 5)
	var remainder := _s32(z) - quotient * 5
	f5b9170((m.u16(effect + 2) << 15) | 8, p, ((remainder & 255) << 8) | ((quotient * 5) & 255), 0)
	f5929f0(effect, p, z)
	return 0


func f59dc50(effect: int, p: int, z: int) -> int:
	if effect == 0:
		return 0
	var row := _s32(f59dbe0(m.u16(effect)))
	if row < 0:
		return 1
	var address := m.u32(0x5ed0b0 + row * 24)
	return 1 if address == 0 else _jy_effect(address, [effect, ((z & 255) << 8) | (p & 255)])


func f59dca0(effect: int) -> int:
	var row := _s32(f59dbe0(m.u16(effect)))
	if row < 0:
		return 0
	var address := m.u32(0x5ed0b0 + row * 24)
	if address == 0:
		return 0
	var count := 0
	for p in range(2):
		for z in range(11):
			if _jy_effect(address, [effect, (z << 8) | p]) != 0:
				count += 1
	return count


func f59dd20(effect: int, p: int) -> int:
	var row := _s32(f59dbe0(m.u16(effect)))
	if row < 0:
		return 0
	var address := m.u32(0x5ed0b0 + row * 24)
	if address == 0:
		return 0
	var count := 0
	for z in range(11):
		if _jy_effect(address, [effect, (z << 8) | (p & 255)]) != 0:
			count += 1
	return count
