class_name DuelVisualMath
extends RefCounted
## 5325a0: cos(i*pi/256)*65536 convertido a entero truncado por585f5c.
static var _cosine: PackedInt32Array = []

static func cos_fx(angle: int) -> int:
	if _cosine.is_empty():
		_cosine.resize(512)
		for i in 512: _cosine[i] = int(cos(i * PI / 256.0) * 65536.0)
	return _cosine[angle & 511]

static func sin_fx(angle: int) -> int:
	return cos_fx(angle - 128)

static func trunc_div(value: int, divisor: int) -> int:
	return int(value / divisor)

static func interpolate(a: Vector2, b: Vector2, weight: int, denominator: int = 256) -> Vector2:
	return Vector2(int(a.x) + trunc_div((int(b.x) - int(a.x)) * weight, denominator), int(a.y) + trunc_div((int(b.y) - int(a.y)) * weight, denominator))

static func interpolate_fx(a: Vector2, b: Vector2, weight: int) -> Vector2:
	# 410030 usa SAR16, incluso en desplazamientos negativos.
	return Vector2(int(a.x) + ((int(b.x - a.x) * weight) >> 16), int(a.y) + ((int(b.y - a.y) * weight) >> 16))
