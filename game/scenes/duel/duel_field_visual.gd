extends Node2D
## FUN_00402fa0 / 00435cc0: terreno global, independiente del propietario de la carta.
const Math = preload("res://scenes/duel/duel_visual_math.gd")
const JoeyTransition = preload("res://scenes/duel/duel_joey_field_transition.gd")
const KaibaTransition = preload("res://scenes/duel/duel_kaiba_field_transition.gd")
const TERRAIN_ADDR := 0xa133ec
const NAMES := ["normal", "mori", "kouya", "yama", "sougen", "umi", "yami", "sanctu", "gaia", "water", "burn", "desert", "shine", "dark", "fusion"]
# field.txt: 2 entradas auxiliares y pares animación/fondo por terreno.
# 435cc0 resuelve el fondo con índice 2 + terreno * 2; no usa otra edición.
const TERRAIN_COUNTS := {"yugi": 7, "kaiba": 14, "joey": 15}
const CHANGE_FRAMES := 81 # 435940: contador +8, final >=640, incluye el fotograma inicial.
const WIPE_CODE := """
shader_type canvas_item;
uniform float displacement = 0.0;
uniform float height_pixels = 600.0;
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	float y = floor(UV.y * height_pixels);
	float distance_from_center = abs(y - height_pixels * 0.5);
	// 4160a0: dos regiones exteriores y 32 filas de alpha 0,8,...,248.
	float row = floor(distance_from_center - displacement);
	pixel.a *= clamp(row / 32.0, 0.0, 1.0);
	COLOR *= pixel;
}
"""

var current_terrain := -1
var target_terrain := -1
var previous_terrain := -1
var _game := ""
var _start_tick := 0
var _last_tick := -1
var _last_counter := -1
var _base := Sprite2D.new()
var _field := Sprite2D.new()
var _wipe := ShaderMaterial.new()
var _joey_wipe := ShaderMaterial.new()
var _kaiba_transition: RefCounted
var _kaiba_wipe := ShaderMaterial.new()
## Desplazamiento de la cortinilla mezclado entre ticks de la presentacion.
var _blend := NativeBlend.new()
var _displacement := 0

func _init() -> void:
	position = Vector2(230, 0)
	_base.centered = false
	_field.centered = false
	var shader := Shader.new()
	shader.code = WIPE_CODE
	_wipe.shader = shader
	var joey_shader := Shader.new()
	joey_shader.code = "shader_type canvas_item; uniform sampler2D target_image : filter_nearest, repeat_disable; uniform sampler2D brush_mask : filter_nearest, repeat_disable; void fragment() { COLOR *= mix(texture(TEXTURE, UV), texture(target_image, UV), texture(brush_mask, UV).r); }"
	_joey_wipe.shader = joey_shader
	_kaiba_wipe.shader = joey_shader
	add_child(_base)
	add_child(_field)

static func terrain(duel: Duel) -> int:
	return duel.m.u16(TERRAIN_ADDR) & 15

static func resource_name(id: int) -> String:
	return "fie_%s" % NAMES[id] if id >= 0 and id < NAMES.size() else "fie_normal"

static func _assets() -> Node:
	return Engine.get_main_loop().root.get_node("Assets")

static func _texture(game: String, filename: String) -> Texture2D:
	var assets := _assets()
	return assets.texture("%s/duel/field/%s.png" % [game, filename])

static func texture_for(game: String, id: int) -> Texture2D:
	# IDs sin entrada nativa no son archivos perdidos. Una entrada válida sigue
	# pasando por Assets.texture, que avisa si falta su PNG esperado.
	if id < 0 or id >= int(TERRAIN_COUNTS.get(game, 0)): return null
	return _texture(game, resource_name(id))

static func intermediate_texture(game: String) -> Texture2D:
	# Recurso 0 de field.txt; null.bmp de Joey representa ausencia de dibujo.
	if game == "joey": return null
	return _texture(game, "fie_tri1" if game == "kaiba" else "fie_eff")

static func wipe_progress(counter: int) -> int:
	if counter < 64: return 256 - (Math.cos_fx(counter * 2) >> 8)
	if counter < 320: return 256
	if counter < 384: return Math.cos_fx((counter - 320) * 2) >> 8
	return 0

func reset(duel: Duel, game: String, tick: int = 0) -> void:
	_game = game
	current_terrain = terrain(duel)
	target_terrain = current_terrain
	previous_terrain = current_terrain
	_start_tick = tick
	_last_tick = tick
	_last_counter = -1
	_kaiba_transition = null
	_show_stable()

func _show_stable() -> void:
	_base.visible = false
	_field.texture = texture_for(_game, current_terrain)
	_field.material = null
	_field.visible = _field.texture != null

func refresh(duel: Duel, game: String, tick: int) -> void:
	_refresh(duel, game, tick, false)

## El campo tiene prioridad nativa 0xffffff00: consume antes de los otros dibujos.
## Un repintado consulta la máscara ya calculada y nunca extrae números MT.
func native_tick(duel: Duel, game: String, tick: int) -> void:
	_refresh(duel, game, tick, true)

func _refresh(duel: Duel, game: String, tick: int, native: bool) -> void:
	var active := terrain(duel)
	if current_terrain < 0 or game != _game or tick < _last_tick:
		reset(duel, game, tick)
		return
	if game == "kaiba" and not native: return
	for _i in mini(tick - _last_tick, 2): _blend.tick()
	_last_tick = tick
	if active != target_terrain:
		previous_terrain = current_terrain
		target_terrain = active
		_start_tick = tick
		_last_counter = -1
		_kaiba_transition = KaibaTransition.new() if game == "kaiba" else null
		_base.texture = intermediate_texture(game)
	if target_terrain == current_terrain: return
	var counter := maxi(0, tick - _start_tick) * 8
	if counter == _last_counter: return
	_last_counter = counter
	if game == "kaiba":
		# 436180 dibuja después de cada actualización435fb0. Agrupar ticks no
		# permite saltarse llamadas MT; la máscara y los dibujos intermedios se cachean.
		_kaiba_transition.advance(counter)
		if counter >= 384:
			current_terrain = target_terrain
			_show_stable()
			return
		_base.visible = false
		_field.texture = texture_for(game, previous_terrain)
		_field.visible = _field.texture != null
		_field.material = _kaiba_wipe if counter / 8 & 1 else null
		_kaiba_wipe.set_shader_parameter("target_image", texture_for(game, target_terrain))
		_kaiba_wipe.set_shader_parameter("brush_mask", _kaiba_transition.texture)
		return
	if counter >= 384:
		current_terrain = target_terrain
		_show_stable()
		return
	if game == "joey":
		_base.visible = false
		_field.texture = texture_for(game, previous_terrain)
		_field.visible = _field.texture != null
		_field.material = null if counter == 0 else _joey_wipe
		if counter > 0:
			_joey_wipe.set_shader_parameter("target_image", texture_for(game, target_terrain))
			_joey_wipe.set_shader_parameter("brush_mask", JoeyTransition.mask(counter))
		return
	_base.visible = _base.texture != null
	_field.texture = texture_for(game, previous_terrain if counter < 64 else target_terrain)
	_field.visible = counter < 64 or counter >= 320
	if counter == 0:
		_field.material = null
	else:
		_field.material = _wipe
		var height: float = _field.texture.get_height() if _field.texture != null else 600
		_wipe.set_shader_parameter("height_pixels", height)
		_displacement = int(height / 2) * wipe_progress(counter) / 256
		_wipe.set_shader_parameter("displacement", _blend.at("wipe", _displacement))


## `fraction`: lo que le queda a la presentacion hasta su siguiente tick.
func show_between(fraction: float) -> void:
	_blend.fraction = fraction
	if _field.material == _wipe:
		_wipe.set_shader_parameter("displacement", _blend.at("wipe", _displacement))

static func normalize(event: Dictionary, duel: Duel) -> Dictionary:
	var result := event.duplicate(true)
	result["mode"] = "field_change"
	result["frames"] = CHANGE_FRAMES
	result["terrain"] = int(event.get("a", terrain(duel))) & 15
	if event.get("game", "") == "joey" and result["terrain"] == 0:
		result["frames"] = 50 # 449120: al392 salta contador640; siguiente update libera.
	return result

static func _sprite(owner: Node2D, texture: Texture2D, factor: float, alpha: float) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(525, 300)
	sprite.scale = Vector2.ONE * factor
	sprite.modulate.a = clampf(alpha, 0, 1)
	owner.add_child(sprite)
	return sprite

static func render(owner: Node2D, event: Dictionary, frame: int) -> bool:
	if event.get("mode", "") != "field_change": return false
	var counter := frame * 8
	var id := int(event.get("terrain", 0))
	var game: String = str(event.get("game", owner.game))
	if counter >= 64 and counter < 320:
		var value := counter - 64
		if id == 0: value = 256 - value
		var texture := _texture(game, "fie_tri2" if game == "kaiba" else "fie_eye") if game != "joey" else null
		if texture != null:
			var alpha := (Math.cos_fx(value - 128) >> 8) / 256.0
			var sprite := _sprite(owner, texture, 1, alpha)
			var size := texture.get_size()
			var scale_fx := (256 - value) * 512 if value < 128 else 65536
			var width := (int(size.x) * scale_fx) >> 16
			var height := (int(size.y) * scale_fx) >> 16
			sprite.scale = Vector2(width / size.x, height / size.y)
			sprite.position = Vector2(525 - Math.trunc_div(width, 2) + width / 2.0, 300 - Math.trunc_div(height, 2) + height / 2.0)
			var material := CanvasItemMaterial.new()
			material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			sprite.material = material
	if id != 0 and counter >= 384 and counter < 640:
		var value := counter - 384
		if value >= 64: value = 64 if value <= 192 else value - 128
		var cosine := Math.cos_fx(value * 2)
		var sine := Math.sin_fx(value * 2)
		var alpha := sine >> 8
		if alpha <= 0: return true
		var texture := _texture(game, resource_name(id) + "_f?")
		if texture == null: return true
		var sprite := _sprite(owner, texture, 1, alpha / 256.0)
		if sprite != null:
			sprite.texture = texture
			var size := texture.get_size()
			var width := Math.trunc_div((128 + ((-cosine * 64) >> 16)) * int(size.x), 128)
			var height := (sine * int(size.y)) >> 16
			sprite.scale = Vector2(width / size.x, height / size.y)
			sprite.position = Vector2(525 - Math.trunc_div(width, 2) + width / 2.0, 300 - Math.trunc_div(height, 2) + height / 2.0)
	return true
