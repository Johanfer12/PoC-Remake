extends Node2D
## Joey41bb40: atributo y raza en la franja inferior del detalle41be80.
const ATTRIBUTES := ["light","dark","water","fire","earth","wind"]
var _items: Array = []
func show_card(card: Dictionary) -> void:
	_items.clear()
	var race := int(card.get("type_id",0))
	var attribute := ATTRIBUTES.find(str(card.get("attribute","")))
	if race > 0 and race < 21 and attribute >= 0:
		_items = [{"atlas":0,"index":attribute,"pos":Vector2(7,512)},
			{"atlas":1,"index":race-1,"pos":Vector2(23,512)}]
	queue_redraw()
func _draw() -> void:
	for item in _items:
		var path := "joey/duel/card/icon_zokusei.png" if item.atlas == 0 else "joey/duel/card/icon_syuzoku.png"
		var texture := Assets.texture(path)
		if texture == null: continue
		var count := 10 if item.atlas == 0 else 20
		var width := int(texture.get_width()/count)
		var src := Rect2(item.index*width,0,width,texture.get_height())
		draw_texture_rect_region(texture,Rect2(item.pos,src.size),src)
