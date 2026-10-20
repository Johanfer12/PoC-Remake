extends Node2D
## Ilustracion exterior al viewport nativo: el duelo conserva800x600 e input local.
const BACKGROUNDS := {
	"yugi": "res://assets/backgrounds/yugi_duel.jpg",
	"joey": "res://assets/backgrounds/joey_duel.png",
}
var _duel: Node
var _background := TextureRect.new()
var _container := SubViewportContainer.new()
var _viewport := SubViewport.new()
var _window: Window
var _previous_aspect: int

func _init(duel: Node) -> void:
	_duel = duel

func _ready() -> void:
	_window = get_tree().root
	_previous_aspect = _window.content_scale_aspect
	_window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	var path: String = BACKGROUNDS.get(_duel.game, "")
	if path != "" and ResourceLoader.exists(path):
		_background.texture = load(path)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_container.mouse_filter = Control.MOUSE_FILTER_PASS
	_container.stretch = false
	add_child(_container)
	_viewport.size = Vector2i(800, 600)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_container.add_child(_viewport)
	_window.size_changed.connect(_layout)
	_layout()
	_viewport.add_child(_duel)

func _layout() -> void:
	var area := _window.get_visible_rect()
	_background.position = area.position
	_background.size = area.size
	_container.position = area.position + (area.size - Vector2(800, 600)) * 0.5
	_container.size = Vector2(800, 600)

func _exit_tree() -> void:
	if is_instance_valid(_window):
		if _window.size_changed.is_connected(_layout): _window.size_changed.disconnect(_layout)
		_window.content_scale_aspect = _previous_aspect
