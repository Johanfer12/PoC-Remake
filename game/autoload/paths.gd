extends Node
## En PC todos los archivos de la aplicación viven en <exe>/PoC Data/.
## Desde el editor, la "carpeta del juego" es la raiz del repositorio (la que contiene game/).
## En Android no se puede escribir junto al APK, asi que se usa el almacenamiento de la app.

var data_dir: String
var save_dir: String
var storage_dir: String
var storage_error := false
var migration_source := ""
var _inventory_root := ""
var _installed := {}


func _init() -> void:
	storage_dir = cmdline_value("storage")
	if storage_dir == "":
		storage_dir = "user://" if OS.has_feature("android") else _base_dir().path_join("PoC Data")
	storage_dir = ProjectSettings.globalize_path(storage_dir)
	storage_error = not _is_writable(storage_dir)
	if not storage_error and not OS.has_feature("android"):
		DirAccess.make_dir_recursive_absolute(storage_dir.path_join("temp"))
		OS.set_environment("TEMP", storage_dir.path_join("temp"))
		OS.set_environment("TMP", storage_dir.path_join("temp"))
		_migrate_preferences_and_saves()
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
	if OS.has_feature("android"):
		return "user://data"
	var portable := resources_path()
	if FileAccess.file_exists(portable.path_join("inventory.json")):
		return portable
	if _allow_legacy():
		var config := ConfigFile.new()
		if config.load(_legacy_root().path_join("content.cfg")) == OK:
			var imported := str(config.get_value("content", "data", ""))
			if FileAccess.file_exists(imported.path_join("inventory.json")):
				migration_source = imported
				return imported
		var previous := _base_dir().path_join("data")
		if FileAccess.file_exists(previous.path_join("inventory.json")):
			migration_source = previous
			return previous
	# Los fixtures/desarrollo no se trasladan automáticamente al abrir el editor.
	if OS.has_feature("editor") and FileAccess.file_exists(_base_dir().path_join("data/inventory.json")):
		return _base_dir().path_join("data")
	return portable


func _resolve_save_dir() -> String:
	var override := cmdline_value("save")
	if override != "":
		return override
	return storage_dir.path_join("saves")


func settings_path() -> String:
	return storage_dir.path_join("content.cfg")


func resources_path() -> String:
	return storage_dir.path_join("resources")


func _legacy_root() -> String:
	var override := cmdline_value("legacy-root")
	return override if override != "" else ProjectSettings.globalize_path("user://")


func _allow_legacy() -> bool:
	return not OS.has_feature("android") and cmdline_value("data") == "" and cmdline_value("save") == "" and (not OS.has_feature("editor") or cmdline_value("legacy-root") != "")


func _migrate_preferences_and_saves() -> void:
	if OS.has_feature("editor") and cmdline_value("storage") == "" and cmdline_value("data") == "" and cmdline_value("save") == "":
		if not _copy_missing(_base_dir().path_join("saves"), storage_dir.path_join("saves")):
			storage_error = true
	if not _allow_legacy():
		return
	if not FileAccess.file_exists(settings_path()):
		var config := ConfigFile.new()
		if config.load(_legacy_root().path_join("content.cfg")) == OK:
			config.set_value("content", "data", "resources")
			if config.save(settings_path()) != OK:
				storage_error = true
	var previous_saves := [_legacy_root().path_join("saves")]
	if not OS.has_feature("editor"):
		previous_saves.push_front(_base_dir().path_join("saves"))
	for previous: String in previous_saves:
		if not _copy_missing(previous, storage_dir.path_join("saves")):
			storage_error = true


func _copy_missing(source: String, target: String) -> bool:
	if not DirAccess.dir_exists_absolute(source):
		return true
	if DirAccess.make_dir_recursive_absolute(target) != OK:
		return false
	var dir := DirAccess.open(source)
	for folder in dir.get_directories():
		if not _copy_missing(source.path_join(folder), target.path_join(folder)):
			return false
	for file in dir.get_files():
		var original := source.path_join(file)
		var destination := target.path_join(file)
		if FileAccess.file_exists(destination):
			continue
		var temporary := destination + ".migration-tmp"
		if DirAccess.copy_absolute(original, temporary) != OK or FileAccess.get_sha256(original) != FileAccess.get_sha256(temporary):
			return false
		if DirAccess.rename_absolute(temporary, destination) != OK:
			return false
	return true


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
