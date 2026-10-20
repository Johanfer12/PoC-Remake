extends "res://scenes/duel/tutorial_overlay.gd"
## Ka46a520/46ad60: asistente de dos imagenes, desplazamiento por coseno y bob global.
## Popup46a480/46aa20 comparte textos, paginas, cola y geometria con el de Yugi.
func _init() -> void:
	_dir = "kaiba/tutorial/"

func _draw() -> void:
	if _portrait == null: return
	if counter > 16:
		var at := Vector2(_portrait.position(0))
		var tex := Assets.texture(_dir + _portrait.resource((~(Game.native_tick >> 4)) & 1))
		var distance := int(at.x) + tex.get_width() if at.x + tex.get_width() / 2 < 400 else 800 - int(at.x)
		var shift := int((65536 - DuelVisualMath.cos_fx(counter / 2 - 128)) * distance / 65536)
		at.x += -shift if at.x + tex.get_width() / 2 < 400 else shift
		var bob: float = Game.native_blend.at([self, "bob"], DuelVisualMath.cos_fx((Game.native_tick * 8 - 128) & 511) >> 14)
		draw_texture(tex, Vector2(_blend.at("portrait", at.x), at.y + bob))
	_draw_bubble()
