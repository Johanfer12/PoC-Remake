extends Node2D
## Escena optativa del motor Joey. Todas las reglas avanzan mediante5bc700;
## ratón/teclado solo proporcionan las entradas que leería la interfaz original.
var engine: JoeyEngine
var _clock := 0.0
var _buttons := 0
var _choice := -1
var _answer := -1
var _cursor_ready := true
var _busy := false
var _hand_scroll := ScrollContainer.new()
var _finished := false
var _status := Label.new()
var _hint := Label.new()
var _dialog := Label.new()
var _hand := HBoxContainer.new()
var _slots: Array[Dictionary] = []
var _hand_stamp := ""
var _cursor := Vector3i(0, 11, 0)
var _last_message := ""
var _ticks := 0

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("14252c")
	background.size = Vector2(800,600)
	add_child(background)
	_label("Joey · Duelo de monstruos normales", Vector2(20,10), 22)
	_status.position = Vector2(20,43)
	add_child(_status)
	_hint.position = Vector2(20,365)
	_hint.size = Vector2(760,40)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_hint)
	_dialog.position = Vector2(20,555)
	_dialog.size = Vector2(480,40)
	add_child(_dialog)
	_label("Rival",Vector2(20,76),18)
	_label("Tu campo",Vector2(20,217),18)
	for p in range(2):
		for z in range(5):
			var position := Vector2(155+z*113, 103 if p else 243)
			var button := _button("",position,Vector2(104,110),func() -> void:
				_cursor_to(p,0,z)
				_buttons |= 0x200)
			button.mouse_entered.connect(func() -> void: _cursor_to(p,0,z))
			var art := TextureRect.new()
			art.position = Vector2(27,4)
			art.size = Vector2(50,69)
			art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			art.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(art)
			var stats := Label.new()
			stats.position = Vector2(3,76)
			stats.size = Vector2(98,31)
			stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			stats.add_theme_font_size_override("font_size",12)
			stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(stats)
			_slots.append({"p":p,"z":z,"button":button,"art":art,"stats":stats})
	_button("Batalla",Vector2(20,105),Vector2(115,34),func() -> void: _choice=3; _cursor_ready=false)
	_button("Fin del turno",Vector2(20,146),Vector2(115,34),func() -> void: _choice=5; _cursor_ready=false)
	_button("Confirmar",Vector2(20,247),Vector2(115,34),func() -> void: _buttons|=0x200)
	_button("Otra acción",Vector2(20,288),Vector2(115,34),func() -> void: _buttons|=0x400)
	_button("Sí",Vector2(520,553),Vector2(70,30),func() -> void: _answer=1; _cursor_ready=false)
	_button("No",Vector2(595,553),Vector2(70,30),func() -> void: _answer=0; _cursor_ready=false)
	_button("Volver",Vector2(685,553),Vector2(90,30),func() -> void: Game.open_title("joey"))
	_hand_scroll.position=Vector2(20,420)
	_hand_scroll.size=Vector2(760,130)
	_hand_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_AUTO
	_hand_scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_hand_scroll)
	_hand.add_theme_constant_override("separation",7)
	_hand_scroll.add_child(_hand)
	_label("Tu mano · selecciona una carta y confirma. Clic derecho o Tab cambia de acción.",Vector2(20,393),13)
	engine = JoeyEngine.create(Paths.data_dir)
	if engine == null:
		_status.text = "No se pudieron cargar los datos de Joey."
		set_process(false)
		return
	if not _prepare_decks():
		_status.text = "No hay suficientes monstruos normales para preparar los mazos."
		set_process(false)
		return
	engine.f5bfeb0(0,0,0x1729)
	engine.m.set_u32(JoeyMem.MODE,(engine.m.u32(JoeyMem.MODE)&~6)|4)
	engine.lp_projection_enabled = true
	engine.set_lp_projection_state([])
	engine.ui_enabled = true
	engine.ui_set_cursor(0,11,0)
	_refresh()

func _label(text: String, at: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text=text
	label.position=at
	label.add_theme_font_size_override("font_size",font_size)
	add_child(label)
	return label

func _button(text: String, at: Vector2, size_: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text=text
	button.position=at
	button.custom_minimum_size=size_
	button.size=size_
	button.focus_mode=Control.FOCUS_NONE
	button.pressed.connect(action)
	add_child(button)
	return button

func _prepare_decks() -> bool:
	var pool: Array[int] = []
	for index in range(1,engine.cards.ids.size()):
		var kind := engine.f4025d0(index)
		var attack := engine.f4027b0(index)&0xffff
		var level := engine.f4026c0(index)&0xffff
		if kind>0 and kind<21 and ((engine.f4025f0(index)>>18)&3)==0 and level>=1 and level<=4 and attack>=500 and attack<2000 and engine._s32(engine.f59dbe0(index))<0:
			pool.append(index)
	pool.sort_custom(func(a: int,b: int) -> bool:
		var aa := engine.f4027b0(a)&0xffff
		var ab := engine.f4027b0(b)&0xffff
		return engine.f4022e0(a)<engine.f4022e0(b) if aa==ab else aa<ab)
	var strong: Array[int] = []
	var weak: Array[int] = []
	for index in pool:
		var atk := engine.f4027b0(index)&0xffff
		var def := engine.f402800(index)&0xffff
		if atk>=1500 and def<=atk:
			strong.append(index)
		if atk<=1000 and def<=1000:
			weak.append(index)
	if strong.size()<14 or weak.size()<14:
		return false
	# Dos mazos legales40cartas/14identidades/maximo3copias; el humano empieza.
	for p in range(2):
		var selected: Array = strong.slice(-14) if p==0 else weak.slice(0,14)
		var address := 0xa54e60+p*0xe2
		engine.m.clear(address,0xe2)
		var n := 0
		for i in selected.size():
			for copy in range(3 if i<12 else 2):
				engine.m.set_u16(address+n*2,selected[i])
				n+=1
		engine.m.set_u16(address+0xdc,n)
	return true

func _cursor_to(p: int,area: int,index: int) -> void:
	_cursor=Vector3i(p,area,index)
	_cursor_ready=true
	if engine!=null:
		engine.ui_set_cursor(p,area,index)

func _unhandled_input(event: InputEvent) -> void:
	if engine==null or _finished:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT:
		_buttons|=0x100
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ENTER,KEY_SPACE: _buttons|=1
			KEY_TAB: _buttons|=0x400
			KEY_ESCAPE: _buttons|=2
			KEY_LEFT: _cursor_to(_cursor.x,_cursor.y,maxi(0,_cursor.z-1))
			KEY_RIGHT:
				var limit := engine.m.u8(JoeyMem.pl(_cursor.x)+8) if _cursor.y==11 else 5
				_cursor_to(_cursor.x,_cursor.y,mini(maxi(0,limit-1),_cursor.z+1))
			KEY_UP: _cursor_to(1 if _cursor.y==0 and _cursor.x==0 else 0,0,_cursor.z%5)
			KEY_DOWN: _cursor_to(0,11,0)

func _process(delta: float) -> void:
	if engine==null or _finished:
		return
	_clock+=delta*60.0
	for i in mini(int(_clock),4):
		_clock-=1.0
		_native_step()
		if _finished:
			break
	_refresh()

## Un fotograma lógico. Se expone para repetir entradas físicas en las pruebas de escena.
func _native_step() -> void:
	engine.events.clear()
	engine.recorded.clear()
	engine.ui_cursor_ready=_cursor_ready and (engine.m.u8(JoeyMem.TURN)&1)==0
	engine.ui_busy=_busy
	engine.ui_press(_buttons)
	if _choice>=0:
		engine.phase_choice=_choice
	if _answer>=0:
		engine.ui_answer(_answer)
	var done := engine.f5bc700()
	engine.flush_projection()
	for event in engine.events:
		if event.get("kind")=="5bf800":
			_last_message="Confirma tu elección para continuar."
	_buttons=0
	_choice=-1
	_answer=-1
	engine.phase_choice=0
	_ticks+=1
	if done:
		_finished=true

func set_input_state(input: Dictionary) -> void:
	if input.has("cursor"):
		var cursor: Array=input.cursor
		_cursor_to(int(cursor[0]),int(cursor[1]),int(cursor[2]))
	_cursor_ready=bool(input.get("ready",false))
	_busy=bool(input.get("busy",false))
	_buttons=int(input.get("buttons",0))

func _refresh() -> void:
	var p := engine.m.u8(JoeyMem.TURN)&1
	var phase := (engine.m.u8(JoeyMem.TURN)>>1)&7
	var phases := ["Robo","Espera","Principal1","Batalla","Principal2","Fin"]
	_status.text="Tú %d LP  ·  Rival %d LP  ·  Turno %d: %s  ·  %s"%[engine.m.u16(JoeyMem.pl(0)+4),engine.m.u16(JoeyMem.pl(1)+4),engine.m.u16(0xa577f8),"tu turno" if p==0 else "rival",phases[phase] if phase<phases.size() else "Preparando"]
	var action := (engine.m.u8(0xa57804)>>3)&15
	var actions := ["Invocar","Voltear","Atacar","Activar","Invocación especial","Cambiar posición","Cambiar posición","Cambiar fase","Rendirse","","Colocar en ataque","Colocar en defensa","Ver lista"]
	_hint.text=("Acción seleccionada: "+actions[action]) if action<actions.size() and engine.m.u16(0xa57806)!=0 else "Selecciona una carta de tu mano o del campo."
	_dialog.text=_last_message
	if _finished:
		_dialog.text="Has ganado." if engine.m.u16(JoeyMem.pl(1)+4)==0 else "Duelo terminado."
	for row in _slots:
		var at := JoeyMem.zone(row.p,row.z)
		var card := engine.m.u32(at)&0xfff
		var flags := engine.m.u16(at+6)
		var hidden: bool = row.p==1 and (flags&2)==0
		row.art.texture=CardDB.card_texture(engine.f4022e0(card)) if card!=0 and not hidden else (Assets.texture("common/card/card_ura.png") if card else null)
		row.stats.text=("Boca abajo" if hidden else "%d / %d"%[engine.f56f690(row.p,row.z),engine.f56f6b0(row.p,row.z)]) if card else "Vacío"
		row.button.modulate=Color("b5edff") if _cursor==Vector3i(row.p,0,row.z) else Color.WHITE
	for owner in range(2):
		var anchors := PackedInt32Array()
		for i in engine.m.u8(JoeyMem.pl(owner)+8):
			anchors.append(20+i*94)
		var fields := PackedInt32Array()
		fields.resize(16)
		for z in range(11):
			fields[z]=155+(z%5)*113
		for z in range(12,16):
			fields[z]=35
		if engine.has_method("ui_set_geometry"):
			engine.call("ui_set_geometry",owner,anchors,fields,-_hand_scroll.scroll_horizontal if owner==0 else 0,0)
	var count := engine.m.u8(JoeyMem.pl(0)+8)
	var stamp := str(count)+":"
	for i in count:
		stamp+=str(engine.m.u32(JoeyMem.pl(0)+0x6d4+i*4))+":"
	if stamp!=_hand_stamp:
		_hand_stamp=stamp
		for child in _hand.get_children():
			_hand.remove_child(child)
			child.queue_free()
		for i in count:
			var card := engine.m.u32(JoeyMem.pl(0)+0x6d4+i*4)&0xfff
			var button := Button.new()
			button.custom_minimum_size=Vector2(87,115)
			button.focus_mode=Control.FOCUS_NONE
			button.tooltip_text=CardDB.name_of(engine.f4022e0(card))
			button.pressed.connect(func() -> void: _cursor_to(0,11,i); _buttons|=0x200)
			button.mouse_entered.connect(func() -> void: _cursor_to(0,11,i))
			_hand.add_child(button)
			var art := TextureRect.new()
			art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			art.texture=CardDB.card_texture(engine.f4022e0(card))
			art.position=Vector2(5,4)
			art.size=Vector2(77,107)
			art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			art.mouse_filter=Control.MOUSE_FILTER_IGNORE
			button.add_child(art)
	for i in _hand.get_child_count():
		var child: Control=_hand.get_child(i)
		child.modulate=Color("b5edff") if _cursor==Vector3i(0,11,i) else Color.WHITE
