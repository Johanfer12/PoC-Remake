class_name JoeyPortZL
extends JoeyPortZK
## Etapa6, lotes L1/L2: materiales y selectores de ritual del PE Joey.

func f5990a0(player: int) -> int:
	var total := 0
	for side in 2:
		for z in 5:
			if f56a140(player, side, z) != 0 and (player == side or (m.u8(JoeyMem.zone(side, z) + 6) & 2) != 0):
				total += f4026c0(m.u16(JoeyMem.zone(side, z)) & 0xfff) & 0xffff
	return total & 0xffffffff

## La cota es estricta: need <= suma < need+smallest. No ordenar ni deduplicar.
func f599570(values: int, last: int, need: int, smallest: int) -> int:
	last = _s32(last)
	need = _s32(need)
	smallest = _s32(smallest)
	while last >= 0:
		var level := _s32(m.u32(values + last * 4))
		if level < need:
			if last != 0 and f599570(values, last - 1, _s32(need - level), mini(smallest, level)) != 0:
				return 1
		elif level < _s32(need + smallest):
			return 1
		last -= 1
	return 0

func f599140(context: int, player: int, area: int, slot: int) -> int:
	var owner := m.u8(context + 2) & 1
	var remaining := m.u8(0xa55c8b)
	var smallest := m.u8(0xa55c8c)
	var ritual := m.u32((0x5ed060 + _s32(f598ed0(m.u16(context))) * 4) & 0xffffffff) & 0x1fff
	var index := 0
	if area == 0:
		index = m.u16(JoeyMem.zone(player, slot)) & 0xfff
		if f56a140(owner, player, slot) == 0: return 0
		if player != owner and (m.u8(JoeyMem.zone(player, slot) + 6) & 2) == 0: return 0
		if _s32(f56a030(owner)) < 0 and (player != owner or f569e10(player, slot) == 0): return 0
	elif area == 11:
		index = m.u16(JoeyMem.pl(player) + JoeyMem.P_HAND + slot * 4) & 0xfff
		if player != owner or _s32(f56a030(owner)) < 0: return 0
		if (f4022e0(index) & 0xffff) == ritual and _s32(f56d2c0(player, f4022e0(index))) < 2: return 0
	if (f4025d0(index) & 0xffff) > 20: return 0
	var level := f4026c0(index) & 0xffff
	if remaining <= level and level < smallest + remaining: return 1
	if level <= smallest: smallest = level
	# PE conserva el nivel candidato mientras recorre las otras cartas.
	var candidates := m.local(42 * 4)
	var count := 0
	for i in m.u8(JoeyMem.pl(owner) + JoeyMem.P_HAND_N):
		if area == 11 and slot == i: continue
		var card := m.u16(JoeyMem.pl(owner) + JoeyMem.P_HAND + i * 4) & 0xfff
		if (f4022e0(card) & 0xffff) == ritual:
			ritual = 0xffffffff # Sólo reservar la primera copia.
		elif count < 42:
			m.set_u32(candidates + count * 4, f4026c0(card) & 0xffff)
			count += 1
	for side in 2:
		for z in 5:
			if f56a140(owner, side, z) == 0: continue
			if player == side:
				if area == 0 and slot == z: continue
			elif (m.u8(JoeyMem.zone(side, z) + 6) & 2) == 0:
				continue
			if count < 42:
				m.set_u32(candidates + count * 4, f4026c0(m.u16(JoeyMem.zone(side, z)) & 0xfff) & 0xffff)
				count += 1
	return f599570(candidates, count - 1, remaining - level, smallest)

func f599840() -> int:
	return m.u8(0xa55c8b)

## Comprueba el ritual antes de elegir materiales; conserva los contadores que
## escribe el PE al explorar un campo lleno, incluso cuando devuelve cero.
func f599850(context: int) -> int:
	var owner := m.u8(context + 2) & 1
	if f570b40(owner) == 0 or f5699c0(0x58a) != 0: return 0
	var row := 0
	while (m.u32(0x5ed060 + row * 4) & 0x1fff) != 0:
		var record := m.u32(0x5ed060 + row * 4)
		if ((record >> 13) & 0x1fff) == (f4022e0(m.u16(context)) & 0xffff):
			if f598f30(owner, row) == 0: return 0
			if _s32(f56a030(owner)) < 0:
				for z in 5:
					if (m.u32(JoeyMem.zone(owner, z)) & 0xfff) == 0: continue
					m.set_u8(0xa55c8c, 0xff)
					m.set_u8(0xa55c8b, record >> 26)
					if f599140(context, owner, 0, z) != 0 and f569e10(owner, z) != 0: return 1
				return 0
			var hand_levels := f598ff0(owner, f402460(record & 0x1fff))
			return int((record >> 26) <= _s32(hand_levels + f5990a0(owner)))
		row += 1
	return 0

func f599e00(player: int, slot: int) -> int:
	# Ghidra lo declara void, pero 599e30 consume EAX: ASM 599e24..599e2c.
	return f568bd0(JoeyMem.pl(player) + JoeyMem.P_GRAVE + slot * 4)


func _zl_pay_ritual(index: int) -> void:
	var level := f4026c0(index) & 0xffff
	m.set_u8(0xa55c8b, maxi(0, m.u8(0xa55c8b) - level))
	m.set_u8(0xa55c8c, mini(m.u8(0xa55c8c), level))


## Selector humano: no consume otra carta mientras hay comando o cola pendientes.
func f5995e0() -> int:
	var context := 0xa55b2c + m.u16(0xa55c80) * 20
	f598ed0(m.u16(context))
	if (m.u32(0xa558ac) & 0x4000) != 0 or m.u16(0xa558a8) != 0: return 0
	var owner := m.u8(context + 2) & 1
	var mask := 0xf1 if _s32(f56a030(owner)) >= 0 else 0xf0
	if f5aa440((mask << 16) | mask) != 0:
		var player := m.u32(0xa55044)
		var area := m.u32(0xa55048)
		var slot := m.u32(0xa5504c)
		if area == 0:
			var index := m.u16(JoeyMem.zone(player, slot)) & 0xfff
			if f599140(context, player, 0, slot) != 0 and f5aa480() != 0:
				_zl_pay_ritual(index)
				f577b30(player, slot)
		elif area == 11:
			if player != owner: return 0
			var index := m.u16(JoeyMem.pl(owner) + JoeyMem.P_HAND + slot * 4) & 0xfff
			if f599140(context, owner, 11, slot) != 0 and f5aa480() != 0:
				_zl_pay_ritual(index)
				# ASM599724 reserva c=0 antes de 5700f0 y lo deja para 575af0.
				f575af0(owner, f5700f0(owner, 11, slot), 0)
	return int(m.u8(0xa55c8b) == 0)


## Estados originales: 128 inicia, 120 paga materiales CPU, 100 busca el monstruo,
## 99 prepara la invocación y devuelve98. No sustituye el despacho de efectos.
func f5999d0(context: int) -> int:
	if (m.u8(context + 4) & 4) != 0: return 0
	var owner := m.u8(context + 2) & 1
	match m.u8(0xa55c8a):
		99:
			f5adb10(owner, 0xa55c90, 1, 1, 11, m.u32(0xa53750))
			return 98
		100:
			for slot in m.u8(JoeyMem.pl(owner) + JoeyMem.P_HAND_N):
				var at := JoeyMem.pl(owner) + JoeyMem.P_HAND + slot * 4
				var id := f4022e0(m.u16(at) & 0xfff) & 0xffff
				var row := _s32(f598ed0(m.u16(context)))
				if id == (m.u32((0x5ed060 + row * 4) & 0xffffffff) & 0x1fff):
					f5675c0(0xa55c90, at)
					m.set_u32(0xa53750, slot)
					return 99
		120:
			if m.u8(0xa55c8b) == 0: return 100
			for slot in m.u8(JoeyMem.pl(owner) + JoeyMem.P_HAND_N):
				var index := m.u16(JoeyMem.pl(owner) + JoeyMem.P_HAND + slot * 4) & 0xfff
				if index != 0 and f599140(context, owner, 11, slot) != 0:
					_zl_pay_ritual(index)
					f575af0(owner, f5700f0(owner, 11, slot), 0)
					return 120
			for z in 5:
				var index := m.u16(JoeyMem.zone(owner, z)) & 0xfff
				if index != 0 and f599140(context, owner, 0, z) != 0:
					_zl_pay_ritual(index)
					f577b30(owner, z)
					return 120
			return 120
		128:
			m.set_u8(0xa55c8b, 0)
			if f599850(context) != 0:
				var row := _s32(f598ed0(m.u16(context)))
				if row >= 0 and f598f30(owner, row) != 0:
					m.set_u8(0xa55c8c, 0xff)
					m.set_u8(0xa55c8b, m.u32(0x5ed060 + row * 4) >> 26)
					if ((m.u8(0xa54e5c) >> 1) & 3) & (1 << owner): return 120
					f5bf800(0xcf)
					f5bf9a0(9, m.u8(0xa55c8b))
					return 100
		_:
			m.set_u8(0xa55c8a, 0)
	return 0
