extends RefCounted
## Composición nativa compartida: 5417e0/53fac0/53fb40/53f9f0.
## Las marcas @0-@9 las convierte 5415c0 en etiquetas de color con la tabla de cada juego
## (Yugi 0x59e148, Kaiba 0x5a1228, Joey 0x5dda6c): @1-@9 abren <FONT color>, @0 la cierra.
## Una "@" sin cifra detrás se queda tal cual, también en el original.
const MARKS := {
	"yugi": ["#ffffff", "#7dd1ff", "#ff7ddd", "#ff00ff", "#00ff00", "#ffff00", "#3560dc", "#000000", "#808080"],
	"kaiba": ["#ffffff", "#7dd1ff", "#ff7ddd", "#ff00ff", "#00ff00", "#ffff00", "#3560dc", "#000000", "#808080"],
	"joey": ["#ffffff", "#8cffd8", "#fa8fe2", "#ff00ff", "#00ff00", "#ffff00", "#3560dc", "#000000", "#808080"],
}


## Texto del cuadro; con keep_marks conserva las marcas @n para dibujarlas con `runs`.
static func format(dialogs: Array, d: Dictionary, keep_marks := false) -> String:
	var raw := _compose(dialogs, d)
	var pages: PackedStringArray = []
	for page in raw.split("<HR>", false):
		page = page.replace("<BR>", "\n").replace("\r", "")
		if not keep_marks:
			page = strip_marks(page)
		page = page.strip_edges()
		if strip_marks(page).strip_edges() != "":
			pages.append(page)
	return "\n".join(pages)


## Componer antes de normalizar saltos: un fragmento <BR> no debe desaparecer.
static func _compose(dialogs: Array, d: Dictionary) -> String:
	var msg := int(d.get("msg", -1))
	var raw: String = str(d.literal) if d.has("literal") else (String(dialogs[msg]) if msg >= 0 and msg < dialogs.size() else "")
	for s: Dictionary in d.get("subs", []):
		if s.has("card"):
			raw = _replace_first(raw, "%s", CardDB.name_of(int(s["card"])))
		elif s.has("msg"):
			var id := int(s["msg"])
			raw = _replace_first(raw, "%s", String(dialogs[id]) if id >= 0 and id < dialogs.size() else "")
		elif s.has("d"):
			raw = _replace_first(raw, "%d", str(int(s["d"])))
		elif s.has("append"):
			var id := int(s["append"])
			raw += "<BR>" + (String(dialogs[id]) if id >= 0 and id < dialogs.size() else "")
		elif s.get("prefix_break", false):
			raw = "<BR>" + raw
	for suffix: Dictionary in d.get("suffixes", []):
		raw += _compose(dialogs, suffix)
	return raw


static func strip_marks(text: String) -> String:
	return RegEx.create_from_string("@[0-9]").sub(text, "", true)


## Trozos [texto, Color] de `text` sin marcas. Las etiquetas se anidan como en HTML: @0 vuelve
## al color anterior y una sin cerrar sigue hasta el final.
static func runs(text: String, game: String, base := Color(1, 1, 1)) -> Array:
	var colors: Array = MARKS.get(game, MARKS["yugi"])
	var stack: Array[Color] = [base]
	var out := []
	var from := 0
	var at := 0
	while at < text.length():
		var digit := text.unicode_at(at + 1) - 0x30 if at + 1 < text.length() else -1
		if text[at] == "@" and digit >= 0 and digit <= 9:
			if at > from:
				out.append([text.substr(from, at - from), stack[-1]])
			if digit == 0:
				if stack.size() > 1: stack.pop_back()
			else:
				stack.append(Color(colors[digit - 1]))
			at += 2
			from = at
		else:
			at += 1
	if at > from:
		out.append([text.substr(from, at - from), stack[-1]])
	return out


static func _replace_first(text: String, what: String, with: String) -> String:
	var at := text.find(what)
	return text if at < 0 else text.substr(0, at) + with + text.substr(at + what.length())
