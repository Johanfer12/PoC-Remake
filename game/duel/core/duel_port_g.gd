class_name DuelPortG
extends DuelPortF
## Modulo del porte del motor de duelo (ver docs/duel/PORTING.md).
## 0x545959 y 0x545aa6 son entradas internas de 0x545930 y 0x545a70:
## ASM 0x545953/0x545a9e salta a ellas con registros ya preparados; no son APIs.
## No hay punteros absolutos a esas dos direcciones en la imagen PE del original.
## 0x547c60/0x547c80 están portadas en DuelPortF; no se duplican aquí.

## FUN_005438c0: detecta un monstruo visible con efecto de la lista original.
func f5438c0(p: int) -> int:
	for z in range(5):
		var zone := DuelMem.zone(p & 1, z)
		var index := m.u16(zone) & 0xfff
		if index != 0 and (m.u8(zone + 6) & 2) != 0 and f541ce0(f401a70(index)) != 0:
			return 1
	return 0

## FUN_00543930: comprueba los atributos de todos los monstruos visibles.
func f543930(p: int) -> int:
	for z in range(5):
		var zone := DuelMem.zone(p & 1, z)
		if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0:
			var attribute := f545e70(p, z)
			if attribute != 0 and (attribute < 3 or attribute == 6):
				return 0
	return 1

## FUN_00543a50: cuenta magias/trampas visibles de una clase.
func f543a50(p: int, kind: int) -> int:
	var count := 0
	for z in range(5, 10):
		var zone := DuelMem.zone(p & 1, z)
		var index := m.u32(zone) & 0xfff
		if index != 0 and (m.u8(zone + 6) & 2) != 0 and ctype(index) == (kind & 0xffff):
			count += 1
	return count

## FUN_00543ab0: cuenta cartas del cementerio de una clase.
func f543ab0(p: int, kind: int) -> int:
	var base := DuelMem.pl(p & 1)
	var count := 0
	for i in range(m.u8(base + 4)):
		if ctype(m.u16(base + 0x8f4 + i * 4) & 0xfff) == (kind & 0xffff):
			count += 1
	return count

## FUN_00543b40: número de zonas de magia/trampa ocupadas.
func f543b40(p: int) -> int:
	var count := 0
	for z in range(5, 10):
		count += int((m.u32(DuelMem.zone(p & 1, z)) & 0xfff) != 0)
	return count

## FUN_00543b90: cuenta cartas colocadas y habilitadas en un bloque de campo.
func f543b90(base: int, p: int, id: int) -> int:
	var count := 0
	for z in range(11):
		var info := base + (p & 1) * 0xd54 + 0xa6 + z * 0x94
		var index := m.u16(info - 0x8e) & 0xfff
		if index != 0 and (m.u32(DuelMem.zone(p & 1, z)) & 0xfff) != 0 and (m.u16(info - 0x88) & 2) == 0 and (m.u16(info) & 0x400) == 0 and (m.u16(info) & 0x200) != 0:
			if id == 0 or f401a70(index) == s16(id):
				count += 1
	return count

## FUN_00543c60: posición de una carta colocada y habilitada, incluyendo campo.
func f543c60(p: int, id: int) -> int:
	for z in range(5, 11):
		var zone := DuelMem.zone(p & 1, z)
		if (m.u16(zone) & 0xfff) == f401ad0(id) and (m.u16(zone + 6) & 2) == 0 and (m.u16(zone + 0x8e) & 0x400) == 0 and (m.u16(zone + 0x8e) & 0x200) != 0:
			return z
	return -1

## FUN_00543cd0: cuenta las cartas habilitadas del campo real.
func f543cd0(p: int, id: int) -> int:
	return f543b90(0xa11944, p, id)

## FUN_00543dd0: busca una referencia exacta en las asociaciones de zona.
func f543dd0(location: int, reference: int) -> int:
	var zone := DuelMem.zone(location & 1, (location & 0xffff) >> 8)
	for i in range(m.u16(zone + 0x88)):
		if m.s16(zone + 8 + i * 2) == s16(reference):
			return 1
	return 0

## FUN_00544100: comprueba si un monstruo puede cambiar de posición.
func f544100(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	if (m.u8(DuelMem.pl(p & 1) + 7) & 0x20) != 0:
		return 0
	if (m.u32(zone) & 0xfff) == 0 or (m.u16(zone + 6) & 0x600) != 0 or f545620(p, z, 0x15c) != 0 or f545620(p, z, 0x4dc) != 0:
		return 0
	var id := f401a70(m.u16(zone) & 0xfff)
	if f542f30(0, 0x536) - int(id == 0x536) + f542f30(1, 0x536) >= 1:
		return 0
	if f542f30(1, 0x148) + f542f30(0, 0x148) > 0 and (m.u8(zone + 6) & 2) != 0 and f545c40(p, z) == 1:
		return 0
	return 1

## FUN_00544210: comprueba si una carta admite tributo.
func f544210(p: int, z: int) -> int:
	var index := m.u16(DuelMem.zone(p & 1, z)) & 0xfff
	if index == 0:
		return 0
	var id := f401a70(index)
	if id > 0x77f and id < 2000:
		return 0
	return f543390(p, z)

## FUN_00544280: cuenta tributos válidos salvo la zona indicada.
func f544280(p: int, skip: int) -> int:
	if f542f30(0, 0x58a) >= 1 or f542f30(1, 0x58a) >= 1:
		return 0
	var count := 0
	for z in range(5):
		if (m.u16(DuelMem.zone(p & 1, z)) & 0xfff) != 0 and z != skip and f544210(p, z) != 0:
			count += 1
	return count

## FUN_005449b0: busca una entrada completa de carta en el cementerio.
func f5449b0(p: int, entry: int) -> int:
	var base := DuelMem.pl(p & 1)
	for i in range(m.u8(base + 4)):
		if m.u32(entry) == m.u32(base + 0x8f4 + i * 4):
			return 1
	return 0

## FUN_00544b70: cuenta monstruos en el cementerio.
func f544b70(p: int) -> int:
	var base := DuelMem.pl(p & 1)
	var count := 0
	for i in range(m.u8(base + 4)):
		count += int(ctype(m.u16(base + 0x8f4 + i * 4) & 0xfff) < 0x15)
	return count

## FUN_00544be0: cuenta monstruos en la mano.
func f544be0(p: int) -> int:
	var base := DuelMem.pl(p & 1)
	var count := 0
	for i in range(m.u8(base + 2)):
		count += int(ctype(m.u16(base + 0x674 + i * 4) & 0xfff) < 0x15)
	return count

## FUN_00544eb0: primera trampa de la mano.
func f544eb0(p: int) -> int:
	return _g_hand_kind(p, 0x15, false)

## FUN_00544f30: primera magia de la mano.
func f544f30(p: int) -> int:
	return _g_hand_kind(p, 0x16, false)

## FUN_00544fb0: primera magia de la mano que no sea de campo.
func f544fb0(p: int) -> int:
	return _g_hand_kind(p, 0x16, true)

func _g_hand_kind(p: int, kind: int, exclude_field: bool) -> int:
	var base := DuelMem.pl(p & 1)
	for i in range(m.u8(base + 2)):
		var index := m.u16(base + 0x674 + i * 4) & 0xfff
		if index != 0 and ctype(index) == kind and (not exclude_field or csub(index) != 2):
			return i
	return -1

## FUN_005451f0: referencia de copia de estadísticas, conservando la mitad alta original.
func f5451f0(p: int, z: int) -> int:
	var offset := (p & 1) * 0xd54 + z * 0x94
	var result := offset
	for i in range(m.u16(0xa119e4 + offset)):
		result = (result & 0xffff0000) | m.u16(0xa11964 + offset + i * 2)
		if m.u8(0xa119a4 + offset + i * 2) == 5:
			return result
	return (result & 0xffff0000) | 0xffff

## FUN_00545510: cuenta asociaciones de equipo y copia de estadísticas.
func f545510(p: int, z: int, only_spell: int, only_equip: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var count := 0
	for i in range(m.u16(zone + 0x88)):
		var tag := m.u8(zone + 0x48 + i * 2)
		if tag == 5:
			count += 1
		elif tag == 1:
			var reference := m.u16(zone + 8 + i * 2)
			var index := m.u16(DuelMem.zone(reference & 1, reference >> 8)) & 0xfff
			if index == 0:
				continue
			var accepted := only_spell == 0 or ctype(index) == 0x16
			if only_equip != 0 and (ctype(index) < 0x15 or ctype(index) > 0x16 or csub(index) != 3) and not accepted:
				continue
			count += 1
	return count

## FUN_00545810: busca una asociación directa de efecto por id.
func f545810(p: int, z: int, id: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	for i in range(m.u16(zone + 0x88)):
		if m.s16(zone + 0x48 + i * 2) == 3 and f401a70(m.u16(zone + 8 + i * 2)) == s16(id):
			return 1
	return 0

## FUN_00545890: índice de asociación de un efecto por id.
func f545890(p: int, z: int, id: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	for i in range(m.u16(zone + 0x88)):
		var tag := m.u8(zone + 0x48 + i * 2)
		var reference := m.u16(zone + 8 + i * 2)
		if tag == 0 or tag > 3:
			continue
		var index := reference if tag == 3 else (m.u16(DuelMem.zone(reference & 1, reference >> 8)) & 0xfff)
		if f401a70(index) == s16(id):
			return i
	return -1

## FUN_00545930: busca una asociación de zona de tipo 1 o 2.
func f545930(p: int, z: int, target_p: int, target_z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	if (m.u32(zone) & 0xfff) == 0:
		return -1
	for i in range(m.u16(zone + 0x88)):
		var tag := m.u8(zone + 0x48 + i * 2)
		var reference := m.u16(zone + 8 + i * 2)
		if tag > 0 and tag < 3 and (reference & 0xff) == target_p and (reference >> 8) == target_z:
			return i
	return -1

## FUN_005459b0: cuenta monstruos visibles afectados por un efecto.
func f5459b0(p: int, id: int) -> int:
	var count := 0
	for z in range(5):
		var zone := DuelMem.zone(p & 1, z)
		if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0 and f545620(p, z, id) != 0:
			count += 1
	return count

## FUN_00545a10: primer monstruo visible afectado por un efecto.
func f545a10(p: int, id: int) -> int:
	for z in range(5):
		var zone := DuelMem.zone(p & 1, z)
		if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0 and f545620(p, z, id) != 0:
			return z
	return -1

## FUN_00545a70: jugador cuyo campo modifica las estadísticas del monstruo.
func f545a70(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u32(zone) & 0xfff
	if index == 0 or z >= 5 or (m.u8(zone + 6) & 2) == 0:
		return -1
	var prop := f401a20(index)
	var id := f401a70(index)
	if id in [0x52e, 0x531] and f543fc0() == 0x14d:
		return -1
	for owner in range(2):
		var field := DuelMem.zone(owner, 10)
		var field_index := m.u16(field) & 0xfff
		if field_index == 0 or (m.u8(field + 0x8f) & 4) != 0 or (m.u8(field + 6) & 2) == 0:
			continue
		var field_id := f401a70(field_index) & 0xffff
		if field_id == 0x42d:
			if (m.u8(zone + 6) & 1) != 0:
				return owner
		elif field_id >= 0x149 and field_id <= 0x14e:
			if m.s16(0x59e268 + (((prop >> 20) & 0x1f) + (field_id - 0x149) * 0x18) * 2) != 0:
				return owner
		elif field_id >= 0x465 and field_id <= 0x46a:
			if m.s16(0x59e388 + ((prop >> 29) - 9000 + field_id * 8) * 2) != 0:
				return owner
	return -1

## FUN_00545e70: atributo actual, incluida una modificación por equipo.
func f545e70(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0:
		return 0
	var attribute := f401a20(index) >> 29
	if z < 5 and (m.u8(zone + 6) & 2) != 0:
		for i in range(m.u16(zone + 0x88)):
			var reference := m.u16(zone + 8 + i * 2)
			var equip := DuelMem.zone(reference & 1, reference >> 8)
			var equip_index := m.u16(equip) & 0xfff
			if m.u8(zone + 0x48 + i * 2) == 1 and equip_index != 0 and (m.u8(equip + 0x8f) & 4) == 0 and f542f30(0, 0x601) == 0 and f542f30(1, 0x601) == 0 and (m.u16(0xa133ec) & 0x100) == 0 and m.s8(0xa133ec) >= 0 and f401a70(equip_index) == 0x5a8:
				attribute = m.u16(equip + 0x8e) >> 11
	return attribute

## FUN_00545240: valida los equipos al cambiar la carta o su posición.
func f545240(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	if (m.u8(zone + 6) & 2) == 0:
		f54c930(p, z)
		f54ca50(p, z, 0)
		return 0
	var effect := m.local(20)
	var valid_ids := [300, 0x12d, 0x12e, 0x130, 0x131, 0x132, 0x133, 0x134, 0x135, 0x137, 0x13a, 0x13b, 0x13c, 0x13e, 0x141, 0x142, 0x143, 0x144, 0x145, 0x146, 0x147, 0x28b, 0x28d, 0x29b, 0x3c2, 0x3f4, 0x3f5, 0x416, 0x417, 0x422, 0x49e, 0x522, 0x58e, 0x604, 0x60e]
	var i := 0
	while i < m.u16(zone + 0x88):
		var reference := m.u16(zone + 8 + i * 2)
		m.clear(effect, 20)
		if m.u8(zone + 0x48 + i * 2) == 1:
			var equip := DuelMem.zone(reference & 1, reference >> 8)
			var index := m.u16(equip) & 0xfff
			if f401a70(index) in valid_ids:
				m.set_u16(effect, index)
				m.set_u16(effect + 2, (((reference >> 8) & 0x3f) << 4) | (reference & 1))
				if f54fc80(effect, ((z & 0xff) << 8) | (p & 0xff)) == 0:
					f54e250(reference & 0xff, reference >> 8, 1)
		i += 1
	return 0

## FUN_00545fb0: valida un equipo contra una ubicación de destino.
func f545fb0(p: int, z: int, target_p: int, target_z: int) -> int:
	var effect := m.local(20)
	m.clear(effect, 20)
	m.set_u16(effect, m.u16(DuelMem.zone(p & 1, z)) & 0xfff)
	m.set_u32(effect + 2, p & 1)
	return f54fc80(effect, ((target_z & 0xff) << 8) | (target_p & 0xff))

## FUN_00546020: busca el monstruo que tiene asociada una carta de equipo.
func f546020(p: int, z: int) -> int:
	if (m.u32(DuelMem.zone(p & 1, z)) & 0xfff) == 0:
		return 0xffff
	for owner in range(2):
		for slot in range(5):
			if f545930(owner, slot, p, z) >= 0:
				return (slot << 8) | owner
	return 0xffff

## FUN_00547ba0: comprueba bonificación contra atributo de la tabla original.
func f547ba0(p: int, z: int, target_p: int, target_z: int) -> int:
	var target := DuelMem.zone(target_p & 1, target_z)
	var zone := DuelMem.zone(p & 1, z)
	for row in range(6):
		if target_z < 5 and (m.u8(target + 6) & 2) != 0 and (f401a70(m.u16(target) & 0xfff) & 0xffff) == m.s16(0x59e3e8 + row * 16) and z < 5 and (m.u8(zone + 6) & 2) != 0:
			if m.u16(0x59e3e8 + (f545e70(p, z) + row * 8) * 2) != 0:
				return 1
	return 0

## FUN_0054c6e0: determina el controlador de una carta tras efectos de control.
func f54c6e0(p: int, z: int, temporary: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var entry := f5419b0(p, 0, z)
	var owner := ((m.u8(zone + 0x90) >> 1) ^ (m.u32(entry) >> 12)) & 1
	for i in range(m.u16(zone + 0x88)):
		var reference := m.u16(zone + 8 + i * 2)
		var tag := m.u8(zone + 0x48 + i * 2)
		var extra := m.u8(zone + 0x49 + i * 2)
		if tag == 1:
			var equip := DuelMem.zone(reference & 1, reference >> 8)
			var index := m.u16(equip) & 0xfff
			if index != 0 and (m.u8(equip + 6) & 2) != 0 and f401a70(index) in [0x42c, 0x5ea] and (m.u8(equip + 0x8f) & 4) == 0:
				owner = reference & 0xff
		elif tag in [3, 0xd, 0xe]:
			var id := f401a70(reference) & 0xffff
			if id in [0x42c, 0x228, 0x280, 0x5ea] or (id in [0x403, 0x4e7] and temporary == 0):
				owner = extra & 1
	return owner

## FUN_0054c860: emite el comando 0x86 conservando los tres argumentos reenviados.
func f54c860(p: int, a: int, b: int, c: int) -> int:
	issue((0x8000 if p != 0 else 0) | 0x86, a, b, c)
	return 0

## FUN_0054c930: convierte el último equipo de control en asociación de efecto.
func f54c930(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	for i in range(m.u16(zone + 0x88) - 1, -1, -1):
		if m.u8(zone + 0x48 + i * 2) != 1:
			continue
		var reference := m.u16(zone + 8 + i * 2)
		var equip := DuelMem.zone(reference & 1, reference >> 8)
		var index := m.u16(equip) & 0xfff
		if index != 0 and (m.u8(equip + 6) & 2) != 0 and (m.u8(equip + 0x8f) & 4) == 0 and f401a70(index) in [0x42c, 0x5ea]:
			issue((0x8000 if p != 0 else 0) | 0x4d, ((i & 0xff) << 8) | (z & 0xff), index, ((reference & 0xff) << 8) | 0xd)
			break
	return 0

## FUN_0054cc10: recorre efectos de campo aislando temporalmente sus monstruos.
func f54cc10(source: int, p: int, both: int, include_spells: int, eligible_only: int) -> int:
	var saved: Array[int] = []
	saved.resize(10)
	for turn in range(both + 1):
		var player := p if turn == 0 else 1 - p
		for z in range(5):
			var zone := DuelMem.zone(player & 1, z)
			saved[player * 5 + z] = m.u16(zone) & 0xfff
			m.set_u32(zone, m.u32(zone) & 0xfffff000)
	for turn in range(both + 1):
		var player := p if turn == 0 else 1 - p
		for z in range(11 if include_spells != 0 else 5):
			var zone := DuelMem.zone(player & 1, z)
			if z < 5:
				m.set_u32(zone, m.u32(zone) ^ ((saved[player * 5 + z] ^ m.u32(zone)) & 0xfff))
			if eligible_only == 0 or f54f9f0(player, z) != 0:
				f555570(player, z)
				f56e3b0(source, player, z)
			if z < 5:
				m.set_u32(zone, m.u32(zone) & 0xfffff000)
	for turn in range(both + 1):
		var player := p if turn == 0 else 1 - p
		for z in range(5):
			var zone := DuelMem.zone(player & 1, z)
			m.set_u32(zone, m.u32(zone) ^ ((saved[player * 5 + z] ^ m.u32(zone)) & 0xfff))
	return 0

## FUN_0054cec0: devuelve una carta del campo, destruyendo las fichas.
func f54cec0(p: int, z: int, entry: int) -> int:
	var id := f401a70(m.u16(entry) & 0xfff)
	if id > 0x77f and id < 2000:
		f54cf50(1 - p, p, z, entry)
	else:
		issue((0x8000 if p != 0 else 0) | 0x7e, m.u16(entry), m.u16(entry + 2), z)
		f54ca50(p, z, 1)
	return 0

## FUN_0054cf50: destruye una carta por batalla y programa sus efectos al morir.
func f54cf50(source_p: int, p: int, z: int, entry: int) -> int:
	if z > 4:
		return 0
	var id := f401a70(m.u16(entry) & 0xfff)
	var mask := 0x8000 if p != 0 else 0
	if id > 0x77f and id < 2000:
		m.set_u32(entry, m.u32(entry) | 0x200000)
		issue(mask | 0x7a, z, 0, 0)
		f54ca50(p, z, 1)
		return 0
	if f543010(0, 0x453) - int(id == 0x453) + f543010(1, 0x453) > 0:
		return f54cec0(p, z, entry)
	m.set_u16(0xa1608a, 0x13)
	m.set_u32(entry, m.u32(entry) | 0x200000)
	issue(mask | 0x7a, z, 0, 0)
	issue(mask | 0x7d, m.u16(entry), m.u16(entry + 2), 0)
	if ctype(m.u16(entry) & 0xfff) < 0x15:
		var flag := DuelMem.pl(p & 1) + 0x11
		m.set_u8(flag, m.u8(flag) | 0x80)
	var effect_ids := [0x454, 0x136, 0x2f, 0x12f, 0x138, 0x139, 0x140, 0x412, 0x1de, 0x23d, 0x414, 0x463, 0x456, 0x45a, 0x45b, 0x45d, 0x45f, 0x460, 0x57d, 0x4d9, 0x4da, 0x4e9]
	var trigger := id in effect_ids or (id in [0x1cd, 0x45c] and (m.u8(DuelMem.zone(p & 1, z) + 7) & 0x10) == 0)
	if id == 0x5ea and source_p != p:
		f54eed0(p, m.u16(entry) & 0xfff, 0xe)
		issue(mask | 0x4c, 1, 0, 0)
	if trigger:
		var current := m.u16(0xa133f2) & 1
		var own_location := (((m.u32(0xa114c0) >> 8) & 7) << 8) | current if p == current else 0xffff
		var other_location := ((((m.u32(0xa114c0) >> 11) & 0xff) << 8) | (1 - current)) & 0x7ff if p == 1 - current else 0xffff
		var descriptor := ((((m.u16(0xa1608a) & 0x3f) << 6) | (m.u32(entry) & 0xfffff00d)) << 19) | (m.u32(entry) & 0xfff) | 0x6e0000
		f53baa0(descriptor & 0xffffffff, (other_location << 16) | own_location)
	f56e2e0(p, 1)
	f54ca50(p, z, 1)
	return 0

## FUN_0054d2d0: cambia boca arriba/abajo y prepara los efectos de volteo.
func f54d2d0(p: int, z: int, trigger_effect: int, visual_effect: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0:
		return 0
	var flip := z < 5 and f541d10(f401a70(index), 0) != 0 and f551c40(p, index, z) != 0 and f542f30(0, 0x5fa) == 0 and f542f30(1, 0x5fa) == 0
	var mask := 0x8000 if p != 0 else 0
	issue(mask | 0x80, z, ~(m.u8(zone + 6) >> 1) & 1, int(visual_effect != 0 and flip))
	if z < 5 and (m.u8(zone + 6) & 2) == 0:
		issue(mask | 0x92, z, 2, 0)
		if trigger_effect != 0 and flip:
			f53baa0(((((z & 0x1f) | (p << 15) | 0x1640) << 16) | index) & 0xffffffff, 0)
	return 0

## FUN_0054d420: cambia la posición y prepara efectos dependientes de ella.
func f54d420(p: int, z: int, position: int, flip_effect: int, mode: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if z > 4 or index == 0:
		return 0
	issue((0x8000 if p != 0 else 0) | 0x7f, z, position, mode)
	var id := f401a70(index)
	var trigger := id in [0x77, 0xa1, 0x1f0] if (m.u8(zone + 6) & 1) == 0 else id == 0x5e
	var descriptor := ((((z & 0x1f) | (p << 15) | 0x1440) << 16) | index) & 0xffffffff
	if trigger and f551c40(p, index, z) != 0:
		f53baa0(descriptor, 0)
	if flip_effect != 0 and position != 0 and (m.u8(zone + 6) & 2) == 0 and f541d10(id, 0) != 0 and f542f30(0, 0x5fa) == 0 and f542f30(1, 0x5fa) == 0:
		f53baa0(descriptor, 0)
	return 0

## FUN_0054d570: mueve una carta a una zona vacía, aplicando daños de control.
func f54d570(_source: int, origin: int, target: int) -> int:
	var p := origin & 0xff
	var z := (origin >> 8) & 0xff
	var target_p := target & 0xff
	var target_z := (target >> 8) & 0xff
	var zone := DuelMem.zone(origin & 1, z)
	if (m.u32(zone) & 0xfff) == 0 or (m.u32(DuelMem.zone(target & 1, target_z)) & 0xfff) != 0:
		return 0
	issue((0x8000 if p != 0 else 0) | 0x83, origin, target, 0)
	if p != target_p and (m.u8(zone + 6) & 2) != 0 and target_z < 5 and (m.u8(zone + 7) & 0x10) != 0:
		var id := f401a70(m.u16(zone) & 0xfff)
		if id in [0x1e3, 0x222]:
			f54eed0(target_p, m.u16(zone) & 0xfff, target_z)
			if id == 0x1e3:
				f54ef90(target_p, 2000)
			else:
				f54f0d0(p, 3000)
			issue((0x8000 if target_p != 0 else 0) | 0x94, target_z, 0, 0)
	return 0

## FUN_0054d6c0: intercambia dos zonas y aplica daños de cambio de control.
func f54d6c0(source: int, origin: int, target: int) -> int:
	var p := origin & 0xff
	var z := (origin >> 8) & 0xff
	var target_p := target & 0xff
	var target_z := (target >> 8) & 0xff
	var zone := DuelMem.zone(origin & 1, z)
	var other := DuelMem.zone(target & 1, target_z)
	var index := m.u16(zone) & 0xfff
	var other_index := m.u16(other) & 0xfff
	if index == 0 or other_index == 0:
		return 0
	issue((0x8000 if source != 0 else 0) | 0x85, origin, target, 0)
	for direction in range(2):
		var src_zone := zone if direction == 0 else other
		var dst_z := target_z if direction == 0 else z
		var dst_p := target_p if direction == 0 else p
		var src_p := p if direction == 0 else target_p
		var src_index := index if direction == 0 else other_index
		var id := f401a70(src_index)
		if (m.u8(src_zone + 6) & 2) != 0 and id in [0x1e3, 0x222] and dst_z < 5 and (m.u8(src_zone + 7) & 0x10) != 0:
			# El primer ramal original pasa el jugador como zona para 0x1e3.
			f54eed0(dst_p, src_index, dst_p if direction == 0 and id == 0x1e3 else dst_z)
			if id == 0x1e3:
				f54ef90(dst_p, 2000)
			else:
				f54f0d0(src_p, 3000)
			issue((0x8000 if dst_p != 0 else 0) | 0x94, dst_z, 0, 0)
	return 0

## FUN_0054d900: emite retirada de una carta de la mano.
func f54d900(p: int, a: int, b: int) -> int:
	issue((0x8000 if p != 0 else 0) | 0xc3, a, b, 0)
	return 0

## FUN_0054d930: envía una carta de la mano al cementerio o la excluye por efecto.
func f54d930(p: int, hand: int, entry: int, trigger: int, a: int, b: int) -> int:
	var mask := 0x8000 if p != 0 else 0
	if f543010(0, 0x453) > 0 or f543010(1, 0x453) > 0:
		issue(mask | 0xc1, hand, a, b)
		return 0
	issue(mask | 0xc0, hand, a, b)
	var id := f401a70(m.u16(entry) & 0xfff)
	var activate := id in [0x1de, 0x412, 0x4da] or (id in [0x215, 0x1ce] and trigger != 0 and ((m.u32(entry) >> 12) & 1) == p)
	if activate:
		f53baa0((((m.u32(entry) & 0xfffff74d) << 19) | (m.u32(entry) & 0xfff) | 0x3a6e0000) & 0xffffffff, 0)
	f56e050(1 - p, 1)
	f56e2e0(p, 1)
	return 0

## FUN_0054da50: retira del cementerio una carta por id.
func f54da50(p: int, id: int) -> int:
	return int(_g_find_list_command(p, id, 4, 0x8f4, 0xd2, 0) >= 0)

## FUN_0054daf0: retira del cementerio y copia la entrada encontrada.
func f54daf0(p: int, id: int, out: int) -> int:
	return int(_g_find_list_command(p, id, 4, 0x8f4, 0xd3, out) >= 0)

## FUN_0054dba0: emite retirada del cementerio por entrada completa.
func f54dba0(p: int, entry: int) -> int:
	issue((0x8000 if p != 0 else 0) | 0xd4, m.u16(entry), m.u16(entry + 2), 0)
	return 0

## FUN_0054dbd0: extrae una carta del mazo y copia su entrada.
func f54dbd0(p: int, id: int, out: int) -> int:
	return _g_find_list_command(p, id, 3, 0x7b4, 0x65, out)

## FUN_0054dc60: emite retirada del mazo por id.
func f54dc60(p: int, id: int) -> int:
	return int(_g_find_list_command(p, id, 3, 0x7b4, 100, 0) >= 0)

func _g_find_list_command(p: int, id: int, count_offset: int, list_offset: int, op: int, out: int) -> int:
	var base := DuelMem.pl(p & 1)
	for i in range(m.u8(base + count_offset)):
		var entry := base + list_offset + i * 4
		if f401a70(m.u16(entry) & 0xfff) == s16(id):
			if out != 0:
				f541cb0(out, entry)
			issue((0x8000 if p != 0 else 0) | op, m.u16(entry), m.u16(entry + 2), 0)
			return i
	return -1

## FUN_0054e340: excluye una carta del campo, distinguiendo fichas y modos.
func f54e340(p: int, z: int, mode: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0 or (m.u16(zone + 0x90) & 4) != 0:
		return 0
	m.set_u16(zone + 0x90, m.u16(zone + 0x90) | 4)
	var id := f401a70(index)
	var op := (0x7b if mode == 0 else 0x7c) if id < 0x780 or id > 1999 else 0x79
	issue((0x8000 if p != 0 else 0) | op, z, 1, 0)
	if z < 5:
		f54ca50(p, z, 1)
	f54dcf0(p, z)
	return 0

## FUN_0054e420: devuelve una carta del campo a la mano y notifica efectos.
func f54e420(p: int, z: int, argument: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0 or (m.u16(zone + 0x90) & 4) != 0:
		return 0
	m.set_u16(zone + 0x90, m.u16(zone + 0x90) | 4)
	var id := f401a70(index)
	if id < 0x780 or id > 1999:
		issue((0x8000 if p != 0 else 0) | 0x81, z, argument, 0)
	else:
		f54e250(p, z, 1)
	if z < 5:
		f54ca50(p, z, 0)
		f56a380(1 - (m.u8(0xa133f2) & 1), 0x1b, ((z & 0xff) << 8) | (p & 0xff))
	f54dcf0(p, z)
	return 0

## FUN_0054e510: devuelve una carta del campo al mazo.
func f54e510(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0 or (m.u16(zone + 0x90) & 4) != 0:
		return 0
	m.set_u16(zone + 0x90, m.u16(zone + 0x90) | 4)
	var id := f401a70(index)
	if id < 0x780 or id > 1999:
		issue((0x8000 if p != 0 else 0) | 0x82, z, 0, 0)
	else:
		f54e250(p, z, 1)
	if z < 5:
		f54ca50(p, z, 0)
	f54dcf0(p, z)
	return 0

## FUN_0054e5d0: devuelve todos los monstruos al mazo y baraja si corresponde.
func f54e5d0(p: int, shuffle: int) -> int:
	for owner in [1 - p, p]:
		for z in range(5):
			f54e510(owner, z)
		if shuffle != 0 and f5431b0(owner) > 0:
			issue((0x8000 if owner != 0 else 0) | 0x60, 1, 0, 0)
	return 0

## FUN_0054e640: cambia orientación sin efecto visual de volteo.
func f54e640(p: int, z: int, effect: int) -> int:
	return f54d2d0(p, z, effect, 0)

## FUN_0054e660: cambia posición con el modo normal.
func f54e660(p: int, z: int, position: int, flip_effect: int) -> int:
	return f54d420(p, z, position, flip_effect, 0)

## FUN_0054e680: descarta una posición de mano, reenviando los argumentos de pila.
func f54e680(p: int, hand: int, trigger: int, argument: int) -> int:
	return f54d930(p, hand, f5419b0(p, 0xb, hand), trigger, argument, 0)

## FUN_0054e6b0: devuelve el control calculado a su jugador correspondiente.
func f54e6b0(p: int, z: int) -> int:
	if (m.u32(DuelMem.zone(p & 1, z)) & 0xfff) == 0:
		return 0
	var owner := f54c6e0(p, z, 0)
	if owner != p:
		var target := f543360(owner)
		if target == -1:
			f54e250(p, z, 1)
		else:
			f54d570(p, ((z & 0xff) << 8) | (p & 0xff), ((target & 0xff) << 8) | (owner & 0xff))
		# Kaiba (550d90) devuelve 1 tras devolver el monstruo y corta el recorrido.
		# En Yugi la funcion es void y nadie lee el resultado.
		return int(rules_game != "yugi")
	return 0

## FUN_0054e730: asocia una carta de equipo y trata la excepción de 0x547.
func f54e730(p: int, origin: int, target: int) -> int:
	var origin_z := (origin >> 8) & 0xff
	var target_z := (target >> 8) & 0xff
	var target_zone := DuelMem.zone(target & 1, target_z)
	var index := m.u16(target_zone) & 0xfff
	issue((0x8000 if p != 0 else 0) | 0x84, origin, target, f401a70(m.u16(DuelMem.zone(origin & 1, origin_z)) & 0xfff))
	if f401a70(index) == 0x547:
		f54eed0(target & 0xff, index, target_z)
		f54e250(origin & 0xff, origin_z, 1)
		if f401a70(m.u16(DuelMem.zone(origin & 1, origin_z)) & 0xfff) == 0x488:
			f54e250(target & 0xff, target_z, 1)
	else:
		f56a380(1 - p, 0x19, ((target << 16) | (origin & 0xffff)) & 0xffffffff)
	return 0

## FUN_0054e850: retira el equipo del objetivo anterior y lo asocia al nuevo.
func f54e850(origin: int, target: int) -> int:
	var p := origin & 0xff
	var z := (origin >> 8) & 0xff
	var former := f546020(p, z)
	issue((0x8000 if p != 0 else 0) | 0x8a, z, 0, 0)
	f54c880(p, origin, former, 1)
	f54e730(p, origin, target)
	return 0

## FUN_0054e8a0: destruye equipos dependientes y elimina referencias al monstruo.
func f54e8a0(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var i := 0
	while i < m.u16(zone + 0x88):
		var reference := m.u16(zone + 8 + i * 2)
		var owner := reference & 0xff
		var slot := reference >> 8
		var linked := DuelMem.zone(reference & 1, slot)
		var tag := m.u8(zone + 0x48 + i * 2)
		var destroy := tag in [5, 6]
		if tag in [1, 10]:
			destroy = (m.u16(linked) & 0xfff) != 0
		elif tag == 2:
			destroy = f401a70(m.u16(linked) & 0xfff) in [0x447, 0x4dc, 0x589] and (m.u8(linked + 0x8f) & 4) == 0
		if destroy:
			f54e250(owner, slot, 1)
		i += 1
	if z < 5:
		for owner in range(2):
			for slot in range(5):
				f54c8a0(owner, slot, p, z)
	return 0

## FUN_0054e9e0: destruye las cartas que copian estadísticas de esta zona.
func f54e9e0(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var i := 0
	while i < m.u16(zone + 0x88):
		if m.u8(zone + 0x48 + i * 2) == 5:
			var reference := m.u16(zone + 8 + i * 2)
			f54e250(reference & 0xff, reference >> 8, 1)
		i += 1
	return 0

## FUN_0054ea40: ofrece un monstruo como tributo y programa efectos al cementerio.
func f54ea40(p: int, z: int) -> int:
	return _g_tribute(p, z, false)

## FUN_0054ec80: retira un monstruo con el comando alternativo 0xa7.
func f54ec80(p: int, z: int) -> int:
	return _g_tribute(p, z, true)

func _g_tribute(p: int, z: int, alternate: bool) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if z > 4 or index == 0 or (m.u16(zone + 0x90) & 4) != 0 or (not alternate and f543390(p, z) == 0):
		return 0
	m.set_u16(zone + 0x90, m.u16(zone + 0x90) | 4)
	var id := f401a70(index)
	var mask := 0x8000 if p != 0 else 0
	var op := 0xa7 if alternate else 0x95
	if id > 0x77f and id < 2000:
		issue(mask | op, z, 0, 0)
		f54e8a0(p, z)
		return 1
	if f543010(0, 0x453) - int(id == 0x453) + f543010(1, 0x453) > 0:
		issue(mask | (0x7b if alternate else 0x95), z, 1, 0)
		f54e8a0(p, z)
		return 1
	issue(mask | op, z, 0, 0)
	if ctype(index) < 0x15:
		var flag := DuelMem.pl(p & 1) + 0x11
		m.set_u8(flag, m.u8(flag) | 0x80)
	f56e2e0(p, 1)
	if id in [0x136, 0x2f, 0x12f, 0x138, 0x139, 0x140, 0x1de, 0x23d, 0x4da, 0x4e9] or (id in [0x1cd, 0x45c] and (m.u8(zone + 7) & 0x10) == 0):
		f53baa0((((m.u32(zone) & 0xfffff78d) << 19) | index | 0x3c6e0000) & 0xffffffff, 0)
	f54e8a0(p, z)
	if not alternate:
		f56a380(1 - p, 0x1e, ((z & 0xff) << 8) | (p & 0xff))
	return 1

## FUN_0054eea0: anuncia una carta con el comando 0x6e.
func f54eea0(p: int, index: int) -> int:
	issue((0x8000 if p != 0 else 0) | 0x6e, f401a70(index), 1, 0)
	return 0

## FUN_0054ef00: anuncia una carta con el comando 0x73.
func f54ef00(p: int, index: int) -> int:
	issue((0x8000 if p != 0 else 0) | 0x73, f401a70(index), 1, 0)
	return 0

## FUN_0054ef30: anuncia una carta con el comando 0x75.
func f54ef30(p: int, index: int) -> int:
	issue((0x8000 if p != 0 else 0) | 0x75, f401a70(index), 1, 0)
	return 0

## FUN_0054ef60: anuncia una carta con el comando 0x76.
func f54ef60(p: int, index: int) -> int:
	issue((0x8000 if p != 0 else 0) | 0x76, f401a70(index), 1, 0)
	return 0

## FUN_0054efe0: emite daño de batalla y notifica cartas que reaccionan.
func f54efe0(p: int, amount: int, origin: int, target: int) -> int:
	var responders := f542f30(1 - p, 0x415)
	if amount == 0:
		return 0
	issue((0x8000 if p != 0 else 0) | 0x43, amount, 0, 1)
	if responders > 0:
		issue((0x8000 if 1 - p != 0 else 0) | 0x1e, 0x415, 0, 0)
		f53e8b0(p, 1, responders)
	var first := origin if (target & 0xff) == p else target
	var second := target if (target & 0xff) == p else origin
	var high := (((((first >> 8) << 4) | (first & 0xf)) & 0xff) << 8) | ((((second >> 8) << 4) & 0xff) | (second & 0xf))
	f56a380(p, 0xd if (target & 0xff) == p else 0xe, ((high << 16) | (amount & 0xffff)) & 0xffffffff)
	return 0

## FUN_0054f0d0: emite daño de efecto y refleja 500 LP por cada 0x59a.
func f54f0d0(p: int, amount: int) -> int:
	var reflect := f543010(p, 0x59a)
	if amount != 0:
		var mask := 0x8000 if p != 0 else 0
		issue(mask | 0x42, amount, 0, 1)
		if reflect > 0:
			issue(mask | 0x1e, 0x59a, 0, 0)
			f54ef90(1 - p, reflect * 500)
	return 0

## FUN_0054f140: roba cartas y aplica descartes e invocación de la carta 0x2fa.
func f54f140(p: int, count: int, discard_spells: int) -> int:
	var base := DuelMem.pl(p & 1)
	var hand := m.u8(base + 2)
	if count == 0:
		return 0
	if (m.u8(base + 0x11) & 0x70) != 0:
		f54ef00(1 - p, f401ad0(0x294))
	var mask := 0x8000 if p != 0 else 0
	for i in range(maxi(0, count)):
		var entry := base + 0x7b4 + i * 4
		var index := m.u16(entry) & 0xfff
		issue(mask | 0x61, 1, 1, 0)
		if ((m.u32(entry) >> 12) & 1) != p and (m.u32(entry) & 0x20000) != 0 and f401a70(index) == 0x2fa:
			var slot := f543360(p)
			f54eed0(p, index, hand)
			if slot < 0:
				f54e680(p, hand, 1, 1)
			else:
				issue(mask | 0xc4, f401a70(index), (((slot & 0xf) | (hand << 4)) & 0xff) | 0x300, 0)
				issue(mask | 0x92, slot, 0xd, 0)
				f54ef90(p, 1000)
		else:
			var discard := false
			if discard_spells != 0 or (m.u8(base + 0x11) & 0x70) != 0:
				f54ef30(p, index)
				issue(mask | 0x1f, f401a70(index), hand, 0)
				discard = ((m.u8(base + 0x11) & 0x70) != 0 and ctype(index) < 0x15 and f445810(index) > 1499) or (discard_spells != 0 and ctype(index) == 0x16)
			if discard:
				f54d930(p, hand, entry, 1, 1, 0)
			else:
				hand += 1
	var damage := f542f30(p, 0x519)
	if damage > 0:
		issue(mask | 0x1e, 0x519, 0, 0)
		f54f0d0(p, damage * 500)
	if (m.u8(0xa133f2) & 0xe) != 0:
		f56e230(1 - p)
		# ASM 0x54f425..0x54f45e: argumentos reconstruidos antes de tail-jmp.
		f56a380(1 - (m.u8(0xa133f2) & 1), 0x1a, (((1 - p) & 0xff) << 16) | (p & 0xff))
	return 0

## FUN_0054f470: robo normal sin descarte de magias.
func f54f470(p: int, count: int) -> int:
	return f54f140(p, count, 0)

## FUN_0054f490: retira cartas de la parte superior del mazo.
func f54f490(p: int, count: int) -> int:
	issue((0x8000 if p != 0 else 0) | 99, count, 0, 0)
	return 0

## FUN_0054f4c0: envía cartas del mazo al cementerio con sus efectos.
func f54f4c0(p: int, count: int, trigger: int) -> int:
	if f543010(0, 0x453) >= 1 or f543010(1, 0x453) >= 1:
		return f54f490(p, count)
	issue((0x8000 if p != 0 else 0) | 0x62, count, 0, 0)
	var base := DuelMem.pl(p & 1)
	for i in range(mini(maxi(0, count), m.u8(base + 3))):
		var index := m.u16(base + 0x7b4 + i * 4) & 0xfff
		var id := f401a70(index)
		if id in [0x412, 0x1de, 0x4da] or (id == 0xc6 and trigger != 0):
			f53baa0((index | (p << 31) | 0x386e0000) & 0xffffffff, 0)
	return 0

## FUN_0054f5f0: envía al cementerio todas las copias del id en mazo y fusión.
func f54f5f0(p: int, id: int, trigger: int) -> int:
	var base := DuelMem.pl(p & 1)
	var count := 0
	for pair in [[3, 0x7b4, 0x67], [5, 0xa34, 0xdd]]:
		for i in range(m.u8(base + int(pair[0]))):
			var entry := base + int(pair[1]) + i * 4
			if f541c10(m.u16(entry) & 0xfff, f401ad0(id)) != 0:
				issue((0x8000 if p != 0 else 0) | int(pair[2]), m.u16(entry), m.u16(entry + 2), 0)
				count += 1
	if (id & 0xffff) in [0x412, 0x1de, 0x4da] or ((id & 0xffff) == 0xc6 and trigger != 0):
		for i in range(count):
			f53baa0(((f401ad0(id) & 0xffff) | (p << 31) | 0x386e0000) & 0xffffffff, 0)
	return 0

## FUN_0054f750: retira todas las copias del id en el mazo.
func f54f750(p: int, id: int) -> int:
	var base := DuelMem.pl(p & 1)
	for i in range(m.u8(base + 3)):
		var entry := base + 0x7b4 + i * 4
		if f401a70(m.u16(entry) & 0xfff) == s16(id):
			issue((0x8000 if p != 0 else 0) | 0x68, m.u16(entry), m.u16(entry + 2), 0)
	return 0

## FUN_0054f7d0: mueve la primera copia del id desde el mazo.
func f54f7d0(p: int, id: int, argument: int) -> int:
	var base := DuelMem.pl(p & 1)
	for i in range(m.u8(base + 3)):
		var entry := base + 0x7b4 + i * 4
		if f401a70(m.u16(entry) & 0xfff) == s16(id):
			issue((0x8000 if p != 0 else 0) | 0x66, m.u16(entry), m.u16(entry + 2), argument)
			return 1
	return 0

## FUN_0054f880: descarta la primera copia del id de la mano.
func f54f880(p: int, id: int) -> int:
	var base := DuelMem.pl(p & 1)
	for i in range(m.u8(base + 2)):
		if f401a70(m.u16(base + 0x674 + i * 4) & 0xfff) == s16(id):
			f54e680(p, i, 0, 1)
			return 1
	return 0

## FUN_0054f910: elegibilidad de un monstruo como objetivo de un efecto.
func f54f910(source_index: int, p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0:
		return 0
	if (m.u8(zone + 6) & 2) == 0:
		return 1
	var valid := true
	if f545c40(p, z) == 1:
		valid = f543010(0, 0x2e4) < 1 and f543010(1, 0x2e4) <= 0
	if f401a70(index) in [0x52e, 0x531] and f543fc0() == 0x14d and ctype(source_index) == 0x16 and csub(source_index) != 3:
		valid = false
	return int(valid)

## FUN_0054f9f0: objetivo válido para efectos globales salvo inmunidad de campo.
func f54f9f0(p: int, z: int) -> int:
	var zone := DuelMem.zone(p & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0:
		return 0
	if f401a70(index) in [0x52e, 0x531] and f543fc0() == 0x14d and (m.u8(zone + 6) & 2) != 0:
		return 0
	return 1

## FUN_0054fa60: valida tributos ligados a la carta 0x47 y sus contadores.
func f54fa60(effect: int, location: int) -> int:
	var p := location & 0xff
	var z := (location >> 8) & 0xff
	var zone := DuelMem.zone(location & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0 or z >= 5 or p != (m.u8(effect + 2) & 1):
		return 0
	var id := f401a70(m.u16(effect))
	var limits := {0x37: 1, 0x38: 3, 0x42: 5}
	if not limits.has(id) or f401a70(index) != 0x115 or f542f30(0, 0x58a) >= 1 or f542f30(1, 0x58a) >= 1:
		return 0
	for i in range(m.u16(zone + 0x88)):
		if m.u8(zone + 0x48 + i * 2) == 1:
			var reference := m.u16(zone + 8 + i * 2)
			var equip := DuelMem.zone(reference & 1, reference >> 8)
			if f401a70(m.u16(equip) & 0xfff) == 0x47 and int(limits[id]) < ((m.u8(equip + 6) & 0x3c) >> 2):
				return 1
	return 0

## FUN_0054fbb0: objetivo de trampa colocada o visible en cinco zonas.
func f54fbb0(_effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	var index := m.u16(zone) & 0xfff
	return int(index != 0 and z > 4 and z < 10 and ((m.u8(zone + 6) & 2) == 0 or ctype(index) == 0x15))

## FUN_0054fc20: monstruo rival válido como objetivo.
func f54fc20(effect: int, location: int) -> int:
	return f550d90(effect, location)

## FUN_0054fc80: restricciones de objetivo de cada equipo original.
func f54fc80(effect: int, location: int) -> int:
	var p := location & 0xff
	var z := (location >> 8) & 0xff
	var zone := DuelMem.zone(location & 1, z)
	var index := m.u16(zone) & 0xfff
	var monster_kind := f545c40(p, z)
	var attribute := f545e70(p, z)
	if z >= 5 or (m.u32(zone) & 0xfff) == 0 or (m.u8(zone + 6) & 2) == 0 or f54f910(m.u16(effect), p, z) == 0:
		return 0
	var id := f401a70(m.u16(effect)) & 0xffff
	if id in [0x138, 0x139, 0x12f, 0x136, 0x140, 0x290, 0x291, 0x412, 0x424, 0x4da, 0x4ea, 0x521, 0x58b, 0x58c, 0x5a8, 0x5a9, 0x5aa, 0x60c]:
		return 1
	var kinds := {300: 15, 0x13a: 1, 0x13b: 19, 0x13e: 12, 0x141: 2, 0x142: 18, 0x144: 7, 0x145: 9, 0x146: 16, 0x147: 14, 0x12e: 3, 0x130: 10, 0x131: 10, 0x133: 11, 0x135: 13, 0x137: 17, 0x49e: 15, 0x3c2: 7, 0x522: 7, 0x58e: 15, 0x60e: 15}
	if kinds.has(id):
		return int(monster_kind == int(kinds[id]))
	var attributes := {0x12d: 2, 0x143: 5, 0x132: 1, 0x134: 3, 0x3f5: 6, 0x29b: 1, 0x28d: 4, 0x3f4: 4}
	if attributes.has(id):
		return int(attribute == int(attributes[id]))
	match id:
		0x28a, 0x422:
			return int((m.u8(effect + 2) & 1) == p)
		0x42c, 0x5ea:
			return int((m.u8(effect + 2) & 1) != p)
		0x13c:
			return int(f401a70(index) in [0x3d, 0x3e, 0x4e1])
		0x47:
			return int(f401a70(index) == 0x115 and (m.u8(effect + 2) & 1) == p and f545620(p, z, 0x47) == 0)
		0x28b:
			return int(f401a70(index) == 0x16d)
		0x416, 0x417:
			return int(monster_kind != 7)
		0x604:
			return int(f401a70(index) == 0x53b)
	return 0

## FUN_00550390: monstruo rival en defensa seleccionable.
func f550390(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var p := location & 0xff
	var zone := DuelMem.zone(location & 1, z)
	if z < 5 and p != (m.u8(effect + 2) & 1) and (m.u32(zone) & 0xfff) != 0 and f54f910(m.u16(effect), p, z) != 0:
		return m.u8(zone + 6) & 1
	return 0

## FUN_00550400: objetivo visible de ATK hasta 1000, distinto de la carta fuente.
func f550400(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var p := location & 0xff
	var zone := DuelMem.zone(location & 1, z)
	if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0 and f547c60(p, z) < 1001 and f54f910(m.u16(effect), p, z) != 0:
		return int(p != (m.u16(effect + 2) & 1) or z != ((m.u16(effect + 2) >> 4) & 0x3f))
	return 0

## FUN_00550490: magia o trampa colocada distinta de la fuente 0x3f1.
func f550490(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	var index := m.u16(zone) & 0xfff
	if index == 0 or z <= 4 or z >= 11 or ((m.u8(zone + 6) & 2) != 0 and ctype(index) == 0x15):
		return 0
	return int(f401a70(m.u16(effect)) != 0x3f1 or (location & 0xff) != (m.u16(effect + 2) & 1) or z != ((m.u16(effect + 2) >> 4) & 0x3f))

## FUN_00550530: monstruo visible Dragón seleccionable.
func f550530(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var p := location & 0xff
	var kind := f545c40(p, z)
	var zone := DuelMem.zone(location & 1, z)
	return int(z < 5 and (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0 and f54f910(m.u16(effect), p, z) != 0 and kind == 1)

## FUN_005505b0: cualquier monstruo seleccionable.
func f5505b0(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	return int(z < 5 and f54f910(m.u16(effect), location & 0xff, z) != 0 and (m.u32(DuelMem.zone(location & 1, z)) & 0xfff) != 0)

## FUN_00550610: carta rival colocada boca abajo.
func f550610(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	if (location & 0xff) != (m.u8(effect + 2) & 1) and (m.u32(zone) & 0xfff) != 0:
		return (~m.u8(zone + 6) >> 1) & 1
	return 0

## FUN_00550660: valida familias de monstruos para las magias de selección.
func f550660(effect: int, location: int) -> int:
	var p := location & 0xff
	var z := (location >> 8) & 0xff
	var zone := DuelMem.zone(location & 1, z)
	var index := m.s16(effect)
	var kind := f545c40(p, z)
	if z >= 5 or (m.u32(zone) & 0xfff) == 0 or f54f910(index, p, z) == 0 or f54f9f0(p, z) == 0 or (m.u8(zone + 6) & 2) == 0 or index == 0:
		return 0
	var id := f401a70(index)
	if id == 0x28f:
		return int(f545510(p, z, 0, 0) > 0)
	var kinds := {0x296: 6, 0x28c: 15, 0x293: 7, 0x295: 10, 0x297: 8, 0x40c: 18, 0x40d: 3}
	return int(kinds.has(id) and kind == int(kinds.get(id, -1)))

## FUN_00550830: monstruo en defensa boca abajo que pueda ofrecerse.
func f550830(_effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	if z < 5 and f543390(location & 0xff, z) != 0 and (m.u16(zone + 6) & 2) == 0:
		return m.u8(zone + 6) & 1
	return 0

## FUN_00550880: monstruo seleccionable boca arriba.
func f550880(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	if z < 5 and (m.u32(zone) & 0xfff) != 0 and f54f910(m.u16(effect), location & 0xff, z) != 0:
		return (m.u8(zone + 6) >> 1) & 1
	return 0

## FUN_005508e0: monstruo seleccionable boca arriba, excluyendo fichas.
func f5508e0(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	var index := m.u16(zone) & 0xfff
	if z < 5 and index != 0:
		var id := f401a70(index)
		if id > 0x77f and id < 2000:
			return 0
		if f54f910(m.u16(effect), location & 0xff, z) != 0:
			return (m.u8(zone + 6) >> 1) & 1
	return 0

## FUN_00550970: monstruo rival visible distinto del objetivo ya marcado.
func f550970(effect: int, location: int) -> int:
	if (location & 0xffff) == m.u16(effect + 6):
		return 0
	return f550d90(effect, location) & f550880(effect, location)

## FUN_005509f0: monstruo rival boca arriba sin comprobación de inmunidad.
func f5509f0(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	if z < 5 and (m.u8(effect + 2) & 1) != (location & 0xff) and (m.u32(zone) & 0xfff) != 0:
		return (m.u8(zone + 6) >> 1) & 1
	return 0

## FUN_00550a40: trampa boca arriba, incluida la zona de campo.
func f550a40(_effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	var index := m.u16(zone) & 0xfff
	return int(index != 0 and z > 4 and z < 11 and (m.u8(zone + 6) & 2) != 0 and ctype(index) == 0x15)

## FUN_00550aa0: monstruo rival seleccionable en ataque.
func f550aa0(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	if z < 5 and (location & 0xff) != (m.u8(effect + 2) & 1) and (m.u32(zone) & 0xfff) != 0 and f54f910(m.u16(effect), location & 0xff, z) != 0:
		return ~m.u8(zone + 6) & 1
	return 0

## FUN_00550b10: equipo visible que puede trasladarse a otro objetivo.
func f550b10(_effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var p := location & 0xff
	var zone := DuelMem.zone(location & 1, z)
	var index := m.u32(zone) & 0xfff
	if z <= 4 or z >= 11 or index == 0 or (m.u8(zone + 6) & 2) == 0 or (f5547b0(index) == 0 and f401a70(index) != 0x47):
		return 0
	var original := f546020(p, z)
	var count := 0
	for owner in range(2):
		for slot in range(5):
			if (m.u8(zone + 0x90) & 1) != 0:
				count += int(f545fb0(p, z, owner, slot) != 0)
			elif s16(original) != -1 and (owner != (original & 0xff) or slot != ((original >> 8) & 0xff)) and f545fb0(p, z, owner, slot) != 0:
				return 1
	return int((m.u8(zone + 0x90) & 1) != 0 and count > 1)

## FUN_00550c30: magia o trampa rival ocupada.
func f550c30(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	return int((m.u8(effect + 2) & 1) != (location & 0xff) and z > 4 and z < 11 and (m.u32(DuelMem.zone(location & 1, z)) & 0xfff) != 0)

## FUN_00550c80: zona de magia/trampa ocupada distinta de la fuente.
func f550c80(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	return int(z > 4 and z < 11 and (m.u32(DuelMem.zone(location & 1, z)) & 0xfff) != 0 and ((location & 0xff) != (m.u16(effect + 2) & 1) or z != ((m.u16(effect + 2) >> 4) & 0x3f)))

## FUN_00550ce0: monstruo boca abajo.
func f550ce0(_effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	if z < 5 and (m.u32(zone) & 0xfff) != 0:
		return ~(m.u8(zone + 6) >> 1) & 1
	return 0

## FUN_00550d20: magia/trampa boca abajo distinta de la fuente.
func f550d20(effect: int, location: int) -> int:
	if f550c80(effect, location) == 0:
		return 0
	return ~(m.u8(DuelMem.zone(location & 1, (location & 0xffff) >> 8) + 6) >> 1) & 1

## FUN_00550d90: monstruo rival seleccionable en cualquier posición.
func f550d90(effect: int, location: int) -> int:
	var z := (location & 0xffff) >> 8
	var p := location & 0xff
	return int(z < 5 and p != (m.u8(effect + 2) & 1) and f54f910(m.u16(effect), p, z) != 0 and (m.u32(DuelMem.zone(location & 1, z)) & 0xfff) != 0)

## FUN_00550e00: monstruo propio visible de id0x15 o tipo19.
func f550e00(effect: int, location: int) -> int:
	var p := location & 0xff
	var z := (location & 0xffff) >> 8
	var zone := DuelMem.zone(location & 1, z)
	var index := m.u16(zone) & 0xfff
	return int(p == (m.u8(effect + 2) & 1) and z < 5 and (m.u8(zone + 6) & 2) != 0 and index != 0 and f54f910(m.u16(effect), p, z) != 0 and (f401a70(index) == 0x15 or f545c40(p, z) == 0x13))

## FUN_00550ea0: tributo propio que permite la invocación de0x526.
func f550ea0(effect: int, location: int) -> int:
	var p := location & 0xff
	var z := (location & 0xffff) >> 8
	var index := m.u16(DuelMem.zone(location & 1, z)) & 0xfff
	if p == (m.u8(effect + 2) & 1) and z < 5 and index != 0 and f542f30(0, 0x58a) < 1 and f542f30(1, 0x58a) < 1:
		var level := f4457d0(index)
		if level != 0 and f56ba50(m.u8(effect + 2) & 1, 0x526, level + 1) > 0:
			return 1
	return 0

## FUN_00550f50: monstruo propio seleccionable cuyo propietario también coincide.
func f550f50(effect: int, location: int) -> int:
	var p := location & 0xff
	var z := (location & 0xffff) >> 8
	var entry := m.u32(DuelMem.zone(location & 1, z))
	return int(f54f910(m.u16(effect), p, z) != 0 and p == (m.u8(effect + 2) & 1) and z < 5 and (entry & 0xfff) != 0 and ((entry >> 12) & 1) == (m.u8(effect + 2) & 1))

## FUN_00550fe0: monstruo propio seleccionable.
func f550fe0(effect: int, location: int) -> int:
	var p := location & 0xff
	var z := (location & 0xffff) >> 8
	return int(f54f910(m.u16(effect), p, z) != 0 and p == (m.u8(effect + 2) & 1) and z < 5 and (m.u16(DuelMem.zone(location & 1, z)) & 0xfff) != 0)
