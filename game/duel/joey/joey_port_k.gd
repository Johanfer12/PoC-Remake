class_name JoeyPortK
extends JoeyPortJ
## Motor nativo de Joey, lote K de la etapa 2: casos del despacho 5b9470 sin funcion propia 0x00-0x58 (_c5b9470_XX).
## Cada funcion se llama f<direccion de Joey_Pc.exe> (o _c5b9470_XX para los casos del despacho)
## y sobrescribe su declaracion con la misma aridad. Cotejo: re/scripts/joey_specs/port_k.py.
##
## Cada fragmento es en realidad una funcion completa a la que 5b9470 salta por cola (jmp): no
## hereda registros utiles del despacho (eax = opcode - 1, ecx = caso) y acaba en su propio ret.
## Los locales de pila sin inicializar que el original rellena por campos de bits quedan a cero
## (m.local); todos sus bits basura se enmascaran o sobrescriben antes de usarse.

const _JK_ENTRY := 0xa558b0
const _JK_PHASE_FLAGS := 0xa577ec


func _jk_s() -> int:
	return m.u32(JoeyMem.CMD_STATE)


## a558ac = s sin el bit 0x4000 (fin del comando).
func _jk_finish(s: int) -> void:
	m.set_u32(JoeyMem.CMD_STATE, s & 0xffffbfff)


## a558ac = s con el paso (bits 0-6) incrementado.
func _jk_next(s: int) -> void:
	m.set_u32(JoeyMem.CMD_STATE, s ^ (((s + 1) ^ s) & 0x7f))


## a558ac = s con el paso decrementado.
func _jk_back(s: int) -> void:
	m.set_u32(JoeyMem.CMD_STATE, s ^ (((s - 1) ^ s) & 0x7f))


## Decrementa el contador de ticks (bits 7-13) de a558ac y devuelve el nuevo valor (sin escribir).
func _jk_tick_down() -> int:
	var s := _jk_s()
	return s ^ ((((s & 0xffffff80) - 1) ^ s) & 0x3f80)


## Paso 0 de los comandos con contador: bits 7-13 = a & 0x7f; termina si es 0, si no avanza.
func _jk_load_ticks(s: int, a: int) -> void:
	var v := ((a & 0x7f) << 7) | (s & 0xffffc07f)
	if v & 0x3f80 == 0:
		_jk_finish(v)
	else:
		_jk_next(v)


static func _jk_zone(p: int, z: int) -> int:
	return 0xa55d74 + (p & 1) * JoeyMem.PLAYER_SIZE + z * JoeyMem.ZONE_SIZE


func _jk_u16_local(value: int) -> int:
	var at := m.local(4)
	m.set_u16(at, value & 0xffff)
	return at


## Entrada local (b << 16 | a) con el indice corregido por 402460.
func _jk_entry_local() -> int:
	var at := m.local(4)
	var x := (cmd_b() << 16) | cmd_a()
	m.set_u32(at, x)
	var card := f402460(x & 0xfff) & 0xfff
	m.set_u32(at, card | (x & 0xfffff000))
	return at


## Destino del buzon para una carta que llega a la mano de p: bits 1-5 = 0xb, bits 6-13 = la
## ultima posicion de la mano (contador - 1 sobre 10 bits) y bit 15 de 570420.
func _jk_hand_dest(p: int) -> int:
	var op := (p & 1) | 0x16
	var n := m.u16(JoeyMem.PLAYER + (p & 1) * JoeyMem.PLAYER_SIZE + JoeyMem.P_HAND_N)
	op = ((((n & 0x3ff) + 0x3ff) << 6) & 0x3fc0) ^ (op & 0x803f)
	return _jk_dest_bit15(op & 0xffff)


func _jk_dest_bit15(op: int) -> int:
	var r := f570420(op & 1, (op >> 1) & 0x1f, (op >> 6) & 0xff)
	return ((r << 0xf) | (op & 0x7fff)) & 0xffff


## Joey 5b9470 caso 0x00 (opcodes 01, codigo en 5740e0): si 481210 no esta ocupado, marca el
## bit 1 del byte +7 de los monstruos boca arriba con ciertas cartas y el bit 2 de las
## magias/trampas boca abajo de tipo 0x15 (o 0x16 del jugador, o sin la carta 0x49c).
func _c5b9470_00() -> int:
	var p := cmd_p()
	if f481210() != 0:
		return 0
	for s in 2:
		for z in 5:
			var za := _jk_zone(s, z)
			if m.u8(za + 6) & 2 == 0:
				continue
			var v := f4022e0(m.u16(za) & 0xfff) & 0xffff
			match v:
				0x2e6, 0x243, 0xf, 0x1ac, 0x2da, 0x540, 0x458, 0x536, 0x5e9:
					m.set_u8(za + 7, m.u8(za + 7) | 2)
	for s in 2:
		var any := f5699c0(0x49c)
		for z in range(5, 11):
			var za := _jk_zone(s, z)
			var card := m.u16(za) & 0xfff
			if card == 0 or m.u8(za + 6) & 2 != 0:
				continue
			var v := f4025d0(card) & 0xffff
			if v == 0x15 or (v == 0x16 and (s == p or any == 0)):
				m.set_u8(za + 7, m.u8(za + 7) | 4)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x01 (opcodes 02, codigo en 574230): fin de turno: 403ec0, borra la mitad
## alta del estado +0x8c de las 12 zonas y de a577ec, los bits 21-23 de todas las listas y
## llama a 56aea0.
func _c5b9470_01() -> int:
	f403ec0(cmd_p())
	for s in 2:
		for z in 12:
			var at := _jk_zone(s, z) + JoeyMem.Z_STATUS
			m.set_u32(at, m.u32(at) & 0xffff)
	m.set_u32(_JK_PHASE_FLAGS, m.u32(_JK_PHASE_FLAGS) & 0xffff)
	for s in 2:
		var pl := JoeyMem.PLAYER + (s & 1) * JoeyMem.PLAYER_SIZE
		# (contador u8, lista): mano, mazo, fusion, cementerio, excluidas.
		for spec in [[0x08, JoeyMem.P_HAND], [0x09, JoeyMem.P_DECK], [0x0b, JoeyMem.P_FUSION],
				[0x0a, JoeyMem.P_GRAVE], [0x0c, JoeyMem.P_BANISH]]:
			var i := 0
			while i < m.u8(pl + spec[0]):
				var at: int = pl + spec[1] + i * 4
				m.set_u32(at, m.u32(at) & 0xff1fffff)
				i += 1
	f56aea0()
	_jk_finish(_jk_s())
	return 0


## Bit de a577ec de cada opcode 15-1b (tabla 5740b8).
const _JK_FLAG_BITS := [0x10, 0x11, 0x13, 0x12, 3, 2, 4]


## Opcodes 15-1b (codigo en 574020): pone (a != 0) o quita el bit de a577ec del opcode.
func _jk_flag_bit() -> int:
	var index := ((m.u32(JoeyMem.CMD) & 0xfff) - 0x15) & 0xffffffff
	if index <= 6:
		var bit: int = 1 << _JK_FLAG_BITS[index]
		if m.u16(JoeyMem.CMD + 2) != 0:
			m.set_u32(_JK_PHASE_FLAGS, m.u32(_JK_PHASE_FLAGS) | bit)
		else:
			m.set_u32(_JK_PHASE_FLAGS, m.u32(_JK_PHASE_FLAGS) & ~bit & 0xffffffff)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x11 (opcodes 15, codigo en 574020): bit 0x10 de a577ec segun a.
func _c5b9470_11() -> int:
	return _jk_flag_bit()


## Joey 5b9470 caso 0x12 (opcodes 16, codigo en 574020): bit 0x11 de a577ec segun a.
func _c5b9470_12() -> int:
	return _jk_flag_bit()


## Joey 5b9470 caso 0x13 (opcodes 17, codigo en 574020): bit 0x13 de a577ec segun a.
func _c5b9470_13() -> int:
	return _jk_flag_bit()


## Joey 5b9470 caso 0x14 (opcodes 18, codigo en 574020): bit 0x12 de a577ec segun a.
func _c5b9470_14() -> int:
	return _jk_flag_bit()


## Joey 5b9470 caso 0x15 (opcodes 19, codigo en 574020): bit 3 de a577ec segun a.
func _c5b9470_15() -> int:
	return _jk_flag_bit()


## Joey 5b9470 caso 0x16 (opcodes 1a, codigo en 574020): bit 2 de a577ec segun a.
func _c5b9470_16() -> int:
	return _jk_flag_bit()


## Joey 5b9470 caso 0x17 (opcodes 1b, codigo en 574020): bit 4 de a577ec segun a.
func _c5b9470_17() -> int:
	return _jk_flag_bit()


## Joey 5b9470 caso 0x1c (opcodes 30, codigo en 570dd0): 5b7c50(0) y 5b8210(0).
func _c5b9470_1c() -> int:
	f5b7c50(0)
	f5b8210(0)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x1e (opcodes 32, codigo en 570cf0): en modo 0x80 llama a 413a90; marca el
## bit 1 del byte +7 de los monstruos 0x538 de p, borra el u16 +0x10 de p y llama a 5a0d60.
func _c5b9470_1e() -> int:
	var p := cmd_p()
	if m.u32(JoeyMem.MODE) & 0x180 == 0x80:
		f413a90(p)
	for z in 5:
		var za := _jk_zone(p, z)
		if f4022e0(m.u16(za) & 0xfff) & 0xffff == 0x538:
			m.set_u8(za + 7, m.u8(za + 7) | 2)
	m.set_u16(JoeyMem.PLAYER + (p & 1) * JoeyMem.PLAYER_SIZE + 0x10, 0)
	f5a0d60(0xa55d64, p, 0, 1)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x21 (opcodes 35, codigo en 570da0): 56c180(p, a).
func _c5b9470_21() -> int:
	f56c180(cmd_p(), cmd_a())
	_jk_finish(_jk_s())
	return 0


## a577fa/a577fc: vale con el bit 0x10 de a577fa salvo que su bit 0 difiera del de a54e5c.
func _jk_turn_owned(turn: int) -> bool:
	return turn & 0x10 == 0 or (m.u8(JoeyMem.MODE) ^ turn) & 1 == 0


## Joey 5b9470 caso 0x22 (opcodes 37, codigo en 570df0): si el turno es local, borra el u16 +0xe
## de ambos jugadores, con a quita el vinculo 0x246 de la zona 0xb del jugador del turno y
## pasa a la fase 0xc (paso 0); siempre quita los bits 0-1 de a577ec.
func _c5b9470_22() -> int:
	var turn := m.u8(JoeyMem.TURN)
	var a := cmd_a()
	if _jk_turn_owned(turn):
		m.set_u16(0xa55d6e, 0)
		m.set_u16(0xa56ab2, 0)
		if a != 0:
			var card := f402460(0x246)
			# ecx = 0xb00 | (a577fa & 1): la mitad alta del registro no la mira 56aca0.
			f56aca0(0xb00 | (m.u8(JoeyMem.TURN) & 1), card, 1)
			turn = m.u8(JoeyMem.TURN)
		m.set_u16(JoeyMem.PHASE_STEP, m.u16(JoeyMem.PHASE_STEP) & 0xff00)
		m.set_u16(JoeyMem.TURN, (turn & 0xff) | 0xc00)
	m.set_u32(_JK_PHASE_FLAGS, m.u32(_JK_PHASE_FLAGS) & 0xfffffffc)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x23 (opcodes 38, codigo en 570e90): fase 6 con paso !a & 1 y bit 0 de
## a577ec.
func _c5b9470_23() -> int:
	var cl := (~m.u8(JoeyMem.CMD + 2)) & 1
	var ax := (m.u8(JoeyMem.TURN) & 0xff) | 0x600
	var step := (m.u32(JoeyMem.PHASE_STEP) & 0xff00) ^ cl
	m.set_u16(JoeyMem.TURN, ax)
	m.set_u16(JoeyMem.PHASE_STEP, step)
	m.set_u32(_JK_PHASE_FLAGS, m.u32(_JK_PHASE_FLAGS) | 1)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x24 (opcodes 39, codigo en 570ee0): 5b7c50(0) y fase 9 (paso 0).
func _c5b9470_24() -> int:
	f5b7c50(0)
	var turn := m.u8(JoeyMem.TURN)
	m.set_u16(JoeyMem.PHASE_STEP, m.u16(JoeyMem.PHASE_STEP) & 0xff00)
	m.set_u16(JoeyMem.TURN, turn | 0x900)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x25 (opcodes 3a, codigo en 570f20): bit 5 de a57840.
func _c5b9470_25() -> int:
	m.set_u8(JoeyMem.BATTLE, m.u8(JoeyMem.BATTLE) | 0x20)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x26 (opcodes 3b, codigo en 570f40): si el turno es local pasa a la fase
## 0xb (paso 0); 56c180(p, a) y quita el bit 1 de a577ec.
func _c5b9470_26() -> int:
	var p := cmd_p()
	var a := cmd_a()
	var turn := m.u8(JoeyMem.TURN)
	if _jk_turn_owned(turn):
		m.set_u16(JoeyMem.PHASE_STEP, m.u16(JoeyMem.PHASE_STEP) & 0xff00)
		m.set_u16(JoeyMem.TURN, turn | 0xb00)
	f56c180(p, a)
	m.set_u32(_JK_PHASE_FLAGS, m.u32(_JK_PHASE_FLAGS) & 0xfffffffd)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x2c (opcodes 4d, codigo en 571bf0): reescribe el vinculo a >> 8 de la
## zona a & 0xff de p con (b, c) por 56b1c0.
func _c5b9470_2c() -> int:
	var a := cmd_a()
	f56b1c0(cmd_p() | ((a & 0xff) << 8), (a >> 8) & 0xff, cmd_b(), cmd_c())
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x39 (opcodes 61, codigo en 571e30): roba b cartas del mazo de p: paso 0
## (mazo vacio: bit 0 de +0xd y fin), paso 1 roba la de arriba con 5691d0 y avisa al buzon
## (40cdb0, del mazo a la mano), paso 2 decrementa b en el comando y repite si queda.
func _c5b9470_39() -> int:
	var s := _jk_s()
	var p := cmd_p()
	match s & 0x7f:
		0:
			var s1 := s ^ (((s + 1) ^ s) & 0x7f)
			m.set_u32(JoeyMem.CMD_STATE, s1)
			var pl := JoeyMem.PLAYER + (p & 1) * JoeyMem.PLAYER_SIZE
			if m.u8(pl + 9) != 0:
				return 0
			m.set_u8(pl + 0xd, m.u8(pl + 0xd) | 1)
			_jk_finish(s1)
		1:
			f5675c0(_JK_ENTRY, JoeyMem.PLAYER + (p & 1) * JoeyMem.PLAYER_SIZE + JoeyMem.P_DECK)
			# 5691d0 recibe tambien a, que no usa.
			f5691d0(p)
			var info := _jk_u16_local((p & 1) | 0x1a)
			var op := _jk_hand_dest(p)
			f40cdb0(m.u32(_JK_ENTRY) & 0xfff, info, _jk_u16_local(op))
			_jk_next(_jk_s())
		2:
			var b := (m.u16(JoeyMem.CMD + 4) - 1) & 0xffff
			m.set_u16(JoeyMem.CMD + 4, b)
			if b == 0:
				_jk_finish(s)
			else:
				_jk_back(s)
		_:
			_jk_finish(s)
	return 0


## Joey 5b9470 caso 0x3a (opcodes 62, codigo en 571fc0): saca la carta de arriba del mazo de p
## (con c, bit 22) y la manda al cementerio (b == 0, 56c590) o a excluidas (56c640) a ticks:
## paso 0 carga a ticks, paso 1 extrae y avisa al buzon, paso 2 la mueve y repite.
func _c5b9470_3a() -> int:
	var s := _jk_s()
	var p := cmd_p()
	var a := cmd_a()
	var b := cmd_b()
	var c := cmd_c()
	match s & 0x7f:
		0:
			_jk_load_ticks(s, a)
		1:
			if f569010(p, 0, _JK_ENTRY) == 0:
				_jk_finish(_jk_s())
				return 0
			var v := m.u32(_JK_ENTRY)
			if c != 0:
				v |= 0x400000
				m.set_u32(_JK_ENTRY, v)
			var info := _jk_u16_local((p & 1) | 0x801a)
			var op := (((((int(b != 0) + 0xe) & 0x1f) | 0xc020) << 1) | ((v >> 0xc) & 1)) & 0xffff
			f40cdb0(v & 0xfff, info, _jk_u16_local(op))
			_jk_next(_jk_s())
		2:
			if b != 0:
				f56c640(_JK_ENTRY, 0)
			else:
				f56c590(_JK_ENTRY)
			var v := _jk_tick_down()
			if v & 0x3f80 == 0:
				_jk_next(v)
			else:
				_jk_back(v)
		_:
			_jk_finish(s)
	return 0


## Joey 5b9470 caso 0x3b (opcodes 63, codigo en 572140): como 62 pero siempre a excluidas y
## esperando a 44ba10; al acabar los ticks termina.
func _c5b9470_3b() -> int:
	var s := _jk_s()
	var p := cmd_p()
	match s & 0x7f:
		0:
			_jk_load_ticks(s, m.u8(JoeyMem.CMD + 2))
		1:
			if f569010(p, 0, _JK_ENTRY) == 0:
				_jk_finish(_jk_s())
				return 0
			var info := _jk_u16_local((p & 1) | 0x801a)
			var op := _jk_u16_local((p & 1) | 0x805e)
			f40cdb0(m.u32(_JK_ENTRY) & 0xfff, info, op)
			_jk_next(_jk_s())
		2:
			if f44ba10() != 0:
				return 0
			f56c640(_JK_ENTRY, 0)
			var v := _jk_tick_down()
			if v & 0x3f80 == 0:
				_jk_finish(v)
			else:
				_jk_back(v)
	return 0


## Joey 5b9470 caso 0x3c (opcodes 64, codigo en 572270): saca del mazo la carta (b << 16 | a)
## y la lleva a la mano de p (56cef0), avisando al buzon.
func _c5b9470_3c() -> int:
	var p := cmd_p()
	var x := _jk_entry_local()
	var s := _jk_s()
	match s & 0x7f:
		0:
			_jk_next(s)
		1:
			if f5690d0((m.u32(x) >> 0xc) & 1, x) == 0:
				_jk_finish(_jk_s())
				return 0
			f56cef0(p, x)
			var info := _jk_u16_local((p & 1) | 0x1a)
			var op := _jk_hand_dest(p)
			f40cdb0(m.u32(x) & 0xfff, info, _jk_u16_local(op))
			_jk_next(_jk_s())
		_:
			_jk_finish(s)
	return 0


## Joey 5b9470 caso 0x3d (opcodes 65, codigo en 572410): saca del mazo de p la carta
## (b << 16 | a).
func _c5b9470_3d() -> int:
	var p := cmd_p()
	var x := _jk_entry_local()
	f5690d0(p, x)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x3e (opcodes 66, codigo en 572480): saca del mazo de p la carta
## (b << 16 | a), avisa al buzon (destino zona c) y la coloca en la zona c con 568610.
func _c5b9470_3e() -> int:
	var p := cmd_p()
	var c := cmd_c()
	var x := _jk_entry_local()
	var s := _jk_s()
	match s & 0x7f:
		0:
			_jk_next(s)
		1:
			if f5690d0(p, x) == 0:
				_jk_finish(_jk_s())
				return 0
			f5675c0(_JK_ENTRY, x)
			var bit := p & 1
			var info := _jk_u16_local(bit | 0x801a)
			var base := (c / 5) * 5 if c < 0xa else c
			var op := (((((c % 5) & 0xff) | 0xfe00) << 5 | (base & 0x1f)) << 1 | bit) & 0xffff
			f40cdb0(m.u32(_JK_ENTRY) & 0xfff, info, _jk_u16_local(op))
			_jk_next(_jk_s())
		_:
			f568610(p, c, _JK_ENTRY, 0, 1)
			_jk_finish(_jk_s())
	return 0


## Opcodes 67 y 68 (codigo en 5725f0; 68 entra por 572770 con c = 1 escrito en el comando):
## saca del mazo de p la carta (b << 16 | a), avisa al buzon y, cuando 44ba10 queda libre, la
## manda al cementerio (c & 1 == 0, 56c590) o a excluidas (56c640).
func _jk_deck_out() -> int:
	var c1 := m.u8(JoeyMem.CMD + 6) & 1
	var p := cmd_p()
	var x := _jk_entry_local()
	var s := _jk_s()
	match s & 0x7f:
		0:
			_jk_next(s)
		1:
			if f5690d0(p, x) == 0:
				_jk_finish(_jk_s())
				return 0
			f5675c0(_JK_ENTRY, x)
			var bit := p & 1
			var info := _jk_u16_local(bit | 0x801a)
			var op := (((((int(c1 != 0) + 0xe) & 0x1f) | 0xc020) << 1) | bit) & 0xffff
			f40cdb0(m.u32(_JK_ENTRY) & 0xfff, info, _jk_u16_local(op))
			_jk_next(_jk_s())
		_:
			if f44ba10() != 0:
				return 0
			if c1 != 0:
				f56c640(_JK_ENTRY, 0)
			else:
				f56c590(_JK_ENTRY)
			_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x3f (opcodes 67, codigo en 5725f0): del mazo al cementerio o a excluidas
## segun c & 1.
func _c5b9470_3f() -> int:
	return _jk_deck_out()


## Joey 5b9470 caso 0x40 (opcodes 68, codigo en 572770): escribe c = 1 en el comando y sigue en
## 5725f0 (del mazo a excluidas).
func _c5b9470_40() -> int:
	m.set_u16(JoeyMem.CMD + 6, 1)
	return _jk_deck_out()


## Joey 5b9470 caso 0x41 (opcodes 6a, codigo en 572900): pone la carta (b << 16 | a) en el
## mazo de su propietario (568c00) y 408b20(p).
func _c5b9470_41() -> int:
	var p := cmd_p()
	var x := _jk_entry_local()
	f568c00((m.u32(x) >> 0xc) & 1, x)
	f408b20(p)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x42 (opcodes 6b, codigo en 572980): pone la carta (b << 16 | a) con 568ca0
## para su propietario.
func _c5b9470_42() -> int:
	var x := _jk_entry_local()
	f568ca0((m.u32(x) >> 0xc) & 1, x)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x43 (opcodes 6c, codigo en 5729e0): si la carta de identidad b esta en la
## ubicacion a, la saca del mazo de p, la vuelve a poner (568c00) y 408b20(p).
func _c5b9470_43() -> int:
	var p := cmd_p()
	var a := cmd_a()
	var v := f5687d0(cmd_b()) & 0xffffffff
	var loc := (v >> 8) & 0xff
	if loc == a:
		var at := f5700f0(v & 0xff, loc, v >> 0x10)
		var x := m.local(4)
		m.set_u32(x, m.u32(at))
		f5690d0(p, x)
		f568c00(p, x)
		f408b20(p)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x4e (opcodes 78, codigo en 570fb0): vacia el indice de la zona a de p
## (conserva los bits 12-31 de la entrada).
func _c5b9470_4e() -> int:
	var za := _jk_zone(cmd_p(), cmd_a())
	m.set_u32(za, m.u32(za) & 0xfffff000)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x51 (opcodes 7b, codigo en 5710f0): devuelve al mazo la carta de la zona a
## de p (b = 0x11 / 0x12 fija los bits 19-20 de la entrada), avisando al buzon; espera a 44ba10.
func _c5b9470_51() -> int:
	var s := _jk_s()
	var p := cmd_p()
	var a := cmd_a()
	var b := cmd_b()
	match s & 0x7f:
		0:
			var za := _jk_zone(p, a)
			if m.u32(za) & 0xfff == 0:
				_jk_finish(_jk_s())
				return 0
			if b == 0x11:
				var e := f5700f0(p, a, 0)
				m.set_u32(e, (m.u32(e) & 0xfff7ffff) | 0x100000)
			elif b == 0x12:
				var e := f5700f0(p, a, 0)
				m.set_u32(e, (m.u32(e) & 0xffefffff) | 0x80000)
			f5675c0(_JK_ENTRY, za)
			f56a600(p, a)
			var entry := m.u32(_JK_ENTRY)
			var op := _jk_u16_local(((entry >> 0xc) & 1) | 0x805e)
			var info := _jk_u16_local(((a & 0xff) << 6) | (p & 1))
			f40cdb0(entry & 0xfff, info, op)
			_jk_next(_jk_s())
		1:
			if f44ba10() == 0:
				_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x53 (opcodes 7d, codigo en 571010): manda la carta (b << 16 | a) al
## cementerio con 56c590 si tiene indice.
func _c5b9470_53() -> int:
	var x := _jk_entry_local()
	if m.u32(x) & 0xfff != 0:
		f56c590(x)
	_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x54 (opcodes 7e, codigo en 571080): manda la carta (b << 16 | a) a
## excluidas con 56c640(.., 0) si tiene indice.
func _c5b9470_54() -> int:
	var x := _jk_entry_local()
	if m.u32(x) & 0xfff != 0:
		f56c640(x, 0)
	_jk_finish(_jk_s())
	return 0


## Origen del buzon para la carta de la zona a de p: bits 6-13 = a, bits 14-15 = byte +6.
func _jk_zone_info(p: int, a: int) -> int:
	var flags := m.u8(_jk_zone(p, a) + 6)
	return ((((flags << 8) | (a & 0xff)) << 6) | (p & 1)) & 0xffff


## Paso 0 de 81 y 82: avanza si la zona a de p tiene carta; si no, termina.
func _jk_zone_step0(s: int, p: int, a: int) -> void:
	if m.u32(_jk_zone(p, a)) & 0xfff == 0:
		_jk_finish(s)
	else:
		_jk_next(s)


## Joey 5b9470 caso 0x57 (opcodes 81, codigo en 571250): devuelve a la mano la carta de la zona
## a de p (5674b0, 56a680), avisando al buzon salvo para fichas.
func _c5b9470_57() -> int:
	var s := _jk_s()
	var p := cmd_p()
	var a := cmd_a()
	match s & 0x7f:
		0:
			_jk_zone_step0(s, p, a)
		1:
			f5675c0(_JK_ENTRY, _jk_zone(p, a))
			f5674b0(p, a)
			if not is_token(m.u32(_JK_ENTRY) & 0xfff):
				var entry := m.u32(_JK_ENTRY)
				var info := _jk_u16_local(_jk_zone_info(p, a))
				var op := (entry >> 0xc) & 1
				var r := f567ad0(entry & 0xfff)
				op = (op & 0xffc1) | ((((int(r != 0) + 0xb) & 0x1f) << 1))
				var n: int
				if f567ad0(m.u32(_JK_ENTRY) & 0xfff) != 0:
					n = 1
				else:
					n = m.u8(JoeyMem.PLAYER + ((m.u32(_JK_ENTRY) >> 0xc) & 1) * JoeyMem.PLAYER_SIZE + JoeyMem.P_HAND_N)
				op = (((n & 0xff) << 6) | (op & 0x803f)) & 0xffff
				op = _jk_dest_bit15(op)
				f40cdb0(m.u32(_JK_ENTRY) & 0xfff, info, _jk_u16_local(op))
			_jk_next(_jk_s())
		_:
			f56a680(p, a)
			_jk_finish(_jk_s())
	return 0


## Joey 5b9470 caso 0x58 (opcodes 82, codigo en 571490): devuelve al mazo (o fusion) la carta de
## la zona a de p, avisando al buzon salvo para fichas; al final 5674b0 y 56a700.
func _c5b9470_58() -> int:
	var s := _jk_s()
	var p := cmd_p()
	var a := cmd_a()
	match s & 0x7f:
		0:
			_jk_zone_step0(s, p, a)
		1:
			f5675c0(_JK_ENTRY, _jk_zone(p, a))
			if not is_token(m.u32(_JK_ENTRY) & 0xfff):
				var entry := m.u32(_JK_ENTRY)
				var info := _jk_u16_local(_jk_zone_info(p, a))
				var op := (entry >> 0xc) & 1
				var r := f567ad0(entry & 0xfff)
				op = (op & 0xffc1) | ((((0xc if r != 0 else 0xd) & 0x1f) << 1))
				var r2 := f567ad0(m.u32(_JK_ENTRY) & 0xfff)
				op = ((int(r2 != 0) << 6) | (op & 0x3f)) & 0xffff
				f40cdb0(m.u32(_JK_ENTRY) & 0xfff, info, _jk_u16_local(op))
			_jk_next(_jk_s())
		_:
			f5674b0(p, a)
			f56a700(p, a)
			_jk_finish(_jk_s())
	return 0
