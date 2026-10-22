class_name JoeyPortR
extends JoeyPortQ
## Motor nativo de Joey, lote R de la etapa 3: motor continuo C 59ca20-59dab0 y 5ba060 (contadores, Necrovalley, cambio por fotograma).
## Cada funcion se llama f<direccion de Joey_Pc.exe> y sobrescribe su declaracion con la misma
## aridad. Cotejo: re/scripts/joey_specs/port_r.py.

## Lista de candidatos (40cae0/40cd00): entradas u32, orden u16 (numero en el byte alto) y total.
const _JR_LIST_ENTRIES := 0xa582a4
const _JR_LIST_ORDER := 0xa584a4
const _JR_LIST_N := 0xa585a4


## Carta activa en magia/trampa: banderas +6 con el bit 1 y estado +0x8c sin los bits 1 y 5.
func _jr_active(zat: int) -> bool:
	var st := m.u32(zat + JoeyMem.Z_STATUS)
	return ((m.u8(zat + JoeyMem.Z_FLAGS) >> 1) & ~(st >> 5) & ~(st >> 1) & 1) != 0


## Joey FUN_0040cd00: entrada de la lista de candidatos cuyo orden (byte alto) es n; sin ella,
## la que sigue a la ultima.
func f40cd00(n: int) -> int:
	var count := m.u32(_JR_LIST_N) & 0xffff
	var i := 0
	while i < count:
		if (n & 0xffffffff) == m.u16(_JR_LIST_ORDER + i * 2) >> 8:
			break
		i += 1
	return _JR_LIST_ENTRIES + i * 4


## Joey FUN_0059ca20: con 0x52 en juego, cada 0x62 boca arriba anuncia 0x94 si tiene el bit 9
## y, en las del jugador p con menos de 0x10 en los bits 2-5, 0x8b.
func f59ca20(p: int) -> int:
	if _s32(f569b00(0x52)) <= 0:
		return 0
	for q in 2:
		for z in 5:
			var zat := JoeyMem.zone(q, z)
			if m.u16(zat) & 0xfff == f402460(0x62) & 0xffff and m.u16(zat + JoeyMem.Z_FLAGS) & 2:
				if m.u16(zat + JoeyMem.Z_FLAGS) & 0x200:
					f578390(q, m.u16(zat) & 0xfff, z)
					f5b9170(_jq_op(q, 0x94), z, 0, 0)
				if q == (p & 0xffffffff) and (m.u8(zat + JoeyMem.Z_FLAGS) & 0x3c) < 0x10:
					f578390(q, m.u16(zat) & 0xfff, z)
					f5b9170(_jq_op(q, 0x8b), z, 1, 0)
	return 0


## Joey FUN_0059cb10: cada carta en monstruos (salvo la zona z de p) que cumple 569790 (0xa5)
## hace ganar 500 puntos de vida a su jugador.
func f59cb10(p: int, z: int) -> int:
	for k in 2:
		var q := p if k == 0 else (1 - p) & 0xffffffff
		for zz in 5:
			if (q != (p & 0xffffffff) or zz != z) and f569790(q, zz, 0xa5) != 0:
				f578390(q, m.u16(JoeyMem.zone(q, zz)) & 0xfff, zz)
				f5787f0(q, 500)
	return 0


## Joey FUN_0059cbb0: con 0x148 en juego, si algun monstruo boca arriba en ataque cumple 56f6d0,
## anuncia 0x1e y les aplica 575190; 1 si lo hizo.
func f59cbb0() -> int:
	var turn := m.u8(JoeyMem.TURN) & 1
	if _s32(f5699c0(0x148)) <= 0:
		return 0
	var any := false
	for q in 2:
		for z in 5:
			var zat := JoeyMem.zone(q, z)
			var fl := m.u16(zat + JoeyMem.Z_FLAGS)
			if m.u32(zat) & 0xfff and fl & 2 and fl & 1 == 0:
				if f56f6d0(q, z) & 0xffff == 1:
					any = true
	if not any:
		return 0
	# Bit 15 invertido: se pone cuando el turno es del jugador 0.
	f5b9170((0x8000 if turn != 1 else 0) | 0x1e, 0x148, 1, 0)
	for q in 2:
		for z in 5:
			var zat := JoeyMem.zone(q, z)
			var fl := m.u16(zat + JoeyMem.Z_FLAGS)
			if m.u32(zat) & 0xfff and fl & 2 and fl & 1 == 0:
				if f56f6d0(q, z) & 0xffff == 1:
					f575190(q, z, 0, 0, f402460(0x148) & 0xffff)
	return 1


## Joey FUN_0059ccf0: anuncia 0xb1 por cada trampa boca arriba en magia/trampa.
func f59ccf0() -> int:
	for q in 2:
		for z in range(5, 10):
			var zat := JoeyMem.zone(q, z)
			if m.u16(zat) & 0xfff and m.u8(zat + JoeyMem.Z_FLAGS) & 2:
				if f4025d0(m.u16(zat) & 0xfff) & 0xffff == 0x15:
					f5b9170(_jq_op(q, 0xb1), z, 1, 0)
	return 0


## Joey FUN_0059cd70: con 0x402 en juego, los monstruos que cumplen 56db30 (0x3f0) se anuncian
## con 0x1e y pasan por 577bf0 empezando por el jugador del turno; 1 si hubo alguno.
func f59cd70() -> int:
	if f5699c0(0x402) == 0:
		return 0
	var mask := 0
	for q in 2:
		for z in 5:
			if f56db30(q, z, 0x3f0) != 0:
				mask |= 1 << ((q * 0x10 + z) & 0x1f)
	if mask == 0:
		return 0
	f5b9170(((m.u8(JoeyMem.TURN) << 0xf) & 0xffff) | 0x1e, 0x402, 1, 0)
	for k in 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ k
		var other := int(_s32(f5699a0(1 - q, 0x402)) > 0)
		for z in 5:
			if mask & (1 << ((q << 4) + z)):
				f577bf0(q, z, other, f402460(0x402) & 0xffff)
	return 1


## Joey FUN_0059ce90: cada 0x40e activa en magia/trampa del rival de p anuncia 0x88 con valor v.
func f59ce90(p: int, v: int) -> int:
	var q := (1 - p) & 0xffffffff
	for z in range(5, 10):
		var zat := JoeyMem.zone(q, z)
		if f4022e0(m.u32(zat) & 0xfff) & 0xffff == 0x40e and _jr_active(zat):
			f5b9170(_jq_op(q, 0x88), z, v, 1)
	return 0


## Joey FUN_0059cf30: cada 0x40e con contador anuncia 0x88 (lo vacia) y, activa, quita al rival
## 500 puntos de vida por contador; 1 si alguna lo hizo.
func f59cf30() -> int:
	var hit := 0
	for k in 2:
		var q := k ^ (m.u8(JoeyMem.TURN) & 1)
		for z in range(5, 10):
			var zat := JoeyMem.zone(q, z)
			var e := m.u32(zat)
			if f4022e0(e & 0xfff) & 0xffff == 0x40e and m.u16(zat + JoeyMem.Z_COUNTER) != 0:
				f5b9170(_jq_op(q, 0x88), z, 0, 0)
				if _jr_active(zat):
					f578390(q, e & 0xfff, z)
					f5784e0(1 - q, m.u16(zat + JoeyMem.Z_COUNTER) * 500)
					hit = 1
	return hit


## Joey FUN_0059d040: con 0x436 en juego anuncia 0x1e y p pierde 500 puntos de vida por copia.
func f59d040(p: int) -> int:
	var n := f5699c0(0x436)
	if _s32(n) > 0:
		f5b9170(_jq_op(p, 0x1e), 0x436, 1, 0)
		f578460(p, (n * 500) & 0xffffffff)
	return 0


## Joey FUN_0059d090: la primera 0x464 boca arriba sin anular (empezando por el jugador del
## turno) destruye con 5747e0 los monstruos boca arriba a los que no afecta 56d790 y que no
## cumplen 56aa70; los que si la cumplen van a la mascara de 5777f0, con aviso 0x1e. 1 si la uso.
func f59d090() -> int:
	for k in 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ k
		for z in 5:
			var zat := JoeyMem.zone(q, z)
			var e := m.u32(zat)
			if f4022e0(e & 0xfff) & 0xffff != 0x464 or m.u8(zat + JoeyMem.Z_FLAGS) & 2 == 0:
				continue
			if f56b440(e & 0xfff, JoeyMem.ident(m.u32(zat))) != 0:
				continue
			var mask := 0
			for t in 2:
				for tz in 5:
					var tat := JoeyMem.zone(t, tz)
					if m.u32(tat) & 0xfff and m.u8(tat + JoeyMem.Z_FLAGS) & 2 \
							and f56d790(t, tz, 0x464) == 0:
						if f56aa70(t, tz) == 0:
							f5747e0(q, (z << 8) | q, (tz << 8) | t, 8)
						else:
							mask |= 1 << ((t * 0x10 + tz) & 0x1f)
			if mask == 0:
				return 0
			var own := f5699a0(m.u8(JoeyMem.TURN) & 1, 0x464)
			var side := int(own == 0) ^ (m.u8(JoeyMem.TURN) & 1)
			f5b9170(0x1e, 0x464, 1, 0)
			f5777f0(side, f402460(0x464) & 0xffff, mask)
			return 1
	return 0


## Joey FUN_0059d240: con 0x476 en juego de p, cada 0x476 activa en magia/trampa/campo de p
## anuncia 0x88; sin el bit 4 de estado lo activa (579990), y encadena su efecto (5ba490).
func f59d240(p: int) -> int:
	if f5699a0(p, 0x476) == 0:
		return 0
	for z in range(5, 11):
		var zat := JoeyMem.zone(p, z)
		var e := m.u32(zat)
		if f4022e0(e & 0xfff) & 0xffff != 0x476:
			continue
		var st := m.u32(zat + JoeyMem.Z_STATUS)
		if ((m.u8(zat + JoeyMem.Z_FLAGS) >> 1) & ~(st >> 5) & ~(st >> 1) & 1) == 0:
			continue
		if st & 0x10 == 0:
			f579990(p, z, 4, 1)
			f5b9170(_jq_op(p, 0x88), z, 0, 0)
			var ident := JoeyMem.ident(m.u32(zat))
			f5ba490(((((z & 0x1f) | (p << 0xf) | 0x3c20) << 0x10) & 0xffffffff) | (e & 0xfff), ident, p & 0xff)
		else:
			f5b9170(_jq_op(p, 0x88), z, 1, 1)
	return 0


## Joey FUN_0059d370: Necrovalley (0x48a) en la zona z de p: lo retira (574900) y destruye con
## 5747e0 las cartas en juego con el id de su vinculo de tipo 9 y, si es 0x2fa, las vinculadas
## (tipo 0xd) al objeto del jugador.
func f59d370(p: int, z: int) -> int:
	var low := p & 1
	var zat := JoeyMem.zone(low, 0) + z * JoeyMem.ZONE_SIZE
	if f4022e0(m.u16(zat) & 0xfff) & 0xffff != 0x48a:
		return 0
	var key := f402460(0x48a) & 0xffff
	var src := ((z & 0xff) << 8) | (p & 0xff)
	var target := 0
	var n := m.u16(zat + JoeyMem.Z_LINKS_N)
	var i := 0
	while i < n:
		if m.u8(zat + JoeyMem.Z_LINK_KIND + i * 2) & 0xf == 9:
			target = m.u16(zat + JoeyMem.Z_LINK_REF + i * 2)
			break
		i += 1
	f574900(p, z, key, 1)
	for q in 2:
		for zz in 11:
			var at := JoeyMem.zone(q, zz)
			if f5674e0(m.u16(at) & 0xfff, target) != 0:
				var e := m.u32(at)
				f5747e0(p, key, src, ((JoeyMem.ident(e) & 0xff) << 8) | 0xb)
	if f4022e0(target) & 0xffff != 0x2fa:
		return 0
	for q in 2:
		var pat := JoeyMem.zone(q, 11)
		var j := 0
		while j < m.u16(pat + JoeyMem.Z_LINKS_N):
			var kind_at := pat + JoeyMem.Z_LINK_KIND + j * 2
			if m.u8(kind_at) & 0xf == 0xd and m.u16(pat + JoeyMem.Z_LINK_REF + j * 2) == target:
				f5747e0(p, key, src, (m.u8(kind_at + 1) << 8) | 0xb)
			j += 1
	return 0


## Joey FUN_0059d560: cada 0x519 activa en magia/trampa de p anuncia 0x88 (+1 contador).
func f59d560(p: int) -> int:
	for z in range(5, 10):
		var zat := JoeyMem.zone(p, z)
		if f4022e0(m.u32(zat) & 0xfff) & 0xffff == 0x519 and _jr_active(zat):
			f5b9170(_jq_op(p, 0x88), z, 1, 1)
	return 0


## Joey FUN_0059d5f0: cada 0x519 con contador anuncia 0x88 (lo vacia) y, activa, da 500 puntos
## de vida a su jugador; 1 si alguna lo hizo.
func f59d5f0() -> int:
	var hit := 0
	for k in 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ k
		for z in range(5, 10):
			var zat := JoeyMem.zone(q, z)
			var e := m.u32(zat)
			if f4022e0(e & 0xfff) & 0xffff == 0x519 and m.u16(zat + JoeyMem.Z_COUNTER) != 0:
				f5b9170(_jq_op(q, 0x88), z, 0, 0)
				if _jr_active(zat):
					f578390(q, e & 0xfff, z)
					f5787f0(q, 500)
					hit = 1
	return hit


## Joey FUN_0059d6e0: cada 0x51a activa en magia/trampa suma n cartas perdidas por p a su
## contador (byte p) con 0x88.
func f59d6e0(p: int, n: int) -> int:
	var shift := ((p & 0xff) * 8) & 0x1f
	for q in 2:
		for z in range(5, 10):
			var zat := JoeyMem.zone(q, z)
			if f4022e0(m.u32(zat) & 0xfff) & 0xffff == 0x51a and _jr_active(zat):
				f5b9170(_jq_op(q, 0x88), z, (n << shift) & 0xffffffff, 1)
	return 0


## Joey FUN_0059d790: cada 0x51a con contador anuncia 0x88 (lo vacia) y, activa, quita a cada
## jugador 300 puntos de vida por carta perdida (su byte del contador); 1 si alguna lo hizo.
func f59d790() -> int:
	var hit := 0
	for k in 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ k
		for z in range(5, 10):
			var zat := JoeyMem.zone(q, z)
			var e := m.u32(zat)
			if f4022e0(e & 0xfff) & 0xffff == 0x51a and m.u16(zat + JoeyMem.Z_COUNTER) != 0:
				f5b9170(_jq_op(q, 0x88), z, 0, 0)
				if _jr_active(zat):
					var t := m.u8(JoeyMem.TURN) & 1
					f578390(q, e & 0xfff, z)
					f5784e0(t, ((m.u16(zat + JoeyMem.Z_COUNTER) >> (t << 3)) & 0xff) * 300)
					f5784e0(t ^ 1, ((m.u16(zat + JoeyMem.Z_COUNTER) >> ((t ^ 1) << 3)) & 0xff) * 300)
					hit = 1
	return hit


## Joey FUN_0059d8f0: cada 0x595 con contador anuncia 0x88 (lo vacia) y, activa, encadena su
## efecto (5ba490); 1 si alguna lo hizo.
func f59d8f0() -> int:
	var hit := 0
	for k in 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ k
		for z in range(5, 10):
			var zat := JoeyMem.zone(q, z)
			var e := m.u32(zat)
			if f4022e0(e & 0xfff) & 0xffff == 0x595 and m.u16(zat + JoeyMem.Z_COUNTER) != 0:
				f5b9170(_jq_op(q, 0x88), z, 0, 0)
				if _jr_active(zat):
					var ident := JoeyMem.ident(m.u32(zat))
					f5ba490(((((z & 0x1f) | (q << 0xf) | 0xa20) << 0x10) & 0xffffffff) | (e & 0xfff), ident, 0)
					hit = 1
	return hit


## Joey FUN_0059da10: cada 0x59a boca arriba sin anular en monstruos de p anuncia 0x88
## (+1 contador). Devuelve el EAX que deja la ultima zona (5787f0 lo propaga).
func f59da10(p: int) -> int:
	var eax := 0
	for z in 5:
		var zat := JoeyMem.zone(p, z)
		var e := m.u32(zat)
		eax = f4022e0(e & 0xfff)
		if eax & 0xffff != 0x59a or m.u8(zat + JoeyMem.Z_FLAGS) & 2 == 0:
			continue
		eax = f56b440(e & 0xfff, JoeyMem.ident(m.u32(zat)))
		if eax == 0:
			eax = f5b9170(_jq_op(p, 0x88), z, 1, 1)
	return eax


## Joey FUN_0059dab0: cada 0x59a con contador en monstruos anuncia 0x88 (lo vacia) y, activa,
## quita al rival 500 puntos de vida por contador; 1 si alguna lo hizo.
func f59dab0() -> int:
	var hit := 0
	var k := 0
	while k < 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ k
		for z in 5:
			var zat := JoeyMem.zone(q, z)
			var e := m.u32(zat)
			var count := m.u16(zat + JoeyMem.Z_COUNTER)
			if f4022e0(e & 0xfff) & 0xffff != 0x59a or count == 0:
				continue
			f5b9170(_jq_op(q, 0x88), z, 0, 0)
			if not _jr_active(zat):
				continue
			f578390(q, e & 0xfff, z)
			for _i in count:
				f5784e0(1 - q, 500)
			# El original reutiliza el contador del bucle de jugadores: tras disparar, sale.
			k = count
			hit = 1
		k += 1
	return hit


## Joey FUN_005ba060: un cambio continuo por fotograma (fuera del turno remoto): avisos de
## 598d70 y de los contadores (0x148, 0x519, 0x40e, 0x51a, 0x59a, 0x595, 0x402, 0x464), banderas
## 3/4 de jugador (56d3f0, 5797e0) y monstruos (574b80, 574480, 5743f0); 1 si alguno actuo.
func f5ba060() -> int:
	var turn := m.u8(JoeyMem.TURN)
	if turn & 0x10 and (m.u8(JoeyMem.MODE) ^ turn) & 1:
		return 0
	if f598d70() != 0:
		return 1
	f59ca20(0xffffffff)
	if f59cbb0() != 0 or f59d5f0() != 0 or f59cf30() != 0 or f59d790() != 0 or f59dab0() != 0 \
			or f59d8f0() != 0 or f59cd70() != 0:
		return 1
	if m.u32(_JQ_RULES) & 1 == 0 and f59d090() != 0:
		return 1
	for k in 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ k
		if f56d3f0(q) == 0:
			f579930(q, 3, 0)
			if m.u8(JoeyMem.pl(q) + 0x6d0) & 0x10:
				f5797e0(q)
		else:
			f579930(q, 3, 1)
			f579930(q, 4, 1)
	for k in 2:
		var q := (m.u8(JoeyMem.TURN) & 1) ^ k
		for z in 5:
			var zat := JoeyMem.zone(q, z)
			if m.u32(zat) & 0xfff:
				if m.u8(zat + JoeyMem.Z_FLAGS) & 2 == 0:
					f574b80(q, z)
				f574480(q, z)
				if f5743f0(q, z) != 0:
					return 1
	return 0

