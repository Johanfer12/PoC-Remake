class_name JoeyPortZC
extends JoeyPortZB
## Proyeccion LP opcional del ensayo sin pantalla. 47c560 es el callback visual que
## llama a 573fb0: su escritura de LP forma parte de las reglas. Al activarlo se
## compactan los ticks visuales y se conservan sus pasos saturados de 100/10/1.
## Fuente: re/out/joey/funcs/0047c4d0.c,0047c4f0.c,0047c550.c,0047c560.c,00573fb0.c.

var lp_projection_enabled := false
var _lp_projection: Array = []


func _lp_ready() -> void:
	if _lp_projection.size() == 2:
		return
	for p in range(2):
		_lp_projection.append({"player": p, "visual": m.u16(JoeyMem.pl(p) + 4), "pending": 0,
			"argument": 0, "held": 0, "delay": 0, "phase": 0, "blink": 0})


func lp_projection_state() -> Array:
	_lp_ready()
	return _lp_projection.duplicate(true)


func set_lp_projection_state(state: Array) -> void:
	_lp_projection = state.duplicate(true)


func _lp_side(this_: int) -> int:
	return int(this_ == m.u32(0x5f3280) + 0xea8)


func f47c4d0(this_: int, value: int) -> int:
	_frontier(0x47c4d0, [this_, value], 0)
	if lp_projection_enabled:
		_lp_ready()
		_lp_projection[_lp_side(this_)]["visual"] = maxi(0, _s32(value))
	return 0


func f47c4f0(this_: int, amount: int, argument: int, held: int) -> int:
	_frontier(0x47c4f0, [this_, amount, argument, held], 0)
	if not lp_projection_enabled:
		return 0
	_lp_ready()
	var state: Dictionary = _lp_projection[_lp_side(this_)]
	if int(state["held"]) & 0xff:
		state["held"] = int(state["held"]) & 0xffffff00
		return 0
	state["argument"] = argument & 0xffffffff
	state["delay"] = 0
	state["pending"] = amount & 0xffffffff
	state["held"] = (int(state["held"]) & 0xffffff00) | (held & 0xff)
	f5c03d0(0x10000009 if _s32(amount) < 0 else 0x1000001f, 0)
	return 0


func f47c550(this_: int) -> int:
	_frontier(0x47c550, [this_], 0)
	if lp_projection_enabled:
		_lp_ready()
		var state: Dictionary = _lp_projection[_lp_side(this_)]
		state["pending"] = 0
		state["held"] = int(state["held"]) & 0xffffff00
	return 0


func f573fb0(p: int, delta: int) -> int:
	delta = _s32(delta)
	var value := _s32(m.u16(JoeyMem.pl(p) + 4) + delta)
	m.set_u16(JoeyMem.pl(p) + 4, mini(value, 0xffff) if delta >= 0 else maxi(value, 0))
	return 0


func _lp_tick(state: Dictionary) -> void:
	var amount := _s32(int(state["pending"]))
	state["phase"] = (int(state["phase"]) + int(int(state["blink"]) != 0) + 1) & 0x7f
	var remaining := absi(amount)
	var before := remaining
	if _s32(int(state["delay"])) < 0x100:
		state["delay"] = (int(state["delay"]) + 8) & 0xffffffff
	elif int(state["held"]) & 0xff == 0 and remaining > 0:
		var step := 100 if remaining >= 100 else (10 if remaining >= 10 else 1)
		remaining -= step
		var delta := -step if amount < 0 else step
		state["visual"] = (int(state["visual"]) + delta) & 0xffffffff
		f573fb0(int(state["player"]), delta)
	if remaining != before:
		state["blink"] = 0x1f
	state["pending"] = (-remaining if amount < 0 else remaining) & 0xffffffff
	state["visual"] = clampi(_s32(int(state["visual"])), 0, 0xffff)
	state["blink"] = maxi(0, _s32(int(state["blink"])) - 1)


func flush_projection() -> int:
	if not lp_projection_enabled:
		return 0
	_lp_ready()
	var ticks := 0
	for state: Dictionary in _lp_projection:
		while int(state["pending"]) != 0 and int(state["held"]) & 0xff == 0:
			_lp_tick(state)
			ticks += 1
			if ticks > 70000:
				push_error("Proyeccion LP no converge")
				return ticks
	return ticks
