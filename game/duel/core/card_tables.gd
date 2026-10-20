class_name CardTables
extends RefCounted
## Tablas de cartas tal como las consulta el motor del duelo (data/common/bin).
##
## El motor guarda en memoria el INDICE de la carta (12 bits) y lo traduce cuando hace falta:
##   id_of(indice)     = CARD_ID.bin[indice]   (FUN_00401a70; 0xffff si se sale de la tabla)
##   index_of(id)      = CARD_IntID.bin[id % 2000] + (id >= 2000)   (FUN_00401ad0)
##   prop(indice)      = CARD_Prop.bin[indice]  (FUN_00401a20)
## Los .ydc, los .ydr y los argumentos de los comandos usan el id ("internal_id" en cards.json).
##
## Campos de prop: bits 0-8 DEF/10, 9-17 ATK/10, 18-19 clase de monstruo, 20-24 tipo
## (21 = trampa, 22 = magia, < 21 monstruo), 25-28 nivel, 29-31 atributo.

const MAX_INDEX := 0x45b

var ids := PackedInt32Array()
var int_ids := PackedInt32Array()
var props := PackedInt64Array()
var packs := PackedInt32Array()


func load_from(data_dir: String) -> bool:
	var bin_dir := data_dir.path_join("common/bin")
	var id_bytes := FileAccess.get_file_as_bytes(bin_dir.path_join("card_id.bin"))
	var int_bytes := FileAccess.get_file_as_bytes(bin_dir.path_join("card_intid.bin"))
	var prop_bytes := FileAccess.get_file_as_bytes(bin_dir.path_join("card_prop.bin"))
	var pack_bytes := FileAccess.get_file_as_bytes(bin_dir.path_join("card_pack.bin"))
	if id_bytes.is_empty() or int_bytes.is_empty() or prop_bytes.is_empty() or pack_bytes.is_empty():
		return false
	ids.resize(id_bytes.size() / 2)
	for i in ids.size():
		ids[i] = id_bytes.decode_u16(i * 2)
	int_ids.resize(int_bytes.size() / 2)
	for i in int_ids.size():
		int_ids[i] = int_bytes.decode_u16(i * 2)
	props.resize(prop_bytes.size() / 4)
	for i in props.size():
		props[i] = prop_bytes.decode_u32(i * 4)
	packs.resize(pack_bytes.size() / 2)
	for i in packs.size():
		packs[i] = pack_bytes.decode_u16(i * 2)
	return true


## FUN_00401a70
func id_of(index: int) -> int:
	index &= 0xffff
	if index > MAX_INDEX or index >= ids.size():
		return 0xffff
	return ids[index]


## FUN_00401ad0
func index_of(card_id: int) -> int:
	card_id &= 0xffff
	if card_id > 3999:
		return 0
	return int_ids[card_id % 2000] + (1 if card_id > 1999 else 0)


## FUN_00401a20
func prop(index: int) -> int:
	index &= 0x7ff
	return props[index] if index < props.size() else 0


## Tipo (bits 20-24): < 21 monstruo, 21 trampa, 22 magia.
func type_of(index: int) -> int:
	return (prop(index) >> 20) & 0x1f
