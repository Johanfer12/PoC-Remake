extends RefCounted
## Panel nativo: Yu440ff0/Jo45a0b0, una palabra por tick en idiomas occidentales.
## La variante japonesa Yu45d580 consume cuatro glifos, sin contar formato ni BR.
var _ends := PackedInt32Array()
var _at := 0
var visible := 0


func reset(text: String, japanese: bool) -> void:
	_ends.clear()
	_at = 0
	visible = 0
	var cursor := 0
	if japanese:
		var glyphs := 0
		while cursor < text.length():
			var letter := text[cursor]
			cursor += 1
			if letter in ["\n", "\r"]: continue
			glyphs += 1
			if glyphs % 4 == 0: _ends.append(cursor)
	else:
		while cursor < text.length():
			# BR no consume el presupuesto de palabras.
			while cursor < text.length() and text[cursor] in ["\n", "\r"]:
				cursor += 1
			var has_letter := false
			var start := cursor
			while cursor < text.length() and text[cursor] not in ["\n", "\r"]:
				var letter := text[cursor]
				cursor += 1
				if letter in [" ", "-"]:
					if has_letter: break
				else:
					has_letter = true
			if cursor > start: _ends.append(cursor)
	if text.length() > 0 and (_ends.is_empty() or _ends[-1] != text.length()):
		_ends.append(text.length())


func step() -> int:
	if _at < _ends.size():
		visible = _ends[_at]
		_at += 1
	return visible
