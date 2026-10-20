extends RefCounted
## Las transiciones usan superficies lógicas800x600, no píxeles de la ventana.
const SIZE := Vector2i(800, 600)

static func capture(viewport: Viewport) -> Texture2D:
	if DisplayServer.get_name() == "headless": return null
	var texture := viewport.get_texture()
	if texture == null: return null
	var image := texture.get_image()
	if image == null or image.is_empty(): return null
	# La textura del viewport no incluye las barras de la ventana. Aplicar
	# get_final_transform sumaba ese margen y recortaba parte de la escena,
	# que luego se ampliaba a800x600. Usar coordenadas del framebuffer.
	var visible := viewport.get_visible_rect()
	if not visible.has_area(): return null
	var density := Vector2(image.get_size()) / visible.size
	var area := Rect2(-visible.position * density, Vector2(SIZE) * density)
	var bounds := Rect2i(Vector2i.ZERO, image.get_size())
	var region := Rect2i(Vector2i(area.position.round()), Vector2i(area.size.round())).intersection(bounds)
	if not region.has_area(): return null
	var logical := image.get_region(region)
	if logical.get_size() != SIZE: logical.resize(SIZE.x, SIZE.y, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(logical)
