extends Node
## Optional, reviewed Spanish card text from community sources. Original data stays intact.
signal changed

const CATALOG_PATH := "res://translations/spanish-card-catalog.json"
const SOURCE := "https://www.db.yugioh-card.com/yugiohdb/card_search.action?ope=2&cid=%s&request_locale=%s"
const HEADERS := ["User-Agent: PowerOfChaos-CardTranslations/1.0", "Accept: text/html"]
var busy := false
var status := "idle"
var completed := 0
var total := 0
var description_count := 0
var _catalog: Dictionary = {}
var _bulk_source := ""
var _cards: Dictionary = {}
var _http := HTTPRequest.new()
var _last_request_msec := -500
var _network_blocked := false
var _network_failed := false
var _bulk_thread: Thread


func _ready() -> void:
	_http.timeout = 30
	_http.body_size_limit = 2 * 1024 * 1024
	_http.use_threads = true
	add_child(_http)
	load_cache()
	# Cached preferences apply immediately; only an explicit toggle starts requests.


func cache_path() -> String:
	return Paths.storage_dir.path_join("translations/cards-spa.json")


func load_cache() -> void:
	_cards.clear()
	_catalog.clear()
	_bulk_source = ""
	var catalog: Variant = _read_json(CATALOG_PATH)
	if catalog is Dictionary and catalog.get("format") == 1 and catalog.get("locale") == "spa" and catalog.get("cards") is Dictionary:
		_catalog = catalog.cards
		_bulk_source = str(catalog.get("bulk_source", ""))
	total = _catalog.size()
	if FileAccess.file_exists(cache_path()):
		var pack: Variant = _read_json(cache_path())
		if pack is Dictionary and pack.get("format") == 1 and pack.get("locale") == "spa" and pack.get("cards") is Dictionary:
			for id: String in pack.cards:
				var entry: Variant = pack.cards[id]
				if entry is Dictionary and _valid_entry(id, entry):
					_cards[id] = entry.duplicate(true)
	_recount()
	status = "ready" if _all_complete() else ("partial" if completed > 0 else "idle")
	changed.emit()


func _exit_tree() -> void:
	if _bulk_thread != null and _bulk_thread.is_started():
		_bulk_thread.wait_to_finish()


func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return null
	return parser.data


func _valid_entry(id: String, entry: Dictionary) -> bool:
	if not _catalog.has(id) or not entry.get("name") is String:
		return false
	var expected: Dictionary = _catalog[id]
	for key: String in ["cid", "password", "english_name", "legacy_description_sha256"]:
		if str(entry.get(key, "")) != str(expected.get(key, "")):
			return false
	if str(entry.name).strip_edges().is_empty() or str(entry.name).length() > 200:
		return false
	if expected.has("approved_name_sha256") or expected.has("approved_description_sha256"):
		var approved_description: Variant = entry.get("description", "")
		return not _bulk_source.is_empty() and entry.get("source_url") == _bulk_source \
			and approved_description is String and not approved_description.is_empty() and approved_description.length() <= 10000 \
			and str(entry.name).sha256_text() == expected.get("approved_name_sha256", "") \
			and approved_description.sha256_text() == expected.get("approved_description_sha256", "") \
			and entry.get("description_verified") == true and entry.get("english_source_url", "") == ""
	if entry.get("source_url") != source_url(expected.cid, "es"):
		return false
	if not str(entry.get("english_source_url", "")).is_empty() and entry.english_source_url != source_url(expected.cid, "en"):
		return false
	var description: Variant = entry.get("description", "")
	if not description is String or description.length() > 10000:
		return false
	if not description.is_empty():
		if not expected.get("review_description", false) or entry.get("description_verified") != true:
			return false
		if entry.get("english_source_url") != source_url(expected.cid, "en"):
			return false
	return true


func _recount() -> void:
	completed = _cards.size()
	description_count = 0
	for entry: Dictionary in _cards.values():
		if not str(entry.get("description", "")).is_empty():
			description_count += 1


func _entry_complete(id: String) -> bool:
	if not _cards.has(id):
		return false
	if _catalog[id].has("approved_name_sha256") or _catalog[id].has("approved_description_sha256"):
		return _valid_entry(id, _cards[id])
	return not _catalog[id].get("review_description", false) or not str(_cards[id].get("english_source_url", "")).is_empty()


func _all_complete() -> bool:
	if _catalog.is_empty():
		return false
	for id: String in _catalog:
		if not _entry_complete(id):
			return false
	return true


func _uses_bulk_catalog() -> bool:
	if _bulk_source.is_empty():
		return false
	for expected: Dictionary in _catalog.values():
		if expected.has("approved_name_sha256") or expected.has("approved_description_sha256"):
			return true
	return false


func text(card: Dictionary, field: String, language: String) -> String:
	if not LauncherSettings.improved_card_texts or language != "spa" or field not in ["names", "descriptions"]:
		return ""
	var id := str(int(card.get("internal_id", -1)))
	if not _cards.has(id):
		return ""
	var expected: Dictionary = _catalog.get(id, {})
	var names: Dictionary = card.get("names", {})
	var descriptions: Dictionary = card.get("descriptions", {})
	if str(card.get("password", "")) != str(expected.get("password", "")) or names.get("eng", "") != expected.get("english_name", ""):
		return ""
	if normalize_english(str(descriptions.get("eng", ""))).sha256_text() != expected.get("legacy_description_sha256", ""):
		return ""
	return str(_cards[id].get("name" if field == "names" else "description", ""))


func ensure_spanish_pack() -> void:
	if busy:
		return
	if _catalog.is_empty():
		load_cache()
	if _catalog.is_empty():
		_set_status("error")
		return
	if _all_complete():
		_set_status("ready")
		return
	busy = true
	_network_blocked = false
	_network_failed = false
	_set_status("downloading")
	if _uses_bulk_catalog():
		await _ensure_bulk_pack()
		return
	for id: String in _catalog:
		if _network_blocked or _network_failed:
			break
		if not LauncherSettings.improved_card_texts:
			busy = false
			_set_status("paused")
			return
		if _entry_complete(id):
			continue
		var expected: Dictionary = _catalog[id]
		var spanish := await _fetch(source_url(expected.cid, "es"))
		if not LauncherSettings.improved_card_texts:
			busy = false
			_set_status("paused")
			return
		if spanish.is_empty():
			continue
		var entry := expected.duplicate(true)
		entry.erase("review_description")
		entry["name"] = spanish.name
		entry["official_english_name"] = spanish.get("english_name", "")
		entry["description"] = ""
		entry["description_verified"] = false
		entry["source_url"] = source_url(expected.cid, "es")
		entry["english_source_url"] = ""
		if expected.get("review_description", false):
			var english := await _fetch(source_url(expected.cid, "en"))
			if not LauncherSettings.improved_card_texts:
				busy = false
				_set_status("paused")
				return
			if not english.is_empty():
				entry["english_source_url"] = source_url(expected.cid, "en")
				if normalize_english(str(english.get("description", ""))).sha256_text() == expected.legacy_description_sha256:
					entry["description"] = spanish.description
					entry["description_verified"] = true
		_cards[id] = entry
		_recount()
		if not _save_cache():
			_cards.erase(id)
			_recount()
			busy = false
			_set_status("storage_error")
			return
		changed.emit()
	busy = false
	_set_status("rate_limited" if _network_blocked else ("error" if _network_failed else ("ready" if _all_complete() else "partial")))


func _ensure_bulk_pack() -> void:
	if not LauncherSettings.improved_card_texts:
		busy = false
		_set_status("paused")
		return
	var download := await _download_bulk()
	if not LauncherSettings.improved_card_texts:
		busy = false
		_set_status("paused")
		return
	if not download.has("body"):
		busy = false
		_set_status(str(download.get("error", "error")))
		return
	_set_status("reviewing")
	_bulk_thread = Thread.new()
	var started := _bulk_thread.start(parse_bulk_payload.bind(download.body, _catalog.duplicate(true), _bulk_source))
	if started != OK:
		_bulk_thread = null
		busy = false
		_set_status("error")
		return
	while _bulk_thread.is_alive():
		await get_tree().process_frame
	var parsed: Variant = _bulk_thread.wait_to_finish()
	_bulk_thread = null
	if not LauncherSettings.improved_card_texts:
		busy = false
		_set_status("paused")
		return
	if not parsed is Dictionary or not parsed.get("ok", false):
		busy = false
		_set_status("error")
		return
	var previous := _cards
	var merged := _cards.duplicate(true)
	for id: String in parsed.cards:
		if _valid_entry(id, parsed.cards[id]):
			merged[id] = parsed.cards[id]
	_cards = merged
	_recount()
	if not _save_cache():
		_cards = previous
		_recount()
		busy = false
		_set_status("storage_error")
		return
	busy = false
	_set_status("ready" if _all_complete() else "partial")


func _download_bulk() -> Dictionary:
	_http.timeout = 180
	_http.body_size_limit = 160 * 1024 * 1024
	var replies: Array = []
	var completion := func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
		replies.append([result, response_code, headers, body])
	_http.request_completed.connect(completion, CONNECT_ONE_SHOT)
	var requested := _http.request(_bulk_source, ["User-Agent: PowerOfChaos-CardTranslations/1.0", "Accept: application/json"])
	if requested != OK:
		_http.request_completed.disconnect(completion)
		_http.timeout = 30
		_http.body_size_limit = 2 * 1024 * 1024
		return {"error": "error"}
	while replies.is_empty():
		if not LauncherSettings.improved_card_texts:
			_http.cancel_request()
			if _http.request_completed.is_connected(completion):
				_http.request_completed.disconnect(completion)
			_http.timeout = 30
			_http.body_size_limit = 2 * 1024 * 1024
			return {"error": "paused"}
		await get_tree().process_frame
	var response: Array = replies[0]
	_http.timeout = 30
	_http.body_size_limit = 2 * 1024 * 1024
	if response[1] in [403, 429]:
		return {"error": "rate_limited"}
	if response[0] != HTTPRequest.RESULT_SUCCESS or response[1] != 200:
		return {"error": "error"}
	return {"body": response[3]}


static func parse_bulk_payload(body: PackedByteArray, catalog: Dictionary, bulk_source: String) -> Dictionary:
	# Runs in a worker: no scene access, signal emission or shared mutable state.
	var parser := JSON.new()
	if parser.parse(body.get_string_from_utf8()) != OK or not parser.data is Array:
		return {"ok": false, "cards": {}}
	var by_cid: Dictionary = {}
	for id: String in catalog:
		var cid := int(catalog[id].get("cid", -1))
		if not by_cid.has(cid):
			by_cid[cid] = []
		by_cid[cid].append(id)
	var cards: Dictionary = {}
	for candidate: Variant in parser.data:
		if not candidate is Dictionary:
			continue
		var raw_cid: Variant = candidate.get("konami_id")
		if not raw_cid is int and not raw_cid is float:
			continue
		var cid := int(raw_cid)
		if not by_cid.has(cid):
			continue
		var names: Dictionary = candidate.get("name", {}) if candidate.get("name") is Dictionary else {}
		var descriptions: Dictionary = candidate.get("text", {}) if candidate.get("text") is Dictionary else {}
		for id: String in by_cid[cid]:
			var expected: Dictionary = catalog[id]
			var name: Variant = expected.get("name_override", names.get("es", ""))
			var description: Variant = expected.get("description_override", descriptions.get("es", ""))
			if not name is String or not description is String or name.is_empty() or description.is_empty():
				continue
			if name.length() > 200 or description.length() > 10000:
				continue
			if name.sha256_text() != expected.get("approved_name_sha256", "") or description.sha256_text() != expected.get("approved_description_sha256", ""):
				continue
			var entry := expected.duplicate(true)
			entry.erase("name_override")
			entry.erase("description_override")
			entry["name"] = name
			entry["description"] = description
			entry["source_url"] = bulk_source
			entry["english_source_url"] = ""
			entry["description_verified"] = true
			cards[id] = entry
	return {"ok": true, "cards": cards}


func _fetch(url: String) -> Dictionary:
	var remaining := 500 - (Time.get_ticks_msec() - _last_request_msec)
	if remaining > 0:
		await get_tree().create_timer(float(remaining) / 1000.0, true, false, true).timeout
	if not LauncherSettings.improved_card_texts:
		return {}
	_last_request_msec = Time.get_ticks_msec()
	if _http.request(url, HEADERS) != OK:
		_network_failed = true
		return {}
	var response: Array = await _http.request_completed
	if response[1] in [403, 429]:
		_network_blocked = true
	if response[0] != HTTPRequest.RESULT_SUCCESS or response[1] != 200:
		if not _network_blocked and response[1] != 404:
			_network_failed = true
		return {}
	return parse_official_html((response[3] as PackedByteArray).get_string_from_utf8())


func _save_cache() -> bool:
	var path := cache_path()
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return false
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"format": 1, "locale": "spa", "cards": _cards}))
	var result := file.get_error()
	file.close()
	if result != OK:
		return false
	return DirAccess.rename_absolute(path + ".tmp", path) == OK


func _set_status(value: String) -> void:
	status = value
	changed.emit()


func status_text(spanish: bool) -> String:
	match status:
		"downloading":
			return ("ES: %d/%d cartas · %d descripciones · descargando…" if spanish else "ES: %d/%d cards · %d descriptions · downloading…") % [completed, total, description_count]
		"reviewing":
			return "Preparando el paquete de cartas revisadas…" if spanish else "Preparing reviewed card text pack…"
		"error":
			return ("ES: %d/%d · interrupción. Desactiva y activa para reintentar." if spanish else "ES: %d/%d · interrupted. Toggle off and on to retry.") % [completed, total]
		"partial":
			return ("ES: %d/%d nombres · %d descripciones · parcial." if spanish else "ES: %d/%d names · %d descriptions · partial.") % [completed, total, description_count]
		"rate_limited":
			return "Servidor limita la descarga. Reintenta más tarde; caché conservada." if spanish else "Server limits downloads. Retry later; cache preserved."
		"storage_error":
			return "No se pudo guardar el paquete de cartas." if spanish else "Could not save the card text pack."
		"ready":
			return ("ES: %d nombres · %d descripciones revisadas." if spanish else "ES: %d names · %d reviewed descriptions.") % [completed, description_count]
		_:
			return ("Español · fuentes comunitarias (%d/%d)." if spanish else "Spanish · community sources (%d/%d).") % [completed, total]


static func source_url(cid: Variant, locale: String) -> String:
	return SOURCE % [str(int(cid)), locale]


static func normalize_english(value: String) -> String:
	var regex := RegEx.new()
	regex.compile("[a-z0-9]+")
	var words := PackedStringArray()
	for found: RegExMatch in regex.search_all(value.to_lower()):
		words.append(found.get_string())
	return " ".join(words)


static func parse_official_html(html: String) -> Dictionary:
	# Restrict extraction to the primary card header and primary description.
	var header := _capture(html, "(?is)<[^>]+id=[\"']cardname[\"'][^>]*>(.*?)</h1>")
	if header.is_empty():
		return {}
	var spanish := _clean_html(header.split("<span", true, 1)[0])
	var english := _clean_html(_capture(header, "(?is)<span[^>]*>(.*?)</span>"))
	var description := _clean_html(_capture(html, "(?is)<div[^>]+class=[\"'][^\"']*item_box_text[^\"']*[\"'][^>]*>.*?<div[^>]+class=[\"'][^\"']*text_linebreak[^\"']*[\"'][^>]*>(.*?)</div>"))
	if spanish.is_empty() or description.is_empty():
		return {}
	return {"name": spanish, "english_name": english, "description": description}


static func _capture(value: String, pattern: String) -> String:
	var regex := RegEx.new()
	if regex.compile(pattern) != OK:
		return ""
	var found := regex.search(value)
	return found.get_string(1) if found != null else ""


static func _clean_html(value: String) -> String:
	var breaks := RegEx.new()
	breaks.compile("(?i)<br\\s*/?>")
	var tags := RegEx.new()
	tags.compile("<[^>]*>")
	var result := tags.sub(breaks.sub(value, "\n", true), "", true).xml_unescape()
	var entities := {
		"nbsp": " ", "aacute": "á", "eacute": "é", "iacute": "í", "oacute": "ó", "uacute": "ú",
		"Aacute": "Á", "Eacute": "É", "Iacute": "Í", "Oacute": "Ó", "Uacute": "Ú", "ntilde": "ñ", "Ntilde": "Ñ",
		"uuml": "ü", "Uuml": "Ü", "iexcl": "¡", "iquest": "¿", "ldquo": "“", "rdquo": "”", "lsquo": "‘", "rsquo": "’",
		"ndash": "–", "mdash": "—", "hellip": "…", "times": "×", "deg": "°", "middot": "·", "bull": "•",
	}
	for entity: String in entities:
		result = result.replace("&" + entity + ";", entities[entity])
	var spaces := RegEx.new()
	spaces.compile("[ \\t\\r\\f]+")
	return spaces.sub(result, " ", true).strip_edges()
