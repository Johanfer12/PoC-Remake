class_name DuelPortB
extends DuelPortA
## Modulo del porte del motor de duelo (ver docs/duel/PORTING.md).
## Lote B: consultas y retiradas de cartas del campo (0x542c70-0x543840), lista de efectos
## pendientes (0x53b960), cursor y cuadros de dialogo (0x53f7e0-0x5417e0) y envoltorios de
## interfaz que son solo presentacion (0x42e820-0x465760).


## Entero de 32 bits con signo (para las comparaciones con signo del original).
static func _s32(v: int) -> int:
	v &= 0xffffffff
	return v - 0x100000000 if v >= 0x80000000 else v


# --- Interfaz: listas, cuadros de dialogo, musica, marcadores ---------------------------------

## FUN_0042e820 (thiscall): constructor de la lista de cartas de la interfaz (fusion,
## seleccion, cementerio, excluidas). Solo presentacion: lee el estado para dibujar.
func f42e820(a1: int, kind: int, a3: int) -> int:
	present("card_list", {"a1": a1, "kind": _s32(kind), "a3": a3})
	return 0


## FUN_0042fda0 (thiscall, ECX = cuadro de dialogo): responde al dialogo con `answer`.
## Lo que toca el estado es FUN_00540d80; el resto (campos +0x10/+0x14 del objeto y cierre
## por la llamada virtual +0x28) es de la interfaz.
func f42fda0(answer: int) -> int:
	f540d80(answer)
	return 0


## 431ee0/432050: vtable59a700+8 ->520730 consulta el botón derecho
## mantenido (+0xc), no un modo automático. El constructor responde y deja
## el objeto inactivo al instante, sin los ocho ticks de cierre manual.
var _dialog_constructor_closed := false

func f431ee0(text: int) -> int:
	_dialog_constructor_closed = input_right_held()
	if _dialog_constructor_closed:
		return f42fda0(0)
	present("dialog", {"type": 1, "text": text})
	return 0


func f432050(text: int, n: int, default: int) -> int:
	default = _s32(default)
	_dialog_constructor_closed = default >= 0 and input_right_held()
	if _dialog_constructor_closed:
		return f42fda0(default)
	present("dialog", {"type": n, "text": text, "options": n, "default": default})
	return 0


## FUN_00437530: elige la musica del duelo segun el tipo de partida y la diferencia de LP.
## Solo presentacion (FUN_00583e10 reproduce la pista).
func f437530() -> int:
	var track := 0x20000004
	var diff := m.u16(0xa12698) - m.u16(0xa11944)
	if game_mode == 6:
		track = 0x20000003
	elif diff > 2999:
		track = 0x20000007
	elif diff < -2999:
		track = 0x20000006
	elif game_mode == 1:
		track = 0x20000005
	present("bgm", {"track": track})
	return 0


## FUN_004376e0: envoltorio de FUN_00437530.
func f4376e0() -> int:
	return f437530()


## FUN_00465480: crea el marcador visual (tipo 0) de la zona a2 + a3 del jugador p si no
## existe ya (FUN_00464c30). Solo presentacion.
func f465480(p: int, a2: int, a3: int) -> int:
	present("zone_marker", {"type": 0, "p": p & 1, "zone": a2 + a3})
	return 0


## FUN_00465550: como FUN_00465480 con el marcador de tipo 1 (si ya existe lo reactiva).
## Solo presentacion.
func f465550(p: int, a2: int, a3: int) -> int:
	present("zone_marker", {"type": 1, "p": p & 1, "zone": a2 + a3})
	return 0


## FUN_00465640: marcador visual de la zona z con el valor v (FUN_004652d0). Solo presentacion.
func f465640(p: int, z: int, v: int) -> int:
	present("zone_marker", {"type": 2, "p": p & 1, "zone": z, "value": v & 0x1ff})
	return 0


## FUN_004437a0: pide la ayuda `index` (duel/help/helpNN, motivo por el que la carta senalada no
## puede hacer la accion) guardandola en DAT_005aa1b4 si es < 0xf. La escena la lee y la borra
## cada fotograma (FUN_004437b0).
func f4437a0(index: int) -> int:
	if _s32(index) < 0xf:
		help_index = _s32(index)
	return 0


## FUN_00464d20 -> FUN_00464cd0: apaga todos los marcadores de zona (byte +4 de cada objeto
## de la lista). Solo presentacion.
func f464d20() -> int:
	present("zone_marker_clear", {})
	return 0


## FUN_00465720
func f465720(p: int, z: int) -> int:
	return f465480(p, z, 0)


## FUN_00465740
func f465740(p: int, z: int) -> int:
	return f465550(p, z, 0)


## FUN_00465760
func f465760(p: int, z: int, v: int) -> int:
	return f465640(p, z, v)


# --- Despacho y lista de efectos pendientes --------------------------------------------------

## FUN_0053aca0: despachador de comandos; lo implementa DuelCmds.dispatch().
func f53aca0() -> int:
	dispatch()
	return 0


## FUN_0053b960: anade una entrada de 0x14 bytes a la lista `list` (0 -> 0xa15c00 con
## contador u16 en 0xa15fc2; otra -> 0xa15e80 con contador en 0xa15fc0). Los 16 bits bajos
## de `code` van a +0; los altos se reempaquetan en el u16 +2 (bit 0 jugador, bits 4-9
## zona); `extra` va a +6/+8. Si la zona es del campo (<= 10) pone el bit 0 del byte +0x90
## de la zona. Devuelve lo que el original deja en EAX.
func f53b960(list: int, code: int, extra: int) -> int:
	code &= 0xffffffff
	extra &= 0xffffffff
	if (code & 0xffff) == 0:
		return code
	if (m.u8(0xa16181) & 1) != 0 and (m.u8(0xa133f2) & 1) != 0:
		# Duelo en red en el turno del rival: se envia al otro equipo (FUN_0053ea40).
		var v := (code & 0x7fffffff) if (code & 0x80000000) != 0 else (code | 0x80000000)
		var buf := m.local(12)
		m.set_u16(buf, list)
		m.set_u16(buf + 2, v)
		m.set_u16(buf + 4, v >> 16)
		m.set_u16(buf + 6, extra)
		m.set_u16(buf + 8, extra >> 16)
		return f53ea40(0xf072, buf, 10)
	var e: int
	if list == 0:
		e = 0xa15c00 + m.u16(0xa15fc2) * 0x14
	else:
		e = 0xa15e80 + m.u16(0xa15fc0) * 0x14
	m.set_u8(e + 4, m.u8(e + 4) & 0xe0)
	m.set_u16(e, code)
	m.set_u16(e + 6, extra)
	var packed := ((((((code >> 16) & 0x1f) | ((code >> 25) << 6)) << 3) \
			| ((code >> 21) & 7)) << 1) | ((code >> 31) & 1)
	m.set_u16(e + 2, packed)
	m.set_u16(e + 8, extra >> 16)
	if list == 0:
		m.set_u16(0xa15fc2, m.u16(0xa15fc2) + 1)
	else:
		m.set_u16(0xa15fc0, m.u16(0xa15fc0) + 1)
	var w := m.u16(e + 2)
	if (w & 0x3f0) > 0xa0:
		return w & 0x3f0
	var at := 0xa119ec + (w & 1) * PS + ((w >> 4) & 0x3f) * 0x94
	m.set_u8(at, m.u8(at) | 1)
	return at


## FUN_0053baa0
func f53baa0(code: int, extra: int) -> int:
	f53b960(0, code, extra)
	return 0


# --- Cursor y cuadros de dialogo -------------------------------------------------------------

## FUN_0053f7e0: guarda la posicion del cursor (jugador, ubicacion, indice) en
## 0xa161b0/b4/b8 normalizando las zonas: (0, 10) pasa a (10, 0) y (0, 5-9) a (5, z-5).
## Mover el cursor del raton (FUN_00540bd0 con los argumentos originales) es presentacion.
func f53f7e0(p: int, loc: int, i: int) -> int:
	m.set_u32(0xa161b0, p)
	m.set_u32(0xa161b4, loc)
	m.set_u32(0xa161b8, i)
	if loc == 0:
		if i == 10:
			m.set_u32(0xa161b4, i)
			m.set_u32(0xa161b8, loc)
		elif _s32(i) >= 5:
			m.set_u32(0xa161b8, i - 5)
			m.set_u32(0xa161b4, 5)
	present("cursor", {"p": p, "loc": loc, "i": i})
	return 0


## FUN_005407d0: direccion de la configuracion del duelo.
func f5407d0() -> int:
	return 0xa114a0


## FUN_00540a50
func f540a50() -> int:
	return 1 if (m.u32(f5407d0() + 8) & 0x201) != 0 else 0


## FUN_00540a70
func f540a70() -> int:
	return 1 if (m.u32(f5407d0() + 8) & 0x502) != 0 else 0


## FUN_00540d80: guarda la respuesta del dialogo (u16 en 0xa16178) y lleva el cursor a la
## posicion guardada en 0xa161a4/a8/ac.
func f540d80(answer: int) -> int:
	m.set_u16(0xa16178, answer)
	f53f7e0(m.u32(0xa161a4), m.u32(0xa161a8), m.u32(0xa161ac))
	return 0


## FUN_00540db0 (cada fotograma): si hay un dialogo pedido (byte 0xa0fb08) crea su ventana
## segun el tipo (u32 0xa0fb04, argumento en 0xa0fb00) y borra la peticion. 1 si hay
## diálogo, 0 si no. La ranura activa incluye el cierre animado hasta dialog_gone.
## El constructor puede responder inmediatamente si el botón derecho sigue mantenido.
func f540db0() -> int:
	# Ventana del original abierta y activa (DAT_005af76c + 0x11ec): el bucle espera. La lista
	# de seleccion de FUN_00407580 ocupa la misma ranura.
	if not dialog_open.is_empty() or not list_open.is_empty():
		return 1
	if m.u8(0xa0fb08) == 0:
		return 0
	_dialog_constructor_closed = false
	var kind := m.u32(0xa0fb04)
	var arg := m.u32(0xa0fb00)
	match kind:
		0:
			present("dialog", {"type": 0, "text": _dialog_msg})
		1:
			f431ee0(0)
		2:
			f432050(0, 2, -1)
		3:
			f432050(0, 3, arg)
		4, 5:
			f431ee0(0)
		6:
			present("dialog", {"type": 6, "text": _dialog_msg, "card": arg})
		7, 8:
			present("dialog", {"type": kind, "text": _dialog_msg})
		9:
			present("dialog", {"type": 9, "text": _dialog_msg, "arg": arg})
		_:
			f431ee0(0)
	if _dialog_constructor_closed:
		pass # El constructor ya entregó la respuesta; la ranura queda inactiva.
	elif auto_answer != -1:
		f540d80(scripted_answer())
	else:
		# Todas las ventanas ocupan DAT_005af76c+0x11ec y bloquean el bucle hasta que la escena
		# contesta con answer_dialog() (FUN_0042fda0 -> FUN_00540d80). Tipos: 0 mensaje con OK
		# (431db0), 1 y los no listados Si/No (431ee0, el default del switch), 2/3 N botones
		# sentaku (432050; en el 3 `arg` es la respuesta del clic derecho), 6 posicion
		# (432240: carta en ataque = respuesta 0, en defensa = 1, boca abajo si el bit 16 de
		# `arg` esta puesto), 7 moneda (432400: cara 0 / cruz 1), 8 cartas por descartar
		# (432570: 0xa16101 iconos) y 9 niveles del ritual (4326a0: `arg` estrellas). Los tipos
		# 8 y 9 no tienen botones.
		var t := kind if kind in [0, 2, 3, 6, 7, 8, 9] else 1
		dialog_open = {"type": t, "msg": _dialog_msg, "subs": dialog_subs_for_scene(),
				"buttons": {0: 0, 1: 2, 2: 2, 3: 3, 6: 2, 7: 2}.get(t, 0),
				"default": arg if t == 3 else -1}
		match t:
			4, 5:
				dialog_open["icon_arg"] = arg
			6:
				dialog_open["card"] = arg & 0xffff
				dialog_open["defense_face_down"] = (arg & 0xffff0000) != 0
			8:
				dialog_open["count"] = m.u8(0xa16101)
			9:
				dialog_open["level"] = arg
		present("dialog_open", dialog_open.duplicate())
	m.set_u8(0xa0fb08, 0)
	return 1


## FUN_005417e0: pide un dialogo con el mensaje `msg` (el texto lo forma FUN_005415c0 en la
## cadena global 0x5aa858; eso es presentacion): borra la respuesta (0xa16178-0xa1617d),
## tipo 0 y marca la peticion en 0xa0fb08.
func f5417e0(msg: int) -> int:
	m.set_u8(0xa1617a, 0)
	m.set_u8(0xa1617b, 0)
	m.set_u8(0xa1617c, 0)
	m.set_u8(0xa1617d, 0)
	m.set_u16(0xa16178, 0)
	m.set_u32(0xa0fb04, 0)
	_dialog_msg = msg
	_dialog_subs = []
	present("dialog_text", {"msg": msg})
	m.set_u8(0xa0fb08, 1)
	return 0


# --- Consultas del campo ---------------------------------------------------------------------

## FUN_00542280 (fuera del lote; la usan 0x5437c0 y 0x543840): 1 si la carta es un monstruo
## de clase 2 (de fusion, FUN_00541950).
func f542280(index: int) -> int:
	if ((f401a20(index) >> 0x14) & 0x1f) < 0x15:
		if (f541950(index) & 0xffff) == 2:
			return 1
	return 0


## FUN_00542c70: quita el vinculo i de las listas de la zona (+0x08 y +0x48, longitud +0x88).
func f542c70(p: int, z: int, i: int) -> int:
	var zone := 0xa1195c + (p & 1) * PS + z * 0x94
	i = _s32(i)
	var n := m.u16(zone + 0x88)
	if i < n:
		n = (n - 1) & 0xffff
		m.set_u16(zone + 0x88, n)
		if i < n:
			var at := zone + 8 + i * 2
			while true:
				m.set_u16(at, m.u16(at + 2))
				m.set_u16(at + 0x40, m.u16(at + 0x42))
				i += 1
				at += 2
				if i >= m.u16(zone + 0x88):
					break
	return 0


## FUN_00542f50: monstruos boca arriba de p para los que FUN_00545c40 da card_id.
func f542f50(p: int, card_id: int) -> int:
	var count := 0
	for z in 5:
		if (m.u8(0xa11962 + (p & 1) * PS + z * 0x94) & 2) != 0:
			if (f545c40(p, z) & 0xffff) == (card_id & 0xffff):
				count += 1
	return count


## FUN_00542fb0: 1 si p tiene la carta 0x3ba boca arriba en magia/trampa (zonas 5-9).
func f542fb0(p: int) -> int:
	var zone := 0xa11c40 + (p & 1) * PS
	for z in range(5, 10):
		if (m.u32(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0:
			if s16(f401a70(m.u16(zone) & 0xfff)) == 0x3ba:
				return 1
		zone += 0x94
	return 0


## FUN_00543010: monstruos boca arriba de p con ese id.
func f543010(p: int, card_id: int) -> int:
	var count := 0
	for z in 5:
		var zone := 0xa1195c + (p & 1) * PS + z * 0x94
		if (m.u16(zone) & 0xfff) != 0 and (m.u8(zone + 6) & 2) != 0:
			if s16(f401a70(m.u16(zone) & 0xfff)) == s16(card_id):
				count += 1
	return count


## FUN_00543130: monstruos boca arriba de p con ese id y el bit 0 de las banderas igual a pos.
func f543130(p: int, card_id: int, pos: int) -> int:
	var count := 0
	for z in 5:
		var zone := 0xa1195c + (p & 1) * PS + z * 0x94
		if (m.u32(zone) & 0xfff) != 0 and (m.u16(zone + 6) & 2) != 0 \
				and (m.u16(zone + 6) & 1) == (pos & 0xffff):
			if s16(f401a70(m.u16(zone) & 0xfff)) == s16(card_id):
				count += 1
	return count


## FUN_005431b0: monstruos de p en el campo.
func f5431b0(p: int) -> int:
	var count := 0
	for z in 5:
		if (m.u32(0xa1195c + (p & 1) * PS + z * 0x94) & 0xfff) != 0:
			count += 1
	return count


## FUN_005431f0: monstruos de p; con face_up solo los boca arriba (bit 1) y con not_bit0 solo
## los que tienen el bit 0 de las banderas a 0.
func f5431f0(p: int, face_up: int, not_bit0: int) -> int:
	var count := 0
	for z in 5:
		var zone := 0xa1195c + (p & 1) * PS + z * 0x94
		if (m.u32(zone) & 0xfff) != 0:
			var ok1 := face_up == 0 or (m.u8(zone + 6) & 2) != 0
			var ok2 := not_bit0 == 0 or (m.u8(zone + 6) & 1) == 0
			if ok1 and ok2:
				count += 1
	return count


## FUN_00543260: 1 si la zona de monstruo z de p esta libre: sin carta, sin su bit en el
## byte +0x12 del jugador (bits 0-4) y sin vinculo de tipo 2 a una carta 0x528.
func f543260(p: int, z: int) -> int:
	p &= 1
	var zone := 0xa1195c + p * PS + z * 0x94
	if (m.u32(zone) & 0xfff) != 0:
		return 0
	if ((1 << (z & 0x1f)) & 0xff & m.u8(0xa11956 + p * PS) & 0x1f) != 0:
		return 0
	var i := 0
	if m.u16(zone + 0x88) != 0:
		while true:
			if m.u8(zone + 0x48 + i * 2) == 2:
				var link := m.u16(zone + 8 + i * 2)
				var other := m.u16(DuelMem.zone(link & 1, (link >> 8) & 0xff)) & 0xfff
				if other != 0 and s16(f401a70(other)) == 0x528:
					return 0
			i += 1
			if i >= m.u16(zone + 0x88):
				break
	return 1


## FUN_00543330: zonas de monstruo libres de p (FUN_00543260).
func f543330(p: int) -> int:
	var count := 0
	for z in 5:
		if f543260(p, z) != 0:
			count += 1
	return count


## FUN_00543360: primera zona de monstruo libre de p, o -1.
func f543360(p: int) -> int:
	for z in 5:
		if f543260(p, z) != 0:
			return z
	return -1


## FUN_00543390: 1 si en la zona z de p hay un monstruo y nadie tiene la carta 0x58a boca
## arriba.
func f543390(p: int, z: int) -> int:
	var zone := 0xa1195c + (p & 1) * PS + z * 0x94
	if (m.u16(zone) & 0xfff) != 0:
		if ((f401a20(m.u16(zone) & 0xfff) >> 0x14) & 0x1f) < 0x15:
			if f542f30(0, 0x58a) < 1:
				return 1 if f542f30(1, 0x58a) < 1 else 0
	return 0


## FUN_00543400: monstruos de p que cumplen FUN_00543390 sin contar la zona skip (0 si alguien
## tiene la carta 0x58a boca arriba).
func f543400(p: int, skip: int) -> int:
	if f542f30(0, 0x58a) >= 1:
		return 0
	if f542f30(1, 0x58a) >= 1:
		return 0
	var count := 0
	for z in 5:
		if (m.u16(0xa1195c + (p & 1) * PS + z * 0x94) & 0xfff) != 0 and z != skip:
			if f543390(p, z) != 0:
				count += 1
	return count


## FUN_00543480: cartas de magia/trampa de p (zonas 5-9, y la 10 con with_field). Con
## face_up cuentan las boca arriba y con face_down las boca abajo; sin ninguno, todas.
func f543480(p: int, face_up: int, face_down: int, with_field: int) -> int:
	var count := 0
	var limit := (1 if with_field != 0 else 0) + 10
	var i := 5
	if limit > 5:
		p &= 1
		var z := 5
		while true:
			var zone := 0xa1195c + z * 0x94 + p * PS
			if (m.u32(zone) & 0xfff) != 0:
				var up := (m.u8(zone + 6) & 2) != 0
				var ok := false
				if face_up == 0:
					ok = (not up) if face_down != 0 else true
				elif face_down != 0:
					ok = true
				else:
					ok = up
				if ok:
					count += 1
			i += 1
			z = i & 0xffff
			if z >= limit:
				break
	return count


## FUN_00543520: 1 si la zona z de p esta vacia y su bit (bits 2-11 del u16 +0x10 del
## jugador) esta a 0.
func f543520(p: int, z: int) -> int:
	if (m.u32(0xa1195c + z * 0x94 + (p & 1) * PS) & 0xfff) != 0:
		return 0
	return 1 if ((m.u16(0xa11954 + (p & 1) * PS) >> 2) & 0x3ff & (1 << (z & 0x1f))) == 0 else 0


## FUN_00543570: primera zona de magia/trampa libre de p (5-9), o -1.
func f543570(p: int) -> int:
	for z in range(5, 10):
		if f543520(p, z) != 0:
			return z
	return -1


# --- Retirar cartas del campo ----------------------------------------------------------------

## FUN_00543610: manda la carta de la zona al cementerio (o la excluye con banish) y vacia
## la zona.
func f543610(p: int, z: int, banish: int) -> int:
	var zone := 0xa1195c + (p & 1) * PS + z * 0x94
	if banish != 0:
		f5443a0(zone)
	else:
		f544300(zone)
	f542c40(p, z)
	return 0


## FUN_00543670: borra de las listas de las zonas de monstruo de ambos jugadores los
## vinculos de tipo 1, 2, 5, 7 y 10 que apuntan a la zona (p, z) (u16 = z << 8 | p).
func f543670(p: int, z: int) -> int:
	var link := ((z & 0xff) << 8) | (p & 0xff)
	for pl in 2:
		for zz in 5:
			var zone := 0xa1195c + (pl & 1) * PS + zz * 0x94
			if m.u16(zone + 0x88) == 0:
				continue
			var i := 0
			while true:
				match m.u8(zone + 0x48 + i * 2):
					1, 2, 5, 7, 10:
						if m.u16(zone + 8 + i * 2) == link:
							f542c70(pl, zz, i)
							i -= 1
				i += 1
				if i >= m.u16(zone + 0x88):
					break
	return 0


## FUN_00543740: manda la carta de la zona al cementerio, borra los vinculos a ella y vacia
## la zona.
func f543740(p: int, z: int) -> int:
	f544300(0xa1195c + (p & 1) * PS + z * 0x94)
	f543670(p, z)
	f542c40(p, z)
	return 0


## FUN_00543780: excluye la carta de la zona y vacia la zona.
func f543780(p: int, z: int) -> int:
	f5443a0(0xa1195c + (p & 1) * PS + z * 0x94)
	f542c40(p, z)
	return 0


## FUN_005437c0: devuelve la carta de la zona a la mano de su propietario (las de fusion a
## su mazo de fusion), borra los vinculos a ella y vacia la zona.
func f5437c0(p: int, z: int) -> int:
	var zone := 0xa1195c + (p & 1) * PS + z * 0x94
	if f542280(m.u16(zone) & 0xfff) == 0:
		f544c50((m.u32(zone) >> 12) & 1, zone)
	else:
		f5425e0((m.u32(zone) >> 12) & 1, zone)
	f543670(p, z)
	f542c40(p, z)
	return 0


## FUN_00543840: devuelve la carta de la zona encima del mazo de su propietario (las de
## fusion a su mazo de fusion), borra los vinculos a ella y vacia la zona.
func f543840(p: int, z: int) -> int:
	var zone := 0xa1195c + (p & 1) * PS + z * 0x94
	if f542280(m.u16(zone) & 0xfff) == 0:
		f542520((m.u32(zone) >> 12) & 1, zone)
	else:
		f5425e0((m.u32(zone) >> 12) & 1, zone)
	f543670(p, z)
	f542c40(p, z)
	return 0
