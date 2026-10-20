class_name DuelScenario
extends RefCounted
## Escenarios de prueba para el duelo normal (herramienta de desarrollo; no existe en el
## original). Un escenario es un JSON en res://scenarios/ que fija quien empieza, la semilla,
## los mazos, las cartas que se roban primero y las que ya estan en el campo, para llegar a
## una situacion concreta sin esperar a que salga al azar.
##
##     {
##       "description": "texto libre",
##       "first": 0,                       # 0 empiezas tu, 1 empieza la CPU
##       "seed": 1234,                     # semilla del barajado (opcional)
##       "decks": [null, null],            # null = tu mazo activo / mazo de demo1
##       "hands": [["Summoned Skull", "0x28"], ["Trap Hole"]],
##       "field": [[{"card": "Celtic Guardian", "zone": 0, "c": 0}], []],
##       "grave": [["Dark Magician"], []],  # opcional
##       "lp": [8000, 100]                  # opcional: LP tras el reparto
##     }
##
## Las cartas se indican por id interno (numero o "0x..") o por nombre (ingles o espanol).
## `hands[p]` se roba en ese orden: las cinco primeras son la mano inicial y la sexta el
## primer robo; si faltan en el mazo se anaden a el. `field[p]` usa el comando 0xf4 de los
## tutoriales: zona 0-4 monstruo (c: 0 ataque, 1 defensa, +10 boca abajo), zona 5-9
## magia/trampa (c != 0 boca abajo), zona 10 magia de campo. `grave[p]` son cartas del mazo
## (se anaden si faltan) que van al cementerio tras el reparto con el comando 0x67 del motor
## (FUN_00549550, del mazo al cementerio), antes de colocar el campo.
## Uso: godot --path game -- --scenario=<nombre> (o "Jugar escenario.bat").

const DIR := "res://scenarios"

var description := ""
var first := 1
## LP de cada jugador tras el reparto (vacio = 8000).
var lp: Array = []
var seed := -1
var decks: Array = [null, null]
var hands: Array = [[], []]
var field: Array = [[], []]
var grave: Array = [[], []]
## Cartas que se anaden al mazo de fusion de cada jugador ("fusion": [[ids], [ids]]).
var fusion: Array = [[], []]
var errors: PackedStringArray = []


## Nombres de los escenarios disponibles (sin extension).
static func list() -> PackedStringArray:
	var out: PackedStringArray = []
	for file in DirAccess.get_files_at(DIR):
		if file.ends_with(".json"):
			out.append(file.get_basename())
	out.sort()
	return out


## Carga `name_or_path` (nombre de res://scenarios o ruta a un .json). null si no existe.
static func load_named(name_or_path: String) -> DuelScenario:
	var path := name_or_path
	if not path.ends_with(".json"):
		path = DIR.path_join(name_or_path + ".json")
	if not FileAccess.file_exists(path):
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return null
	var s := DuelScenario.new()
	s._read(parsed)
	return s


func _read(d: Dictionary) -> void:
	description = String(d.get("description", ""))
	first = int(d.get("first", 1)) & 1
	seed = int(d.get("seed", -1))
	lp = []
	for v in d.get("lp", []):
		lp.append(int(v))
	var raw_decks: Array = d.get("decks", [null, null])
	var raw_hands: Array = d.get("hands", [[], []])
	var raw_field: Array = d.get("field", [[], []])
	var raw_grave: Array = d.get("grave", [[], []])
	var raw_fusion: Array = d.get("fusion", [[], []])
	for p in 2:
		decks[p] = null
		if p < raw_decks.size() and raw_decks[p] is Dictionary:
			decks[p] = {"main": _ids(raw_decks[p].get("main", [])), "side": _ids(raw_decks[p].get("side", [])), "fusion": _ids(raw_decks[p].get("fusion", []))}
		hands[p] = _ids(raw_hands[p]) if p < raw_hands.size() else PackedInt32Array()
		grave[p] = _ids(raw_grave[p]) if p < raw_grave.size() else PackedInt32Array()
		fusion[p] = _ids(raw_fusion[p]) if p < raw_fusion.size() else PackedInt32Array()
		var placed: Array = []
		if p < raw_field.size():
			for entry: Dictionary in raw_field[p]:
				var id := resolve(entry.get("card", ""))
				if id >= 0:
					placed.append({"card": id, "zone": int(entry.get("zone", 0)), "c": int(entry.get("c", 0))})
		field[p] = placed


func _ids(values: Array) -> PackedInt32Array:
	var out := PackedInt32Array()
	for v in values:
		var id := resolve(v)
		if id >= 0:
			out.append(id)
	return out


## Id interno de una carta indicada por numero, "0x..." o nombre (ingles o espanol).
func resolve(value: Variant) -> int:
	if value is int or value is float:
		return int(value)
	var text := String(value).strip_edges()
	if text.begins_with("0x"):
		return text.hex_to_int()
	if text.is_valid_int():
		return text.to_int()
	var lower := text.to_lower()
	for card: Dictionary in _card_list():
		var names: Dictionary = card.get("names", {})
		for lang in ["eng", "spa"]:
			if String(names.get(lang, "")).to_lower() == lower:
				return int(card["internal_id"])
	errors.append("carta desconocida: %s" % text)
	return -1


static var _cards_cache: Array = []


## Cartas de la base de datos: las del autoload CardDB o, en las pruebas sin arbol de escena
## (-s), las de data/common/db/cards.json.
static func _card_list() -> Array:
	var tree := Engine.get_main_loop() as SceneTree
	var db: Node = tree.root.get_node_or_null("CardDB") if tree != null else null
	if db != null and not db.get("cards").is_empty():
		return db.get("cards")
	if _cards_cache.is_empty():
		var path := ProjectSettings.globalize_path("res://../data/common/db/cards.json").simplify_path()
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		_cards_cache = parsed if parsed is Array else []
	return _cards_cache


## Mazos de la partida: los del escenario o los indicados; se anaden las cartas de la mano
## que falten para que se puedan robar.
func build_decks(defaults: Array[Dictionary]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for p in 2:
		var deck: Dictionary = (decks[p] if decks[p] != null else defaults[p]).duplicate(true)
		var main: PackedInt32Array = deck["main"]
		var available := Array(main)
		for id in Array(hands[p]) + Array(grave[p]):
			var k := available.find(id)
			if k >= 0:
				available.remove_at(k)
			else:
				main.append(id)
		deck["main"] = main
		var fusion_deck: PackedInt32Array = deck.get("fusion", PackedInt32Array())
		fusion_deck.append_array(fusion[p])
		deck["fusion"] = fusion_deck
		out.append(deck)
	return out


## Aplica al motor la mano y el campo (despues de start_normal).
func apply(duel: Duel) -> PackedStringArray:
	var warnings := errors.duplicate()
	warnings.append_array(duel.apply_scenario({"hands": hands, "field": field, "grave": grave, "lp": lp}))
	return warnings
