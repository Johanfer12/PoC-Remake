class_name TitleArt
extends RefCounted
## Composicion del fondo de titulo de cada juego, a 800x600, a partir de su title.txt.
## Lo usa la pantalla de titulo; el selector de juego solo usa los logos.
##
## Esquema por juego (verificado componiendo las pantallas):
## - Yugi:  version comercial (0x466e70): TITLE1 y despues TITLE2g (item 6, con logo; TITLE2e
##          es la variante "jump", elegida por Region.dat en 0x40a830) como fondo del menu.
## - Kaiba: fondo "TITLE_e" + logo "titlelogo_e" CENTRADO en su coordenada (400,144).
## - Joey:  fondo "TITLE_1_?" + logo "joey_logo" con esquina superior izquierda en (120,10).

const SCRIPT := "%s/title/title.txt"


static func splash_texture(_game: String) -> Texture2D:
	return null   # Yugi entra con la transicion del estado 1 de 0x467000 (title_screen.gd)


static func build_background(game: String, with_logo := true) -> Node2D:
	var root := Node2D.new()
	var layout := Assets.layout(SCRIPT % game)
	match game:
		"yugi":
			_add(root, Assets.texture("yugi/title/title2g.bmp"), Vector2.ZERO)
		"kaiba":
			_add(root, Assets.texture("kaiba/title/title_e.bmp"), Vector2.ZERO)
			if with_logo:
				var i := layout.index_of("titlelogo_e.yga")
				var logo := Assets.texture("kaiba/title/titlelogo_e.yga")
				_add(root, logo, Vector2(layout.position(i)) - logo.get_size() / 2.0)
		"joey":
			_add(root, Assets.texture("joey/title/TITLE_1_?.bmp"), Vector2.ZERO)
			if with_logo:
				var i := layout.index_of("joey_logo.bmp")
				_add(root, Assets.texture("joey/title/joey_logo.bmp"), Vector2(layout.position(i)))
	return root


## Logo suelto para el selector de juego. El de Yugi no existe como imagen en el original:
## lo recorta del splash el conversor (pocx logo).
static func logo_texture(game: String) -> Texture2D:
	match game:
		"yugi":
			return Assets.texture("yugi/title/yugi_logo.png")
		"kaiba":
			return Assets.texture("kaiba/title/titlelogo_e.yga")
		"joey":
			return Assets.texture("joey/title/joey_logo.bmp")
	return null


static func _add(parent: Node2D, tex: Texture2D, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = pos
	parent.add_child(s)
	return s
