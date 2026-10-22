class_name Ydc
extends RefCounted
## Formato de mazo .ydc del original (Deck.ydc, file/cpu*.ydc):
##   8 bytes de cabecera: byte0/version y u32 +4/fecha de la coleccion.
##   El editor exporta la cabecera de system.dat; herramientas sin cabecera usan 1/0.
##   y tres listas en este orden: principal, fusion, side; cada una u16 n + n x u16 id interno.


static func save(path: String, deck: Dictionary, head := PackedByteArray()) -> bool:
	if not head.is_empty() and head.size() != 8: return false
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	if head.is_empty():
		f.store_32(1)
		f.store_32(0)
	else:
		f.store_buffer(head)
	for zone in ["main", "fusion", "side"]:
		var ids: Array = deck.get(zone, [])
		f.store_16(ids.size())
		for id in ids:
			f.store_16(int(id))
	f.close()
	return true


## Los 8 bytes de cabecera (vacio si no caben). El original (0x436bf0 -> 0x442750) solo
## compara el byte 0 y el u32 de +4 con los de la cabecera del system.dat.
static func header(path: String) -> PackedByteArray:
	var raw := FileAccess.get_file_as_bytes(path)
	return raw.slice(0, 8) if raw.size() >= 8 else PackedByteArray()

static func header_matches(actual: PackedByteArray, expected: PackedByteArray) -> bool:
	return actual.size() == 8 and expected.size() == 8 and actual[0] == expected[0] and actual.decode_u32(4) == expected.decode_u32(4)


## Devuelve {main, fusion, side} o {} si el archivo no es valido.
static func load(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null or f.get_length() < 14:
		return {}
	f.get_32()
	f.get_32()
	var deck := {}
	for zone in ["main", "fusion", "side"]:
		if f.get_position() + 2 > f.get_length():
			return {}
		var n := f.get_16()
		if n > 200 or f.get_position() + n * 2 > f.get_length():
			return {}
		var ids: Array = []
		for i in n:
			ids.append(f.get_16())
		deck[zone] = ids
	return deck
