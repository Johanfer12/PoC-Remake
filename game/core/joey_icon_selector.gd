extends RefCounted
## Joey 441c90/442640 y 4420d0/442a70: respuesta índice o máscara, sin Sí/No.
var kind := 4
var target := 0
var enabled := 0
var selected := 0
var count := 0
var counter := 0
var answer := -1
var complete := false
func setup(value: int, arg: int) -> void:
	kind = value
	target = arg & 255
	enabled = (arg >> 8) & 255
func select(index: int) -> bool:
	if complete: return false
	if kind == 4:
		if index < 0 or index >= 20: return false
		answer = index
		complete = true
		return true
	var bit := 1 << index
	if index < 0 or index >= 6 or not (enabled & bit): return false
	counter = 0
	enabled ^= bit
	selected |= bit
	count += 1
	answer = selected
	complete = count == target
	return true
func tick() -> bool:
	if complete or count > 0: counter += 1
	return complete and counter > 15 # vtable442210: no >=15.
func alpha(index: int, hover: int) -> int:
	if kind == 4: return 256 if index == hover and not (counter & 2) else 128
	var bit := 1 << index
	if (selected & bit) and not (counter & 2): return 256
	if not (enabled & bit): return 32
	return 256 if index == hover else 128
static func origin(value: int, index: int, center := Vector2i(525,300)) -> Vector2i:
	if value == 4: return center + Vector2i((index % 10 - 5) * 32, (index / 10) * 32 - 32)
	return center + Vector2i((index - 3) * 32, -16)
