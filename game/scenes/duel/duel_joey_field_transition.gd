extends RefCounted
## 449ca0/424ca0: copia acumulada del terreno nuevo con pincel horizontal de64px
## sobre36 segmentos. Coordenadas relativas al bitmap570x600, sin interpolacion.
static var _masks: Array[Texture2D] = []

static func endpoint(n: int) -> Vector2i:
	if n < 0: return Vector2i(65, 72)
	var half := n / 2
	if (n & 1) != 0: return Vector2i(maxi(0, half - 9) * 50 + 65, mini(9, half) * 50 + 72)
	return Vector2i(mini(9, half + 1) * 50 + 65, maxi(0, half - 8) * 50 + 72)

static func _row(bytes: PackedByteArray, x: int, y: int) -> void:
	if y < 0 or y >= 600: return
	for column in range(maxi(0, x - 32), mini(570, x + 32)):
		bytes[y * 570 + column] = 255

static func _line(bytes: PackedByteArray, from: Vector2i, to: Vector2i) -> void:
	var dx := absi(to.x - from.x)
	var dy := absi(to.y - from.y)
	var step := 1 if to.x > from.x and to.y > from.y else -1
	if dy < dx:
		if to.x < from.x:
			if to.y < from.y: step = 1
			var swap := from
			from = to
			to = swap
		var error := dx / 2
		var y := from.y
		for x in range(from.x, to.x + 1):
			_row(bytes, x, y)
			error -= dy
			if error < 0:
				error += dx
				y += step
	else:
		if to.y < from.y:
			if to.x < from.x: step = 1
			var swap := from
			from = to
			to = swap
		var error := dy / 2
		var x := from.x
		for y in range(from.y, to.y + 1):
			_row(bytes, x, y)
			error -= dx
			if error < 0:
				error += dy
				x += step

static func mask(counter: int) -> Texture2D:
	if _masks.is_empty():
		var bytes := PackedByteArray()
		bytes.resize(570 * 600)
		for n in 36:
			_line(bytes, endpoint(n - 1), endpoint(n))
			_masks.append(ImageTexture.create_from_image(Image.create_from_data(570, 600, false, Image.FORMAT_L8, bytes)))
	return _masks[clampi(counter * 36 / 384, 0, 35)]
