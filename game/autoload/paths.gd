extends Node
## Rutas del juego. Todo vive junto al ejecutable para que sea portable:
##   <carpeta del juego>/data   assets convertidos por tools/pocx
##   <carpeta del juego>/saves  partidas guardadas
## Desde el editor, la "carpeta del juego" es la raiz del repositorio (la que contiene game/).
## En Android no se puede escribir junto al APK, asi que se usa el almacenamiento de la app.

var data_dir: String
var save_dir: String
var _inventory_root := ""
var _installed := {}


func _init() -> void:
	data_dir = _resolve_data_dir()
	save_dir = _resolve_save_dir()


func has_data() -> bool:
	return FileAccess.file_exists(data_dir.path_join("inventory.json"))


func has_game(game: String) -> bool:
	if not has_data():
		return false
	if _inventory_root != data_dir:
		var inventory: Variant = JSON.parse_string(FileAccess.get_file_as_string(data_dir.path_join("inventory.json")))
		_installed = inventory.get("games", {}) if inventory is Dictionary else {}
		_inventory_root = data_dir
	return _installed.has(game)


func _resolve_data_dir() -> String:
	var override := cmdline_value("data")
	if override != "":
		return override
	var config := ConfigFile.new()
	if config.load("user://content.cfg") == OK:
		var imported := str(config.get_value("content", "data", ""))
		if FileAccess.file_exists(imported.path_join("inventory.json")):
			return imported
	if OS.has_feature("android"):
		return "user://data"
	return _base_dir().path_join("data")


func _resolve_save_dir() -> String:
	var override := cmdline_value("save")
	if override != "":
		return override
	if OS.has_feature("android"):
		return "user://saves"
	var dir := _base_dir().path_join("saves")
	if _is_writable(dir):
		return dir
	# p. ej. instalado en Program Files: unico caso en que se sale de la carpeta del juego
	return "user://saves"


func _base_dir() -> String:
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path("res://").path_join("..").simplify_path()
	return OS.get_executable_path().get_base_dir()


func _is_writable(dir: String) -> bool:
	if DirAccess.make_dir_recursive_absolute(dir) != OK:
		return false
	var probe := dir.path_join(".probe")
	var f := FileAccess.open(probe, FileAccess.WRITE)
	if f == null:
		return false
	f.close()
	DirAccess.remove_absolute(probe)
	return true


## Lee "--nombre=valor" de los argumentos de usuario (los que van despues de "--").
static func cmdline_value(name: String) -> String:
	var prefix := "--%s=" % name
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(prefix):
			return arg.substr(prefix.length())
	return ""
