class_name JoeyPortM
extends JoeyPortL
## Motor nativo de Joey, lote M de la etapa 3: M3 5703a0-574f70 (ubicaciones, emisores de movimiento, equipos y productores).
## Cada funcion se llama f<direccion de Joey_Pc.exe> y sobrescribe su declaracion con la misma
## aridad. Cotejo: re/scripts/joey_specs/port_m.py.
##
## Los indices de zona y las sumas zona + i no se enmascaran (como en el original): se calculan
## con aritmetica de 32 bits y comparaciones con signo donde el ASM usa jl/jg.

## Banderas +6 del objeto de zona 0 del jugador 0 y lista u16 0xa569e8 (excluidas, 570420).
const _JM_FLAGS := 0xa55d7a
const _JM_BANISH_TAG := 0xa569e8
## Palabra de reglas (a577ec), banderas por jugador (a56430) y mascara de zonas (a577f0).
const _JM_RULES := 0xa577ec
const _JM_PFLAGS := 0xa56430
const _JM_ZMASK := 0xa577f0

## Ids de equipo que 574480 vuelve a comprobar con 579ce0 (tablas 57475c y 574778 del ASM).
const _JM_EQUIPS := [0x12c, 0x12d, 0x12e, 0x130, 0x131, 0x132, 0x133, 0x134, 0x135, 0x137, 0x13a,
		0x13b, 0x13c, 0x13e, 0x141, 0x142, 0x143, 0x144, 0x145, 0x146, 0x147, 0x28b, 0x28d, 0x29b,
		0x3c2, 0x3f4, 0x3f5, 0x416, 0x417, 0x422, 0x49e, 0x58e, 0x604, 0x60e]


## Opcode con el bit 15 si x (32 bits) no es 0 (neg/sbb/and 0x8000/or).
static func _jm_op(x: int, base: int) -> int:
	return (0x8000 if (x & 0xffffffff) != 0 else 0) | base


## Objeto separado del campo (a57864) si coincide con a57840, si no el vacio (a578f4).
func _jm_detached(p: int, loc: int) -> int:
	var battle := m.u32(JoeyMem.BATTLE) & 0xffff
	if (p & 0xffffffff) == (battle & 1) and (loc & 0xffffffff) == ((battle >> 8) & 7):
		return JoeyMem.DETACHED
	return JoeyMem.DETACHED_EMPTY


## Joey FUN_005703a0: bit 0 de las banderas del objeto de (p, loc + i); 0 en las listas 11-15.
func f5703a0(p: int, loc: int, i: int) -> int:
	var sl := _s32(loc)
	if sl >= 0xb and sl <= 0xf:
		return 0
	var at := _s32(loc + i)
	if at > 10:
		return m.u8(_jm_detached(p, loc) + 6) & 1
	return m.u8((_JM_FLAGS + at * JoeyMem.ZONE_SIZE + (p & 1) * JoeyMem.PLAYER_SIZE) & 0xffffffff) & 1


## Joey FUN_00570420: 1 si la carta de (p, loc, i) esta boca arriba (bit 1 de las banderas); mano
## visible segun el modo o 56d3c0, mazo segun 570be0, cementerio siempre, excluidas por su marca.
func f570420(p: int, loc: int, i: int) -> int:
	match loc & 0xffffffff:
		0xb:
			if (p & 0xffffffff) != (m.u32(JoeyMem.MODE) & 1) and f56d3c0(p) == 0:
				return 0
			return 1
		0xc:
			return 0
		0xd:
			return f570be0(p, (JoeyMem.PLAYER + JoeyMem.P_DECK + i * 4 + (p & 1) * JoeyMem.PLAYER_SIZE) & 0xffffffff)
		0xe:
			return 1
		0xf:
			var at := (_JM_BANISH_TAG + i * 2 + (p & 1) * JoeyMem.PLAYER_SIZE) & 0xffffffff
			var tag := m.u8(at)
			if tag == 0x40:
				return (m.u8(at + 1) >> 1) & 1
			if tag == 0x80:
				return 0
			return 1
	var z := _s32(loc + i)
	if z > 10:
		return (m.u8(_jm_detached(p, loc) + 6) >> 1) & 1
	return (m.u8((_JM_FLAGS + z * JoeyMem.ZONE_SIZE + (p & 1) * JoeyMem.PLAYER_SIZE) & 0xffffffff) >> 1) & 1


## Joey FUN_00570670: pone (value != 0) o quita el bit `bit` de la palabra de reglas a577ec.
func f570670(bit: int, value: int) -> int:
	var mask := 1 << (bit & 0x1f)
	if value != 0:
		m.set_u32(_JM_RULES, m.u32(_JM_RULES) | mask)
	else:
		m.set_u32(_JM_RULES, m.u32(_JM_RULES) & ~mask)
	return 0


## Joey FUN_005706b0: pone (value != 0) o quita el bit `bit` de las banderas a56430 del jugador.
func f5706b0(p: int, bit: int, value: int) -> int:
	var at := _JM_PFLAGS + (p & 1) * JoeyMem.PLAYER_SIZE
	var mask := 1 << (bit & 0x1f)
	if value != 0:
		m.set_u32(at, m.u32(at) | mask)
	else:
		m.set_u32(at, m.u32(at) & ~mask)
	return 0


## Joey FUN_00570790: retira la carta de (p, loc, i): saca de la lista (mano 56cfc0+56d190, fusion
## 569200, mazo 5690d0, cementerio 56c870+56ad50, excluidas 56cd20) o vacia el objeto de zona
## (56a490, memset y bit de a577f0) o el objeto separado.
func f570790(p: int, loc: int, i: int) -> int:
	var entry := f5700f0(p, loc, i)
	match loc & 0xffffffff:
		0xb:
			f56cfc0(p, i)
			f56d190(p)
			return 0
		0xc:
			f569200(p, entry)
			return 0
		0xd:
			f5690d0(p, entry)
			return 0
		0xe:
			f56c870(p, entry)
			f56ad50(entry)
			return 0
		0xf:
			f56cd20(p, entry)
			return 0
	var z := _s32(loc + i)
	if z < 0xb:
		f56a490(p, z)
		f5bddf0((JoeyMem.zone(p, 0) + z * JoeyMem.ZONE_SIZE) & 0xffffffff, 0x90)
		var bit := ((p << 4) + loc + i) & 0x1f
		m.set_u32(_JM_ZMASK, m.u32(_JM_ZMASK) & ~(1 << bit))
		return 0
	f5bddf0(_jm_detached(p, loc), 0x90)
	return 0


## Joey FUN_005708d0: coloca la entrada `src` en (p, loc): mano 56cef0, fusion 568d10, mazo
## arriba/abajo 568c00/568ca0, cementerio 56c590, excluidas 56c640, monstruo 568610 (cara y
## posicion en arg >> 8 y arg & 0xff) o magia 5686e0; en listas propias salvo el cementerio
## aplica 56ad50.
func f5708d0(p: int, loc: int, arg: int, src: int) -> int:
	match loc & 0xffffffff:
		0xb:
			f56cef0(p, src)
		0xc:
			f568d10(p, src)
		0xd:
			if arg != 0:
				f568ca0(p, src)
			else:
				f568c00(p, src)
		0xe:
			f56c590(src)
		0xf:
			f56c640(src, arg)
		_:
			if _s32(loc) < 5:
				f568610(p, loc, src, (arg >> 8) & 0xff, arg & 0xff)
			else:
				f5686e0(p, loc, src, arg & 0xff)
	var sl := _s32(loc)
	if ((m.u32(src) >> 12) & 1) == (p & 0xffffffff) and sl != 0xe and sl > 10:
		f56ad50(src)
	return 0


## Joey FUN_00570a10: 1 si `index` no esta bloqueado (56b440) y los LP de p superan 500 por cada
## 0x436 en juego.
func f570a10(p: int, index: int) -> int:
	if f56b440(index, 0xffffffff) != 0:
		return 0
	var limit := _s32(f5699c0(0x436) * 500)
	return int(m.u16(JoeyMem.PLAYER + JoeyMem.P_LP + (p & 1) * JoeyMem.PLAYER_SIZE) > limit)


## Joey FUN_00570a70: 1 si p puede robar/buscar: sin bit 20 de a56430, sin 0x592 propio ni 0x5f6.
func f570a70(p: int) -> int:
	if (m.u32(_JM_PFLAGS + (p & 1) * JoeyMem.PLAYER_SIZE) & 0x100000) != 0:
		return 0
	if f5699a0(p, 0x592) != 0:
		return 0
	return int(f5699c0(0x5f6) == 0)


## Joey FUN_00570ac0: 570a70 si hay 0x47f en juego; si no, 1.
func f570ac0(p: int) -> int:
	if f5699c0(0x47f) != 0:
		return f570a70(p)
	return 1


## Joey FUN_00570af0: 1 sin bit 21 de a56430 del jugador, sin 0x5e6 ni 0x5f6 en juego.
func f570af0(p: int) -> int:
	if (m.u32(_JM_PFLAGS + (p & 1) * JoeyMem.PLAYER_SIZE) & 0x200000) != 0:
		return 0
	if f5699c0(0x5e6) != 0:
		return 0
	return int(f5699c0(0x5f6) == 0)


## Joey FUN_00570b40: 0 si p tiene 0x592; si no, 570af0.
func f570b40(p: int) -> int:
	if f5699a0(p, 0x592) != 0:
		return 0
	return f570af0(p)


## Joey FUN_00570b70: 1 si el indice no cumple 567a00, o si es toon (5675f0) y p tiene 569cb0.
func f570b70(p: int, index: int) -> int:
	if f567a00(index) == 0:
		return 1
	if f5675f0(index) != 0 and f569cb0(p) != 0:
		return 1
	return 0


## Joey FUN_00570bb0: 1 si el rival (1 - p) no tiene 0x5e7 en juego (recuento <= 0).
func f570bb0(p: int) -> int:
	return int(_s32(f5699a0((1 - p) & 0xffffffff, 0x5e7)) <= 0)


## Joey FUN_00570be0: posicion + 1 del vinculo de tipo 0xd de la ranura del jugador (zona 11)
## con la carta 0x2fa y el dato igual al dueno de la entrada en `entry_at`, o 0.
func f570be0(p: int, entry_at: int) -> int:
	var e := m.u32(entry_at)
	var owner := JoeyMem.ident(e)
	var slot := JoeyMem.zone(p, 11)
	var i := 0
	while i < m.u16(slot + JoeyMem.Z_LINKS_N):
		var kind_at := slot + JoeyMem.Z_LINK_KIND + i * 2
		if (m.u8(kind_at) & 0xf) == 0xd:
			var ref := f402460(0x2fa) & 0xffff
			if m.u16(kind_at - 0x40) == ref and m.u8(kind_at + 1) == owner:
				return i + 1
		i += 1
	return 0


## Joey FUN_00570c70: posicion + 1 del vinculo de tipo 3 de la ranura del jugador (zona 11) con la
## carta 0x443 y el dato igual a `data`, o 0.
func f570c70(p: int, data: int) -> int:
	var slot := JoeyMem.zone(p, 11)
	var i := 0
	while i < m.u16(slot + JoeyMem.Z_LINKS_N):
		var kind_at := slot + JoeyMem.Z_LINK_KIND + i * 2
		if (m.u8(kind_at) & 0xf) == 3:
			var ref := f402460(0x443) & 0xffff
			if m.u16(kind_at - 0x40) == ref and m.u8(kind_at + 1) == (data & 0xffff):
				return i + 1
		i += 1
	return 0


## Joey FUN_00573c30: cierra el comando en curso marcando la zona (jugador del bit 15, zona a):
## bit 14 de la entrada si b & 1, bit 3 o 16 del estado segun b & 4, quita el bit 1 (570710),
## borra su bit de a55d70 en la fase 3 del jugador del turno y termina el comando.
func f573c30() -> int:
	var p := (m.u32(JoeyMem.CMD) & 0xffff) >> 15
	var z := m.u16(JoeyMem.CMD + 2)
	var at := JoeyMem.zone(p, 0) + z * JoeyMem.ZONE_SIZE
	if (m.u8(JoeyMem.CMD + 4) & 1) != 0:
		m.set_u32(at, m.u32(at) | 0x4000)
	var status := m.u32(at + JoeyMem.Z_STATUS)
	if (m.u8(JoeyMem.CMD + 4) & 4) != 0:
		status |= 8
	else:
		status |= 0x10000
	m.set_u32(at + JoeyMem.Z_STATUS, status)
	f570710(p, z, 1, 0)
	var turn := m.u8(JoeyMem.TURN)
	if (turn & 0xe) == 6 and p == (turn & 1):
		var mask_at := JoeyMem.PLAYER + 0x10 + p * JoeyMem.PLAYER_SIZE
		m.set_u16(mask_at, m.u16(mask_at) & ~(1 << (z & 0x1f)))
	m.set_u32(JoeyMem.CMD_STATE, m.u32(JoeyMem.CMD_STATE) & 0xffffbfff)
	return 0


## Joey FUN_005743f0: si la carta de (p, z) tiene otro controlador (56c210), la manda a su lado
## (575750 con su zona libre 56a030) o, sin zona libre, la destruye (577840); 1 si actua.
func f5743f0(p: int, z: int) -> int:
	if (m.u32(JoeyMem.zone(p, z)) & 0xfff) == 0:
		return 0
	var q := f56c210(p, z)
	if (q & 0xffffffff) == (p & 0xffffffff):
		return 0
	var free := f56a030(q)
	if _s32(free) == -1:
		f577840(p, z, 1, 0)
		return 1
	f575750(p, ((z & 0xff) << 8) | (p & 0xff), ((free & 0xff) << 8) | (q & 0xff))
	return 1


## Joey FUN_00574480: revisa los vinculos de (p, z): boca abajo, 574d10; con 0x547 sin bloquear
## destruye los de tipo 1/4/5; los equipos de tipo 1 que ya no pueden ir sobre el monstruo
## (579ce0) se destruyen.
func f574480(p: int, z: int) -> int:
	var zo := JoeyMem.zone(p, z)
	if (m.u8(zo + 6) & 2) == 0:
		f574d10(p, z, 0)
		return 0
	var i := 0
	while i < m.u16(zo + JoeyMem.Z_LINKS_N):
		var ref := m.u16(zo + JoeyMem.Z_LINK_REF + i * 2)
		var lo := ref & 0xff
		var hi := ref >> 8
		var equip_check := true
		if (f4022e0(m.u16(zo) & 0xfff) & 0xffff) == 0x547:
			var e := m.u32(zo)
			if f56b440(e & 0xfff, JoeyMem.ident(e)) == 0:
				equip_check = false
				var kind := m.u8(zo + JoeyMem.Z_LINK_KIND + i * 2) & 0xf
				if kind == 1 or kind == 4 or kind == 5:
					f577840(lo, hi, int(lo != (p & 0xffffffff)), m.u32(zo) & 0xfff)
		if equip_check and (m.u8(zo + JoeyMem.Z_LINK_KIND + i * 2) & 0xf) == 1:
			var tz := JoeyMem.zone(lo, hi)
			var index := m.u16(tz) & 0xfff
			if _JM_EQUIPS.has(f4022e0(index) & 0xffff):
				var local := m.local(0x14)
				m.set_u16(local, index)
				m.set_u16(local + 2, ((hi & 0x1f) << 1) | (lo & 1))
				m.set_u16(local + 4, (JoeyMem.ident(m.u32(tz)) << 5) & 0x1fe0)
				if f579ce0(local, ((z & 0xff) << 8) | (p & 0xff)) == 0:
					f577840(lo, hi, 0, index)
		i += 1
	return 0


## Joey FUN_005747e0: emite 0x86 (bit 15 si p != 0) con a, b, c.
func f5747e0(p: int, a: int, b: int, c: int) -> int:
	f5b9170(_jm_op(p, 0x86), a, b, c)
	return 0


## Joey FUN_00574810: emite 0x86 salvo que la carta (indice de tipo 0x16 o modo 0x4000/0x8000)
## vaya a una zona protegida por 56c460; 1 si lo emite.
func f574810(p: int, card: int, ref: int, c: int) -> int:
	var mode := card & 0xe000
	var check := false
	if mode == 0:
		check = (f4025d0(card) & 0xffff) == 0x16
	else:
		check = mode == 0x4000 or mode == 0x8000
	if check and f56c460(ref & 0xff, (ref >> 8) & 0xff) != 0:
		return 0
	f5b9170(_jm_op(p, 0x86), card, ref, c)
	return 1


## Joey FUN_00574890: si (p, z) tiene un vinculo hacia ref (56dc10), emite 0x87 para quitarlo
## (tipo 1, bit 8 si `keep` es 0).
func f574890(p: int, z: int, ref: int, keep: int) -> int:
	if _s32(f56dc10(p, z, ref & 0xff, (ref >> 8) & 0xff)) >= 0:
		f5b9170(_jm_op(p, 0x87), ref, ((z & 0xff) << 8) | (p & 0xff), (int(keep == 0) << 8) | 1)
	return 0


## Joey FUN_00574900: si (p, z) tiene el vinculo 3/11-13 de la carta (56db30), emite 0x87 para
## quitarlo (tipo 3, bit 8 si `keep` es 0).
func f574900(p: int, z: int, card_id: int, keep: int) -> int:
	if f56db30(p, z, card_id) != 0:
		f5b9170(_jm_op(p, 0x87), f402460(card_id), ((z & 0xff) << 8) | (p & 0xff), (int(keep == 0) << 8) | 3)
	return 0


## Joey FUN_00574960: emite 0x4d con (b << 8) | a.
func f574960(p: int, a: int, b: int) -> int:
	f5b9170(_jm_op(p, 0x4d), ((b & 0xff) << 8) | (a & 0xff), 0, 0)
	return 0


## Joey FUN_00574990: 5749b0 con el ultimo argumento a 1.
func f574990(p: int, ref: int, b: int) -> int:
	f5749b0(p, ref, b, 1)
	return 0


## Joey FUN_005749b0: cambia la posicion de la carta ref = (z << 8) | p: con mode 1 emite 0x88
## para 0x4ea y 0x8a si tiene contadores (banderas & 0x3c); luego 0xb2 y el aviso 0x1a (598590).
func f5749b0(p: int, ref: int, b: int, mode: int) -> int:
	var lo := ref & 0xff
	var hi := (ref >> 8) & 0xff
	if (mode & 0xffffffff) == 1:
		var zo := JoeyMem.zone(lo, hi)
		if (f4022e0(m.u16(zo) & 0xfff) & 0xffff) == 0x4ea:
			# 1 - dx con dl = b y dh = 0; la mitad alta de EDX no llega a la cola (u16).
			f5b9170(_jm_op(lo, 0x88), hi, 1 - (b & 0xff), 0)
		if (m.u8(zo + 6) & 0x3c) != 0:
			f5b9170(_jm_op(lo, 0x8a), hi, 0, 0)
	f5b9170(_jm_op(p, 0xb2), ref, b, mode)
	f598590(m.u8(JoeyMem.TURN) & 1, 0x1a, ((b & 0xffff) << 16) | (ref & 0xffff))
	return 0


## Joey FUN_00574ac0: cambia la posicion de ref = (z << 8) | p: si esta unida (56fb40) quita el
## vinculo (574890) y usa 56fbc0 como modo; si no, modo 1 (5749b0).
func f574ac0(ref: int, b: int) -> int:
	var hi := (ref >> 8) & 0xff
	var lo := ref & 0xff
	var link := f56fb40(lo, hi)
	var mode := f56fbc0(lo, hi) & 0xffff
	if (link & 0xffff) == 0xffff:
		mode = 1
	else:
		f574890(link & 0xff, (link >> 8) & 0xff, ref & 0xffff, 1)
	f5749b0(lo, ref, b, mode)
	return 0


## Joey FUN_00574b50: quita de los monstruos de ambos jugadores los vinculos hacia (z << 8) | p.
func f574b50(p: int, z: int) -> int:
	var ref := ((z & 0xff) << 8) | (p & 0xff)
	for q in 2:
		for k in 5:
			f574890(q, k, ref, 1)
	return 0


## Joey FUN_00574b80: del ultimo al primero, el primer vinculo de tipo 1 de (p, z) hacia un
## monstruo boca arriba sin bit 5 del estado con 0x42c, 0x4ea o 0x5ea emite 0x4d (dato: jugador o
## contador de 0x4ea).
func f574b80(p: int, z: int) -> int:
	var zo := JoeyMem.zone(p, z)
	var i := m.u16(zo + JoeyMem.Z_LINKS_N) - 1
	while i >= 0:
		if (m.u8(zo + JoeyMem.Z_LINK_KIND + i * 2) & 0xf) == 1:
			var ref := m.u16(zo + JoeyMem.Z_LINK_REF + i * 2)
			var lo := ref & 0xff
			var tz := JoeyMem.zone(lo, (ref >> 8) & 0xff)
			if (m.u32(tz) & 0xfff) != 0 and (m.u8(tz + 6) & 2) != 0 and (m.u8(tz + JoeyMem.Z_STATUS) & 0x20) == 0:
				var card_id := f4022e0(m.u16(tz) & 0xfff) & 0xffff
				var data := -1
				if card_id == 0x42c or card_id == 0x5ea:
					data = lo
				elif card_id == 0x4ea:
					data = m.u16(tz + JoeyMem.Z_COUNTER)
				if data >= 0:
					f5b9170(_jm_op(p, 0x4d), ((i & 0xff) << 8) | (z & 0xff), m.u16(tz) & 0xfff, ((data & 0xff) << 8) | 0xd)
					return 0
		i -= 1
	return 0


## Joey FUN_00574d10: destruye lo que depende de (p, z): vinculos 1/4/5 con carta; 2/6/7/8 hacia
## 0x4dc/0x589 sin bit 5 del estado, o 0x15c/0x447 si `fields`; en monstruos, 574b50.
func f574d10(p: int, z: int, fields: int) -> int:
	var zo := JoeyMem.zone(p, z)
	var i := 0
	while i < m.u16(zo + JoeyMem.Z_LINKS_N):
		var kind := m.u8(zo + JoeyMem.Z_LINK_KIND + i * 2) & 0xf
		var ref := m.u16(zo + JoeyMem.Z_LINK_REF + i * 2)
		var lo := ref & 0xff
		var hi := ref >> 8
		var tz := JoeyMem.zone(lo, hi)
		match kind:
			1, 4, 5:
				if (m.u32(tz) & 0xfff) != 0:
					f577840(lo, hi, 0, 0)
			2, 6, 7, 8:
				var card_id := f4022e0(m.u16(tz) & 0xfff) & 0xffff
				var free := (m.u8(tz + JoeyMem.Z_STATUS) & 0x20) == 0
				if card_id == 0x4dc or card_id == 0x589:
					if free:
						f577840(lo, hi, 0, 0)
				elif card_id == 0x15c or card_id == 0x447:
					if free and fields != 0:
						f577840(lo, hi, 0, 0)
		i += 1
	if _s32(z) < 5:
		f574b50(p, z)
	return 0


## Joey FUN_00574eb0: destruye las cartas con vinculo de tipo 5 desde (p, z) (577840 con la carta).
func f574eb0(p: int, z: int) -> int:
	var zo := JoeyMem.zone(p, z)
	var i := 0
	while i < m.u16(zo + JoeyMem.Z_LINKS_N):
		if (m.u8(zo + JoeyMem.Z_LINK_KIND + i * 2) & 0xf) == 5:
			var ref := m.u16(zo + JoeyMem.Z_LINK_REF + i * 2)
			f577840(ref & 0xff, (ref >> 8) & 0xff, 1, m.u32(zo) & 0xfff)
		i += 1
	return 0


## Joey FUN_00574f40: 574f70 con el u16 apuntado por `at` como ultimo argumento.
func f574f40(at: int, p: int, z: int, flip: int) -> int:
	f574f70(p, z, flip, m.u16(at))
	return 0


## Joey FUN_00574f70: voltea la carta de (p, z) (0x80) salvo zona protegida para el tipo 0x16;
## en monstruos avisa (598590 0x8) si queda boca arriba o abre la cadena (5ba490) si `flip` y su
## efecto de volteo aplica (567620 + 57ee80).
func f574f70(p: int, z: int, flip: int, card: int) -> int:
	var zo := JoeyMem.zone(p, z)
	var index := m.u16(zo) & 0xfff
	var not_card := int(card == 0)
	if (f4025d0(card) & 0xffff) == 0x16 and f56c460(p, z) != 0:
		return 0
	if index == 0:
		return 0
	var tag := ((((z & 0x1f) | (p << 15) | 0x1620) & 0xffff) << 16) | index
	var flags := m.u16(zo + 6)
	var dl := ((((~flags & 2) | (flags & 1)) << 4) | (z & 0xf)) << 1 & 0xff
	dl |= p & 1
	var w := (dl << 8) | (p & 0x8000) | (JoeyMem.ident(m.u32(zo)) & 0xff)
	var effect := 0
	if _s32(z) < 5 and f567620(index, 0) != 0 and f57ee80(tag, w & 0xff, 0) != 0:
		effect = 1
	f5b9170(_jm_op(p, 0x80), z, ((~m.u8(zo + 6) & 0xff) >> 1) & 1, int(not_card != 0 and effect != 0))
	if _s32(z) >= 5:
		return 0
	if (m.u8(zo + 6) & 2) == 0:
		if flip != 0 and effect != 0:
			f5ba490(tag, w & 0xff, w & 0xffff)
		return 0
	f598590(m.u8(JoeyMem.TURN) & 1, 8, w & 0xffff)
	return 0
