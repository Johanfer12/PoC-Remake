extends RefCounted
## Y44d430/Ka44e930/Jo46f390: cambio de la carta grande, paso16 y ancho coseno.
var requested := -1
var displayed := -1
var counter := 128
var phase := 0

func request(id: int) -> void:
	if id == requested: return
	requested = id
	if phase == 0:
		counter = 240
		phase = 1
	elif phase == 2:
		counter = 256
		phase = 3
	else:
		counter = 0
		phase = 1

func tick() -> void:
	if phase == 1:
		counter = mini(256, counter + 16)
		if counter > 128: displayed = requested
		if counter == 256:
			phase = 2
			counter = -1 # 44d430 deja el cache completo y termina el render.
	elif phase == 3:
		counter = maxi(0, counter - 16)
		if counter < 128: displayed = requested
		if counter == 0:
			phase = 4
			counter = -1

func frame(width := 200) -> Dictionary:
	if phase == 0 or counter in [-1, 0, 256]:
		return {"id": displayed, "width": width, "x": 7, "alpha": 255}
	var cosine := DuelVisualMath.cos_fx(-counter if counter < 128 else counter - 256)
	var extent := (cosine * width) >> 16
	return {"id": displayed, "width": extent, "x": width / 2 - extent / 2 + 7,
		"alpha": ((cosine * 207) >> 16) + 48}
