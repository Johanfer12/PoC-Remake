class_name UiRandom
extends RefCounted
## MT de interfaz del original (objeto global 0x5aed28 en Yugi_Pc.exe; Kaiba 533640/5334e0,
## Joey 55c140/55c0e0 son la misma rutina en su ejecutable). No es el rand() del CRT que usa
## el nucleo del duelo: lo comparten janken, bustos, reacciones, mazo del rival, premios,
## efectos y tutorial (21 llamadores en Yugi; inventario en docs/duel/MT_INTERFAZ.md).
##
## 40c140 lo siembra una sola vez al arrancar con GetTickCount (0x40c66a); despues nadie lo
## vuelve a sembrar. En el port hay una instancia compartida (`draw`) sembrada en Game._ready
## con el reloj, o por Debug con --ui-seed=N o con el evento ui_seed de la traza (--ui-replay).

## 531140: indice 0x271 = sin sembrar (al pedir un numero se siembra con 0x1105).
const UNSEEDED := 0x271

var _mt := PackedInt64Array()
var _index := UNSEEDED

static var _shared: UiRandom
## Semilla de la instancia compartida y numeros sacados desde entonces (diagnostico).
static var shared_seed := -1
static var shared_draws := 0
## --ui-rand-log: imprime cada numero ("ui-rand: <n> <valor> <llamador>") para cotejarlo con
## los eventos ui_rand de la traza (el llamador solo sale en compilaciones de depuracion).
static var log_draws := false


func _init(seed_value := -1) -> void:
	_mt.resize(624)
	if seed_value >= 0:
		reseed(seed_value)


## 530fe0: inicializacion antigua de Knuth con el LCG 69069 (0x10dcd), mitad alta de dos pasos.
func reseed(seed_value: int) -> void:
	var value := seed_value & 0xffffffff
	for i in 624:
		var upper := value & 0xffff0000
		value = (value * 69069 + 1) & 0xffffffff
		_mt[i] = upper | (value >> 16)
		value = (value * 69069 + 1) & 0xffffffff
	_index = 624


## 531140: genrand clasico (tabla DAT_005aa6dc = {0, 0x9908b0df}).
func next() -> int:
	if _index >= 624:
		if _index == UNSEEDED:
			reseed(0x1105)
		for i in 624:
			var y := (_mt[i] & 0x80000000) | (_mt[(i + 1) % 624] & 0x7fffffff)
			_mt[i] = (_mt[(i + 397) % 624] ^ (y >> 1) ^ (0x9908b0df if y & 1 else 0)) & 0xffffffff
		_index = 0
	var value: int = _mt[_index]
	_index += 1
	value ^= value >> 11
	value ^= (value & 0xff3a58ad) << 7
	value &= 0xffffffff
	value ^= (value & 0xffffdf8c) << 15
	value &= 0xffffffff
	return (value ^ (value >> 18)) & 0xffffffff


## GetTickCount de 40c140. Se usa la hora del sistema y no Time.get_ticks_msec(): al arrancar
## el motor ese contador vale casi siempre lo mismo y repetiria la secuencia.
static func clock_seed() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0) & 0xffffffff


static func seed_shared(seed_value: int) -> void:
	if _shared == null:
		_shared = UiRandom.new()
	_shared.reseed(seed_value)
	shared_seed = seed_value & 0xffffffff
	shared_draws = 0


## FUN_00531140 sobre el objeto global 0x5aed28.
static func draw() -> int:
	if _shared == null:
		seed_shared(clock_seed())
	shared_draws += 1
	var value := _shared.next()
	if log_draws:
		var stack := get_stack()
		var caller := ""
		for frame in stack.slice(1):
			if not String(frame["source"]).ends_with("duel_portrait_effects.gd") or frame["function"] != "visual_rand":
				caller = "%s:%s:%d" % [String(frame["source"]).get_file(), frame["function"], frame["line"]]
				break
		print("ui-rand: %d %d %s" % [shared_draws, value, caller])
	return value


## FUN_00401ba0: 0 sin llamar al MT si n == 0; si no, MT % n.
static func draw_mod(n: int) -> int:
	return 0 if n == 0 else draw() % n
