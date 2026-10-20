class_name JoeyPortF
extends JoeyPortE
## Motor nativo de Joey, etapa 2: despacho de comandos (5b9470). Los casos de manejador saltan
## a su funcion 40xxxx; los 74 sin funcion propia (66 fragmentos en 570cf0-5743ef y 8 en linea
## dentro de 5b9470) son metodos _c5b9470_XX que portan los lotes siguientes. La tabla de casos
## es la de bytes 5b9aec del ejecutable (opcode - 1 -> caso). Cotejo: joey_specs/port_f.py.

## Caso de cada opcode (1-0x100): bytes de 5b9aec.
const _DISPATCH_CASE := [0, 1, 2, 3, 4, 5, 6, 7, 172, 8, 9, 10, 11, 12, 172, 172, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 172, 172, 24, 25, 26, 27, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 28, 29, 30, 31, 32, 33, 172, 34, 35, 36, 37, 38, 39, 172, 172, 172, 40, 41, 42, 43, 172, 172, 172, 172, 172, 172, 172, 172, 172, 44, 172, 172, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 172, 172, 172, 172, 172, 56, 57, 58, 59, 60, 61, 62, 63, 64, 172, 65, 66, 67, 172, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 172, 95, 96, 172, 97, 98, 99, 100, 101, 102, 172, 103, 104, 172, 105, 172, 172, 172, 172, 172, 172, 172, 172, 172, 106, 107, 172, 172, 108, 109, 110, 172, 172, 172, 172, 172, 111, 112, 172, 113, 114, 115, 172, 172, 116, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 117, 118, 119, 120, 121, 122, 123, 124, 172, 172, 172, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 172, 135, 136, 137, 172, 172, 172, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 172, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 172, 172, 170, 171]

## FUN_005b9470: ejecuta un paso del comando en curso (a550a0): opcodes 1-0x100 por su caso;
## el resto, y los casos que caen en el default 5b982a, terminan el comando sin hacer nada.
func f5b9470() -> int:
	var op := m.u32(JoeyMem.CMD)
	m.set_u16(0xa55040, m.u16(0xa55040) & 0xfffe)
	var index := ((op & 0xfff) - 1) & 0xffffffff
	if index > 0xff:
		return _c5b9470_default()
	match _DISPATCH_CASE[index]:
		0x00: _c5b9470_00()  # 01
		0x01: _c5b9470_01()  # 02
		0x02: f4048c0()  # 03
		0x03: f404770()  # 04
		0x04: f409d00()  # 05
		0x05: f409ab0()  # 06
		0x06: f4089c0()  # 07
		0x07: f404460()  # 08
		0x08: f408a40()  # 0a
		0x09: f408ab0()  # 0b
		0x0a: f40b470()  # 0c
		0x0b: f40b4d0()  # 0d
		0x0c: f40b560()  # 0e
		0x0d: f4086c0()  # 11
		0x0e: f40c050()  # 12
		0x0f: f40c050()  # 13
		0x10: f404580()  # 14
		0x11: _c5b9470_11()  # 15
		0x12: _c5b9470_12()  # 16
		0x13: _c5b9470_13()  # 17
		0x14: _c5b9470_14()  # 18
		0x15: _c5b9470_15()  # 19
		0x16: _c5b9470_16()  # 1a
		0x17: _c5b9470_17()  # 1b
		0x18: f40aa40()  # 1e
		0x19: f40ad90()  # 1f
		0x1a: f40ae80()  # 20
		0x1b: f40af10()  # 21
		0x1c: _c5b9470_1c()  # 30
		0x1d: f407a20()  # 31
		0x1e: _c5b9470_1e()  # 32
		0x1f: f407880()  # 33
		0x20: f407960()  # 34
		0x21: _c5b9470_21()  # 35
		0x22: _c5b9470_22()  # 37
		0x23: _c5b9470_23()  # 38
		0x24: _c5b9470_24()  # 39
		0x25: _c5b9470_25()  # 3a
		0x26: _c5b9470_26()  # 3b
		0x27: f405020()  # 3c
		0x28: f408410()  # 40
		0x29: f40c050()  # 41
		0x2a: _c5b9470_2a()  # 42
		0x2b: _c5b9470_2b()  # 43
		0x2c: _c5b9470_2c()  # 4d
		0x2d: _c5b9470_2d()  # 50
		0x2e: _c5b9470_2e()  # 51
		0x2f: _c5b9470_2f()  # 52
		0x30: _c5b9470_30()  # 53
		0x31: _c5b9470_31()  # 54
		0x32: _c5b9470_32()  # 55
		0x33: f407860()  # 56
		0x34: f407a90()  # 57
		0x35: f407ac0()  # 58
		0x36: f407b30()  # 59
		0x37: f407b70()  # 5a
		0x38: f408b90()  # 60
		0x39: _c5b9470_39()  # 61
		0x3a: _c5b9470_3a()  # 62
		0x3b: _c5b9470_3b()  # 63
		0x3c: _c5b9470_3c()  # 64
		0x3d: _c5b9470_3d()  # 65
		0x3e: _c5b9470_3e()  # 66
		0x3f: _c5b9470_3f()  # 67
		0x40: _c5b9470_40()  # 68
		0x41: _c5b9470_41()  # 6a
		0x42: _c5b9470_42()  # 6b
		0x43: _c5b9470_43()  # 6c
		0x44: f407120()  # 6e
		0x45: f4061b0()  # 6f
		0x46: f4063e0()  # 70
		0x47: f4067d0()  # 71
		0x48: f406b20()  # 72
		0x49: f406f70()  # 73
		0x4a: f40c050()  # 74
		0x4b: f407120()  # 75
		0x4c: f407120()  # 76
		0x4d: f4049c0()  # 77
		0x4e: _c5b9470_4e()  # 78
		0x4f: f404b40()  # 79
		0x50: f405620()  # 7a
		0x51: _c5b9470_51()  # 7b
		0x52: f405190()  # 7c
		0x53: _c5b9470_53()  # 7d
		0x54: _c5b9470_54()  # 7e
		0x55: f407c70()  # 7f
		0x56: f407e60()  # 80
		0x57: _c5b9470_57()  # 81
		0x58: _c5b9470_58()  # 82
		0x59: _c5b9470_59()  # 83
		0x5a: f40a0d0()  # 84
		0x5b: _c5b9470_5b()  # 85
		0x5c: _c5b9470_5c()  # 86
		0x5d: _c5b9470_5d()  # 87
		0x5e: _c5b9470_5e()  # 88
		0x5f: _c5b9470_5f()  # 8a
		0x60: f40b270()  # 8b
		0x61: _c5b9470_61()  # 8d
		0x62: f408ee0()  # 8e
		0x63: f409240()  # 8f
		0x64: f409700()  # 90
		0x65: f408030()  # 91
		0x66: _c5b9470_66()  # 92
		0x67: _c5b9470_67()  # 94
		0x68: f4074f0()  # 95
		0x69: f40b370()  # 97
		0x6a: f40c050()  # a1
		0x6b: _c5b9470_6b()  # a2
		0x6c: f40a3c0()  # a5
		0x6d: _c5b9470_6d()  # a6
		0x6e: _c5b9470_6e()  # a7
		0x6f: f407440()  # ad
		0x70: f40afc0()  # ae
		0x71: _c5b9470_71()  # b0
		0x72: f408730()  # b1
		0x73: f40a230()  # b2
		0x74: f408d30()  # b5
		0x75: _c5b9470_75()  # c0
		0x76: _c5b9470_76()  # c1
		0x77: _c5b9470_77()  # c2
		0x78: _c5b9470_78()  # c3
		0x79: f405960()  # c4
		0x7a: f405c60()  # c5
		0x7b: f406060()  # c6
		0x7c: _c5b9470_7c()  # c7
		0x7d: _c5b9470_7d()  # cb
		0x7e: _c5b9470_7e()  # cc
		0x7f: _c5b9470_7f()  # cd
		0x80: f4059c0()  # ce
		0x81: f405cb0()  # cf
		0x82: _c5b9470_82()  # d0
		0x83: _c5b9470_83()  # d1
		0x84: _c5b9470_84()  # d2
		0x85: _c5b9470_85()  # d3
		0x86: _c5b9470_86()  # d4
		0x87: _c5b9470_87()  # d6
		0x88: _c5b9470_88()  # d7
		0x89: f4072b0()  # d8
		0x8a: _c5b9470_8a()  # dc
		0x8b: _c5b9470_8b()  # dd
		0x8c: _c5b9470_8c()  # de
		0x8d: f407160()  # df
		0x8e: f40a7c0()  # e0
		0x8f: f40a900()  # e1
		0x90: f40a690()  # e2
		0x91: f40a690()  # e3
		0x92: f40a6a0()  # e4
		0x93: f409940()  # e5
		0x94: f407be0()  # e6
		0x95: f408210()  # e8
		0x96: f408270()  # e9
		0x97: f408670()  # ea
		0x98: f40b610()  # eb
		0x99: f40b670()  # ec
		0x9a: f40b6c0()  # ed
		0x9b: f40b800()  # ee
		0x9c: f40b850()  # ef
		0x9d: f40b9c0()  # f0
		0x9e: f40ba20()  # f1
		0x9f: f40ba60()  # f2
		0xa0: f40bad0()  # f3
		0xa1: f40bbb0()  # f4
		0xa2: f40be00()  # f5
		0xa3: f40bf30()  # f6
		0xa4: f40bf60()  # f7
		0xa5: f40bfc0()  # f8
		0xa6: f40bff0()  # f9
		0xa7: f40c050()  # fa
		0xa8: f40c090()  # fb
		0xa9: f40c140()  # fc
		0xaa: f40c1b0()  # ff
		0xab: f40c060()  # 100
		0xac: _c5b9470_default()  # 09, 0f, 10, 1c, 1d, 22, 23, 24, 25, 26, 27, 28, 29, 2a, 2b, 2c, 2d, 2e, 2f, 36, 3d, 3e, 3f, 44, 45, 46, 47, 48, 49, 4a, 4b, 4c, 4e, 4f, 5b, 5c, 5d, 5e, 5f, 69, 6d, 89, 8c, 93, 96, 98, 99, 9a, 9b, 9c, 9d, 9e, 9f, a0, a3, a4, a8, a9, aa, ab, ac, af, b3, b4, b6, b7, b8, b9, ba, bb, bc, bd, be, bf, c8, c9, ca, d5, d9, da, db, e7, fd, fe
	return 0


## Comando en curso (a550a0): jugador (bit 15 del opcode) y argumentos a, b, c.
func cmd_p() -> int:
	return m.u16(JoeyMem.CMD) >> 15


func cmd_a() -> int:
	return m.u16(JoeyMem.CMD + 2)


func cmd_b() -> int:
	return m.u16(JoeyMem.CMD + 4)


func cmd_c() -> int:
	return m.u16(JoeyMem.CMD + 6)


## Paso del manejador: bits 0-6 de a558ac.
func cmd_step() -> int:
	return m.u32(JoeyMem.CMD_STATE) & 0x7f


## Paso siguiente: s ^ ((s + 1 ^ s) & 0x7f), tras aplicar `mask` (0xffffc07f borra el contador).
func cmd_advance(mask: int = 0xffffffff) -> void:
	var s := m.u32(JoeyMem.CMD_STATE) & mask
	m.set_u32(JoeyMem.CMD_STATE, s ^ (((s + 1) ^ s) & 0x7f))


## Fin del comando: borra el bit 0x4000 de a558ac.
func cmd_finish() -> void:
	m.set_u32(JoeyMem.CMD_STATE, m.u32(JoeyMem.CMD_STATE) & 0xffffbfff)


## Contador propio de ticks (bits 7-13 de a558ac): suma 0x80 y devuelve a558ac entero.
func cmd_tick() -> int:
	var s := m.u32(JoeyMem.CMD_STATE)
	s ^= (((s & 0xffffff80) + 0x80) ^ s) & 0x3f80
	m.set_u32(JoeyMem.CMD_STATE, s)
	return s


## Campo de un objeto visual (41cf60/41cee0/418b50). Sin objeto (0) se lee como pagina a cero,
## igual que el oraculo; la rama con objeto la cotejaran las trazas Frida.
func obj_u32(obj: int, offset: int) -> int:
	if obj == 0:
		return 0
	return m.u32(obj + offset)


## 5b982a: default del despacho: el comando termina sin hacer nada.
func _c5b9470_default() -> int:
	m.set_u32(JoeyMem.CMD_STATE, m.u32(JoeyMem.CMD_STATE) & 0xffffbfff)
	return 0


## 5b9470 caso 0x00 (opcodes 01): codigo en 5740e0 (sin funcion propia).
func _c5b9470_00() -> int:
	return _unported(0x5740e0)


## 5b9470 caso 0x01 (opcodes 02): codigo en 574230 (sin funcion propia).
func _c5b9470_01() -> int:
	return _unported(0x574230)


## 5b9470 caso 0x11 (opcodes 15): codigo en 574020 (sin funcion propia).
func _c5b9470_11() -> int:
	return _unported(0x574020)


## 5b9470 caso 0x12 (opcodes 16): codigo en 574020 (sin funcion propia).
func _c5b9470_12() -> int:
	return _unported(0x574020)


## 5b9470 caso 0x13 (opcodes 17): codigo en 574020 (sin funcion propia).
func _c5b9470_13() -> int:
	return _unported(0x574020)


## 5b9470 caso 0x14 (opcodes 18): codigo en 574020 (sin funcion propia).
func _c5b9470_14() -> int:
	return _unported(0x574020)


## 5b9470 caso 0x15 (opcodes 19): codigo en 574020 (sin funcion propia).
func _c5b9470_15() -> int:
	return _unported(0x574020)


## 5b9470 caso 0x16 (opcodes 1a): codigo en 574020 (sin funcion propia).
func _c5b9470_16() -> int:
	return _unported(0x574020)


## 5b9470 caso 0x17 (opcodes 1b): codigo en 574020 (sin funcion propia).
func _c5b9470_17() -> int:
	return _unported(0x574020)


## 5b9470 caso 0x1c (opcodes 30): codigo en 570dd0 (sin funcion propia).
func _c5b9470_1c() -> int:
	return _unported(0x570dd0)


## 5b9470 caso 0x1e (opcodes 32): codigo en 570cf0 (sin funcion propia).
func _c5b9470_1e() -> int:
	return _unported(0x570cf0)


## 5b9470 caso 0x21 (opcodes 35): codigo en 570da0 (sin funcion propia).
func _c5b9470_21() -> int:
	return _unported(0x570da0)


## 5b9470 caso 0x22 (opcodes 37): codigo en 570df0 (sin funcion propia).
func _c5b9470_22() -> int:
	return _unported(0x570df0)


## 5b9470 caso 0x23 (opcodes 38): codigo en 570e90 (sin funcion propia).
func _c5b9470_23() -> int:
	return _unported(0x570e90)


## 5b9470 caso 0x24 (opcodes 39): codigo en 570ee0 (sin funcion propia).
func _c5b9470_24() -> int:
	return _unported(0x570ee0)


## 5b9470 caso 0x25 (opcodes 3a): codigo en 570f20 (sin funcion propia).
func _c5b9470_25() -> int:
	return _unported(0x570f20)


## 5b9470 caso 0x26 (opcodes 3b): codigo en 570f40 (sin funcion propia).
func _c5b9470_26() -> int:
	return _unported(0x570f40)


## 5b9470 caso 0x2a (opcodes 42): codigo en 5b9570 (sin funcion propia).
func _c5b9470_2a() -> int:
	return _unported(0x5b9570)


## 5b9470 caso 0x2b (opcodes 43): codigo en 5b957b (sin funcion propia).
func _c5b9470_2b() -> int:
	return _unported(0x5b957b)


## 5b9470 caso 0x2c (opcodes 4d): codigo en 571bf0 (sin funcion propia).
func _c5b9470_2c() -> int:
	return _unported(0x571bf0)


## 5b9470 caso 0x2d (opcodes 50): codigo en 5b958b (sin funcion propia).
func _c5b9470_2d() -> int:
	return _unported(0x5b958b)


## 5b9470 caso 0x2e (opcodes 51): codigo en 5b9596 (sin funcion propia).
func _c5b9470_2e() -> int:
	return _unported(0x5b9596)


## 5b9470 caso 0x2f (opcodes 52): codigo en 5b95a1 (sin funcion propia).
func _c5b9470_2f() -> int:
	return _unported(0x5b95a1)


## 5b9470 caso 0x30 (opcodes 53): codigo en 5b95ac (sin funcion propia).
func _c5b9470_30() -> int:
	return _unported(0x5b95ac)


## 5b9470 caso 0x31 (opcodes 54): codigo en 5b95b7 (sin funcion propia).
func _c5b9470_31() -> int:
	return _unported(0x5b95b7)


## 5b9470 caso 0x32 (opcodes 55): codigo en 5b95c2 (sin funcion propia).
func _c5b9470_32() -> int:
	return _unported(0x5b95c2)


## 5b9470 caso 0x39 (opcodes 61): codigo en 571e30 (sin funcion propia).
func _c5b9470_39() -> int:
	return _unported(0x571e30)


## 5b9470 caso 0x3a (opcodes 62): codigo en 571fc0 (sin funcion propia).
func _c5b9470_3a() -> int:
	return _unported(0x571fc0)


## 5b9470 caso 0x3b (opcodes 63): codigo en 572140 (sin funcion propia).
func _c5b9470_3b() -> int:
	return _unported(0x572140)


## 5b9470 caso 0x3c (opcodes 64): codigo en 572270 (sin funcion propia).
func _c5b9470_3c() -> int:
	return _unported(0x572270)


## 5b9470 caso 0x3d (opcodes 65): codigo en 572410 (sin funcion propia).
func _c5b9470_3d() -> int:
	return _unported(0x572410)


## 5b9470 caso 0x3e (opcodes 66): codigo en 572480 (sin funcion propia).
func _c5b9470_3e() -> int:
	return _unported(0x572480)


## 5b9470 caso 0x3f (opcodes 67): codigo en 5725f0 (sin funcion propia).
func _c5b9470_3f() -> int:
	return _unported(0x5725f0)


## 5b9470 caso 0x40 (opcodes 68): codigo en 572770 (sin funcion propia).
func _c5b9470_40() -> int:
	return _unported(0x572770)


## 5b9470 caso 0x41 (opcodes 6a): codigo en 572900 (sin funcion propia).
func _c5b9470_41() -> int:
	return _unported(0x572900)


## 5b9470 caso 0x42 (opcodes 6b): codigo en 572980 (sin funcion propia).
func _c5b9470_42() -> int:
	return _unported(0x572980)


## 5b9470 caso 0x43 (opcodes 6c): codigo en 5729e0 (sin funcion propia).
func _c5b9470_43() -> int:
	return _unported(0x5729e0)


## 5b9470 caso 0x4e (opcodes 78): codigo en 570fb0 (sin funcion propia).
func _c5b9470_4e() -> int:
	return _unported(0x570fb0)


## 5b9470 caso 0x51 (opcodes 7b): codigo en 5710f0 (sin funcion propia).
func _c5b9470_51() -> int:
	return _unported(0x5710f0)


## 5b9470 caso 0x53 (opcodes 7d): codigo en 571010 (sin funcion propia).
func _c5b9470_53() -> int:
	return _unported(0x571010)


## 5b9470 caso 0x54 (opcodes 7e): codigo en 571080 (sin funcion propia).
func _c5b9470_54() -> int:
	return _unported(0x571080)


## 5b9470 caso 0x57 (opcodes 81): codigo en 571250 (sin funcion propia).
func _c5b9470_57() -> int:
	return _unported(0x571250)


## 5b9470 caso 0x58 (opcodes 82): codigo en 571490 (sin funcion propia).
func _c5b9470_58() -> int:
	return _unported(0x571490)


## 5b9470 caso 0x59 (opcodes 83): codigo en 571670 (sin funcion propia).
func _c5b9470_59() -> int:
	return _unported(0x571670)


## 5b9470 caso 0x5b (opcodes 85): codigo en 5718c0 (sin funcion propia).
func _c5b9470_5b() -> int:
	return _unported(0x5718c0)


## 5b9470 caso 0x5c (opcodes 86): codigo en 571bc0 (sin funcion propia).
func _c5b9470_5c() -> int:
	return _unported(0x571bc0)


## 5b9470 caso 0x5d (opcodes 87): codigo en 571c40 (sin funcion propia).
func _c5b9470_5d() -> int:
	return _unported(0x571c40)


## 5b9470 caso 0x5e (opcodes 88): codigo en 571cd0 (sin funcion propia).
func _c5b9470_5e() -> int:
	return _unported(0x571cd0)


## 5b9470 caso 0x5f (opcodes 8a): codigo en 571d70 (sin funcion propia).
func _c5b9470_5f() -> int:
	return _unported(0x571d70)


## 5b9470 caso 0x61 (opcodes 8d): codigo en 571de0 (sin funcion propia).
func _c5b9470_61() -> int:
	return _unported(0x571de0)


## 5b9470 caso 0x66 (opcodes 92): codigo en 573c30 (sin funcion propia).
func _c5b9470_66() -> int:
	return _unported(0x573c30)


## 5b9470 caso 0x67 (opcodes 94): codigo en 573cf0 (sin funcion propia).
func _c5b9470_67() -> int:
	return _unported(0x573cf0)


## 5b9470 caso 0x6b (opcodes a2): codigo en 571de0 (sin funcion propia).
func _c5b9470_6b() -> int:
	return _unported(0x571de0)


## 5b9470 caso 0x6d (opcodes a6): codigo en 573da0 (sin funcion propia).
func _c5b9470_6d() -> int:
	return _unported(0x573da0)


## 5b9470 caso 0x6e (opcodes a7): codigo en 573e30 (sin funcion propia).
func _c5b9470_6e() -> int:
	return _unported(0x573e30)


## 5b9470 caso 0x71 (opcodes b0): codigo en 573bd0 (sin funcion propia).
func _c5b9470_71() -> int:
	return _unported(0x573bd0)


## 5b9470 caso 0x75 (opcodes c0): codigo en 5732d0 (sin funcion propia).
func _c5b9470_75() -> int:
	return _unported(0x5732d0)


## 5b9470 caso 0x76 (opcodes c1): codigo en 573430 (sin funcion propia).
func _c5b9470_76() -> int:
	return _unported(0x573430)


## 5b9470 caso 0x77 (opcodes c2): codigo en 573720 (sin funcion propia).
func _c5b9470_77() -> int:
	return _unported(0x573720)


## 5b9470 caso 0x78 (opcodes c3): codigo en 5735d0 (sin funcion propia).
func _c5b9470_78() -> int:
	return _unported(0x5735d0)


## 5b9470 caso 0x7c (opcodes c7): codigo en 573800 (sin funcion propia).
func _c5b9470_7c() -> int:
	return _unported(0x573800)


## 5b9470 caso 0x7d (opcodes cb): codigo en 573790 (sin funcion propia).
func _c5b9470_7d() -> int:
	return _unported(0x573790)


## 5b9470 caso 0x7e (opcodes cc): codigo en 573bb0 (sin funcion propia).
func _c5b9470_7e() -> int:
	return _unported(0x573bb0)


## 5b9470 caso 0x7f (opcodes cd): codigo en 573bc0 (sin funcion propia).
func _c5b9470_7f() -> int:
	return _unported(0x573bc0)


## 5b9470 caso 0x82 (opcodes d0): codigo en 572cd0 (sin funcion propia).
func _c5b9470_82() -> int:
	return _unported(0x572cd0)


## 5b9470 caso 0x83 (opcodes d1): codigo en 572db0 (sin funcion propia).
func _c5b9470_83() -> int:
	return _unported(0x572db0)


## 5b9470 caso 0x84 (opcodes d2): codigo en 572ae0 (sin funcion propia).
func _c5b9470_84() -> int:
	return _unported(0x572ae0)


## 5b9470 caso 0x85 (opcodes d3): codigo en 572fb0 (sin funcion propia).
func _c5b9470_85() -> int:
	return _unported(0x572fb0)


## 5b9470 caso 0x86 (opcodes d4): codigo en 572e90 (sin funcion propia).
func _c5b9470_86() -> int:
	return _unported(0x572e90)


## 5b9470 caso 0x87 (opcodes d6): codigo en 573010 (sin funcion propia).
func _c5b9470_87() -> int:
	return _unported(0x573010)


## 5b9470 caso 0x88 (opcodes d7): codigo en 573270 (sin funcion propia).
func _c5b9470_88() -> int:
	return _unported(0x573270)


## 5b9470 caso 0x8a (opcodes dc): codigo en 572a70 (sin funcion propia).
func _c5b9470_8a() -> int:
	return _unported(0x572a70)


## 5b9470 caso 0x8b (opcodes dd): codigo en 572780 (sin funcion propia).
func _c5b9470_8b() -> int:
	return _unported(0x572780)


## 5b9470 caso 0x8c (opcodes de): codigo en 573170 (sin funcion propia).
func _c5b9470_8c() -> int:
	return _unported(0x573170)
