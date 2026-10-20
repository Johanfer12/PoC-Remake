class_name JoeyPortD
extends JoeyPortC
## Motor nativo de Joey, lote D de la etapa 1: 56cc50-56dcc0 (M2: consultas de vinculos y estado).
## Cada funcion se llama f<direccion de Joey_Pc.exe> y sobrescribe su declaracion de joey_decl.gd
## con la misma aridad. Cotejo: re/scripts/joey_specs/port_d.py.

# Listas del jugador (direcciones del jugador 0; el 1 suma 0xd44).
const _JD_HAND_N := 0xa55d68      ## u8 mano (el u16 lleva el mazo en el byte alto)
const _JD_GRAVE_N := 0xa55d6a     ## u8 cementerio
const _JD_BANISH_N := 0xa55d6c    ## u8 excluidas
const _JD_HAND := 0xa56434
const _JD_GRAVE := 0xa566f0
const _JD_BANISH := 0xa5686c
const _JD_BANISH_AUX := 0xa569e8  ## u16 por carta excluida, paralelo a la lista
const _JD_FLAGS := 0xa56430       ## u32 de banderas del jugador (bit 3: mano sin barajar)
# Objeto de zona (direcciones de la zona 0 del jugador 0).
const _JD_Z_ENTRY := 0xa55d74
const _JD_Z_FLAGS := 0xa55d7a
const _JD_Z_LINKS_N := 0xa55d7e
const _JD_Z_LINK_REF := 0xa55d80
const _JD_Z_LINK_KIND := 0xa55dc0
const _JD_Z_STATUS := 0xa55e00


## Desplazamiento del objeto de zona: p acotado, z sin acotar (como el original).
static func _jd_zoff(p: int, z: int) -> int:
	return (p & 1) * JoeyMem.PLAYER_SIZE + _s32(z) * JoeyMem.ZONE_SIZE


## Desplazamiento del objeto de zona al que apunta una referencia de vinculo (byte bajo: jugador,
## byte alto: zona).
static func _jd_ref_off(ref: int) -> int:
	return (ref & 1) * JoeyMem.PLAYER_SIZE + ((ref >> 8) & 0xff) * JoeyMem.ZONE_SIZE


## Resta 1 al byte bajo del contador u16 sin tocar el alto: ((b - 1) ^ b) & 0xff ^ u16.
func _jd_dec_count(addr: int) -> int:
	var v := m.u16(addr)
	v = ((((v - 1) ^ v) & 0xff) ^ v) & 0xffff
	m.set_u16(addr, v)
	return v & 0xff


## Comparacion de entradas de 56cd20/56d010/56d100: indice antes de la version 1001, u32 despues.
func _jd_same_entry(a: int, b: int) -> bool:
	if _s32(f44baa0()) < 0x3e9:
		return ((m.u32(a) ^ m.u32(b)) & 0xfff) == 0
	return m.u32(a) == m.u32(b)


## Joey FUN_0056cc50: saca la carta i de las excluidas de p y corre las siguientes (con su u16
## paralelo); 0 si i no es menor que el contador.
func f56cc50(p: int, i: int) -> int:
	var q := p & 1
	var n_at := _JD_BANISH_N + q * JoeyMem.PLAYER_SIZE
	i = _s32(i)
	if i >= m.u8(n_at):
		return 0
	var n := _jd_dec_count(n_at)
	while i < n:
		var at := _JD_BANISH + q * JoeyMem.PLAYER_SIZE + i * 4
		f5675c0(at, at + 4)
		var aux := _JD_BANISH_AUX + q * JoeyMem.PLAYER_SIZE + i * 2
		m.set_u16(aux, m.u16(aux + 2))
		i += 1
		n = m.u8(n_at)
	return 1


## Joey FUN_0056cd20: busca la entrada en las excluidas de p y la saca con 56cc50.
func f56cd20(p: int, entry: int) -> int:
	var q := p & 1
	var n_at := _JD_BANISH_N + q * JoeyMem.PLAYER_SIZE
	var i := 0
	while i < m.u8(n_at):
		if _jd_same_entry(_JD_BANISH + q * JoeyMem.PLAYER_SIZE + i * 4, entry):
			return f56cc50(p, i)
		i += 1
	return 0


## Joey FUN_0056cdc0: monstruos (tipo < 0x15) en el cementerio de p.
func f56cdc0(p: int) -> int:
	var q := p & 1
	var n_at := _JD_GRAVE_N + q * JoeyMem.PLAYER_SIZE
	var count := 0
	var i := 0
	while i < m.u8(n_at):
		if (f4025d0(m.u16(_JD_GRAVE + q * JoeyMem.PLAYER_SIZE + i * 4) & 0xfff) & 0xffff) < 0x15:
			count += 1
		i += 1
	return count


## Joey FUN_0056ce40: monstruos en las excluidas de p; las marcadas con 0x80 en su u16 paralelo
## solo cuentan (sin mirar el tipo) si `marked` no es 0.
func f56ce40(p: int, marked: int) -> int:
	var q := p & 1
	var n_at := _JD_BANISH_N + q * JoeyMem.PLAYER_SIZE
	var count := 0
	var i := 0
	while i < m.u8(n_at):
		if m.u8(_JD_BANISH_AUX + q * JoeyMem.PLAYER_SIZE + i * 2) == 0x80:
			if marked != 0:
				count += 1
		elif (f4025d0(m.u16(_JD_BANISH + q * JoeyMem.PLAYER_SIZE + i * 4) & 0xfff) & 0xffff) < 0x15:
			count += 1
		i += 1
	return count


## Joey FUN_0056cef0: pone la entrada al final de la mano de p, salvo los ids 0x780-0x783; las
## cartas de marco 2 (fusiones) van al mazo de fusion de su propietario con 568d10.
func f56cef0(p: int, src: int) -> int:
	var q := p & 1
	var n_at := _JD_HAND_N + q * JoeyMem.PLAYER_SIZE
	# El destino se calcula con el contador leido antes de las llamadas.
	var dst := _JD_HAND + q * JoeyMem.PLAYER_SIZE + m.u8(n_at) * 4
	if (m.u32(src) & 0xfff) == 0:
		return 0
	if (f4022e0(m.u32(src) & 0xfff) & 0xffff) >= 0x780 and (f4022e0(m.u16(src) & 0xfff) & 0xffff) <= 0x783:
		return 0
	if (f402740(m.u16(src) & 0xfff) & 0xffff) == 2:
		f568d10((m.u32(src) >> 12) & 1, src)
		return 0
	f5675c0(dst, src)
	var v := m.u16(n_at)
	m.set_u16(n_at, (((v + 1) ^ v) & 0xff) ^ v)
	return 0


## Joey FUN_0056cfc0: borra el indice de la carta i de la mano de p (deja sus banderas).
func f56cfc0(p: int, i: int) -> int:
	var q := p & 1
	if _s32(i) < m.u8(_JD_HAND_N + q * JoeyMem.PLAYER_SIZE):
		var at := _JD_HAND + q * JoeyMem.PLAYER_SIZE + _s32(i) * 4
		m.set_u32(at, m.u32(at) & 0xfffff000)
	return 0


## Joey FUN_0056d010: busca la entrada en la mano de p, la saca y corre las siguientes; 1 si estaba.
func f56d010(p: int, entry: int) -> int:
	var q := p & 1
	var n_at := _JD_HAND_N + q * JoeyMem.PLAYER_SIZE
	var i := 0
	while i < m.u8(n_at):
		if _jd_same_entry(_JD_HAND + q * JoeyMem.PLAYER_SIZE + i * 4, entry):
			var n := _jd_dec_count(n_at)
			while i < n:
				var at := _JD_HAND + q * JoeyMem.PLAYER_SIZE + i * 4
				f5675c0(at, at + 4)
				i += 1
				n = m.u8(n_at)
			return 1
		i += 1
	return 0


## Joey FUN_0056d100: posicion de la entrada en la mano de p, o -1.
func f56d100(p: int, entry: int) -> int:
	var q := p & 1
	var n_at := _JD_HAND_N + q * JoeyMem.PLAYER_SIZE
	var i := 0
	while i < m.u8(n_at):
		if _jd_same_entry(_JD_HAND + q * JoeyMem.PLAYER_SIZE + i * 4, entry):
			return i
		i += 1
	return -1


## Joey FUN_0056d190: compacta la mano de p quitando las entradas sin indice de carta.
func f56d190(p: int) -> int:
	var q := p & 1
	var n_at := _JD_HAND_N + q * JoeyMem.PLAYER_SIZE
	var i := 0
	while i < m.u8(n_at):
		var at := _JD_HAND + q * JoeyMem.PLAYER_SIZE + i * 4
		if (m.u32(at) & 0xfff) == 0:
			var n := _jd_dec_count(n_at)
			var j := i
			while j < n:
				var cur := _JD_HAND + q * JoeyMem.PLAYER_SIZE + j * 4
				f5675c0(cur, cur + 4)
				j += 1
				n = m.u8(n_at)
		else:
			i += 1
	return 0


## Joey FUN_0056d240: posicion en la mano de p de la primera carta de tipo 0x16, o -1.
func f56d240(p: int) -> int:
	var q := p & 1
	var n_at := _JD_HAND_N + q * JoeyMem.PLAYER_SIZE
	var i := 0
	while i < m.u8(n_at):
		var index := m.u16(_JD_HAND + q * JoeyMem.PLAYER_SIZE + i * 4) & 0xfff
		if index != 0 and (f4025d0(index) & 0xffff) == 0x16:
			return i
		i += 1
	return -1


## Joey FUN_0056d2c0: cartas de la mano de p con ese id.
func f56d2c0(p: int, card_id: int) -> int:
	var q := p & 1
	var n_at := _JD_HAND_N + q * JoeyMem.PLAYER_SIZE
	var count := 0
	var i := 0
	while i < m.u8(n_at):
		if (f4022e0(m.u16(_JD_HAND + q * JoeyMem.PLAYER_SIZE + i * 4) & 0xfff) & 0xffff) == (card_id & 0xffff):
			count += 1
		i += 1
	return count


## Joey FUN_0056d340: posicion en la mano de p de la primera carta con ese id, o -1.
func f56d340(p: int, card_id: int) -> int:
	var q := p & 1
	var n_at := _JD_HAND_N + q * JoeyMem.PLAYER_SIZE
	var i := 0
	while i < m.u8(n_at):
		if (f4022e0(m.u16(_JD_HAND + q * JoeyMem.PLAYER_SIZE + i * 4) & 0xfff) & 0xffff) == (card_id & 0xffff):
			return i
		i += 1
	return -1


## Joey FUN_0056d3c0: bit 3 de las banderas del jugador p.
func f56d3c0(p: int) -> int:
	return (m.u32(_JD_FLAGS + (p & 1) * JoeyMem.PLAYER_SIZE) >> 3) & 1


## Joey FUN_0056d3f0: 1 si hay en juego 0x445 del rival de p, 0x461 de cualquiera, o 0x480 cuando
## p es el jugador del turno.
func f56d3f0(p: int) -> int:
	if _s32(f5699a0((1 - p) & 0xffffffff, 0x445)) > 0:
		return 1
	if _s32(f5699c0(0x461)) > 0:
		return 1
	if p == (m.u8(JoeyMem.TURN) & 1) and _s32(f5699c0(0x480)) > 0:
		return 1
	return 0


## Joey FUN_0056d460: baraja la mano de p (Fisher-Yates con 5bddb0) si el bit 3 lo permite y hay
## al menos dos cartas; 1 si la baraja.
func f56d460(p: int) -> int:
	if f56d3c0(p) != 0:
		return 0
	var q := p & 1
	var n := m.u8(_JD_HAND_N + q * JoeyMem.PLAYER_SIZE)
	if n < 2:
		return 0
	var hand := _JD_HAND + q * JoeyMem.PLAYER_SIZE
	var tmp := m.local(4)
	var k := n - 1
	var bound := n
	while k > 0:
		var at := hand + (bound - 1) * 4
		var other := hand + _s32(f5bddb0(bound)) * 4
		f5675c0(tmp, other)
		f5675c0(other, at)
		f5675c0(at, tmp)
		bound -= 1
		k -= 1
	return 1


## Joey FUN_0056d520: si 0x49a esta en juego y 56aa70(p, z) es positivo, el recuento de 0x49a.
func f56d520(p: int, z: int) -> int:
	var n := f5699c0(0x49a)
	if _s32(n) > 0 and _s32(f56aa70(p, z)) > 0:
		return n
	return 0


## Joey FUN_0056d560: referencia del primer vinculo de tipo 5 de la zona, o 0xffff. La mitad alta
## de EAX es la del desplazamiento de la zona.
func f56d560(p: int, z: int) -> int:
	var off := _jd_zoff(p, z)
	var high := (off & 0xffffffff) & 0xffff0000
	var n := m.u16(_JD_Z_LINKS_N + off)
	for i in n:
		if (m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf) == 5:
			return high | m.u16(_JD_Z_LINK_REF + off + i * 2)
	return high | 0xffff


## Joey FUN_0056d5c0: vinculos de tipo 1, 4 o 5 de la zona cuya zona de destino tiene carta.
func f56d5c0(p: int, z: int) -> int:
	var off := _jd_zoff(p, z)
	var count := 0
	var n := m.u16(_JD_Z_LINKS_N + off)
	for i in n:
		var kind := m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf
		if kind == 1 or (kind > 3 and kind < 6):
			var ref := m.u16(_JD_Z_LINK_REF + off + i * 2)
			if (m.u32(_JD_Z_ENTRY + _jd_ref_off(ref)) & 0xfff) != 0:
				count += 1
	return count


## Joey FUN_0056d660: vinculos de tipo 1, 2, 6, 7 u 8 de la zona cuyo destino tiene ese id.
func f56d660(p: int, z: int, card_id: int) -> int:
	var off := _jd_zoff(p, z)
	var count := 0
	var i := 0
	while i < m.u16(_JD_Z_LINKS_N + off):
		var kind := m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf
		if kind in [1, 2, 6, 7, 8]:
			var ref := m.u16(_JD_Z_LINK_REF + off + i * 2)
			if (f4022e0(m.u16(_JD_Z_ENTRY + _jd_ref_off(ref)) & 0xfff) & 0xffff) == (card_id & 0xffff):
				count += 1
		i += 1
	return count


## Joey FUN_0056d740: 56d790, salvo que el id sea de tipo 0x16 y 56c460(p, z) no sea 0.
func f56d740(p: int, z: int, card_id: int) -> int:
	if (f4025d0(f402460(card_id)) & 0xffff) == 0x16 and f56c460(p, z) != 0:
		return 0
	return f56d790(p, z, card_id)


## Joey FUN_0056d790: vinculos de tipo 1, 2, 6, 7 u 8 de la zona cuyo destino tiene ese id, no
## tiene el bit 5 del estado y 56b440 (indice, identidad) da 0.
func f56d790(p: int, z: int, card_id: int) -> int:
	var off := _jd_zoff(p, z)
	var count := 0
	var i := 0
	while i < m.u16(_JD_Z_LINKS_N + off):
		var kind := m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf
		if kind in [1, 2, 6, 7, 8]:
			var target := _jd_ref_off(m.u16(_JD_Z_LINK_REF + off + i * 2))
			var index := m.u16(_JD_Z_ENTRY + target) & 0xfff
			if (f4022e0(index) & 0xffff) == (card_id & 0xffff) and (m.u8(_JD_Z_STATUS + target) & 0x20) == 0:
				var entry := m.u32(_JD_Z_ENTRY + target)
				if f56b440(index, ((entry >> 12) & 1) + ((entry >> 24) & 0x7f) * 2) == 0:
					count += 1
		i += 1
	return count


## Joey FUN_0056d8d0: como 56d740 pero sin 56b440 y solo con destinos del jugador `owner`
## (comparado con el byte bajo de la referencia).
func f56d8d0(p: int, z: int, card_id: int, owner: int) -> int:
	if (f4025d0(f402460(card_id)) & 0xffff) == 0x16 and f56c460(p, z) != 0:
		return 0
	var off := _jd_zoff(p, z)
	var count := 0
	var i := 0
	while i < m.u16(_JD_Z_LINKS_N + off):
		var kind := m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf
		if kind in [1, 2, 6, 7, 8]:
			var ref := m.u16(_JD_Z_LINK_REF + off + i * 2)
			var target := _jd_ref_off(ref)
			if owner == (ref & 0xff) and (m.u8(_JD_Z_STATUS + target) & 0x20) == 0:
				if (f4022e0(m.u16(_JD_Z_ENTRY + target) & 0xfff) & 0xffff) == (card_id & 0xffff):
					count += 1
		i += 1
	return count


## Joey FUN_0056da10: posicion del primer vinculo de tipo 3 u 11-13 de la zona cuya referencia
## (un indice de carta) tiene ese id, o -1.
func f56da10(p: int, z: int, card_id: int) -> int:
	var off := _jd_zoff(p, z)
	var i := 0
	while i < m.u16(_JD_Z_LINKS_N + off):
		var kind := m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf
		if kind == 3 or (kind > 10 and kind < 14):
			if (f4022e0(m.u16(_JD_Z_LINK_REF + off + i * 2)) & 0xffff) == (card_id & 0xffff):
				return i
		i += 1
	return -1


## Joey FUN_0056daa0: vinculos de tipo 3 u 11-13 de la zona cuya referencia tiene ese id.
func f56daa0(p: int, z: int, card_id: int) -> int:
	var off := _jd_zoff(p, z)
	var count := 0
	var i := 0
	while i < m.u16(_JD_Z_LINKS_N + off):
		var kind := m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf
		if kind == 3 or (kind > 10 and kind < 14):
			if (f4022e0(m.u16(_JD_Z_LINK_REF + off + i * 2)) & 0xffff) == (card_id & 0xffff):
				count += 1
		i += 1
	return count


## Joey FUN_0056db30: 1 si 56da10 encuentra el vinculo.
func f56db30(p: int, z: int, card_id: int) -> int:
	return int(_s32(f56da10(p, z, card_id)) >= 0)


## Joey FUN_0056db60: posicion del primer vinculo de tipo 3 u 11-13 cuyos bits 13-15 de la
## referencia valen `bits`, o -1.
func f56db60(p: int, z: int, bits: int) -> int:
	var off := _jd_zoff(p, z)
	var n := m.u16(_JD_Z_LINKS_N + off)
	for i in n:
		var kind := m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf
		if kind == 3 or (kind > 10 and kind < 14):
			if (m.u16(_JD_Z_LINK_REF + off + i * 2) & 0xe000) == (bits & 0xffff):
				return i
	return -1


## Joey FUN_0056dbe0: 1 si 56db60 encuentra el vinculo.
func f56dbe0(p: int, z: int, bits: int) -> int:
	return int(_s32(f56db60(p, z, bits)) >= 0)


## Joey FUN_0056dc10: posicion del vinculo (de tipo distinto de 3, en 1-8) de la zona ocupada que
## apunta al jugador `owner` y la zona `target`, o -1.
func f56dc10(p: int, z: int, owner: int, target: int) -> int:
	var off := _jd_zoff(p, z)
	if (m.u32(_JD_Z_ENTRY + off) & 0xfff) == 0:
		return -1
	var n := m.u16(_JD_Z_LINKS_N + off)
	for i in n:
		var kind := m.u8(_JD_Z_LINK_KIND + off + i * 2) & 0xf
		if kind in [1, 2, 4, 5, 6, 7, 8]:
			var ref := m.u16(_JD_Z_LINK_REF + off + i * 2)
			if (ref & 0xff) == owner and ((ref >> 8) & 0xff) == target:
				return i
	return -1


## Joey FUN_0056dcc0: monstruos boca arriba (bandera 2) de p cuya zona da 56d740 distinto de 0.
func f56dcc0(p: int, card_id: int) -> int:
	var q := p & 1
	var count := 0
	for z in 5:
		var at := JoeyMem.zone(q, z)
		if (m.u32(at) & 0xfff) != 0 and (m.u8(_JD_Z_FLAGS + q * JoeyMem.PLAYER_SIZE + z * JoeyMem.ZONE_SIZE) & 2) != 0:
			if f56d740(p, z, card_id) != 0:
				count += 1
	return count
