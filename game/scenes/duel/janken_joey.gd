extends "res://scenes/duel/janken_scene.gd"
## Init45e670/update460640. El jugador local nativo es1 (44bee0), mientras que el
## nucleo compartido del port usa0: _button guarda el valor efectivo boton^5f3288.
## Los dibujos45ffa0/460200 usan ese valor efectivo; finished entrega opciones del port.

func _init() -> void:
	super("joey")

func _initial_scroll() -> int:
	return (UiRandom.draw() % 3 + 5) * W * 256   # 45e670: MT 55c140

func _ready() -> void:
	super._ready()
	if _button >= 0: _button ^= 1

func _cpu_choose() -> void:
	super._cpu_choose()
	_button ^= 1

func _enter_buttons() -> void:
	# 460d81: dieciseis pasos, manos completas; las paredes las cubren.
	_t += 16
	_hands_draw(Rect2i(X1, Y0, X2 - X1, Y3 - Y0))
	_buttons_draw()
	_frame_draw()
	if _t >= 256:
		if _result != 2: _warp(Vector2(400, H / 2 + Y0))
		_next()

func _frame_draw() -> void:
	# 45e9f0: cintas horizontales, piezas fijas, centro y columnas delante de las manos.
	var spread := 0
	if _state == 3: spread = (400 - W) / 2 * mini(absi(_t), 128) * 2
	elif _state > 3: spread = (400 - W) / 2 << 8
	for x in [0, 200, 400, 600]:
		var top := posmod((_scroll_cpu + (spread if x < 400 else -spread)) / 768, 6)
		var bottom := posmod((_scroll_me + (-spread if x < 400 else spread)) / 768, 6)
		_blit(33 + top, Vector2(x, 0))
		_blit(33 + bottom, Vector2(x, Y3))
		if x == 0 or x == 600:
			_blit(38 - top, Vector2(x, Y1))
			_blit(38 - bottom, Vector2(x, 300))
	for index in [1, 6, 9, 4]: _blit(index, _layout.position(index))
	var v := 256
	if _state == 1: v = maxi(256, _t * 256 / 8 + 256)
	elif _state == 2: v = maxi(256, 512 - _t * 256 / 8)
	elif _state == 3: v = (128 - mini(absi(_t), 128)) * 2
	_middle_draw(v)
	_strips_draw()

func _belt(index: int, pos: Vector2) -> void:
	# 4226c0(90 grados): coordenada superior izquierda del rectangulo girado.
	var size := _tex[index].get_size()
	_cmds.append(["rot", index, pos + Vector2(NativeJankenRaster.top_left_center(Vector2i(size), 128)), 128, Rect2i()])


func _command_piece(cmd: Array) -> Array:
	var piece := super._command_piece(cmd)
	if cmd[1] >= 33 and cmd[1] <= 38:
		# 45e9f0 cambia el fotograma de cada casilla fija, no mueve una cinta hasta otra.
		# Las columnas4226c0 conservan fila/lado cuando se desplazan al entrar los botones.
		var at: Vector2 = cmd[2]
		if cmd[0] == "tex": piece.append(at)
		elif cmd[0] == "rot": piece.append([at.y, at.x < 400])
	return piece

func _strips_draw() -> void:
	super._strips_draw()
	if _state > 4:
		var displacement := W * maxi(0, (128 - _t) * 2) / 256 if _state == 5 else 0
		for y in [Y0, Y2]:
			if _state == 5 and _t < 128:
				_belt(33, Vector2(200 - displacement, y))
				_belt(33, Vector2(550 + displacement, y))
			_blit(39, Vector2(-_layout.position(39).x - displacement, y))
			_blit(40, Vector2(X2 - _layout.position(40).x + displacement, y))
	for index in [0, 3, 2, 5]: _blit(index, _layout.position(index))

func _buttons_draw() -> void:
	if _state == 5:
		var close := 0 if _t < 128 else DuelVisualMath.cos_fx((_t - 256) & 511) * H >> 16
		_button_blit(0, Vector2(X1, Y0 - H + close), 256)
		_blit(7, Vector2(X1, Y1), mini(_t, 255) / 256.0)
		_button_blit(1, Vector2(X1, Y3 - close), 256)
	elif _state == 7:
		_cmds.append(["fill", Rect2i(X1, Y0, X2 - X1, Y3 - Y0)])
		_blit(41, Vector2(200, Y1))
		_blit(42, Vector2(550, Y1))
		var move := clampi(_t - 128, 0, 128)
		if _t < 128: _blit(7, Vector2(X1, Y1), (128 - _t) * 2 / 256.0)
		var other := int(_button == 0)
		_button_blit(other, Vector2(X1, Y2 if _button == 0 else Y0), (128 - _t) * 2)
		var base := Y0 if _button == 0 else Y2
		_button_blit(_button, Vector2(X1, (300 - H / 2 - base) * move / 128 + base), 256)
	else:
		super._buttons_draw()

func _button_blit(which: int, pos: Vector2, alpha: int) -> void:
	if _state != 5 or _t >= 128:
		var frame := posmod((int(pos.y) + 600) / 2, 6)
		var y := Y0 if which == 0 else Y2
		_belt(33 + frame, Vector2(pos.x, y))
		_belt(38 - frame, Vector2(pos.x + 350, y))
	super._button_blit(which, pos + Vector2(50, 0), alpha)
