class_name NativeDeckStartup
extends RefCounted
## Joey 44a550 ->5bea80: prune an existing deck without granting cards.
## 44aa00 returns 0xb for pruning or invalid size; these do not select the starter.
const IMPORT := preload("res://core/native_deck_import.gd")
const LIMITS := preload("res://core/native_card_limits.gd")


static func resolve_joey(deck: Dictionary, collection: Dictionary, native: Dictionary) -> Dictionary:
	var limit := func(id: int) -> int: return LIMITS.copy_limit("joey", id, native)
	return IMPORT.filter(deck, "joey", collection, limit, LIMITS.COPY_VARIANTS, CardDB.by_id)
