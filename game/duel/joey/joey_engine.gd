class_name JoeyEngine
extends JoeyPortZS
## Motor de duelo nativo de Joey: ultima clase de la cadena (JoeyDecl -> JoeyFrontier -> JoeyBase -> JoeyPortA..ZS).
## Ver docs/duel/PLAN_MOTOR_JOEY.md.


## Carga tablas de cartas e imagen nativa. Devuelve null si falta algo en data/.
static func create(data_dir: String) -> JoeyEngine:
	var tables := CardTables.new()
	if not tables.load_from(data_dir):
		return null
	var engine := JoeyEngine.new(tables)
	if not engine.load_data(data_dir):
		return null
	return engine


## The scene supplies local/opponent decks and a local janken choice (0 starts).
## Retail44bee0 assigns local index444210: host1, guest0.569380 maps the
## relative input decks to those absolute players; the wire never mirrors them.
func start_network(decks: Array[Dictionary], opts: int, rand_seed: int, transport: Object) -> void:
	assert(decks.size() == 2 and transport != null)
	network_transport = transport
	f5bdb20()
	var local := int(bool(transport.get("is_host")))
	var first := (opts & 1) ^ local
	m.set_u32(GAME_KIND, 3)
	m.set_u32(0x5f3288, local)
	m.set_u32(0x5f328c, first)
	m.set_u32(0x5f3290, rand_seed)
	for relative in 2:
		var address := 0xa54e60 + relative * 0xe2
		m.clear(address, 0xe2)
		for row in [["main", 0, 0xdc, 80], ["side", 0xa0, 0xde, 15], ["fusion", 0xbe, 0xe0, 15]]:
			var ids: Variant = decks[relative].get(row[0], [])
			assert(ids.size() <= int(row[3]))
			for i in ids.size():
				m.set_u16(address + int(row[1]) + i * 2, f402460(int(ids[i])))
			m.set_u16(address + int(row[2]), ids.size())
	f5bfeb0(local, first, rand_seed)
