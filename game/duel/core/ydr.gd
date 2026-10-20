class_name Ydr
extends RefCounted
## Repeticion del duelo (.ydr). Mismo formato que lee y escribe el original (0x436f60):
##   "YGR\0", u32 version, u32 marca del mazo, u32 version del duelo (100),
##   u32 opciones (bit 0 = jugador que empieza), u32 semilla (time(NULL)),
##   Joey >=1001 intercala u32 jugador local antes de opciones (cabecera 28 bytes).
##   dos mazos de tres listas (principal, fusion, side; u16 n + n * u16 id),
##   u32 n + n comandos de 8 bytes (u16 opcode con el jugador en el bit 15 + 3 * u16).
## Ver tools/pocx/replay.py, que hace lo mismo en Python.

const MAGIC := "YGR"

var version := 0
var deck_mark := 0
var duel_version := 0
## Joey >=1001 añade el jugador local antes de FIRST/SEED (44ad50).
var local_player := 0
## Compatibilidad explícita con archivos del antiguo port que omitían LOCAL.
var legacy_missing_local_player := false
var options := 0
var seed := 0
## [{main, fusion, side}, {main, fusion, side}] con ids de carta
var decks: Array[Dictionary] = []
## Comandos tal cual: cada uno PackedInt32Array([opcode, a, b, c]) con el bit 15 en opcode.
var commands: Array[PackedInt32Array] = []


static func load_file(path: String) -> Ydr:
	var data := FileAccess.get_file_as_bytes(path)
	if data.is_empty():
		return null
	return parse(data)


static func parse(data: PackedByteArray) -> Ydr:
	if data.size() < 0x18 or data.slice(0, 3).get_string_from_ascii() != MAGIC or data[3] != 0:
		return null
	if data.decode_u32(12) >= 1001:
		var native := _parse_layout(data, true)
		if native != null: return native
		var legacy := _parse_layout(data, false)
		if legacy != null: legacy.legacy_missing_local_player = true
		return legacy
	return _parse_layout(data, false)


static func _parse_layout(data: PackedByteArray, has_local: bool) -> Ydr:
	var off := 0x1c if has_local else 0x18
	if data.size() < off: return null
	var r := Ydr.new()
	r.version = data.decode_u32(4)
	r.deck_mark = data.decode_u32(8)
	r.duel_version = data.decode_u32(12)
	if has_local:
		r.local_player = data.decode_u32(16)
		if r.local_player > 1: return null
	r.options = data.decode_u32(20 if has_local else 16)
	r.seed = data.decode_u32(24 if has_local else 20)
	for p in 2:
		var deck := {}
		for list_name in ["main", "fusion", "side"]:
			if off + 2 > data.size(): return null
			var n := data.decode_u16(off)
			off += 2
			if off + n * 2 > data.size(): return null
			var ids := PackedInt32Array()
			for i in n:
				ids.append(data.decode_u16(off + i * 2))
			off += n * 2
			deck[list_name] = ids
		r.decks.append(deck)
	if off + 4 > data.size(): return null
	var count := data.decode_u32(off)
	off += 4
	if off + count * 8 != data.size():
		return null
	for i in count:
		var o := off + i * 8
		r.commands.append(PackedInt32Array([data.decode_u16(o), data.decode_u16(o + 2),
				data.decode_u16(o + 4), data.decode_u16(o + 6)]))
	return r


var first_player: int:
	get:
		return options & 1


## Escritura en el mismo orden que 0x436f60 en modo escritura (+0x28 = 1): marca, 8 bytes de
## version y marca de mazo, version del duelo ((DAT_005aed1c + 1) * 100), opciones
## (DAT_005af770), semilla (DAT_005af774), los dos mazos (0x436900) y los comandos (0x436b40).
## Joey44ad50 añade LOCAL desde1001 y escribe los mazos en orden absoluto.
func to_bytes() -> PackedByteArray:
	var out := PackedByteArray()
	out.append_array(MAGIC.to_ascii_buffer())
	out.append(0)
	var header := [version, deck_mark, duel_version]
	if duel_version >= 1001: header.append(local_player)
	header.append_array([options, seed])
	for v in header:
		var b := PackedByteArray()
		b.resize(4)
		b.encode_u32(0, int(v) & 0xffffffff)
		out.append_array(b)
	for p in 2:
		for list_name in ["main", "fusion", "side"]:
			var ids: PackedInt32Array = decks[p].get(list_name, PackedInt32Array())
			var b := PackedByteArray()
			b.resize(2 + ids.size() * 2)
			b.encode_u16(0, ids.size())
			for i in ids.size():
				b.encode_u16(2 + i * 2, ids[i] & 0xffff)
			out.append_array(b)
	var head := PackedByteArray()
	head.resize(4)
	head.encode_u32(0, commands.size())
	out.append_array(head)
	for cmd in commands:
		var b := PackedByteArray()
		b.resize(8)
		for k in 4:
			b.encode_u16(k * 2, cmd[k] & 0xffff)
		out.append_array(b)
	return out


func save(path: String) -> bool:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(to_bytes())
	f.close()
	return true
