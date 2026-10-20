class_name JoeyReplayEngine
extends JoeyEngine
## File cursor bridge of the original 449df0..449e20. Rules remain native.
var replay_commands: Array[PackedInt32Array] = []
var replay_position := 0
var replay_active := false
var _replay_word := 0


func configure_replay(replay: Ydr, mode := 4) -> void:
	replay_commands = replay.commands.duplicate()
	replay_position = 0
	replay_active = true
	network_transport = null
	events.clear()
	recorded.clear()
	unported_calls.clear()
	m.set_u32(VERSION, replay.duel_version)
	m.set_u32(GAME_KIND, mode)
	for p in 2:
		var at := 0xa54e60 + p * 0xe2
		m.clear(at, 0xe2)
		for row in [["main", 0, 0xdc, 80], ["side", 0xa0, 0xde, 15], ["fusion", 0xbe, 0xe0, 15]]:
			var ids: Variant = replay.decks[p].get(row[0], [])
			assert(ids.size() <= int(row[3]))
			for i in ids.size(): m.set_u16(at + int(row[1]) + i * 2, f402460(int(ids[i])))
			m.set_u16(at + int(row[2]), ids.size())
	f5bfeb0(0, replay.options & 1, replay.seed)


func f449df0() -> int:
	if not replay_active: return super.f449df0()
	if _replay_word == 0: _replay_word = m.local(8)
	m.clear(_replay_word, 8)
	if replay_position < replay_commands.size():
		for i in 4: m.set_u16(_replay_word + i * 2, replay_commands[replay_position][i])
	return _replay_word


func f449e00() -> int:
	if not replay_active: return super.f449e00()
	replay_position = mini(replay_position + 1, replay_commands.size())
	return 0


func f449e10() -> int:
	if not replay_active: return super.f449e10()
	replay_position = 0
	return 0


func f449e20() -> int:
	if not replay_active: return super.f449e20()
	return int(replay_position >= replay_commands.size())


func f5b9370(op: int, a: int, b: int, c: int) -> int:
	var count := m.u16(JoeyMem.QUEUE_COUNT)
	var result := super.f5b9370(op, a, b, c)
	if replay_active and m.u16(JoeyMem.QUEUE_COUNT) > count:
		recorded.append(PackedInt32Array([op & 65535, a & 65535, b & 65535, c & 65535]))
	return result
