extends RefCounted
## Se prepara y verifica la partida nueva antes de apartar los datos activos.
const Store = preload("res://core/save_store.gd")


static func _discard_prepared(directory: String) -> void:
	# Solo archivos creados por esta operacion; nunca un borrado recursivo.
	for name in ["system.json", "system.json.tmp", ".reset-complete", "content.cfg"]:
		var target := directory.path_join(name)
		if FileAccess.file_exists(target):
			DirAccess.remove_absolute(target)
	if DirAccess.dir_exists_absolute(directory):
		DirAccess.remove_absolute(directory)


static func reset(saves: String, settings: String, fresh: Dictionary) -> Dictionary:
	var backup := saves + "-before-reset-%d" % Time.get_unix_time_from_system()
	var serial := 0
	while DirAccess.dir_exists_absolute(backup) or FileAccess.file_exists(backup) or DirAccess.dir_exists_absolute(backup + "-new") or FileAccess.file_exists(backup + "-new"):
		serial += 1
		backup = saves + "-before-reset-%d-%d" % [Time.get_unix_time_from_system(), serial]
	var staging := backup + "-new"
	var err := Store.write_save(staging.path_join("system.json"), fresh)
	if err == OK:
		err = Store.write_text(staging.path_join(".reset-complete"), "Do not migrate old saves again.\n")
	if err != OK:
		_discard_prepared(staging)
		return {"error": "No se pudo preparar la partida: " + error_string(err), "backup": ""}
	var config := ConfigFile.new()
	var had_settings := FileAccess.file_exists(settings)
	if had_settings:
		err = config.load(settings)
		if err != OK:
			_discard_prepared(staging)
			return {"error": "No se pudieron leer los ajustes: " + error_string(err), "backup": ""}
	# Conserva las rutas de importacion, pero restablece todas las preferencias.
	for section in config.get_sections():
		if section != "content":
			config.erase_section(section)
	err = config.save(staging.path_join("content.cfg"))
	if err != OK:
		_discard_prepared(staging)
		return {"error": "No se pudieron preparar los ajustes: " + error_string(err), "backup": ""}
	var had_saves := DirAccess.dir_exists_absolute(saves)
	err = DirAccess.rename_absolute(saves, backup) if had_saves else DirAccess.make_dir_recursive_absolute(backup)
	if err == OK and had_settings:
		err = DirAccess.rename_absolute(settings, backup.path_join("reset-content.cfg"))
	if err == OK:
		err = DirAccess.rename_absolute(staging.path_join("content.cfg"), settings)
	if err == OK:
		err = DirAccess.rename_absolute(staging, saves)
	if err != OK:
		# Recuperar las rutas originales; nunca borrar los datos anteriores.
		var rollback := OK
		if FileAccess.file_exists(backup.path_join("reset-content.cfg")):
			if FileAccess.file_exists(settings):
				rollback = DirAccess.rename_absolute(settings, staging.path_join("content.cfg"))
			if rollback == OK:
				rollback = DirAccess.rename_absolute(backup.path_join("reset-content.cfg"), settings)
		elif not had_settings and FileAccess.file_exists(settings):
			rollback = DirAccess.rename_absolute(settings, staging.path_join("content.cfg"))
		if had_saves and DirAccess.dir_exists_absolute(backup) and not DirAccess.dir_exists_absolute(saves):
			var restored := DirAccess.rename_absolute(backup, saves)
			if restored != OK:
				rollback = restored
		if rollback == OK:
			_discard_prepared(staging)
		return {"error": "No se pudo reiniciar: " + error_string(err) + (". Recuperacion manual: " + backup if rollback != OK else ""), "backup": backup}
	return {"error": "", "backup": backup, "data": fresh}
