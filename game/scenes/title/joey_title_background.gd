extends Node2D
## 489170: dos superficies formato10 con máscara alfa4bit, suma saturada sobre RGB565.
var layout: Layout
var counter := -4
var bg: Texture2D
var logo: Texture2D
var bands_material: ShaderMaterial
func setup(value: Layout) -> void:
	layout = value
	bg = Assets.texture("joey/title/" + layout.resource(5))
	logo = Assets.texture("joey/title/" + layout.resource(6))
	bands_material = ShaderMaterial.new()
	bands_material.shader = preload("res://scenes/title/joey_title_bands.gdshader")
	bands_material.set_shader_parameter("layer1", Assets.texture("joey/title/" + layout.resource(22)))
	bands_material.set_shader_parameter("layer2", Assets.texture("joey/title/" + layout.resource(25)))
	bands_material.set_shader_parameter("mask_image", Assets.texture("joey/title/" + layout.resource(23)))
	bands_material.set_shader_parameter("origin1", Vector2i(layout.position(22)))
	bands_material.set_shader_parameter("origin2", Vector2i(layout.position(25)))
static func band_left(c: int, index: int, x: int) -> int:
	var weight := c * 2 + index * 16
	return ((x - 310) * weight + (x + 560) * (256 - weight)) / 256
static func masked_contribution(color565: int, mask565: int) -> int:
	var alpha4 := (mask565 & 31) >> 1
	return (((color565 >> 11) * alpha4 / 15) << 11) | ((((color565 >> 5) & 63) * alpha4 / 15) << 5) | ((color565 & 31) * alpha4 / 15)
static func add565(dest: int, source: int) -> int:
	return (mini(31, (dest >> 11) + (source >> 11)) << 11) | (mini(63, ((dest >> 5) & 63) + ((source >> 5) & 63)) << 5) | mini(31, (dest & 31) + (source & 31))
func advance(c: int, _tick: int) -> void:
	counter = c
	material = bands_material if c < 128 else null
	bands_material.set_shader_parameter("counter", maxi(0, c))
	queue_redraw()
func _draw() -> void:
	if bg == null: return
	draw_texture(bg, Vector2.ZERO)
	if counter >= 128:
		var alpha := mini(256, counter * 4 - 512)
		draw_texture(logo, Vector2(layout.position(6)), Color(1, 1, 1, alpha / 256.0))
