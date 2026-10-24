class_name NativeJankenRaster
extends RefCounted
## 415cc0/415ec0 -> 4fc880/500bf0: vértices enteros y líneas inclusivas fixed20.
## Caché acotada: conserva la selección nativa del texel sin depender de triángulos GPU.
const FX := 1048576
const HALF := 524288
const CACHE_LIMIT := 192
static var _cache: Dictionary = {}
static var _order: Array = []
const RASTER_SHADER := preload("res://shaders/native_janken_raster.gdshader")

static func begin(canvas: CanvasItem) -> void:
	if not canvas.has_meta("native_raster_material"):
		var material := ShaderMaterial.new()
		material.shader = RASTER_SHADER
		canvas.material = material
		canvas.set_meta("native_raster_material", material)
	canvas.set_meta("native_raster_rows", PackedFloat32Array())
	canvas.set_meta("native_raster_transient_meshes", [])

static func finish(canvas: CanvasItem) -> void:
	var rows: PackedFloat32Array = canvas.get_meta("native_raster_rows")
	if rows.is_empty(): return
	var image := Image.create_from_data(2, rows.size() / 8, false, Image.FORMAT_RGBAF, rows.to_byte_array())
	var material: ShaderMaterial = canvas.get_meta("native_raster_material")
	material.set_shader_parameter("native_rows", ImageTexture.create_from_image(image))

static func draw_scaled(canvas: CanvasItem, tex: Texture2D, target: Rect2) -> void:
	var size := Vector2i(target.size)
	if tex == null or size.x <= 0 or size.y <= 0: return
	var rows: PackedFloat32Array = canvas.get_meta("native_raster_rows")
	var row := rows.size() / 8
	rows.append_array(PackedFloat32Array([-65536,size.x,size.y,0,0,0,tex.get_width(),tex.get_height()]))
	canvas.set_meta("native_raster_rows",rows)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector2Array([target.position,Vector2(target.end.x,target.position.y),target.end,Vector2(target.position.x,target.end.y)])
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([Vector2(-row-1,0),Vector2(-row-1,1),Vector2(-row-1.25,1),Vector2(-row-1.25,0)])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0,1,2,0,2,3])
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var meshes: Array = canvas.get_meta("native_raster_transient_meshes")
	meshes.append(mesh)
	canvas.set_meta("native_raster_transient_meshes",meshes)
	canvas.draw_mesh(mesh,tex)

static func vertices(size: Vector2i, angle: int) -> Array[Vector2i]:
	var c := DuelVisualMath.cos_fx(angle)
	var s := DuelVisualMath.sin_fx(angle)
	var left := -( (size.x - 1) / 2 )
	var top := -( (size.y - 1) / 2 )
	var right := size.x / 2
	var bottom := size.y / 2
	var result: Array[Vector2i] = []
	for p: Vector2i in [Vector2i(left, top), Vector2i(right, top), Vector2i(right, bottom), Vector2i(left, bottom)]:
		result.append(Vector2i((p.x * c - p.y * s) >> 16, (p.y * c + p.x * s) >> 16))
	return result

static func top_left_center(size: Vector2i, angle: int) -> Vector2i:
	# 4226c0: las cardinales reciben esquina superior izquierda, no centro W/H.
	var points := vertices(size, angle)
	var minimum := points[0]
	for point: Vector2i in points: minimum = minimum.min(point)
	return -minimum

static func _chain(points: Array[Vector2i], uv: Array[Vector2i], start: int, finish: int, direction: int) -> Array:
	var result := []
	var i := start
	while i != finish:
		var j := posmod(i + direction, 4)
		if points[j].y > points[i].y:
			result.append([points[i], points[j], uv[i], uv[j]])
		i = j
	return result

static func _edge_at(chain: Array, y: int) -> PackedInt64Array:
	var edge: Array = chain.back()
	for candidate: Array in chain:
		if y < candidate[1].y:
			edge = candidate
			break
	var a: Vector2i = edge[0]
	var b: Vector2i = edge[1]
	var u: Vector2i = edge[2]
	var v: Vector2i = edge[3]
	var dy := b.y - a.y
	var t := y - a.y
	return PackedInt64Array([a.x * FX + HALF + t * ((b.x - a.x) * FX / dy),
		u.x * FX + HALF + t * ((v.x - u.x) * FX / dy),
		u.y * FX + HALF + t * ((v.y - u.y) * FX / dy)])

static func raster(source: Image, angle: int, clip: Rect2i = Rect2i()) -> Dictionary:
	var size := source.get_size()
	var points := vertices(size, angle)
	var uv: Array[Vector2i] = [Vector2i.ZERO, Vector2i(size.x - 1, 0), size - Vector2i.ONE, Vector2i(0, size.y - 1)]
	var first := 0
	var last := 0
	var minimum := points[0]
	var maximum := points[0]
	for i in range(1, 4):
		if points[i].y < points[first].y or (points[i].y == points[first].y and points[i].x < points[first].x): first = i
		if points[i].y > points[last].y or (points[i].y == points[last].y and points[i].x > points[last].x): last = i
		minimum = minimum.min(points[i])
		maximum = maximum.max(points[i])
	var left := _chain(points, uv, first, last, -1)
	var right := _chain(points, uv, first, last, 1)
	var output_size := maximum - minimum + Vector2i.ONE
	var pixels := PackedByteArray()
	pixels.resize(output_size.x * output_size.y * 4)
	if left.is_empty() or right.is_empty():
		return {"image": Image.create_from_data(output_size.x, output_size.y, false, Image.FORMAT_RGBA8, pixels), "offset": minimum}
	var input := source.get_data()
	for y in range(minimum.y, maximum.y + 1):
		if clip.has_area() and (y < clip.position.y or y >= clip.end.y): continue
		var a := _edge_at(left, y)
		var b := _edge_at(right, y)
		var x0 := a[0] >> 20
		var x1 := b[0] >> 20
		var width := x1 - x0
		var u0 := a[1] >> 20
		var v0 := a[2] >> 20
		var du := ((b[1] >> 20) - u0) * FX / width if width != 0 else 0
		var dv := ((b[2] >> 20) - v0) * FX / width if width != 0 else 0
		var start := x0
		var end := x1
		var skip := 0
		if clip.has_area():
			if a[0] > clip.end.x * FX - HALF or b[0] < clip.position.x * FX + HALF: continue
			if a[0] < clip.position.x * FX + HALF:
				start = clip.position.x
				skip = (clip.position.x * FX + HALF - a[0]) >> 20
			if b[0] > clip.end.x * FX - HALF: end = clip.end.x - 1
		for x in range(start, end + 1):
			var u := u0 + ((x - start + skip) * du >> 20)
			var v := v0 + ((x - start + skip) * dv >> 20)
			if u < 0 or u >= size.x or v < 0 or v >= size.y: continue
			var src := (v * size.x + u) * 4
			var dst := ((y - minimum.y) * output_size.x + x - minimum.x) * 4
			pixels[dst] = input[src]
			pixels[dst + 1] = input[src + 1]
			pixels[dst + 2] = input[src + 2]
			pixels[dst + 3] = input[src + 3]
	return {"image": Image.create_from_data(output_size.x, output_size.y, false, Image.FORMAT_RGBA8, pixels), "offset": minimum}

static func draw(canvas: CanvasItem, tex: Texture2D, center: Vector2, angle: float, clip: Rect2i) -> void:
	if tex == null: return
	var turn := posmod(roundi(angle), 512)
	var local_clip := Rect2i(clip.position - Vector2i(center), clip.size) if clip.has_area() else Rect2i()
	var rows: PackedFloat32Array = canvas.get_meta("native_raster_rows")
	var first_row := rows.size() / 8
	var key := "%d:%d:%s:%d" % [tex.get_instance_id(), turn, local_clip, first_row]
	if not _cache.has(key):
		var item := _mesh(Vector2i(tex.get_size()), turn, local_clip, first_row)
		_cache[key] = item
		_order.append(key)
		if _order.size() > CACHE_LIMIT: _cache.erase(_order.pop_front())
	var entry: Dictionary = _cache[key]
	rows.append_array(entry.rows)
	canvas.set_meta("native_raster_rows", rows)
	if entry.mesh != null:
		canvas.draw_set_transform(center)
		canvas.draw_mesh(entry.mesh, tex)
		canvas.draw_set_transform(Vector2.ZERO)

static func _mesh(size: Vector2i, angle: int, clip: Rect2i, first_row: int) -> Dictionary:
	var points := vertices(size, angle)
	var uv: Array[Vector2i] = [Vector2i.ZERO, Vector2i(size.x - 1, 0), size - Vector2i.ONE, Vector2i(0, size.y - 1)]
	var first := 0
	var last := 0
	for i in range(1, 4):
		if points[i].y < points[first].y or (points[i].y == points[first].y and points[i].x < points[first].x): first = i
		if points[i].y > points[last].y or (points[i].y == points[last].y and points[i].x > points[last].x): last = i
	var left := _chain(points, uv, first, last, -1)
	var right := _chain(points, uv, first, last, 1)
	var rows := PackedFloat32Array()
	var verts := PackedVector2Array()
	var coords := PackedVector2Array()
	var indices := PackedInt32Array()
	if not left.is_empty() and not right.is_empty():
		for y in range(points[first].y, points[last].y + 1):
			if clip.has_area() and (y < clip.position.y or y >= clip.end.y): continue
			var a := _edge_at(left,y)
			var b := _edge_at(right,y)
			var start := a[0] >> 20
			var end := b[0] >> 20
			var width := end - start
			var u0 := a[1] >> 20
			var v0 := a[2] >> 20
			var du := ((b[1] >> 20) - u0) * FX / width if width != 0 else 0
			var dv := ((b[2] >> 20) - v0) * FX / width if width != 0 else 0
			var skip := 0
			if clip.has_area():
				if a[0] > clip.end.x * FX - HALF or b[0] < clip.position.x * FX + HALF: continue
				if a[0] < clip.position.x * FX + HALF:
					start = clip.position.x
					skip = (clip.position.x * FX + HALF - a[0]) >> 20
				if b[0] > clip.end.x * FX - HALF: end = clip.end.x - 1
			if end < start: continue
			var row := first_row + rows.size() / 8
			rows.append_array(PackedFloat32Array([u0,v0,du >> 16,du & 65535,dv >> 16,dv & 65535,size.x,size.y]))
			var at := verts.size()
			verts.append_array(PackedVector2Array([Vector2(start,y),Vector2(end+1,y),Vector2(end+1,y+1),Vector2(start,y+1)]))
			coords.append_array(PackedVector2Array([Vector2(-row-1,skip),Vector2(-row-1,skip+end-start+1),Vector2(-row-1,skip+end-start+1),Vector2(-row-1,skip)]))
			indices.append_array(PackedInt32Array([at,at+1,at+2,at,at+2,at+3]))
	var mesh: ArrayMesh
	if not verts.is_empty():
		mesh = ArrayMesh.new()
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = verts
		arrays[Mesh.ARRAY_TEX_UV] = coords
		arrays[Mesh.ARRAY_INDEX] = indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return {"mesh": mesh, "rows": rows}
