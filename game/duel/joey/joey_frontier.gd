class_name JoeyFrontier
extends JoeyDecl
## GENERADO por re/scripts/joey_frontier.py: no editar a mano. Frontera de presentacion del
## motor nativo de Joey (docs/duel/FRONTERA_JOEY.md): cada funcion emite el evento
## present("XXXXXX") y devuelve el mismo valor fijo que el oraculo da en Unicorn.

## Eventos de presentacion emitidos, en orden: {kind, args}.
var events: Array[Dictionary] = []


func present(kind: String, data: Dictionary = {}) -> void:
	var event := data.duplicate()
	event["kind"] = kind
	events.append(event)


func _frontier(address: int, args: Array, value: int) -> int:
	present("%06x" % address, {"args": args})
	return value


## Proveedor del objeto de texto vacio; JoeyPortZK escribe flag/ptr/len/cap.
func _frontier_empty_text(_out: int, _flag: int) -> void:
	pass


## Dependencias sin portar (DEFERRED), salvo en la prueba del oraculo, que
## activa defer_later para cotejar lo que las rodea; el evento lleva sus argumentos.
var defer_later := false
## Retornos de frontera por caso del oraculo; solo se leen con defer_later.
var deferred_results: Dictionary = {}


func _deferred(address: int, args: Array, value: int) -> int:
	if not defer_later:
		return _unported(address)
	var text := args.map(func(a): return a if a is String else "%x" % (int(a) & 0xffffffff))
	present("%06x(%s)" % [address, ",".join(text)])
	return int(deferred_results.get(address, value))


## Bytes en hexadecimal de un bufer pasado a una diferida (DEFERRED_POINTERS); lo da JoeyBase.
func _deferred_bytes(_address: int, _size: int) -> String:
	return ""


func f402290(a0: int) -> int:
	return _frontier(0x402290, [a0], 0)


func f402560(a0: int) -> int:
	return _frontier(0x402560, [a0], 0)


func f402be0(a0: int, a1: int) -> int:
	return _frontier(0x402be0, [a0, a1], 0)


func f4030f0(a0: int, a1: int) -> int:
	return _frontier(0x4030f0, [a0, a1], 0)


func f403310(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x403310, [a0, a1, a2], 0)


func f403700(a0: int) -> int:
	return _frontier(0x403700, [a0], 0)


func f403770(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x403770, [a0, a1, a2], 0)


func f403800(a0: int, a1: int) -> int:
	return _frontier(0x403800, [a0, a1], 0)


func f403900(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x403900, [a0, a1, a2], 0)


func f403b20(a0: int) -> int:
	return _frontier(0x403b20, [a0], 0)


func f403b70(a0: int) -> int:
	return _frontier(0x403b70, [a0], 0)


func f403bc0(a0: int, a1: int) -> int:
	return _frontier(0x403bc0, [a0, a1], 0)


func f403bf0(a0: int, a1: int) -> int:
	return _frontier(0x403bf0, [a0, a1], 0)


func f403c20(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x403c20, [a0, a1, a2], 0)


func f403c50(a0: int, a1: int) -> int:
	return _frontier(0x403c50, [a0, a1], 0)


func f403c80(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x403c80, [a0, a1, a2], 0)


func f403cb0(a0: int, a1: int) -> int:
	return _frontier(0x403cb0, [a0, a1], 0)


func f403ce0(a0: int, a1: int) -> int:
	return _frontier(0x403ce0, [a0, a1], 0)


func f403d10(a0: int) -> int:
	return _frontier(0x403d10, [a0], 0)


func f403d40(a0: int, a1: int) -> int:
	return _frontier(0x403d40, [a0, a1], 0)


func f403dd0(a0: int) -> int:
	return _frontier(0x403dd0, [a0], 0)


func f403e10(a0: int, a1: int) -> int:
	return _frontier(0x403e10, [a0, a1], 0)


func f403ec0(a0: int) -> int:
	return _frontier(0x403ec0, [a0], 0)


func f403f00(a0: int) -> int:
	return _frontier(0x403f00, [a0], 0)


func f40a0a0(this_: int) -> int:
	return _frontier(0x40a0a0, [this_], 0)


func f40ca70() -> int:
	return _frontier(0x40ca70, [], 0)


func f413a90(a0: int) -> int:
	return _frontier(0x413a90, [a0], 0)


func f413ac0() -> int:
	return _frontier(0x413ac0, [], 0)


func f413ad0() -> int:
	return _frontier(0x413ad0, [], 0)


func f413af0(a0: int) -> int:
	return _frontier(0x413af0, [a0], 0)


func f413b20() -> int:
	return _frontier(0x413b20, [], 0)


func f413b30(a0: int, a1: int) -> int:
	return _frontier(0x413b30, [a0, a1], 0)


func f413b80() -> int:
	return _frontier(0x413b80, [], 0)


func f413ba0(a0: int, a1: int, a2: int, a3: int) -> int:
	return _frontier(0x413ba0, [a0, a1, a2, a3], 0)


func f414a20(this_: int, a0: int) -> int:
	return _frontier(0x414a20, [this_, a0], this_)


func f4166f0(this_: int, a0: int, a1: int, a2: int) -> int:
	return _frontier(0x4166f0, [this_, a0, a1, a2], this_)


func f416a00(this_: int, a0: int, a1: int, a2: int, a3: int) -> int:
	return _frontier(0x416a00, [this_, a0, a1, a2, a3], this_)


func f4189d0(this_: int, a0: int) -> int:
	return _frontier(0x4189d0, [this_, a0], 0)


func f418b50(this_: int, a0: int) -> int:
	return _frontier(0x418b50, [this_, a0], 0)


func f41cea0(a0: int, a1: int) -> int:
	return _frontier(0x41cea0, [a0, a1], 0)


func f41cee0(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x41cee0, [a0, a1, a2], 0)


func f41cf60(a0: int, a1: int) -> int:
	return _frontier(0x41cf60, [a0, a1], 0)


func f41d050(this_: int) -> int:
	return _frontier(0x41d050, [this_], 0)


func f41d0c0(this_: int) -> int:
	return _frontier(0x41d0c0, [this_], 0)


func f41d160(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x41d160, [this_, a0, a1], 0)


func f41d3f0(this_: int, a0: int) -> int:
	return _frontier(0x41d3f0, [this_, a0], 0)


func f41d580(this_: int, a0: int) -> int:
	return _frontier(0x41d580, [this_, a0], 0)


func f41d6c0(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x41d6c0, [this_, a0, a1], 0)


func f41db40(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x41db40, [this_, a0, a1], 0)


func f41df00(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x41df00, [this_, a0, a1], 0)


func f41f530(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x41f530, [a0, a1, a2], 1)


func f41f550(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x41f550, [a0, a1, a2], 0)


func f41f570() -> int:
	return _frontier(0x41f570, [], 0)


func f43a060(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x43a060, [this_, a0, a1], 0)


func f43c550(this_: int, a0: int, a1: int, a2: int) -> int:
	return _frontier(0x43c550, [this_, a0, a1, a2], 0)


func f43c710(this_: int) -> int:
	return _frontier(0x43c710, [this_], 0)


func f43c720(this_: int) -> int:
	return _frontier(0x43c720, [this_], 0)


func f43c730(this_: int, a0: int) -> int:
	return _frontier(0x43c730, [this_, a0], 0)


func f43c750(this_: int) -> int:
	return _frontier(0x43c750, [this_], 0)


func f443e40(a0: int, a1: int) -> int:
	return _frontier(0x443e40, [a0, a1], 0)


func f449740(this_: int, a0: int) -> int:
	return _frontier(0x449740, [this_, a0], 0)


func f449780(a0: int, a1: int) -> int:
	return _frontier(0x449780, [a0, a1], 0)


func f4497b0(a0: int) -> int:
	return _frontier(0x4497b0, [a0], 0)


func f449d50(a0: int) -> int:
	return _frontier(0x449d50, [a0], 0)


func f449df0() -> int:
	return _frontier(0x449df0, [], 0)


func f449e00() -> int:
	return _frontier(0x449e00, [], 0)


func f449e10() -> int:
	return _frontier(0x449e10, [], 0)


func f449e20() -> int:
	return _frontier(0x449e20, [], 1)


func f44ba00() -> int:
	return _frontier(0x44ba00, [], 0)


func f44ba10() -> int:
	return _frontier(0x44ba10, [], 0)


func f44ba70(a0: int) -> int:
	return _frontier(0x44ba70, [a0], 0)


func f44bad0(a0: int) -> int:
	return _frontier(0x44bad0, [a0], 0)


func f44ef40(a0: int) -> int:
	return _frontier(0x44ef40, [a0], 0)


func f44efd0(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x44efd0, [this_, a0, a1], this_)


func f44f630(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x44f630, [this_, a0, a1], this_)


func f44fcc0(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x44fcc0, [this_, a0, a1], this_)


func f450260(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x450260, [this_, a0, a1], this_)


func f450730(this_: int, a0: int) -> int:
	return _frontier(0x450730, [this_, a0], this_)


func f450c30(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x450c30, [this_, a0, a1], this_)


func f4511d0(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x4511d0, [this_, a0, a1], this_)


func f4516a0(this_: int) -> int:
	return _frontier(0x4516a0, [this_], this_)


func f451b80(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x451b80, [this_, a0, a1], this_)


func f4520e0(this_: int, a0: int, a1: int, a2: int, a3: int, a4: int) -> int:
	return _frontier(0x4520e0, [this_, a0, a1, a2, a3, a4], this_)


func f452f20(this_: int, a0: int) -> int:
	return _frontier(0x452f20, [this_, a0], this_)


func f4532c0(this_: int, a0: int) -> int:
	return _frontier(0x4532c0, [this_, a0], this_)


func f453830(this_: int, a0: int) -> int:
	return _frontier(0x453830, [this_, a0], this_)


func f453b60(this_: int) -> int:
	return _frontier(0x453b60, [this_], this_)


func f455d90(this_: int) -> int:
	return _frontier(0x455d90, [this_], this_)


func f456100(this_: int) -> int:
	return _frontier(0x456100, [this_], this_)


func f456490(this_: int, a0: int, a1: int, a2: int) -> int:
	return _frontier(0x456490, [this_, a0, a1, a2], this_)


func f4568c0(this_: int, a0: int) -> int:
	return _frontier(0x4568c0, [this_, a0], this_)


func f4571d0(this_: int, a0: int) -> int:
	return _frontier(0x4571d0, [this_, a0], this_)


func f4580f0(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x4580f0, [this_, a0, a1], this_)


func f458d00(this_: int) -> int:
	return _frontier(0x458d00, [this_], this_)


func f45cf80(this_: int, a0: int) -> int:
	return _frontier(0x45cf80, [this_, a0], 0)


func f479b30() -> int:
	return _frontier(0x479b30, [], 0)


func f47c4d0(this_: int, a0: int) -> int:
	return _frontier(0x47c4d0, [this_, a0], 0)


func f47c4f0(this_: int, a0: int, a1: int, a2: int) -> int:
	return _frontier(0x47c4f0, [this_, a0, a1, a2], 0)


func f47c550(this_: int) -> int:
	return _frontier(0x47c550, [this_], 0)


func f4811f0(a0: int, a1: int) -> int:
	return _frontier(0x4811f0, [a0, a1], 0)


func f481210() -> int:
	return _frontier(0x481210, [], 0)


func f481230(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x481230, [this_, a0, a1], 0)


func f481a10() -> int:
	return _frontier(0x481a10, [], 0)


func f486ca0(a0: int, a1: int) -> int:
	return _frontier(0x486ca0, [a0, a1], 0)


func f486cc0(a0: int, a1: int) -> int:
	return _frontier(0x486cc0, [a0, a1], 0)


func f486ce0(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x486ce0, [a0, a1, a2], 0)


func f486d00(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x486d00, [a0, a1, a2], 0)


func f486d20() -> int:
	return _frontier(0x486d20, [], 0)


func f486d30() -> int:
	return _frontier(0x486d30, [], 0)


func f48c3a0(this_: int, a0: int, a1: int, a2: int, a3: int, a4: int) -> int:
	return _frontier(0x48c3a0, [this_, a0, a1, a2, a3, a4], 0)


func f48cbd0(this_: int, a0: int) -> int:
	return _frontier(0x48cbd0, [this_, a0], 0)


func f48d0f0(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x48d0f0, [this_, a0, a1], 0)


func f48d190(this_: int, a0: int, a1: int) -> int:
	return _frontier(0x48d190, [this_, a0, a1], 0)


func f48d230(this_: int) -> int:
	return _frontier(0x48d230, [this_], 0)


func f48d6a0(this_: int, a0: int) -> int:
	return _frontier(0x48d6a0, [this_, a0], 0)


func f48dd00(a0: int, a1: int) -> int:
	return _frontier(0x48dd00, [a0, a1], 0)


func f48dd20(a0: int) -> int:
	return _frontier(0x48dd20, [a0], 0)


func f547ce0() -> int:
	return _deferred(0x547ce0, [], 0)


func f579a00(a0: int, a1: int) -> int:
	return _deferred(0x579a00, [_deferred_bytes(a0, 20), a1], 0)


func f579bc0(a0: int, a1: int) -> int:
	return _deferred(0x579bc0, [_deferred_bytes(a0, 20), a1], 0)


func f579c40(a0: int, a1: int) -> int:
	return _deferred(0x579c40, [_deferred_bytes(a0, 20), a1], 0)


func f57a470(a0: int, a1: int) -> int:
	return _deferred(0x57a470, [_deferred_bytes(a0, 20), (a1 & 65535)], 0)


func f57a570(a0: int, a1: int) -> int:
	return _deferred(0x57a570, [_deferred_bytes(a0, 20), a1], 0)


func f57a630(a0: int, a1: int) -> int:
	return _deferred(0x57a630, [_deferred_bytes(a0, 20), a1], 0)


func f57a6e0(a0: int, a1: int) -> int:
	return _deferred(0x57a6e0, [_deferred_bytes(a0, 20), a1], 0)


func f57a790(a0: int, a1: int) -> int:
	return _deferred(0x57a790, [_deferred_bytes(a0, 20), a1], 0)


func f57a820(a0: int, a1: int) -> int:
	return _deferred(0x57a820, [_deferred_bytes(a0, 20), a1], 0)


func f57a8a0(a0: int, a1: int) -> int:
	return _deferred(0x57a8a0, [_deferred_bytes(a0, 20), a1], 0)


func f57a930(a0: int, a1: int) -> int:
	return _deferred(0x57a930, [_deferred_bytes(a0, 20), a1], 0)


func f57a9a0(a0: int, a1: int) -> int:
	return _deferred(0x57a9a0, [_deferred_bytes(a0, 20), a1], 0)


func f57aa30(a0: int, a1: int) -> int:
	return _deferred(0x57aa30, [_deferred_bytes(a0, 20), a1], 0)


func f57aaa0(a0: int, a1: int) -> int:
	return _deferred(0x57aaa0, [_deferred_bytes(a0, 20), a1], 0)


func f57ac40(a0: int, a1: int) -> int:
	return _deferred(0x57ac40, [_deferred_bytes(a0, 20), a1], 0)


func f57aca0(a0: int, a1: int) -> int:
	return _deferred(0x57aca0, [_deferred_bytes(a0, 20), a1], 0)


func f57ad50(a0: int, a1: int) -> int:
	return _deferred(0x57ad50, [_deferred_bytes(a0, 20), a1], 0)


func f57ada0(a0: int, a1: int) -> int:
	return _deferred(0x57ada0, [_deferred_bytes(a0, 20), a1], 0)


func f57ae20(a0: int, a1: int) -> int:
	return _deferred(0x57ae20, [_deferred_bytes(a0, 20), a1], 0)


func f57aec0(a0: int, a1: int) -> int:
	return _deferred(0x57aec0, [_deferred_bytes(a0, 20), a1], 0)


func f57af30(a0: int, a1: int) -> int:
	return _deferred(0x57af30, [_deferred_bytes(a0, 20), a1], 0)


func f57b010(a0: int, a1: int) -> int:
	return _deferred(0x57b010, [_deferred_bytes(a0, 20), a1], 0)


func f57b0e0(a0: int, a1: int) -> int:
	return _deferred(0x57b0e0, [_deferred_bytes(a0, 20), a1], 0)


func f57b180(a0: int, a1: int) -> int:
	return _deferred(0x57b180, [_deferred_bytes(a0, 20), a1], 0)


func f57b1f0(a0: int, a1: int) -> int:
	return _deferred(0x57b1f0, [_deferred_bytes(a0, 20), a1], 0)


func f57b270(a0: int, a1: int) -> int:
	return _deferred(0x57b270, [_deferred_bytes(a0, 20), a1], 0)


func f57b2e0(a0: int, a1: int) -> int:
	return _deferred(0x57b2e0, [_deferred_bytes(a0, 20), a1], 0)


func f57b3b0(a0: int, a1: int) -> int:
	return _deferred(0x57b3b0, [_deferred_bytes(a0, 20), a1], 0)


func f57b4d0(a0: int, a1: int) -> int:
	return _deferred(0x57b4d0, [_deferred_bytes(a0, 20), a1], 0)


func f57b530(a0: int, a1: int) -> int:
	return _deferred(0x57b530, [_deferred_bytes(a0, 20), a1], 0)


func f57b5a0(a0: int, a1: int) -> int:
	return _deferred(0x57b5a0, [_deferred_bytes(a0, 20), a1], 0)


func f57b600(a0: int, a1: int) -> int:
	return _deferred(0x57b600, [_deferred_bytes(a0, 20), a1], 0)


func f57b680(a0: int, a1: int) -> int:
	return _deferred(0x57b680, [_deferred_bytes(a0, 20), a1], 0)


func f57b730(a0: int, a1: int) -> int:
	return _deferred(0x57b730, [_deferred_bytes(a0, 20), a1], 0)


func f57b7d0(a0: int, a1: int) -> int:
	return _deferred(0x57b7d0, [_deferred_bytes(a0, 20), a1], 0)


func f57b860(a0: int, a1: int) -> int:
	return _deferred(0x57b860, [_deferred_bytes(a0, 20), a1], 0)


func f57b910(a0: int, a1: int) -> int:
	return _deferred(0x57b910, [_deferred_bytes(a0, 20), a1], 0)


func f57b9a0(a0: int, a1: int) -> int:
	return _deferred(0x57b9a0, [_deferred_bytes(a0, 20), a1], 0)


func f57ba90(a0: int, a1: int) -> int:
	return _deferred(0x57ba90, [_deferred_bytes(a0, 20), a1], 0)


func f57bb20(a0: int, a1: int) -> int:
	return _deferred(0x57bb20, [_deferred_bytes(a0, 20), a1], 0)


func f57bbf0(a0: int, a1: int) -> int:
	return _deferred(0x57bbf0, [_deferred_bytes(a0, 20), a1], 0)


func f57bca0(a0: int, a1: int) -> int:
	return _deferred(0x57bca0, [_deferred_bytes(a0, 20), a1], 0)


func f57bd30(a0: int, a1: int) -> int:
	return _deferred(0x57bd30, [_deferred_bytes(a0, 20), a1], 0)


func f57bd90(a0: int, a1: int) -> int:
	return _deferred(0x57bd90, [_deferred_bytes(a0, 20), a1], 0)


func f57be40(a0: int, a1: int) -> int:
	return _deferred(0x57be40, [_deferred_bytes(a0, 20), a1], 0)


func f57bf30(a0: int, a1: int) -> int:
	return _deferred(0x57bf30, [_deferred_bytes(a0, 20), a1], 0)


func f57bfb0(a0: int, a1: int) -> int:
	return _deferred(0x57bfb0, [_deferred_bytes(a0, 20), a1], 0)


func f57c060(a0: int, a1: int) -> int:
	return _deferred(0x57c060, [_deferred_bytes(a0, 20), a1], 0)


func f57c100(a0: int, a1: int) -> int:
	return _deferred(0x57c100, [_deferred_bytes(a0, 20), a1], 0)


func f57c1c0(a0: int, a1: int) -> int:
	return _deferred(0x57c1c0, [_deferred_bytes(a0, 20), a1], 0)


func f57c250(a0: int, a1: int) -> int:
	return _deferred(0x57c250, [_deferred_bytes(a0, 20), a1], 0)


func f57c2b0(a0: int, a1: int) -> int:
	return _deferred(0x57c2b0, [_deferred_bytes(a0, 20), a1], 0)


func f57c310(a0: int, a1: int) -> int:
	return _deferred(0x57c310, [_deferred_bytes(a0, 20), a1], 0)


func f57c3b0(a0: int, a1: int) -> int:
	return _deferred(0x57c3b0, [_deferred_bytes(a0, 20), a1], 0)


func f57c5c0(a0: int) -> int:
	return _deferred(0x57c5c0, [_deferred_bytes(a0, 20)], 0)


func f57c5f0(a0: int) -> int:
	return _deferred(0x57c5f0, [_deferred_bytes(a0, 20)], 0)


func f57c660(a0: int) -> int:
	return _deferred(0x57c660, [_deferred_bytes(a0, 20)], 0)


func f57c680(a0: int) -> int:
	return _deferred(0x57c680, [_deferred_bytes(a0, 20)], 0)


func f57c6a0(a0: int) -> int:
	return _deferred(0x57c6a0, [_deferred_bytes(a0, 20)], 0)


func f57c6e0(a0: int) -> int:
	return _deferred(0x57c6e0, [_deferred_bytes(a0, 20)], 0)


func f57c910(a0: int) -> int:
	return _deferred(0x57c910, [_deferred_bytes(a0, 20)], 0)


func f57cb50(a0: int) -> int:
	return _deferred(0x57cb50, [_deferred_bytes(a0, 20)], 0)


func f57cb80(a0: int) -> int:
	return _deferred(0x57cb80, [_deferred_bytes(a0, 20)], 0)


func f57cc80(a0: int) -> int:
	return _deferred(0x57cc80, [_deferred_bytes(a0, 20)], 0)


func f57ccc0(a0: int) -> int:
	return _deferred(0x57ccc0, [_deferred_bytes(a0, 20)], 0)


func f57cd40(a0: int) -> int:
	return _deferred(0x57cd40, [_deferred_bytes(a0, 20)], 0)


func f57ce10(a0: int) -> int:
	return _deferred(0x57ce10, [_deferred_bytes(a0, 20)], 0)


func f57ce80(a0: int, a1: int) -> int:
	return _deferred(0x57ce80, [_deferred_bytes(a0, 20), a1], 0)


func f57d420(a0: int) -> int:
	return _deferred(0x57d420, [_deferred_bytes(a0, 20)], 0)


func f57d510(a0: int) -> int:
	return _deferred(0x57d510, [_deferred_bytes(a0, 20)], 0)


func f57d560(a0: int) -> int:
	return _deferred(0x57d560, [_deferred_bytes(a0, 20)], 0)


func f57d6a0(a0: int, a1: int) -> int:
	return _deferred(0x57d6a0, [_deferred_bytes(a0, 20), a1], 0)


func f57d7c0(a0: int) -> int:
	return _deferred(0x57d7c0, [_deferred_bytes(a0, 20)], 0)


func f57d870(a0: int) -> int:
	return _deferred(0x57d870, [_deferred_bytes(a0, 20)], 0)


func f57d8b0(a0: int) -> int:
	return _deferred(0x57d8b0, [_deferred_bytes(a0, 20)], 0)


func f57d8f0(a0: int) -> int:
	return _deferred(0x57d8f0, [_deferred_bytes(a0, 20)], 0)


func f57da50(a0: int, a1: int) -> int:
	return _deferred(0x57da50, [_deferred_bytes(a0, 20), a1], 0)


func f57dc10(a0: int) -> int:
	return _deferred(0x57dc10, [_deferred_bytes(a0, 20)], 0)


func f57dc40(a0: int) -> int:
	return _deferred(0x57dc40, [_deferred_bytes(a0, 20)], 0)


func f57ddd0(a0: int) -> int:
	return _deferred(0x57ddd0, [_deferred_bytes(a0, 20)], 0)


func f57ddf0(a0: int) -> int:
	return _deferred(0x57ddf0, [_deferred_bytes(a0, 20)], 0)


func f57de10(a0: int) -> int:
	return _deferred(0x57de10, [_deferred_bytes(a0, 20)], 0)


func f57de30(a0: int) -> int:
	return _deferred(0x57de30, [_deferred_bytes(a0, 20)], 0)


func f57e2b0(a0: int, a1: int, a2: int, a3: int) -> int:
	return _deferred(0x57e2b0, [a0, a1, a2, a3], 0)


func f57e3c0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57e3c0, [a0, a1, a2], 0)


func f57ec70(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57ec70, [a0, a1, a2], 0)


func f57ed20(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57ed20, [a0, a1, a2], 0)


func f57ef90(a0: int, a1: int) -> int:
	return _deferred(0x57ef90, [a0, a1], 0)


func f57f240(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f240, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57f2c0(a0: int) -> int:
	return _deferred(0x57f2c0, [_deferred_bytes(a0, 20)], 0)


func f57f2f0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f2f0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57f360(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f360, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57f490(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f490, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57f4c0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f4c0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57f510(a0: int) -> int:
	return _deferred(0x57f510, [_deferred_bytes(a0, 20)], 0)


func f57f550(a0: int) -> int:
	return _deferred(0x57f550, [_deferred_bytes(a0, 20)], 0)


func f57f570(a0: int) -> int:
	return _deferred(0x57f570, [_deferred_bytes(a0, 20)], 0)


func f57f5c0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f5c0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57f610(a0: int) -> int:
	return _deferred(0x57f610, [_deferred_bytes(a0, 20)], 0)


func f57f640(a0: int) -> int:
	return _deferred(0x57f640, [_deferred_bytes(a0, 20)], 0)


func f57f6a0(a0: int) -> int:
	return _deferred(0x57f6a0, [_deferred_bytes(a0, 20)], 0)


func f57f6f0(a0: int) -> int:
	return _deferred(0x57f6f0, [_deferred_bytes(a0, 20)], 0)


func f57f7b0(a0: int) -> int:
	return _deferred(0x57f7b0, [_deferred_bytes(a0, 20)], 0)


func f57f810(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f810, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57f8d0(a0: int) -> int:
	return _deferred(0x57f8d0, [_deferred_bytes(a0, 20)], 0)


func f57f930(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f930, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57f940(a0: int) -> int:
	return _deferred(0x57f940, [_deferred_bytes(a0, 20)], 0)


func f57f970(a0: int) -> int:
	return _deferred(0x57f970, [_deferred_bytes(a0, 20)], 0)


func f57f9b0(a0: int) -> int:
	return _deferred(0x57f9b0, [_deferred_bytes(a0, 20)], 0)


func f57f9f0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57f9f0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57fa60(a0: int) -> int:
	return _deferred(0x57fa60, [_deferred_bytes(a0, 20)], 0)


func f57fa90() -> int:
	return _deferred(0x57fa90, [], 0)


func f57fac0() -> int:
	return _deferred(0x57fac0, [], 0)


func f57fae0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57fae0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57fb70(a0: int) -> int:
	return _deferred(0x57fb70, [_deferred_bytes(a0, 20)], 0)


func f57fc40(a0: int) -> int:
	return _deferred(0x57fc40, [_deferred_bytes(a0, 20)], 0)


func f57fc70(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57fc70, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57ff50(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57ff50, [_deferred_bytes(a0, 20), a1, a2], 0)


func f57ffd0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x57ffd0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f580050(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x580050, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5800a0(a0: int) -> int:
	return _deferred(0x5800a0, [_deferred_bytes(a0, 20)], 0)


func f580100(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x580100, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5801c0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x5801c0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f580330(a0: int) -> int:
	return _deferred(0x580330, [_deferred_bytes(a0, 20)], 0)


func f580360(a0: int) -> int:
	return _deferred(0x580360, [_deferred_bytes(a0, 20)], 0)


func f580450(a0: int) -> int:
	return _deferred(0x580450, [_deferred_bytes(a0, 20)], 0)


func f5804f0(a0: int) -> int:
	return _deferred(0x5804f0, [_deferred_bytes(a0, 20)], 0)


func f580600(a0: int) -> int:
	return _deferred(0x580600, [_deferred_bytes(a0, 20)], 0)


func f5806c0(a0: int) -> int:
	return _deferred(0x5806c0, [_deferred_bytes(a0, 20)], 0)


func f580710(a0: int) -> int:
	return _deferred(0x580710, [_deferred_bytes(a0, 20)], 0)


func f580780(a0: int) -> int:
	return _deferred(0x580780, [_deferred_bytes(a0, 20)], 0)


func f5807f0(a0: int) -> int:
	return _deferred(0x5807f0, [_deferred_bytes(a0, 20)], 0)


func f580870(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x580870, [_deferred_bytes(a0, 20), a1, a2], 0)


func f580960(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x580960, [_deferred_bytes(a0, 20), a1, a2], 0)


func f580d20(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x580d20, [_deferred_bytes(a0, 20), a1, a2], 0)


func f580d60(a0: int) -> int:
	return _deferred(0x580d60, [_deferred_bytes(a0, 20)], 0)


func f580de0(a0: int) -> int:
	return _deferred(0x580de0, [_deferred_bytes(a0, 20)], 0)


func f580e80(a0: int) -> int:
	return _deferred(0x580e80, [_deferred_bytes(a0, 20)], 0)


func f580ec0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x580ec0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f580f70(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x580f70, [_deferred_bytes(a0, 20), a1, a2], 0)


func f581000(a0: int) -> int:
	return _deferred(0x581000, [_deferred_bytes(a0, 20)], 0)


func f581040() -> int:
	return _deferred(0x581040, [], 0)


func f581130(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x581130, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5811b0(a0: int) -> int:
	return _deferred(0x5811b0, [_deferred_bytes(a0, 20)], 0)


func f581210(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x581210, [_deferred_bytes(a0, 20), a1, a2], 0)


func f581330(a0: int) -> int:
	return _deferred(0x581330, [_deferred_bytes(a0, 20)], 0)


func f581370(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x581370, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5813d0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x5813d0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f581480(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x581480, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5814d0(a0: int) -> int:
	return _deferred(0x5814d0, [_deferred_bytes(a0, 20)], 0)


func f581540(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x581540, [_deferred_bytes(a0, 20), a1, a2], 0)


func f581600(a0: int) -> int:
	return _deferred(0x581600, [_deferred_bytes(a0, 20)], 0)


func f581630(a0: int) -> int:
	return _deferred(0x581630, [_deferred_bytes(a0, 20)], 0)


func f5816e0(a0: int) -> int:
	return _deferred(0x5816e0, [_deferred_bytes(a0, 20)], 0)


func f581740() -> int:
	return _deferred(0x581740, [], 0)


func f581770(a0: int) -> int:
	return _deferred(0x581770, [_deferred_bytes(a0, 20)], 0)


func f581790(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x581790, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5818c0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x5818c0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f581b30(a0: int) -> int:
	return _deferred(0x581b30, [_deferred_bytes(a0, 20)], 0)


func f581b80() -> int:
	return _deferred(0x581b80, [], 0)


func f581c30(a0: int) -> int:
	return _deferred(0x581c30, [_deferred_bytes(a0, 20)], 0)


func f581c90(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x581c90, [_deferred_bytes(a0, 20), a1, a2], 0)


func f581cd0(a0: int) -> int:
	return _deferred(0x581cd0, [_deferred_bytes(a0, 20)], 0)


func f581d60(a0: int) -> int:
	return _deferred(0x581d60, [_deferred_bytes(a0, 20)], 0)


func f581de0() -> int:
	return _deferred(0x581de0, [], 0)


func f581e10(a0: int) -> int:
	return _deferred(0x581e10, [_deferred_bytes(a0, 20)], 0)


func f581e80(a0: int) -> int:
	return _deferred(0x581e80, [_deferred_bytes(a0, 20)], 0)


func f581eb0(a0: int) -> int:
	return _deferred(0x581eb0, [_deferred_bytes(a0, 20)], 0)


func f581ee0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x581ee0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f581f40(a0: int) -> int:
	return _deferred(0x581f40, [_deferred_bytes(a0, 20)], 0)


func f581fc0(a0: int) -> int:
	return _deferred(0x581fc0, [_deferred_bytes(a0, 20)], 0)


func f582040(a0: int) -> int:
	return _deferred(0x582040, [_deferred_bytes(a0, 20)], 0)


func f582080() -> int:
	return _deferred(0x582080, [], 0)


func f5820a0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x5820a0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5820e0(a0: int) -> int:
	return _deferred(0x5820e0, [_deferred_bytes(a0, 20)], 0)


func f582140(a0: int) -> int:
	return _deferred(0x582140, [_deferred_bytes(a0, 20)], 0)


func f5821a0(a0: int) -> int:
	return _deferred(0x5821a0, [_deferred_bytes(a0, 20)], 0)


func f582200() -> int:
	return _deferred(0x582200, [], 0)


func f582210(a0: int) -> int:
	return _deferred(0x582210, [_deferred_bytes(a0, 20)], 0)


func f582250(a0: int) -> int:
	return _deferred(0x582250, [_deferred_bytes(a0, 20)], 0)


func f582270(a0: int) -> int:
	return _deferred(0x582270, [_deferred_bytes(a0, 20)], 0)


func f582330(a0: int) -> int:
	return _deferred(0x582330, [_deferred_bytes(a0, 20)], 0)


func f582370(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x582370, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582400(a0: int) -> int:
	return _deferred(0x582400, [_deferred_bytes(a0, 20)], 0)


func f582440(a0: int) -> int:
	return _deferred(0x582440, [_deferred_bytes(a0, 20)], 0)


func f582590(a0: int, a1: int) -> int:
	return _deferred(0x582590, [_deferred_bytes(a0, 20), a1], 0)


func f582680(a0: int) -> int:
	return _deferred(0x582680, [_deferred_bytes(a0, 20)], 0)


func f5826b0() -> int:
	return _deferred(0x5826b0, [], 0)


func f5826d0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x5826d0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582790(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x582790, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582860(a0: int) -> int:
	return _deferred(0x582860, [_deferred_bytes(a0, 20)], 0)


func f582890(a0: int) -> int:
	return _deferred(0x582890, [_deferred_bytes(a0, 20)], 0)


func f582990(a0: int) -> int:
	return _deferred(0x582990, [_deferred_bytes(a0, 20)], 0)


func f5829d0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x5829d0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582ae0(a0: int) -> int:
	return _deferred(0x582ae0, [_deferred_bytes(a0, 20)], 0)


func f582b60(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x582b60, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582be0() -> int:
	return _deferred(0x582be0, [], 0)


func f582bf0(a0: int) -> int:
	return _deferred(0x582bf0, [_deferred_bytes(a0, 20)], 0)


func f582c40(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x582c40, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582c70(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x582c70, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582d30(a0: int) -> int:
	return _deferred(0x582d30, [_deferred_bytes(a0, 20)], 0)


func f582e40(a0: int) -> int:
	return _deferred(0x582e40, [_deferred_bytes(a0, 20)], 0)


func f582e60(a0: int) -> int:
	return _deferred(0x582e60, [_deferred_bytes(a0, 20)], 0)


func f582ea0(a0: int) -> int:
	return _deferred(0x582ea0, [_deferred_bytes(a0, 20)], 0)


func f582ed0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x582ed0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582f20(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x582f20, [_deferred_bytes(a0, 20), a1, a2], 0)


func f582fa0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x582fa0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f583050(a0: int) -> int:
	return _deferred(0x583050, [_deferred_bytes(a0, 20)], 0)


func f5830b0(a0: int) -> int:
	return _deferred(0x5830b0, [_deferred_bytes(a0, 20)], 0)


func f583120() -> int:
	return _deferred(0x583120, [], 0)


func f583150(a0: int) -> int:
	return _deferred(0x583150, [_deferred_bytes(a0, 20)], 0)


func f583180(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x583180, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5831f0(a0: int) -> int:
	return _deferred(0x5831f0, [_deferred_bytes(a0, 20)], 0)


func f583240(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x583240, [_deferred_bytes(a0, 20), a1, a2], 0)


func f583340(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x583340, [_deferred_bytes(a0, 20), a1, a2], 0)


func f583370(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x583370, [_deferred_bytes(a0, 20), a1, a2], 0)


func f5833d0(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x5833d0, [_deferred_bytes(a0, 20), a1, a2], 0)


func f583400(a0: int) -> int:
	return _deferred(0x583400, [_deferred_bytes(a0, 20)], 0)


func f5835f0(a0: int) -> int:
	return _deferred(0x5835f0, [_deferred_bytes(a0, 20)], 0)


func f583be0(a0: int) -> int:
	return _deferred(0x583be0, [_deferred_bytes(a0, 20)], 0)


func f583d20(a0: int) -> int:
	return _deferred(0x583d20, [_deferred_bytes(a0, 20)], 0)


func f583f30() -> int:
	return _deferred(0x583f30, [], 0)


func f583f40(a0: int) -> int:
	return _deferred(0x583f40, [_deferred_bytes(a0, 20)], 0)


func f584040(a0: int) -> int:
	return _deferred(0x584040, [_deferred_bytes(a0, 20)], 0)


func f584160(a0: int) -> int:
	return _deferred(0x584160, [_deferred_bytes(a0, 20)], 0)


func f584270(a0: int) -> int:
	return _deferred(0x584270, [_deferred_bytes(a0, 20)], 0)


func f5842e0(a0: int) -> int:
	return _deferred(0x5842e0, [_deferred_bytes(a0, 20)], 0)


func f584360(a0: int) -> int:
	return _deferred(0x584360, [_deferred_bytes(a0, 20)], 0)


func f584390(a0: int) -> int:
	return _deferred(0x584390, [_deferred_bytes(a0, 20)], 0)


func f584440(a0: int) -> int:
	return _deferred(0x584440, [_deferred_bytes(a0, 20)], 0)


func f5844a0(a0: int) -> int:
	return _deferred(0x5844a0, [_deferred_bytes(a0, 20)], 0)


func f5844c0(a0: int) -> int:
	return _deferred(0x5844c0, [_deferred_bytes(a0, 20)], 0)


func f584500(a0: int) -> int:
	return _deferred(0x584500, [_deferred_bytes(a0, 20)], 0)


func f584610(a0: int, a1: int) -> int:
	return _deferred(0x584610, [_deferred_bytes(a0, 20), a1], 0)


func f584660(a0: int, a1: int) -> int:
	return _deferred(0x584660, [_deferred_bytes(a0, 20), a1], 0)


func f5846b0(a0: int, a1: int) -> int:
	return _deferred(0x5846b0, [_deferred_bytes(a0, 20), a1], 0)


func f584930(a0: int) -> int:
	return _deferred(0x584930, [_deferred_bytes(a0, 20)], 0)


func f5849d0(a0: int) -> int:
	return _deferred(0x5849d0, [_deferred_bytes(a0, 20)], 0)


func f584a90(a0: int) -> int:
	return _deferred(0x584a90, [_deferred_bytes(a0, 20)], 0)


func f584c80(a0: int) -> int:
	return _deferred(0x584c80, [_deferred_bytes(a0, 20)], 0)


func f584cb0(a0: int) -> int:
	return _deferred(0x584cb0, [_deferred_bytes(a0, 20)], 0)


func f584d00(a0: int) -> int:
	return _deferred(0x584d00, [_deferred_bytes(a0, 20)], 0)


func f584de0(a0: int) -> int:
	return _deferred(0x584de0, [_deferred_bytes(a0, 20)], 0)


func f584e60(a0: int) -> int:
	return _deferred(0x584e60, [_deferred_bytes(a0, 20)], 0)


func f585130(a0: int) -> int:
	return _deferred(0x585130, [_deferred_bytes(a0, 20)], 0)


func f585170(a0: int) -> int:
	return _deferred(0x585170, [_deferred_bytes(a0, 20)], 0)


func f585200(a0: int) -> int:
	return _deferred(0x585200, [_deferred_bytes(a0, 20)], 0)


func f5852a0(a0: int) -> int:
	return _deferred(0x5852a0, [_deferred_bytes(a0, 20)], 0)


func f585310(a0: int) -> int:
	return _deferred(0x585310, [_deferred_bytes(a0, 20)], 0)


func f585350(a0: int) -> int:
	return _deferred(0x585350, [_deferred_bytes(a0, 20)], 0)


func f5853b0(a0: int) -> int:
	return _deferred(0x5853b0, [_deferred_bytes(a0, 20)], 0)


func f585420(a0: int) -> int:
	return _deferred(0x585420, [_deferred_bytes(a0, 20)], 0)


func f585540(a0: int) -> int:
	return _deferred(0x585540, [_deferred_bytes(a0, 20)], 0)


func f585640(a0: int) -> int:
	return _deferred(0x585640, [_deferred_bytes(a0, 20)], 0)


func f585730(a0: int) -> int:
	return _deferred(0x585730, [_deferred_bytes(a0, 20)], 0)


func f585970(a0: int) -> int:
	return _deferred(0x585970, [_deferred_bytes(a0, 20)], 0)


func f5859c0(a0: int) -> int:
	return _deferred(0x5859c0, [_deferred_bytes(a0, 20)], 0)


func f5859e0(a0: int) -> int:
	return _deferred(0x5859e0, [_deferred_bytes(a0, 20)], 0)


func f585ae0(a0: int) -> int:
	return _deferred(0x585ae0, [_deferred_bytes(a0, 20)], 0)


func f585b10(a0: int) -> int:
	return _deferred(0x585b10, [_deferred_bytes(a0, 20)], 0)


func f585bf0(a0: int) -> int:
	return _deferred(0x585bf0, [_deferred_bytes(a0, 20)], 0)


func f585c80(a0: int) -> int:
	return _deferred(0x585c80, [_deferred_bytes(a0, 20)], 0)


func f585d30(a0: int) -> int:
	return _deferred(0x585d30, [_deferred_bytes(a0, 20)], 0)


func f585d50(a0: int) -> int:
	return _deferred(0x585d50, [_deferred_bytes(a0, 20)], 0)


func f585dc0(a0: int) -> int:
	return _deferred(0x585dc0, [_deferred_bytes(a0, 20)], 0)


func f585e40(a0: int) -> int:
	return _deferred(0x585e40, [_deferred_bytes(a0, 20)], 0)


func f585e70(a0: int) -> int:
	return _deferred(0x585e70, [_deferred_bytes(a0, 20)], 0)


func f585f50(a0: int) -> int:
	return _deferred(0x585f50, [_deferred_bytes(a0, 20)], 0)


func f586040(a0: int) -> int:
	return _deferred(0x586040, [_deferred_bytes(a0, 20)], 0)


func f5860e0(a0: int) -> int:
	return _deferred(0x5860e0, [_deferred_bytes(a0, 20)], 0)


func f5861f0(a0: int) -> int:
	return _deferred(0x5861f0, [_deferred_bytes(a0, 20)], 0)


func f586260(a0: int) -> int:
	return _deferred(0x586260, [_deferred_bytes(a0, 20)], 0)


func f586290(a0: int) -> int:
	return _deferred(0x586290, [_deferred_bytes(a0, 20)], 0)


func f586330(a0: int) -> int:
	return _deferred(0x586330, [_deferred_bytes(a0, 20)], 0)


func f586500(a0: int, a1: int) -> int:
	return _deferred(0x586500, [_deferred_bytes(a0, 20), a1], 0)


func f586540(a0: int) -> int:
	return _deferred(0x586540, [_deferred_bytes(a0, 20)], 0)


func f5865c0(a0: int) -> int:
	return _deferred(0x5865c0, [_deferred_bytes(a0, 20)], 0)


func f586850(a0: int) -> int:
	return _deferred(0x586850, [_deferred_bytes(a0, 20)], 0)


func f5868a0(a0: int) -> int:
	return _deferred(0x5868a0, [_deferred_bytes(a0, 20)], 0)


func f586b10(a0: int) -> int:
	return _deferred(0x586b10, [_deferred_bytes(a0, 20)], 0)


func f586b30(a0: int, a1: int) -> int:
	return _deferred(0x586b30, [_deferred_bytes(a0, 20), a1], 0)


func f586ef0(a0: int) -> int:
	return _deferred(0x586ef0, [_deferred_bytes(a0, 20)], 0)


func f586fb0(a0: int) -> int:
	return _deferred(0x586fb0, [_deferred_bytes(a0, 20)], 0)


func f5870c0(a0: int) -> int:
	return _deferred(0x5870c0, [_deferred_bytes(a0, 20)], 0)


func f5871a0(a0: int) -> int:
	return _deferred(0x5871a0, [_deferred_bytes(a0, 20)], 0)


func f5872b0(a0: int) -> int:
	return _deferred(0x5872b0, [_deferred_bytes(a0, 20)], 0)


func f5875a0(a0: int) -> int:
	return _deferred(0x5875a0, [_deferred_bytes(a0, 20)], 0)


func f5877e0(a0: int) -> int:
	return _deferred(0x5877e0, [_deferred_bytes(a0, 20)], 0)


func f587950(a0: int) -> int:
	return _deferred(0x587950, [_deferred_bytes(a0, 20)], 0)


func f587a90(a0: int, a1: int) -> int:
	return _deferred(0x587a90, [_deferred_bytes(a0, 20), a1], 0)


func f587e80(a0: int) -> int:
	return _deferred(0x587e80, [_deferred_bytes(a0, 20)], 0)


func f587f90(a0: int) -> int:
	return _deferred(0x587f90, [_deferred_bytes(a0, 20)], 0)


func f5881d0(a0: int) -> int:
	return _deferred(0x5881d0, [_deferred_bytes(a0, 20)], 0)


func f588260(a0: int) -> int:
	return _deferred(0x588260, [_deferred_bytes(a0, 20)], 0)


func f588380(a0: int) -> int:
	return _deferred(0x588380, [_deferred_bytes(a0, 20)], 0)


func f5883c0(a0: int) -> int:
	return _deferred(0x5883c0, [_deferred_bytes(a0, 20)], 0)


func f5885a0(a0: int) -> int:
	return _deferred(0x5885a0, [_deferred_bytes(a0, 20)], 0)


func f588640(a0: int) -> int:
	return _deferred(0x588640, [_deferred_bytes(a0, 20)], 0)


func f5886c0(a0: int, a1: int) -> int:
	return _deferred(0x5886c0, [_deferred_bytes(a0, 20), a1], 0)


func f5887c0(a0: int) -> int:
	return _deferred(0x5887c0, [_deferred_bytes(a0, 20)], 0)


func f588830(a0: int) -> int:
	return _deferred(0x588830, [_deferred_bytes(a0, 20)], 0)


func f5889a0(a0: int) -> int:
	return _deferred(0x5889a0, [_deferred_bytes(a0, 20)], 0)


func f588ae0(a0: int) -> int:
	return _deferred(0x588ae0, [_deferred_bytes(a0, 20)], 0)


func f588b70(a0: int, a1: int) -> int:
	return _deferred(0x588b70, [_deferred_bytes(a0, 20), a1], 0)


func f588d30(a0: int) -> int:
	return _deferred(0x588d30, [_deferred_bytes(a0, 20)], 0)


func f588d90(a0: int, a1: int) -> int:
	return _deferred(0x588d90, [_deferred_bytes(a0, 20), a1], 0)


func f589030(a0: int, a1: int) -> int:
	return _deferred(0x589030, [_deferred_bytes(a0, 20), a1], 0)


func f589160(a0: int) -> int:
	return _deferred(0x589160, [_deferred_bytes(a0, 20)], 0)


func f589200(a0: int) -> int:
	return _deferred(0x589200, [_deferred_bytes(a0, 20)], 0)


func f5892d0(a0: int) -> int:
	return _deferred(0x5892d0, [_deferred_bytes(a0, 20)], 0)


func f589400(a0: int) -> int:
	return _deferred(0x589400, [_deferred_bytes(a0, 20)], 0)


func f589480(a0: int) -> int:
	return _deferred(0x589480, [_deferred_bytes(a0, 20)], 0)


func f589610(a0: int) -> int:
	return _deferred(0x589610, [_deferred_bytes(a0, 20)], 0)


func f5897b0(a0: int) -> int:
	return _deferred(0x5897b0, [_deferred_bytes(a0, 20)], 0)


func f5897e0(a0: int) -> int:
	return _deferred(0x5897e0, [_deferred_bytes(a0, 20)], 0)


func f589830(a0: int) -> int:
	return _deferred(0x589830, [_deferred_bytes(a0, 20)], 0)


func f589860(a0: int) -> int:
	return _deferred(0x589860, [_deferred_bytes(a0, 20)], 0)


func f589920(a0: int) -> int:
	return _deferred(0x589920, [_deferred_bytes(a0, 20)], 0)


func f589970(a0: int) -> int:
	return _deferred(0x589970, [_deferred_bytes(a0, 20)], 0)


func f5899a0(a0: int) -> int:
	return _deferred(0x5899a0, [_deferred_bytes(a0, 20)], 0)


func f589a90(a0: int) -> int:
	return _deferred(0x589a90, [_deferred_bytes(a0, 20)], 0)


func f589b10(a0: int) -> int:
	return _deferred(0x589b10, [_deferred_bytes(a0, 20)], 0)


func f589b70(a0: int) -> int:
	return _deferred(0x589b70, [_deferred_bytes(a0, 20)], 0)


func f589c00(a0: int, a1: int) -> int:
	return _deferred(0x589c00, [_deferred_bytes(a0, 20), a1], 0)


func f589c70(a0: int, a1: int) -> int:
	return _deferred(0x589c70, [_deferred_bytes(a0, 20), a1], 0)


func f589db0(a0: int) -> int:
	return _deferred(0x589db0, [_deferred_bytes(a0, 20)], 0)


func f589e60(a0: int) -> int:
	return _deferred(0x589e60, [_deferred_bytes(a0, 20)], 0)


func f589eb0(a0: int, a1: int) -> int:
	return _deferred(0x589eb0, [_deferred_bytes(a0, 20), a1], 0)


func f58a140(a0: int) -> int:
	return _deferred(0x58a140, [_deferred_bytes(a0, 20)], 0)


func f58a170(a0: int) -> int:
	return _deferred(0x58a170, [_deferred_bytes(a0, 20)], 0)


func f58a200(a0: int) -> int:
	return _deferred(0x58a200, [_deferred_bytes(a0, 20)], 0)


func f58a250(a0: int) -> int:
	return _deferred(0x58a250, [_deferred_bytes(a0, 20)], 0)


func f58a2c0(a0: int) -> int:
	return _deferred(0x58a2c0, [_deferred_bytes(a0, 20)], 0)


func f58a4a0(a0: int) -> int:
	return _deferred(0x58a4a0, [_deferred_bytes(a0, 20)], 0)


func f58a660(a0: int) -> int:
	return _deferred(0x58a660, [_deferred_bytes(a0, 20)], 0)


func f58a690(a0: int) -> int:
	return _deferred(0x58a690, [_deferred_bytes(a0, 20)], 0)


func f58a880(a0: int) -> int:
	return _deferred(0x58a880, [_deferred_bytes(a0, 20)], 0)


func f58ac10(a0: int) -> int:
	return _deferred(0x58ac10, [_deferred_bytes(a0, 20)], 0)


func f58add0(a0: int) -> int:
	return _deferred(0x58add0, [_deferred_bytes(a0, 20)], 0)


func f58afe0(a0: int) -> int:
	return _deferred(0x58afe0, [_deferred_bytes(a0, 20)], 0)


func f58b040(a0: int) -> int:
	return _deferred(0x58b040, [_deferred_bytes(a0, 20)], 0)


func f58b3d0(a0: int, a1: int) -> int:
	return _deferred(0x58b3d0, [_deferred_bytes(a0, 20), a1], 0)


func f58b400(a0: int) -> int:
	return _deferred(0x58b400, [_deferred_bytes(a0, 20)], 0)


func f58b5e0(a0: int) -> int:
	return _deferred(0x58b5e0, [_deferred_bytes(a0, 20)], 0)


func f58b810(a0: int) -> int:
	return _deferred(0x58b810, [_deferred_bytes(a0, 20)], 0)


func f58b930(a0: int) -> int:
	return _deferred(0x58b930, [_deferred_bytes(a0, 20)], 0)


func f58b9a0(a0: int) -> int:
	return _deferred(0x58b9a0, [_deferred_bytes(a0, 20)], 0)


func f58ba80(a0: int) -> int:
	return _deferred(0x58ba80, [_deferred_bytes(a0, 20)], 0)


func f58bb10(a0: int) -> int:
	return _deferred(0x58bb10, [_deferred_bytes(a0, 20)], 0)


func f58bf40(a0: int) -> int:
	return _deferred(0x58bf40, [_deferred_bytes(a0, 20)], 0)


func f58c080(a0: int) -> int:
	return _deferred(0x58c080, [_deferred_bytes(a0, 20)], 0)


func f58c2e0(a0: int) -> int:
	return _deferred(0x58c2e0, [_deferred_bytes(a0, 20)], 0)


func f58c430(a0: int) -> int:
	return _deferred(0x58c430, [_deferred_bytes(a0, 20)], 0)


func f58c490(a0: int) -> int:
	return _deferred(0x58c490, [_deferred_bytes(a0, 20)], 0)


func f58c890(a0: int) -> int:
	return _deferred(0x58c890, [_deferred_bytes(a0, 20)], 0)


func f58c950(a0: int) -> int:
	return _deferred(0x58c950, [_deferred_bytes(a0, 20)], 0)


func f58ca70(a0: int) -> int:
	return _deferred(0x58ca70, [_deferred_bytes(a0, 20)], 0)


func f58cb70(a0: int) -> int:
	return _deferred(0x58cb70, [_deferred_bytes(a0, 20)], 0)


func f58cc00(a0: int) -> int:
	return _deferred(0x58cc00, [_deferred_bytes(a0, 20)], 0)


func f58cca0(a0: int) -> int:
	return _deferred(0x58cca0, [_deferred_bytes(a0, 20)], 0)


func f58cdf0(a0: int) -> int:
	return _deferred(0x58cdf0, [_deferred_bytes(a0, 20)], 0)


func f58ceb0(a0: int) -> int:
	return _deferred(0x58ceb0, [_deferred_bytes(a0, 20)], 0)


func f58cf50(a0: int) -> int:
	return _deferred(0x58cf50, [_deferred_bytes(a0, 20)], 0)


func f58cfa0(a0: int) -> int:
	return _deferred(0x58cfa0, [_deferred_bytes(a0, 20)], 0)


func f58cfd0(a0: int) -> int:
	return _deferred(0x58cfd0, [_deferred_bytes(a0, 20)], 0)


func f58d220(a0: int, a1: int) -> int:
	return _deferred(0x58d220, [_deferred_bytes(a0, 20), a1], 0)


func f58d380(a0: int) -> int:
	return _deferred(0x58d380, [_deferred_bytes(a0, 20)], 0)


func f58d480(a0: int, a1: int) -> int:
	return _deferred(0x58d480, [_deferred_bytes(a0, 20), a1], 0)


func f58d590(a0: int) -> int:
	return _deferred(0x58d590, [_deferred_bytes(a0, 20)], 0)


func f58d5e0(a0: int) -> int:
	return _deferred(0x58d5e0, [_deferred_bytes(a0, 20)], 0)


func f58d660(a0: int) -> int:
	return _deferred(0x58d660, [_deferred_bytes(a0, 20)], 0)


func f58d860(a0: int) -> int:
	return _deferred(0x58d860, [_deferred_bytes(a0, 20)], 0)


func f58d930(a0: int) -> int:
	return _deferred(0x58d930, [_deferred_bytes(a0, 20)], 0)


func f58d970(a0: int) -> int:
	return _deferred(0x58d970, [_deferred_bytes(a0, 20)], 0)


func f58da00(a0: int) -> int:
	return _deferred(0x58da00, [_deferred_bytes(a0, 20)], 0)


func f58da80(a0: int) -> int:
	return _deferred(0x58da80, [_deferred_bytes(a0, 20)], 0)


func f58dbd0(a0: int) -> int:
	return _deferred(0x58dbd0, [_deferred_bytes(a0, 20)], 0)


func f58dcc0(a0: int) -> int:
	return _deferred(0x58dcc0, [_deferred_bytes(a0, 20)], 0)


func f58de30(a0: int) -> int:
	return _deferred(0x58de30, [_deferred_bytes(a0, 20)], 0)


func f58dec0(a0: int) -> int:
	return _deferred(0x58dec0, [_deferred_bytes(a0, 20)], 0)


func f58dfe0(a0: int) -> int:
	return _deferred(0x58dfe0, [_deferred_bytes(a0, 20)], 0)


func f58e160(a0: int) -> int:
	return _deferred(0x58e160, [_deferred_bytes(a0, 20)], 0)


func f58e1f0(a0: int) -> int:
	return _deferred(0x58e1f0, [_deferred_bytes(a0, 20)], 0)


func f58e2f0(a0: int) -> int:
	return _deferred(0x58e2f0, [_deferred_bytes(a0, 20)], 0)


func f58e3a0(a0: int) -> int:
	return _deferred(0x58e3a0, [_deferred_bytes(a0, 20)], 0)


func f58e4e0(a0: int, a1: int) -> int:
	return _deferred(0x58e4e0, [_deferred_bytes(a0, 20), a1], 0)


func f58e580(a0: int) -> int:
	return _deferred(0x58e580, [_deferred_bytes(a0, 20)], 0)


func f58e670(a0: int) -> int:
	return _deferred(0x58e670, [_deferred_bytes(a0, 20)], 0)


func f58e790(a0: int) -> int:
	return _deferred(0x58e790, [_deferred_bytes(a0, 20)], 0)


func f58e830(a0: int, a1: int) -> int:
	return _deferred(0x58e830, [_deferred_bytes(a0, 20), a1], 0)


func f58e850(a0: int) -> int:
	return _deferred(0x58e850, [_deferred_bytes(a0, 20)], 0)


func f58e950(a0: int) -> int:
	return _deferred(0x58e950, [_deferred_bytes(a0, 20)], 0)


func f58ea30(a0: int) -> int:
	return _deferred(0x58ea30, [_deferred_bytes(a0, 20)], 0)


func f58eae0(a0: int) -> int:
	return _deferred(0x58eae0, [_deferred_bytes(a0, 20)], 0)


func f58ecd0(a0: int) -> int:
	return _deferred(0x58ecd0, [_deferred_bytes(a0, 20)], 0)


func f58ed20(a0: int) -> int:
	return _deferred(0x58ed20, [_deferred_bytes(a0, 20)], 0)


func f58ee30(a0: int) -> int:
	return _deferred(0x58ee30, [_deferred_bytes(a0, 20)], 0)


func f58ee90(a0: int) -> int:
	return _deferred(0x58ee90, [_deferred_bytes(a0, 20)], 0)


func f58eee0(a0: int) -> int:
	return _deferred(0x58eee0, [_deferred_bytes(a0, 20)], 0)


func f58ef90(a0: int) -> int:
	return _deferred(0x58ef90, [_deferred_bytes(a0, 20)], 0)


func f58f140(a0: int, a1: int) -> int:
	return _deferred(0x58f140, [_deferred_bytes(a0, 20), a1], 0)


func f58f1a0(a0: int) -> int:
	return _deferred(0x58f1a0, [_deferred_bytes(a0, 20)], 0)


func f58f2d0(a0: int) -> int:
	return _deferred(0x58f2d0, [_deferred_bytes(a0, 20)], 0)


func f58f3d0(a0: int) -> int:
	return _deferred(0x58f3d0, [_deferred_bytes(a0, 20)], 0)


func f58f4b0(a0: int, a1: int) -> int:
	return _deferred(0x58f4b0, [_deferred_bytes(a0, 20), a1], 0)


func f58f5d0(a0: int) -> int:
	return _deferred(0x58f5d0, [_deferred_bytes(a0, 20)], 0)


func f58f640(a0: int) -> int:
	return _deferred(0x58f640, [_deferred_bytes(a0, 20)], 0)


func f58f7e0(a0: int) -> int:
	return _deferred(0x58f7e0, [_deferred_bytes(a0, 20)], 0)


func f58f830(a0: int) -> int:
	return _deferred(0x58f830, [_deferred_bytes(a0, 20)], 0)


func f58f940(a0: int) -> int:
	return _deferred(0x58f940, [_deferred_bytes(a0, 20)], 0)


func f58f9f0(a0: int) -> int:
	return _deferred(0x58f9f0, [_deferred_bytes(a0, 20)], 0)


func f58fa90(a0: int, a1: int) -> int:
	return _deferred(0x58fa90, [_deferred_bytes(a0, 20), a1], 0)


func f58ff70(a0: int) -> int:
	return _deferred(0x58ff70, [_deferred_bytes(a0, 20)], 0)


func f590010(a0: int) -> int:
	return _deferred(0x590010, [_deferred_bytes(a0, 20)], 0)


func f590080(a0: int) -> int:
	return _deferred(0x590080, [_deferred_bytes(a0, 20)], 0)


func f5901a0(a0: int) -> int:
	return _deferred(0x5901a0, [_deferred_bytes(a0, 20)], 0)


func f590410(a0: int) -> int:
	return _deferred(0x590410, [_deferred_bytes(a0, 20)], 0)


func f5904b0(a0: int) -> int:
	return _deferred(0x5904b0, [_deferred_bytes(a0, 20)], 0)


func f590640(a0: int) -> int:
	return _deferred(0x590640, [_deferred_bytes(a0, 20)], 0)


func f5906b0(a0: int) -> int:
	return _deferred(0x5906b0, [_deferred_bytes(a0, 20)], 0)


func f5907d0(a0: int) -> int:
	return _deferred(0x5907d0, [_deferred_bytes(a0, 20)], 0)


func f590870(a0: int) -> int:
	return _deferred(0x590870, [_deferred_bytes(a0, 20)], 0)


func f5909a0(a0: int) -> int:
	return _deferred(0x5909a0, [_deferred_bytes(a0, 20)], 0)


func f590a20(a0: int) -> int:
	return _deferred(0x590a20, [_deferred_bytes(a0, 20)], 0)


func f590b60(a0: int) -> int:
	return _deferred(0x590b60, [_deferred_bytes(a0, 20)], 0)


func f590ba0(a0: int, a1: int) -> int:
	return _deferred(0x590ba0, [_deferred_bytes(a0, 20), a1], 0)


func f590d80(a0: int) -> int:
	return _deferred(0x590d80, [_deferred_bytes(a0, 20)], 0)


func f591040(a0: int) -> int:
	return _deferred(0x591040, [_deferred_bytes(a0, 20)], 0)


func f591210(a0: int) -> int:
	return _deferred(0x591210, [_deferred_bytes(a0, 20)], 0)


func f5912b0(a0: int) -> int:
	return _deferred(0x5912b0, [_deferred_bytes(a0, 20)], 0)


func f5912f0(a0: int) -> int:
	return _deferred(0x5912f0, [_deferred_bytes(a0, 20)], 0)


func f5914a0(a0: int) -> int:
	return _deferred(0x5914a0, [_deferred_bytes(a0, 20)], 0)


func f5916e0(a0: int, a1: int) -> int:
	return _deferred(0x5916e0, [_deferred_bytes(a0, 20), a1], 0)


func f591760(a0: int, a1: int) -> int:
	return _deferred(0x591760, [_deferred_bytes(a0, 20), a1], 0)


func f591890(a0: int) -> int:
	return _deferred(0x591890, [_deferred_bytes(a0, 20)], 0)


func f5921c0(a0: int, a1: int) -> int:
	return _deferred(0x5921c0, [_deferred_bytes(a0, 20), a1], 0)


func f593530(a0: int) -> int:
	return _deferred(0x593530, [_deferred_bytes(a0, 20)], 0)


func f593740(a0: int, a1: int) -> int:
	return _deferred(0x593740, [_deferred_bytes(a0, 20), a1], 0)


func f5938d0(a0: int) -> int:
	return _deferred(0x5938d0, [_deferred_bytes(a0, 20)], 0)


func f593970(a0: int, a1: int) -> int:
	return _deferred(0x593970, [_deferred_bytes(a0, 20), a1], 0)


func f593a20(a0: int, a1: int) -> int:
	return _deferred(0x593a20, [_deferred_bytes(a0, 20), a1], 0)


func f593ba0(a0: int, a1: int) -> int:
	return _deferred(0x593ba0, [_deferred_bytes(a0, 20), a1], 0)


func f593bf0(a0: int) -> int:
	return _deferred(0x593bf0, [_deferred_bytes(a0, 20)], 0)


func f593ca0(a0: int) -> int:
	return _deferred(0x593ca0, [_deferred_bytes(a0, 20)], 0)


func f593cc0(a0: int) -> int:
	return _deferred(0x593cc0, [_deferred_bytes(a0, 20)], 0)


func f593cf0(a0: int) -> int:
	return _deferred(0x593cf0, [_deferred_bytes(a0, 20)], 0)


func f593f80(a0: int, a1: int) -> int:
	return _deferred(0x593f80, [_deferred_bytes(a0, 20), a1], 0)


func f594200(a0: int) -> int:
	return _deferred(0x594200, [_deferred_bytes(a0, 20)], 0)


func f5944d0(a0: int, a1: int) -> int:
	return _deferred(0x5944d0, [_deferred_bytes(a0, 20), a1], 0)


func f594520(a0: int) -> int:
	return _deferred(0x594520, [_deferred_bytes(a0, 20)], 0)


func f594780(a0: int, a1: int) -> int:
	return _deferred(0x594780, [_deferred_bytes(a0, 20), a1], 0)


func f594810(a0: int, a1: int) -> int:
	return _deferred(0x594810, [_deferred_bytes(a0, 20), a1], 0)


func f594860(a0: int, a1: int) -> int:
	return _deferred(0x594860, [_deferred_bytes(a0, 20), a1], 0)


func f5948b0(a0: int, a1: int) -> int:
	return _deferred(0x5948b0, [_deferred_bytes(a0, 20), a1], 0)


func f594a10(a0: int, a1: int) -> int:
	return _deferred(0x594a10, [_deferred_bytes(a0, 20), a1], 0)


func f594b70(a0: int, a1: int) -> int:
	return _deferred(0x594b70, [_deferred_bytes(a0, 20), a1], 0)


func f594bb0(a0: int, a1: int) -> int:
	return _deferred(0x594bb0, [_deferred_bytes(a0, 20), a1], 0)


func f594c00(a0: int) -> int:
	return _deferred(0x594c00, [_deferred_bytes(a0, 20)], 0)


func f594f00(a0: int) -> int:
	return _deferred(0x594f00, [_deferred_bytes(a0, 20)], 0)


func f5952c0(a0: int, a1: int) -> int:
	return _deferred(0x5952c0, [_deferred_bytes(a0, 20), a1], 0)


func f595310(a0: int, a1: int) -> int:
	return _deferred(0x595310, [_deferred_bytes(a0, 20), a1], 0)


func f595360(a0: int, a1: int) -> int:
	return _deferred(0x595360, [_deferred_bytes(a0, 20), a1], 0)


func f595530(a0: int, a1: int) -> int:
	return _deferred(0x595530, [_deferred_bytes(a0, 20), a1], 0)


func f595780(a0: int, a1: int) -> int:
	return _deferred(0x595780, [_deferred_bytes(a0, 20), a1], 0)


func f595a90(a0: int, a1: int) -> int:
	return _deferred(0x595a90, [_deferred_bytes(a0, 20), a1], 0)


func f595ac0(a0: int) -> int:
	return _deferred(0x595ac0, [_deferred_bytes(a0, 20)], 0)


func f595ce0(a0: int) -> int:
	return _deferred(0x595ce0, [_deferred_bytes(a0, 20)], 0)


func f595d60(a0: int) -> int:
	return _deferred(0x595d60, [_deferred_bytes(a0, 20)], 0)


func f595f20(a0: int) -> int:
	return _deferred(0x595f20, [_deferred_bytes(a0, 20)], 0)


func f5961c0(a0: int) -> int:
	return _deferred(0x5961c0, [_deferred_bytes(a0, 20)], 0)


func f5963e0(a0: int, a1: int) -> int:
	return _deferred(0x5963e0, [_deferred_bytes(a0, 20), a1], 0)


func f5965e0(a0: int) -> int:
	return _deferred(0x5965e0, [_deferred_bytes(a0, 20)], 0)


func f596910(a0: int) -> int:
	return _deferred(0x596910, [_deferred_bytes(a0, 20)], 0)


func f596ba0(a0: int, a1: int) -> int:
	return _deferred(0x596ba0, [_deferred_bytes(a0, 20), a1], 0)


func f596be0(a0: int) -> int:
	return _deferred(0x596be0, [_deferred_bytes(a0, 20)], 0)


func f596d70(a0: int) -> int:
	return _deferred(0x596d70, [_deferred_bytes(a0, 20)], 0)


func f597030(a0: int) -> int:
	return _deferred(0x597030, [_deferred_bytes(a0, 20)], 0)


func f5971a0(a0: int, a1: int) -> int:
	return _deferred(0x5971a0, [_deferred_bytes(a0, 20), a1], 0)


func f597270(a0: int, a1: int) -> int:
	return _deferred(0x597270, [_deferred_bytes(a0, 20), a1], 0)


func f5974d0(a0: int, a1: int) -> int:
	return _deferred(0x5974d0, [_deferred_bytes(a0, 20), a1], 0)


func f597520(a0: int, a1: int) -> int:
	return _deferred(0x597520, [_deferred_bytes(a0, 20), a1], 0)


func f597570(a0: int, a1: int) -> int:
	return _deferred(0x597570, [_deferred_bytes(a0, 20), a1], 0)


func f599850(a0: int) -> int:
	return _deferred(0x599850, [_deferred_bytes(a0, 20)], 0)


func f5999d0(a0: int) -> int:
	return _deferred(0x5999d0, [_deferred_bytes(a0, 20)], 0)


func f599e30(a0: int, a1: int, a2: int) -> int:
	return _deferred(0x599e30, [a0, (a1 & 65535), a2], 0)


func f5bd2d0() -> int:
	return _deferred(0x5bd2d0, [], 0)


func f5bde30(a0: int, a1: int) -> int:
	return _frontier(0x5bde30, ["*", a1], 0)


func f5bde70(a0: int, a1: int) -> int:
	return _frontier(0x5bde70, ["*", a1], 0)


func f5bdec0(a0: int, a1: int) -> int:
	return _frontier(0x5bdec0, ["*", a1], 0)


func f5bdf20(a0: int, a1: int) -> int:
	return _frontier(0x5bdf20, ["*", a1], 0)


func f5bdf40(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x5bdf40, ["*", a1, a2], 0)


func f5bdfc0(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x5bdfc0, ["*", "*", a2], 0)


func f5bee70() -> int:
	return _frontier(0x5bee70, [], 0)


func f5bee80(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x5bee80, [a0, a1, a2], 0)


func f5beeb0() -> int:
	return _frontier(0x5beeb0, [], 0)


func f5beed0() -> int:
	return _frontier(0x5beed0, [], 0)


func f5bf180() -> int:
	return _frontier(0x5bf180, [], 0)


func f5bf1a0() -> int:
	return _frontier(0x5bf1a0, [], 0)


func f5bf230(a0: int, a1: int, a2: int) -> int:
	return _frontier(0x5bf230, [a0, a1, a2], 0)


func f5bf490(a0: int) -> int:
	return _frontier(0x5bf490, [a0], 0)


func f5bf4b0() -> int:
	return _frontier(0x5bf4b0, [], 0)


func f5bf590(a0: int, a1: int) -> int:
	_frontier_empty_text(a0, a1)
	return _frontier(0x5bf590, [a0, a1], a0)


func f5bf800(a0: int) -> int:
	return _frontier(0x5bf800, ["*"], 0)


func f5bf9a0(a0: int, a1: int) -> int:
	return _frontier(0x5bf9a0, [a0, a1], 0)


func f5bf9c0() -> int:
	return _frontier(0x5bf9c0, [], 0)


func f5bfcf0(this_: int, a0: int, a1: int, a2: int, a3: int) -> int:
	return _frontier(0x5bfcf0, [this_, a0, a1, a2, a3], 0)


func f5c03d0(a0: int, a1: int) -> int:
	return _frontier(0x5c03d0, [a0, a1], 0)
