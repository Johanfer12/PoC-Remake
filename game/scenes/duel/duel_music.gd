extends RefCounted
## Yu437530, Ka437ae0 y Jo44c320. Diferencia rival-humano en la memoria del port.
static func track(game: String, mode: int, lp: Array) -> String:
	var diff := int(lp[1]) - int(lp[0])
	if game == "yugi" and mode == 6: return "tutorial"
	if game == "kaiba" and mode == 6: return "m_tuto"
	if diff > 2999: return "lp_furi" if game == "yugi" else "m_furi"
	if diff < -2999: return "lp_yuri" if game == "yugi" else "m_yuri"
	match game:
		"yugi": return "stage2" if mode == 1 else "stage1"
		"kaiba": return "m_duel2" if mode == 1 else "m_duel1"
		"joey": return "m_duel1" if mode == 3 else "m_duel3" if mode == 1 else "m_duel2"
	return ""

static func path(game: String, mode: int, lp: Array) -> String:
	return "%s/voice/stream/%s.wav" % [game, track(game, mode, lp)]
