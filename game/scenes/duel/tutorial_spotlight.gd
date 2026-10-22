extends Node2D
## 468100/4681a0/468210 -> 464490, círculos416260 y rectángulos4163d0.
var enabled := false
var counter := 0
var rectangle := false
var center := Vector2(400, 300)
var half_size := Vector2(400, 300)
var _shade := ColorRect.new()
var _material := ShaderMaterial.new()
var _bright: Texture2D
var _dim: Texture2D
var _blend := NativeBlend.new()
const CODE := """
shader_type canvas_item;
uniform vec2 center;
uniform vec2 half_size;
uniform bool rectangle;
uniform float diameter;
uniform bool frozen = false;
uniform sampler2D bright_image : filter_nearest, repeat_disable;
uniform sampler2D dim_image : filter_nearest, repeat_disable;
uniform float dim_factor = 0.5;
void fragment() {
 vec2 p = floor(UV * vec2(800.0,600.0)) - center;
 // 416260: ancho entero de cada fila, limite derecho exclusivo de SetRect.
 float width = floor(2.0 * sqrt(max(0.0, floor(diameter * diameter / 4.0) - p.y * p.y)));
 float left = -floor(width / 2.0);
 bool inside = rectangle ? (p.x >= -half_size.x && p.x < half_size.x && p.y >= -half_size.y && p.y < half_size.y)
                         : (abs(p.y) <= floor(diameter / 2.0) && p.x >= left && p.x < left + width);
 if (frozen) {
  vec4 dim = texture(dim_image, UV);
  dim.rgb *= dim_factor;
  COLOR = inside ? texture(bright_image, UV) : dim;
 } else {
  COLOR = vec4(0.0,0.0,0.0,inside ? 0.0 : 0.5);
 }
}
"""
func _ready() -> void:
	z_index = 10
	_shade.size = Vector2(800, 600)
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = CODE
	_material.shader = shader
	_shade.material = _material
	add_child(_shade)
	_refresh()
func event(e: Dictionary) -> void:
	if e["kind"] == "tutorial_spotlight_close":
		# 464490: al salir conserva la superficie sombreada ya dibujada.
		if counter == 256 and _bright != null:
			var current := _capture()
			if current != null:
				_dim = current
				_material.set_shader_parameter("dim_image", _dim)
				_material.set_shader_parameter("dim_factor", 1.0)
		enabled = false
	else:
		# 464490: superficies1/2 copiadas al entrar; 2 oscurecida con4e2db0(128,0).
		if counter == 0:
			_bright = _capture()
			_dim = _bright
			_material.set_shader_parameter("bright_image", _bright)
			_material.set_shader_parameter("dim_image", _dim)
			_material.set_shader_parameter("dim_factor", 0.5)
			_material.set_shader_parameter("frozen", _bright != null)
		enabled = true
		rectangle = bool(e["rectangle"])
		var a := int(e["a"])
		var b := int(e["b"])
		var c := int(e["c"])
		if rectangle:
			var left := a / 10
			var top := a % 10 * 100 + b / 100
			half_size = Vector2((c / 1000 + b % 100 * 10 - left) / 2, (c % 1000 - top) / 2)
			center = Vector2(left, top) + half_size
		else:
			center = Vector2(a, b)
			half_size = Vector2(c, c)
		# Con el foco ya abierto, el original salta al nuevo sitio.
		if counter > 0:
			for key in ["center", "half_size", "diameter"]: _blend.cut(key)
	_refresh()

func _capture() -> Texture2D:
	return preload("res://core/native_snapshot.gd").capture(get_viewport())

func busy() -> bool:
	return counter != (256 if enabled else 0)
func advance() -> void:
	if busy():
		counter = mini(256, counter + (16 if counter == 0 else 32)) if enabled else maxi(0, counter - (16 if counter == 256 else 32))
	_blend.tick()
	_refresh()
## La lección avanza el foco por ticks enteros: entre ticks se dibuja con su reloj.
func show_between(fraction: float) -> void:
	_blend.fraction = fraction
	_refresh()
func _refresh() -> void:
	_shade.visible = counter > 0
	var at := Vector2(int(((int(center.x) - 400) * counter + 102400) / 256), int(((int(center.y) - 300) * counter + 76800) / 256))
	var full := Vector2(400, 300) if rectangle else Vector2(500, 500)
	var size := Vector2(int(((int(half_size.x) - int(full.x)) * counter * 2 + int(full.x) * 512) / 256) / 2, int(((int(half_size.y) - int(full.y)) * counter * 2 + int(full.y) * 512) / 256) / 2)
	_material.set_shader_parameter("center", _blend.at("center", at))
	_material.set_shader_parameter("half_size", _blend.at("half_size", size))
	_material.set_shader_parameter("rectangle", rectangle)
	_material.set_shader_parameter("diameter", _blend.at("diameter", int(((int(half_size.x) - 500) * counter * 2 + 256000) / 256)))
