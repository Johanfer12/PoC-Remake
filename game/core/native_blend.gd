class_name NativeBlend
extends RefCounted
## Dibujo entre ticks nativos (NativeClock). Cada valor que una escena calcula en un tick (una
## posicion, un alfa, un tamano) se dibuja mezclado desde el que tenia en el tick anterior, con
## un tick de retraso, como la interpolacion fisica de Godot y la de la presentacion del duelo.
## La logica sigue a NativeClock.HZ y los valores de cada tick no cambian: solo se suaviza lo
## que se ve entre dos ticks. Lo discreto (fotogramas, texturas, textos) no se mezcla.
##
## Uso: tick() en cada tick de la escena, `fraction` = lo que queda en su reloj y, al dibujar,
## at(clave, valor del tick actual). La clave nombra lo que se mueve; un valor que no se pidio
## en el tick anterior (aparece, cambia de pieza o salta) se dibuja tal cual.

const PRUNE_TICKS := 64

## Avance hacia el tick siguiente, de 0 a 1. Hasta que quien lo avanza lo indique (al empezar y
## tras cada tick()) vale 1: se dibuja el tick actual. Si vuelve a empezar sin que haya habido
## tick() (quien lo avanza se ha detenido pero su reloj sigue), se dibuja el ultimo tick.
var fraction := 1.0:
	set(value):
		value = clampf(value, 0.0, 1.0)
		if value < fraction and not _ticked:
			_stalled = true
		_ticked = false
		fraction = value
var _tick := 0
var _ticked := false
var _stalled := false
var _values := {}   # clave -> [tick, valor anterior, valor actual]
## Propiedades de nodos mezcladas con nodes(): nodo -> {propiedad: valor del tick}.
var _held := {}


func tick() -> void:
	_tick += 1
	fraction = 1.0
	_ticked = true
	_stalled = false
	if _tick % PRUNE_TICKS == 0:
		for key in _values.keys():
			if int(_values[key][0]) < _tick - 2:
				_values.erase(key)


## Valor que se dibuja: el del tick anterior mezclado hacia `value` (Vector2, float, int, Color
## o Rect2) del tick actual.
func at(key: Variant, value: Variant) -> Variant:
	var entry: Array = _values.get(key, [])
	if entry.is_empty():
		_values[key] = [_tick, value, value]
		return value
	if entry[0] != _tick:
		entry[1] = entry[2] if entry[0] == _tick - 1 and typeof(entry[2]) == typeof(value) else value
		entry[0] = _tick
	entry[2] = value
	if not NativeClock.interpolate or _stalled or fraction >= 1.0 or entry[1] == value:
		return value
	return mix(entry[1], value, fraction)


## Angulo en radianes: mezcla por el camino corto.
func angle(key: Variant, value: float) -> float:
	at(key, value)
	if not NativeClock.interpolate or _stalled or fraction >= 1.0:
		return value
	return lerp_angle(_values[key][1], value, fraction)


## El valor `key` salta: en este tick se dibuja sin mezclar.
func cut(key: Variant) -> void:
	_values.erase(key)


## Otra clave pasa a nombrar lo mismo (p. ej. una carta que cambia de hueco en la mano).
func rename(mapping: Dictionary) -> void:
	var moved := {}
	for old in mapping:
		if _values.has(old):
			moved[mapping[old]] = _values[old]
			_values.erase(old)
	_values.merge(moved, true)


## Nodos que la escena coloca en cada tick: guarda posicion, escala, giro y color del tick y
## los muestra mezclados. restore() debe ir antes de los ticks para que la logica lea y escriba
## sus propios valores, no los mezclados. Una textura distinta cuenta como otra pieza.
const NODE_PROPERTIES := ["position", "scale", "rotation", "modulate"]

func nodes(list: Array) -> void:
	restore()
	for node: CanvasItem in list:
		if node == null or not node.is_visible_in_tree():
			continue
		var held := {}
		var texture: Variant = node.get("texture")
		var id := "%d:%d" % [node.get_instance_id(), texture.get_rid().get_id() if texture is Texture2D else 0]
		for property in NODE_PROPERTIES:
			var value: Variant = node.get(property)
			var shown: Variant = angle([id, property], value) if property == "rotation" else at([id, property], value)
			node.set(property, shown)
			held[property] = [value, node.get(property)]
		_held[node] = held


## Vuelve a los valores del tick, salvo en lo que se haya escrito despues de mezclar (p. ej. la
## entrada cambia de menu entre dos fotogramas).
func restore() -> void:
	for node in _held:
		if is_instance_valid(node):
			for property in _held[node]:
				var pair: Array = _held[node][property]
				if node.get(property) == pair[1]:
					node.set(property, pair[0])
	_held.clear()


## Para lo que se rehace en cada tick sin identidad propia (sprites de la presentacion del
## duelo, ordenes de dibujo del janken): cada elemento es [algo, pieza, posicion Vector2, ...].
## Devuelve parejas [indice anterior, indice actual] de la misma pieza; cada elemento se usa una
## vez. Primero los que siguen en el mismo sitio, despues los mas cercanos: el orden cambia
## cuando algo aparece o desaparece, y emparejar por orden deslizaria una pieza hasta el sitio
## de otra. Grupos grandes de una misma pieza que se mueven a la vez (tiras de los retratos) se
## emparejan por orden.
const PAIR_SEARCH_LIMIT := 32

static func pairs(prev: Array, cur: Array) -> Array:
	var out := []
	var still := {}
	for i in prev.size():
		var key := [prev[i][1], prev[i][2]]
		if not still.has(key): still[key] = []
		still[key].append(i)
	var left_prev := {}
	var left_cur := {}
	for j in cur.size():
		var list: Array = still.get([cur[j][1], cur[j][2]], [])
		if list.is_empty():
			if not left_cur.has(cur[j][1]): left_cur[cur[j][1]] = []
			left_cur[cur[j][1]].append(j)
		else:
			out.append([list.pop_front(), j])
	for key in still:
		for i in still[key]:
			if not left_prev.has(key[0]): left_prev[key[0]] = []
			left_prev[key[0]].append(i)
	for piece in left_cur:
		var olds: Array = left_prev.get(piece, [])
		var news: Array = left_cur[piece]
		if olds.is_empty(): continue
		olds.sort()
		if olds.size() > PAIR_SEARCH_LIMIT or news.size() > PAIR_SEARCH_LIMIT:
			for k in mini(olds.size(), news.size()): out.append([olds[k], news[k]])
			continue
		var candidates := []
		for j in news:
			for i in olds:
				candidates.append([(prev[i][2] as Vector2).distance_squared_to(cur[j][2]), i, j])
		candidates.sort_custom(func(x: Array, y: Array) -> bool:
			return x[0] < y[0] or (x[0] == y[0] and (x[2] < y[2] or (x[2] == y[2] and x[1] < y[1]))))
		var used := {}
		for c in candidates:
			if used.has("p%d" % c[1]) or used.has("c%d" % c[2]): continue
			used["p%d" % c[1]] = true
			used["c%d" % c[2]] = true
			out.append([c[1], c[2]])
	return out


static func mix(a: Variant, b: Variant, t: float) -> Variant:
	match typeof(b):
		TYPE_INT, TYPE_FLOAT:
			return lerpf(a, b, t)
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return Vector2(a).lerp(Vector2(b), t)
		TYPE_COLOR:
			return (a as Color).lerp(b, t)
		TYPE_RECT2, TYPE_RECT2I:
			var r0 := Rect2(a)
			var r1 := Rect2(b)
			return Rect2(r0.position.lerp(r1.position, t), r0.size.lerp(r1.size, t))
	return b
