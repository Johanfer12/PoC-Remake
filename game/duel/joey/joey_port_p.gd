class_name JoeyPortP
extends JoeyPortO
## Motor nativo de Joey, lote P de la etapa 3: M3 577880-578bb0 (emisores, pagos 5784e0/5787f0).
## Cada funcion se llama f<direccion de Joey_Pc.exe> y sobrescribe su declaracion con la misma
## aridad. Cotejo: re/scripts/joey_specs/port_p.py.


## Bit de la zona (p, z) en las mascaras de 576960: shl por cl, que solo usa los 5 bits bajos.
static func _jp_bit(p: int, z: int) -> int:
	return 1 << (((p << 4) + z) & 0x1f)


## Variable local {u16 carta, u16 lado, 16 bytes a cero} que pasan a 576960 los emisores sin info.
func _jp_info(card: int, side: int) -> int:
	var at := m.local(0x14)
	m.set_u16(at, card)
	m.set_u16(at + 2, side)
	return at


static func _jp_hi(p: int) -> int:
	return 0x8000 if p != 0 else 0


## Joey FUN_00577880: destruye la carta de (p, z) por efecto de info (576940); 1 si se destruyo.
func f577880(info: int, p: int, z: int) -> int:
	var bit := _jp_bit(p, z)
	return int(f576940(info, bit) & bit != 0)


## Joey FUN_005778b0: destruye (p, z) al cementerio con banderas 0xa; 1 si se destruyo.
func f5778b0(info: int, p: int, z: int) -> int:
	var bit := _jp_bit(p, z)
	return int(f576960(info, bit, 0xe, 0xa) & bit != 0)


## Joey FUN_005778f0: excluye la carta de (p, z) sin carta causante; 1 si se excluyo.
func f5778f0(p: int, z: int, flags: int) -> int:
	var bit := _jp_bit(p, z)
	var info := _jp_info(0, p & 1)
	return int(f576960(info, bit, 0xf, flags) & bit != 0)


## Joey FUN_00577950: excluye la carta de (p, z) por efecto de info; 1 si se excluyo.
func f577950(info: int, p: int, z: int, flags: int) -> int:
	var bit := _jp_bit(p, z)
	return int(f576960(info, bit, 0xf, flags) & bit != 0)


## Joey FUN_00577990: devuelve a la mano la carta de (p, z); 1 si se devolvio.
func f577990(info: int, p: int, z: int) -> int:
	var bit := _jp_bit(p, z)
	return int(f576960(info, bit, 0xb, 0) & bit != 0)


## Joey FUN_005779d0: devuelve a la mano (p, z) por la carta card del lado side; 1 si se devolvio.
func f5779d0(p: int, z: int, side: int, card: int) -> int:
	var bit := _jp_bit(p, z)
	var info := _jp_info(card, (side ^ p) & 1)
	return int(f576960(info, bit, 0xb, 0) & bit != 0)


## Joey FUN_00577a40: devuelve a la mano las zonas de la mascara (deja en EAX lo de 576960).
func f577a40(info: int, mask: int) -> int:
	return f576960(info, mask, 0xb, 0)


## Joey FUN_00577a60: devuelve al mazo la carta de (p, z); 1 si se devolvio.
func f577a60(info: int, p: int, z: int) -> int:
	var bit := _jp_bit(p, z)
	return int(f576960(info, bit, 0xd, 0) & bit != 0)


## Joey FUN_00577aa0: devuelve al mazo las zonas de la mascara (deja en EAX lo de 576960).
func f577aa0(info: int, mask: int) -> int:
	return f576960(info, mask, 0xd, 0)


## Joey FUN_00577ac0: devuelve al mazo (p, z), con 0x20000 si la carta es del propio p.
func f577ac0(info: int, p: int, z: int) -> int:
	var bit := _jp_bit(p, z)
	var e := m.u32((0xa55d74 + z * 0x90 + (p & 1) * JoeyMem.PLAYER_SIZE) & 0xffffffff)
	var flags := 0 if ((e >> 0xc) & 1) != (p & 0xffffffff) else 0x20000
	return int(f576960(info, bit, 0xd, flags) & bit != 0)


## Joey FUN_00577b30: manda al cementerio (p, z) sin carta causante y con 0x1000; 1 si se hizo.
func f577b30(p: int, z: int) -> int:
	var bit := _jp_bit(p, z)
	var info := _jp_info(0, p & 1)
	return int(f576960(info, bit, 0xe, 0x1000) & bit != 0)


## Joey FUN_00577b90: manda al cementerio (p, z) sin carta causante y con 0x20; 1 si se hizo.
func f577b90(p: int, z: int) -> int:
	var bit := _jp_bit(p, z)
	var info := _jp_info(0, p & 1)
	return int(f576960(info, bit, 0xe, 0x20) & bit != 0)


## Joey FUN_00577bf0: manda al cementerio (p, z) por la carta card del lado side; 1 si se hizo.
func f577bf0(p: int, z: int, side: int, card: int) -> int:
	var bit := _jp_bit(p, z)
	var info := _jp_info(card, (side ^ p) & 1)
	return int(f576960(info, bit, 0xe, 0) & bit != 0)


## Joey FUN_00577c60: manda al cementerio la carta de (p, z) por efecto de info; 1 si se hizo.
func f577c60(info: int, p: int, z: int) -> int:
	var bit := _jp_bit(p, z)
	return int(f576960(info, bit, 0xe, 0) & bit != 0)


## Joey FUN_00577ca0: lleva (p, z) a la ubicacion kind, con 0x20000 si p != owner; 1 si se hizo.
func f577ca0(info: int, p: int, z: int, owner: int, kind: int) -> int:
	var bit := _jp_bit(p, z)
	var flags := 0x20000 if (p & 0xffffffff) != (owner & 0xffffffff) else 0
	return int(f576960(info, bit, kind, flags) & bit != 0)


## Joey FUN_00577cf0: sacrificio de la carta de (p, z) (z < 5): comando 0x7c, avisos de los
## monstruos con efecto al ir al cementerio (5ba490), aviso 0x15 y arrastre (577280).
func f577cf0(p: int, z: int, at: int, tribute: int, desc: int) -> int:
	if m.u32(at) & 0xfff == 0:
		return 0
	if _s32(z) >= 5:
		return 0
	var hi := _jp_hi(p)
	var t := int(tribute != 0)
	if is_token(m.u32(at) & 0xfff):
		f5b9170(hi | 0x7c, z, 0, t)
	elif f5699c0(0x453) != 0:
		f5b9170(hi | 0x7c, z, 1, t)
	else:
		f5b9170(hi | 0x7c, z, 0, t)
		f59d6e0((m.u32(at) >> 0xc) & 1, 1)
		var card_id := f4022e0(m.u16(at) & 0xfff) & 0xffff
		var notify := false
		match card_id:
			0x2f, 0x12f, 0x136, 0x138, 0x139, 0x140, 0x1de, 0x23d, 0x412, 0x414, 0x454, \
					0x456, 0x45a, 0x45b, 0x45d, 0x45f, 0x460, 0x463, 0x4da, 0x4e9, 0x57d:
				notify = true
			0x1cd, 0x45c:
				notify = m.u8(at + 7) & 2 == 0
			0x5ea:
				var e := m.u32(at)
				var own := (e >> 0xc) & 1
				if (p & 0xffffffff) == own and tribute != 0 \
						and f56b440(e & 0xfff, own + ((e >> 0x18) & 0x7f) * 2) == 0:
					e = m.u32(at)
					f5783c0(p, 0xe, m.u16(at) & 0xfff, JoeyMem.ident(e))
					e = m.u32(at)
					var b := ((((e >> 0x18) & 0x7f) << 1) + ((e >> 0xc) & 1)) & 0xff
					f579790(p, m.u16(at) & 0xfff, (b << 8) | 3)
		if notify:
			var e := m.u32(at)
			f5ba490((((e & 0xfffff549) << 0x13) | (e & 0xfff) | 0x2a4e0000) & 0xffffffff, JoeyMem.ident(e), desc)
	if f4022e0(m.u16(at) & 0xfff) & 0xffff == 0x4d9:
		var e := m.u32(at)
		f5ba490(((e & 0xfff) | ((p << 0x1f) & 0xffffffff) | 0x2a5f0000) & 0xffffffff, JoeyMem.ident(e), desc)
	f598590(m.u8(JoeyMem.TURN) & 1, 0x15, desc)
	f577280(at, p, z, t + 6)
	return 0


## Lado (bit 0 o 1 de a57840) y ubicacion (bits 8-10 u 11-13) de la carta separada idx.
func _jp_detached(idx: int) -> Array:
	var w := m.u32(JoeyMem.BATTLE) & 0xffff
	if idx == 0:
		return [w & 1, (w >> 8) & 7]
	return [(w >> 1) & 1, (w >> 0xb) & 7]


## Joey FUN_00578030: destruye la carta separada idx (a57864 + idx * 0x90) por efecto de la
## carta info: comando 0x79, efecto de destruccion (576f40), aviso 0x1c y arrastre. 1 si lo hizo.
func f578030(info: int, idx: int) -> int:
	var d := _jp_detached(idx)
	var side: int = d[0]
	var loc: int = d[1]
	var at := (JoeyMem.DETACHED + idx * 0x90) & 0xffffffff
	var index := m.u16(at) & 0xfff
	if f4025d0(m.u16(info)) & 0xffff == 0x16 and f56c460(side, loc) != 0:
		return 0
	if index == 0:
		return 0
	var v453 := f5699c0(0x453)
	var guarded := int(_s32(v453) > 0)
	var to_grave := 0
	if guarded == 0 and not is_token(index):
		to_grave = 1
	var e := m.u32(at)
	var other := int((m.u8(info + 2) & 1) != side)
	var fl := m.u16(at + 6)
	var c := ((0xf - to_grave) & 0xf) << 1 | ((other ^ side) & 1)
	c = (c << 2) | (fl & 2)
	c = (c << 2) | (fl & 1) | 2
	c = (c << 4) | (loc & 0xf)
	c = (c << 1) | (side & 1)
	var desc := ((c << 8) | (JoeyMem.ident(e) & 0xff)) & 0xffffffff
	var how := 3 if other != 0 else 2
	f5b9170(_jp_hi(side) | 0x79, ((loc & 0xff) << 8) | 0xff, ((-guarded) & 0xf) + 1, how)
	if to_grave:
		f59d6e0((m.u32(at) >> 0xc) & 1, 1)
	f576f40(desc, at)
	if not is_token(index):
		f598590(m.u8(JoeyMem.TURN) & 1, 0x1c, desc)
	f577280(at, side, loc, how)
	return 1


## Joey FUN_00578250: devuelve a la mano la carta separada idx por efecto de info (comando
## 0x8f, o 0x79 para las cartas 0x780-0x783) y arrastra sus ligadas. 1 si lo hizo.
func f578250(info: int, idx: int, flags: int) -> int:
	var d := _jp_detached(idx)
	var side: int = d[0]
	var loc: int = d[1]
	var at := (JoeyMem.DETACHED + idx * 0x90) & 0xffffffff
	var index := m.u16(at) & 0xfff
	if f4025d0(m.u16(info)) & 0xffff == 0x16 and f56c460(side, loc) != 0:
		return 0
	if index == 0:
		return 0
	if is_token(index):
		f5b9170(_jp_hi(side) | 0x79, ((loc & 0xff) << 8) | 0xff, 1, 0)
	else:
		if (m.u8(info + 2) & 1) != side:
			flags |= 1
		var b := ((m.u32(at) >> 0xc) & 1) | 0x11e
		var a := ((((loc & 0x7f) | 0xff80) << 1) | (side & 1)) & 0xffff
		f5b9170(0x8f, a, b, flags)
	f577280(at, side, loc, flags)
	return 1


## Joey FUN_00578390: comando 0x72 (carta revelada) con el id de index y el lugar where.
func f578390(p: int, index: int, where: int) -> int:
	return f5b9170(_jp_hi(p) | 0x72, f4022e0(index), where, 0)


## Joey FUN_005783c0: comando 0x72 con el id de index y el lugar (ident << 8) | loc en bytes.
func f5783c0(p: int, loc: int, index: int, ident: int) -> int:
	return f5b9170(_jp_hi(p) | 0x72, f4022e0(index), ((ident & 0xff) << 8) | (loc & 0xff), 0)


## Joey FUN_00578400: comando 0x73 con el id de index.
func f578400(p: int, index: int) -> int:
	return f5b9170(_jp_hi(p) | 0x73, f4022e0(index), 1, 0)


## Joey FUN_00578430: comando 0x75 con el id de index.
func f578430(p: int, index: int) -> int:
	return f5b9170(_jp_hi(p) | 0x75, f4022e0(index), 1, 0)


## Joey FUN_00578460: comando 0x43 (dano a p) de amount, acotado a 0xffff, sin aviso.
func f578460(p: int, amount: int) -> int:
	if amount & 0xffffffff == 0:
		return 0
	if _s32(amount) > 0xffff:
		amount = 0xffff
	return f5b9170(_jp_hi(p) | 0x43, amount, 0, 0)


## Joey FUN_005784a0: como 578460 con el ultimo argumento a 1.
func f5784a0(p: int, amount: int) -> int:
	if amount & 0xffffffff == 0:
		return 0
	if _s32(amount) > 0xffff:
		amount = 0xffff
	return f5b9170(_jp_hi(p) | 0x43, amount, 0, 1)


## Joey FUN_005784e0: pago de vida: comando 0x43 de amount (acotado a 0xffff) y aviso 0x10
## con (p << 16) | amount.
func f5784e0(p: int, amount: int) -> int:
	if amount & 0xffffffff == 0:
		return 0
	if _s32(amount) > 0xffff:
		amount = 0xffff
	f5b9170(_jp_hi(p) | 0x43, amount, 0, 1)
	return f598590(m.u8(JoeyMem.TURN) & 1, 0x10, ((p & 0xffff) << 0x10) | (amount & 0xffff))


## Joey FUN_00578540: dano de combate amount a p entre la carta src y la dst ({u16 lugar, u16
## indice}): comando 0x43, avisos de 0x20a/0x71/0xdb/0x530/0x5e7 y de 0x415 del rival, pago
## de 0x2da y aviso 0xe con el descriptor.
func f578540(p: int, amount: int, src: int, dst: int) -> int:
	if amount & 0xffffffff == 0:
		return 0
	if _s32(amount) > 0xffff:
		amount = 0xffff
	var low := amount & 0xffff
	var w := m.u16(dst)
	var v := 0
	if w & 0x40:
		var s := m.u16(src)
		v = ((((s & 0xe) << 3) | (s & 1)) << 16) | low
		v = ((0x1000000 - ((w & 1) << 24)) ^ v) & 0xfffffff
		v |= 0x50000000
	elif w & 0x80:
		var c := w & 1
		v = (((((c | 0x50) << 5) | (w & 0xe)) << 3) | c) << 16 | low
	else:
		var s := m.u16(src)
		var x := ((((w & 0xe) << 3) | (w & 1)) << 5) | (s & 0xe)
		v = (((x << 3) | (s & 1)) << 16) | low
	v &= 0xffffffff
	f5b9170(_jp_hi(p) | 0x43, amount, 0, 1)
	if ((v >> 8) & 0xf0000) != (v & 0xf0000):
		var card_id := f4022e0(m.u16(src + 2)) & 0xffff
		if card_id in [0x20a, 0x71, 0xdb, 0x530, 0x5e7]:
			var a := ((((v & 0xffff3840) | 0x3840) << 0xf) | ((v >> 4) & 0xf0000) | m.u16(src + 2)) & 0xffffffff
			f5ba490(a, m.u8(src + 1), v)
		if ((v >> 0x10) & 0xf) != (p & 0xffffffff):
			var q := (-1 - p) & 1
			for z in range(5, 11):
				var at := JoeyMem.zone(q, z)
				var index := m.u32(at) & 0xfff
				if f4022e0(index) & 0xffff != 0x415:
					continue
				var st := m.u32(at + 0x8c)
				if ((m.u8(at + 6) >> 1) & ~(st >> 5) & ~(st >> 1)) & 1 == 0:
					continue
				var e := m.u32(at)
				var hi := 0x80000000 if (p + 1) & 1 else 0
				f5ba490((((z & 0x1f) | 0x1c20) << 0x10) | hi | index, JoeyMem.ident(e), v)
	if s16(f4022e0(m.u16(dst + 2))) == 0x2da and m.u8(dst) & 0xc0 == 0:
		var q := (v >> 0x18) & 0xf
		var zz := v >> 0x1c
		if f56d560(q, zz) & 0xffff != 0xffff:
			f578390(q, m.u16(dst + 2), zz)
			f5784e0((1 - q) & 0xffffffff, v & 0xffff)
	return f598590(m.u8(JoeyMem.TURN) & 1, 0xe, v)


## Joey FUN_005787f0: ganancia de vida: comando 0x42 de amount (acotado a 0xffff), aviso 0x11
## y 59da10.
func f5787f0(p: int, amount: int) -> int:
	if amount & 0xffffffff == 0:
		return 0
	if _s32(amount) > 0xffff:
		amount = 0xffff
	f5b9170(_jp_hi(p) | 0x42, amount, 0, 1)
	f598590(m.u8(JoeyMem.TURN) & 1, 0x11, ((p & 0xffff) << 0x10) | (amount & 0xffff))
	return f59da10(p)


## Joey FUN_00578860: p roba n cartas (comando 0x61 por carta); con reveal o con 0x294 en la
## ranura del jugador las revela (0x75 y 0x1f) y lanza 579310 (monstruo de ATK >= 1500 con
## 0x294) o 5759a0 (magia con reveal); 0x2fa avisa por 5ba490; despues avisa 0x475 del rival.
func f578860(p: int, n: int, reveal: int) -> int:
	var count := m.u8(JoeyMem.pl(p) + JoeyMem.P_HAND_N)
	var info := (((1 - p) & 0xff) << 16) | (p & 0xff)
	var has294 := f5709d0(p, 0x294)
	var sent_spell := false
	if n & 0xffffffff == 0:
		return 0
	if has294 != 0:
		f578400((1 - p) & 0xffffffff, f402460(0x294))
	if _s32(n) > 0:
		var at := JoeyMem.pl(p) + JoeyMem.P_DECK
		var hi := _jp_hi(p)
		var left := _s32(n)
		while left != 0:
			f5b9170(hi | 0x61, 1, 1, 0)
			if f4022e0(m.u16(at) & 0xfff) & 0xffff == 0x2fa and f570be0(p, at) != 0:
				var e := m.u32(at)
				var r := f5ba490(((e & 0xfff) | ((p << 0x1f) & 0xffffffff) | 0x365f0000) & 0xffffffff, JoeyMem.ident(e), info)
				if r == 0:
					f574960(p, 0xb, (f570be0(p, at) - 1) & 0xffffffff)
				count += 1
			elif reveal == 0 and has294 == 0:
				count += 1
			else:
				var index := m.u16(at) & 0xfff
				f578430(p, index)
				f5b9170(hi | 0x1f, f4022e0(index), count, 0)
				if has294 != 0 and f402690(index) != 0 and f4027b0(index) & 0xffff >= 0x5dc:
					f579310(p, count, at, 1)
				elif reveal != 0 and f4025d0(index) & 0xffff == 0x16:
					f5759a0(p, count, at, 1)
					sent_spell = true
				else:
					count += 1
			at += 4
			left -= 1
	var q := (-1 - p) & 1
	for z in range(5, 10):
		var at := JoeyMem.zone(q, z)
		if f4022e0(m.u16(at) & 0xfff) & 0xffff != 0x475:
			continue
		var st := m.u32(at + 0x8c)
		if ((m.u8(at + 6) >> 1) & ~(st >> 5) & ~(st >> 1)) & 1 == 0:
			continue
		var e := m.u32(at)
		var hi := 0x80000000 if (p + 1) & 1 else 0
		f5ba490((((z & 0x1f) | 0x3620) << 0x10) | hi | (e & 0xfff), JoeyMem.ident(e), info)
	f579810()
	f59d560(p)
	if not sent_spell:
		f598590(m.u8(JoeyMem.TURN) & 1, 0x1b, info)
	return f579890()


## Joey FUN_00578b60: p roba n cartas sin revelarlas (578860).
func f578b60(p: int, n: int) -> int:
	return f578860(p, n, 0)


## Joey FUN_00578b80: comando 0x62 (descarte del mazo) de n cartas con el bloqueo de 0x453.
func f578b80(p: int, n: int) -> int:
	return f5b9170(_jp_hi(p) | 0x62, n, 1, 0)


## Joey FUN_00578bb0: p manda n cartas del mazo al cementerio (como mucho las que tiene):
## comando 0x62, avisos de 0x412/0x1de/0x4da (y 0xc6 con flag) por 5ba490, 59d6e0 por
## propietario y aviso 0x1d.
func f578bb0(p: int, n: int, flag: int) -> int:
	var own := 0
	var deck := m.u8(JoeyMem.pl(p) + JoeyMem.P_DECK_N)
	if _s32(n) >= deck:
		n = deck
	if f5699c0(0x453) != 0:
		return f578b80(p, n)
	f5b9170(_jp_hi(p) | 0x62, n, 0, flag)
	if _s32(n) > 0:
		var at := JoeyMem.pl(p) + JoeyMem.P_DECK
		var left := _s32(n)
		while left != 0:
			own = (own + ((((m.u32(at) >> 0xc) & 1) ^ p) & 0xffffffff)) & 0xffffffff
			var card_id := f4022e0(m.u16(at) & 0xfff) & 0xffff
			if card_id == 0x412 or card_id == 0x1de or card_id == 0x4da or (card_id == 0xc6 and flag != 0):
				var e := m.u32(at)
				f5ba490(((e & 0xfff) | ((p << 0x1f) & 0xffffffff) | 0x3a4e0000) & 0xffffffff, JoeyMem.ident(e), 0)
			at += 4
			left -= 1
	f59d6e0(p, (n - own) & 0xffffffff)
	f59d6e0((1 - p) & 0xffffffff, own)
	return f598590(m.u8(JoeyMem.TURN) & 1, 0x1d, 0)
