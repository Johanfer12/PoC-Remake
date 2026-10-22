class_name JoeyPortQ
extends JoeyPortP
## Motor nativo de Joey, lote Q de la etapa 3: M3 578d00-579990 (banderas de jugador 5797e0/579930/579990) y motor continuo C 598b50-59c8d0.
## Cada funcion se llama f<direccion de Joey_Pc.exe> y sobrescribe su declaracion con la misma
## aridad. Cotejo: re/scripts/joey_specs/port_q.py.

## Palabra de reglas continuas (bits que activa 570670 / 5798f0).
const _JQ_RULES := 0xa577ec
## Contador de suspension de los avisos continuos (byte bajo) y su bandera de bloqueo (bit 15).
const _JQ_HOLD := 0xa55c94
const _JQ_HOLD_FLAGS := 0xa55ce8
## Tabla fija de ids (bits 13-25, fin cuando son 0) que consultan 598ed0/598f30.
const _JQ_ID_TABLE := 0x5ed060


static func _jq_op(p: int, op: int) -> int:
	return (0x8000 if p != 0 else 0) | op


## Ids que encadenan un efecto al sacarse del mazo o del mazo de fusion (578d00).
static func _jq_chains(card_id: int, flag: int) -> bool:
	match card_id & 0xffff:
		0x412, 0x1de, 0x4da:
			return true
		0xc6:
			return flag != 0
	return false


## Joey FUN_00578d00: busca en el mazo (solo cartas propias) y en el mazo de fusion de p las
## cartas con ese id (todas si all != 0, si no la primera), las anuncia con 0x8e y encadena el
## efecto de las que lo tienen; con 0x453 en juego delega en 579020.
func f578d00(p: int, card_id: int, all: int, flag: int) -> int:
	var found := 0
	if f5699c0(0x453) != 0:
		f579020(p, card_id, all, flag)
		return 0
	var pl := JoeyMem.pl(p)
	var low := p & 1
	var i := 0
	var stop := false
	while i < m.u8(pl + JoeyMem.P_DECK_N):
		var at := pl + JoeyMem.P_DECK + i * 4
		var key := f402460(card_id)
		if f5674e0(m.u16(at) & 0xfff, key) != 0 and ((m.u32(at) >> 0xc) & 1) == (p & 0xffffffff):
			if all == 0 and found != 0:
				break
			found += 1
			var e := m.u32(at)
			f5b9170(0x8e, ((JoeyMem.ident(e) & 0xff) << 8) | low | 0x1a, low | 0x11c, int(flag != 0))
			if _jq_chains(card_id, flag):
				var ident := JoeyMem.ident(m.u32(at))
				f5ba490((f402460(card_id) & 0xffff) | ((p << 0x1f) & 0xffffffff) | 0x3a4e0000, ident, 0)
		i += 1
	i = 0
	while i < m.u8(pl + JoeyMem.P_FUSION_N):
		var at := pl + JoeyMem.P_FUSION + i * 4
		var key := f402460(card_id)
		if f5674e0(m.u16(at) & 0xfff, key) != 0:
			if all == 0 and found != 0:
				break
			found += 1
			var e := m.u32(at)
			f5b9170(0x8e, ((JoeyMem.ident(e) & 0xff) << 8) | low | 0x18, low | 0x11c, int(flag != 0))
			if _jq_chains(card_id, flag):
				var ident := JoeyMem.ident(m.u32(at))
				f5ba490((f402460(card_id) & 0xffff) | ((p << 0x1f) & 0xffffffff) | 0x3a4e0000, ident, 0)
		i += 1
	f59d6e0(p, found)
	f598590(m.u8(JoeyMem.TURN) & 1, 0x1d, 0)
	return 0


## Joey FUN_00579020: variante de 578d00 con 0x453 en juego: anuncia con 0x8e (b = 0x11e) las
## cartas con ese id del mazo y del mazo de fusion de p, sin mirar el propietario ni encadenar.
func f579020(p: int, card_id: int, all: int, flag: int) -> int:
	var pl := JoeyMem.pl(p)
	var low := p & 1
	var found := 0
	var i := 0
	while i < m.u8(pl + JoeyMem.P_DECK_N):
		var at := pl + JoeyMem.P_DECK + i * 4
		if f5674e0(m.u16(at) & 0xfff, f402460(card_id)) != 0:
			if all == 0 and found != 0:
				break
			found += 1
			var e := m.u32(at)
			f5b9170(0x8e, ((JoeyMem.ident(e) & 0xff) << 8) | low | 0x1a, ((e >> 0xc) & 1) | 0x11e, int(flag != 0))
		i += 1
	i = 0
	while i < m.u8(pl + JoeyMem.P_FUSION_N):
		var at := pl + JoeyMem.P_FUSION + i * 4
		if f5674e0(m.u16(at) & 0xfff, f402460(card_id)) != 0:
			if all == 0 and found != 0:
				return 0
			found += 1
			var e := m.u32(at)
			f5b9170(0x8e, ((JoeyMem.ident(e) & 0xff) << 8) | low | 0x18, ((e >> 0xc) & 1) | 0x11e, int(flag != 0))
		i += 1
	return 0


## Joey FUN_005791d0: saca del mazo de p (576110 hacia la ubicacion d) la primera carta con ese
## id; 1 si la encontro.
func f5791d0(p: int, card_id: int, d: int) -> int:
	var pl := JoeyMem.pl(p)
	var i := 0
	while i < m.u8(pl + JoeyMem.P_DECK_N):
		var at := pl + JoeyMem.P_DECK + i * 4
		if f5674e0(m.u16(at) & 0xfff, f402460(card_id)) != 0:
			f576110(p, 0xd, JoeyMem.ident(m.u32(at)), p, d, 1, 0)
			return 1
		i += 1
	return 0


## Joey FUN_005792a0: anuncia con 0x6c (mazo) las hasta 5 primeras cartas de la lista de
## candidatos, de la ultima a la primera.
func f5792a0(p: int) -> int:
	var n := 5
	if _s32(f40cae0()) <= 5:
		n = f40cae0()
	n = _s32(n)
	if n - 1 < 0:
		return 0
	var k := n
	while k != 0:
		var serial := (m.u32(f40cd00(k)) >> 0x18) & 0x7f
		var owner := (m.u32(f40cd00(k)) >> 0xc) & 1
		f5b9170(_jq_op(p, 0x6c), 0xd, owner + serial * 2, 0)
		k -= 1
	return 0


## Joey FUN_00579310: 579330 para la carta i de la mano.
func f579310(p: int, i: int, at: int, flag: int) -> int:
	return f579330(p, 0xb, i, at, flag)


## Joey FUN_00579330: muestra la carta (entrada `at`, posicion i de la ubicacion loc) al rival
## con 0x79, anota la carta perdida (59d6e0), encadena el efecto de las cartas que lo tienen al
## revelarse (0x412, 0x1de, 0x4da, 0xc6 desde el mazo), aplica 0x3ba (destruye toons) y 0x5ea
## (al cementerio con 5783c0/579790) y avisa con 598590 (0x1f).
func f579330(p: int, loc: int, i: int, at: int, flag: int) -> int:
	var index := m.u16(at) & 0xfff
	var forbidden := int(_s32(f5699c0(0x453)) > 0)
	var lost := false
	if forbidden == 0:
		lost = not is_token(index)
	f5b9170(_jq_op(p, 0x79), ((loc & 0xff) << 8) | (i & 0xff), 0x10 if forbidden else 1, 3 if flag != 0 else 2)
	if lost:
		f59d6e0((m.u32(at) >> 0xc) & 1, 1)
	var chain := false
	match f4022e0(index) & 0xffff:
		0x412, 0x1de, 0x4da:
			chain = forbidden == 0
		0xc6:
			chain = forbidden == 0 and flag != 0 and (loc & 0xffffffff) == 0xd
		0x3ba:
			for k in 2:
				var q := p if k == 0 else (1 - p) & 0xffffffff
				# Lee las banderas de la zona k (no de la z del bucle), como el original.
				var flags_at := JoeyMem.zone(q, k) + JoeyMem.Z_FLAGS
				for z in 5:
					var zat := JoeyMem.zone(q, z)
					var idx := m.u16(zat) & 0xfff
					if m.u8(flags_at) & 2 and f5675f0(idx) != 0 and f56b440(idx, JoeyMem.ident(m.u32(zat))) == 0:
						f577840(q, z, flag, 0)
		0x5ea:
			var e := m.u32(at)
			var owner := (e >> 0xc) & 1
			if (p & 0xffffffff) == owner and lost and flag != 0 \
					and f56b440(index, owner + ((e >> 0x18) & 0x7f) * 2) == 0:
				e = m.u32(at)
				f5783c0(p, 0xe, e & 0xfff, JoeyMem.ident(e))
				e = m.u32(at)
				f579790(p, e & 0xfff, ((JoeyMem.ident(e) & 0xff) << 8) | 3)
	if chain:
		var e := m.u32(at)
		f5ba490((((e & 0xfffff7c9) << 0x13) & 0xffffffff) | index | 0x3e4e0000, JoeyMem.ident(e), 0)
	var tail := m.u32(at)
	f598590(m.u8(JoeyMem.TURN) & 1, 0x1f, (JoeyMem.ident(tail) & 0xffff) | (int(_s32(flag) > 0) << 0x10))
	return 0


## Joey FUN_00579660: 579330 para la carta i del mazo.
func f579660(p: int, i: int, flag: int) -> int:
	return f579330(p, 0xd, i, f5700f0(p, 0xd, i), flag)


## Joey FUN_00579690: 579330 para la carta i del mazo de fusion.
func f579690(p: int, i: int, flag: int) -> int:
	return f579330(p, 0xc, i, f5700f0(p, 0xc, i), flag)


## Joey FUN_005796c0: juega la carta i de la mano (0xcf): una magia de campo reemplaza la de la
## zona 10 (577840) y va a la zona 10; si no, a la zona que da 56a400. Devuelve la zona.
func f5796c0(p: int, i: int, b: int) -> int:
	var z := f56a400(p)
	var index := m.u32(JoeyMem.pl(p) + JoeyMem.P_HAND + i * 4) & 0xfff
	if f4025d0(index) & 0xffff == 0x16 and f402700(index) & 0xffff == 2:
		if m.u32(JoeyMem.zone(p, 10)) & 0xfff != 0:
			f577840(p, 10, 0, index)
		z = 10
	f59d040(p)
	f5b9170(_jq_op(p, 0xcf), f4022e0(index), ((z & 0xff) << 8) | (i & 0xff), b & 0xff)
	return z


## Joey FUN_00579790: anuncia con 0x86 la carta (b = 0xb00 | p). La mitad alta de b sale de ECX,
## que 5b9170 descarta (solo guarda u16): el port no la lleva.
func f579790(p: int, a: int, c: int) -> int:
	return f5747e0(p, a, 0xb00 | (p & 0xff), c)


## Joey FUN_005797c0: 574900 sobre la ranura del jugador (zona 11): quita su vinculo de la carta.
func f5797c0(p: int, card_id: int, keep: int) -> int:
	return f574900(p, 0xb, card_id, keep)


## Joey FUN_005797e0: emite 0xc6 con un rand() como semilla (mitad baja y alta).
func f5797e0(p: int) -> int:
	var r := rng.rand()
	f5b9170(_jq_op(p, 0xc6), r, r >> 0x10, 0)
	return 0


## Joey FUN_00579810: suspende los avisos continuos (incrementa el contador de a55c94); al
## pasar de 0 limpia sus banderas. En red, si el turno no es local, lo pide con el paquete 0xf058.
func f579810() -> int:
	var hold := m.u32(_JQ_HOLD)
	if hold & 0x8000:
		return 0
	var turn := m.u8(JoeyMem.TURN)
	if turn & 0x10 and (m.u8(JoeyMem.MODE) ^ turn) & 1:
		var packet := m.local(4)
		m.set_u32(packet, 1)
		f5bd090(0xf058, packet, 2)
		return 0
	var old := m.u8(_JQ_HOLD)
	m.set_u16(_JQ_HOLD, m.u16(_JQ_HOLD) ^ (((hold + 1) ^ old) & 0xff))
	if old == 0:
		m.set_u16(_JQ_HOLD, m.u16(_JQ_HOLD) & 0x80ff)
		m.set_u16(_JQ_HOLD_FLAGS, m.u16(_JQ_HOLD_FLAGS) & 0xdfff)
	return 0


## Joey FUN_00579890: reanuda los avisos continuos (decrementa el contador de a55c94); en red,
## si el turno no es local, lo pide con el paquete 0xf058.
func f579890() -> int:
	var hold := m.u32(_JQ_HOLD)
	if hold & 0x8000:
		return 0
	var turn := m.u8(JoeyMem.TURN)
	if turn & 0x10 and (m.u8(JoeyMem.MODE) ^ turn) & 1:
		var packet := m.local(4)
		m.set_u32(packet, 0)
		f5bd090(0xf058, packet, 2)
		return 0
	var old := m.u8(_JQ_HOLD)
	m.set_u16(_JQ_HOLD, m.u16(_JQ_HOLD) ^ (((hold - 1) ^ old) & 0xff))
	return 0


## Joey FUN_005798f0: cambia el bit `bit` de la palabra de reglas a577ec (570670) y lo
## anuncia con 0x0c si su valor no es ya `value`.
func f5798f0(bit: int, value: int) -> int:
	if (m.u32(_JQ_RULES) >> (bit & 0x1f)) & 1 != (value & 0xffffffff):
		f570670(bit, value)
		f5b9170(0xc, bit, value, 0)
	return 0


## Joey FUN_00579930: cambia el bit `bit` de las banderas a56430 de p (5706b0) y lo anuncia
## con 0x0d si su valor no es ya `value`.
func f579930(p: int, bit: int, value: int) -> int:
	if (m.u32(JoeyMem.pl(p) + 0x6d0) >> (bit & 0x1f)) & 1 != (value & 0xffffffff):
		f5706b0(p, bit, value)
		f5b9170(_jq_op(p, 0xd), bit, value, 0)
	return 0


## Joey FUN_00579990: cambia el bit `bit` del estado +0x8c de la zona z de p (570710) y lo
## anuncia con 0x0e si su valor no es ya `value`.
func f579990(p: int, z: int, bit: int, value: int) -> int:
	var at := (JoeyMem.zone(p, 0) + JoeyMem.Z_STATUS + z * JoeyMem.ZONE_SIZE) & 0xffffffff
	if (m.u32(at) >> (bit & 0x1f)) & 1 != (value & 0xffffffff):
		f570710(p, z, bit, value)
		f5b9170(_jq_op(p, 0xe), z, bit, value)
	return 0


## Joey FUN_00598b50: 1 si la carta idx en la zona z de p cuenta como "boca arriba continua":
## monstruo en magia/trampa, magia/trampa continua (subtipo 3) boca arriba o fuera del campo, o
## 0x28a/0x291/0x4ea boca arriba sin el bit 1 de estado.
func f598b50(p: int, z: int, idx: int) -> int:
	if idx & 0xffffffff == 0:
		return 0
	var zs := _s32(z)
	if zs > 4 and zs < 10 and f402690(idx) != 0:
		return 1
	if f402700(idx) & 0xffff == 3:
		if zs <= 4:
			return 0
		if zs > 10:
			return 1
		return (m.u8(JoeyMem.zone(p, z) + JoeyMem.Z_FLAGS) >> 1) & 1
	var card_id := f4022e0(idx) & 0xffff
	if card_id == 0x28a or card_id == 0x291 or card_id == 0x4ea:
		if zs > 4 and zs < 10:
			var at := JoeyMem.zone(p, z)
			if m.u8(at + JoeyMem.Z_FLAGS) & 2 and m.u8(at + JoeyMem.Z_STATUS) & 2 == 0:
				return 1
	return 0


## Joey FUN_00598c40: 1 si la carta idx en la zona z de p queda anulada por las reglas
## continuas de a577ec (bits 2-5, 16-19) con las excepciones de 0x409 (sin 0x2ef) y 0x603.
func f598c40(p: int, z: int, idx: int) -> int:
	var on := 0
	if f4025d0(idx) & 0xffff == 0x15:
		on = int(m.u32(_JQ_RULES) & 8 != 0)
	else:
		if _s32(z) <= 4:
			if f567620(idx, 0xffffffff) != 0 and m.u8(_JQ_RULES) & 0x20:
				return 1
			return 0
		on = int(m.u32(_JQ_RULES) & 4 != 0)
	if f402700(idx) & 0xffff == 3 or f598b50(p, z, idx) != 0:
		var rules := m.u32(_JQ_RULES)
		if rules & 0x10 or rules & 0x10000:
			on = 1
	if f4022e0(idx) & 0xffff == 0x409 and f5699c0(0x2ef) == 0:
		on = 0
	match f402700(idx) & 0xffff:
		2:
			if m.u32(_JQ_RULES) & 0x20000:
				on = 1
		4:
			match f4025d0(idx) & 0xffff:
				0x15:
					if m.u32(_JQ_RULES) & 0x80000:
						on = 1
				0x16:
					if m.u32(_JQ_RULES) & 0x40000:
						on = 1
	if f4022e0(idx) & 0xffff == 0x603:
		on = 0
	return on


## Joey FUN_00598d70: recalcula las reglas continuas 2-5 de a577ec (0x2ef, 0x409, 0x482, 0x601,
## 0x5fa en juego) y el bit 5 de estado (anulada) de cada carta boca arriba del campo segun
## 598c40; devuelve 1 si cambio alguna anulacion.
func f598d70() -> int:
	var locked := (m.u32(_JQ_RULES) >> 0x13) & 1
	var b3 := 0
	var b2 := 0
	var b4 := 0
	var b5 := 0
	if f5699c0(0x2ef) != 0:
		b3 = 1
	elif locked == 0:
		if f569b00(0x409) != 0:
			b3 = 1
		else:
			b2 = int(f569b00(0x482) != 0)
			b4 = int(f569b00(0x601) != 0)
			b5 = int(f569b00(0x5fa) != 0)
	f5798f0(3, b3)
	f5798f0(2, b2)
	f5798f0(4, b4)
	f5798f0(5, b5)
	var changed := 0
	for q in 2:
		for z in 11:
			var at := JoeyMem.zone(q, z)
			var index := m.u32(at) & 0xfff
			if index == 0 or m.u8(at + JoeyMem.Z_FLAGS) & 2 == 0:
				continue
			var off := f598c40(q, z, index)
			var status := m.u8(at + JoeyMem.Z_STATUS)
			if off == 0:
				if status & 0x20:
					f579990(q, z, 5, 0)
					changed = 1
					f59d370(q, z)
			elif status & 0x20 == 0:
				f579990(q, z, 5, 1)
				changed = 1
	return changed


## Joey FUN_00598ed0: posicion del id de la carta idx en la tabla fija 5ed060, o -1.
func f598ed0(idx: int) -> int:
	if m.u32(_JQ_ID_TABLE) & 0x3ffe000 == 0:
		return 0xffffffff
	var at := _JQ_ID_TABLE
	var i := 0
	while true:
		var card_id := f4022e0(idx) & 0xffff
		if (m.u32(at) >> 0xd) & 0x1fff == card_id:
			return i
		at += 4
		i += 1
		if m.u32(at) & 0x3ffe000 == 0:
			break
	return 0xffffffff


## Joey FUN_00598f30: 1 si p tiene en la mano una carta con el id de la entrada k de la tabla
## 5ed060 que 56b440 no bloquea.
func f598f30(p: int, k: int) -> int:
	var pl := JoeyMem.pl(p)
	var i := 0
	while i < m.u8(pl + JoeyMem.P_HAND_N):
		var at := pl + JoeyMem.P_HAND + i * 4
		var card_id := f4022e0(m.u16(at) & 0xfff) & 0xffff
		if card_id == m.u32((_JQ_ID_TABLE + k * 4) & 0xffffffff) & 0x1fff:
			if f56b440(m.u32(at) & 0xfff, 0xffffffff) == 0:
				return 1
		i = (i + 1) & 0xffff
	return 0


## Joey FUN_00598ff0: suma de niveles de la mano de p sin contar la primera copia del indice.
func f598ff0(p: int, index: int) -> int:
	var pl := JoeyMem.pl(p)
	if m.u8(pl + JoeyMem.P_HAND_N) == 0:
		return 0
	var target := index & 0xffff
	var sum := 0
	var found := false
	var i := 0
	while true:
		var card := m.u16(pl + JoeyMem.P_HAND + i * 4) & 0xfff
		if found or card != target:
			sum += f4026c0(card) & 0xffff
			if target == card:
				found = true
		else:
			found = true
		i += 1
		if m.u8(pl + JoeyMem.P_HAND_N) <= i:
			return sum & 0xffffffff
	return 0


## Joey FUN_0059c8d0: voltea boca arriba la carta de (p, z) (578390 y 0x8b) salvo que este
## protegida (bit 9 o posicion >= 0x10); si no estaba anulada, anuncia con 0x86 cada monstruo
## boca arriba de tipo 2 (56f6d0) que 56dc10 relaciona con ella.
func f59c8d0(p: int, z: int) -> int:
	var at := (JoeyMem.zone(p, 0) + z * JoeyMem.ZONE_SIZE) & 0xffffffff
	var fl := m.u16(at + JoeyMem.Z_FLAGS)
	if fl & 0x200 or fl & 0x3c >= 0x10:
		return 0
	if m.u8(at + JoeyMem.Z_STATUS) & 0x20:
		f5b9170(_jq_op(p, 0x8b), z, 1, 0)
		return 0
	f578390(p, m.u16(at) & 0xfff, z)
	f5b9170(_jq_op(p, 0x8b), z, 1, 0)
	for q in 2:
		for zz in 5:
			var qat := JoeyMem.zone(q, zz)
			if m.u32(qat) & 0xfff == 0 or m.u8(qat + JoeyMem.Z_FLAGS) & 2 == 0:
				continue
			if f56f6d0(q, zz) & 0xffff != 2:
				continue
			if _s32(f56dc10(q, zz, p, z)) < 0:
				continue
			f5747e0(p, ((z & 0xff) << 8) | (p & 0xff), ((zz & 0xff) << 8) | q, 6)
	return 0
