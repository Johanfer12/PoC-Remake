extends RefCounted
## 4471b0 -> CRT5860f0/586080: comparacion sin desempate añadido.
static func sort_records(items: Array, key: Callable, first := 0, last := -1) -> void:
	if last < 0: last = items.size() - 1
	if last <= first: return
	var lo := first
	var hi := last
	var stack: Array[Vector2i] = []
	while true:
		if hi - lo + 1 <= 8:
			while hi > lo:
				var largest := lo
				for i in range(lo + 1, hi + 1):
					if key.call(items[i]) > key.call(items[largest]): largest = i
				_swap(items, largest, hi)
				hi -= 1
		else:
			var mid := lo + ((hi - lo + 1) >> 1)
			if key.call(items[lo]) > key.call(items[mid]): _swap(items, lo, mid)
			if key.call(items[lo]) > key.call(items[hi]): _swap(items, lo, hi)
			if key.call(items[mid]) > key.call(items[hi]): _swap(items, mid, hi)
			var left := lo
			var right := hi
			while true:
				if left < mid:
					left += 1
					while left < mid and key.call(items[left]) <= key.call(items[mid]): left += 1
					if left >= mid:
						left += 1
						while left <= hi and key.call(items[left]) <= key.call(items[mid]): left += 1
				else:
					left += 1
					while left <= hi and key.call(items[left]) <= key.call(items[mid]): left += 1
				right -= 1
				while right > mid and key.call(items[right]) > key.call(items[mid]): right -= 1
				if left > right: break
				_swap(items, left, right)
				if mid == right: mid = left
			right += 1
			if mid < right:
				right -= 1
				while right > mid and key.call(items[right]) == key.call(items[mid]): right -= 1
				if right <= mid:
					right -= 1
					while right > lo and key.call(items[right]) == key.call(items[mid]): right -= 1
			else:
				right -= 1
				while right > lo and key.call(items[right]) == key.call(items[mid]): right -= 1
			if right - lo >= hi - left:
				if lo < right: stack.append(Vector2i(lo, right))
				lo = left
			else:
				if left < hi: stack.append(Vector2i(left, hi))
				hi = right
			if lo < hi: continue
		if stack.is_empty(): return
		var pending: Vector2i = stack.pop_back()
		lo = pending.x
		hi = pending.y

static func _swap(items: Array, a: int, b: int) -> void:
	if a == b: return
	var temporary: Variant = items[a]
	items[a] = items[b]
	items[b] = temporary

## Joey CRT5c3ee9: pivote central intercambiado con primero, sin mediana de tres.
static func sort_joey(items: Array, key: Callable, first := 0, last := -1) -> void:
	if last < 0: last = items.size() - 1
	if last <= first: return
	var stack: Array[Vector2i] = [Vector2i(first, last)]
	while not stack.is_empty():
		var bounds: Vector2i = stack.pop_back()
		var lo := bounds.x
		var hi := bounds.y
		if hi - lo + 1 <= 8:
			while hi > lo:
				var largest := lo
				for i in range(lo + 1, hi + 1):
					if key.call(items[i]) > key.call(items[largest]): largest = i
				_swap(items, largest, hi)
				hi -= 1
			continue
		_swap(items, lo + ((hi - lo + 1) >> 1), lo)
		var left := lo
		var right := hi + 1
		while true:
			left += 1
			while left <= hi and key.call(items[left]) <= key.call(items[lo]): left += 1
			right -= 1
			while right > lo and key.call(items[right]) >= key.call(items[lo]): right -= 1
			if left > right: break
			_swap(items, left, right)
		_swap(items, lo, right)
		if lo + 1 < right: stack.append(Vector2i(lo, right - 1))
		if left < hi: stack.append(Vector2i(left, hi))
