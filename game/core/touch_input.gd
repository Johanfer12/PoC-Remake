extends RefCounted
## Solo un toque nuevo fuera de la ventana cancela; raton y mando conservan su entrada.
static func outside(event: InputEvent, over_window: bool) -> bool:
	return event is InputEventMouseButton and event.pressed \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and bool(event.get_meta("platform_touch", false)) and not over_window
