class_name JoeyPortN
extends JoeyPortM
## Motor nativo de Joey, lote N de la etapa 3: M3 575160-576360 (emisores de comandos y marca de destruccion 576360).
## Cada funcion se llama f<direccion de Joey_Pc.exe> y sobrescribe su declaracion con la misma
## aridad. Cotejo: re/scripts/joey_specs/port_n.py.
##
## 576110 es cdecl de 7 argumentos (Ghidra le anade ECX/EDX como basura de registro, que solo
## acaba en bits altos que 5b9170 descarta).

## Marcas de destruccion de 576360/576200 (bit (p << 4) + z) y turno.
const _JN_MARKS := 0xa577f0
const _JN_TURN := 0xa577fa


## Bit 15 del opcode: jugador distinto de 0.
static func _jn_side(p: int) -> int:
	return 0x8000 if (p & 0xffffffff) != 0 else 0


## Byte alto de los comandos 0x8e: (identidad * 2 + propietario) truncado a 8 bits.
static func _jn_key_hi(e: int) -> int:
	return (JoeyMem.ident(e) & 0xff) << 8


## Contador de mano (u8 +8) del jugador p & 1.
func _jn_hand_n(p: int) -> int:
	return m.u8(JoeyMem.pl(p) + JoeyMem.P_HAND_N)


## 576360 (0x447/0x488): boca arriba (+6 bit 1) y sin los bits 1 y 5 del estado +0x8c.
func _jn_bound_live(p: int, z: int) -> bool:
	var at := JoeyMem.zone(p, z)
	var status := m.u32(at + JoeyMem.Z_STATUS)
	return ((m.u8(at + 6) >> 1) & ~(status >> 5) & ~(status >> 1) & 1) != 0


## Joey FUN_00575160: emite 0x80 (bit 15 si a != 0) con b, c y 0x100.
func f575160(a: int, b: int, c: int) -> int:
	f5b9170(_jn_side(a) | 0x80, b, c, 0x100)
	return 0


## Joey FUN_00575190: 575210(p, z, a, b, 0) salvo si e es magia y 56c460(p, z) protege la carta.
func f575190(p: int, z: int, a: int, b: int, e: int) -> int:
	if (f4025d0(e) & 0xffff) == 0x16 and f56c460(p, z) != 0:
		return 0
	return f575210(p, z, a, b, 0)


## Joey FUN_005751e0: 575190(a, b, c, d, *(u16 *)ptr).
func f5751e0(ptr: int, a: int, b: int, c: int, d: int) -> int:
	return f575190(a, b, c, d, m.u16(ptr))


## Joey FUN_00575210: cambia de posicion la carta de la zona de monstruo (p, z): emite 0x7f
## (z, boca arriba pedida, aviso), 579990 si avisa, y encadena 5ba490 para 0x5e / 0x77, 0xa1,
## 0x1f0 al voltearse, para la carta de la lista 567620 sin 0x5fa en juego y 598590 al voltear.
func f575210(p: int, z: int, face: int, check: int, notify: int) -> int:
	var at := JoeyMem.zone(p, z)
	var index := m.u16(at) & 0xfff
	if _s32(z) >= 5 or index == 0:
		return 0
	var flags := m.u16(at + 6)
	var up := (flags >> 1) & 1
	var down := (~flags) & 1
	var hi := (((((((up ^ face) & 1) << 1) | down) << 4) | (z & 0xf)) << 1 | (p & 1)) & 0xff
	var word := ((hi << 8) | (z & 0x80ff)) & 0xffff
	word ^= ((JoeyMem.ident(m.u32(at)) ^ z) & 0xff)
	f5b9170(_jn_side(p) | 0x7f, z, face, notify)
	if notify != 0:
		f579990(p, z, 0x11, 1)
	var chain := (((z & 0x1f) | (p << 15) | 0x1420) << 16 | index) & 0xffffffff
	if (face == 0) != (up == 0):
		var card_id := f4022e0(index) & 0xffff
		var hit := card_id == 0x5e
		if down != 0:
			hit = card_id == 0x77 or card_id == 0xa1 or card_id == 0x1f0
		if hit:
			f5ba490(chain, word & 0xff, word)
	if check != 0:
		if face == 0:
			return 1
		if up == 0 and f567620(index, 0) != 0 and f5699c0(0x5fa) == 0:
			f5ba490(chain, word & 0xff, word)
	if face != 0 and up != 0:
		f598590(m.u8(_JN_TURN) & 1, 8, word)
	return 1


## Joey FUN_005754a0: voltea o cambia de posicion la carta de (p, z) segun su estado (574f70 si
## esta boca arriba en defensa sin 0x47f en juego), salvo magia e protegida por 56c460.
func f5754a0(p: int, z: int, e: int) -> int:
	var free := f5699c0(0x47f) == 0
	if (f4025d0(e) & 0xffff) == 0x16 and f56c460(p, z) != 0:
		return 0
	var flags := m.u16(JoeyMem.zone(p, z) + 6)
	if free and (flags & 2) != 0:
		if (flags & 1) != 0:
			f574f70(p, z, 0, e)
			return 0
		f575190(p, z, 1, 0, e)
		return 0
	if (m.u8(JoeyMem.zone(p, z) + 6) & 1) == 0:
		f575190(p, z, 0, 0, e)
	return 0


## Joey FUN_00575570: tras mover la carta de a = (z << 8) | p a b, emite 0x8a por cada equipo
## 0x60c vinculado y, si es 0x1e3 o 0x222 en defensa (+7 bit 1) y el destino es monstruo, pide la
## respuesta 578390 y emite 0x94.
func f575570(a: int, b: int) -> int:
	var p := a & 0xff
	var z := (a >> 8) & 0xff
	var q := b & 0xff
	var qz := (b >> 8) & 0xff
	if p == q:
		return 0
	var at := JoeyMem.zone(p, z)
	if (m.u8(at + 6) & 2) == 0:
		return 0
	var i := 0
	while i < m.u16(at + JoeyMem.Z_LINKS_N):
		var ref := m.u16(at + JoeyMem.Z_LINK_REF + i * 2)
		if (m.u8(at + JoeyMem.Z_LINK_KIND + i * 2) & 0xf) == 1:
			var rp := ref & 0xff
			var rz := ref >> 8
			if (f4022e0(m.u16(JoeyMem.zone(rp, rz)) & 0xfff) & 0xffff) == 0x60c:
				f5b9170(_jn_side(rp) | 0x8a, rz, 0, 0)
		i += 1
	var card_id := f4022e0(m.u16(at) & 0xfff) & 0xffff
	if card_id != 0x1e3 and card_id != 0x222:
		return 0
	if qz >= 5 or (m.u8(at + 7) & 2) == 0:
		return 0
	f578390(q, m.u16(at) & 0xfff, qz)
	if card_id == 0x1e3:
		f5784e0(q, 2000)
	else:
		f5787f0(p, 3000)
	f5b9170(_jn_side(q) | 0x94, qz, 0, 0)
	return 0


## Joey FUN_00575750: mueve la carta de la zona a a la zona b vacia (0x83) y avisa 575570.
func f575750(_unused: int, a: int, b: int) -> int:
	if (m.u32(JoeyMem.zone(a & 1, (a >> 8) & 0xff)) & 0xfff) != 0 \
			and (m.u32(JoeyMem.zone(b & 1, (b >> 8) & 0xff)) & 0xfff) == 0:
		f5b9170(_jn_side(a & 0xff) | 0x83, a, b, 0)
		f575570(a, b)
	return 0


## Joey FUN_00575800: intercambia las cartas de las zonas a y b ocupadas (0x85) y avisa 575570
## en los dos sentidos.
func f575800(side: int, a: int, b: int) -> int:
	if (m.u16(JoeyMem.zone(a & 1, (a >> 8) & 0xff)) & 0xfff) != 0 \
			and (m.u16(JoeyMem.zone(b & 1, (b >> 8) & 0xff)) & 0xfff) != 0:
		f5b9170(_jn_side(side) | 0x85, a, b, 0)
		f575570(a, b)
		f575570(b, a)
	return 0


## Joey FUN_005758a0: emite 0x8e para llevar la carta i de la mano de p al mazo (0x1a), arriba
## si flag != 0.
func f5758a0(p: int, i: int, flag: int) -> int:
	var e := m.u32(f5700f0(p, 0xb, i))
	var bit := (e >> 12) & 1
	f5b9170(0x8e, _jn_key_hi(e) | ((p & 1) | 0x16), (int(flag == 0) << 8) | (bit | 0x1a), 0)
	return 0


## Joey FUN_00575900: emite 0x8e para sacar la identidad k del cementerio de p hacia la mano o
## el mazo de fusion (0xd / 0xc segun 567ad0), si esta en el cementerio.
func f575900(p: int, k: int, flag: int) -> int:
	if _s32(f568ad0(p, k)) < 0:
		return 0
	var dest := 0xd - int(f567ad0(f568b90(k)) != 0)
	var b := ((((dest & 0x7f) | (int(flag == 0) << 7)) << 1) | (p & 1)) & 0xffff
	f5b9170(0x8e, ((k & 0xff) << 8) | ((p & 1) | 0x1c), b, 0)
	return 0


## Joey FUN_00575970: descarta la carta i de la mano de p (5759a0 sobre su entrada).
func f575970(p: int, i: int, d: int) -> int:
	return f5759a0(p, i, f5700f0(p, 0xb, i), d)


## Joey FUN_005759a0: descarta la entrada ptr de la mano de p (575af0) y avisa 59ce90 si es
## del propio p, 59d240 y 598590 (0x1e).
func f5759a0(p: int, i: int, ptr: int, d: int) -> int:
	if _s32(i) < 0:
		return 0
	f575af0(p, ptr, int(d != 0))
	if (p & 0xffffffff) == ((m.u32(ptr) >> 12) & 1):
		f59ce90(p, 1)
	f59d240(p)
	f598590(m.u8(_JN_TURN) & 1, 0x1e, p & 0xff)
	return 0


## Joey FUN_00575a10: descarta la carta i de la mano de p y, si 570c70 lo pide, la respuesta
## 0x443 (578400 y 5784e0).
func f575a10(p: int, i: int) -> int:
	if _s32(i) < 0:
		return 0
	var ptr := f5700f0(p, 0xb, i)
	f5759a0(p, i, ptr, 0)
	if f570c70(p, JoeyMem.ident(m.u32(ptr))) != 0:
		f578400(p, f402460(0x443))
		f5784e0(p, 2000)
	return 0


## Joey FUN_00575a80: emite 0x8e de la mano a las excluidas (0x1e) con su contador.
func f575a80(p: int, ptr: int, c: int) -> int:
	var e := m.u32(ptr)
	var bit := (e >> 12) & 1
	var banished := m.u8(JoeyMem.pl(bit) + JoeyMem.P_BANISH_N)
	f5b9170(0x8e, _jn_key_hi(e) | ((p & 1) | 0x16), (banished << 8) | (bit | 0x1e), c)
	return 0


## Joey FUN_00575af0: manda al cementerio (0x11c) la entrada ptr de la mano de p, o la excluye
## con 0x453 en juego; encadena 5ba490 para 0x1de/0x412/0x4da (y 0x1ce/0x215 si c y es de p),
## y avisa 59d6e0 y 598590 (0x1f).
func f575af0(p: int, ptr: int, c: int) -> int:
	if f5699c0(0x453) != 0:
		f575a80(p, ptr, c)
		return 0
	var e := m.u32(ptr)
	var bit := (e >> 12) & 1
	f5b9170(0x8e, _jn_key_hi(e) | ((p & 1) | 0x16), bit | 0x11c, c)
	var card_id := f4022e0(m.u16(ptr) & 0xfff) & 0xffff
	var hit := card_id == 0x1de or card_id == 0x412 or card_id == 0x4da
	if card_id == 0x215 or card_id == 0x1ce:
		hit = (c & 1) != 0 and ((m.u32(ptr) >> 12) & 1) == (p & 0xffffffff)
	if hit:
		var v := m.u32(ptr)
		f5ba490((((v & 0xfffff7c9) << 0x13) | (v & 0xfff) | 0x3e4e0000) & 0xffffffff, JoeyMem.ident(v), 0)
	f59d6e0((m.u32(ptr) >> 12) & 1, 1)
	f598590(m.u8(_JN_TURN) & 1, 0x1f, (JoeyMem.ident(m.u32(ptr)) & 0xffff) | (int((c & 1) != 0) << 16))
	return 0


## Joey FUN_00575c40: si la carta ptr esta en el cementerio de p, emite 0x8e hacia la mano
## (0xb) o el mazo de fusion (0xc); si va a la mano, emite tambien 0x1f con su id.
func f575c40(p: int, ptr: int) -> int:
	if _s32(f56cb40(p, ptr)) < 0:
		return 0
	var hand := _jn_hand_n(p)
	var dest := 0xb + int(f567ad0(m.u16(ptr) & 0xfff) != 0)
	var b := ((((dest & 0x7f) | (hand << 7)) << 1) | (p & 1)) & 0xffff
	f5b9170(0x8e, _jn_key_hi(m.u32(ptr)) | ((p & 1) | 0x1c), b, 0)
	if f567ad0(m.u16(ptr) & 0xfff) == 0:
		var card_id := f4022e0(m.u16(ptr) & 0xfff)
		f5b9170(_jn_side(p) | 0x1f, card_id, _jn_hand_n(p), 0)
	return 1


## Joey FUN_00575d50: como 575c40 desde el efecto e (+2 bit 0 = jugador): c = 1 si el efecto
## es del rival, y el 0x1f lo emite el jugador del efecto.
func f575d50(e: int, p: int, ptr: int) -> int:
	if _s32(f56cb40(p, ptr)) < 0:
		return 0
	var foreign := int((m.u8(e + 2) & 1) != (p & 0xffffffff))
	var hand := _jn_hand_n(p)
	var dest := 0xb + int(f567ad0(m.u16(ptr) & 0xfff) != 0)
	var b := ((((dest & 0x7f) | (hand << 7)) << 1) | (p & 1)) & 0xffff
	f5b9170(0x8e, _jn_key_hi(m.u32(ptr)) | ((p & 1) | 0x1c), b, foreign)
	if f567ad0(m.u16(ptr) & 0xfff) == 0:
		var owner := m.u8(e + 2) & 1
		var card_id := f4022e0(m.u16(ptr) & 0xfff)
		f5b9170(((m.u16(e + 2) & 1) << 15) | 0x1f, card_id, _jn_hand_n(owner), 0)
	return 1


## Joey FUN_00575e80: como 575d50, pero la carta va a la mano del rival de p y el 0x1f lo emite
## el rival del jugador del efecto.
func f575e80(e: int, p: int, ptr: int) -> int:
	if _s32(f56cb40(p, ptr)) < 0:
		return 0
	var foreign := int((m.u8(e + 2) & 1) != ((1 - p) & 0xffffffff))
	var other := (~p) & 1
	var hand := _jn_hand_n(other)
	var dest := 0xb + int(f567ad0(m.u16(ptr) & 0xfff) != 0)
	var b := ((((dest & 0x7f) | (hand << 7)) << 1) | other) & 0xffff
	f5b9170(0x8e, _jn_key_hi(m.u32(ptr)) | ((p & 1) | 0x1c), b, foreign)
	if f567ad0(m.u16(ptr) & 0xfff) == 0:
		var rival := 1 - (m.u8(e + 2) & 1)
		var card_id := f4022e0(m.u16(ptr) & 0xfff)
		f5b9170(_jn_side(rival) | 0x1f, card_id, _jn_hand_n(rival), 0)
	return 1


## Joey FUN_00575fe0: emite 0x8e para excluir (0x11e) la carta ptr del cementerio de p, tras
## buscarla con 5687d0.
func f575fe0(p: int, ptr: int, c: int) -> int:
	f5687d0(JoeyMem.ident(m.u32(ptr)))
	var e := m.u32(ptr)
	f5b9170(0x8e, _jn_key_hi(e) | ((p & 1) | 0x1c), (p & 1) | 0x11e, int(c != 0))
	return 0


## Joey FUN_00576050: busca en el mazo de p la primera carta con ese id y emite 0x8e para
## llevarla a la mano (0x16 con el contador de mano); 1 si la encuentra.
func f576050(p: int, card_id: int) -> int:
	var pl := JoeyMem.pl(p)
	if (m.u16(pl + JoeyMem.P_HAND_N) & 0xff00) == 0:
		return 0
	var at := pl + JoeyMem.P_DECK
	var i := 0
	while true:
		if (f4022e0(m.u16(at) & 0xfff) & 0xffff) == (card_id & 0xffff):
			var e := m.u32(at)
			f5b9170(0x8e, _jn_key_hi(e) | ((p & 1) | 0x1a), (m.u8(pl + JoeyMem.P_HAND_N) << 8) | ((p & 1) | 0x16), 0)
			return 1
		i += 1
		at += 4
		if i >= (m.u16(pl + JoeyMem.P_HAND_N) >> 8):
			break
	return 0


## Joey FUN_00576110: emite 0x90 con (b & 0x7f | c << 7) << 1 | a & 1, (e & 0x7f) << 1 | d & 1 y
## g << 8 | f (bytes).
func f576110(a: int, b: int, c: int, d: int, e: int, f: int, g: int) -> int:
	var x := ((((b & 0x7f) | ((c & 0xff) << 7)) << 1) | (a & 1)) & 0xffff
	var y := (((e & 0x7f) << 1) | (d & 1)) & 0xffff
	f5b9170(0x90, x, y, ((g & 0xff) << 8) | (f & 0xff))
	return 0


## Joey FUN_00576170: rand() y, si quedan al menos dos monstruos boca abajo en defensa de p
## (bit 0 sin bit 1), emite 0xae con la tirada y la mascara filtrada.
func f576170(p: int, mask: int) -> int:
	var r := rng.rand()
	var count := 0
	for i in 5:
		var at := JoeyMem.zone(p, i)
		var flags := m.u16(at + 6)
		if (m.u32(at) & 0xfff) == 0 or (flags & 2) != 0 or (flags & 1) == 0:
			mask &= ~(1 << i)
		else:
			count += 1
	if count > 1:
		f5b9170(_jn_side(p) | 0xae, r, r >> 16, mask)
	return 0


## Joey FUN_00576200: 1 si la carta de (p, z) puede ser objetivo del efecto e: ocupada, sin marca
## a577f0, no protegida por 56c460 frente a magias y, con e +4 bit 4 y flag contra el rival en
## magia/trampa, que no sea trampa salvo 0x2b1 con el estado bit 2.
func f576200(e: int, p: int, z: int, flag: int) -> int:
	var at := JoeyMem.zone(p, z)
	var index := m.u32(at) & 0xfff
	if index == 0:
		return 0
	if (m.u32(_JN_MARKS) & (1 << (((p << 4) + z) & 0x1f))) != 0:
		return 0
	if (f4025d0(m.u16(e)) & 0xffff) == 0x16 and f56c460(p, z) != 0:
		return 0
	if (m.u8(e + 4) & 0x10) != 0 and flag != 0:
		var desc := m.u16(e + 2)
		var rival := 1 - (((desc >> 0xe) & 1) ^ (desc & 1))
		if (p & 0xffffffff) == rival and _s32(z) >= 5 and (f4025d0(index) & 0xffff) == 0x15:
			if (f4022e0(index) & 0xffff) != 0x2b1 or (m.u8(at + JoeyMem.Z_STATUS) & 4) == 0:
				return 0
	return 1


## Joey FUN_00576300: filtra la mascara (bit (p << 4) + z, z 0-10) con 576200.
func f576300(e: int, mask: int, flag: int) -> int:
	var result := 0
	for p in 2:
		for z in 11:
			var bit := 1 << ((p * 16 + z) & 0x1f)
			if (mask & bit) != 0 and f576200(e, p, z, flag) != 0:
				result |= bit
	return result


## Joey FUN_00576360: marca para destruir la carta de (p, z) en a577f0 y propaga la marca:
## 0x488/0x447 a la carta que la lleva (56b250), 0x3ba a los toon, 0x5f8 y 0x605-0x608 a sus
## pares, 0x14d en el campo a los 0x58f, y a las cartas de sus vinculos 1/4/5 y 2/6/7 (0x4dc,
## 0x589 y, en cadena, 0x15c/0x447). Salvo magia e protegida por 56c460.
func f576360(p: int, z: int, deep: int, e: int) -> int:
	var index := f570230(p, z, 0)
	if (f4025d0(e) & 0xffff) == 0x16 and f56c460(p, z) != 0:
		return 0
	if (index & 0xffff) == 0:
		return 0
	var shift := (p << 4) & 0xffffffff
	var bit := 1 << ((shift + z) & 0x1f)
	var marks := m.u32(_JN_MARKS)
	if (bit & marks) != 0:
		return 0
	m.set_u32(_JN_MARKS, marks | bit)
	var card_id := f4022e0(index) & 0xffff
	if card_id == 0x488:
		if deep != 0 and _jn_bound_live(p, z):
			var ref := f56b250(p, z)
			if (ref & 0xffff) != 0xffff:
				var rp := ref & 0xff
				var rz := (ref >> 8) & 0xff
				var at := JoeyMem.zone(rp, rz)
				if (m.u32(at) & 0xfff) != 0 and (m.u8(at + 6) & 2) != 0:
					f576360(rp, rz, 1, index & 0xffff)
	elif card_id == 0x3ba:
		if deep != 0:
			for q in 2:
				for k in 5:
					var at := JoeyMem.zone(q, k)
					if (m.u8(at + 6) & 2) != 0 and f5675f0(m.u16(at) & 0xfff) != 0:
						var v := m.u32(at)
						if f56b440(v & 0xfff, JoeyMem.ident(v)) == 0:
							f576360(q, k, 1, index & 0xffff)
	elif card_id == 0x447:
		if _jn_bound_live(p, z):
			var ref := f56b250(p, z)
			if (ref & 0xffff) != 0xffff:
				f576360(ref & 0xff, (ref >> 8) & 0xff, 1, index & 0xffff)
	elif card_id == 0x5f8 or (card_id > 0x604 and card_id <= 0x608):
		if _s32(z) >= 5 and (m.u8(JoeyMem.zone(p, z) + 6) & 2) != 0 and f5699a0(p, 0x5f8) != 0:
			for k in range(5, 10):
				var at := JoeyMem.zone(p, k)
				if k == (z & 0xffffffff) or (m.u32(at) & 0xfff) == 0 or (m.u8(at + 6) & 2) == 0:
					continue
				var other := f4022e0(m.u16(at) & 0xfff) & 0xffff
				if other == 0x5f8 or (other > 0x604 and other <= 0x608):
					f576360(p, k, 1, f402460(0x5f8) & 0xffff)
	if (z & 0xffffffff) == 10 and (m.u8(JoeyMem.zone(p, 10) + 6) & 2) != 0:
		var rival := JoeyMem.zone((-1 - p) & 1, 10)
		var go := (m.u32(rival) & 0xfff) == 0 or (m.u8(rival + 6) & 2) == 0 \
				or ((1 << ((0x1a - shift) & 0x1f)) & m.u32(_JN_MARKS)) != 0
		if go and (f4022e0(index) & 0xffff) == 0x14d:
			for q in 2:
				for k in range(5, 11):
					var at := JoeyMem.zone(q, k)
					if (f4022e0(m.u16(at) & 0xfff) & 0xffff) == 0x58f and (m.u8(at + 6) & 2) != 0 \
							and (m.u8(at + JoeyMem.Z_STATUS) & 0x20) == 0:
						f576360(q, k, 1, index & 0xffff)
	var zone := JoeyMem.zone(p, z)
	var i := 0
	while i < m.u16(zone + JoeyMem.Z_LINKS_N):
		var ref := m.u16(zone + JoeyMem.Z_LINK_REF + i * 2)
		var rp := ref & 0xff
		var rz := ref >> 8
		match m.u8(zone + JoeyMem.Z_LINK_KIND + i * 2) & 0xf:
			1, 4, 5:
				if (m.u32(JoeyMem.zone(rp, rz)) & 0xfff) != 0:
					f576360(rp, rz, 1, 0)
			2, 6, 7:
				var at := JoeyMem.zone(rp, rz)
				var other := f4022e0(m.u16(at) & 0xfff) & 0xffff
				var free := (m.u8(at + JoeyMem.Z_STATUS) & 0x20) == 0
				if other == 0x4dc or other == 0x589:
					if free:
						f576360(rp, rz, 1, 0)
				elif other == 0x15c or other == 0x447:
					if free and deep != 0:
						f576360(rp, rz, 1, 0)
		i += 1
	return 0
