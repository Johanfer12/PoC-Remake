class_name JoeyPortO
extends JoeyPortN
## Motor nativo de Joey, lote O de la etapa 3: M3 576940-577840 (lote de destruccion 576960/576b30, registro de efectos 576f40, arrastre 577280).
## Cada funcion se llama f<direccion de Joey_Pc.exe> y sobrescribe su declaracion con la misma
## aridad. Cotejo: re/scripts/joey_specs/port_o.py.

## Mascara de zonas en destruccion (bit p * 16 + z), la que marca 576360 y consume 576b30.
const _JO_DESTROYING := 0xa577f0


## Joey FUN_00576940: destruye las zonas de la mascara por efecto de la carta (576960, al cementerio).
func f576940(info: int, mask: int) -> int:
	return f576960(info, mask, 0xe, 2)


## Joey FUN_00576960: destruccion en lote: marca las zonas de la mascara que se pueden destruir
## (576300/576360), aplica 576b30 a cada una empezando por el jugador del turno y devuelve los
## bits de a577f0 que cambiaron. info apunta a {u16 indice de la carta causante, u16 lado}.
func f576960(info: int, mask: int, kind: int, flags: int) -> int:
	var old := m.u32(_JO_DESTROYING)
	var face := (flags >> 1) & 1
	var hit := f576300(info, mask, face) & 0xffffffff
	for i in 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ i
		for z in 11:
			if hit & (1 << (((q << 4) + z) & 0x1f)):
				f576360(q, z, face, m.u16(info))
	if m.u32(_JO_DESTROYING) != 0:
		f598d70()
		if f5699c0(0x453) != 0:
			flags |= 0x10000
		f579810()
		m.set_u32(_JO_DESTROYING, hit | old)
		for i in 2:
			var q := (m.u8(JoeyMem.TURN) & 1) ^ i
			for z in 11:
				var bit := 1 << (((q << 4) + z) & 0x1f)
				if hit & bit == 0:
					continue
				var k := kind
				if f567ad0(m.u16(JoeyMem.zone(q, z)) & 0xfff) != 0 and (kind == 0xb or kind == 0xd):
					k = 0xc
				m.set_u32(_JO_DESTROYING, m.u32(_JO_DESTROYING) & ~bit)
				var w := m.u16(info + 2)
				var side := ((w >> 14) & 1) ^ (w & 1)
				f576b30(q, z, k, (int(side != q) + flags) & 0xffffffff, m.u16(info))
		f579890()
	return (m.u32(_JO_DESTROYING) ^ old) & 0xffffffff


## Joey FUN_00576b30: destruye la carta de (p, z) hacia la ubicacion kind (<= 0xa sin efecto,
## 0xb mano, 0xc fusion, 0xd mazo, 0xe cementerio, 0xf excluida): emite el comando de traslado,
## registra el efecto de destruccion (576f40, 598590) y arrastra las cartas ligadas (577280).
## Devuelve 1 si la destruyo.
func f576b30(p: int, z: int, kind: int, flags: int, card: int) -> int:
	var side := p & 1
	var at := JoeyMem.zone(p, z)
	var index := m.u16(at) & 0xfff
	if f4025d0(card) & 0xffff == 0x16 and f56c460(p, z) != 0:
		return 0
	if kind != 0xe and kind != 0xf and m.u8(at + 0x8c) & 4 != 0:
		return 0
	if index == 0:
		return 0
	var bit := 1 << (((p << 4) + z) & 0x1f)
	if m.u32(_JO_DESTROYING) & bit:
		return 0
	var lost := 0
	if kind == 0xe and not is_token(index):
		lost = 1
	var face := (flags >> 1) & 1
	var e := m.u32(at)
	var desc := (((e >> 0xc) & 1) + ((e >> 0x18) & 0x7f) * 2) & 0xff
	if kind == 0xe and flags & 0x10000:
		kind = 0xf
		lost = 0
	var fl := m.u16(at + 6)
	var c := (int(flags & 8 != 0) << 4) | (kind & 0xf)
	c = (c << 1) | (((flags & 1) ^ p) & 1)
	c = (c << 2) | (fl & 2)
	c = (c << 1) | face
	c = (c << 1) | (fl & 1)
	c = (c << 4) | (z & 0xf)
	c = (c << 1) | side
	desc = (desc | (c << 8)) & 0xffffffff
	m.set_u32(_JO_DESTROYING, m.u32(_JO_DESTROYING) | bit)
	var op_hi := 0x8000 if p != 0 else 0
	if flags & 0x1000:
		f5b9170(op_hi | 0x95, z, int(lost == 0), 0)
	elif face:
		f5b9170(op_hi | 0x79, z, 1 if lost else 0x10, flags)
	elif _s32(kind) <= 0xa:
		f5b9170(op_hi | 0x8d, z, 1, 0)
		var pb := p & 0xff
		var turned := int(flags & 0x20000 != 0) ^ pb
		f5b9170(op_hi | 0x83, ((z & 0xff) << 8) | pb, ((kind & 0xff) << 8) | (turned & 0xff), 0)
	elif is_token(index):
		f5b9170(op_hi | 0x79, z, 1, 0)
	else:
		var own := int(flags & 0x20000 != 0) ^ ((m.u32(at) >> 0xc) & 1)
		var extra := 0
		# Mitad alta de EDX (kind - 0xb) que el original arrastra a los argumentos.
		var hi := (kind - 0xb) & 0xffff0000
		match kind - 0xb:
			0:
				extra = m.u8(JoeyMem.pl(own) + JoeyMem.P_HAND_N)
				hi = 0
			1, 3, 4:
				extra = 1
		var b := ((((extra << 7) | (kind & 0x7f) | hi) << 1) | own) & 0xffffffff
		var a := ((hi << 1) | ((z & 0x7f) << 1) | (b & 0xffff0000) | (p & 1)) & 0xffffffff
		f5b9170(0x8f, a, b, flags)
	if lost:
		f59d6e0((m.u32(at) >> 0xc) & 1, 1)
	if _s32(kind) > 0xa:
		f576f40(desc, at)
		if not is_token(index):
			f598590(m.u8(JoeyMem.TURN) & 1, 0x1c, desc)
	f577280(at, p, z, flags)
	return 1


## Joey FUN_00576f40: registra el efecto que dispara la destruccion de la carta del objeto de
## zona `at` segun su id (desc: descriptor de 576b30). Su retorno no lo usa ningun llamador.
func f576f40(desc: int, at: int) -> int:
	var own_bit := (desc >> 8) & 1
	var index := m.u32(at) & 0xfff
	var bit14 := (desc >> 0xe) & 1
	var not22 := ((~desc) >> 0x16) & 1
	var grave := int((desc & 0x3c0000) == 0x380000)
	var level := (desc >> 9) & 0xf
	var crossed := (((desc >> 9) ^ desc) >> 8) & 1
	if f4022e0(index) & 0xffff >= 0x780:
		var id0 := f4022e0(index)
		if id0 & 0xffff <= 0x783:
			return id0
	var id := f4022e0(index) & 0xffff
	var ret := id
	var tail := false
	if id > 0x456:
		if id > 0x4d9:
			if id > 0x57d:
				if id != 0x5ea:
					return id
				var e := m.u32(at)
				var owner := (e >> 0xc) & 1
				if own_bit != owner or level >= 5 or bit14 == 0 or grave == 0 or crossed == 0:
					return owner
				var r := f56b440(index, owner + ((e >> 0x18) & 0x7f) * 2)
				if r != 0:
					return r
				e = m.u32(at)
				f5783c0((e >> 0xc) & 1, 0xe, index, ((e >> 0xc) & 1) + ((e >> 0x18) & 0x7f) * 2)
				e = m.u32(at)
				var serial := ((((e >> 0x18) & 0x7f) << 1) + ((e >> 0xc) & 1)) & 0xff
				# ECX lleva el mismo byte; 579790 solo usa su mitad alta, que 5b9170 descarta.
				return f579790(own_bit, index, (serial << 8) | 3)
			if id == 0x57d:
				return id
			if id == 0x4da:
				if grave == 0:
					return 0
				tail = true
			elif id != 0x4e9:
				return (id - 0x4e9) & 0xffffffff
			else:
				ret = 0
		elif id == 0x4d9:
			if bit14 == 0:
				return 0
			var e := m.u32(at)
			return f5ba490(index | (own_bit << 31) | 0x385f0000, ((e >> 0xc) & 1) + ((e >> 0x18) & 0x7f) * 2, desc)
		else:
			ret = (id - 0x45a) & 0xffffffff
			if ret != 2:
				return ret
			return _jo_576f40_1cd(at, desc, index, ret, not22, grave)
	else:
		if id == 0x456:
			return id
		if id > 0x1cd:
			if id > 0x412:
				return (id - 0x414) & 0xffffffff
			if id == 0x412 or id == 0x1de:
				if grave == 0:
					return 0
				tail = true
			elif id != 0x23d:
				return (id - 0x23d) & 0xffffffff
			else:
				ret = 0
		elif id == 0x1cd:
			return _jo_576f40_1cd(at, desc, index, id, not22, grave)
		elif id <= 0x136:
			if id != 0x136 and id != 0x2f and id != 0x12f:
				return id
		elif id < 0x138:
			return id
		elif id > 0x139 and id != 0x140:
			return id
	if not tail:
		if not22 == 0:
			return ret
		if grave == 0:
			return 0
	return _jo_576f40_insert(at, desc, index)


## Rama 57709e de 576f40 (ids 0x1cd y 0x45c): sin la carta boca abajo (+7 bit 1) inserta.
func _jo_576f40_1cd(at: int, desc: int, index: int, ret: int, not22: int, grave: int) -> int:
	if not22 == 0:
		return ret
	if grave == 0:
		return 0
	if m.u8(at + 7) & 2:
		return grave
	return _jo_576f40_insert(at, desc, index)


## Bloque 577211 de 576f40: inserta el efecto 0x384e en la cadena (5ba490).
func _jo_576f40_insert(at: int, desc: int, index: int) -> int:
	var e := m.u32(at)
	var key := (((e & 0xfffff709) << 0x13) | index | 0x384e0000) & 0xffffffff
	return f5ba490(key, ((e >> 0xc) & 1) + ((e >> 0x18) & 0x7f) * 2, desc)


## Joey FUN_00577280: arrastra con la carta destruida del objeto `at` (lado p, zona z) las que
## dependen de ella: copias 0x5f8/0x605-0x608, monstruos de 0x3ba, el equipo de 0x447/0x488,
## los 0x58f del campo 0x14d y las cartas de sus vinculos de tipo 1/4/5 y 2/6/7/8.
func f577280(at: int, p: int, z: int, flags: int) -> int:
	var index := m.u32(at) & 0xfff
	var face := (flags >> 1) & 1
	var keep := flags & 0x10000
	var id := f4022e0(index) & 0xffff
	var linked := false
	if id > 0x488:
		if (id == 0x5f8 or (id > 0x604 and id <= 0x608)) and _s32(z) >= 5 and f5699a0(p, 0x5f8) != 0:
			for zz in range(5, 10):
				if zz == z:
					continue
				var o := JoeyMem.zone(p, zz)
				if m.u32(o) & 0xfff == 0 or m.u8(o + 6) & 2 == 0:
					continue
				var id2 := f4022e0(m.u16(o) & 0xfff) & 0xffff
				if id2 == 0x5f8 or (id2 > 0x604 and id2 <= 0x608):
					f576b30(p, zz, 0xe, (keep + 2) & 0xffffffff, f402460(0x5f8) & 0xffff)
	elif id == 0x488:
		linked = face != 0
	elif id == 0x3ba:
		if face:
			for q in 2:
				for zz in 5:
					var o := JoeyMem.zone(q, zz)
					if m.u8(o + 6) & 2 == 0 or f5675f0(m.u16(o) & 0xfff) == 0:
						continue
					var e := m.u32(o)
					if f56b440(e & 0xfff, ((e >> 0xc) & 1) + ((e >> 0x18) & 0x7f) * 2) == 0:
						f576b30(q, zz, 0xe, (int(q != p) + 2 + keep) & 0xffffffff, index)
	elif id == 0x447:
		linked = true
	if linked:
		var o := JoeyMem.zone(p, z)
		if m.u32(o) & 0xfff == index:
			var st := m.u32(o + 0x8c)
			if ((m.u8(o + 6) >> 1) & ~(st >> 5) & ~(st >> 1) & 1) != 0:
				var r := f56b250(p, z)
				if r & 0xffff != 0xffff:
					var q := r & 0xff
					var zz := (r >> 8) & 0xff
					var t := JoeyMem.zone(q, zz)
					if m.u32(t) & 0xfff != 0 and m.u8(t + 6) & 2 != 0:
						f576b30(q, zz, 0xe, (int(q != p) + 2 + keep) & 0xffffffff, index)
	if z == 10 and m.u8(JoeyMem.zone(p, 10) + 6) & 2 != 0:
		var o := JoeyMem.zone(~p & 1, 10)
		var go := m.u32(o) & 0xfff == 0 or m.u8(o + 6) & 2 == 0
		if not go:
			go = m.u32(_JO_DESTROYING) & (1 << ((0x1a - (p << 4)) & 0x1f)) != 0
		if go:
			f5b9170((0x8000 if p != 0 else 0) | 0x11, 0, 0, 0)
			if f4022e0(index) & 0xffff == 0x14d:
				for q in 2:
					for zz in range(5, 11):
						var t := JoeyMem.zone(q, zz)
						if f4022e0(m.u16(t) & 0xfff) & 0xffff != 0x58f:
							continue
						if m.u8(t + 6) & 2 == 0 or m.u8(t + 0x8c) & 0x20 != 0:
							continue
						f576b30(q, zz, 0xe, (int(q != p) + keep + 2) & 0xffffffff, f402460(0x58f) & 0xffff)
	var i := 0
	while i < m.u16(at + JoeyMem.Z_LINKS_N):
		var kind := m.u8(at + JoeyMem.Z_LINK_KIND + i * 2) & 0xf
		var ref := m.u16(at + JoeyMem.Z_LINK_REF + i * 2)
		var q := ref & 0xff
		var zz := (ref >> 8) & 0xff
		var t := JoeyMem.zone(q, zz)
		match kind:
			1, 4, 5:
				if m.u32(t) & 0xfff != 0:
					f576b30(q, zz, 0xe, (keep + 2) & 0xffffffff, 0)
			2, 6, 7, 8:
				var lid := f4022e0(m.u16(t) & 0xfff) & 0xffff
				var hit := false
				if lid == 0x4dc or lid == 0x589:
					hit = m.u8(t + 0x8c) & 0x20 == 0
				elif lid == 0x15c or lid == 0x447:
					hit = m.u8(t + 0x8c) & 0x20 == 0 and face != 0
				if hit:
					f576b30(q, zz, 0xe, (keep + 2) & 0xffffffff, 0)
		i += 1
	return 0


## Joey FUN_005777f0: destruye las zonas de la mascara por efecto de la carta `card` del lado p
## (estructura local {card, p & 1} para 576960, al cementerio). Devuelve lo que 576960.
func f5777f0(p: int, card: int, mask: int) -> int:
	var info := m.local(0x14)
	m.set_u16(info, card)
	m.set_u16(info + 2, p & 1)
	return f576960(info, mask, 0xe, 2)


## Joey FUN_00577840: destruye la carta de (p, z) por efecto de la carta `card` del lado
## p ^ who (5777f0); 1 si su zona cambio de estado.
func f577840(p: int, z: int, who: int, card: int) -> int:
	var bit := 1 << (((p << 4) + z) & 0x1f)
	var r := f5777f0(p ^ who, card, bit)
	return int(r & bit != 0)
