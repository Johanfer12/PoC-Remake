class_name DuelPortH
extends DuelPortG
## Rutinas de efectos del original Yugi, lote H.

func _h_zone(loc: int) -> int:
	return 0xa1195c + (loc & 1) * 0xd54 + (loc >> 8) * 0x94

## FUN_00551050: objetivo magia boca arriba en zona 5 a 10.
func f551050(_effect: int, loc: int) -> int:
	var z := loc >> 8
	var a := _h_zone(loc)
	return int(z > 4 and z < 11 and (m.u32(a) & 0xfff) != 0 and (m.u8(a + 6) & 2) != 0 and ctype(m.u32(a) & 0xfff) == 22)

## FUN_005510b0: objetivo fuera de monstruos y del otro jugador.
func f5510b0(effect: int, loc: int) -> int:
	return int((loc >> 8) > 4 and (m.u32(_h_zone(loc)) & 0xfff) != 0 and (m.u8(effect + 2) & 1) != (loc & 0xff))

## FUN_00551100: monstruo visible con bandera de entrada bit16.
func f551100(_effect: int, loc: int) -> int:
	var a := _h_zone(loc)
	if (loc >> 8) < 5 and (m.u32(a) & 0xfff) and (m.u8(a + 6) & 2):
		return m.u8(a + 2) & 1
	return 0

## FUN_00551150: magia o trampa colocada boca abajo.
func f551150(_effect: int, loc: int) -> int:
	var z := loc >> 8
	var a := _h_zone(loc)
	if z > 4 and z < 10 and (m.u32(a) & 0xfff):
		return (m.u8(a + 6) >> 1 & 1) ^ 1
	return 0

## FUN_005511a0: monstruo visible de clase fusión susceptible al efecto.
func f5511a0(effect: int, loc: int) -> int:
	var z := loc >> 8
	var a := _h_zone(loc)
	var idx := m.u16(a) & 0xfff
	if z < 5 and idx != 0 and (m.u8(a + 6) & 2):
		if f54f910(m.u16(effect), loc & 0xff, z) != 0 and ctype(idx) < 21:
			return int(f541950(idx) == 2)
	return 0

## FUN_00551230: coste de LP original por ID de carta.
func f551230(p: int, idx: int) -> int:
	match f401a70(idx):
		0x406, 0x42e, 0x42f, 0x49f, 0x3ba, 0x191:
			return 1000
		0x488:
			return 800
		0x489, 0x3f9:
			return 500
		0x1a3:
			return 5000
		0x1f9:
			return 3000
		0x404, 0x4bc:
			return f53fbf0(m.u16(0xa11944 + (p & 1) * 0xd54))
	return 0

## FUN_00551390: emite el pago de LP del efecto.
func f551390(effect: int) -> int:
	var cost := f551230(m.u8(effect + 2) & 1, m.u16(effect))
	if cost > 0:
		issue((m.u16(effect + 2) << 15) | 0x43, cost, 1, 0)
	return 1

## FUN_005513d0: envía al cementerio la carta del descriptor.
func f5513d0(effect: int) -> int:
	var v := m.u16(effect + 2)
	f54ea40(v & 1, (v >> 4) & 0x3f)
	return 1

## FUN_00551400: retira carta solo durante la fase y participante indicados.
func f551400(effect: int) -> int:
	var v := m.u16(effect + 2)
	if ((v ^ m.u8(0xa133f2)) & 1) == 0 and (v & 0xfc00) == 0x800:
		f54ea40(v & 1, (v >> 4) & 0x3f)
	return 1

## FUN_005515a0: registra ataques a monstruos por efecto con modificador 49c.
func f5515a0(effect: int) -> int:
	var mode := 0
	match f401a70(m.u16(effect)):
		0x3ff, 0x405:
			mode = 1
		0x42b:
			mode = 5
		0x430:
			mode = 2
		_:
			return 1
	var count := f542f30(1, 0x49c) + f542f30(0, 0x49c)
	f53e870(m.u8(effect + 2) & 1, mode, 0, count)
	return 1

## FUN_005518e0: inicia selección de una carta para el efecto.
func f5518e0(e: int) -> int:
	f53e870(m.u8(e + 2) & 1, 1, 1, 0)
	return 1

## FUN_00551910: solicita selección de dos cartas y espera un fotograma.
func f551910(e: int) -> int:
	if m.u8(0xa15fe4):
		return 1
	f53e8f0(m.u8(e + 2) & 1, 2)
	m.set_u8(0xa15fe4, 1)
	return 0

## FUN_00551950: prepara selección de carta y espera un fotograma.
func f551950(e: int) -> int:
	if m.u8(0xa15fe4):
		return 1
	f53e8b0(m.u8(e + 2) & 1, 0, 1)
	m.set_u8(0xa15fe4, 1)
	return 0

## FUN_00551c40: construye descriptor temporal para comprobar el efecto.
func f551c40(p: int, idx: int, location: int) -> int:
	var e := m.local(20)
	m.clear(e, 20)
	m.set_u16(e, idx)
	m.set_u32(e + 2, ((location & 0x3f) << 4) | (p & 1))
	return f551a40(e, 0, int(location == 11))

## FUN_00551cb0: descriptor de comprobación de carta colocada.
func f551cb0(p: int, z: int, reason: int) -> int:
	var e := m.local(20)
	m.clear(e, 20)
	var idx := m.u16(0xa1195c + (p & 1) * 0xd54 + z * 0x94) & 0xfff
	m.set_u16(e, idx)
	m.set_u32(e + 2, (((z & 0x3f) | (reason << 6)) << 4) | (p & 1))
	if idx == 0:
		return 0
	return f551a40(e, 0, 0)

## FUN_00551d40: evita duplicar participantes/zonas en las dos listas de efectos.
func f551d40(p: int, z: int) -> int:
	for pair in [[0xa15fc0, 0xa15e82], [0xa15fc2, 0xa15c02]]:
		for i in range(m.u16(pair[0])):
			var v := m.u16(pair[1] + i * 20)
			if (v & 1) == p and ((v >> 4) & 0x3f) == z:
				return 1
	return 0

## FUN_00552260: reacción de monstruo marcado mientras existe monstruo contrario.
func f552260(e: int, _unused: int, from_hand: int) -> int:
	var v := m.u16(e + 2)
	if from_hand == 0 and (m.u8(0xa11963 + (v & 1) * 0xd54 + ((v >> 4) & 0x3f) * 0x94) & 0x10):
		return _h_monsters(1 - (v & 1))
	return 0

## FUN_005522d0: carta de mano si no se consumió invocación y queda espacio.
func f5522d0(e: int, _unused: int, from_hand: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(from_hand != 0 and not (m.u8(0xa1194c + p * 0xd54) & 0x10) and f543330(p) != 0)

## FUN_00552310: comprueba invocación disponible y presencia de cartas 4e1/3d.
func f552310(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if f56e660(p) == 0 or f543330(p) == 0:
		return 0
	return int(f542f30(1, 0x4e1) + f542f30(0, 0x4e1) + f542f30(1, 0x3d) + f542f30(0, 0x3d) != 0)

func _h_monsters(p: int) -> int:
	for z in range(5):
		if m.u32(0xa1195c + (p & 1) * 0xd54 + z * 0x94) & 0xfff:
			return 1
	return 0

## FUN_00552390: existe cualquier monstruo en el campo.
func f552390() -> int:
	return int(_h_monsters(0) != 0 or _h_monsters(1) != 0)

## FUN_005523d0: existe monstruo contrario.
func f5523d0(e: int) -> int:
	return _h_monsters(1 - (m.u16(e + 2) & 1))

## FUN_00552410: existe monstruo contrario boca abajo.
func f552410(e: int) -> int:
	var p := 1 - (m.u16(e + 2) & 1)
	for z in range(5):
		var a := 0xa1195c + p * 0xd54 + z * 0x94
		if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 2):
			return 1
	return 0

## FUN_00552460: al menos 1000 LP y candidato válido en la lista del efecto.
func f552460(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if m.u16(0xa11944 + p * 0xd54) < 1000:
		return 0
	return int(f56ba50(p, f401a70(m.u16(e)), 0) > 0)

## FUN_00552560: requisitos de LP y fusión para los efectos 1a3 y 1f9.
func f552560(e: int) -> int:
	var p := m.u8(e + 2) & 1
	var id := s16(f401a70(m.u16(e)))
	var lp := m.u16(0xa11944 + p * 0xd54)
	var fusion := m.u8(0xa11949 + p * 0xd54)
	if id == 0x1a3:
		return int(lp > 4999 and fusion != 0 and f56e660(p) != 0 and f543330(p) != 0)
	if id == 0x1f9:
		return int(lp > 2999 and fusion != 0)
	return 0

## FUN_00552610: bandera bit12 de la zona del efecto, salvo carta de mano.
func f552610(e: int, _unused: int, from_hand: int) -> int:
	if from_hand:
		return 0
	var v := m.u16(e + 2)
	return (m.u16(0xa11962 + (v & 1) * 0xd54 + ((v >> 4) & 0x3f) * 0x94) >> 12) & 1

## FUN_00552650: exige al menos dos objetivos entre ambos jugadores.
func f552650() -> int:
	return int(f543480(1, 0, 1, 1) + f543480(0, 0, 1, 1) > 1)

## FUN_00552680: reacción a ataque o presencia de monstruos en posición indicada.
func f552680(e: int, _unused: int, from_hand: int) -> int:
	if from_hand:
		return 0
	var v := m.u16(e + 2)
	if (v & 0xfc00) == 0x4000:
		var p := m.u8(e + 6) & 1
		var a := 0xa1195c + p * 0xd54 + m.u8(e + 7) * 0x94
		if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 1) and (v & 1) != m.u8(e + 6):
			return 1
	return int(f5431f0(v & 1, 1, 0) > 0)

## FUN_005527d0: hay objetivos válidos en campo contrario.
func f5527d0(e: int) -> int:
	return int(f543480(1 - (m.u8(e + 2) & 1), 0, 0, 1) > 0)

## FUN_005529b0: invocación de carta sin equipos y con material disponible.
func f5529b0(e: int, _unused: int, hand: int) -> int:
	var v := m.u16(e + 2)
	var p := v & 1
	var z := (v >> 4) & 0x3f
	if hand == 0 and s16(f5451f0(p, z)) == -1 and f543570(p) != -1:
		return (m.u16(0xa11962 + p * 0xd54 + z * 0x94) >> 12) & 1
	return 0

## FUN_00552a20: comprueba bandera de turno salvo fase inicial propia.
func f552a20(e: int, _unused: int, hand: int) -> int:
	if hand:
		return 0
	var v := m.u16(e + 2)
	if ((v ^ m.u8(0xa133f2)) & 1) != 0 or (v & 0xfc00) != 0x800:
		return 1
	return int(not (m.u8(0xa11963 + (v & 1) * 0xd54 + ((v >> 4) & 0x3f) * 0x94) & 0x10) and f542f30(0, 0x58a) < 1 and f542f30(1, 0x58a) < 1)

## FUN_00552ab0: exige tres cartas concretas y dos zonas vacías sin bloqueo 58a.
func f552ab0(e: int, _unused: int, hand: int) -> int:
	var p := m.u8(e + 2) & 1
	if hand or f543330(p) <= 1 or f542f30(0, 0x58a) >= 1 or f542f30(1, 0x58a) >= 1:
		return 0
	return int(f544a00(p, 0x2e1) != 0 and f544a00(p, 0x2f4) != 0 and f544a00(p, 800) != 0)

## FUN_00552b90: exige al menos 1000 LP.
func f552b90(e: int) -> int:
	return int(m.u16(0xa11944 + (m.u8(e + 2) & 1) * 0xd54) > 999)

## FUN_00552cc0: monstruo invocado visible con fuerza máxima de 2000.
func f552cc0(e: int) -> int:
	var reason := m.u16(e + 2) >> 10
	var p := m.u8(e + 6)
	var z := m.u8(e + 7)
	var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
	return int(reason > 4 and reason < 8 and (m.u32(a) & 0xfff) != 0 and (m.u8(a + 6) & 2) != 0 and f547c60(p, z) < 2001)

## FUN_00552eb0: al menos dos monstruos propios y uno contrario.
func f552eb0(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(f5431b0(p) >= 2 and f5431b0(1 - p) > 0)

## FUN_00552f00: candidato de invocación sin bloqueo por 402.
func f552f00(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if f543330(p) == 0 or f56e660(p) == 0 or f543a30(0, 0x402) >= 1 or f543a30(1, 0x402) >= 1:
		return 0
	return int(f56ba50(p, f401a70(m.u16(e)), 0) > 0)

## FUN_00552f90: candidatos disponibles sin bloqueo contrario 5e7.
func f552f90(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if f542f30(1 - p, 0x5e7) > 0:
		return 0
	return int(f56ba50(p, f401a70(m.u16(e)), 0) > 0)

## FUN_00553280: posibilidad de pagar descartes según origen del efecto.
func f553280(e: int, _unused: int, hand: int) -> int:
	return int(f5521a0(m.u8(e + 2) & 1, hand + 1) != 0)

## FUN_005532b0: cementerio no vacío y sin bloqueo contrario 5e7.
func f5532b0(e: int) -> int:
	if f542f30(1 - (m.u8(e + 2) & 1), 0x5e7) > 0:
		return 0
	return int(m.u8(0xa11948) != 0 or m.u8(0xa1269c) != 0)

## FUN_00553300: hay un monstruo en la mano propia.
func f553300(e: int) -> int:
	var p := m.u8(e + 2) & 1
	for i in range(m.u8(0xa11946 + p * 0xd54)):
		if ctype(m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff) < 21:
			return 1
	return 0

## FUN_00553390: monstruo contrario y zona propia libre.
func f553390(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(f5431b0(1 - p) != 0 and f543330(p) != 0)

func _h_chain_card_valid(other: int) -> bool:
	if other == 0:
		return false
	var v := m.u16(other + 2)
	var speed := (v >> 1) & 7
	return (v & 0x3f0) <= 0xa0 and speed != 3 and speed != 4

## FUN_005533d0: reacción contra magia/trampa o carta colocada, salvo 603.
func f5533d0(e: int, other: int, hand: int) -> int:
	if hand:
		return 0
	var reason := m.u16(e + 2) >> 10
	var a := 0xa1195c + (m.u8(e + 6) & 1) * 0xd54 + m.u8(e + 7) * 0x94
	if reason > 30 and reason < 34 and (m.u32(a) & 0xfff):
		return 1
	return int(_h_chain_card_valid(other) and ctype(m.u16(other)) >= 21 and s16(f401a70(m.u16(other))) != 0x603)

## FUN_00553490: reacción a magia que puede pagar un descarte, salvo 603.
func f553490(e: int, other: int, hand: int) -> int:
	return int(hand == 0 and _h_chain_card_valid(other) and ctype(m.u16(other)) == 22 and f5521a0(m.u8(e + 2) & 1, 1) != 0 and s16(f401a70(m.u16(other))) != 0x603)

## FUN_00553520: reacción a trampa con más de 1000 LP.
func f553520(e: int, other: int, hand: int) -> int:
	return int(hand == 0 and _h_chain_card_valid(other) and ctype(m.u16(other)) == 21 and m.u16(0xa11944 + (m.u8(e + 2) & 1) * 0xd54) > 1000)

## FUN_005535a0: reacciona a carta colocada si existe objetivo propio legal.
func f5535a0(e: int, _unused: int, hand: int) -> int:
	var p := m.u8(e + 6)
	var z := m.u8(e + 7)
	var reason := m.u16(e + 2) >> 10
	if hand or reason <= 30 or reason >= 34 or z >= 11 or not (m.u32(0xa1195c + (p & 1) * 0xd54 + z * 0x94) & 0xfff):
		return 0
	var own := m.u16(e + 2) & 1
	if p == own and f543400(own, z) == 0:
		return 0
	own = m.u8(e + 2) & 1
	if p != own and f543400(own, 0xffffffff) == 0:
		return 0
	return 1

## FUN_00553630: mano contraria no vacía.
func f553630(e: int) -> int:
	return int(m.u8(0xa11946 + (1 - (m.u16(e + 2) & 1)) * 0xd54) != 0)

## FUN_00553660: lista de candidatos del efecto no vacía.
func f553660(e: int) -> int:
	return int(f56ba50(m.u8(e + 2) & 1, f401a70(m.u16(e)), 0) > 0)

## FUN_005536a0: invocación por efecto 41e con bandera específica de jugador.
func f5536a0(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(f56e660(p) != 0 and (m.u8(0xa11955 + p * 0xd54) & 0x80) != 0 and f543330(p) != 0 and f56ba50(p, 0x41e, 0) != 0)

## FUN_005538e0: ambos jugadores tienen objetivos elegibles.
func f5538e0(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(f543400(p, 0xffffffff) != 0 and f543400(1 - p, 0xffffffff) != 0)

## FUN_00553920: hay monstruos durante fase de robo indicada.
func f553920(e: int) -> int:
	if (m.u8(0xa133f2) & 14) != 2:
		return 0
	var p := m.u8(e + 2) & 1
	return int(f5431b0(p) >= 1 or f5431b0(1 - p) > 0)

## FUN_00553970: puede pagar cinco descartes y existe carta en el campo.
func f553970(e: int, _unused: int, hand: int) -> int:
	if f5521a0(m.u8(e + 2) & 1, hand + 5) == 0:
		return 0
	for p in range(2):
		for z in range(11):
			if m.u32(0xa1195c + p * 0xd54 + z * 0x94) & 0xfff:
				return 1
	return 0

## FUN_005539d0: puede pagar dos descartes además de la carta de mano.
func f5539d0(e: int, _unused: int, hand: int) -> int:
	return int(f5521a0(m.u8(e + 2) & 1, hand + 2) != 0)

## FUN_00553a00: LP estrictamente mayores que coste y mano contraria no vacía.
func f553a00(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(m.u16(0xa11944 + p * 0xd54) > f551230(p, m.u16(e)) and m.u8(0xa11946 + (1 - p) * 0xd54) != 0)

## FUN_00553a60: reacción a magia/trampa contraria con objetivos para 431.
func f553a60(e: int, other: int, hand: int) -> int:
	if hand or other == 0:
		return 0
	var z := (m.u16(other + 2) >> 4) & 0x3f
	if z > 4 and z < 11 and ((m.u16(e + 2) ^ m.u16(other + 2)) & 1):
		return int(f554bc0(0x431, m.u16(e + 2) & 1, other) > 0)
	return 0

## FUN_00553ac0: quedan más de cuatro cartas en el mazo.
func f553ac0(e: int) -> int:
	return int(m.u8(0xa11947 + (m.u8(e + 2) & 1) * 0xd54) > 4)

## FUN_00553ae0: magia en cementerio contrario.
func f553ae0(e: int) -> int:
	var p := 1 - (m.u8(e + 2) & 1)
	for i in range(m.u8(0xa11948 + p * 0xd54)):
		if ctype(m.u16(0xa12238 + p * 0xd54 + i * 4) & 0xfff) == 22:
			return 1
	return 0

## FUN_00553b80: invocación especial con zona y candidato disponibles.
func f553b80(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(f56e660(p) != 0 and f543330(p) != 0 and f56ba50(p, f401a70(m.u16(e)), 0) > 0)

## FUN_00553be0: monstruo contrario boca arriba.
func f553be0(e: int) -> int:
	var p := 1 - (m.u16(e + 2) & 1)
	for z in range(5):
		var a := 0xa1195c + p * 0xd54 + z * 0x94
		if (m.u32(a) & 0xfff) and (m.u8(a + 6) & 2):
			return 1
	return 0

## FUN_00553f80: cinco monstruos en cementerio propio.
func f553f80(e: int) -> int:
	var p := m.u8(e + 2) & 1
	var count := 0
	for i in range(m.u8(0xa11948 + p * 0xd54)):
		if ctype(m.u16(0xa12238 + p * 0xd54 + i * 4) & 0xfff) < 21:
			count += 1
		if count > 4:
			return 1
	return 0

## FUN_00554010: hay monstruo boca abajo en cualquier lado.
func f554010() -> int:
	for z in range(5):
		for p in range(2):
			var a := 0xa1195c + p * 0xd54 + z * 0x94
			if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 2):
				return 1
	return 0

## FUN_00554070: ambos jugadores pueden invocar y tienen candidatos.
func f554070(e: int) -> int:
	if f56e660(m.u8(e + 2) & 1) == 0:
		return 0
	for p in range(2):
		if f543330(p) == 0 or f56ba50(p, f401a70(m.u16(e)), 0) == 0:
			return 0
	return 1

## FUN_005540d0: invocación especial pagando 800 LP con saldo mayor al coste.
func f5540d0(e: int) -> int:
	return f553b80(e) if m.u16(0xa11944 + (m.u8(e + 2) & 1) * 0xd54) >= 801 else 0

## FUN_00554130: al menos dos monstruos en posición requerida.
func f554130() -> int:
	return int(f5431f0(1, 1, 0) + f5431f0(0, 1, 0) > 1)

## FUN_00554160: carta contraria boca abajo y al menos 1000 LP.
func f554160(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if m.u16(0xa11944 + p * 0xd54) < 1000:
		return 0
	for z in range(11):
		var a := 0xa1195c + (1 - p) * 0xd54 + z * 0x94
		if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 2):
			return 1
	return 0

## FUN_005541c0: monstruo propio en posición requerida.
func f5541c0(e: int) -> int:
	return int(f5431f0(m.u8(e + 2) & 1, 1, 0) > 0)

## FUN_005541f0: monstruo contrario en posición requerida.
func f5541f0(e: int) -> int:
	return int(f5431f0(1 - (m.u8(e + 2) & 1), 1, 0) > 0)

## FUN_00554220: mano propia supera coste y mano contraria contiene cartas.
func f554220(e: int, _unused: int, cost: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(m.u8(0xa11946 + (1 - p) * 0xd54) != 0 and m.u8(0xa11946 + p * 0xd54) > (cost & 0xffffffff))

## FUN_00554270: monstruo contrario y uno de tres IDs habilitadores propios.
func f554270(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if f5431f0(1 - p, 0, 0) == 0:
		return 0
	return int(f542f30(p, 0x22) >= 1 or f542f30(p, 0x4ba) >= 1 or f542f30(p, 0x7f2) > 0)

## FUN_005542f0: invocación especial antes de consumir invocación normal.
func f5542f0(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(f543330(p) != 0 and f56e660(p) != 0 and not (m.u8(0xa1194c + p * 0xd54) & 0x10) and f56ba50(p, f401a70(m.u16(e)), 0) > 0)

## FUN_00554370: ambos jugadores tienen monstruos en posición requerida.
func f554370(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(f5431f0(1 - p, 0, 0) != 0 and f5431f0(p, 0, 0) != 0)

## FUN_005545b0: carta 39 propia y ningún bloqueo 58a.
func f5545b0(e: int) -> int:
	return int(f542f30(0, 0x58a) < 1 and f542f30(1, 0x58a) < 1 and f543010(m.u8(e + 2) & 1, 0x39) > 0)

## FUN_00554600: cuatro espacios libres y sin marca de invocación.
func f554600(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(not (m.u8(0xa1194c + p * 0xd54) & 0x20) and f543330(p) > 3)

## FUN_00554640: fase principal indicada por bits 1 a 3.
func f554640() -> int:
	return int((m.u8(0xa133f2) & 14) == 4)

## FUN_00554650: contrario tiene hasta 3000 LP.
func f554650(e: int) -> int:
	return int(m.u16(0xa11944 + (1 - (m.u16(e + 2) & 1)) * 0xd54) < 3001)

## FUN_00554680: mano contraria supera cinco cartas y propia tiene menos de tres.
func f554680(e: int, _unused: int, hand: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(hand == 0 and m.u8(0xa11946 + (1 - p) * 0xd54) > 5 and m.u8(0xa11946 + p * 0xd54) < 3)

## FUN_005546e0: fase principal y banderas de invocación libres.
func f5546e0(e: int) -> int:
	var base := (m.u8(e + 2) & 1) * 0xd54
	if (m.u8(0xa133f2) & 14) == 4 and not (m.u8(0xa11954 + base) & 2):
		return (m.u8(0xa1194c + base) >> 4 & 1) ^ 1
	return 0

## FUN_00554720: monstruos propios y todas las cartas de mano conservan propietario.
func f554720(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if f5431b0(p) == 0:
		return 0
	for i in range(m.u8(0xa11946 + p * 0xd54)):
		if ((m.u32(f5419b0(p, 11, i)) >> 12) & 1) != p:
			return 0
	return 1

## FUN_00554b30: objetivo alternativo de magia/equipo distinto del actual.
func f554b30(id: int, other: int, p: int, z: int) -> int:
	if other == 0 or (s16(id) == 0x431 and ctype(m.u16(other)) != 22):
		return 0
	if f554910(m.u16(other)) != 0 and (m.u32(0xa1195c + (p & 1) * 0xd54 + z * 0x94) & 0xfff) and (p != m.u8(other + 12) or z != m.u8(other + 13)):
		return f56e5b0(other, p, z)
	return 0

## FUN_00554bc0: cuenta objetivos alternativos para 431 o 525.
func f554bc0(id: int, p: int, other: int) -> int:
	var count := 0
	if (id & 0xffff) == 0x431:
		for q in range(2):
			for z in range(5):
				if f554b30(id, other, q, z):
					count += 1
	elif (id & 0xffff) == 0x525:
		for z in range(5):
			if f554b30(id, other, p, z):
				count += 1
	return count

## FUN_00554c60: reacción a ataque o magia contraria redirigible.
func f554c60(e: int, other: int) -> int:
	var v := m.u16(e + 2)
	if (v & 0xfc00) == 0x4000 and m.u8(e + 6) != (v & 1):
		return int(f5431b0(v & 1) > 1)
	if other:
		var z := (m.u16(other + 2) >> 4) & 0x3f
		if z > 4 and z < 11 and ((m.u16(other + 2) ^ v) & 1):
			return int(f554bc0(0x525, v & 1, other) > 0)
	return 0

## FUN_00554cf0: más de una zona vacía entre ambos campos.
func f554cf0() -> int:
	return int(f543330(1) + f543330(0) > 1)

## FUN_00554d60: magia en la mano propia, salvo efecto desde la mano.
func f554d60(e: int, _unused: int, hand: int) -> int:
	if hand:
		return 0
	var p := m.u8(e + 2) & 1
	for i in range(m.u8(0xa11946 + p * 0xd54)):
		if ctype(m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff) == 22:
			return 1
	return 0

## FUN_00554e00: monstruo contrario boca abajo y en defensa durante evento 2000.
func f554e00(e: int, _unused: int, hand: int) -> int:
	if hand or (m.u16(e + 2) & 0xfc00) != 0x2000 or m.u8(e + 6) == (m.u16(e + 2) & 1):
		return 0
	var a := 0xa1195c + (m.u8(e + 6) & 1) * 0xd54 + m.u8(e + 7) * 0x94
	if (m.u32(a) & 0xfff) and (m.u16(a + 6) & 1):
		return (m.u8(a + 6) >> 1 & 1) ^ 1
	return 0

## FUN_00554e70: monstruo invocable y al menos dos magias/trampas para pagar.
func f554e70(e: int, _unused: int, hand: int) -> int:
	var p := m.u8(e + 2) & 1
	if f543330(p) == 0:
		return 0
	var monsters := 0
	var others := 0
	for i in range(m.u8(0xa11946 + p * 0xd54)):
		var idx := m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff
		if ctype(idx) < 21:
			if f5421c0(idx) == 0:
				monsters += 1
		else:
			others += 1
	if hand != 0 and others != 0:
		others -= 1
	return int(monsters != 0 and others > 1)

## FUN_00554f50: requisito de campo y candidatos para 58d.
func f554f50(e: int) -> int:
	var p := m.u8(e + 2) & 1
	return int(f544be0(p) != 0 and f56ba50(p, 0x58d, 0) > 0)

## FUN_00554f90: campo actual es 14d.
func f554f90() -> int:
	return int(s16(f543fc0()) == 0x14d)

## FUN_00554fa0: reacción a invocación cuando existe monstruo.
func f554fa0(e: int, _unused: int, hand: int) -> int:
	var reason := m.u16(e + 2) >> 10
	return f552390() if hand == 0 and reason > 4 and reason < 8 else 0

## FUN_00554fe0: reacción a ataque propio con carta 57d.
func f554fe0(e: int, other: int, hand: int) -> int:
	if hand or other or (m.u16(e + 2) & 0xfc00) != 0x4000:
		return 0
	var p := m.u8(e + 8)
	var a := 0xa1195c + (p & 1) * 0xd54 + m.u8(e + 9) * 0x94
	return int((m.u32(a) & 0xfff) != 0 and p == (m.u16(e + 2) & 1) and f543010(p, 0x57d) > 0)

func _h_no_58a_candidate(e: int, id: int) -> int:
	return int(f542f30(0, 0x58a) < 1 and f542f30(1, 0x58a) < 1 and f56ba50(m.u8(e + 2) & 1, id, 0) > 0)

## FUN_00555060: candidato 58d sin bloqueo 58a.
func f555060(e: int) -> int:
	return _h_no_58a_candidate(e, 0x58d)

## FUN_005550b0: más de un objetivo propio.
func f5550b0(e: int) -> int:
	return int(f543400(m.u8(e + 2) & 1, 0xffffffff) > 1)

## FUN_005550e0: candidato 59f sin bloqueo 58a.
func f5550e0(e: int) -> int:
	return _h_no_58a_candidate(e, 0x59f)

## FUN_00555130: mano propia de al menos dos cartas.
func f555130(e: int) -> int:
	return int(m.u8(0xa11946 + (m.u8(e + 2) & 1) * 0xd54) > 1)

## FUN_00555160: mano propia no vacía, salvo efecto desde la mano.
func f555160(e: int, _unused: int, hand: int) -> int:
	return int(hand == 0 and m.u8(0xa11946 + (m.u8(e + 2) & 1) * 0xd54) != 0)

## FUN_005551a0: más de un objetivo entre ambos jugadores.
func f5551a0() -> int:
	return int(f543480(1, 0, 0, 1) + f543480(0, 0, 0, 1) > 1)

## FUN_005551d0: reacción a magia distinta de 603, sin bloqueo 58a.
func f5551d0(_e: int, other: int, hand: int) -> int:
	return int(hand == 0 and other != 0 and ctype(m.u16(other)) == 22 and f542f30(0, 0x58a) < 1 and f542f30(1, 0x58a) < 1 and s16(f401a70(m.u16(other))) != 0x603)

## FUN_00555380: ataque contrario y al menos dos atacantes posibles.
func f555380(e: int) -> int:
	var v := m.u16(e + 2)
	return int((v & 0xfc00) == 0x4000 and m.u8(e + 6) != (v & 1) and f5431f0(1 - (v & 1), 1, 0) > 1)

## FUN_005554c0: posición de objetivo contrario durante evento 3800.
func f5554c0(e: int, _unused: int, hand: int) -> int:
	if hand == 0 and (m.u16(e + 2) & 0xfc00) == 0x3800 and (m.u8(e + 8) & 15) != (m.u16(e + 2) & 1):
		var v := m.u8(e + 9)
		return m.u8(0xa11962 + (v & 1) * 0xd54 + (v >> 4) * 0x94) & 1
	return 0

## FUN_00555520: cinco candidatos 60d y ausencia de 453 en ambos campos.
func f555520(e: int) -> int:
	return int(f543010(0, 0x453) < 1 and f543010(1, 0x453) < 1 and f56ba50(m.u8(e + 2) & 1, 0x60d, 0) > 4)

## FUN_00555570: destruye objetivo, marcando primero cartas con tratamiento especial.
func f555570(p: int, z: int) -> int:
	var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
	var idx := m.u16(a) & 0xfff
	if idx == 0:
		return 0
	var id := f401a70(idx)
	if id in [0x4d9, 0x2f, 0x23d, 0x4e9]:
		issue((0x8000 if p != 0 else 0) | 0x92, z, 1, 0)
		m.set_u32(a, m.u32(a) | 0x4000)
	f54e250(p, z, 1)
	return 0

## FUN_00555d30: selección y barajado del mazo con estados 80/7f/7e.
func f555d30(e: int) -> int:
	var p := m.u8(e + 2) & 1
	match m.u32(0xa15fe0) & 0xff:
		0x7e:
			f542a20(p)
		0x7f:
			f407580(p, -1, 0xaa, 0)
			return 0x7e
		0x80:
			if p == 0:
				f5417e0(0xf5)  # 0x555d30: FUN_005417e0 + FUN_00540d60(0, 0).
				f540d60(0, 0)
				return 0x7f
	return 0

## FUN_00555db0: emite reorganización y barajado en estados 80/7f/7e.
func f555db0(e: int) -> int:
	match m.u32(0xa15fe0) & 0xff:
		0x7e:
			issue((m.u16(e + 2) << 15) | 0x60, 1, 0, 0)
		0x7f:
			issue((m.u16(e + 2) << 15) | 0xd6, 1, 0, 0)
			return 0x7e
		0x80:
			return 0x7f
	return 0


## FUN_00554e45: cola interna de 554e00; recibe desplazamientos en EAX/EDX y entrada ECX.
func f554e45(player_offset: int, entry: int, zone_offset: int) -> int:
	var v := m.u16(0xa11962 + player_offset + zone_offset)
	return int((entry & 0xfff) != 0 and (v & 1) != 0 and (v & 2) == 0)

## FUN_00555c20: devuelve carta de mazo a mano y la anuncia según descriptor.
func f555c20(e: int) -> int:
	if not (m.u8(e + 4) & 4) and (m.u8(e + 10) & 7) == 2:
		var entry := m.u32(e + 12)
		var idx := entry & 0xfff
		var p := m.u8(e + 2) & 1
		if f544a00(p, f401a70(idx)) > 0:
			issue(((entry >> 12) << 15) | 0xdf, f401a70(idx), 0, 0)
			issue((m.u16(e + 2) << 15) | 0xd2, m.u16(e + 12), 0, 0)
			issue((m.u16(e + 2) << 15) | 0x1f, f401a70(idx), m.u8(0xa11946 + p * 0xd54), 0)
	return 0

## FUN_00555d00: baraja al jugador del efecto salvo descriptor marcado.
func f555d00(e: int) -> int:
	if not (m.u8(e + 4) & 4):
		issue((m.u16(e + 2) << 15) | 0x60, 0, 0, 0)
	return 0

## FUN_00555e20: retira los dos objetivos guardados en el descriptor.
func f555e20(e: int) -> int:
	var p := m.u8(e + 8)
	var z := m.u8(e + 9)
	f54e340(m.u8(e + 6), m.u8(e + 7), 0)
	f54e340(p, z, 0)
	return 0

## FUN_00555e60: retira objetivo visible y añade su carta como equipo.
func f555e60(e: int) -> int:
	if (m.u8(e + 10) & 7) == 1:
		var p := m.u8(e + 12)
		var z := m.u8(e + 13)
		if (m.u16(0xa1195c + (p & 1) * 0xd54 + z * 0x94) & 0xfff) and f54ea40(p, z) != 0:
			var v := m.u16(e + 2)
			f54c860(v & 1, m.u16(e), (((v >> 4) & 0x3f) << 8) | (v & 1), 3)
	return 0

## FUN_00555ee0: daño de 500 por objetivo contrario válido.
func f555ee0(e: int) -> int:
	var p := 1 - (m.u8(e + 2) & 1)
	var count := f543480(p, 0, 0, 1)
	if not (m.u8(e + 4) & 4) and count > 0:
		f54ef90(p, count * 500)
	return 0

## FUN_00551a40: validador central de efectos, costes, velocidad y tabla de objetivos.
func f551a40(e: int, other: int, hand: int) -> int:
	var idx := m.u16(e)
	var row := f56e540(idx)
	if f583e00(idx) != 0:
		return 0
	if other:
		var speed := f551990(idx)
		if speed < f551990(m.u16(other)) or speed == 1:
			return 0
	if (m.u16(e + 2) & 0xfc00) == 0x4400:
		var id := f401a70(idx)
		if not (id in [1099, 0x28a, 0x291, 0x2b0, 0x3f7, 0x3f8, 0x433, 0x434, 0x43a, 0x522, 0x49a, 0x4b3, 0x4b4, 0x587, 0x5fe]):
			return 0
	var p := m.u8(e + 2) & 1
	var cost := f551230(p, idx)
	if hand:
		cost += (f542f30(1, 0x436) + f542f30(0, 0x436)) * 500
	if m.u16(0xa11944 + p * 0xd54) <= cost or row < 0:
		return 0
	var target_fn := effect_column(row, 0x8)
	var condition_fn := effect_column(row, 0xc)
	if condition_fn and invoke_original(condition_fn, [e, other, hand]) == 0:
		return 0
	if target_fn == 0:
		return 1
	for q in range(2):
		for z in range(11):
			if invoke_original(target_fn, [e, (z << 8) | q]):
				return 1
	return 0

## FUN_00551dc0: valida respuesta desde magia/trampa colocada en zona indicada.
func f551dc0(other: int, p: int, z: int) -> int:
	var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
	var flags := m.u8(a + 6)
	var idx := m.u16(a) & 0xfff
	var e := m.local(20)
	m.copy(e, other, 20)
	var v := m.u16(e + 2)
	v = (v & 0xfc0e) | (p & 1) | ((z << 4) & 0x3f0)
	m.set_u16(e + 2, v)
	if idx == 0:
		return 0
	m.set_u16(e, idx)
	if ctype(idx) < 21 or f551990(idx) < f551990(m.u16(other)) or f551d40(p, z):
		return 0
	var id := f401a70(idx)
	if not (id in [0x594, 0x3f9, 0x52c, 0x5fc]) and (flags & 2):
		return 0
	if p == 0:
		f4437a0(4)  # FUN_004437a0: ayuda del original.
	var marks := m.u16(a + 0x8e)
	if (marks & 0x200) and not (marks & 0x400) and (ctype(idx) != 21 or (f542f30(0, 0x2ef) == 0 and f542f30(1, 0x2ef) == 0)):
		return f551a40(e, other, 0)
	return 0

## FUN_00551f50: valida magia rápida de mano propia durante su turno.
func f551f50(other: int, p: int, i: int) -> int:
	var idx := m.u16(0xa11fb8 + (p & 1) * 0xd54 + i * 4) & 0xfff
	var e := m.local(20)
	m.copy(e, other, 20)
	m.set_u32(e + 2, (m.u32(e + 2) & 0xfffffcbe) | (p & 1) | 0xb0)
	m.set_u16(e, idx)
	if ctype(idx) == 22 and csub(idx) == 5 and f551990(m.u16(other)) <= f551990(idx):
		if f5435a0(p, idx) != 0 and (m.u8(0xa133f2) & 1) == p and f542f30(0, 0x49c) == 0 and f542f30(1, 0x49c) == 0:
			return f551a40(e, other, 1)
	return 0

## FUN_00552090: busca respuesta legal en campo, mano o monstruo 5f5.
func f552090(other: int, p: int) -> int:
	for z in range(5, 10):
		if f551dc0(other, p, z):
			return 1
	if p == (m.u8(0xa133f2) & 1):
		for i in range(m.u8(0xa11946 + (p & 1) * 0xd54)):
			if f551f50(other, p, i):
				return 1
	elif ctype(m.u16(other)) == 22:
		for z in range(5):
			var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
			var idx := m.u16(a) & 0xfff
			if (m.u8(a + 6) & 2) and idx != 0 and f551d40(p, z) == 0 and s16(f401a70(idx)) == 0x5f5:
				return 1
	return 0

## FUN_005521a0: cuenta descartes posibles, excluyendo magias bajo 49c.
func f5521a0(p: int, count: int) -> int:
	var n := m.u8(0xa11946 + (p & 1) * 0xd54)
	if f542f30(1, 0x49c) + f542f30(0, 0x49c) == 0:
		return int(count <= n)
	for i in range(n):
		if ctype(m.u16(0xa11fb8 + (p & 1) * 0xd54 + i * 4) & 0xfff) != 22:
			count -= 1
	return int(count < 1)

## FUN_005524b0: al menos dos objetivos válidos en fase propia con carta boca arriba.
func f5524b0(e: int, _unused: int, hand: int) -> int:
	var v := m.u16(e + 2)
	if hand or ((v ^ m.u8(0xa133f2)) & 1) != 0 or (v & 0xfc00) != 0x800 or not (m.u8(0xa11962 + (v & 1) * 0xd54 + ((v >> 4) & 0x3f) * 0x94) & 2):
		return 0
	var count := 0
	for p in range(2):
		for z in range(5):
			if f550400(e, (z << 8) | p):
				count += 1
				if count > 1:
					return 1
	return 0

func _h_small_monster(e: int) -> int:
	var p := m.u8(e + 2) & 1
	var tmp := m.local(12)
	for z in range(5):
		var idx := m.u16(0xa1195c + p * 0xd54 + z * 0x94) & 0xfff
		if idx and ctype(idx) < 21:
			f546470(p, z, tmp)
			if _s32c(m.u32(tmp + 4)) < 1001 and (m.u8(tmp + 2) & 0xe0) == 0x40:
				return 1
	return 0

## FUN_00552700: monstruo pequeño de atributo requerido sin bloqueo 58a.
func f552700(e: int) -> int:
	return _h_small_monster(e) if f542f30(0, 0x58a) < 1 and f542f30(1, 0x58a) < 1 else 0

## FUN_0055272f: cola interna de 552700, tras comprobar 58a.
func f55272f(e: int) -> int:
	return _h_small_monster(e)

## FUN_00552800: valida reacción que protege otra trampa de destrucción.
func f552800(e: int, other: int, hand: int) -> int:
	if hand or other == 0 or ((m.u8(other + 2) ^ m.u8(e + 2)) & 1) == 0:
		return 0
	var id := f401a70(m.u16(other))
	var p := m.u16(e + 2) & 1
	var own_z := (m.u16(e + 2) >> 4) & 0x3f
	if id in [0x425, 0x426, 0x42b, 0x29f]:
		for z in range(5, 10):
			var idx := m.u16(0xa1195c + p * 0xd54 + z * 0x94) & 0xfff
			if idx != 0 and z != own_z and ctype(idx) == 21:
				return 1
	elif id in [0x437, 0x46e, 0x46f, 0x53, 0xdf, 0x3ec]:
		var q := m.u8(other + 12)
		var z := m.u8(other + 13)
		var idx := m.u16(0xa1195c + (q & 1) * 0xd54 + z * 0x94) & 0xfff
		return int(idx != 0 and (q != p or z != own_z) and ctype(idx) == 21)
	return 0

## FUN_00552bb0: invocación de monstruo tipo1 habilitada por carta 2e4.
func f552bb0(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if f543330(p) == 0 or f56e660(p) == 0 or (f543010(0, 0x2e4) < 1 and f543010(1, 0x2e4) < 1):
		return 0
	for i in range(m.u8(0xa11946 + p * 0xd54)):
		var idx := m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff
		if ctype(idx) == 1 and (f541ce0(f401a70(idx)) == 0 or f542fb0(p) != 0):
			return 1
	return 0

## FUN_00552d30: reacción a invocación contraria con umbrales ATK/DEF por ID.
func f552d30(e: int) -> int:
	var reason := m.u16(e + 2) >> 10
	if reason != 5 and reason != 6:
		return 0
	var p := m.u8(e + 6)
	var z := m.u8(e + 7)
	var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
	if not (m.u32(a) & 0xfff) or not (m.u8(a + 6) & 2) or p == (m.u16(e + 2) & 1):
		return 0
	match s16(f401a70(m.u16(e))):
		0x2a8:
			return int(f547c80(p, z) < 501)
		0x2a9:
			return int(f547c60(p, z) < 501)
		0x3ea:
			return int(f547c60(p, z) > 999)
	return 0

## FUN_00552e00: hay fusión realizable en el mazo de fusión.
func f552e00(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if p == 0:
		f4437a0(14)  # FUN_004437a0: ayuda del original.
	if f56e660(p) == 0:
		return 0
	var tmp := m.local(8)
	for i in range(m.u8(0xa11949 + p * 0xd54)):
		if f563e50(p, m.u16(0xa12378 + p * 0xd54 + i * 4) & 0xfff, tmp):
			return 1
	return 0

## FUN_00552ff0: invocación pagando 500 LP en fases permitidas del turno propio o contrario.
func f552ff0(e: int, _unused: int, hand: int) -> int:
	var p := m.u16(e + 2) & 1
	if hand or m.u16(0xa11944 + p * 0xd54) <= 499:
		return 0
	var turn := m.u8(0xa133f2)
	if ((p ^ turn) & 1) == 0:
		var phase := (turn >> 1) & 7
		if phase != 2 and phase != 4:
			return 0
	elif (turn & 14) != 6:
		return 0
	if f56e600(p) == 0:
		return 0
	for i in range(m.u8(0xa11946 + p * 0xd54)):
		var idx := m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff
		if f57a490(p, idx) != 0 and f5421c0(idx) == 0:
			return 1
	return 0

## FUN_00551450: tributa monstruo con ATK hasta1000 y atributo requerido.
func f551450(e: int) -> int:
	var p := m.u8(e + 2) & 1
	var tmp := m.local(12)
	if p:
		for z in range(5):
			var idx := m.u16(f5419b0(p, z, 0)) & 0xfff
			if idx != 0 and ctype(idx) < 21:
				f546470(p, z, tmp)
				if _s32c(m.u32(tmp + 4)) < 1001 and (m.u8(tmp + 2) & 0xe0) == 0x40:
					f54ea40(p, z)
					return 1
		return 0
	if m.u8(0xa15fe4) == 0:
		f5417e0(0x11)  # FUN_005417e0 del original.
		m.set_u8(0xa15fe4, 1)
	elif m.u8(0xa15fe4) == 1:
		if f57a060(0xf0):
			var z := m.u32(0xa161ac)
			f546470(p, z, tmp)
			if _s32c(m.u32(tmp + 4)) < 1001 and (m.u8(tmp + 2) & 0xe0) == 0x40 and f579890():
				f54ea40(p, z)
				return 1
		if m.u32(0xa114a8) & 0x102:
			m.set_u8(0xa15fe4, 0)
	return 0

## FUN_00551670: tributa objetivo humano o CPU, excluyendo objetivo de carta407.
func f551670(e: int) -> int:
	var id := s16(f401a70(m.u16(e)))
	if (m.u8(e + 2) & 1) and id != 0x407:
		f53e950(1)
		return 1
	if m.u8(0xa15fe4) == 0:
		f5417e0(0x12)  # FUN_005417e0 del original.
		m.set_u8(0xa15fe4, 1)
	elif m.u8(0xa15fe4) == 1 and f57a060(0xf0):
		var p := m.u32(0xa161a4)
		var z := m.u32(0xa161ac)
		if (id != 0x407 or m.u8(e + 6) != p or m.u8(e + 7) != z) and f579890():
			f54ea40(p, z)
			return 1
	return 0

## FUN_00551740: tributa monstruo con ID39 o76d seleccionado.
func f551740() -> int:
	if m.u8(0xa15fe4) == 0:
		dialog_format(0x13, [{"card": f401ad0(0x39)}])  # 0x551740: FUN_0053fac0 + FUN_005417e0.
		m.set_u8(0xa15fe4, 1)
	elif m.u8(0xa15fe4) == 1 and f57a060(0xe0):
		var p := m.u32(0xa161a4)
		var z := m.u32(0xa161ac)
		var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
		var idx := m.u16(a) & 0xfff
		if idx != 0 and (m.u8(a + 6) & 2) and s16(f401a70(idx)) in [0x39, 0x76d] and f579890():
			f54ea40(p, z)
			return 1
	return 0

## FUN_00551840: descarta una magia elegida de la mano.
func f551840() -> int:
	if m.u8(0xa15fe4) == 0:
		f5417e0(0x14)  # FUN_005417e0 del original.
		m.set_u8(0xa15fe4, 1)
	elif m.u8(0xa15fe4) == 1 and f57a060(1):
		var p := m.u32(0xa161a4)
		var i := m.u32(0xa161ac)
		var idx := m.u16(0xa11fb8 + (p & 1) * 0xd54 + i * 4) & 0xfff
		if ctype(idx) == 22 and f579890():
			f54e680(p, i, 0, 1)
			return 1
	return 0


## FUN_00553710: condiciones de trampas que responden al ataque contrario.
func f553710(e: int, _unused: int, hand: int) -> int:
	var p := m.u8(e + 2) & 1
	f5431b0(p)
	f5431b0(1 - p)
	if hand or m.u8(e + 6) == p or (m.u16(e + 2) & 0xfc00) != 0x4000:
		return 0
	var id := f401a70(m.u16(e))
	match id:
		0x3c0, 0x587, 0x44a, 0x4be, 0x590:
			return 1
		0x3de:
			return int(m.u8(e + 9) <= 4 and f5431b0(p) != 0 and f543330(p) != 0 and f5431f0(1 - p, 1, 0) > 1)
		0x3b1:
			return int(m.u8(e + 9) <= 4 and f5431b0(p) != 0 and f543330(p) >= 2 and f56ba50(p, 0x3b1, 0) > 1)
		0x420, 0x2ad:
			for z in range(10):
				var a := 0xa1195c + (1 - p) * 0xd54 + z * 0x94
				if (m.u32(a) & 0xfff) and not (m.u8(a + 6) & 1):
					return 1
	return 0

## FUN_00553c30: predicados de eventos de carta por ID y motivo del descriptor.
func f553c30(e: int, other: int, hand: int) -> int:
	if hand:
		return 0
	var p := m.u16(e + 2) & 1
	var q := m.u8(e + 6)
	var r := m.u16(e + 2) & 0xfc00
	match f401a70(m.u16(e)):
		0x46e:
			return int(q == p and r == 0x5000)
		0x46f:
			return int(q == p and r == 0x5400)
		0x470:
			return int(r == 0x6400)
		0x471:
			return int(other != 0 and ctype(m.u16(other)) == 22 and s16(f53b880(m.u16(other))) == 2)
		0x472:
			return int(other != 0 and ctype(m.u16(other)) == 22 and s16(f53b880(m.u16(other))) == 4)
		0x473:
			return int(other != 0 and ctype(m.u16(other)) == 21 and s16(f53b880(m.u16(other))) == 4)
		0x474, 0x518:
			var reason := m.u16(e + 2) >> 10
			if reason < 13 or reason > 15:
				return 0
			return int(m.u8(e + 8) == p) if reason == 15 else int((m.u8(e + 8) & 15) == p)
		0x475:
			return int(q != p and f542e60(1 - p, 0x475, 0xffffffff) <= 0 and r == 0x6800)
		0x476:
			return int(q == p and f542e60(1 - p, 0x476, 0xffffffff) <= 0 and r == 0x7400)
		0x47d:
			return int(q == p and r == 0x6c00)
		0x515:
			var reason := m.u16(e + 2) >> 10
			if reason == 30:
				return int(q == p)
			if reason == 19:
				return int(q == p or m.u8(e + 8) == p)
	return 0

## FUN_005543c0: invocación de tributo usando campo contrario en fase principal.
func f5543c0(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if (m.u8(0xa133f2) & 14) != 4 or f5431b0(1 - p) == 0 or f542f30(0, 0x58a) >= 1 or f542f30(1, 0x58a) >= 1:
		return 0
	if p == 0:
		for z in range(5):
			var a := 0xa1195c + z * 0x94
			var idx := m.u16(a) & 0xfff
			if idx and (m.u8(a + 6) & 2) and s16(f401a70(idx)) in [0x58, 0x105, 0x1ff]:
				return 1
	if (m.u8(0xa1194c + p * 0xd54) & 0x10) or f544280(1 - p, 0xffffffff) == 0:
		return 0
	for i in range(m.u8(0xa11946 + p * 0xd54)):
		var idx := m.u16(0xa11fb8 + p * 0xd54 + i * 4) & 0xfff
		var level := (f401a20(idx) >> 25) & 15
		if ctype(idx) < 21 and f5421c0(idx) == 0 and level > 4:
			if level < 7:
				if f543360(p) != -1:
					return 1
			elif f544280(p, 0xffffffff) > 0:
				return 1
	return 0

## FUN_00555240: existe equipo transferible a otro monstruo boca arriba.
func f555240(e: int, _unused: int, hand: int) -> int:
	if hand:
		return 0
	for target_p in range(2):
		for target_z in range(5):
			var a := 0xa1195c + target_p * 0xd54 + target_z * 0x94
			if not (m.u32(a) & 0xfff) or not (m.u8(a + 6) & 2):
				continue
			for p in range(2):
				for z in range(5, 10):
					var valid := f550b10(e, (z << 8) | p)
					var accepts := f545fb0(p, z, target_p, target_z)
					var old := s16(f546020(p, z))
					if old != ((target_z << 8) | target_p) and accepts != 0 and valid != 0:
						return 1
	return 0

## FUN_005553d0: exige ausencia de respuesta y material suficiente para nivel del objetivo.
func f5553d0(e: int, other: int, hand: int) -> int:
	if hand or other:
		return 0
	return f5553e3(e)

## FUN_005553e3: cola interna de 5553d0, compara material y nivel visible.
func f5553e3(e: int) -> int:
	var p := m.u8(e + 2) & 1
	if f542f30(1 - p, 0x5e7) >= 1:
		return 0
	var amount := f544b70(p)
	if amount == 0:
		return 0
	for q in range(2):
		for z in range(5):
			var a := 0xa1195c + q * 0xd54 + z * 0x94
			var idx := m.u16(a) & 0xfff
			if idx and (m.u8(a + 6) & 2):
				var prop := f401a20(idx)
				var typ := (prop >> 20) & 31
				var level := (prop >> 25) & 15
				if typ > 20 and typ < 24:
					level = 0
				elif typ == 24:
					level = 10
				if level <= amount:
					return 1
	return 0

## FUN_00555620: destruye magias148 y después monstruos tipo1 visibles en defensa.
func f555620(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var state := m.u32(0xa15fe0) & 0xff
	if state != 0x7f:
		if state != 0x80:
			return 0
		var found := false
		for p in range(2):
			for z in range(5, 10):
				var a := 0xa1195c + p * 0xd54 + z * 0x94
				var idx := m.u16(a) & 0xfff
				if idx and (m.u8(a + 6) & 2) and s16(f401a70(idx)) == 0x148:
					f54e250(p, z, 1)
					found = true
		return 0x7f if found else 1
	for p in range(2):
		for z in range(5):
			var a := 0xa1195c + p * 0xd54 + z * 0x94
			if (m.u32(a) & 0xfff) and (m.u16(a + 6) & 3) == 3 and s16(f545c40(p, z)) == 1:
				f54e660(p, z, 0, 0)
	return 1

## FUN_00555730: selecciona carta de mazo por efecto y la lleva a mano, luego baraja.
func f555730(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var p := m.u16(e + 2) & 1
	var state := m.u32(0xa15fe0) & 0xff
	match state:
		100:
			issue((m.u16(e + 2) << 15) | 0x60, 0, 0, 0)
			return 1
		0x77:
			if p != 0 and m.u8(0xa11947 + p * 0xd54) != 0:
				f407580(p, 13, 0, 0)
		0x78:
			if p != 0 and m.u8(0xa11947 + p * 0xd54) != 0:
				f5417e0(0xf9)  # FUN_005417e0 del original.
			return 0x77
		0x7e:
			var entry := f4073b0()
			var idx := m.u16(entry) & 0xfff
			if f54dc60(p, f401a70(idx)) != 0:
				f54ef30(p, idx)
				issue((m.u16(e + 2) << 15) | 0x1f, f401a70(idx), m.u8(0xa11946 + p * 0xd54), 0)
		0x7f:
			f407580(p, -1, f401a70(m.u16(e)), 0)
			return 0x7e
		0x80:
			var n := f56ba50(p, f401a70(m.u16(e)), 0)
			if n == 0:
				f5417e0(0x15)  # FUN_005417e0 del original.
				return 120 if p != 0 else 100
			if p:
				f57d330(m.u16(e))
				f4073a0(m.u16(0xa14f02))
				return 0x7e
			f5417e0(0x16)  # FUN_005417e0 del original.
			return 0x7f
		_:
			return 0
	return 100

## FUN_00555980: enlaza la carta visible propia a monstruos tipo2 de ambos campos.
func f555980(e: int) -> int:
	if m.u8(e + 4) & 4:
		return 0
	var v := m.u16(e + 2)
	var p := v & 1
	var z := (v >> 4) & 0x3f
	var a := 0xa1195c + p * 0xd54 + z * 0x94
	if (m.u32(a) & 0xfff) and (m.u8(a + 6) & 2):
		issue((v << 15) | 0x94, z, 0, 0)
		for q in range(2):
			for target in range(5):
				var b := 0xa1195c + q * 0xd54 + target * 0x94
				if (m.u32(b) & 0xfff) and (m.u8(b + 6) & 2) and s16(f545c40(q, target)) == 2:
					f54c860(p, (z << 8) | p, (target << 8) | q, 2)
	return 0

## FUN_00555a80: revela objetivo boca abajo, anuncia y destruye si es trampa.
func f555a80(e: int) -> int:
	if not (m.u8(e + 4) & 4) and (m.u8(e + 10) & 7) == 1:
		var p := m.u8(e + 12)
		var z := m.u8(e + 13)
		var a := 0xa1195c + (p & 1) * 0xd54 + z * 0x94
		var idx := m.u16(a) & 0xfff
		if idx:
			if not (m.u8(a + 6) & 2):
				var flag := 0x8000 if p != 0 else 0
				issue(flag | 0x80, z, 0, 0)
				f54ef30(p, idx)
				issue(flag | 0xf1, 15, 0, 0)
				if ctype(idx) == 21:
					f54e250(p, z, 1)
				else:
					issue(flag | 0x80, z, 0, 0)
			elif ctype(idx) == 21:
				f54e250(p, z, 1)
	return 0

## FUN_00555b70: tributa objetivo y causa mitad ATK o500 según carta de origen.
func f555b70(e: int) -> int:
	if (m.u8(e + 10) & 7) == 1:
		var p := m.u8(e + 12)
		var z := m.u8(e + 13)
		if m.u16(0xa1195c + (p & 1) * 0xd54 + z * 0x94) & 0xfff:
			var damage := 0
			var id := s16(f401a70(m.u16(e)))
			if id == 0x58:
				damage = f53fbd0(f547c60(p, z))
			elif id == 0x1ff:
				damage = 500
			if f54ea40(p, z):
				f54ef90(1 - (m.u8(e + 2) & 1), damage)
	return 0

## FUN_00555f40: asocia objetivo de equipo y marca descriptor inválido si no se puede.
func f555f40(e: int) -> int:
	var v := m.u16(e + 2)
	var p := v & 1
	var z := (v >> 4) & 0x3f
	if not (m.u32(0xa1195c + p * 0xd54 + z * 0x94) & 0xfff):
		return 0
	if f54fc80(e, m.u16(e + 12)) == 0:
		m.set_u8(e + 4, m.u8(e + 4) | 8)
		return 0
	if ctype(m.u16(e)) == 21 and (m.u16(e + 4) & 4):
		m.set_u16(e + 4, m.u16(e + 4) | 8)
		return 0
	var origin := (z << 8) | p
	if (m.u8(e + 10) & 7) == 1:
		f54e730(p, origin, m.u16(e + 12))
	elif s16(f401a70(m.u16(e))) == 0x3c2 and (m.u8(e + 10) & 7) == 2:
		f54e730(p, origin, m.u16(e + 12))
		issue((v << 15) | 0x88, z, m.u16(e + 14), 0)
	return 0

## FUN_00556070: variante de equipo con confirmación humana y posible descarte.
func f556070(e: int, _unused: int) -> int:
	var v := m.u16(e + 2)
	if (v & 14) != 6:
		return f555f40(e)
	match m.u32(0xa15fe0) & 0xff:
		0x7d:
			if f54ea40(m.u8(e + 12), m.u8(e + 13)):
				issue((v << 15) | 0xd0, f401a70(m.u16(e)), 0, 0)
		0x7e:
			return 0x7e - int(invoke_original(0x565380, [e, 0]) != 0)
		0x7f:
			# Respuesta del cuadro pedido en 0x80.
			if m.u16(0xa16178) != 0:
				m.set_u8(0xa15fe5, 0)
				return 0x7e
		0x80:
			if v & 1:
				return 0
			if f543400(v & 1, 0xffffffff):
				# Cuadro Si/No: mensaje 0x17 con el nombre de la carta 0x12f.
				dialog_format(0x17, [{"card": f401ad0(0x12f)}])
				f540d60(1, 0)
				return 0x7f

		_:
			return 0
	return 100



## FUN_0053fbf0: la mitad redondeada ((v * 5 + 4) / 10, division entera de C).
func f53fbf0(value: int) -> int:
	return int((value * 5 + 4) / 10)


## FUN_005547b0: 1 si la carta (indice) esta en la lista de 0x5547b0 (comparaciones del C).
func f5547b0(index: int) -> int:
	var id := f401a70(index) & 0xffff
	if id in [0x422, 0x290, 0x291, 0x13e, 0x28a, 0x28b, 0x28d, 0x412, 0x416, 0x417, 0x3f4, 0x3f5,
			0x29b, 0x3c2, 0x5a8, 0x5a9, 0x5aa, 0x604, 0x60c, 0x60e, 0x58e, 0x521, 0x58b, 0x58c,
			0x49e, 0x424, 0x42c]:
		return 1
	if (id >= 0x140 and id < 0x148) or (id >= 300 and id < 0x13d):
		return 1
	return 0


## FUN_00552600: condicion (+0x0c) de la carta 1a8: solo responde desde la mano.
func f552600(_e: int, _unused: int, hand: int) -> int:
	return int(hand != 0)


## FUN_00552b60: condicion (+0x0c) de la carta 3b6: fuera de la mano y motivo 0x13 (0x4c00).
func f552b60(e: int, _unused: int, hand: int) -> int:
	if hand:
		return 0
	return int((m.u16(e + 2) & 0xfc00) == 0x4c00)


## FUN_005530f0: condicion (+0x0c) de reacciones a una carta del rival (426, 3fb, 3fd, 3fe,
## 4df, 5fb): cada id exige su lista de cartas que la provocan.
func f5530f0(e: int, other: int, hand: int) -> int:
	if hand or other == 0 or ((m.u8(e + 2) ^ m.u8(other + 2)) & 1) == 0:
		return 0
	var target := f401a70(m.u16(other)) & 0xffff
	match f401a70(m.u16(e)) & 0xffff:
		0x426:
			return int(target == 0x29f)
		0x3fb:
			return int(target == 0x14f)
		0x3fd:
			return int(target == 0x3f0)
		0x3fe:
			return int(target == 0x150)
		0x4df:
			return int(target in [0x3c8, 0x3ee, 0x3ef, 0x3f2, 0x401, 0x40f, 0x42e, 0x42f, 0x439]
					or (target >= 0x151 and target < 0x15a))
		0x5fb:
			return int(ctype(m.u16(other)) == 0x16 and f554910(m.u16(other)) != 0)
	return 0


## FUN_00554100: condicion (+0x0c) de la carta 49b: motivo 0x0d (0x3400) y el jugador del
## byte +8 distinto del dueño de la entrada.
func f554100(e: int) -> int:
	if (m.u16(e + 2) & 0xfc00) != 0x3400:
		return 0
	return int((m.u8(e + 8) & 0xf) != (m.u16(e + 2) & 1))


## FUN_00554d10: condicion (+0x0c) de la carta 529: responde a una magia (tipo 0x16) que no
## sea la 603, fuera de la mano.
func f554d10(_e: int, other: int, hand: int) -> int:
	if hand or other == 0 or ctype(m.u16(other)) != 0x16:
		return 0
	return int((f401a70(m.u16(other)) & 0xffff) != 0x603)


## FUN_00554910: 1 si FUN_005547b0 la acepta o el id esta en su segunda lista.
func f554910(index: int) -> int:
	if f5547b0(index) != 0:
		return 1
	var id := f401a70(index) & 0xffff
	if id in [0x4bb, 0x403, 0x413, 0x430, 0x433, 0x434, 0x43a, 0x485, 0x3ff, 0x3ab, 0x13f, 0x15c,
			0x2ac, 0x3de, 0x3f7, 0x3f8, 0x5ab, 0x5f7, 0x5f9, 0x5fc, 0x5fe, 0x60a, 0x587, 0x4c4,
			0x4dc, 0x4e0, 0x515, 0x524, 0x527]:
		return 1
	return 0


## FUN_0056e5b0: llama a la rutina de objetivo (+0x08) de la entrada de la tabla de efectos de
## la carta `e` con (zona << 8) | jugador; 1 si la carta no tiene entrada o rutina; 0 si e es 0.
func f56e5b0(e: int, p: int, z: int) -> int:
	if e == 0:
		return 0
	var row := f56e540(m.u16(e))
	if row < 0 or effect_column(row, 0x8) == 0:
		return 1
	return invoke_original(effect_column(row, 0x8), [e, ((z & 0xff) << 8) | (p & 0xff)])
