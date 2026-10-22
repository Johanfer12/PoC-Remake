class_name NativeDeckImport
extends RefCounted
## Y540450/Ka542b20/Jo5bea80: limpieza al importar, antes de reemplazar el editor.
## Quita por intercambio con la ultima carta, recorriendo main, Fusion y Side.

static func filter(deck: Dictionary, game: String, collection: Dictionary,
		limit: Callable, variants: Array, card_by_id: Callable) -> Dictionary:
	var pending: Dictionary = deck.duplicate(true)
	var accepted := {"main": [], "side": [], "fusion": []}
	var removed := {}
	var mask: int = {"yugi": 1, "kaiba": 3, "joey": 7}[game]
	for zone in ["main", "fusion", "side"]:
		var i := 0
		while i < pending[zone].size():
			var id := int(pending[zone][i])
			var card: Dictionary = card_by_id.call(id)
			var used: int = accepted.main.count(id) + accepted.side.count(id) + accepted.fusion.count(id)
			for group in variants:
				if id not in group: continue
				for alias in group:
					if alias == id: continue
					used += accepted.fusion.count(alias) if id in [14, 2014, 68, 2068] else accepted.main.count(alias) + accepted.side.count(alias)
				break
			var owned := int(collection.get(str(id), 0)) & 255
			var usable: bool = not card.is_empty() and (int(card.pack) & mask) != 0
			if not usable or used >= int(limit.call(id)) or accepted[zone].count(id) >= owned:
				removed[id] = int(removed.get(id, 0)) + 1
				pending[zone][i] = pending[zone].back()
				pending[zone].pop_back()
			else:
				accepted[zone].append(id)
				i += 1
	return {"deck": accepted, "removed": removed}
