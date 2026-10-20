class_name DuelPortO
extends DuelPortN
## Modulo del porte del motor de duelo (ver docs/duel/PORTING.md).

## FUN_0057dbb0: cartas que la CPU conserva según la prioridad del descarte.
func f57dbb0(priority: int, id: int) -> int:
	id &= 0xffff
	if id > 15 and id < 21:
		return 1
	if priority > 0:
		if id in [0x3f2, 0x29f, 0x14f, 0x150, 0x15b, 0x2da, 0x3ba, 0x3f0, 0x403, 0x405, 0x406, 0x420, 0x425, 0x42c, 0x49b]:
			return 1
		if id == 0x246 and f545060(0, 0x15b) + f544a00(0, 0x15b) != 0:
			return 1
		if id == 0x452 and f57d6f0(0, -1, 1, 0) <= f57d6f0(1, -1, 1, 0):
			return 1
	return int(priority >= 2 and id in [0x39, 0x1a3, 0x76d])

## FUN_0057de50: busca el monstruo prescindible con menor suma de ATK y DEF.
func f57de50(base: int, player: int) -> int:
	var offset := (player & 1) * 0xd54
	for stage in range(3):
		var best := -1
		var score := 9999
		for slot in range(m.u8(0xa11946 + offset)):
			var address := (0xa11fb8 if stage == 0 else base + 0x674) + offset + slot * 4
			var index := m.u16(address) & 0xfff
			if stage < 2 and (index == 0 or ctype(index) >= 0x15):
				continue
			if stage == 0 and f541950(index) != 0:
				continue
			if f57dbb0(1, f401a70(index)) != 0:
				continue
			var value := f445850(index) + f445810(index)
			if value < score:
				score = value
				best = slot
		if best >= 0:
			return best
	return -1

## FUN_0057e1c0: selecciona el monstruo de tributo de mayor ATK, priorizando nivel alto.
func f57e1c0(base: int, player: int) -> int:
	var offset := (player & 1) * 0xd54
	for stage in range(2):
		var best := -1
		var score := -1
		for slot in range(m.u8(0xa11946 + offset)):
			var index := m.u16(base + offset + 0x674 + slot * 4) & 0xfff
			if index == 0 or ctype(index) >= 0x15 or f5421c0(index) != 0:
				continue
			if f57dbb0(1, f401a70(index)) != 0:
				continue
			var value := f445810(index)
			if value > score and (stage != 0 or f4457d0(index) > 4):
				score = value
				best = slot
		if best >= 0:
			return best
	return -1

## FUN_0057e380: elige carta descartable, reservando los tributos si hay invocaciones especiales.
func f57e380() -> int:
	if (f57d2c0(1, 0x3f0) >= 0 or f57d2c0(1, 0x488) >= 0 or f5802d0(0x447) != 0) and f543330(1) > 0:
		var best := f57e1c0(0xa11944, 1)
		if best >= 0:
			return best
	for slot in range(m.u8(0xa1269a)):
		if f401a70(m.u16(0xa12d0c + slot * 4) & 0xfff) == 0x1da:
			return slot
	return f57de50(0xa11944, 1)

## FUN_0057e440: simula el resultado de un ataque en seis bytes de salida.
func f57e440(attacker: int, target: int, out: int) -> int:
	var attack := f547c60(1, attacker)
	m.set_u16(out, ((((target & 7) << 3) | (attacker & 7)) << 4) | (m.u16(out) & 0xf005))
	m.set_u16(out + 2, 0)
	m.set_u16(out + 4, 0)
	var flags := m.u8(0xa11962 + target * 0x94)
	if (flags & 1) == 0:
		var opponent := f547c60(0, target)
		if opponent < attack:
			m.set_u16(out, m.u16(out) | 0x808)
			m.set_u16(out + 4, attack - opponent)
		elif attack < opponent:
			m.set_u8(out + 1, m.u8(out + 1) | 4)
			m.set_u16(out + 4, attack - opponent)
		else:
			m.set_u8(out + 1, m.u8(out + 1) | 0xc)
	else:
		var defense := f547c80(0, target)
		if (flags & 2) == 0:
			defense = 1
			for slot in range(5):
				if f571810(1, slot, 1) != 0:
					defense = maxi(defense, f547c60(1, slot))
			defense -= 1
		if defense < attack:
			m.set_u16(out, m.u16(out) | 0x808)
		elif attack < defense:
			m.set_u16(out + 4, attack - defense)
	return 0

## FUN_0057e540: determina el mejor objetivo de ataque para un monstruo de la CPU.
func f57e540(attacker: int, out: int) -> int:
	if (f571600(1, attacker) != 0 or f5431b0(0) == 0) and f401a70(m.u16(0xa126b0 + attacker * 0x94) & 0xfff) != 0x5f3:
		m.set_u8(out, m.u8(out) | 6)
		m.set_u16(out + 4, f547c60(1, attacker))
		m.set_u16(out, ((attacker & 7) << 4) | (m.u16(out) & 0xf38f))
		return 1
	m.set_u8(out, m.u8(out) & 0xf5)
	var scratch := m.local(6)
	for target in range(5):
		if (m.u32(0xa1195c + target * 0x94) & 0xfff) == 0:
			continue
		f57e440(attacker, target, scratch)
		if (m.u32(scratch) & 8) == 0:
			continue
		if (m.u16(out) & 8) != 0 and m.s16(scratch + 4) <= m.s16(out + 4):
			if f547c80(0, (m.u32(scratch) >> 7) & 7) <= f547c80(0, (m.u16(out) & 0x380) >> 7):
				continue
		m.copy(out, scratch, 6)
	return (m.u8(out) & 8) >> 3

## FUN_0057e690: evalúa si el ataque supera a una carta enemiga.
func f57e690(attack: int, target: int) -> int:
	var flags := m.u8(0xa11962 + target * 0x94)
	var value := f547c60(0, target) if (flags & 1) == 0 else f547c80(0, target)
	if (flags & 1) != 0 and (flags & 2) == 0:
		return 1
	return int(not (attack <= value and (value != attack or (flags & 1) != 0)))

## FUN_0057e6e0: comprueba si hay algún objetivo que pueda vencer este ATK.
func f57e6e0(attack: int) -> int:
	if f5431b0(0) == 0:
		return 1
	for target in range(5):
		if (m.u32(0xa1195c + target * 0x94) & 0xfff) != 0 and f57e690(attack, target) != 0:
			return 1
	return 0

## FUN_0057e740: ordena atacantes de menor ATK a mayor y escoge el primer ataque favorable.
func f57e740() -> int:
	m.set_u16(0xa1344c, m.u16(0xa1344c) & 0xf3f9)
	m.set_u16(0xa13450, 0)
	var attackers: Array[int] = []
	for slot in range(5):
		if f571810(1, slot, 1) != 0:
			attackers.append(slot)
	if attackers.is_empty():
		return 0
	# local_14[0] es tambien el bufer que recibe 57e540: la ordenacion deja ahi el ATK del
	# ultimo atacante comparado y 57e540 solo hace OR/mascaras sobre el (bits 8-9 llegan a la
	# zona objetivo via 0xa1344c << 4). Con un solo atacante el original arrastra la pila.
	var local14 := 0
	var swapped := true
	while swapped:
		swapped = false
		for i in range(attackers.size() - 1):
			var first := attackers[i]
			var second := attackers[i + 1]
			var id := f401a70(m.u16(0xa126b0 + second * 0x94) & 0xfff)
			local14 = f547c60(1, first) & 0xffffffff
			if f547c60(1, second) < local14 and id not in [0x226, 0x2e8, 0x2f9]:
				attackers[i] = second
				attackers[i + 1] = first
				swapped = true
	var out := m.local(8)
	m.set_u32(out, local14)
	for attacker in attackers:
		f547c60(1, attacker)
		if f57e540(attacker, out) != 0:
			m.copy(0xa1344c, out, 6)
			m.set_u16(0xa1344c, m.u16(0xa1344c) | 4)
			return 1
	return 0

## FUN_0057e8d0: guarda ambos campos para las simulaciones de la CPU.
func f57e8d0() -> int:
	m.copy(0xa13454, 0xa11944, 0x1aac)
	return 0

## FUN_0057e8f0: restaura ambos campos después de una simulación.
func f57e8f0() -> int:
	m.copy(0xa11944, 0xa13454, 0x1aac)
	return 0

## FUN_0057e910: simula dar vuelta a los monstruos de la CPU excepto los de efecto particular.
func f57e910() -> int:
	for slot in range(5):
		var flags := 0xa126b6 + slot * 0x94
		var index := m.u16(flags - 6) & 0xfff
		if index != 0 and f541d10(f401a70(index), 0) == 0:
			m.set_u16(flags, (m.u16(flags) & 0xfdfe) | 2)
			m.set_u16(0xa126ae, m.u16(0xa126ae) & ~(1 << slot))
	return 0

## FUN_0057e980: simula los tributos e invocación desde una posición de la mano.
func f57e980(hand: int, tributes: int) -> int:
	for shift in [0, 4, 8, 12]:
		if ((tributes >> shift) & 0xf) != 0:
			var zone: int = 0xa126b0 + ((tributes >> shift) & 7) * 0x94
			m.set_u32(zone, m.u32(zone) & 0xfffff000)
	var slot := f543360(1)
	var address := 0xa126b0 + slot * 0x94
	m.set_u32(address, m.u32(address) ^ ((m.u32(0xa12d0c + hand * 4) ^ m.u32(address)) & 0xfff))
	m.set_u16(address + 6, (m.u16(address + 6) & 0xfffe) | 2)
	return 0

## FUN_0057ea80: simula una fase de batalla completa y suma el daño favorable.
func f57ea80() -> int:
	m.set_u32(0xa14f00, m.u32(0xa14f00) & 0xffffffc0)
	var damage := 0
	if f571d30(1) != 0:
		f571c30(0xa11944, 1, 0, 0)
		while f57e740() != 0:
			var outcome := m.u32(0xa1344c)
			m.set_u16(0xa126ae, m.u16(0xa126ae) | (1 << ((outcome >> 4) & 7)))
			if (outcome & 0x400) != 0:
				var address := 0xa126b0 + ((outcome >> 10) & 1) * 0x94
				m.set_u32(address, m.u32(address) & 0xfffff000)
				var old := m.u16(0xa14f00)
				m.set_u16(0xa14f00, old ^ (((old + 1) ^ old) & 7))
			if (outcome & 0x800) != 0:
				var address := 0xa1195c + ((outcome >> 11) & 1) * 0x94
				m.set_u32(address, m.u32(address) & 0xfffff000)
				var old := m.u16(0xa14f00)
				m.set_u16(0xa14f00, old ^ ((((old & 0xf8) + 8) ^ old) & 0x38))
			damage += m.s16(0xa13450)
	return damage

## FUN_0057eb90: consulta un ataque favorable sin modificar el campo real.
func f57eb90(flip: int) -> int:
	f57e8d0()
	if flip != 0:
		f57e910()
	var result := f57e740()
	f57e8f0()
	return result

## FUN_005802d0: busca una magia o trampa del id indicado que pueda activarse.
func f5802d0(id: int) -> int:
	var effect := m.local(20)
	for slot in range(5, 10):
		var index := m.u32(0xa126b0 + slot * 0x94) & 0xfff
		if index == 0:
			continue
		m.clear(effect, 20)
		m.set_u16(effect, index)
		m.set_u32(effect + 2, 1)
		if f401a70(index) == s16(id) and f5691b0(effect, 1, slot) != 0:
			return 1
	return 0

## FUN_005808c0: decide si la CPU puede permitirse el daño de una batalla adversa.
func f5808c0() -> int:
	var enemy := f547c60(0, f57d7d0(0, -1, 1, 0))
	var own := f547c60(1, f57d7d0(1, -1, 1, 0))
	var lp := m.u16(0xa12698)
	if enemy < lp and enemy - own < lp and enemy <= own:
		var total := 0
		for slot in range(5):
			total += f547c60(0, slot)
		return int(lp < total)
	return 1

## FUN_00581bf0: compara ATK y DEF con el campo, los LP y el daño inmediato.
func f581bf0(attack: int, defense: int) -> int:
	var enemy := f57d6f0(0, -1, 1, 0)
	var own := f57d6f0(1, -1, 1, 0)
	var own_def := f57d6f0(1, -1, 0, 1)
	if f5431b0(0) == 0 and m.u16(0xa11944) <= f57da00(1) and attack != 0:
		return 0
	if enemy - attack > 999:
		return 1
	if attack < defense:
		if attack == 0:
			return 1
		if attack < enemy or attack < 1900:
			if maxi(own, own_def) <= defense and defense > 1500:
				return 1
			if f5431b0(0) == 0 or attack < enemy:
				return -1
	elif attack < enemy and (enemy - attack > 300 or m.u16(0xa12698) < 301):
		return -1
	return 0

## FUN_00581cd0: posición preferida para un monstruo, con excepciones por efecto.
func f581cd0(index: int, fallback: int) -> int:
	var id := f401a70(index) & 0xffff
	if id in [0x4d8, 0x2da, 0xf, 499, 0x1ff, 0x455, 0x462, 0x4de, 0x4e6, 0x534, 0x536]:
		return 0
	if id == 0x4db:
		return 1
	if f541d10(id, 1) != 0 or f541d10(id, 0) != 0:
		return 1
	var choice := f581bf0(f445810(index), f445850(index))
	return fallback if choice == -1 else choice

## FUN_00581e00: limpia las simulaciones y entra en la primera fase principal.
func f581e00() -> int:
	m.clear(0xa13440, 0x1ac8)
	issue((m.u16(0xa133f2) << 15) | 0x52, 0, 0, 0)
	return 1

## FUN_00583c80: inicia la batalla de la CPU si existe un ataque favorable.
func f583c80() -> int:
	if m.u8(0xa1343d) == 0:
		if f571d30(m.u8(0xa133f2) & 1) == 0 or f57eb90(0) == 0:
			return 1
		m.set_u8(0xa1343d, m.u8(0xa1343d) + 1)
		m.set_u16(0xa133f2, m.u16(0xa133f2) & 0x807f)
		m.set_u8(0xa133f4, 0)
	return f575e50(m.u8(0xa133f2) & 1)

## FUN_00583cf0: ejecuta la tabla de decisiones consecutivas de la CPU.
func f583cf0() -> int:
	var target := m.u32(0x5ad3a8 + m.u8(0xa13439) * 4)
	if target == 0:
		return 1
	if invoke_original(target) != 0:
		m.set_u8(0xa13439, m.u8(0xa13439) + 1)
		m.set_u8(0xa1343d, 0)
		m.set_u8(0xa1343a, 0)
	return 0

## FUN_0057ebc0: escoge invocación y tributos comparando simulaciones de batalla.
func f57ebc0(out_damage: int) -> int:
	var blocked := false
	for slot in range(5):
		if (m.u32(0xa126b0 + slot * 0x94) & 0xfff) != 0 and f545620(1, slot, 0x403) != 0:
			blocked = true
			break
	f57e8d0()
	f57e910()
	var best_damage := f57ea80()
	var best_kills := (m.u32(0xa14f00) >> 3) & 7
	f57e8f0()
	var best := -1
	for hand in range(m.u8(0xa1269a)):
		var index := m.u16(0xa12d0c + hand * 4) & 0xfff
		if f57a490(1, index) == 0 or f57dbb0(2, f401a70(index)) != 0 or f5421c0(index) != 0:
			continue
		var level := f4457d0(index)
		var tributes := 0
		var cost := 0
		if level in [1, 2, 3, 4]:
			if blocked:
				continue
		elif level in [5, 6]:
			tributes = f57ceb0(-1, 0)
			if tributes == -1:
				continue
			cost = f547c60(1, tributes)
			tributes |= 8
		else:
			var first := f57ceb0(-1, 0)
			var second := f57ceb0(first, 0)
			if first == -1 or second == -1:
				continue
			cost = maxi(f547c60(1, first), f547c60(1, second))
			tributes = (second & 7) | (first << 4) | 8
		if cost >= f445810(index):
			continue
		f57e8d0()
		f57e980(hand, tributes)
		f57e910()
		var damage := f57ea80()
		_o_simulation_counts()
		f57e8f0()
		var result := m.u32(0xa14f00)
		if (damage == best_damage and best_kills < ((result >> 3) & 7) and (result & 0x1c0) != 0) or best_damage < damage:
			if damage > 0:
				best_damage = damage
			best_kills = (result >> 3) & 7
			best = hand
	m.set_u32(out_damage, best_damage)
	return best

## Conserva los contadores de monstruos de la simulación en el resultado de la IA.
func _o_simulation_counts() -> void:
	var flags := m.u16(0xa14f00)
	flags ^= ((f5431b0(1) << 6) ^ flags) & 0x1c0
	flags ^= ((f5431b0(0) << 9) ^ flags) & 0xe00
	m.set_u16(0xa14f00, flags)

## FUN_0057eef0: busca una invocación sin tributos que mejore daño o destrucciones.
func f57eef0() -> int:
	f57e8d0()
	f57e910()
	var best_damage := f57ea80()
	f57e8f0()
	var best := -1
	var best_kills := 0
	for hand in range(m.u8(0xa1269a)):
		var index := m.u16(0xa12d0c + hand * 4) & 0xfff
		if f57a490(1, index) == 0 or f57dbb0(2, f401a70(index)) != 0 or f5421c0(index) != 0 or f4457d0(index) > 4:
			continue
		f57e8d0()
		f57e980(hand, 0)
		f57e910()
		var damage := f57ea80()
		_o_simulation_counts()
		f57e8f0()
		var result := m.u32(0xa14f00)
		if (damage == best_damage and best_kills < ((result >> 3) & 7) and (result & 0x1c0) != 0) or best_damage < damage:
			if damage > 0:
				best_damage = damage
			best_kills = (result >> 3) & 7
			best = hand
	return best

## FUN_0057f9c0: activa una trampa colocada para contrarrestar el efecto consultado.
func f57f9c0(effect: int, id: int) -> int:
	var index := f401ad0(id)
	if m.u16(0xa12698) <= f551230(1, index):
		return 0
	if ((m.u8(0xa133ec) & 0x20) != 0 and ctype(index) == 0x16) or ((m.u8(0xa133ec) & 0x40) != 0 and ctype(index) == 0x15):
		return 0
	for slot in range(5, 10):
		var zone := 0xa126b0 + slot * 0x94
		if (m.u32(zone) & 0xfff) == 0 or (m.u8(zone + 6) & 2) != 0 or (m.u8(zone + 0x8f) & 2) == 0:
			continue
		if (f401a70(m.u16(zone) & 0xfff) & 0xffff) != id or f551dc0(effect, 1, slot) == 0:
			continue
		issue(0x8007, 0, 0, 0)
		f54e640(1, slot, 0)
		var descriptor := (((m.u16(effect + 2) & 0xfffffc40) | ((slot & 0x1f) | 0xffff8020) << 1) << 15) | (m.u32(zone) & 0xfff)
		f53bac0(descriptor & 0xffffffff, m.u32(effect + 6))
		return 1
	return 0

## FUN_00580370: busca y prepara la activación de una carta de la CPU por id.
func f580370(id: int) -> int:
	var hand := f57d2c0(1, id)
	var index := f401ad0(id)
	var kind := ctype(index)
	if kind > 0x14 and kind < 0x17 and csub(index) == 2:
		if (m.u32(0xa12c78) & 0xfff) != 0 or f543fc0() == s16(id):
			return 0
	var effect := m.local(20)
	var equip_ids := [300, 0x12d, 0x12e, 0x12f, 0x130, 0x131, 0x132, 0x133, 0x134, 0x135, 0x136, 0x137, 0x138, 0x139, 0x13a, 0x13b, 0x13c, 0x13e, 0x140, 0x141, 0x142, 0x143, 0x144, 0x145, 0x146, 0x147, 0x28b, 0x28d, 0x291, 0x29b, 0x3f4, 0x3f5, 0x412, 0x49e, 0x4b3, 0x58c]
	if (id & 0xffff) in equip_ids:
		var valid := false
		for slot in range(5):
			m.clear(effect, 20)
			m.set_u16(effect, index)
			m.set_u8(effect + 2, 1)
			if f54fc80(effect, ((slot & 0xff) << 8) | 1) != 0:
				valid = true
		if not valid:
			return 0
	if f551230(1, index) >= m.u16(0xa12698):
		return 0
	if ((m.u8(0xa133ec) & 0x20) != 0 and kind == 0x16) or ((m.u8(0xa133ec) & 0x40) != 0 and kind == 0x15):
		return 0
	for slot in range(5, 10):
		var zone := 0xa126b0 + slot * 0x94
		m.clear(effect, 20)
		m.set_u16(effect, m.u16(zone) & 0xfff)
		m.set_u16(effect + 2, ((slot & 0x3f) << 4) | 1)
		if m.u16(effect) != 0 and (m.u8(zone + 0x8f) & 2) != 0 and (m.u8(zone + 6) & 2) == 0:
			if f401a70(m.u16(effect)) == s16(id) and f551a40(effect, 0, 0) != 0:
				issue(0x8091, slot, 0, 0)
				f53baa0(((m.u32(zone) & 0xfff) | (((slot & 0x1f) | 0xffff8020) << 16)) & 0xffffffff, 0)
				return 1
	if kind != 0x15 and f5435a0(1, index) != 0 and hand >= 0:
		m.clear(effect, 20)
		m.set_u16(effect, m.u16(0xa12d0c + hand * 4) & 0xfff)
		m.set_u8(effect + 2, 0xb1)
		if f551a40(effect, 0, 1) != 0:
			m.set_u8(0xa1343e, hand)
			m.set_u8(0xa1343a, 200)
			return 1
	return 0

## FUN_005806d0: prepara los efectos de monstruos de una tabla priorizada.
func f5806d0() -> int:
	var effect := m.local(20)
	m.set_u8(0xa1343b, 0)
	while m.u8(0xa1343b) < 5:
		m.set_u8(0xa1343c, 0)
		while m.u8(0xa1343c) < 5:
			var slot := m.u8(0xa1343c)
			var zone := 0xa126b0 + slot * 0x94
			var id := m.s16(0x5ad39c + m.u8(0xa1343b) * 2)
			m.clear(effect, 20)
			m.set_u16(effect, m.u16(zone) & 0xfff)
			m.set_u16(effect + 2, (slot << 4) | 1)
			if m.u16(effect) != 0 and f401a70(m.u16(effect)) == id and (m.u8(zone + 6) & 2) != 0 and f551a40(effect, 0, 0) != 0:
				if id == 0x1ff and f580370(0x76e) != 0:
					_o_prepare_hand_effect()
					return 0
				if id != 0x1ff or f5431b0(1) > 1:
					f53baa0(((m.u32(zone) & 0xfff) | (((slot & 0x1f) | 0xffff8040) << 16)) & 0xffffffff, 0)
					return 1
			m.set_u8(0xa1343c, slot + 1)
		m.set_u8(0xa1343b, m.u8(0xa1343b) + 1)
	return 0

## Prepara el descriptor de la carta elegida en la mano de la CPU.
func _o_s32(value: int) -> int:
	return value - 0x100000000 if value >= 0x80000000 else value

func _o_prepare_hand_effect() -> void:
	m.set_u8(0xa1340d, 0)
	m.set_u8(0xa1340f, m.u8(0xa1340f) | 1)
	m.set_u8(0xa13408, m.u8(0xa13408) | 2)
	m.set_u8(0xa13410, m.u8(0xa1343e))
	m.set_u16(0xa13404, m.u16(0xa12d0c + m.u8(0xa1343e) * 4) & 0xfff)

## FUN_00581430: considera Cambio de Corazón antes de otras decisiones de la fase.
func f581430() -> int:
	var state := m.u8(0xa1343a)
	if state == 0:
		if (m.u16(0xa1194a) & 0x2000) == 0:
			var own := f57d6f0(1, -1, 1, 0)
			var stats := m.local(12)
			for slot in range(5):
				var zone := 0xa1195c + slot * 0x94
				if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 1) == 0:
					f546470(0, slot, stats)
					if _o_s32(m.u32(stats + 4)) < own and f580370(0x3ca) != 0:
						return 0
		return 1
	if state == 200:
		_o_prepare_hand_effect()
		m.set_u8(0xa1343a, 201)
	elif state != 201:
		return 1
	var allowed := int(f542f30(0, 0x49c) == 0 and f542f30(1, 0x49c) == 0)
	f570040(allowed, 0, 0)
	if (m.u8(0xa13408) & 2) == 0:
		m.set_u8(0xa1343a, 0)
	return 0

## FUN_00582190: decide si merece la pena voltear un monstruo por su efecto.
func f582190(slot: int) -> int:
	var player := m.u8(0xa133f2) & 1
	var enemy := 1 - player
	if f544100(player, slot) == 0 or f56e600(player) == 0:
		return 0
	var zone := 0xa1195c + player * 0xd54 + slot * 0x94
	if (m.u8(zone + 6) & 2) != 0:
		return 0
	var id := f401a70(m.u32(zone) & 0xfff) & 0xffff
	if f541d10(id, 0) == 0:
		return 0
	if id == 0x24e:
		return int(m.u8(0xa11946 + player * 0xd54) < 6)
	if id in [0x53, 0xdf]:
		return int(f543a50(enemy, 0x15) + f543cd0(enemy, 0) != 0)
	if id == 0x249:
		return int(f543b40(enemy) > 1)
	if id in [500, 0x21c, 0x259, 0x280]:
		return int(f5431b0(enemy) != 0)
	if id in [0x452, 0x48b]:
		return int(f5431b0(enemy) >= f5431b0(player))
	return 1

## FUN_00581e40: coloca magias y trampas según los recursos del rival.
func f581e40() -> int:
	var player := m.u16(0xa133f2) & 1
	var enemy := 1 - player
	if f57ce60(player) == 0:
		return 1
	if m.u8(0xa1343d) == 0:
		if f581430() == 0:
			return 0
		m.set_u8(0xa1343a, 0)
	elif m.u8(0xa1343d) == 1:
		while m.u8(0xa1343a) < m.u8(0xa11946 + player * 0xd54):
			var hand := m.u8(0xa1343a)
			var index := m.u16(0xa11fb8 + player * 0xd54 + hand * 4) & 0xfff
			var slot := f543570(player)
			if slot < 0:
				return 1
			var id := f401a70(index) & 0xffff
			var place := false
			if id == 0x136:
				place = true
			elif id in [0x406, 0x409, 0x405, 0x482]:
				var kind := 0x15 if id in [0x406, 0x409] else 0x16
				for target in range(5, 10):
					var zone := 0xa1195c + target * 0x94 + enemy * 0xd54
					var entry := m.u16(zone) & 0xfff
					if entry != 0 and ctype(entry) == kind and (m.u8(zone + 6) & 2) == 0:
						place = true
				if kind == 0x16:
					for h in range(m.u8(0xa11946 + enemy * 0xd54)):
						if ctype(m.u16(0xa11fb8 + enemy * 0xd54 + h * 4) & 0xfff) == 0x16:
							place = true
			elif id not in [0x4dd, 0x522]:
				place = ctype(index) == 0x15 or (ctype(index) == 0x16 and csub(index) == 5)
			if place:
				f56e0b0(player)
				issue((m.u16(0xa133f2) << 15) | 0xc5, f401a70(index), (hand << 4) | (slot & 0xf), 0)
				return 0
			m.set_u8(0xa1343a, hand + 1)
	else:
		return 1
	m.set_u8(0xa1343d, m.u8(0xa1343d) + 1)
	return 0

## FUN_00583840: ajusta las posiciones de monstruos antes de la batalla.
func f583840() -> int:
	var stage := m.u8(0xa1343d)
	if stage == 0:
		f5806d0()
		m.set_u8(0xa1343a, 0)
	elif stage == 1:
		var player := m.u8(0xa133f2) & 1
		if (m.u8(0xa1194b + player * 0xd54) & 0x20) != 0:
			return 1
		var stats := m.local(12)
		while m.u8(0xa1343a) < 5:
			var slot := m.u8(0xa1343a)
			if f544100(player, slot) == 0:
				m.set_u8(0xa1343a, slot + 1)
				continue
			var flip_allowed := f56e600(player)
			var zone := 0xa1195c + player * 0xd54 + slot * 0x94
			var flags := m.u16(zone + 6)
			var attack := f547c60(player, slot)
			if (flags & 2) == 0:
				m.set_u16(zone + 6, flags | 2)
				attack = f547c60(player, slot)
				m.set_u8(zone + 6, m.u8(zone + 6) & 0xfd)
			var id := f401a70(m.u16(zone) & 0xfff)
			var flip := false
			if (flags & 2) == 0 and flip_allowed != 0:
				flip = (id == 500 and f5431b0(1 - player) > 0) or id == 0x2fa or (id == 0x452 and f57d6f0(1, -1, 1, 1) < f57d6f0(0, -1, 1, 0))
			if flip:
				f57cad0(player, slot)
				m.set_u8(0xa1343a, slot + 1)
				return 0
			f546470(1, slot, stats)
			var atk := _o_s32(m.u32(stats + 4))
			var def := _o_s32(m.u32(stats + 8))
			var prefer_def := f57e6e0(attack) == 0 or attack < 1 or f581bf0(atk, def) == 1
			if prefer_def:
				if f581bf0(atk, def) != 0 and (flags & 3) == 2:
					f54d420(player, slot, 0, 0, 1)
					m.set_u8(0xa1343a, slot + 1)
					return 0
			else:
				if (flags & 3) == 1 and f541d10(id, 1) == 0 and flip_allowed != 0:
					f57cad0(player, slot)
					m.set_u8(0xa1343a, slot + 1)
					return 0
				if (flags & 3) == 3:
					f54d420(player, slot, 0, 0, 1)
					m.set_u8(0xa1343a, slot + 1)
					return 0
			m.set_u8(0xa1343a, slot + 1)
	else:
		return 1
	m.set_u8(0xa1343d, m.u8(0xa1343d) + 1)
	return 0

## FUN_0057f090: decide si merece la pena encadenar cada trampa de respuesta.
func f57f090(effect: int) -> int:
	if effect == 0:
		return 0
	var index := m.u16(effect)
	var kind := ctype(index)
	var lp := m.u16(0xa12698)
	var enemy_lp := m.u16(0xa11944)
	if lp <= f551230(1, index) or ((m.u8(0xa133ec) & 0x20) != 0 and kind == 0x16) or ((m.u8(0xa133ec) & 0x40) != 0 and kind == 0x15):
		return 0
	var id := f401a70(index) & 0xffff
	if id in [0x44a, 0x44b, 0x2ad, 0x2a8, 0x2a9, 0x3de, 0x3ea, 0x415, 0x447, 0x52b, 0x474, 0x475, 0x47b, 0x47f, 0x4b3, 0x4b4, 0x517, 0x518, 0x52d, 0x587, 0x58f, 0x590, 0x5a7, 0x5f8, 0x600]:
		return 1
	var p := m.u8(effect + 6)
	var z := m.u8(effect + 7)
	var target_p := m.u8(effect + 8)
	var target_z := m.u8(effect + 9)
	match id:
		0x3f7:
			if (m.u16(effect + 2) & 1) != 0 and (m.u16(effect + 2) & 0xfc00) == 0x4400:
				var enemy := z if p == 0 else target_z
				var own := z if target_p == 0 else target_z
				var flags := m.u16(0xa126b6 + own * 0x94)
				if (flags & 3) == 2:
					var stats := m.local(12)
					f546470(0, enemy, stats)
					var enemy_attack := _o_s32(m.u32(stats + 4))
					# ASM 0x57f3fe: lee DEF de la salida antes de comprobar la posición.
					if (m.u8(0xa11962 + enemy * 0x94) & 1) != 0:
						enemy_attack = _o_s32(m.u32(stats + 8))
					f546470(1, own, stats)
					var own_attack := _o_s32(m.u32(stats + 4))
					return int(own_attack <= enemy_attack and enemy_attack - own_attack < 500)
		0x3c0:
			var attack := f547c60(p, z)
			if target_z < 5:
				var flags := m.u8(0xa11962 + (target_p & 1) * 0xd54 + target_z * 0x94)
				var defense := f547c80(target_p, target_z) if (flags & 1) != 0 else f547c60(target_p, target_z)
				return int(defense <= attack)
			return int(lp <= attack or attack > 1499)
		0x15c:
			if (m.u8(0xa133f2) & 1) == 0 and (m.u16(effect + 2) & 0xfc00) == 0x4000:
				return int(f547c60(0, z) == f57d6f0(0, -1, 1, 0) or f542f30(1, 0x15c) != 0)
		0x3ab:
			var own := f57d6f0(1, -1, 1, 0)
			if own >= 0 and own < lp and enemy_lp < own:
				return 1
			var enemy := f57d6f0(0, -1, 1, 0)
			if enemy >= 0 and enemy < lp:
				return int(enemy_lp < enemy or (enemy > 1499 and _o_s32((enemy_lp - enemy) & 0xffffffff) < lp))
		0x3ed:
			var strongest := 0
			for slot in range(5):
				strongest = maxi(strongest, maxi(f547c60(1, slot), f547c80(1, slot)))
			for slot in range(5):
				if (m.u8(0xa11962 + slot * 0x94) & 2) != 0 and f547c60(0, slot) > strongest:
					return 1
		0x408:
			if f5431b0(0) * 500 < enemy_lp:
				return int(rng.rand() % 3 + 1 < f5431b0(0))
			return 1
		0x40e:
			return int(f57d2c0(1, 0x4c5) != 0 or f57d2c0(1, 0x42f) != 0)
		0x41f, 0x420:
			if id == 0x41f and ((m.u16(effect + 2) & 1) == 0 or (m.u16(effect + 2) & 0xfc00) != 0x4000):
				return 0
			var attack := f547c60(p, z)
			var flags := m.u8(0xa11962 + (target_p & 1) * 0xd54 + target_z * 0x94)
			var target_value := f547c60(target_p, target_z) if (flags & 1) == 0 else f547c80(target_p, target_z)
			if target_value <= attack:
				if lp <= f547c60(p, z) or (f5431b0(1) == 0 and f5431b0(0) > 1):
					return 1
				var damage := f57da00(p)
				return int(damage >= lp or f57da00(1 - p) <= damage)
		0x444:
			return int(f5431f0(1, 1, 0) + f5431f0(0, 1, 0) > 2)
		0x47e:
			var count := 0
			for player in range(2):
				for slot in range(5):
					var entry := m.u32(0xa1195c + player * 0xd54 + slot * 0x94) & 0xfff
					if entry != 0 and f542150(entry) != 0:
						count += 1
			if count * 500 > enemy_lp:
				return 1
			var advantage := 0
			for slot in range(5):
				var enemy := m.u32(0xa1195c + slot * 0x94) & 0xfff
				var own := m.u32(0xa126b0 + slot * 0x94) & 0xfff
				if enemy != 0 and f542150(enemy) != 0:
					advantage += 1
				if own != 0 and f542150(own) != 0:
					advantage -= 1
			return int(advantage > 1)
		0x49a:
			for slot in range(5):
				var zone := 0xa126b0 + slot * 0x94
				if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0 and f543cf0(1, slot) >= 1:
					return 1
		0x4be:
			var attack := f547c60(p, z)
			if (enemy_lp >> 1) <= attack or attack >= lp:
				return 1
			if _o_s32((enemy_lp - attack) & 0xffffffff) <= lp:
				return int(f5431b0(0) == 1)
			return 1
		0x591:
			return int(f5431b0(0) != 0)
	return 0

## FUN_0057fb00: decide qué carta colocada encadenar contra un efecto rival.
func f57fb00(effect: int) -> int:
	var index := m.u16(effect)
	var id := f401a70(index) & 0xffff
	var lp := m.u16(0xa12698)
	var in_chain := (m.u8(effect + 2) & 1) != 0
	var counter := 0
	if id == 0x3ee or (id > 0x148 and id < 0x14f) or id in [0x151, 0x152, 0x153, 0x154, 0x155, 0x42d, 0x465, 0x466, 0x467, 0x468, 0x469, 0x46a]:
		return 0
	var burn_costs := {200: 200, 0xe3: 500, 0xe4: 600, 0xe5: 800, 0xe6: 1000, 0x3ef: 300}
	if burn_costs.has(id) and lp > int(burn_costs[id]):
		return 0
	if id == 0x40f and ((m.u8(0xa1269a) * 200) & 0xffff) < lp:
		return 0
	if id in [0x53, 0xdf, 0x3ec, 0x425, 0x426, 0x42b, 0x46e, 0x46f]:
		counter = 0x2b1
	elif id in [0x14f, 0x150]:
		if in_chain:
			return 0
		if f57f9c0(effect, 0x3fb if id == 0x14f else 0x3fe) != 0:
			return 1
		counter = 0x294
	elif id == 0x15b:
		var count := 0
		for player in range(2):
			for slot in range(5):
				var entry := m.u32(0xa1195c + player * 0xd54 + slot * 0x94) & 0xfff
				if entry != 0 and f542150(entry) != 0:
					count += 1
		if m.u16(0xa11944) < count * 500 and f57f9c0(effect, 0x47e) != 0:
			return 1
		if rng.rand() % 3 + 1 < count:
			counter = 0x47e
	elif id == 0x29f:
		if in_chain or f543480(1, 0, 0, 0) == 0:
			return 0
		if f57f9c0(effect, 0x426) != 0 or f57f9c0(effect, 0x2b1) != 0:
			return 1
		if f543480(1, 0, 0, 0) > 1 and m.u8(0xa1269a) != 0 and f57f9c0(effect, 0x405) != 0:
			return 1
		for slot in range(5, 11):
			var zone := 0xa126b0 + slot * 0x94
			if (m.u8(zone + 6) & 2) == 0:
				var card_id := f401a70(m.u16(zone) & 0xfff) & 0xffff
				if card_id in [0x43a, 0x3f7, 0x3f8, 0x433, 0x434, 0x4b3, 0x4b4, 0x5a7] and f57f9c0(effect, card_id) != 0:
					return 1
		return 0
	elif id in [0x3f1, 0x437]:
		if in_chain:
			return 0
		if f57f9c0(effect, 0x2b1) != 0:
			return 1
		var zone := 0xa1195c + (m.u8(effect + 12) & 1) * 0xd54 + m.u8(effect + 13) * 0x94
		if (m.u32(zone) & 0xfff) != 0 and f401a70(m.u16(zone) & 0xfff) in [0x136, 0x405]:
			return 0
	elif id == 0x3f0:
		if in_chain:
			return 0
		if f57f9c0(effect, 0x3fd) != 0:
			return 1
		counter = 0x402
	elif id in [499, 0x455, 0x462, 0x4d8, 0x4de, 0x534]:
		counter = 0x3ea
	if counter != 0 and f57f9c0(effect, counter) != 0:
		return 1
	if f541d10(f401a70(index), 0) != 0 and f57f9c0(effect, 0x3ea) != 0:
		return 1
	var kind := ctype(index)
	if kind == 0x15 and not in_chain:
		if f57f9c0(effect, 0x409) != 0:
			return 1
		if lp >= 1001 and f57f9c0(effect, 0x406) != 0:
			return 1
	elif kind == 0x16 and not in_chain:
		if f57f9c0(effect, 0x482) != 0:
			return 1
		if m.u8(0xa1269a) != 0 and f57f9c0(effect, 0x405) != 0:
			return 1
	return int(f57f9c0(effect, 0x5a7) != 0)

## FUN_00580940: recorre las prioridades de activación de magias de la CPU.
func f580940() -> int:
	var state := m.u8(0xa1343a)
	var activate := 0
	match state:
		0:
			if (m.u32(0xa16184) & 0x200) != 0:
				m.set_u8(0xa1343a, 100)
				return 0
		1:
			if f580370(0x3f2) != 0 or f580370(0x410) != 0:
				return 0
			if f5431b0(0) > 0 and f5431b0(1) == 0 and f580370(0x14f) != 0:
				return 0
			if f5808c0() != 0 and f580370(0x14f) != 0:
				return 0
			if f57d7d0(1, -1, 1, 1) < f57d7d0(0, -1, 1, 0) and f580370(0x14f) != 0:
				return 0
			if f5431b0(0) > 0 and f5431b0(1) == 0 and f580370(0x150) != 0:
				return 0
			if f5431b0(0) > 0 and f580370(0x150) != 0:
				return 0
			if f5431f0(0, 0, 0) > 0 and f544be0(1) > 0 and f580370(0x3ff) != 0:
				return 0
			if f5431b0(0) < f5431b0(1) and f580370(0x423) != 0:
				return 0
			if f5431f0(0, 1, 0) >= 1:
				activate = 0x3e9
		2:
			if f544280(0, -1) > 0 and (m.u8(0xa126a0) & 0x10) == 0 and f542f30(0, 0x15b) == 0:
				for hand in range(m.u8(0xa1269a)):
					var index := m.u16(0xa12d0c + hand * 4) & 0xfff
					if ctype(index) != 0 and ctype(index) < 0x15 and f5421c0(index) == 0 and f4457d0(index) > 4 and (f4457d0(index) < 7 or f5431b0(1) != 0):
						if f580370(0x403) != 0 or f580370(0x42c) != 0:
							return 0
			for slot in range(5):
				var zone := 0xa1195c + slot * 0x94
				if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0 and f547c60(0, slot) > 1799 and f580370(0x42c) != 0:
					return 0
			if f580370(0x3f0) != 0:
				return 0
			var target := f57d330(f401ad0(0x488))
			if target >= 0:
				var index := m.u32(0xa11624 + target * 4) & 0xfff
				if f445810(index) >= 1001 or (f541950(index) == 1 and f541d10(f401a70(index), 0) == 0):
					activate = 0x488
		3:
			if (m.u32(0xa16184) & 1) != 0:
				if f57d2c0(1, 0x3f0) != -1 and f580370(0x3c8) != 0:
					return 0
				if f57d2c0(1, 0x488) != -1 and f580370(0x3c8) != 0:
					return 0
				for i in range(mini(3, m.u8(0xa1269b))):
					var id := f401a70(m.u16(0xa12e4c + i * 4) & 0xfff)
					if id in [0x3f0, 0x14f, 0x150, 0x3c8, 0x488] and f580370(0x3c8) != 0:
						return 0
			else:
				activate = 0x3c8
		4:
			var valuable := f542e60(1, 0x40e, -1) > 0
			for id in [0x10, 0x11, 0x12, 0x13, 0x14, 0x14f, 0x150, 0x290, 0x3f0, 0x403, 0x420, 0x42c, 0x488]:
				# El original compara con cero, incluso cuando no hay carta (-1).
				if f57d2c0(0, id) != 0:
					valuable = true
			if valuable and f580370(0x4c5) != 0:
				return 0
			m.set_u8(0xa1343a, (state + 1) & 0xff)
			m.set_u8(0xa1343b, 0)
			m.set_u8(0xa1343c, 0)
			return 0
		5:
			m.set_u8(0xa1343b, 0)
			while m.u8(0xa1343b) < 0x37:
				var i := m.u8(0xa1343b)
				if f580370(m.s16(0x59e448 + i * 2)) != 0:
					return 0
				m.set_u8(0xa1343b, i + 1)
			var effect := m.local(20)
			if f5431f0(1, 1, 0) > 0:
				m.set_u8(0xa1343b, 0)
				while m.u8(0xa1343b) < 0x25:
					var i := m.u8(0xa1343b)
					var id := m.s16(0x59e4b8 + i * 2)
					m.clear(effect, 20)
					m.set_u16(effect, f401ad0(id))
					m.set_u16(effect + 2, 1)
					var target := f57d8b0(effect, 1, -1)
					if target >= 0 and f547c60(1, target) > 1299 and f580370(id) != 0:
						return 0
					m.set_u8(0xa1343b, i + 1)
			if f5431f0(1, 1, 0) > 0 and m.u16(0xa12698) < m.u16(0xa11944) and f57d6f0(1, -1, 1, 0) > 1499:
				m.clear(effect, 20)
				m.set_u16(effect, f401ad0(0x290))
				m.set_u16(effect + 2, 1)
				var target := f57d8b0(effect, 1, -1)
				if f545620(1, target, 0x290) != 0:
					target = f57d8b0(effect, 1, target)
				if target >= 0 and f547c60(1, target) > 1499 and f580370(0x290) != 0:
					return 0
			if f5431b0(0) > 0:
				var strongest := 0
				for slot in range(5):
					var zone := 0xa126b0 + slot * 0x94
					if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 1) == 0:
						strongest = maxi(strongest, f547c60(1, slot))
				for slot in range(5):
					var zone := 0xa1195c + slot * 0x94
					if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 1) == 0:
						f546470(0, slot, effect)
						if strongest <= _o_s32(m.u32(effect + 4)) and _o_s32(m.u32(effect + 8)) < strongest and f580370(0x413) != 0:
							return 0
			return 1
		100:
			if f57dad0() == 0 and (f5430d0(1, 0x2f) >= 1 or f5430d0(1, 0x23d) >= 1):
				activate = 0x14f
		101:
			if f580370(0x3c8) != 0 or f580370(0x3f2) != 0:
				return 0
		102:
			if f57dad0() == 0 and (f5431f0(0, 1, 0) < 1 or f5431b0(1) != 0):
				return 1
			if f542e60(1, 0x15b, -1) != 0:
				return 1
			return 0 if f580370(0x15b) != 0 else 1
		200, 201:
			if state == 200:
				_o_prepare_hand_effect()
				m.set_u8(0xa1343a, 201)
			f570040(int(f542f30(0, 0x49c) == 0 and f542f30(1, 0x49c) == 0), 0, 0)
			if (m.u8(0xa13408) & 2) == 0:
				m.set_u32(0xa1343a, m.u32(0xa1343a) & 0xffffff)
			return 0
		_:
			return 1
	if activate != 0 and f580370(activate) != 0:
		return 0
	m.set_u8(0xa1343a, m.u8(0xa1343a) + 1)
	return 0

## FUN_00581580: selecciona invocación defensiva o de efecto para la CPU.
func f581580() -> int:
	var blocked := false
	for slot in range(5):
		if (m.u32(0xa126b0 + slot * 0x94) & 0xfff) != 0 and f545620(1, slot, 0x403) != 0:
			blocked = true
			break
	if not blocked and f543330(1) != 0:
		if f5431b0(0) >= 2:
			var hand := f57d2c0(1, 0x259)
			if hand >= 0:
				return hand
		if f5431b0(0) >= 1:
			for id in [500, 0x21c, 0x259, 0xff, 0x419]:
				var hand := f57d2c0(1, id)
				if hand >= 0:
					return hand
		if f543ab0(1, 0x16) >= 1:
			var hand := f57d2c0(1, 0x1ab)
			if hand >= 0:
				return hand
		if f543ab0(1, 0x15) >= 1:
			var hand := f57d2c0(1, 0x65)
			if hand >= 0:
				return hand
		if not (m.u8(0xa1269a) > 2 and m.u8(0xa11946) <= m.u8(0xa1269a) + 2):
			for id in [0x21b, 0x24e]:
				var hand := f57d2c0(1, id)
				if hand >= 0:
					return hand
		if m.u8(0xa11947) <= 4:
			var hand := f57d2c0(1, 0x231)
			if hand >= 0:
				return hand
		for pair in [[0x246, f543a30(0, 0x15b)], [0x27, f543a30(0, 0x148)], [0x109, f543b40(0) - 1], [0x249, f543cd0(0, 0) - 1], [0xdf, f543cd0(0, 0)]]:
			if int(pair[1]) >= 1:
				var hand := f57d2c0(1, int(pair[0]))
				if hand >= 0:
					return hand
		if f5431b0(0) >= 1 and f5431b0(1) == 0:
			for id in [0x48b, 0x452, 0x45a, 0x45b, 0x51b]:
				var hand := f57d2c0(1, id)
				if hand >= 0:
					return hand
	var strongest_enemy := 0
	for slot in range(5):
		strongest_enemy = maxi(strongest_enemy, f547c60(0, slot))
	var strongest_own := f57d6f0(1, -1, 1, 0)
	var best := -1
	for hand in range(m.u8(0xa1269a)):
		var index := m.u16(0xa12d0c + hand * 4) & 0xfff
		var value := maxi(f445810(index), f445850(index))
		if f57a490(1, index) == 0 or f57dbb0(2, f401a70(index)) != 0 or f5421c0(index) != 0:
			continue
		if not ((strongest_own < value and strongest_enemy <= value) or (blocked and f4457d0(index) > 4)):
			continue
		if f4457d0(index) < 5 and f543330(1) == 0:
			continue
		if f57d060(index) != 0:
			strongest_own = value
			best = hand
	if best >= 0:
		return best
	if f543330(1) != 0:
		for hand in range(m.u8(0xa1269a)):
			var index := m.u16(0xa12d0c + hand * 4) & 0xfff
			if f4457d0(index) < 5 and f57a490(1, index) != 0 and f57dbb0(2, f401a70(index)) == 0 and f5421c0(index) == 0:
				return hand
	return -1

## FUN_00583250: alterna invocaciones, efectos y magias en la fase principal.
func f583250() -> int:
	var player := m.u16(0xa133f2) & 1
	var stage := m.u8(0xa1343d)
	match stage:
		0:
			if (m.u8(0xa1194c + player * 0xd54) & 0x10) != 0 or f56e600(player) == 0 or f57ce60(player) == 0:
				if m.u8(0xa13439) > 3:
					return 1
				if m.u16(0xa133f0) != 0:
					m.set_u8(0xa1343d, 1)
					return 0
				return 1
			if f542e60(1 - player, 0x15b, -1) > 0:
				m.set_u8(0xa1343d, 1)
				return 0
			if m.u16(0xa133f0) == 0:
				m.set_u8(0xa1343d, 10)
				return 0
			var blocked := false
			for slot in range(5):
				if (m.u32(0xa126b0 + slot * 0x94) & 0xfff) != 0 and f545620(1, slot, 0x403) != 0:
					blocked = true
					break
			var hand := -1
			if not blocked and f57eb90(1) != 0:
				hand = f57eef0()
			var immediate := hand >= 0
			if hand < 0:
				hand = f57ebc0(m.local(4))
			if hand >= 0:
				var acted := _o_summon_from_hand(player, hand, 0, immediate, false)
				if acted == 1:
					return 1
				if acted == 2:
					return 0
		1:
			m.set_u8(0xa1343a, 0)
			m.set_u8(0xa1343b, 0)
			m.set_u8(0xa1343c, 0)
		2:
			if f5806d0() != 0:
				m.set_u8(0xa1343d, 0)
				return 0
		3:
			if f5808b0() == 0:
				return 0
			m.set_u8(0xa1343a, 0)
			m.set_u8(0xa1343b, 0)
			m.set_u8(0xa1343c, 0)
		4:
			if f580940() != 0:
				m.set_u8(0xa1343c, 0)
				m.set_u8(0xa1343b, 0)
				m.set_u8(0xa1343a, 0)
				m.set_u8(0xa1343d, 10)
			return 0
		10:
			if f57ce60(player) == 0 or (m.u8(0xa1194c + player * 0xd54) & 0x10) != 0:
				return 1
			var hand := f581580()
			if hand < 0:
				return 1
			var acted := _o_summon_from_hand(player, hand, 1, false, true)
			if acted == 2:
				return 0
			if acted == 0 and f4457d0(m.u16(0xa11fb8 + player * 0xd54 + hand * 4) & 0xfff) == 0:
				return 1
			m.set_u8(0xa1343d, 1)
			return 0
		_:
			return 1
	m.set_u8(0xa1343d, m.u8(0xa1343d) + 1)
	return 0

## Comparte la emisión de invocación; 0=sin opción, 1=invocó, 2=volteó tributo.
func _o_summon_from_hand(player: int, hand: int, fallback: int, immediate: bool, defensive: bool) -> int:
	var index := m.u16(0xa11fb8 + player * 0xd54 + hand * 4) & 0xfff
	var position := int(f581cd0(index, fallback) == 0)
	var level := f4457d0(index)
	var slot := f543360(player)
	var tributes := 0
	var issuer := player
	if immediate:
		f57c800(issuer, hand, slot, tributes, position)
		return 1
	if level == 0:
		return 0
	if level < 5:
		if defensive and slot < 0:
			return 0
	elif level < 7:
		slot = f57ceb0(-1, 0)
		if slot == -1:
			return 0
		if f582190(slot) != 0:
			f57cad0(player, slot)
			return 2
		tributes = slot | 0x90
	else:
		slot = f57ceb0(-1, 0)
		var second := f57ceb0(slot, 0)
		if slot == -1 or second == -1:
			return 0
		for tribute in [slot, second]:
			if f582190(tribute) != 0:
				f57cad0(player, tribute)
				return 2
		tributes = ((second & 0xff) << 8) | (slot & 0xff) | 0x9090
		issuer = 1
	f57c800(issuer, hand, slot, tributes, position)
	return 1

## FUN_00582360: usa magias de la tabla prioritaria y las invocaciones especiales.
func f582360() -> int:
	var player := m.u16(0xa133f2) & 1
	var stage := m.u8(0xa1343d)
	var effect := m.local(20)
	if stage == 0:
		m.set_u8(0xa1343a, 0)
		while m.u8(0xa1343a) < 25:
			var i := m.u8(0xa1343a)
			var id := m.s16(0x59e504 + i * 2)
			if f543cd0(player, id) != 0:
				var index := f401ad0(id)
				if _o_priority_spell(id, player, false) and _o_can_pay_spell(player, index):
					m.clear(effect, 20)
					m.set_u16(effect, index)
					for slot in range(5, 10):
						var offset := slot * 0x94
						var entry := m.u32(0xa1195c + offset + player * 0xd54) & 0xfff
						# Dirección literal del original: la comprobación apunta al bloque CPU.
						if entry != 0 and entry == index and (m.u8(0xa1273f + offset) & 2) != 0 and f5691b0(effect, 1, slot) != 0:
							issue((m.u16(0xa133f2) << 15) | 0x91, slot, 0, 0)
							f53baa0((((slot & 0x1f) | 0xffff8020) << 16 | (index & 0xffff)) & 0xffffffff, 0)
							return 0
			m.set_u8(0xa1343a, i + 1)
		m.set_u8(0xa1343d, 1)
		stage = 1
	if stage == 1:
		m.set_u8(0xa1343a, 0)
		while m.u8(0xa1343a) < 25:
			var i := m.u8(0xa1343a)
			var id := m.s16(0x59e504 + i * 2)
			if f57d2c0(player, id) >= 0:
				var index := f401ad0(id)
				if _o_priority_spell(id, player, true) and _o_can_pay_spell(player, index):
					m.clear(effect, 20)
					m.set_u16(effect, index)
					m.set_u32(effect + 2, 0xb1)
					if f551a40(effect, 0, 1) != 0 and f5435a0(player, index) != 0:
						m.set_u8(0xa1343d, 2)
						return 0
			m.set_u8(0xa1343a, i + 1)
		m.set_u8(0xa1343d, 3)
		return 0
	if stage == 2:
		var id := m.u16(0x59e504 + m.u8(0xa1343a) * 2)
		var hand := f57d2c0(player, id)
		var slot := f543570(player)
		var immediate := f542f30(1 - player, 0x49c) == 0 and f542f30(player, 0x49c) == 0
		var argument := ((hand << 4) | (slot & 0xf)) & 0xff
		issue((m.u16(0xa133f2) << 15) | 0xc5, id, argument | (0x100 if immediate else 0), 0)
		if immediate:
			f53baa0(((((f543570(player) & 0x1f) | 0xffff8020) << 16) | (f401ad0(id) & 0xffff)) & 0xffffffff, 0)
		m.set_u8(0xa1343d, 0)
		return 0
	if stage == 3:
		if f57ce60(player) != 0 and f57d2c0(player, 0x1a8) >= 0 and f56ba50(player, 0x1a8, 0) > 0:
			f56e0b0(player)
			f54e680(player, f57d2c0(player, 0x1a8), 0, 1)
			f53baa0(((f401ad0(0x1a8) & 0xffff) | (m.u16(0xa133f2) << 31) | 0x6e0000) & 0xffffffff, 0)
			m.set_u8(0xa1343d, 0)
			return 0
		m.set_u8(0xa1343d, 4)
		stage = 4
	if stage >= 4 and stage <= 6:
		while stage <= 6:
			var id := 0x546 if stage == 4 else (0x17a if stage == 5 else 0x5f0)
			var can_summon := f57ce60(player) != 0 and f57d2c0(player, id) >= 0 and f543330(player) != 0
			if can_summon and stage == 4:
				can_summon = f5431b0(1 - player) - f5431b0(player) > 1
			if can_summon and stage == 5:
				can_summon = f543010(1 - player, 0x4db) + f543010(player, 0x4db) > 0
			if can_summon:
				var position := int(f581cd0(f401ad0(id), 0) == 0)
				f57cd30(player, f57d2c0(player, id), f543360(player), 0, position)
				m.set_u8(0xa1343d, 0)
				return 0
			stage += 1
			m.set_u8(0xa1343d, stage)
	return 1

## Restricciones de coste y prohibiciones de magia/trampa usadas por la IA.
func _o_can_pay_spell(player: int, index: int) -> bool:
	if m.u16(0xa11944 + player * 0xd54) <= f551230(player, index):
		return false
	var kind := ctype(index)
	return not (((m.u8(0xa133ec) & 0x20) != 0 and kind == 0x16) or ((m.u8(0xa133ec) & 0x40) != 0 and kind == 0x15))

## Condiciones de la tabla de magias; cambian si la carta viene de la mano.
func _o_priority_spell(id: int, player: int, from_hand: bool) -> bool:
	var enemy := 1 - player
	if id > 0x150 and id < 0x15a:
		return true
	if id in [0x3ee, 0x3ef, 0x427, 0x42e, 0x435]:
		return true
	match id:
		0x15a:
			if from_hand:
				return m.u16(0xa11944 + enemy * 0xd54) < 2000 and m.u16(0xa11944 + player * 0xd54) > 1500
			return m.u16(0xa11944 + enemy * 0xd54) < m.u16(0xa11944 + player * 0xd54) + 500
		0x294:
			return not from_hand and f57d6f0(0, -1, 1, 0) > 1499
		0x29f, 0x437:
			return f543b40(enemy) > 0
		0x438:
			return f543b40(enemy) > 0 and (not from_hand or f543b40(player) == 0)
		0x425:
			return f543b40(enemy) > 0 and f543b40(player) == 0
		0x3ec:
			return f543a50(enemy, 0x15) > 0
		0x3f1:
			return f543a50(enemy, 0x16) > 0
		0x40f:
			if from_hand:
				return false
			var hand := m.u8(0xa11946 + enemy * 0xd54)
			return hand > 2 or hand * 200 > m.u16(0xa11944 + enemy * 0xd54)
		0x42f:
			return m.u8(0xa11946 + enemy * 0xd54) != 0
		0x485, 0x486:
			for slot in range(0 if id == 0x485 else 5, 5 if id == 0x485 else 10):
				var zone := 0xa1195c + enemy * 0xd54 + slot * 0x94
				if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) == 0:
					return true
	return false


