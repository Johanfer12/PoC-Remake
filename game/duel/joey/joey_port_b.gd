class_name JoeyPortB
extends JoeyPortA
## Motor nativo de Joey, lote B de la etapa 1: 5699a0-56b220 (fin de M1 y principio de M2: recuentos, vinculos).
## Cada funcion se llama f<direccion de Joey_Pc.exe> y sobrescribe su declaracion de joey_decl.gd
## con la misma aridad. Cotejo: re/scripts/joey_specs/port_b.py.
##
## 56a6fd no se porta: son los tres NOP de relleno entre 56a680 y 56a700 (Ghidra lo tomo por
## funcion); nada la llama ni salta a ella.


## Objeto de zona z del jugador p & 1, con z sin enmascarar y la aritmetica de 32 bits del original.
static func _jb_za(p: int, z: int) -> int:
	return (0xa55d74 + (p & 1) * 0xd44 + z * 0x90) & 0xffffffff


## Condicion activa de un objeto de zona: bit 1 de las banderas y bits 1 y 5 del estado a cero.
func _jb_active(za: int) -> bool:
	var st := m.u32(za + JoeyMem.Z_STATUS)
	return ((m.u8(za + JoeyMem.Z_FLAGS) >> 1) & ~(st >> 5) & ~(st >> 1) & 1) != 0


## Joey FUN_005699a0: 569820 sin zona excluida.
func f5699a0(p: int, card_id: int) -> int:
	return f569820(p, card_id, 0xffffffff)


## Joey FUN_005699c0: 569820 sumado para los dos jugadores (primero el 1).
func f5699c0(card_id: int) -> int:
	var a := f569820(1, card_id, 0xffffffff)
	var b := f569820(0, card_id, 0xffffffff)
	return (b + a) & 0xffffffff


## Joey FUN_005699f0: cuantas cartas boca arriba con ese id tiene p en el campo, salvo la zona
## `skip`: zonas 0-4 si es monstruo; si no, 5-10 sin el bit 1 del estado.
func f5699f0(p: int, card_id: int, skip: int) -> int:
	var count := 0
	var kind := f4025d0(f402460(card_id)) & 0xffff
	if kind < 0x15:
		for z in 5:
			var za := _jb_za(p, z)
			var e := m.u32(za) & 0xfff
			if e != 0 and z != skip:
				if (f4022e0(e) & 0xffff) == (card_id & 0xffff) and (m.u8(za + 6) & 2) != 0:
					count += 1
		return count
	for z in range(5, 11):
		var za := _jb_za(p, z)
		var e := m.u32(za) & 0xfff
		if e != 0 and z != skip:
			if (f4022e0(e) & 0xffff) == (card_id & 0xffff) and (m.u8(za + 6) & 2) != 0 \
					and (m.u8(za + JoeyMem.Z_STATUS) & 2) == 0:
				count += 1
	return count


## Joey FUN_00569ae0: 5699f0 sin zona excluida.
func f569ae0(p: int, card_id: int) -> int:
	return f5699f0(p, card_id, 0xffffffff)


## Joey FUN_00569b00: 5699f0 sumado para los dos jugadores (primero el 1).
func f569b00(card_id: int) -> int:
	var a := f5699f0(1, card_id, 0xffffffff)
	var b := f5699f0(0, card_id, 0xffffffff)
	return (b + a) & 0xffffffff


## Joey FUN_00569b30: magias/trampas activas de p (zonas 5-10) con ese id, sin 56b440 y con el
## contador de las banderas (bits 2-5) por debajo de `limit` (comparacion con signo).
func f569b30(p: int, card_id: int, limit: int) -> int:
	var count := 0
	for z in range(5, 11):
		var za := _jb_za(p, z)
		var entry := m.u32(za)
		var e := entry & 0xfff
		if e == 0:
			continue
		if (f4022e0(e) & 0xffff) != (card_id & 0xffff) or not _jb_active(za):
			continue
		if f56b440(e, ((entry >> 12) & 1) + ((entry >> 24) & 0x7f) * 2) & 0xffffffff != 0:
			continue
		if (m.u8(za + 6) >> 2) & 0xf < _s32(limit):
			count += 1
	return count


## Joey FUN_00569bf0: monstruos boca arriba de p cuyo valor de 56f6d0 es `value`.
func f569bf0(p: int, value: int) -> int:
	var count := 0
	for z in 5:
		if (m.u8(_jb_za(p, z) + 6) & 2) != 0:
			if (f56f6d0(p, z) & 0xffff) == (value & 0xffff):
				count += 1
	return count


## Joey FUN_00569c50: cartas con ese id en las zonas 0-10 de p (sin mirar si estan vacias).
func f569c50(p: int, card_id: int) -> int:
	var count := 0
	for z in 11:
		if (f4022e0(m.u16(_jb_za(p, z)) & 0xfff) & 0xffff) == (card_id & 0xffff):
			count += 1
	return count


## Joey FUN_00569cb0: 1 si 569720 encuentra la carta 0x3ba en p.
func f569cb0(p: int) -> int:
	return int(_s32(f569720(p, 0x3ba)) >= 0)


## Joey FUN_00569cd0: monstruos boca arriba de p con ese id y el bit 0 de las banderas igual a `bit`.
func f569cd0(p: int, card_id: int, bit: int) -> int:
	var count := 0
	for z in 5:
		var za := _jb_za(p, z)
		if (m.u32(za) & 0xfff) == 0:
			continue
		var flags := m.u16(za + 6)
		if (flags & 2) == 0 or (flags & 1) != (bit & 0xffff):
			continue
		if (f4022e0(m.u16(za) & 0xfff) & 0xffff) == (card_id & 0xffff):
			count += 1
	return count


## Joey FUN_00569d50: zonas de monstruo ocupadas de p (short).
func f569d50(p: int) -> int:
	var count := 0
	for z in 5:
		if (m.u32(_jb_za(p, z)) & 0xfff) != 0:
			count += 1
	return count & 0xffff


## Joey FUN_00569d90: monstruos de p, si `face_up` solo boca arriba (bit 1) y si `no_bit0` solo
## sin el bit 0 de las banderas (short).
func f569d90(p: int, face_up: int, no_bit0: int) -> int:
	var count := 0
	for z in 5:
		var za := _jb_za(p, z)
		if (m.u32(za) & 0xfff) == 0:
			continue
		var flags := m.u8(za + 6)
		var a := face_up == 0 or (flags & 2) != 0
		var b := no_bit0 == 0 or (flags & 1) == 0
		if a and b:
			count += 1
	return count & 0xffff


## Joey FUN_00569e10: 1 si la zona z de p esta libre de bloqueos: ni un vinculo tipo 2 del objeto
## de jugador de p (zona 11) hacia una carta 0x528 activa que apunte a z, ni una marca 0x40 de
## la lista de +0xc88 (contador en +0xc) de cualquier jugador para (p, z).
func f569e10(p: int, z: int) -> int:
	var player := JoeyMem.pl(p)
	var i := 0
	while i < m.u16(player + 0x64e):
		var kind_at := player + 0x690 + i * 2
		if (m.u8(kind_at) & 0xf) == 2:
			var ref := m.u16(kind_at - 0x40)
			# La zona del vinculo es el byte alto sin limite.
			var target := (0xa55d74 + (ref & 1) * 0xd44 + ((ref >> 8) & 0xff) * 0x90) & 0xffffffff
			if (f4022e0(m.u16(target) & 0xfff) & 0xffff) == 0x528 and z == m.u8(kind_at + 1) \
					and _jb_active(target):
				return 0
		i += 1
	for s in 2:
		var other := JoeyMem.pl(s)
		var n := m.u8(other + 0xc)
		for k in n:
			var at := other + 0xc88 + k * 2
			var b1 := m.u8(at + 1)
			if m.u8(at) == 0x40 and p == (b1 & 1) and z == (b1 >> 4):
				return 0
	return 1


## Joey FUN_00569f70: 1 si la zona z de p esta vacia y 569e10 la deja usar.
func f569f70(p: int, z: int) -> int:
	if (m.u32(_jb_za(p, z)) & 0xfff) != 0:
		return 0
	return int(f569e10(p, z) != 0)


## Joey FUN_00569fc0: mascara de las zonas de monstruo bloqueadas (bit p * 5 + z) para la pantalla.
func f569fc0() -> int:
	var mask := 0
	var bit := 0
	for p in 2:
		for z in 5:
			mask |= int(f569e10(p, z) == 0) << bit
			bit += 1
	# 4497b0: mascara de zonas libres en pantalla (presentacion pura).
	f4497b0(mask)
	return 0


## Joey FUN_0056a000: zonas de monstruo de p que 569f70 da por utilizables.
func f56a000(p: int) -> int:
	var count := 0
	for z in 5:
		if f569f70(p, z) != 0:
			count += 1
	return count


## Joey FUN_0056a030: primera zona de monstruo utilizable de p; con el bit 0 de a577ec evita
## antes las zonas de origen (a57840 bits 0 y 8-10, carta en a57864) y destino (bits 1 y 11-13,
## carta en a578f4) del combate. -1 si no hay.
func f56a030(p: int) -> int:
	if (m.u8(0xa577ec) & 1) != 0:
		for z in 5:
			if f569f70(p, z) == 0:
				continue
			var b := m.u32(0xa57840) & 0xffff
			if p == (b & 1) and z == ((b >> 8) & 7) and (m.u32(0xa57864) & 0xfff) != 0:
				continue
			if p != ((b >> 1) & 1) or z != ((b >> 11) & 7) or (m.u32(0xa578f4) & 0xfff) == 0:
				return z
	for z in 5:
		if f569f70(p, z) != 0:
			return z
	return 0xffffffff


## Joey FUN_0056a0d0: 56a140 salvo para los ids 0x781-0x782.
func f56a0d0(who: int, p: int, z: int) -> int:
	var card_id := f4022e0(m.u16(_jb_za(p, z)) & 0xfff) & 0xffff
	if card_id >= 0x781 and card_id <= 0x782:
		return 0
	return f56a140(who, p, z)


## Joey FUN_0056a140: 1 si `who` controla el monstruo de la zona z de p: ocupada, z < 5, sin
## 0x58a en el campo y, si no es suyo, con un vinculo 0x4c4 (56da10) cuyo byte alto es `who`.
func f56a140(who: int, p: int, z: int) -> int:
	var za := _jb_za(p, z)
	if (m.u16(za) & 0xfff) == 0:
		return 0
	if _s32(z) >= 5:
		return 0
	if _s32(f5699c0(0x58a)) > 0:
		return 0
	if who != p:
		var i := f56da10(p, z, 0x4c4)
		if _s32(i) < 0:
			return 0
		if m.u8((za + JoeyMem.Z_LINK_KIND + 1 + i * 2) & 0xffffffff) != who:
			return 0
	return 1


## Joey FUN_0056a200: suma de 56a0d0 sobre los monstruos de ambos jugadores salvo la zona `skip`
## (z << 8 | p); 0 si hay 0x58a en el campo.
func f56a200(who: int, skip: int) -> int:
	if _s32(f5699c0(0x58a)) > 0:
		return 0
	var total := 0
	for p in 2:
		for z in 5:
			if (m.u32(_jb_za(p, z)) & 0xfff) != 0 and ((z << 8) | p) != skip:
				total = (total + f56a0d0(who, p, z)) & 0xffffffff
	return total


## Joey FUN_0056a290: como 56a200 con 56a140 (sin la excepcion de 0x781-0x782).
func f56a290(who: int, skip: int) -> int:
	if _s32(f5699c0(0x58a)) > 0:
		return 0
	var total := 0
	for p in 2:
		for z in 5:
			if (m.u32(_jb_za(p, z)) & 0xfff) != 0 and ((z << 8) | p) != skip:
				total = (total + f56a140(who, p, z)) & 0xffffffff
	return total


## Joey FUN_0056a320: magias/trampas de p en las zonas 5-9 (y la 10 si `with_field`). Con
## `face_up` y sin `face_down` cuenta las boca arriba; con `face_down` y sin `face_up`, las boca
## abajo; con ambos o ninguno, todas (short).
func f56a320(p: int, face_up: int, face_down: int, with_field: int) -> int:
	var count := 0
	var end := int(with_field != 0) + 10
	var z := 5
	while (z & 0xffff) < end:
		var za := _jb_za(p, z & 0xffff)
		if (m.u32(za) & 0xfff) != 0:
			var up := (m.u8(za + 6) & 2) != 0
			var counted: bool
			if face_up == 0:
				counted = true if face_down == 0 else not up
			elif face_down != 0:
				counted = true
			else:
				counted = up
			if counted:
				count += 1
		z += 1
	return count & 0xffff


## Joey FUN_0056a3c0: 1 si la zona z de p esta vacia.
func f56a3c0(p: int, z: int) -> int:
	return int((m.u32(_jb_za(p, z)) & 0xfff) == 0)


## Joey FUN_0056a400: primera zona de magia/trampa (5-9) vacia de p; -1 si no hay.
func f56a400(p: int) -> int:
	for z in range(5, 10):
		if f56a3c0(p, z) != 0:
			return z
	return 0xffffffff


## Joey FUN_0056a430: 1 si p puede colocar la magia/trampa del indice: subtipo 2 o una zona 5-9 libre.
func f56a430(p: int, index: int) -> int:
	if (f402700(index) & 0xffff) == 2:
		return 1
	for z in range(5, 10):
		if (m.u32(_jb_za(p, z)) & 0xfff) == 0:
			return 1
	return 0


## Joey FUN_0056a490: quita de todas las zonas (0-11 de ambos jugadores) los vinculos de tipo
## 1-2 y 4-8 que apuntan a la zona (p, z) (referencia z << 8 | p, en bytes).
func f56a490(p: int, z: int) -> int:
	var key := ((z & 0xff) << 8) | (p & 0xff)
	for s in 2:
		for zone in 12:
			var za := _jb_za(s, zone)
			var i := 0
			while i < m.u16(za + JoeyMem.Z_LINKS_N):
				var kind := m.u8(za + JoeyMem.Z_LINK_KIND + i * 2) & 0xf
				var ref := m.u16(za + JoeyMem.Z_LINK_REF + i * 2)
				if kind >= 1 and kind <= 8 and kind != 3 and ref == key:
					f5695e0(s, zone, i)
					i -= 1
				i += 1
	return 0


## Joey FUN_0056a570: retira la carta de la zona con 56c590, sus vinculos entrantes y vacia el objeto.
func f56a570(p: int, z: int) -> int:
	f56c590(_jb_za(p, z))
	f56a490(p, z)
	f56a5c0(p, z)
	return 0


## Joey FUN_0056a5c0: vacia el objeto de la zona z de p (0x90 bytes).
func f56a5c0(p: int, z: int) -> int:
	f5bddf0(_jb_za(p, z), 0x90)
	return 0


## Joey FUN_0056a600: como 56a570 retirando la carta con 56c640(objeto, 0).
func f56a600(p: int, z: int) -> int:
	f56c640(_jb_za(p, z), 0)
	f56a490(p, z)
	f56a5c0(p, z)
	return 0


## Joey FUN_0056a650: 56a600 si `mode`, si no 56a570.
func f56a650(p: int, z: int, mode: int) -> int:
	if mode != 0:
		return f56a600(p, z)
	return f56a570(p, z)


## Joey FUN_0056a680: manda la carta de la zona a su propietario (568d10 si 567ad0, si no
## 56cef0), quita sus vinculos entrantes y vacia el objeto.
func f56a680(p: int, z: int) -> int:
	var za := _jb_za(p, z)
	if f567ad0(m.u16(za) & 0xfff) != 0:
		f568d10((m.u32(za) >> 12) & 1, za)
	else:
		f56cef0((m.u32(za) >> 12) & 1, za)
	f56a490(p, z)
	f56a5c0(p, z)
	return 0


## Joey FUN_0056a700: como 56a680 con 568c00 en lugar de 56cef0.
func f56a700(p: int, z: int) -> int:
	var za := _jb_za(p, z)
	if f567ad0(m.u16(za) & 0xfff) != 0:
		f568d10((m.u32(za) >> 12) & 1, za)
	else:
		f568c00((m.u32(za) >> 12) & 1, za)
	f56a490(p, z)
	f56a5c0(p, z)
	return 0


## Joey FUN_0056a780: 1 si p tiene un monstruo boca arriba con 5675f0 y sin 56b440.
func f56a780(p: int) -> int:
	for z in 5:
		var za := _jb_za(p, z)
		var e := m.u16(za) & 0xfff
		if e == 0 or (m.u8(za + 6) & 2) == 0:
			continue
		if f5675f0(e) == 0:
			continue
		var entry := m.u32(za)
		if f56b440(e, ((entry >> 12) & 1) + ((entry >> 24) & 0x7f) * 2) == 0:
			return 1
	return 0


## Joey FUN_0056a810: 1 si todos los monstruos boca arriba de p tienen 56f9e0 entre 3 y 5.
func f56a810(p: int) -> int:
	for z in 5:
		var za := _jb_za(p, z)
		if (m.u32(za) & 0xfff) != 0 and (m.u8(za + 6) & 2) != 0:
			var v := f56f9e0(p, z) & 0xffff
			if v < 3 or v > 5:
				return 0
	return 1


## Joey FUN_0056a880: magias (tipo 0x16) boca arriba de p en las zonas 5-9.
func f56a880(p: int) -> int:
	var count := 0
	for z in range(5, 10):
		var za := _jb_za(p, z)
		if (m.u32(za) & 0xfff) != 0 and (m.u8(za + 6) & 2) != 0:
			if (f4025d0(m.u16(za) & 0xfff) & 0xffff) == 0x16:
				count += 1
	return count


## Joey FUN_0056a8e0: cartas del cementerio de p con ese tipo (4025d0).
func f56a8e0(p: int, kind: int) -> int:
	var player := JoeyMem.pl(p)
	var count := 0
	if m.u8(player + JoeyMem.P_GRAVE_N) == 0:
		return 0
	var i := 0
	while i < m.u8(player + JoeyMem.P_GRAVE_N):
		if (f4025d0(m.u16(player + JoeyMem.P_GRAVE + i * 4) & 0xfff) & 0xffff) == (kind & 0xffff):
			count += 1
		i += 1
	return count


## Joey FUN_0056a960: cartas boca abajo de p (zonas 0-10) con el bit 10 de las banderas y sin el
## bit 5 del estado; con `card_id` distinto de 0, solo las de ese id. El primer argumento no se usa.
func f56a960(_unused: int, p: int, card_id: int) -> int:
	var count := 0
	for z in 11:
		var za := _jb_za(p, z)
		var e := m.u16(za) & 0xfff
		if e == 0:
			continue
		var flags := m.u16(za + 6)
		if (flags & 2) != 0 or (m.u8(za + JoeyMem.Z_STATUS) & 0x20) != 0 or (flags & 0x400) == 0:
			continue
		if (card_id & 0xffff) != 0 and (f4022e0(e) & 0xffff) != (card_id & 0xffff):
			continue
		count += 1
	return count


## Joey FUN_0056a9e0: primera zona 5-10 de p con esa carta boca abajo, el bit 10 de las banderas
## y sin el bit 5 del estado; -1 si no hay.
func f56a9e0(p: int, card_id: int) -> int:
	for z in range(5, 11):
		var za := _jb_za(p, z)
		var index := f402460(card_id) & 0xffff
		if (m.u32(za) & 0xfff) != index:
			continue
		var flags := m.u16(za + 6)
		if (flags & 2) == 0 and (m.u8(za + JoeyMem.Z_STATUS) & 0x20) == 0 and (flags & 0x400) != 0:
			return z
	return 0xffffffff


## Joey FUN_0056aa50: 56a960 con el puntero fijo a55d64.
func f56aa50(p: int, card_id: int) -> int:
	return f56a960(0xa55d64, p, card_id)


## Joey FUN_0056aa70: monstruos boca arriba (zonas 0-4 de ambos jugadores, salvo la propia) para
## los que 5674e0(su indice, el de la zona) da distinto de 0. 0 si la zona no esta boca arriba.
func f56aa70(p: int, z: int) -> int:
	var za := _jb_za(p, z)
	var own := m.u16(za) & 0xfff
	if (m.u8(za + 6) & 2) == 0:
		return 0
	if own == 0:
		return 0
	var count := 0
	for k in 2:
		for j in 5:
			var side: int
			if k != 0:
				side = p
				if z == j:
					continue
			else:
				side = (1 - p) & 0xffffffff
				# p nunca es igual a 1 - p: el rival se recorre entero.
				if p == side and z == j:
					continue
			var other := _jb_za(side, j)
			var e := m.u16(other) & 0xfff
			if e != 0 and (m.u8(other + 6) & 2) != 0 and f5674e0(e, own) != 0:
				count += 1
	return count


## Joey FUN_0056ab60: anade el vinculo (ref, tipo) a la zona `at` (byte 0 jugador, byte 1 zona)
## sin comprobar el maximo.
func f56ab60(at: int, ref: int, kind: int) -> int:
	var q := at & 1
	var z := (at >> 8) & 0xff
	var count_at := 0xa55d7e + z * 0x90 + q * 0xd44
	var slot := m.u16(count_at) + z * 0x48 + q * 0x6a2
	m.set_u16(0xa55d80 + slot * 2, ref)
	m.set_u16(0xa55dc0 + slot * 2, kind)
	m.set_u16(count_at, m.u16(count_at) + 1)
	return 0


## Joey FUN_0056abe0: quita de la zona `at` el primer vinculo (o todos si `all`) de tipo 1-2 o
## 4-8 con esa referencia. 5695e0 recibe el byte 0 de `at` sin enmascarar.
func f56abe0(at: int, ref: int, all: int) -> int:
	var p8 := at & 0xff
	var z := (at >> 8) & 0xff
	var za := _jb_za(p8, z)
	var i := 0
	while i < m.u16(za + JoeyMem.Z_LINKS_N):
		var kind := m.u8(za + JoeyMem.Z_LINK_KIND + i * 2) & 0xf
		if kind >= 1 and kind <= 8 and kind != 3 \
				and m.u16(za + JoeyMem.Z_LINK_REF + i * 2) == (ref & 0xffff):
			f5695e0(p8, z, i)
			if all == 0:
				return 0
		else:
			i += 1
	return 0


## Joey FUN_0056aca0: quita de la zona `at` el primer vinculo (o todos si `all`) de tipo 3 u
## 0xb-0xd cuya referencia (sus bits 13-15 si los tiene) es `ref`.
func f56aca0(at: int, ref: int, all: int) -> int:
	var p8 := at & 0xff
	var z := (at >> 8) & 0xff
	var za := _jb_za(p8, z)
	var i := 0
	while i < m.u16(za + JoeyMem.Z_LINKS_N):
		var kind := m.u8(za + JoeyMem.Z_LINK_KIND + i * 2) & 0xf
		var value := m.u16(za + JoeyMem.Z_LINK_REF + i * 2)
		if kind == 3 or (kind > 10 and kind <= 13):
			if (value & 0xe000) != 0:
				value &= 0xe000
			if value == (ref & 0xffff):
				f5695e0(p8, z, i)
				if all == 0:
					return 0
				continue
		i += 1
	return 0


## Joey FUN_0056ad50: quita de las cartas 0x48a activas (zonas 5-10 de ambos jugadores) los
## vinculos tipo 0xb de 0x48a cuyo byte alto es la identidad de la carta apuntada (propietario +
## identidad * 2).
func f56ad50(entry_at: int) -> int:
	var entry := m.u32(entry_at)
	var key := ((entry >> 12) & 1) + ((entry >> 24) & 0x7f) * 2
	for s in 2:
		for z in range(5, 11):
			var za := _jb_za(s, z)
			if (f4022e0(m.u16(za) & 0xfff) & 0xffff) != 0x48a or not _jb_active(za):
				continue
			var i := m.u16(za + JoeyMem.Z_LINKS_N) - 1
			while i >= 0:
				var at := za + JoeyMem.Z_LINK_KIND + i * 2
				if (m.u8(at) & 0xf) == 0xb and m.u16(at - 0x40) == (f402460(0x48a) & 0xffff) \
						and m.u8(at + 1) == key:
					f5695e0(s, z, i)
				i -= 1
	return 0


## Joey FUN_0056aea0: fin de turno de los vinculos (zonas ocupadas y objeto de jugador): quita
## los de tipo 0 y, en los de tipo 3 y 0xc, descuenta los turnos del nibble alto (quitandolos a 0).
func f56aea0() -> int:
	for s in 2:
		for z in 12:
			var za := _jb_za(s, z)
			if (m.u16(za) & 0xfff) == 0 and z != 11:
				continue
			var i := m.u16(za + JoeyMem.Z_LINKS_N) - 1
			while i >= 0:
				var at := za + JoeyMem.Z_LINK_KIND + i * 2
				var w := m.u16(at)
				var kind := w & 0xf
				if kind == 0:
					f5695e0(s, z, i)
				elif kind == 3 or kind == 0xc:
					var turns := (w & 0xff) >> 4
					if turns == 0:
						f5695e0(s, z, i)
					else:
						m.set_u16(at, ((turns + 0xfff) << 4) | (w & 0xff0f))
				i -= 1
	return 0


## Joey FUN_0056af90: al cambiar la carta de la zona: quita sus vinculos de tipo 6, 8, 0xb y 0xc,
## los de tipo 8 de los monstruos que apuntan a ella, limpia las banderas (& 0xfe03) y pone el
## bit 9 a las cartas de la lista fija de ids.
func f56af90(p: int, z: int) -> int:
	var za := _jb_za(p, z)
	if (m.u32(za) & 0xfff) == 0:
		return 0
	var i := m.u16(za + JoeyMem.Z_LINKS_N) - 1
	while i >= 0:
		match m.u8(za + JoeyMem.Z_LINK_KIND + i * 2) & 0xf:
			6, 8, 0xb, 0xc:
				f5695e0(p, z, i)
		i -= 1
	var key := ((z & 0xff) << 8) | (p & 0xff)
	for s in 2:
		for j in 5:
			var other := _jb_za(s, j)
			var k := m.u16(other + JoeyMem.Z_LINKS_N) - 1
			while k >= 0:
				if (m.u8(other + JoeyMem.Z_LINK_KIND + k * 2) & 0xf) == 8 \
						and m.u16(other + JoeyMem.Z_LINK_REF + k * 2) == key:
					f5695e0(s, j, k)
				k -= 1
	m.set_u16(za + 6, m.u16(za + 6) & 0xfe03)
	var card_id := f4022e0(m.u16(za) & 0xfff) & 0xffff
	match card_id:
		0xf, 0x62, 0x172, 0x173, 0x174, 0x1ac, 0x1cd, 0x243, 0x2da, 0x2e6, 0x458, 0x45c, 0x4e6, \
				0x536, 0x540, 0x5e9:
			m.set_u8(za + 7, m.u8(za + 7) | 2)
	return 0


## Joey FUN_0056b1c0: reescribe el vinculo i de la zona `at` (byte 0 jugador, byte 1 zona).
func f56b1c0(at: int, i: int, ref: int, kind: int) -> int:
	var slot := (i + ((at >> 8) & 0xff) * 0x48 + (at & 1) * 0x6a2) & 0xffffffff
	m.set_u16((0xa55d80 + slot * 2) & 0xffffffff, ref)
	m.set_u16((0xa55dc0 + slot * 2) & 0xffffffff, kind)
	return 0


## Joey FUN_0056b220: 1 si el nibble bajo de a577f4 es el valor de 569660.
func f56b220(p: int) -> int:
	var v := f569660(p) & 0xffff
	return int((m.u8(0xa577f4) & 0xf) == v)
