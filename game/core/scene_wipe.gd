extends CanvasLayer
## D10: Y532390/40a260/530e30 -> PE5aa590[13]=525bf0.
## Dos snapshots; el destino queda sin actualizacion/entrada durante16 ticks.
const CLOCK := preload("res://core/native_clock.gd")
const SHADER_CODE := """
shader_type canvas_item;
uniform sampler2D next_frame : filter_nearest;
uniform int progress = 0;
uniform int mode = 19;
void fragment() {
	int row = int(floor(UV.y * 600.0)) % 4;
	int x = int(floor(UV.x * 800.0));
	int phase = row == 0 || row == 2 ? progress : progress - 128;
	int extent = (800 * phase) / 128;
	bool left = row == 0 || row == 1;
	bool visible = phase > 0 && (left ? x < min(800, extent) : x >= max(0, 800 - extent - 1));
	if (mode == 42) {
		visible = progress > 0 && ((int(floor(UV.y * 600.0)) & 15) <= (progress >> 4));
	} else if (mode == 75) {
		int y = int(floor(UV.y * 600.0));
		int band = y / 16;
		int total = (600 + 17) / 16;
		int length = min(16, ((total + 16) * progress) / 256 - band);
		int bottom = band * 16 + length;
		// 52d5fb..52d606: el extremo exclusivo que excede600 se recorta a599.
		if (bottom > 600) { bottom = 599; }
		visible = progress > 0 && y < bottom;
	}
	COLOR = visible ? texture(next_frame, UV) : texture(TEXTURE, UV);
}
"""
var mode := 0x13
var progress := 0
var _clock := 0.0
var _screen: Node
var _previous_mode: int
var _old: Texture2D
var _new: Texture2D
var _material := ShaderMaterial.new()

func _init(old_frame: Texture2D, new_frame: Texture2D, screen: Node = null, previous_mode := 0, effect := 0x13) -> void:
	mode = effect
	_old = old_frame
	_new = new_frame
	_screen = screen
	_previous_mode = previous_mode

func _ready() -> void:
	layer = 1000
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_material.shader = shader
	_material.set_shader_parameter("mode", mode)
	_material.set_shader_parameter("next_frame", _new)
	var frame := TextureRect.new()
	frame.texture = _old
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.size = Vector2(800, 600)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.material = _material
	add_child(frame)

func set_destination(texture: Texture2D) -> void:
	_new = texture
	_material.set_shader_parameter("next_frame", _new)

func _process(delta: float) -> void:
	_clock += CLOCK.ticks(delta)
	while _clock >= 1.0:
		_clock -= 1.0
		tick()

func tick() -> void:
	progress = mini(256, progress + 16)
	_material.set_shader_parameter("progress", progress)
	# 40a260 dibuja240 y312b0 termina ese mismo tick: el destino vuelve en el siguiente.
	if progress == 240:
		_release_screen()
	if progress == 256:
		finish()

func _release_screen() -> void:
	if is_instance_valid(_screen):
		_screen.process_mode = _previous_mode
		_screen = null

func finish() -> void:
	_release_screen()
	hide()
	queue_free()

## ASM525ce3/525de4/525f2d: izquierdaN pixeles; derechaN+1 por el -1.
static func revealed(x: int, y: int, p: int, width := 800) -> bool:
	if p >= 256:
		return true
	var row := y & 3
	var phase := p if row in [0, 2] else p - 128
	if phase <= 0:
		return false
	var extent := (width * phase) >> 7
	return x < mini(width, extent) if row in [0, 1] else x >= maxi(0, width - extent - 1)

## 52d470: bandas16, longitud decreciente; 5288e0: filasmod16 inclusivas.
static func revealed_mode(x: int, y: int, p: int, effect: int, width := 800, height := 600) -> bool:
	if p >= 256: return true
	if p <= 0: return false
	if effect == 0x2a: return (y & 15) <= (p >> 4)
	if effect == 0x4b:
		var bands := (height + 17) / 16
		var length := mini(16, ((bands + 16) * p >> 8) - y / 16)
		var bottom := y / 16 * 16 + length
		if bottom > height: bottom = height - 1
		return y < bottom
	return revealed(x, y, p, width)

func _exit_tree() -> void:
	if is_instance_valid(_screen):
		_screen.process_mode = _previous_mode
		_screen = null
