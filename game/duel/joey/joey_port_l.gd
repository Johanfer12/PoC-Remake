class_name JoeyPortL
extends JoeyPortK
## Motor nativo de Joey, lote L de la etapa 2: casos del despacho 5b9470 sin funcion propia 0x59-0xac (_c5b9470_XX).
## Cada funcion se llama f<direccion de Joey_Pc.exe> (o _c5b9470_XX para los casos del despacho)
## y sobrescribe su declaracion con la misma aridad. Cotejo: re/scripts/joey_specs/port_l.py.
##
## Todos los fragmentos de este lote (571670-573fa8) son cuerpos completos: abren su propio
## marco, leen el comando solo de a550a0-a550a6 y terminan con ret hacia el llamador de 5b9470,
## asi que los registros de entrada (EAX indice, ECX caso) no influyen salvo en bits altos de
## argumentos que los llamados enmascaran. Los casos 0x7e y 0x7f escriben c = 0x20 y saltan a los
## cuerpos de 0x75 y 0x76. Las palabras de ubicacion que se construyen sobre variables locales
## sin inicializar acaban con todos sus bits fijados por el codigo (comprobado en el ASM).

## Carta en transito, objeto de zona del jugador 0 y mano del jugador 0 (el 1 suma 0xd44).
const _JL_MOVED := 0xa558b0
const _JL_ZONE := 0xa55d74
const _JL_HAND := 0xa56434


## Objeto de zona z (sin enmascarar) del jugador p & 1.
static func _jl_zone(p: int, z: int) -> int:
	return _JL_ZONE + (p & 1) * JoeyMem.PLAYER_SIZE + z * JoeyMem.ZONE_SIZE


## Entrada i de la mano del jugador p & 1.
static func _jl_hand(p: int, i: int) -> int:
	return _JL_HAND + (p & 1) * JoeyMem.PLAYER_SIZE + i * 4


## Entrada local (b << 16 | a) con el indice 12 bits sustituido por 402460(a & 0xfff).
func _jl_entry_ab() -> int:
	var local := m.local(4)
	m.set_u32(local, (cmd_b() << 16) | cmd_a())
	var idx := f402460(cmd_a() & 0xfff)
	m.set_u32(local, (idx & 0xfff) | (m.u32(local) & 0xfffff000))
	return local


## Palabra de ubicacion de 570420: (r << 15) | (w & 0x7fff), con r = 570420(w & 1, w >> 1, w >> 6).
func _jl_with_570420(w: int) -> int:
	w &= 0xffff
	var r := f570420(w & 1, (w >> 1) & 0x1f, (w >> 6) & 0xff)
	return ((r << 0xf) | (w & 0x7fff)) & 0xffff


## Joey 5b9470 caso 0x59 (opcodes 83, codigo en 571670): mueve la carta de la zona (a & 1, a >> 8)
## a la zona (b & 1, b >> 8): paso 0 comprueba ambas zonas (<= 10), paso 1 avisa al buzon 40cdb0
## y del paso 2 en adelante copia el objeto, vacia el origen y reescribe los vinculos (56b360).
func _c5b9470_59() -> int:
	var a := cmd_a()
	var b := cmd_b()
	var a_lo := a & 0xff
	var a_hi := a >> 8
	var b_lo := b & 0xff
	var b_hi := b >> 8
	var step := cmd_step()
	if step == 0:
		if a_hi > 10 or b_hi > 10:
			cmd_finish()
		else:
			cmd_advance()
		return 0
	if step == 1:
		f5675c0(_JL_MOVED, f5700f0(a_lo, a_hi, 0))
		var w_from := ((((m.u16(_jl_zone(a_lo, a_hi) + JoeyMem.Z_FLAGS) << 0xd) & 0xffff) \
				| (a_hi & 0x1f)) << 1 | (a_lo & 1)) & 0xffff
		var w_to := ((b_hi & 0x1f) << 1) | (b_lo & 1) | (w_from & 0xc000)
		if b_hi >= 5:
			w_to &= 0xbfff
		var from := m.local(4)
		var to := m.local(4)
		m.set_u16(from, w_from)
		m.set_u16(to, w_to)
		f40cdb0(m.u32(_JL_MOVED) & 0xfff, from, to)
		cmd_advance()
		return 0
	var src := _jl_zone(a_lo, a_hi)
	var dst := _jl_zone(b_lo, b_hi)
	f5bde10(dst, src, 0x90)
	f5675c0(dst, _JL_MOVED)
	f5bddf0(src, 0x90)
	m.set_u32(0xa577f0, m.u32(0xa577f0) & ~(1 << (((a_lo << 4) + a_hi) & 0x1f)))
	m.set_u32(dst + JoeyMem.Z_STATUS, m.u32(dst + JoeyMem.Z_STATUS) & 0xfffdffff)
	if b_hi >= 5:
		m.set_u16(dst + JoeyMem.Z_FLAGS, m.u16(dst + JoeyMem.Z_FLAGS) & 0xfffe)
	f56b360((a_hi << 8) | a_lo, (b_hi << 8) | b_lo)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x5b (opcodes 85, codigo en 5718c0): intercambia los objetos de las zonas
## (a & 1, a >> 8) y (b & 1, b >> 8) dejando sus entradas en a550a6 y a558b0 (paso 0), avisa al
## buzon 40ced0 (paso 1) y restaura las entradas cruzadas (paso 2).
func _c5b9470_5b() -> int:
	var a_lo := m.u8(JoeyMem.CMD + 2)
	var a_hi := m.u8(JoeyMem.CMD + 3)
	var b_lo := m.u8(JoeyMem.CMD + 4)
	var b_hi := m.u8(JoeyMem.CMD + 5)
	var step := cmd_step()
	if step == 0:
		var za := _jl_zone(a_lo, a_hi)
		if (m.u32(za) & 0xfff) == 0:
			cmd_finish()
			return 0
		var zb := _jl_zone(b_lo, b_hi)
		if (m.u32(zb) & 0xfff) == 0:
			cmd_finish()
			return 0
		var tmp := m.local(0x90)
		f5bde10(tmp, zb, 0x90)
		f5bde10(zb, za, 0x90)
		f5bde10(za, tmp, 0x90)
		m.set_u32(za + JoeyMem.Z_STATUS, m.u32(za + JoeyMem.Z_STATUS) & 0xfffdffff)
		var status_b := m.u32(zb + JoeyMem.Z_STATUS) & 0xfffdffff
		m.set_u32(zb + JoeyMem.Z_STATUS, status_b)
		# Rotacion de referencias a -> ranura temporal (b_lo + 2) -> b -> a. El primer argumento
		# lleva en su mitad alta la del estado de b (56b360 la descarta).
		var x := (status_b & 0xffff0000) | (a_hi << 8) | a_lo
		var y := (b_hi << 8) | ((b_lo + 2) & 0xff)
		var z := (b_hi << 8) | b_lo
		f56b360(x, y)
		f56b360(z, x)
		f56b360(y, z)
		var entry_b := m.u32(zb)
		var moved := m.u32(_JL_MOVED)
		var entry_a := m.u32(za)
		m.set_u32(za, entry_a & 0xfffff000)
		var keep_b := m.u32(zb)
		m.set_u16(JoeyMem.CMD + 6, entry_a & 0xfff)
		m.set_u32(_JL_MOVED, moved ^ ((entry_b ^ moved) & 0xfff))
		m.set_u32(zb, keep_b & 0xfffff000)
	elif step == 1:
		var from := m.local(4)
		var to := m.local(4)
		m.set_u16(from, ((((m.u8(_jl_zone(a_lo, a_hi) + JoeyMem.Z_FLAGS) << 8) | a_hi) << 6) | (a_lo & 1)) & 0xffff)
		m.set_u16(to, ((((m.u8(_jl_zone(b_lo, b_hi) + JoeyMem.Z_FLAGS) << 8) | b_hi) << 6) | (b_lo & 1)) & 0xffff)
		f40ced0(from, to)
	else:
		if step == 2:
			var za := _jl_zone(a_lo, a_hi)
			m.set_u32(za, (cmd_c() & 0xfff) | (m.u32(za) & 0xfffff000))
			var zb := _jl_zone(b_lo, b_hi)
			var e := m.u32(zb)
			m.set_u32(zb, ((e ^ m.u32(_JL_MOVED)) & 0xfff) ^ e)
		cmd_finish()
		return 0
	cmd_advance()
	return 0


## Joey 5b9470 caso 0x5c (opcodes 86, codigo en 571bc0): anade el vinculo (a, c) a la zona b
## (56ab60).
func _c5b9470_5c() -> int:
	f56ab60(cmd_b(), cmd_a(), cmd_c())
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x5d (opcodes 87, codigo en 571c40): quita de la zona b el vinculo de
## referencia a: tipos 3/0xb-0xd (56aca0) si c & 0xff es 3 o esta fuera de 1-8, y el resto
## (56abe0) en otro caso; todos los que coincidan si c >> 8 es 0.
func _c5b9470_5d() -> int:
	var c := cmd_c()
	var all := 1 if (c >> 8) == 0 else 0
	var kind := c & 0xff
	if kind >= 1 and kind <= 8 and kind != 3:
		f56abe0(cmd_b(), cmd_a(), all)
	else:
		f56aca0(cmd_b(), cmd_a(), all)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x5e (opcodes 88, codigo en 571cd0): contador +8 de la zona a & 0xff de p:
## le suma b si c no es 0 o lo fija a b si c es 0.
func _c5b9470_5e() -> int:
	var at := _jl_zone(cmd_p(), cmd_a() & 0xff) + JoeyMem.Z_COUNTER
	if cmd_c() != 0:
		m.set_u16(at, m.u16(at) + cmd_b())
	else:
		m.set_u16(at, cmd_b())
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x5f (opcodes 8a, codigo en 571d70): si la zona a de p tiene carta, pone
## (b & 0xf) en los bits 2-5 de sus banderas.
func _c5b9470_5f() -> int:
	var at := _jl_zone(cmd_p(), cmd_a())
	if (m.u32(at) & 0xfff) != 0:
		var flags := m.u16(at + JoeyMem.Z_FLAGS)
		m.set_u16(at + JoeyMem.Z_FLAGS, ((cmd_b() & 0xf) << 2) | (flags & 0xffc3))
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x61 (opcodes 8d, codigo en 571de0): vacia los vinculos (+0xa) de la zona a
## de p.
func _c5b9470_61() -> int:
	return _jl_clear_links()


## Joey 5b9470 caso 0x6b (opcodes a2, codigo en 571de0, el mismo que 0x61): vacia los vinculos
## de la zona a de p.
func _c5b9470_6b() -> int:
	return _jl_clear_links()


func _jl_clear_links() -> int:
	m.set_u16(_jl_zone(cmd_p(), cmd_a()) + JoeyMem.Z_LINKS_N, 0)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x66 (opcodes 92, codigo en 573c30): marca la zona a de p (bit 14 de la
## entrada si b & 1; estado | 8 si b & 4 y | 0x10000 si no; bit 1 del estado con 570710) y, en
## las fases 6-7 del turno de p, quita el bit a de la mascara +0x10 del jugador.
func _c5b9470_66() -> int:
	var p := cmd_p()
	var a := cmd_a()
	var at := _jl_zone(p, a)
	if (m.u8(JoeyMem.CMD + 4) & 1) != 0:
		m.set_u32(at, m.u32(at) | 0x4000)
	var status := m.u32(at + JoeyMem.Z_STATUS)
	if (m.u8(JoeyMem.CMD + 4) & 4) != 0:
		status |= 8
	else:
		status |= 0x10000
	m.set_u32(at + JoeyMem.Z_STATUS, status)
	f570710(p, a, 1, 0)
	var turn := m.u8(JoeyMem.TURN)
	if (turn & 0xe) == 6 and p == (turn & 1):
		var mask_at := JoeyMem.PLAYER + 0x10 + (p & 1) * JoeyMem.PLAYER_SIZE
		m.set_u16(mask_at, m.u16(mask_at) & ~(1 << (a & 0x1f)))
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x67 (opcodes 94, codigo en 573cf0): pone el bit 9 de las banderas (b & 1)
## del objeto de la zona a + c de p; por encima de 10, la carta separada si a57840 la situa en
## (p, a) o el objeto vacio a578f4.
func _c5b9470_67() -> int:
	var p := cmd_p()
	var a := cmd_a()
	var z := cmd_c() + a
	var obj := 0
	if z > 10:
		var battle := m.u32(JoeyMem.BATTLE) & 0xffff
		if p == (battle & 1) and a == ((battle >> 8) & 7):
			obj = JoeyMem.DETACHED
		else:
			obj = JoeyMem.DETACHED_EMPTY
	else:
		obj = _jl_zone(p, z)
	m.set_u16(obj + JoeyMem.Z_FLAGS, ((cmd_b() & 1) << 9) | (m.u16(obj + JoeyMem.Z_FLAGS) & 0xfdff))
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x6d (opcodes a6, codigo en 573da0): escribe en la zona a & 0xff de p la
## entrada (c << 16 | b) con el indice de la carta b (402460).
func _c5b9470_6d() -> int:
	var local := m.local(4)
	m.set_u32(local, (cmd_c() << 16) | cmd_b())
	var at := _jl_zone(cmd_p(), cmd_a() & 0xff)
	var idx := f402460(cmd_b() & 0xfff)
	m.set_u32(local, (idx & 0xfff) | (m.u32(local) & 0xfffff000))
	f5675c0(at, local)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x6e (opcodes a7, codigo en 573e30): en el paso 0 manda la carta de la zona
## a de p al cementerio (bit 20 de la entrada, 56a650 con b), marca a56430 si es un monstruo
## propio que no es 0x780-0x783 y b es 0, y avisa al buzon 40cdb0; despues termina.
func _c5b9470_6e() -> int:
	var p := cmd_p()
	var a := cmd_a()
	var b := cmd_b()
	if cmd_step() != 0:
		cmd_finish()
		return 0
	var entry := f5700f0(p, a, 0)
	m.set_u32(entry, (m.u32(entry) & 0xfff7ffff) | 0x100000)
	var at := _jl_zone(p, a)
	if p == ((m.u32(at) >> 0xc) & 1) and a < 5:
		var card_id := f4022e0(m.u16(at) & 0xfff) & 0xffff
		if card_id < 0x780 or (f4022e0(m.u16(at) & 0xfff) & 0xffff) > 0x783:
			if b == 0:
				var flag_at := 0xa56430 + (p & 1) * JoeyMem.PLAYER_SIZE
				m.set_u32(flag_at, m.u32(flag_at) | 0x1000000)
	f5675c0(_JL_MOVED, at)
	f56a650(p, a, b)
	var moved := m.u32(_JL_MOVED)
	var from := m.local(4)
	var to := m.local(4)
	m.set_u16(from, ((((m.u8(at + JoeyMem.Z_FLAGS) << 8) | (a & 0xff)) << 6) | (p & 1)) & 0xffff)
	m.set_u16(to, (((((1 if b != 0 else 0) + 0xe) & 0x1f) | 0xc020) << 1) | ((moved >> 0xc) & 1))
	f40cdb0(moved & 0xfff, from, to)
	cmd_advance()
	return 0


## Joey 5b9470 caso 0x71 (opcodes b0, codigo en 573bd0): salvo en el turno remoto (bit 4 de
## a577fa con distinto jugador que a54e5c), si la cadena a55c80 tiene mas de un eslabon marca el
## ultimo con el bit 2 (y el 3 si a no es 0).
func _c5b9470_71() -> int:
	var turn := m.u8(JoeyMem.TURN)
	if (turn & 0x10) == 0 or ((m.u8(JoeyMem.MODE) ^ turn) & 1) == 0:
		var n := m.u16(0xa55c80)
		if n > 1:
			var at := 0xa55b1c + n * 20
			m.set_u8(at, m.u8(at) | 4)
			if cmd_a() != 0:
				m.set_u16(at, m.u16(at) | 8)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x75 (opcodes c0, codigo en 5732d0): saca la carta a de la mano de p (paso
## 1, buzon 40cdb0 hacia 0x5c) y la manda al cementerio con 56c590 (paso 2), con las banderas de
## c (0x20 cara abajo, 1 bit 22). Con b = 0 no hace nada y el comando no termina.
func _c5b9470_75() -> int:
	return _jl_hand_to_grave(cmd_c())


## Joey 5b9470 caso 0x7e (opcodes cc, codigo en 573bb0): c = 0x20 y el caso 0x75.
func _c5b9470_7e() -> int:
	m.set_u16(JoeyMem.CMD + 6, 0x20)
	return _jl_hand_to_grave(cmd_c())


func _jl_hand_to_grave(c: int) -> int:
	var p := cmd_p()
	var a := cmd_a()
	if cmd_b() == 0:
		return 0
	var step := cmd_step()
	if step == 0:
		cmd_advance()
		return 0
	if step == 1:
		_jl_send_hand(p, a, 0x805c)
		return 0
	if step == 2:
		f56d190(p)
		var moved := m.u32(_JL_MOVED)
		if (c & 0x20) != 0:
			moved = (moved & 0xfff7ffff) | 0x100000
			m.set_u32(_JL_MOVED, moved)
		if (c & 1) != 0:
			m.set_u32(_JL_MOVED, moved | 0x400000)
		f56c590(_JL_MOVED)
	cmd_finish()
	return 0


## Paso 1 comun de 0x75/0x76: la entrada a de la mano de p pasa a a558b0 y se vacia; buzon
## 40cdb0 de (a << 6 | p | 0x8016) a (to | dueno).
func _jl_send_hand(p: int, a: int, to_base: int) -> void:
	var hand := _jl_hand(p, a)
	f5675c0(_JL_MOVED, hand)
	m.set_u32(hand, m.u32(hand) & 0xfffff000)
	var moved := m.u32(_JL_MOVED)
	var from := m.local(4)
	var to := m.local(4)
	m.set_u16(from, ((a & 0xff) << 6) | (p & 1) | 0x8016)
	m.set_u16(to, ((moved >> 0xc) & 1) | to_base)
	f40cdb0(moved & 0xfff, from, to)
	cmd_advance()


## Joey 5b9470 caso 0x76 (opcodes c1, codigo en 573430): saca la carta a de la mano de p (paso
## 1, buzon 40cdb0 hacia 0x5e) y, cuando 44ba10 no esta ocupado, la retira con 56d190 y 56c640
## (paso 2) con las banderas de c (0x10, 0x20, 1). Con b = 0 o del paso 3 en adelante no hace
## nada y el comando no termina.
func _c5b9470_76() -> int:
	return _jl_hand_to_banish(cmd_c())


## Joey 5b9470 caso 0x7f (opcodes cd, codigo en 573bc0): c = 0x20 y el caso 0x76.
func _c5b9470_7f() -> int:
	m.set_u16(JoeyMem.CMD + 6, 0x20)
	return _jl_hand_to_banish(cmd_c())


func _jl_hand_to_banish(c: int) -> int:
	var p := cmd_p()
	var a := cmd_a()
	if cmd_b() == 0:
		return 0
	var step := cmd_step()
	if step == 0:
		cmd_advance()
		return 0
	if step == 1:
		_jl_send_hand(p, a, 0x805e)
		return 0
	if step != 2 or f44ba10() != 0:
		return 0
	if cmd_b() != 0:
		f56d190(p)
	var moved := m.u32(_JL_MOVED)
	if (c & 0x10) != 0:
		moved = (moved & 0xffefffff) | 0x80000
		m.set_u32(_JL_MOVED, moved)
	if (c & 0x20) != 0:
		moved = (moved & 0xfff7ffff) | 0x100000
		m.set_u32(_JL_MOVED, moved)
	if (c & 1) != 0:
		m.set_u32(_JL_MOVED, moved | 0x400000)
	f56c640(_JL_MOVED, 0)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x77 (opcodes c2, codigo en 573720): 56d010 de p con la entrada
## (b << 16 | a) e indice de la carta a.
func _c5b9470_77() -> int:
	var local := _jl_entry_ab()
	f56d010(cmd_p(), local)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x78 (opcodes c3, codigo en 5735d0): saca la carta a de la mano de p (los
## pasos 0 y 1 en el mismo tick; buzon 40cdb0 hacia 0x1a, con el bit 6 si b es 0) y la coloca
## con 568c00 (b != 0) o 568ca0 (paso 2).
func _c5b9470_78() -> int:
	var p := cmd_p()
	var a := cmd_a()
	var step := cmd_step()
	if step == 0:
		cmd_advance()
		step = 1
	if step == 1:
		var hand := _jl_hand(p, a)
		f5675c0(_JL_MOVED, hand)
		m.set_u32(hand, m.u32(hand) & 0xfffff000)
		var moved := m.u32(_JL_MOVED)
		var from := m.local(4)
		var to := m.local(4)
		m.set_u16(from, ((a & 0xff) << 6) | (p & 1) | 0x8016)
		m.set_u16(to, ((1 if cmd_b() == 0 else 0) << 6) | ((moved >> 0xc) & 1) | 0x1a)
		f40cdb0(moved & 0xfff, from, to)
		cmd_advance()
		return 0
	if step == 2:
		f56d190(p)
		if cmd_b() != 0:
			f568c00((m.u32(_JL_MOVED) >> 0xc) & 1, _JL_MOVED)
		else:
			f568ca0((m.u32(_JL_MOVED) >> 0xc) & 1, _JL_MOVED)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x7c (opcodes c7, codigo en 573800): intercambio de cartas de mano: la b del
## rival pasa a p (56cef0, buzon 40cdb0 de la mano rival a la propia; paso 0) y la recibe con
## 56d010 (paso 1); la a de p pasa al rival (pasos 2 y 3); el paso 4 termina.
func _c5b9470_7c() -> int:
	var p := cmd_p()
	var q := (~p) & 1
	var step := cmd_step()
	if step > 3:
		cmd_finish()
		return 0
	match step:
		0:
			f56cef0(p, _jl_hand(q, cmd_b()))
			_jl_swap_mail(q, cmd_b() & 0xff, p)
		1:
			f56d010(1 - p, _jl_hand(q, cmd_b()))
		2:
			f56cef0(1 - p, _jl_hand(p, cmd_a()))
			_jl_swap_mail(p & 1, cmd_a() & 0xff, q)
		3:
			f56d010(p, _jl_hand(p, cmd_a()))
	cmd_advance()
	return 0


## Buzon 40cdb0(1) de 0x7c: de la posicion `pos` de la mano de `from_p` al final de la mano de
## `to_p` (cuenta u16 +8 mas 0x3ff, ocho bits); ambas palabras pasan por 570420.
func _jl_swap_mail(from_p: int, pos: int, to_p: int) -> void:
	var from := m.local(4)
	var to := m.local(4)
	m.set_u16(from, _jl_with_570420(from_p | 0x16 | (pos << 6)))
	var count := m.u16(JoeyMem.PLAYER + JoeyMem.P_HAND_N + (to_p & 1) * JoeyMem.PLAYER_SIZE)
	var w := (to_p & 1) | 0x16 | ((((count & 0x3ff) + 0x3ff) << 6) & 0x3fc0)
	m.set_u16(to, _jl_with_570420(w))
	f40cdb0(1, from, to)


## Joey 5b9470 caso 0x7d (opcodes cb, codigo en 573790): 56cef0 de p con la entrada
## (b << 16 | a) e indice de la carta a.
func _c5b9470_7d() -> int:
	var local := _jl_entry_ab()
	f56cef0(cmd_p(), local)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x82 (opcodes d0, codigo en 572cd0): busca la carta a de p con 56cac0 (paso 1;
## si no esta, termina), la retira (56c870) con buzon 40cdb0 de 0x5c a 0x1a y la coloca con
## 568c00 tras 5674a0 (paso 2).
func _c5b9470_82() -> int:
	return _jl_place_found(0x1a, true)


## Joey 5b9470 caso 0x83 (opcodes d1, codigo en 572db0): como 0x82 con buzon hacia 0x5a y 568ca0.
func _c5b9470_83() -> int:
	return _jl_place_found(0x5a, false)


func _jl_place_found(to_base: int, face_up: bool) -> int:
	var p := cmd_p()
	var idx := f402460(cmd_a())
	var step := cmd_step()
	if step == 0:
		cmd_advance()
		return 0
	if step == 1:
		if f56cac0(p, idx, _JL_MOVED) != 0:
			f56c870(p, _JL_MOVED)
			var from := m.local(4)
			var to := m.local(4)
			m.set_u16(from, (p & 1) | 0x805c)
			m.set_u16(to, (p & 1) | to_base)
			f40cdb0(m.u32(_JL_MOVED) & 0xfff, from, to)
			cmd_advance()
			return 0
		cmd_finish()
		return 0
	f5674a0(_JL_MOVED)
	if face_up:
		f568c00(p, _JL_MOVED)
	else:
		f568ca0(p, _JL_MOVED)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x84 (opcodes d2, codigo en 572ae0): retira de p la entrada (b << 16 | a)
## (56c870) con buzon 40cdb0 de 0x5c al final de la mano (o a 0x58 si la carta es de clase 2;
## pasos 0 y 1 en el mismo tick) y la anade con 568d10 (clase 2) o 56cef0 tras 5674a0 (paso 2).
func _c5b9470_84() -> int:
	var p := cmd_p()
	var local := _jl_entry_ab()
	var step := cmd_step()
	if step == 0:
		cmd_advance()
		step = 1
	if step == 1:
		f56c870(p, local)
		f5675c0(_JL_MOVED, local)
		var moved := m.u32(_JL_MOVED)
		var from := m.local(4)
		var to := m.local(4)
		m.set_u16(from, (p & 1) | 0x805c)
		var count := m.u8(JoeyMem.PLAYER + JoeyMem.P_HAND_N + (p & 1) * JoeyMem.PLAYER_SIZE)
		var w := ((moved >> 0xc) & 1) | 0x16 | (count << 6)
		w = _jl_with_570420(w)
		if (f402740(m.u32(_JL_MOVED) & 0xfff) & 0xffff) == 2:
			w = (w & 0x4001) | 0x58
		m.set_u16(to, w)
		f40cdb0(m.u32(_JL_MOVED) & 0xfff, from, to)
		cmd_advance()
		return 0
	f5674a0(local)
	if (f402740(m.u32(_JL_MOVED) & 0xfff) & 0xffff) == 2:
		f568d10(p, local)
	else:
		f56cef0(p, local)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x85 (opcodes d3, codigo en 572fb0): retira (56c870) la entrada
## (b << 16 | a) con indice de la carta a, del jugador del bit 12 de a.
func _c5b9470_85() -> int:
	var local := _jl_entry_ab()
	f56c870((m.u32(local) >> 0xc) & 1, local)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x86 (opcodes d4, codigo en 572e90): retira de p la entrada (b << 16 | a)
## (56c870, buzon 40cdb0 de 0x5c a 0x5e; paso 1) y, cuando 44ba10 no esta ocupado, la excluye con
## 56c640 (paso 2). Del paso 3 en adelante no hace nada y el comando no termina.
func _c5b9470_86() -> int:
	var p := cmd_p()
	var local := _jl_entry_ab()
	var step := cmd_step()
	if step == 0:
		cmd_advance()
		return 0
	if step == 1:
		f56c870(p, local)
		f5675c0(_JL_MOVED, local)
		var from := m.local(4)
		var to := m.local(4)
		m.set_u16(from, (p & 1) | 0x805c)
		m.set_u16(to, (p & 1) | 0x805e)
		f40cdb0(m.u32(_JL_MOVED) & 0xfff, from, to)
		cmd_advance()
		return 0
	if step == 2 and f44ba10() == 0:
		f56c640(local, 0)
		cmd_finish()
	return 0


## Joey 5b9470 caso 0x87 (opcodes d6, codigo en 573010): con el paso a 0, cada tick saca la carta
## de arriba del cementerio de p (570790/5708d0 hacia 0xc o 0xd segun 567ad0) con buzon 40cdb0,
## hasta vaciarlo; entonces termina. Con otro paso no hace nada.
func _c5b9470_87() -> int:
	if cmd_step() != 0:
		return 0
	var p := cmd_p()
	var counts := JoeyMem.PLAYER + JoeyMem.P_GRAVE_N + (p & 1) * JoeyMem.PLAYER_SIZE
	var n := m.u16(counts)
	if (n & 0xff) == 0:
		cmd_finish()
		return 0
	f5675c0(_JL_MOVED, f5700f0(p, 0xe, (n & 0xff) - 1))
	var from := m.local(4)
	var to := m.local(4)
	m.set_u16(from, (((((n & 0x3ff) + 0x3ff) << 6) & 0x3fc0) | (p & 1) | 0x1c) | 0x8000)
	var r := f567ad0(m.u32(_JL_MOVED) & 0xfff)
	var w := ((((0xc if r != 0 else 0xd) & 0x1f) << 1) | (p & 1)) & 0xffff
	m.set_u16(to, w)
	f570790(p, 0xe, m.u8(counts) - 1)
	f5708d0(w & 1, (w >> 1) & 0x1f, (w >> 6) & 0xff, _JL_MOVED)
	f40cdb0(m.u32(_JL_MOVED) & 0xfff, from, to)
	return 0


## Joey 5b9470 caso 0x88 (opcodes d7, codigo en 573270): 56c590 de la entrada (b << 16 | a) con
## indice de la carta a.
func _c5b9470_88() -> int:
	f56c590(_jl_entry_ab())
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x8a (opcodes dc, codigo en 572a70): 569200 de p con la entrada
## (b << 16 | a) e indice de la carta a.
func _c5b9470_8a() -> int:
	var local := _jl_entry_ab()
	f569200(cmd_p(), local)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x8b (opcodes dd, codigo en 572780): retira de p la entrada (b << 16 | a) con
## 569200 (paso 1; si no esta, termina; buzon 40cdb0 de 0x18 a 0x1c/0x1e segun c & 1) y, cuando
## 44ba10 no esta ocupado, la manda con 56c640 (c & 1) o 56c590 (paso 2).
func _c5b9470_8b() -> int:
	var p := cmd_p()
	var c1 := cmd_c() & 1
	var local := _jl_entry_ab()
	var step := cmd_step()
	if step == 0:
		cmd_advance()
		return 0
	if step == 1:
		if f569200(p, local) == 0:
			cmd_finish()
			return 0
		f5675c0(_JL_MOVED, local)
		var from := m.local(4)
		var to := m.local(4)
		m.set_u16(from, (p & 1) | 0x8018)
		m.set_u16(to, (((((1 if c1 != 0 else 0) + 0xe) & 0x1f) | 0xc020) << 1) | (p & 1))
		f40cdb0(m.u32(_JL_MOVED) & 0xfff, from, to)
		cmd_advance()
		return 0
	if f44ba10() != 0:
		return 0
	if c1 != 0:
		f56c640(_JL_MOVED, 0)
	else:
		f56c590(_JL_MOVED)
	cmd_finish()
	return 0


## Joey 5b9470 caso 0x8c (opcodes de, codigo en 573170): retira la entrada (b << 16 | a) del
## jugador del bit 12 de a con 56cd20 (paso 1, buzon 40cdb0 de 0x5e a 0x5c) y la manda con 56c590
## (paso 2).
func _c5b9470_8c() -> int:
	var local := _jl_entry_ab()
	var owner := (m.u32(local) >> 0xc) & 1
	var step := cmd_step()
	if step == 0:
		cmd_advance()
		return 0
	if step == 1:
		f56cd20(owner, local)
		f5675c0(_JL_MOVED, local)
		var from := m.local(4)
		var to := m.local(4)
		m.set_u16(from, owner | 0x805e)
		m.set_u16(to, owner | 0x805c)
		f40cdb0(m.u32(_JL_MOVED) & 0xfff, from, to)
		cmd_advance()
		return 0
	f56c590(local)
	cmd_finish()
	return 0
