class_name RivalDeckChoice
extends RefCounted
## Tablas y ramas nativas: Kaiba 438210; Joey 44bbe0.
## `draw` es el MT de interfaz; separado para comprobar cada rama y sus tiradas.

const KAIBA := [
	["kaiba_j", "kaiba_jj", "kaiba_gensaku", "kaiba_equip", "kaiba_hand", "kaiba_fusion", "kaiba_deck", "kaiba_blueeyes", "kaiba_inifu", "kaiba_dragon", "kaiba_k", "kaiba_kk", "kaiba_kkk"],
	["kaiba_deck", "kaiba_inifu", "yk_bokori", "yk_kongo", "yk_counter", "kaiba_fusion", "kaiba_blueeyes", "kaiba_equip", "kaiba_kkk", "kaiba_kk", "yk_k", "yk_kk", "yk_kkk"],
]
const JOEY_CPU := [[0, 1, 2, 3, 4], [3, 4, 10, 11, 12], [10, 11, 12, 13, 14], [13, 14, 15, 20, 21], [20, 21, 22, 23, 24], [23, 24, 25, 26, 27], [25, 26, 27, 28, 29]]
const JOEY_FULL := [
	["0ge1", "0umi", "0val"],
	["1dec", "1red", "1too", "1ins", "1uij", "1umi", "1val"],
	["1fus", "1gam", "1ge1", "1ge2", "1hik", "1mix"],
	["2dec", "2val", "2too", "2ge1", "2hik", "2ins", "2uij"],
	["2fus", "2gam", "2ge2", "2mix", "2red", "2umi"],
	["3all", "3dec", "3yam", "3fus", "3too", "3hnd"],
	["3all", "3dec", "3exo", "3fus", "3grv", "3hnd"],
]


static func kaiba(pct: int, last: int, run: int, mixed: bool, draw: Callable) -> String:
	var pool: Array = KAIBA[int(mixed)]
	var index := -1
	if pct < 40:
		if last == 2 and run >= 2 and (int(draw.call()) & 1) == 0:
			index = 1
		if last == 1:
			if run > 5 and int(draw.call()) % 3 == 0:
				index = 10
			elif run > 3 and (int(draw.call()) & 3) == 0:
				index = 10
	elif pct < 65:
		if last == 2 and run >= 3 and int(draw.call()) % 3 == 0:
			index = int(draw.call()) & 1
		if last == 1:
			if run > 5 and (int(draw.call()) & 1) == 0:
				index = 11 + (int(draw.call()) & 1)
			elif run > 3 and int(draw.call()) % 3 == 0:
				index = 10 + (int(draw.call()) & 1)
	elif pct < 85:
		if last == 2 and run >= 3 and int(draw.call()) % 3 == 0:
			index = 1
		if last == 1:
			if run > 4 and (int(draw.call()) & 1) == 0:
				index = 11 + (int(draw.call()) & 1)
			elif run > 2 and int(draw.call()) % 3 == 0:
				index = 11 + (int(draw.call()) & 1)
	else:
		index = 2 + int(draw.call()) % (10 + int(mixed))
	if index < 0:
		index = 2 + (int(draw.call()) & 7)
	return "kaiba/file/%s.json" % pool[index]


static func joey(level: int, mixed: bool, draw: Callable) -> String:
	if not mixed:
		return "joey/file/cpu_%03d.json" % JOEY_CPU[clampi(level, 1, 7) - 1][int(draw.call()) % 5]
	var pool: Array = JOEY_FULL[clampi(level + 2, 3, 9) - 3]
	return "joey/file/ful_%s.json" % pool[int(draw.call()) % pool.size()]


## 446df0; tablas DWORD 5daf40 y 5daf64. El match solo cambia nivel al decidirse.
## FF inicial: 446f43 lee sin signo; tablas solapadas PE5db360/5db368.
const JOEY_INITIAL_LOSS_THRESHOLDS := {255: 4530096, 257: 4206720}

static func joey_after_result(level: int, mixed: bool, last: int, run: int, decided: bool) -> Vector2i:
	if not decided:
		return Vector2i(level, run)
	var offset := int(mixed) * 2
	var effective := maxi(1, (level & 255) + offset)
	if last == 1:
		if effective < (9 if mixed else 7) and run >= [0, 3, 4, 5, 5, 5, 6, 6, 7][effective]:
			return Vector2i(effective - offset + 1, 0)
	elif effective > offset + 1:
		var thresholds := [0, 0, 3, 4, 4, 4, 4, 3, 2, 2]
		var threshold: int = thresholds[effective] if effective < thresholds.size() else JOEY_INITIAL_LOSS_THRESHOLDS[effective]
		if run >= threshold: return Vector2i((effective - offset - 1) & 255, 0)
	return Vector2i(level, run)
