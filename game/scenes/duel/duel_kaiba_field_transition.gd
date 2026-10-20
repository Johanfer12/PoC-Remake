extends RefCounted
## Kaiba435fb0/436180: superficie persistente, fragmentos MT%20 en los ticks impares.
var counter := 0
var cells: Array[int] = []
var draws := 0
var texture: ImageTexture

static func cell_rect(index: int) -> Rect2i:
	var row := index / 5
	return Rect2i(99 + index % 5 * 78, 89 + row * 100 + int(row > 1) * 20, 78, 100)

func advance(to_counter: int) -> void:
	var changed := false
	while counter < mini(to_counter, 384):
		counter += 8
		if counter >= 384 or (counter / 8 & 1) == 0: continue
		for _i in counter * 20 / 384:
			var cell := UiRandom.draw() % 20
			draws += 1
			if cell not in cells:
				cells.append(cell)
				changed = true
	if not changed and texture != null: return
	var image := Image.create(570, 600, false, Image.FORMAT_L8)
	for cell in cells: image.fill_rect(cell_rect(cell), Color.WHITE)
	if texture == null: texture = ImageTexture.create_from_image(image)
	else: texture.update(image)
