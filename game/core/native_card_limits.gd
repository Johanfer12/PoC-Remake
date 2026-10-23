class_name NativeCardLimits
extends RefCounted
## Shared editor/startup limits from Y53fd30, Ka542400 and Jo5be190.
## Native flags are read from native_system, including Joey's original byte +10ee.

const MAX_COPIES := 3
const OLD_FORBIDDEN := [1902, 1903, 1910, 1911, 1912, 1920, 1921, 1922, 1923]
const OLD_LIMITED := [20, 17, 19, 16, 18, 1010, 968, 1027, 335, 336, 1008, 1056,
	1071, 1070, 1081, 1077, 1068, 1106, 1065, 347, 1221, 573, 1154, 751, 1150,
	1160, 1095, 1314, 47, 1061, 671, 1214, 939, 1450, 1449, 474]
const JOEY_FORBIDDEN := [1106, 1071, 1081, 1027, 336, 671, 1154]
const JOEY_LIMITED := [474, 47, 573, 751, 20, 17, 19, 16, 18, 1070, 1061, 1077,
	1068, 1010, 1008, 1449, 1221, 968, 1065, 1160, 347, 335, 1450, 1056, 1150,
	939, 1214, 1095]
## Alias copies count main/side, except the two Fusion pairs which count Fusion.
const COPY_VARIANTS := [[0, 2000], [14, 2014], [34, 1210, 2034], [37, 2037],
	[40, 2040], [57, 1901], [61, 1249], [63, 2063], [68, 2068], [387, 2387],
	[389, 2389], [1003, 1034]]


static func copy_limit(game: String, id: int, native: Dictionary) -> int:
	if game == "joey":
		if id in JOEY_FORBIDDEN:
			var block := Marshalls.base64_to_raw(str(native.get("block", "")))
			return 0 if block.size() > 0x10ee and block[0x10ee] != 0 else 1
		if id in JOEY_LIMITED:
			return 1
		return 2 if id in [1163, 590, 1157] else MAX_COPIES
	if id in OLD_FORBIDDEN:
		return 0
	if int(native.get("limit_flags", 0)) & 1:
		return MAX_COPIES
	if id in OLD_LIMITED:
		return 1
	return 2 if id in [1157, 1147, 1163, 590] else MAX_COPIES
