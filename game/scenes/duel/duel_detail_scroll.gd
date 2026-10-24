extends Node2D
##41c920/41c980: la columna pasiva permanece dibujada incluso sin texto.
var _texture: Texture2D
var _scroll: ScrollContainer
func setup(game: String, scroll: ScrollContainer) -> void:
	_texture = Engine.get_main_loop().root.get_node("Assets").texture("%s/duel/detail/scroll_bar.png" % game)
	_scroll = scroll
	#41c920 Joey;411850 Kaiba /4119b0 Yugi conservan su origen propio.
	position = Vector2(186, 364) if game == "joey" else Vector2(189, 365)
func _process(_delta: float) -> void: queue_redraw()
static func plan(active: bool, value: int, maximum: int, state: int = 0) -> Array:
	if not active: return [{"x":186,"y":364,"rect":[0,0,16,162]}]
	var offset := (maximum / 2 + 112 * value) / maximum
	return [{"x":186,"y":364,"rect":[32 if state == -1 else 16,0,48 if state == -1 else 32,16]},
		{"x":186,"y":508,"rect":[32 if state == 1 else 16,144,48 if state == 1 else 32,160]},
		{"x":186,"y":380+offset,"rect":[16,16,32,32]}]
func _draw() -> void:
	if _texture == null or not is_instance_valid(_scroll): return
	var bar := _scroll.get_v_scroll_bar()
	for row in plan(bar.max_value > bar.page, int(bar.value), maxi(1,int(bar.max_value-bar.page))):
		var r: Array = row.rect
		var rect := Rect2(r[0],r[1],r[2]-r[0],r[3]-r[1])
		draw_texture_rect_region(_texture, Rect2(Vector2(row.x,row.y)-Vector2(186,364),rect.size),rect)
