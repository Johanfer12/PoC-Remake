extends Node
## Android updates keep user content separate and delegate installation to Android.
signal changed
const REPOSITORY := "https://github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake"
const API := "https://api.github.com/repos/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/releases?per_page=100"
const HEADERS := ["Accept: application/vnd.github+json", "User-Agent: PowerOfChaos-AndroidUpdater"]
const APK := "PowerOfChaos-Android.apk"
var current := "v" + str(ProjectSettings.get_setting("application/config/version", "0.0.0"))
var version_code := 0
var certificate := ""
var available := ""
var state := "idle"
var detail := ""
var _http := HTTPRequest.new()
var _asset_url := ""
var _metadata_url := ""
var _phase := ""
var _checked := false

func _ready() -> void:
	if FileAccess.file_exists("res://build_info.json"):
		var info: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://build_info.json"))
		if info is Dictionary:
			current = str(info.get("version", current))
			version_code = int(info.get("android_version_code", 0))
			certificate = str(info.get("android_signing_sha256", "")).to_lower()
	_http.timeout = 30
	_http.body_size_limit = 4 * 1024 * 1024
	_http.use_threads = true
	add_child(_http)
	_http.request_completed.connect(_completed)

func supported() -> bool:
	return OS.has_feature("android")

func check_once() -> void:
	if _checked or not supported() or DisplayServer.get_name() == "headless": return
	_checked = true
	check()

func check() -> void:
	if state in ["checking", "validating"]: return
	available = ""
	_state("checking")
	_request(API, "releases")

func _state(value: String, message := "") -> void:
	state = value
	detail = message
	changed.emit()

func _request(url: String, phase: String) -> void:
	_phase = phase
	if _http.request(url, HEADERS) != OK:
		_fail("No se pudo conectar con GitHub. / Could not connect to GitHub.")

static func version_parts(tag: String) -> Array:
	var regex := RegEx.new()
	regex.compile("^v?(\\d+)\\.(\\d+)\\.(\\d+)(?:-(alpha|beta|rc)\\.(\\d+))?$")
	var found := regex.search(tag)
	if found == null: return []
	return [found.get_string(1).to_int(), found.get_string(2).to_int(), found.get_string(3).to_int(), ["alpha", "beta", "rc", ""].find(found.get_string(4)), found.get_string(5).to_int()]

static func newer(candidate: String, installed: String) -> bool:
	var a := version_parts(candidate)
	var b := version_parts(installed)
	if a.is_empty() or b.is_empty(): return false
	for i in a.size():
		if a[i] != b[i]: return a[i] > b[i]
	return false

static func trusted_asset(url: String) -> bool:
	return url.begins_with(REPOSITORY + "/releases/download/") and not "?" in url and not "#" in url

func select_release(releases: Array, request_metadata := true) -> void:
	available = ""
	_asset_url = ""
	_metadata_url = ""
	for release: Variant in releases:
		if not release is Dictionary or release.get("draft", false): continue
		var tag := str(release.get("tag_name", ""))
		if not newer(tag, current) or (available != "" and not newer(tag, available)): continue
		if release.get("prerelease", false) and not "-" in current: continue
		var apk := ""
		var metadata := ""
		var assets: Variant = release.get("assets", [])
		if not assets is Array: continue
		for asset: Variant in assets:
			if not asset is Dictionary or asset.get("state", "uploaded") != "uploaded": continue
			var url := str(asset.get("browser_download_url", ""))
			if not trusted_asset(url) or not url.begins_with(REPOSITORY + "/releases/download/" + tag + "/"): continue
			if asset.get("name") == APK: apk = url
			elif asset.get("name") == "ANDROID_RELEASE.json": metadata = url
		if apk != "" and metadata != "":
			available = tag
			_asset_url = apk
			_metadata_url = metadata
	if available.is_empty():
		_state("current")
	else:
		_state("validating")
		if request_metadata: _request(_metadata_url, "metadata")

func validate_metadata(info: Variant) -> bool:
	if not info is Dictionary or info.get("package") != "org.porttesting.powerofchaos" or info.get("version") != available or info.get("apk") != APK or info.get("original_game_data_included", true):
		_fail("Información Android inválida. / Invalid Android release metadata.")
		return false
	var sha := str(info.get("sha256", "")).to_lower()
	if sha.length() != 64 or not sha.is_valid_hex_number():
		_fail("SHA-256 Android inválido. / Invalid Android SHA-256.")
		return false
	if int(info.get("version_code", 0)) <= version_code:
		available = ""
		_state("current")
		return false
	if certificate.is_empty() or str(info.get("signing_certificate_sha256", "")).to_lower() != certificate:
		_state("manual", "Este APK usa otra firma. Genera la actualización con tu firma original desde PC. / This APK uses a different signing key. Build an update with your original key on PC.")
		return false
	_state("available")
	return true

func download() -> void:
	if not supported() or state != "available": return
	# Never replace a content-bearing APK before a persistent copy is ready.
	var paths: Node = get_tree().root.get_node("Paths")
	if not paths.content_pack_persistent and not FileAccess.file_exists(paths.storage_dir.path_join("data/inventory.json")):
		_fail("Primero importa o conserva tus recursos en la aplicación. / Import or preserve your game content first.")
		return
	if OS.shell_open(_asset_url) != OK:
		_fail("No se pudo abrir la descarga. / Could not open the download.")
		return
	_state("opened", "Descarga el APK y confirma la actualización en Android. No desinstales la aplicación. / Download the APK and confirm the Android update. Do not uninstall the application.")

func _completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_fail("Conexión fallida (HTTP %d). / Connection failed." % code)
		return
	var value: Variant = JSON.parse_string(body.get_string_from_utf8())
	if _phase == "releases":
		if value is Array: select_release(value)
		else: _fail("Respuesta de GitHub inválida. / Invalid GitHub response.")
	elif _phase == "metadata": validate_metadata(value)

func cancel() -> void:
	if state in ["checking", "validating"]:
		_http.cancel_request()
		_state("idle")

func _fail(message: String) -> void:
	_state("error", message)
