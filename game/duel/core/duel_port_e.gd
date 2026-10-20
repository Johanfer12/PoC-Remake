class_name DuelPortE
extends DuelPortD
## Modulo del porte del motor de duelo (ver docs/duel/PORTING.md).
## Lote E: destruccion, fusiones, busqueda de cartas para efectos y permiso de ataque
## (0x54dcf0-0x571c30), mas las auxiliares puras que usan y no estaban en ningun lote.

## Lista de cartas candidatas que rellena FUN_0056ba50: entradas u32, origen u16 de cada
## una (1 mano, 2 mazo, 4 cementerio, 8 mazo de fusion, 0x10 excluidas) y contador u16.
const E_LIST := 0xa11624
const E_KIND := 0xa11824
const E_COUNT := 0xa11924


# --- Destruccion ----------------------------------------------------------------------------

## FUN_0054dcf0: efectos al dejar el campo la carta de la zona z (antes de destruirla).
func f54dcf0(p: int, z: int) -> int:
	var q := (p & 1) * PS
	var zone := 0xa1195c + z * 0x94 + q
	var cid := f401a70(m.u16(zone) & 0xfff) & 0xffff
	if cid == 0x14d:
		if (m.u8(zone + 6) & 2) != 0:
			if z != 10:
				return 0
			f54cbb0(p, 0x58f)
			f54cbb0(1 - p, 0x58f)
			if (m.u8(0xa11f2a + q) & 2) != 0:
				issue((0x8000 if p != 0 else 0) | 0x11, 0, 0, 0)
			return 0
	elif cid == 0x447:
		var r := f544000(p, z)
		if (r & 0xffff) != 0xffff and (m.u8(zone + 0x8f) & 4) == 0:
			f54e250(r & 0xff, (r >> 8) & 0xff, 1)
	elif cid == 0x48a:
		issue((0x8000 if p != 0 else 0) | 0x90, z, 0, 0)
	if z != 10:
		return 0
	if (m.u8(0xa11f2a + q) & 2) != 0:
		issue((0x8000 if p != 0 else 0) | 0x11, 0, 0, 0)
	return 0


## FUN_0054de00: destruye la carta de la zona z: emite 0x79 (o 0x7b si hay una 0x453 boca
## arriba en el campo), efectos al destruirse y vaciado de la zona (FUN_0054ca50).
## a3 viaja en el comando; a4 != 0 activa los efectos "al ir al cementerio".
func f54de00(p: int, z: int, a3: int, a4: int) -> int:
	var q := (p & 1) * PS
	var zone := 0xa1195c + z * 0x94 + q
	var ix := m.u16(zone) & 0xfff
	if ix == 0:
		return 0
	var fl := m.u16(zone + 0x90)
	if (fl & 4) != 0:
		return 0
	m.set_u16(zone + 0x90, fl | 4)
	f54dcf0(p, z)
	var pbit := 0x8000 if p != 0 else 0
	if (f401a70(ix) & 0xffff) >= 0x780 and (f401a70(ix) & 0xffff) < 0x7d0:
		issue(pbit | 0x79, z, a3, 0)
		f54ca50(p, z, 1)
		return 0
	var is453 := 1 if (f401a70(ix) & 0xffff) == 0x453 else 0
	var n := f543010(0, 0x453) - is453
	n += f543010(1, 0x453)
	var other := n > 0
	if ctype(ix) < 0x15:
		m.set_u8(0xa11955 + q, m.u8(0xa11955 + q) | 0x80)
	issue(pbit | (0x7b if other else 0x79), z, a3, 0)
	var t := ctype(ix)
	var code := 0x1e
	if t == 0x15:
		code = 0x15
	elif t == 0x16:
		code = 0x14
	f56a380(1 - p, code, ((z & 0xff) << 8) | (p & 0xff))
	if (f401a70(ix) & 0xffff) == 0x488 and (m.u8(zone + 0x8f) & 4) == 0:
		var r := f544000(p, z)
		if (r & 0xffff) != 0xffff:
			var rp := r & 0xff
			var rz := (r >> 8) & 0xff
			var rzone := 0xa1195c + rz * 0x94 + (rp & 1) * PS
			if (m.u32(rzone) & 0xfff) != 0 and (m.u8(rzone + 6) & 2) != 0:
				f54de00(rp, rz, 1, 1)
	if other:
		return 0
	f56e2e0(p, 1)
	if a4 == 0:
		return 0
	# Efectos al ir al cementerio segun el id (0x54e047-0x54e228)
	var reg := false   # registra el efecto 0x3c6e (FUN_0053baa0)
	match f401a70(ix) & 0xffff:
		0x12f, 0x136, 0x138, 0x139, 0x140, 0x1de, 0x412, 0x4da:
			reg = true
		0x1cd, 0x45c:
			reg = (m.u8(zone + 7) & 0x10) == 0
		0x2f, 0x23d, 0x4d9, 0x4e9:
			reg = (m.u32(zone) & 0x1c000) != 0 or z >= 5
		0x48a:
			issue(pbit | 0x90, z, 0, 0)
		0x3ba:
			if (m.u8(zone + 6) & 2) != 0 and (m.u8(zone + 0x8f) & 4) == 0:
				f54eed0(p, ix, z)
				if f542e60(p, 0x3ba, z) == 0:
					for i in 5:
						var e := m.u16(0xa1195c + q + i * 0x94) & 0xfff
						if e != 0 and f541ce0(f401a70(e)) != 0:
							f54de00(p, i, 1, 1)
					var oq := ((-1 - p) & 1) * PS
					for i in 5:
						var e := m.u16(0xa1195c + oq + i * 0x94) & 0xfff
						if e != 0 and f541ce0(f401a70(e)) != 0:
							f54de00(1 - p, i, 1, 1)
	if reg:
		var entry := m.u32(zone)
		f53baa0((((entry & 0xfffff78d) << 0x13) | ix | 0x3c6e0000) & 0xffffffff, 0)
	f54ca50(p, z, 1)
	return 0


## FUN_0054e250: destruye la carta de la zona z; si era una de las piezas 0x5f8/0x605-0x608 y
## sigue la 0x5f8 en el campo, destruye tambien las otras piezas de magia/trampa.
func f54e250(p: int, z: int, a3: int) -> int:
	var q := (p & 1) * PS
	var ix := m.u16(0xa1195c + z * 0x94 + q) & 0xfff
	f54de00(p, z, 1, 1 if (a3 & 0xffff) != 0 else 0)
	if ix == 0:
		return 0
	if f542f30(p, 0x5f8) == 0:
		return 0
	var cid := f401a70(ix) & 0xffff
	if cid != 0x5f8 and (cid <= 0x604 or cid > 0x608):
		return 0
	for i in range(5, 10):
		if i == z:
			continue
		var e := m.u32(0xa1195c + i * 0x94 + q)
		if (e & 0xfff) == 0:
			continue
		var c := f401a70(e & 0xfff) & 0xffff
		if c == 0x5f8 or (c > 0x604 and c <= 0x608):
			f54de00(p, i, 1, 0)
	return 0


## FUN_0054ef90: dano `amount` a los puntos de vida de p (comando 0x43) y aviso 0xf.
func f54ef90(p: int, amount: int) -> int:
	if amount == 0:
		return 0
	issue((0x8000 if p != 0 else 0) | 0x43, amount, 0, 1)
	f56a380(p, 0xf, ((p & 0xffff) << 16) | (amount & 0xffff))
	return 0


# --- Fusiones --------------------------------------------------------------------------------

## FUN_00563c20: busca un material con ese id (o su arte alternativo, id + 2000) en los
## monstruos (0x4000 | zona) o en la mano (0x8000 | posicion) de p, sin repetir ex1/ex2.
## Despues acepta cualquier comodin (FUN_00563b40). 0xffff si no hay.
func f563c20(p: int, card_id: int, ex1: int, ex2: int) -> int:
	var q := (p & 1) * PS
	var cid := card_id & 0xffff
	var e1 := ex1 & 0xffff
	var e2 := ex2 & 0xffff
	for z in 5:
		var ix := m.u16(0xa1195c + q + z * 0x94) & 0xfff
		if ix != 0:
			if (f401a70(ix) & 0xffff) == cid or (f401a70(ix) & 0xffff) == cid + 0x7d0:
				var r := z + 0x4000
				if e1 != r and e2 != r:
					return r
	var i := 0
	while i < m.u8(0xa11946 + q):
		var ix := m.u16(0xa11fb8 + q + i * 4) & 0xfff
		if (f401a70(ix) & 0xffff) == cid or (f401a70(ix) & 0xffff) == cid + 0x7d0:
			var r := i + 0x8000
			if e1 != r and e2 != r:
				return r
		i += 1
	for z in 5:
		var ix := m.u16(0xa1195c + q + z * 0x94) & 0xfff
		if ix != 0 and f563b40(f401a70(ix)) != 0:
			var r := z + 0x4000
			if e1 != r and e2 != r:
				return r
	i = 0
	while i < m.u8(0xa11946 + q):
		var ix := m.u16(0xa11fb8 + q + i * 4) & 0xfff
		if ix != 0 and f563b40(f401a70(ix)) != 0:
			var r := i + 0x8000
			if e1 != r and e2 != r:
				return r
		i += 1
	# El original solo fija ax = 0xffff; los llamadores usan los 16 bits bajos.
	return 0xffff


## FUN_00563df0: indice de la carta que senala el codigo de material (0x8000 mano,
## 0x4000 zona de monstruo).
func f563df0(p: int, code: int) -> int:
	if (code & 0x8000) != 0:
		return m.u32(0xa11fb8 + ((code & 0xfff) + (p & 1) * 0x355) * 4) & 0xfff
	if (code & 0x4000) != 0:
		return m.u32(0xa1195c + (code & 0xfff) * 0x94 + (p & 1) * PS) & 0xfff
	return code & 0xffff0000


## FUN_00563e50: 1 si p tiene los materiales para invocar por fusion la carta `index`
## (tablas de 0x5aa890, dos materiales, y 0x5aa9d0, tres). Los codigos de los materiales
## (ver FUN_00563c20) quedan en out_addr (u16[2] o u16[3]).
func f563e50(p: int, index: int, out_addr: int) -> int:
	if ctype(index) >= 0x15 or (f541950(index) & 0xffff) != 2:
		return 0
	var cid := f401a70(index) & 0xffff
	if cid >= 0x7d0:
		cid = (cid + 0xf830) & 0xffff
	var off := 0
	while off < 0x13e:
		if cid == m.u16(0x5aa890 + off):
			var m2 := m.u16(0x5aa894 + off)
			var r1 := f563c20(p, m.u16(0x5aa892 + off), 0xffff, 0xffff)
			m.set_u16(out_addr + 2, r1)
			var r0 := f563c20(p, m2, r1, 0xffff)
			m.set_u16(out_addr, r0)
			if (r0 & 0xffff) == 0xffff or m.u16(out_addr + 2) == 0xffff:
				return 0
			if f563b40(f401a70(f563df0(p, r0))) != 0 \
					and f563b40(f401a70(f563df0(p, m.u16(out_addr + 2)))) != 0:
				return 0
			if (m.u16(out_addr) & 0x8000) == 0 or (m.u16(out_addr + 2) & 0x8000) == 0:
				return 1
			return 0 if f543360(p) < 0 else 1
		off += 6
	for k in 4:
		if cid != m.u16(0x5aa9d0 + k * 8):
			continue
		var m2 := m.u16(0x5aa9d4 + k * 8)
		var m3 := m.u16(0x5aa9d6 + k * 8)
		var r2 := f563c20(p, m.u16(0x5aa9d2 + k * 8), 0xffff, 0xffff)
		m.set_u16(out_addr + 4, r2)
		var r1 := f563c20(p, m2, r2, 0xffff)
		m.set_u16(out_addr + 2, r1)
		var r0 := f563c20(p, m3, m.u16(out_addr + 4), r1)
		m.set_u16(out_addr, r0)
		if (r0 & 0xffff) == 0xffff or m.u16(out_addr + 2) == 0xffff \
				or m.u16(out_addr + 4) == 0xffff:
			return 0
		if f563b40(f401a70(f563df0(p, r0))) != 0 \
				and f563b40(f401a70(f563df0(p, m.u16(out_addr + 2)))) != 0:
			return 0
		if f563b40(f401a70(f563df0(p, m.u16(out_addr)))) != 0 \
				and f563b40(f401a70(f563df0(p, m.u16(out_addr + 4)))) != 0:
			return 0
		if f563b40(f401a70(f563df0(p, m.u16(out_addr + 2)))) != 0 \
				and f563b40(f401a70(f563df0(p, m.u16(out_addr + 4)))) != 0:
			return 0
		if (m.u16(out_addr) & 0x8000) == 0 or (m.u16(out_addr + 2) & 0x8000) == 0 \
				or (m.u16(out_addr + 4) & 0x8000) == 0:
			return 1
		return 0 if f543360(p) < 0 else 1
	return 0


# --- Avisos ----------------------------------------------------------------------------------

## FUN_0056a380: deja un aviso (codigo `kind`, dato `data`) en 0xa1608a-0xa16092 para el
## jugador p. En duelo en red con el turno del jugador 1 se envia al rival (FUN_0053ea40).
func f56a380(p: int, kind: int, data: int) -> int:
	if (m.u8(0xa16181) & 1) != 0 and (m.u8(0xa133f2) & 1) != 0:
		var packet := m.local(10)
		m.set_u16(packet, (1 - p) & 0xffff)
		m.set_u16(packet + 2, kind)
		m.set_u16(packet + 4, data & 0xffff)
		m.set_u16(packet + 6, (data >> 16) & 0xffff)
		f53ea40(0xf059, packet, 10)
		return 0
	m.set_u16(0xa1608a, kind)
	m.set_u32(0xa1608c, data)
	m.set_u8(0xa16091, 0)
	var b := p & 1
	var v := (((b * 2) | b) << 4) | (m.u16(0xa16092) & 0xffcf)
	m.set_u16(0xa16092, (v & 0xff70) | 0x40)
	return 0


## FUN_0056e2e0: por cada 0x51a boca arriba en el campo, p recibe a2 * 300 de dano.
func f56e2e0(p: int, a2: int) -> int:
	var n := f542f30(1 - p, 0x51a)
	n += f542f30(p, 0x51a)
	if n > 0:
		issue((0x8000 if p != 0 else 0) | 0x1e, 0x51a, 1, 0)
		f54ef90(p, n * a2 * 300)
	return 0


# --- Busqueda de cartas para los efectos ------------------------------------------------

## FUN_0056b9e0: 1 si la carta i del cementerio de p puede volver al campo (no es de
## fusion/ritual ni especial, o ya se invoco correctamente: bit 14 de la entrada).
func f56b9e0(p: int, i: int) -> int:
	var at := 0xa12238 + ((p & 1) * 0x355 + i) * 4
	var cls := f541950(m.u16(at) & 0xfff) & 0xffff
	if cls == 0:
		return 1
	if cls < 2 or cls > 3:
		if f5421c0(m.u16(at) & 0xfff) == 0:
			return 1
	return (m.u32(at) >> 14) & 1


## Anade la entrada de entry_addr a la lista de 0xa11624 con ese origen.
func _e_add(entry_addr: int, kind: int) -> void:
	m.set_u32(E_LIST + m.u16(E_COUNT) * 4, m.u32(entry_addr))
	m.set_u16(E_KIND + m.u16(E_COUNT) * 2, kind)
	m.set_u16(E_COUNT, m.u16(E_COUNT) + 1)


## Recorre una lista (contador u8 en cnt_at, entradas u32 en list_at) y anade las entradas
## que cumplen pred(direccion, i).
func _e_scan(cnt_at: int, list_at: int, kind: int, pred: Callable) -> void:
	var i := 0
	while i < m.u8(cnt_at):
		var at := list_at + i * 4
		if pred.call(at, i):
			_e_add(at, kind)
		i += 1


## Quita la entrada i de la lista de 0xa11624 (copia y luego descuenta, como el original).
func _e_remove(i: int) -> void:
	var c := i
	while c < m.u16(E_COUNT):
		m.set_u32(E_LIST + c * 4, m.u32(E_LIST + c * 4 + 4))
		m.set_u16(E_KIND + c * 2, m.u16(E_KIND + c * 2 + 2))
		c += 1
	m.set_u16(E_COUNT, m.u16(E_COUNT) - 1)


## Atributo de la carta (bits 29-31 de prop).
func _e_attr(index: int) -> int:
	return (f401a20(index) >> 0x1d) & 7


## FUN_0056ba50: rellena la lista de 0xa11624 con las cartas que puede elegir el efecto de la
## carta `card_id` del jugador p (mano, mazo, cementerio, fusion o excluidas segun el id).
## a3 es un dato extra del efecto (nivel, carta, jugador). Devuelve cuantas hay.
## Las salidas anticipadas del original con la lista vacia equivalen al final comun.
func f56ba50(p: int, card_id: int, a3: int) -> int:
	var cid := card_id & 0xffff
	var force := false       # bVar2: quita 0x2d6-0x2d8/0x2fe aunque haya 0x3ba en el campo
	var no_filter := false   # bVar3: no las quita nunca
	m.set_u16(E_COUNT, 0)
	var q := (p & 1) * PS
	var oq := ((-p - 1) & 1) * PS
	var hand_n := 0xa11946 + q
	var hand := 0xa11fb8 + q
	var deck_n := 0xa11947 + q
	var deck := 0xa120f8 + q
	var grave_n := 0xa11948 + q
	var grave := 0xa12238 + q
	var fus_n := 0xa11949 + q
	var fus := 0xa12378 + q
	var all := func(_at: int, _i: int) -> bool: return true
	var is_mon := func(at: int, _i: int) -> bool: return ctype(m.u16(at) & 0xfff) < 0x15
	var is_spell := func(at: int, _i: int) -> bool: return ctype(m.u16(at) & 0xfff) == 0x16
	match cid:
		0x3eb, 0x40a, 0x60b:
			var out := m.local(8)
			_e_scan(fus_n, fus, 8, func(at: int, _i: int) -> bool:
				return f563e50(p, m.u16(at) & 0xfff, out) != 0)
		0x1a3, 0x1f9, 0x5e8:
			_e_scan(fus_n, fus, 8, all)
		0xaa, 0x3fa:
			var dq := q if cid == 0xaa else oq
			no_filter = true
			var n := m.u8(0xa11947 + dq)
			var j := 0
			while j < n and j <= 4:
				_e_add(0xa120f8 + dq + j * 4, 2)
				j += 1
		0xf:
			var f := func(at: int, _i: int) -> bool:
				return s16(f401a70(m.u16(at) & 0xfff)) == 0x4b2
			_e_scan(hand_n, hand, 1, f)
			_e_scan(deck_n, deck, 2, f)
		0x2f, 0x23d:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				var ix := m.u16(at) & 0xfff
				if ctype(ix) >= 0x15:
					return false
				var v := f445810(ix) if cid == 0x2f else f445850(ix)
				return (v & 0xffff) < 0x5dd)
		0x65:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				return ctype(m.u16(at) & 0xfff) == 0x15)
		0x13d:
			var f := func(at: int, _i: int) -> bool:
				var c := f401a70(m.u16(at) & 0xfff) & 0xffff
				return c > 0x3c and (c < 0x3f or c == 0x4e1)
			_e_scan(hand_n, hand, 1, f)
			_e_scan(deck_n, deck, 2, f)
		0x191:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				var c := s16(f401a70(m.u16(at) & 0xfff))
				return c == 0x3eb or c == 0x40a)
		0x1a8:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				return s16(f401a70(m.u16(at) & 0xfff)) == 0x1a8)
		0x1ab:
			_e_scan(grave_n, grave, 4, is_spell)
		0x3b1:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				return ctype(m.u16(at) & 0xfff) > 0x14)
		0x3c6:
			# Mira el tipo de la carta j de la mano pero anade la carta j del mazo (asi en
			# el original).
			var j := 0
			while j < m.u8(hand_n):
				var hx := m.u16(hand + j * 4) & 0xfff
				if hx != 0 and ctype(hx) == 1:
					_e_add(deck + j * 4, 1)
				j += 1
		0x3f0:
			for pl in 2:
				var pq := (pl & 1) * PS
				_e_scan(0xa11948 + pq, 0xa12238 + pq, 4, func(at: int, i: int) -> bool:
					return ctype(m.u16(at) & 0xfff) < 0x15 and f56b9e0(pl, i) != 0)
		0x3f3, 0x5e7:
			if cid == 0x3f3:
				no_filter = true
			_e_scan(0xa11948 + oq, 0xa12238 + oq, 4, is_mon)
		0x400:
			no_filter = true
			_e_scan(grave_n, grave, 4, all)
			_e_scan(0xa11948 + oq, 0xa12238 + oq, 4, all)
		0x410:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				var c := s16(f401a70(m.u16(at) & 0xfff))
				return c == 0x3eb or c == 0x40a)
		0x41e:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				var ix := m.u16(at) & 0xfff
				return ctype(ix) < 0x15 and (f445810(ix) & 0xffff) < 0x5dd and f5421c0(ix) == 0)
			force = true
		0x439:
			no_filter = true
			_e_scan(deck_n, deck, 2, all)
		0x443:
			_e_scan(0xa11948 + oq, 0xa12238 + oq, 4, is_spell)
		0x447, 0x487, 0x488, 0x5f0, 0x45c:
			_e_scan(grave_n, grave, 4, func(at: int, i: int) -> bool:
				return ctype(m.u16(at) & 0xfff) < 0x15 and f56b9e0(p, i) != 0)
			if cid == 0x45c and p == a3:
				# Quita la primera 0x45c (descuenta y luego copia, como el original).
				var j := 0
				if m.u16(E_COUNT) != 0:
					while true:
						if s16(f401a70(m.u16(E_LIST + j * 4) & 0xfff)) == 0x45c:
							m.set_u16(E_COUNT, m.u16(E_COUNT) - 1)
							var c := j
							while c < m.u16(E_COUNT):
								m.set_u32(E_LIST + c * 4, m.u32(E_LIST + c * 4 + 4))
								m.set_u16(E_KIND + c * 2, m.u16(E_KIND + c * 2 + 2))
								c += 1
							break
						j += 1
						if j >= m.u16(E_COUNT):
							break
		0x454, 0x456, 0x45d, 0x45f, 0x460, 0x463:
			var want: int = {0x454: 5, 0x456: 4, 0x45d: 1, 0x45f: 3, 0x460: 6, 0x463: 2}[cid]
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				var ix := m.u16(at) & 0xfff
				if ctype(ix) >= 0x15 or (f445810(ix) & 0xffff) >= 0x5dd:
					return false
				var ok := _e_attr(ix) == want
				if (f541950(ix) & 0xffff) == 3 or (f541950(ix) & 0xffff) == 2:
					ok = false
				var c := f401a70(ix) & 0xffff
				if c in [0x37, 0x38, 0x3e, 0x42, 0x170, 0x175, 0x187, 0x2e5, 0x34d]:
					return false
				return ok)
		0x455:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				var ix := m.u16(at) & 0xfff
				return ctype(ix) < 0x15 and (f541950(ix) & 0xffff) == 3)
		0x45a, 0x45b, 0x51b:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				return (f401a70(m.u16(at) & 0xfff) & 0xffff) == cid)
		0x47b:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				var ix := m.u16(at) & 0xfff
				return ctype(ix) < 0x15 and (f445810(ix) & 0xffff) < 0x5dd and f542150(ix) == 0)
		0x462:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				var ix := m.u16(at) & 0xfff
				return ctype(ix) == 0x16 and (f53b880(ix) & 0xffff) == 6)
		0x4b2:
			_e_scan(deck_n, deck, 2, is_spell)
		0x4bc:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				var c := s16(f401a70(m.u16(at) & 0xfff))
				return c == 0x22 or c == 0x4ba or c == 0x7f2)
		0x4d8:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				return s16(f401a70(m.u16(at) & 0xfff)) == 0x2ea)
		0x4d9:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				var c := s16(f401a70(m.u16(at) & 0xfff))
				return c == 0x2ea or c == 0x4d8)
		0x526:
			_e_scan(deck_n, deck, 2, func(at: int, _i: int) -> bool:
				var ix := m.u16(at) & 0xfff
				return ctype(ix) == 10 and (f4457d0(ix) & 0xffff) == a3 and f5421c0(ix) == 0)
		0x58d:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				return ctype(m.u16(at) & 0xfff) < 0x15 and (m.u32(at) & 0x200000) != 0)
		0x59f:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				return ctype(m.u16(at) & 0xfff) == 0x16 and (m.u32(at) & 0x400000) != 0)
		0x5e9:
			no_filter = true
			_e_scan(grave_n, grave, 4, is_mon)
		0x5ea:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				return ctype(m.u16(at) & 0xfff) == 3)
		0x5eb, 0x5ec, 0x5ed, 0x5ee, 0x5ef:
			var want: int = [1, 4, 3, 5, 6][cid - 0x5eb]
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				var ix := m.u16(at) & 0xfff
				return ctype(ix) < 0x15 and _e_attr(ix) == want)
		0x5f4:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				return (m.u32(at) & 0x100000) != 0)
		0x5fc:
			_e_scan(grave_n, grave, 4, is_mon)
		0x60a:
			_e_scan(grave_n, grave, 4, func(at: int, _i: int) -> bool:
				return f563b70(a3, m.u16(at) & 0xfff) != 0 and (m.u32(at) & 0x100000) != 0)
		0x60d:
			_e_scan(0xa1194a + q, 0xa124b8 + q, 0x10, func(at: int, i: int) -> bool:
				return ctype(m.u16(at) & 0xfff) < 0x15 and m.u8(0xa125f8 + q + i * 2) != 2)
		_:
			return 0
	if m.u16(E_COUNT) == 0:
		return 0
	var r := f542fb0(p)
	if (force or r == 0) and not no_filter:
		var k := 0
		while k < m.u16(E_COUNT):
			if f541ce0(f401a70(m.u16(E_LIST + k * 4) & 0xfff)) != 0:
				_e_remove(k)
			else:
				k += 1
	var i := 0
	while i < m.u16(E_COUNT):
		if (m.u32(E_LIST + i * 4) & 0x20000) != 0:
			_e_remove(i)
		else:
			i += 1
	i = 0
	while i < m.u16(E_COUNT):
		if f583e00(m.u16(E_LIST + i * 4) & 0xfff) != 0:
			_e_remove(i)
		else:
			i += 1
	return m.u16(E_COUNT)


# --- Ataque ----------------------------------------------------------------------------------

## FUN_005715c0: el monstruo de la zona z ya ha atacado (bit 1 del byte +7 de la zona y
## bit z del u16 0xa1195a del jugador).
func f5715c0(p: int, z: int) -> int:
	var q := (p & 1) * PS
	var at := 0xa11963 + z * 0x94 + q
	m.set_u8(at, m.u8(at) | 2)
	m.set_u16(0xa1195a + q, m.u16(0xa1195a + q) | (1 << (z & 0x1f)))
	return 0


## FUN_00571780: hay una 0x47a boca arriba en magia/trampa que impide atacar a los monstruos
## de ese tipo (bits 11-15 del u16 +0x8e de su zona).
func f571780(race: int) -> int:
	var r := race & 0xffff
	for pl in 2:
		var q := (pl & 1) * PS
		for z in range(5, 10):
			var zone := 0xa1195c + z * 0x94 + q
			if (m.u32(zone) & 0xfff) == 0 or (m.u8(zone + 6) & 2) == 0 \
					or (m.u8(zone + 0x8f) & 4) != 0:
				continue
			if (f401a70(m.u16(zone) & 0xfff) & 0xffff) == 0x47a \
					and (m.u16(zone + 0x8e) >> 0xb) == r:
				return 1
	return 0


## FUN_00571810: 1 si el monstruo de la zona z de p puede atacar. a3 != 0 aplica tambien
## los costes y condiciones propias de la carta.
func f571810(p: int, z: int, a3: int) -> int:
	var q := (p & 1) * PS
	var zone := 0xa1195c + z * 0x94 + q
	var flags := m.u16(zone + 6)
	var ix := m.u16(zone) & 0xfff
	if ix == 0 or (flags & 2) == 0:
		return 0
	if ((1 << (z & 0x1f)) & m.u16(0xa1195a + q)) != 0:
		return 0
	# FUN_00546470 escribe 12 bytes: +2 tipo (5 bits), +4 ATK
	var buf := m.local(0x10)
	f546470(p, z, buf)
	var atk := m.u16(buf + 4)
	var race := m.u8(buf + 2) & 0x1f
	if f545620(p, z, 0x15c) != 0:
		return 0
	if f545620(p, z, 0x4dc) != 0:
		return 0
	if f545730(p, z, 0x60c) != 0:
		return 0
	if f545730(p, z, 0x417) != 0 and race != 7:
		return 0
	if f571780(race) != 0:
		return 0
	if f545620(p, z, 0x2d9) != 0:
		return 0
	if f545620(p, z, 0x534) != 0:
		return 0
	if (f542f30(0, 0x46b) > 0 or f542f30(1, 0x46b) > 0) and atk >= 0x5dc:
		return 0
	if (f542f30(0, 0x52b) > 0 or f542f30(1, 0x52b) > 0) and (f4457d0(ix) & 0xffff) > 3:
		return 0
	var other := 1 - p
	if f542f30(other, 0x548) > 0 and race == 10:
		return 0
	if f545620(p, z, 0x58b) != 0:
		return 0
	if (f401a70(ix) & 0xffff) == 0x5f3 and f5431b0(other) == 0:
		return 0
	var is536 := 1 if (f401a70(ix) & 0xffff) == 0x536 else 0
	var n := f542f30(0, 0x536) - is536
	n += f542f30(1, 0x536)
	if n > 0:
		return 0
	if a3 != 0:
		var lp := m.u16(0xa11944 + q)
		match f401a70(ix) & 0xffff:
			0x226:
				if lp < 1000:
					return 0
			0x2d6, 0x2d7, 0x2d8, 0x2fe:
				if lp < 500:
					return 0
			0x2e8, 0x2f9:
				if f543400(p, z) == 0:
					return 0
		if m.u8(0xa11947 + q) < f542f30(other, 0x427):
			return 0
		var k := f542f30(1, 0x42a)
		k += f542f30(0, 0x42a)
		if k != 0 and m.u16(0xa11944 + q) <= k * 500:
			return 0
	if ((f401a70(ix) & 0xffff) == 0x31c or (flags & 1) == 0) \
			and (m.u8(zone + 7) & 8) == 0 and (m.u8(zone + 0x8e) & 0xc) == 0:
		return 1
	return 0


## FUN_00571c30: calcula en el u16 base + 0x14 (del bloque de p) la mascara de monstruos que
## pueden atacar. a4 != 0 limpia tambien base + 0x16 e incluye los que ya han atacado.
## a3 no se usa.
func f571c30(base: int, p: int, _a3: int, a4: int) -> int:
	var q := (p & 1) * PS
	var mask_at := base + q + 0x14
	m.set_u16(mask_at, 0)
	if f542f30(1 - p, 0x15b) != 0:
		return 0
	if f542f30(0, 0x4ce) != 0 or f542f30(1, 0x4ce) != 0:
		return 0
	var k := f542f30(1, 0x42a)
	k += f542f30(0, 0x42a)
	if m.u16(0xa11944 + q) < k * 500:
		return 0
	if a4 != 0:
		m.set_u16(base + q + 0x16, 0)
	for i in 5:
		if f571810(p, i, 1) != 0:
			if a4 != 0 or ((1 << (i & 0x1f)) & m.u16(0xa1195a + q)) == 0:
				m.set_u16(mask_at, m.u16(mask_at) | (1 << (i & 0x1f)))
	return 0


# --- Auxiliares puras fuera de los lotes (las usan las funciones de este modulo) ----------

## FUN_004457d0 (indice en ESI): nivel de la carta (0 magia/trampa, 10 el tipo 0x18).
func f4457d0(index: int) -> int:
	var t := (f401a20(index) >> 0x14) & 0x1f
	if t >= 0x15:
		if t <= 0x17:
			return 0
		if t == 0x18:
			return 10
	return (f401a20(index) >> 0x19) & 0xf


## FUN_00445810 (indice en ESI): ATK base (4000 el tipo 0x18).
func f445810(index: int) -> int:
	var t := (f401a20(index) >> 0x14) & 0x1f
	if t >= 0x15:
		if t <= 0x17:
			return 0
		if t == 0x18:
			return 4000
	return ((f401a20(index) >> 9) & 0x1ff) * 10


## FUN_00445850 (indice en ESI): DEF base (4000 el tipo 0x18).
func f445850(index: int) -> int:
	var t := (f401a20(index) >> 0x14) & 0x1f
	if t >= 0x15:
		if t <= 0x17:
			return 0
		if t == 0x18:
			return 4000
	return (f401a20(index) & 0x1ff) * 10


## FUN_0053b880 (indice en ESI): subtipo de magia/trampa (0 si es otra cosa).
func f53b880(index: int) -> int:
	var t := (f401a20(index) >> 0x14) & 0x1f
	if t >= 0x15 and t <= 0x16:
		return (f401a20(index) >> 0x11) & 7
	return 0


## FUN_00542150: monstruo de clase 1 o uno de los ids 0x2da, 0x32c, 0x4d9, 0x536, 0x5f6.
func f542150(index: int) -> int:
	if ((f401a20(index) >> 0x14) & 0x1f) >= 0x15:
		return 0
	var r := 1 if (f541950(index) & 0xffff) == 1 else 0
	var c := f401a70(index) & 0xffff
	if c in [0x2da, 0x32c, 0x4d9, 0x536, 0x5f6]:
		r = 1
	return r


## FUN_005421c0: monstruo que no se puede invocar de forma normal (fusion, ritual o ids
## concretos).
func f5421c0(index: int) -> int:
	if ((f401a20(index) >> 0x14) & 0x1f) >= 0x15:
		return 0
	var cls := f541950(index) & 0xffff
	if cls == 0:
		return 0
	if cls > 1 and cls <= 3:
		return 1
	var c := f401a70(index) & 0xffff
	if c >= 0x2d6 and c <= 0x2d8:
		return 1
	if c >= 0x5ea and c <= 0x5ef:
		return 1
	if c in [0x37, 0x38, 0x3e, 0x42, 0x170, 0x175, 0x187, 0x2e5, 0x2fe, 0x34d, 0x4b2, 0x4e9]:
		return 1
	return 0


## FUN_00563b40: material comodin de fusion (ids 0x6c, 0x101, 0x10c, 0x281).
func f563b40(card_id: int) -> int:
	var c := card_id & 0xffff
	return 1 if c == 0x6c or c == 0x101 or c == 0x10c or c == 0x281 else 0


## FUN_00563b70: 1 si la carta `b` es material de la fusion `a` (tablas de 0x5aa890 y
## 0x5aa9d0) o es un comodin.
func f563b70(a: int, b: int) -> int:
	var u1 := f401a70(a) & 0xffff
	var u2 := f401a70(b) & 0xffff
	if u1 >= 0x7d0:
		u1 = (u1 + 0xf830) & 0xffff
	if u2 >= 0x7d0:
		u2 = (u2 + 0xf830) & 0xffff
	var off := 0
	while off < 0x13e:
		if u1 == m.u16(0x5aa890 + off):
			if m.u16(0x5aa892 + off) == u2 or m.u16(0x5aa894 + off) == u2:
				return 1
		off += 6
	off = 0
	while off < 0x20:
		if u1 == m.u16(0x5aa9d0 + off):
			if m.u16(0x5aa9d2 + off) == u2 or m.u16(0x5aa9d4 + off) == u2 \
					or m.u16(0x5aa9d6 + off) == u2:
				return 1
		off += 8
	return 1 if f563b40(u2) != 0 else 0


## FUN_00583e00: siempre 0 (filtro vacio de FUN_0056ba50).
func f583e00(_index: int) -> int:
	return 0
