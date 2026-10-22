class_name JoeyPortZP
extends JoeyPortZO
## E: resolución nativa de cartas. Los retornos definidos son AX/AL.

func _zp_owner(ctx: int) -> int:
	return m.u8(ctx + 2) & 1

func f4025b0(attribute: int) -> int:
	return 0x5f23d4 if attribute == 0 else f402560(attribute + 0x212)

func _zp_source(ctx: int) -> int:
	return JoeyMem.zone(_zp_owner(ctx), (m.u16(ctx + 2) >> 1) & 31)

func _zp_live(ctx: int) -> bool:
	return (m.u8(ctx + 4) & 4) == 0

func _zp_target(ctx: int, slot: int = 0) -> int:
	var out := m.local(4)
	return m.u32(out) if f583470(ctx, slot, out) != 0 else -1

func _zp_ref(ctx: int) -> int:
	var b := m.u8(ctx + 2)
	return ((b >> 1) << 8 | b) & 0x1f01

func f583f40(ctx: int) -> int:
	var p := ((m.u16(ctx + 2) >> 14) ^ m.u16(ctx + 2)) & 1
	var card := f4022e0(m.u16(ctx)) & 0xffff
	var wanted := {0x51: 0x2e5, 0x186: 0x187, 0x28b: 0x170}.get(card, ctx) as int
	if not _zp_live(ctx): return 0
	match m.u8(0xa55c8a):
		126: f5b9170((p << 15) | 0x60, 0, 0, 0)
		127:
			f568fa0(p, f402460(wanted), 0xa55c90)
			f5adb10(p, 0xa55c90, 1, 1, 13, p)
			return 126
		128:
			if f569300(p, wanted) != 0 and f570b40(p) != 0:
				return 127 if f56a000(p) != 0 else 0
	return 0

func f584040(ctx: int) -> int:
	var source := _zp_source(ctx)
	if not _zp_live(ctx) or (m.u16(source) & 0xfff) != m.u16(ctx) or (m.u8(source + 6) & 2) == 0: return 0
	f5b9170((m.u16(ctx + 2) << 15) | 0x94, (m.u8(ctx + 2) >> 1) & 31, 0, 0)
	for p in range(2):
		for z in range(5):
			var at := JoeyMem.zone(p, z)
			if (m.u32(at) & 0xfff) != 0 and (m.u8(at + 6) & 2) != 0 and (f56f6d0(p, z) & 0xffff) == 2:
				f5747e0(_zp_owner(ctx), _zp_ref(ctx), (z << 8) | p, 6)
	return 0

func f584160(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var t := _zp_target(ctx)
	if t < 0: return 0
	var p := t & 255
	var z := (t >> 8) & 255
	var at := JoeyMem.zone(p & 1, z)
	var index := m.u16(at) & 0xfff
	if index == 0: return 0
	if (m.u8(at + 6) & 2) == 0:
		f575160(p, z, 1)
		f578430(p, index)
		f5b9170((int(p != 0) << 15) | 0xf1, 15, 0, 0)
		if (f4025d0(index) & 0xffff) == 21 and (m.u8(ctx + 4) & 16) == 0:
			f577880(ctx, p, z)
		else: f575160(p, z, 0)
	elif (f4025d0(index) & 0xffff) == 21:
		f577880(ctx, p, z)
	return 0

func f584270(ctx: int) -> int:
	if _zp_live(ctx) and (m.u16(ctx + 4) & 0xe000) == 0x4000:
		var entry := m.u32(ctx + 6)
		var out := m.local(4)
		m.set_u32(out, entry)
		if _s32(f568ad0(_zp_owner(ctx), ((entry >> 12) & 1) + ((entry >> 24) & 127) * 2)) >= 0:
			f575d50(ctx, _zp_owner(ctx), out)
	return 0

func f5842e0(ctx: int) -> int:
	if (f4022e0(m.u16(ctx)) & 0xffff) != 0x415 or (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx):
		if (m.u16(ctx + 2) & 0x3000) == 0x1000: f5bce50(1 - _zp_owner(ctx), 1, 1)
	return 0

func f584360(ctx: int) -> int:
	if _zp_live(ctx): f5b9170((m.u16(ctx + 2) << 15) | 0x60, 0, 0, 0)
	return 0

func f584390(ctx: int) -> int:
	var p := _zp_owner(ctx)
	match m.u8(0xa55c8a):
		126: f5792a0(p)
		127:
			f40c940(p, 11, 0xaa, 0)
			return 126
		128:
			if m.u8(JoeyMem.pl(p) + 9) != 0 and ((m.u32(0xa54e5c) >> (1 + p)) & 1) == 0:
				f5bf800(0xf5)
				f5bf9a0(0, 0)
				return 127
	return 0

func f584440(ctx: int) -> int:
	match m.u8(0xa55c8a):
		126: f5b9170((m.u16(ctx + 2) << 15) | 0x60, 1, 0, 0)
		127:
			f5b9170((m.u16(ctx + 2) << 15) | 0xd6, 1, 0, 0)
			return 126
		128: return 127
	return 0

func f5844a0(ctx: int) -> int:
	f578b60(_zp_owner(ctx), 1)
	return 0

func f5844c0(ctx: int) -> int:
	f5747e0(_zp_owner(ctx), m.u16(ctx), _zp_ref(ctx), 12)
	return 0

func f584610(ctx: int, _unused: int) -> int:
	if (m.u16(ctx + 2) & 0x3000) != 0x2000: return f584500(ctx)
	f575900(_zp_owner(ctx), (m.u16(ctx + 4) & 0x1fe0) >> 5, 1)
	return 0

func f584660(ctx: int, _unused: int) -> int:
	if (m.u16(ctx + 2) & 0x3000) != 0x2000: return f584500(ctx)
	f5784e0(1 - _zp_owner(ctx), 500)
	return 0

func f584930(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var t := _zp_target(ctx)
	if t < 0: return 0
	var p := t & 255
	var z := (t >> 8) & 255
	if f583510(ctx, p, z) != 0:
		var flags := m.u16(JoeyMem.zone(p & 1, z) + 6)
		if (flags & 1) != 0: f5751e0(ctx, p, z, int((flags & 2) == 0), 1)
	return 0

func f5849d0(ctx: int) -> int:
	if not _zp_live(ctx) or (m.u16(_zp_source(ctx)) & 0xfff) != m.u16(ctx): return 0
	for p in range(2):
		for z in range(5):
			var at := JoeyMem.zone(p, z)
			if (m.u16(at + 6) & 3) == 2 and (m.u32(at) & 0xfff) != 0 and (f56f6d0(p, z) & 0xffff) == 1:
				f5751e0(ctx, p, z, 0, 0)
	return 0

func f584c80(ctx: int) -> int:
	if not _zp_live(ctx) or m.u8(0xa55c8a) != 128: return 0
	f576940(ctx, 0x1f001f)
	return 127

func f584cb0(ctx: int) -> int:
	if not _zp_live(ctx) or m.u8(0xa55c8a) != 128: return 0
	f576940(ctx, 0x1f << (16 - _zp_owner(ctx) * 16))
	return 127

func f584d00(ctx: int) -> int:
	if _zp_live(ctx):
		var card := f4022e0(m.u16(ctx)) & 0xffff
		var amount := {0x151: 200, 0x152: 500, 0x153: 600, 0x154: 800, 0x155: 1000, 0x3ee: 400}.get(card, 0) as int
		f5787f0(m.u8(ctx + 6) & 1, amount)
	return 0

func f584de0(ctx: int) -> int:
	if _zp_live(ctx):
		var card := f4022e0(m.u16(ctx)) & 0xffff
		if card == 0x523:
			f5787f0(_zp_owner(ctx), 1000)
			f5787f0(1 - _zp_owner(ctx), 1000)
		elif card == 0x5a2: f5787f0(_zp_owner(ctx), 1000)
	return 0

func f585130(ctx: int) -> int:
	if _zp_live(ctx):
		f5784e0(1 - _zp_owner(ctx), 1000)
		f5784e0(_zp_owner(ctx), 500)
	return 0

func _zp_reveal(ctx: int) -> void:
	var p := 1 - _zp_owner(ctx)
	for z in range(5):
		var at := JoeyMem.zone(p, z)
		if (m.u32(at) & 0xfff) != 0 and (m.u8(at + 6) & 2) == 0: f574f40(ctx, p, z, 1)

func f585170(ctx: int) -> int:
	if not _zp_live(ctx) or m.u8(0xa55c8a) != 128: return 0
	_zp_reveal(ctx)
	return 127

func f585200(ctx: int) -> int:
	if (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx):
		var t := _zp_target(ctx)
		if t >= 0: f5747e0(_zp_owner(ctx), _zp_ref(ctx), t, 6 if (f4022e0(m.u16(ctx)) & 0xffff) == 0x4dc else 2)
	return 0

func f5852a0(ctx: int) -> int:
	if _zp_live(ctx): _zp_reveal(ctx)
	return 0

func f585310(ctx: int) -> int:
	f5b9170((m.u16(ctx + 2) << 15) | 0x94, (m.u8(ctx + 2) >> 1) & 31, 0, 0)
	f5b9170((m.u16(ctx + 2) << 15) | 0x3a, 0, 0, 0)
	return 0

func f585350(ctx: int) -> int:
	var out := m.local(4)
	if f56cac0(_zp_owner(ctx), 0x3eb, out) != 0 or f56cac0(_zp_owner(ctx), 0x40a, out) != 0:
		f575d50(ctx, _zp_owner(ctx), out)
	return 0

func f5853b0(ctx: int) -> int:
	if _zp_live(ctx):
		var mask := 0
		for slot in range(2):
			var t := _zp_target(ctx, slot)
			if t >= 0 and f57a630(ctx, t) != 0: mask |= 1 << (((t >> 8) + (t << 4)) & 31)
		f576940(ctx, mask)
	return 0

func f585970(ctx: int) -> int:
	if _zp_live(ctx):
		if (m.u16(ctx + 2) & 0x3000) != 0x2000: f5787f0(_zp_owner(ctx), 3000)
		else: f5784a0(_zp_owner(ctx), 5000)
	return 0

func f5859c0(ctx: int) -> int:
	f578b60(_zp_owner(ctx), 2)
	return 0

func f585ae0(ctx: int) -> int:
	f575900(_zp_owner(ctx), (m.u16(ctx + 4) & 0x1fe0) >> 5, 1)
	return 0

func f585d30(ctx: int) -> int:
	f578b60(1 - _zp_owner(ctx), 2)
	return 0

func f585d50(ctx: int) -> int:
	if _zp_live(ctx):
		var t := _zp_target(ctx)
		if t >= 0 and (m.u16(JoeyMem.zone(t & 1, (t >> 8) & 255)) & 0xfff) != 0:
			f577990(ctx, t & 255, (t >> 8) & 255)
	return 0

func f585e40(ctx: int) -> int:
	if _zp_live(ctx): f578bb0(1 - _zp_owner(ctx), 5, 1)
	return 0

func f586260(ctx: int) -> int:
	if _zp_live(ctx): f578860(1 - _zp_owner(ctx), 3, 1)
	return 0

func f586290(ctx: int) -> int:
	if (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx):
		f5b9170((m.u16(ctx + 2) << 15) | 0x94, (m.u8(ctx + 2) >> 1) & 31, 0, 0)
		f5747e0(_zp_owner(ctx), m.u16(ctx), _zp_ref(ctx), ((m.u8(0xa577f8) << 1) & 255) << 8 | 11)
	return 0

func f586500(ctx: int, _unused: int) -> int:
	if (m.u16(ctx + 2) & 0x3000) == 0x1000: return f583f40(ctx)
	return f584500(ctx)

func _zp_mask_phase(ctx: int, mask: int) -> int:
	if not _zp_live(ctx) or m.u8(0xa55c8a) != 128: return 0
	f576940(ctx, mask)
	return 127

func f586850(ctx: int) -> int:
	return _zp_mask_phase(ctx, 0x7e0 << (16 - _zp_owner(ctx) * 16))

func f586b10(ctx: int) -> int:
	if _zp_live(ctx): f5798f0(20, 1)
	return 0

func f588380(ctx: int) -> int:
	if _zp_live(ctx):
		var p := m.u8(ctx + 6) & 1
		f579790(p, m.u16(ctx), (int((m.u8(0xa577fa) & 1) != p) << 4) | 3)
	return 0

func f588d30(ctx: int) -> int:
	if _zp_live(ctx) and m.u8(JoeyMem.pl(1 - _zp_owner(ctx)) + 9) != 0:
		f40c940(_zp_owner(ctx), 5, f4022e0(m.u16(ctx)), 0)
	return 0

func f5897b0(ctx: int) -> int:
	if _zp_live(ctx): f579930(_zp_owner(ctx), 22, 1)
	return 0

func f5897e0(ctx: int) -> int:
	var p := 1 - _zp_owner(ctx)
	if _zp_live(ctx) and f56a290(p, 0xffffffff) != 0: f5bcf00(p, 0xffff, 1)
	return 0

func f589830(ctx: int) -> int:
	return _zp_mask_phase(ctx, 0x7e007e0)

func f589920(ctx: int) -> int:
	if not _zp_live(ctx) or m.u8(0xa55c8a) != 128: return 0
	f578b60(_zp_owner(ctx), 1)
	f5787f0(1 - _zp_owner(ctx), 1000)
	return 127

func f589970(ctx: int) -> int:
	return _zp_mask_phase(ctx, 0x7ff07ff)

func f589e60(ctx: int) -> int:
	if not _zp_live(ctx) or m.u8(0xa55c8a) != 128: return 0
	var position := ((m.u16(ctx + 2) >> 1) & 31) + _zp_owner(ctx) * 16
	f577a40(ctx, (1 << (position & 31)) ^ 0x7e007e0)
	return 127

func f58a140(ctx: int) -> int:
	if _zp_live(ctx): f579930(1 - _zp_owner(ctx), 1, 1)
	return 0

func f58a200(ctx: int) -> int:
	if _zp_live(ctx):
		var count := f569d50(1) + f569d50(0)
		if _s32(count) > 0: f5787f0(_zp_owner(ctx), count * 300)
	return 0

func f58a250(ctx: int) -> int:
	if _zp_live(ctx) and (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx):
		f579990(_zp_owner(ctx), (m.u16(ctx + 2) >> 1) & 31, 1, 0)
		f5b9170(((m.u16(ctx + 2) << 15) & 0xffff) | 0xf1, 60, 0, 0)
	return 0

func f58a660(ctx: int) -> int:
	if _zp_live(ctx): f579930(_zp_owner(ctx), 2, 1)
	return 0

func f58afe0(ctx: int) -> int:
	if _zp_live(ctx):
		f5747e0(_zp_owner(ctx), m.u16(ctx), _zp_ref(ctx), 12)
		f5b9170((m.u16(ctx + 2) << 15) | 0x94, (m.u8(ctx + 2) >> 1) & 31, 0, 0)
	return 0

func f58b3d0(ctx: int, _arg: int) -> int:
	if (m.u16(ctx + 2) & 0x3000) == 0x2000: return f58b400(ctx)
	return 0

func f58b930(ctx: int) -> int:
	if _zp_live(ctx) and (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx) and (m.u16(ctx + 2) & 0x3000) == 0x1000:
		f578b60(_zp_owner(ctx), 2)
	return 0

func f58c430(ctx: int) -> int:
	if _zp_live(ctx) and (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx): f59d370(_zp_owner(ctx), (m.u16(ctx + 2) >> 1) & 31)
	return 0

func f58cf50(ctx: int) -> int:
	if _zp_live(ctx):
		f5b9170((int(m.u8(ctx + 16) != 0) << 15) | 0x35, m.u8(ctx + 17), 1, 0)
		f5b9170(((m.u16(ctx + 2) << 15) & 0xffff) | 0x37, 0, 0, 0)
	return 0

func f58cfa0(ctx: int) -> int:
	f5b9170(((m.u16(ctx + 2) << 15) & 0xffff) | 0x37, 1, 0, 0)
	return 0

func f58d590(ctx: int) -> int:
	if _zp_live(ctx):
		var ref := m.u16(ctx + 16)
		f5b9170(((ref & 0xff01) << 7) | 0xb1, (ref & 0x1e00) >> 9, 1, 0)
		f5778b0(ctx, (ref >> 8) & 1, (ref >> 9) & 15)
	return 0

func f58d5e0(ctx: int) -> int:
	var ref := m.u16(0xa57844 + (m.u8(0xa577fa) & 1) * 16)
	if (ref & 16) == 0:
		var entry := m.u32(JoeyMem.zone(ref & 1, (ref >> 1) & 7))
		if ((entry >> 12) & 1) + ((entry >> 24) & 127) * 2 == (ref >> 8): f577990(ctx, ref & 1, (ref >> 1) & 7)
	return 0

func f58d930(ctx: int) -> int:
	if _zp_live(ctx): f5787f0(_zp_owner(ctx), m.u16(ctx + 16))
	return 0

func f58e830(ctx: int, out: int) -> int:
	if _zp_live(ctx): m.set_u16(out + 6, int(m.u16(out + 6) == 0))
	return 0

func f58ecd0(ctx: int) -> int:
	if _zp_live(ctx):
		f577a60(ctx, _zp_owner(ctx), (m.u16(ctx + 2) >> 1) & 31)
		f5b9170(((m.u16(ctx + 2) << 15) & 0xffff) | 0x60, 1, 0, 0)
	return 0

func f58ee30(ctx: int) -> int:
	if _zp_live(ctx) and (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx): f576940(ctx, 0x4000400)
	return 0

func f58ee90(ctx: int) -> int:
	if _zp_live(ctx):
		var flags := (((m.u8(0xa577f8) + 2) * 2 + _zp_owner(ctx)) & 255) << 8 | 13
		for p in range(2): f579790(p, m.u16(ctx), flags)
	return 0

func f58f5d0(ctx: int) -> int:
	if _zp_live(ctx) and (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx) and m.u16(ctx + 6) != 0:
		f5784e0(1 - _zp_owner(ctx), 500)
	return 0

func f58f7e0(ctx: int) -> int:
	if f583470(ctx, 0, 0) != 0:
		var target := f583440(ctx, 0)
		f5751e0(ctx, target & 255, (target >> 8) & 255, 0, 0)
	return 0

func f584a90(ctx: int) -> int:
	var p := _zp_owner(ctx)
	var other := JoeyMem.zone(1 - p, 10)
	var other_index := m.u16(other) & 0xfff
	if (m.u16(_zp_source(ctx)) & 0xfff) != m.u16(ctx): return 0
	if other_index != 0 and (m.u8(other + 6) & 2) != 0: f577880(ctx, 1 - p, 10)
	for q in range(2):
		for z in range(5):
			var at := JoeyMem.zone(q, z)
			if (m.u32(at) & 0xfff) != 0 and (m.u8(at + 6) & 2) != 0: f5747e0(p, _zp_ref(ctx), (z << 8) | q, 8)
	if m.u16(ctx) != other_index:
		f5b9170(((m.u16(ctx + 2) << 15) & 0xffff) | 0x11, f569660(f4022e0(m.u16(ctx))), 1, 0)
		if (f4022e0(other_index) & 0xffff) == 0x14d:
			var mask := 0
			for q in range(2):
				for z in range(5, 11):
					var at := JoeyMem.zone(q, z)
					if (f4022e0(m.u16(at) & 0xfff) & 0xffff) == 0x58f and (m.u8(at + 6) & 2) != 0 and (m.u8(at + 140) & 32) == 0:
						mask |= 1 << ((q * 16 + z) & 31)
			f576940(ctx, mask)
	return 0

func f584e60(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var p := 1 - _zp_owner(ctx)
	var card := f4022e0(m.u16(ctx)) & 0xffff
	var amount := 0
	match card:
		0x156, 0x157, 0x158, 0x159, 0x3ef:
			p = m.u8(ctx + 6) & 1
			amount = {0x156: 200, 0x157: 500, 0x158: 600, 0x159: 800, 0x3ef: 300}[card]
		0x58: amount = m.u16(ctx + 6)
		0x109: amount = f56a320(p, 0, 0, 1) * 500
		0x1e9, 0x215: amount = 1000
		0x1ff: amount = 500
		0x408: amount = f569d50(p) * 500
		0x40f:
			p = m.u8(ctx + 6) & 1
			amount = m.u8(JoeyMem.pl(p) + 8) * 200
		0x52c:
			if (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx) and m.u16(ctx + 6) != 0: amount = 500
			else: return 0
		0x598: amount = 1200
		0x59b, 0x59c: amount = 800
	f5784e0(p, amount)
	return 0

func f5859e0(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var target := _zp_target(ctx)
	if target < 0: return 0
	var p := target & 255
	var z := (target >> 8) & 255
	var at := JoeyMem.zone(p & 1, z)
	var index := m.u16(at) & 0xfff
	if index == 0: return 0
	if (m.u8(at + 6) & 2) == 0:
		f575160(p, z, 1)
		f578430(p, index)
		f5b9170((int(p != 0) << 15) | 0xf1, 15, 0, 0)
		if (f4025d0(index) & 0xffff) != 21: f577880(ctx, p, z)
		else: f575160(p, z, 0)
	elif (f4025d0(index) & 0xffff) != 21: f577880(ctx, p, z)
	return 0

func f585540(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var p := _zp_owner(ctx)
	var stage := m.u8(0xa55c8a)
	if stage == 127:
		var toss := f5bddb0(2)
		f5b9170((m.u16(ctx + 2) << 15) | 0xe0, m.u16(0xa558b4), toss, (m.u8(ctx + 2) >> 1) & 31)
		f5747e0(p, m.u16(ctx), _zp_ref(ctx), (int(toss == m.u16(0xa558b4)) << 8) | 12)
		return 10
	if stage != 128:
		f5b9170((m.u16(ctx + 2) << 15) | 0x94, (m.u8(ctx + 2) >> 1) & 31, 0, 0)
		return 0
	if ((m.u32(0xa54e5c) >> (p + 1)) & 1) != 0: m.set_u16(0xa558b4, f5bddb0(2))
	else:
		f5bf800(0x38)
		f5bf9a0(7, 0)
	return 127

func f585b10(ctx: int) -> int:
	var p := _zp_owner(ctx)
	if not _zp_live(ctx) or ((m.u32(0xa54e5c) >> (p + 1)) & 1) != 0: return 0
	match m.u8(0xa55c8a):
		126:
			if m.u16(0xa558b4) == 0: return 0
			if (m.u32(0xa54e54) & 0x102) != 0: return 128
			if f5aa440(1) != 0 and f5aa480() != 0:
				f5758a0(p, m.u32(0xa5504c), 0)
				return 128
		128:
			if m.u8(JoeyMem.pl(p) + 8) == 0: return 0
			f5bf800(0x1e)
			f5bf9a0(1, 0)
		_: return 0
	return 126

func f585bf0(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var t := _zp_target(ctx)
	if t >= 0:
		var at := JoeyMem.zone(t & 1, (t >> 8) & 255)
		if (m.u32(at) & 0xfff) != 0 and (m.u8(at + 6) & 2) != 0 and (f56f6d0(t & 255, (t >> 8) & 255) & 0xffff) == 1:
			f577880(ctx, t & 255, (t >> 8) & 255)
	return 0

func f585c80(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var t := _zp_target(ctx)
	if t < 0 or (m.u16(JoeyMem.zone(t & 1, (t >> 8) & 255)) & 0xfff) == 0: return 0
	var card := f4022e0(m.u16(ctx)) & 0xffff
	if card in [0x3ff, 0x4bb] and f583510(ctx, t & 255, (t >> 8) & 255) == 0: return 0
	f577880(ctx, t & 255, (t >> 8) & 255)
	return 0

func f585e70(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var t := _zp_target(ctx)
	if t < 0: return 0
	var p := t & 255
	var z := (t >> 8) & 255
	var at := JoeyMem.zone(p & 1, z)
	var index := m.u16(at) & 0xfff
	if index != 0 and p != _zp_owner(ctx) and (m.u8(at + 6) & 2) == 0:
		f575160(p, z, 1)
		f578430(p, index)
		f5b9170((int(p != 0) << 15) | 0xf1, 15, 0, 0)
		f575160(p, z, 0)
		f5b9170((m.u16(ctx + 2) << 15) | 0x94, (m.u8(ctx + 2) >> 1) & 31, 0, 0)
	return 0

func f585f50(ctx: int) -> int:
	var p := _zp_owner(ctx)
	var mask := 0
	for z in range(5, 10):
		var at := JoeyMem.zone(1 - p, z)
		if (m.u8(at + 6) & 2) != 0 and (f4022e0(m.u16(at) & 0xfff) & 0xffff) == 0x15b:
			mask |= 1 << ((z + 16 - p * 16) & 31)
	f576940(ctx, mask)
	if mask != 0:
		var mode := (m.u8(0xa577fa) ^ p) & 1
		if mode == 0 and (m.u8(0xa577fa) & 14) == 8: mode = 2
		f579790(p, m.u16(ctx), (mode << 4) | 3)
	return 0

func f586040(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var mask := 0
	for slot in range(m.u16(ctx + 4) >> 13):
		var t := _zp_target(ctx, slot)
		if t >= 0 and f59dc50(ctx, t & 255, (t >> 8) & 255) != 0:
			mask |= 1 << (((t >> 8) + (t << 4)) & 31)
	f576940(ctx, mask)
	return 0

func f5860e0(ctx: int) -> int:
	if not _zp_live(ctx): return 0
	var p := _zp_owner(ctx)
	match m.u8(0xa55c8a):
		125:
			f578b60(1 - p, 5)
			f579890()
			return 124
		126:
			f579810()
			f578b60(p, 5)
			return 125
		127:
			if m.u8(JoeyMem.pl(1 - p) + 8) == 0: return 126
			f575970(1 - p, 0, 1)
			return 127
		128:
			if m.u8(JoeyMem.pl(p) + 8) != 0:
				f575970(p, 0, 0)
				return 128
			return 127
	return 0

func f5861f0(ctx: int) -> int:
	if _zp_live(ctx):
		var mask := 0
		for slot in range(mini(2, m.u16(ctx + 4) >> 13)):
			var t := _zp_target(ctx, slot)
			if t >= 0: mask |= 1 << (((t >> 8) + (t << 4)) & 31)
		f577a40(ctx, mask)
	return 0

func f58cdf0(ctx: int) -> int:
	var p := _zp_owner(ctx)
	var free := f56a400(p)
	if _s32(free) < 0:
		f577840(p, (m.u16(ctx + 2) >> 1) & 31, 0, m.u16(ctx))
	else:
		var dst := ((free & 255) << 8) | ((m.u8(0xa57840) >> 1) & 1)
		f575750(p, _zp_ref(ctx), dst)
		f574990(p, dst, m.u16(0xa57840) & 0x701)
	f5b9170(0x39, 0, 0, 0)
	return 0

func f58dbd0(ctx: int) -> int:
	var phase := m.u8(0xa55c8a)
	if phase == 127: f5bd030(1)
	elif phase == 128 and _zp_live(ctx) and (m.u16(_zp_source(ctx)) & 0xfff) == m.u16(ctx):
		if (m.u32(0xa577ec) & 3) == 2 and f583470(ctx, 0, 0) != 0:
			var target := f583440(ctx, 0)
			if f57c100(ctx, target) != 0:
				f5b9170((int(m.u8(ctx + 16) != 0) << 15) | 0x33, m.u8(ctx + 17), (target >> 8) & 255, (target & 255) + 1)
				return 127
	return 0


func _zp_signed(value: int, bits: int) -> int:
	var sign_bit: int = 1 << (bits - 1)
	return ((value & ((1 << bits) - 1)) ^ sign_bit) - sign_bit


func f5846b0(param_1: int, param_2: int) -> int:
	var sVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var puVar5: int = 0
	var iVar6: int = 0
	var _pc: int = 61
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((1) & 0xffffffff)
			3:
				var _v0: int = f5bf800(0x15)
				_pc = 2
			4:
				_pc = 3 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 1
			5:
				return ((0x7e) & 0xffffffff)
			6:
				var _v1: int = f5af5a0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(param_1), 0)
				_pc = 5
			7:
				_pc = 13 if (int(_zp_signed(iVar6, 32) < _zp_signed(iVar3, 32))) != 0 else 6
			8:
				puVar5 = (((puVar5 + (2) * 2)) & 0xffffffff)
				_pc = 7
			9:
				iVar6 = _zp_signed(_zp_signed((_zp_signed(iVar6, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 8
			10:
				return ((0x7e) & 0xffffffff)
			11:
				var _v2: int = f40caa0(iVar6)
				_pc = 10
			12:
				_pc = 11 if (int(_zp_signed(sVar1, 32) == _zp_signed(0x3d, 32))) != 0 else 9
			13:
				var _v3: int = f4022e0(_zp_signed((_zp_signed(m.u16(puVar5), 32) & _zp_signed(0xfff, 32)), 32))
				sVar1 = _zp_signed(_v3, 16)
				_pc = 12
			14:
				puVar5 = ((0xa582a4) & 0xffffffff)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(0, 32) < _zp_signed(iVar3, 32))) != 0 else 6
			16:
				iVar6 = _zp_signed(0, 32)
				_pc = 15
			17:
				_pc = 22 if (int(_zp_signed(iVar6, 32) < _zp_signed(iVar3, 32))) != 0 else 16
			18:
				puVar5 = (((puVar5 + (2) * 2)) & 0xffffffff)
				_pc = 17
			19:
				iVar6 = _zp_signed(_zp_signed((_zp_signed(iVar6, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 18
			20:
				_pc = 11
			21:
				_pc = 20 if (int(_zp_signed(sVar1, 32) == _zp_signed(0x4e1, 32))) != 0 else 19
			22:
				var _v4: int = f4022e0(_zp_signed((_zp_signed(m.u16(puVar5), 32) & _zp_signed(0xfff, 32)), 32))
				sVar1 = _zp_signed(_v4, 16)
				_pc = 21
			23:
				puVar5 = ((0xa582a4) & 0xffffffff)
				_pc = 22
			24:
				_pc = 23 if (int(_zp_signed(0, 32) < _zp_signed(iVar3, 32))) != 0 else 16
			25:
				iVar6 = _zp_signed(0, 32)
				_pc = 24
			26:
				_pc = 32 if (int(_zp_signed(iVar6, 32) < _zp_signed(iVar3, 32))) != 0 else 25
			27:
				puVar5 = (((puVar5 + (2) * 2)) & 0xffffffff)
				_pc = 26
			28:
				iVar6 = _zp_signed(_zp_signed((_zp_signed(iVar6, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 27
			29:
				return ((0x7e) & 0xffffffff)
			30:
				var _v5: int = f40caa0(iVar6)
				_pc = 29
			31:
				_pc = 30 if (int(_zp_signed(sVar1, 32) == _zp_signed(0x3e, 32))) != 0 else 28
			32:
				var _v6: int = f4022e0(_zp_signed((_zp_signed(m.u16(puVar5), 32) & _zp_signed(0xfff, 32)), 32))
				sVar1 = _zp_signed(_v6, 16)
				_pc = 31
			33:
				puVar5 = ((0xa582a4) & 0xffffffff)
				_pc = 32
			34:
				_pc = 33 if (int(_zp_signed(0, 32) < _zp_signed(iVar3, 32))) != 0 else 25
			35:
				iVar6 = _zp_signed(0, 32)
				_pc = 34
			36:
				var _v7: int = f599e30(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), 0x13d, 0)
				iVar3 = _zp_signed(_v7, 32)
				_pc = 35
			37:
				return ((0x7f) & 0xffffffff)
			38:
				var _v8: int = f5bf800(0x19)
				_pc = 37
			39:
				_pc = 38 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 36
			40:
				_pc = 39 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 4
			41:
				var _v9: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x13d, 0)
				iVar3 = _zp_signed(_v9, 32)
				_pc = 40
			42:
				_pc = 41 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			43:
				var _v10: int = f57f640(param_1)
				iVar3 = _zp_signed(_v10, 32)
				_pc = 42
			44:
				return ((0x7e) & 0xffffffff)
			45:
				var _v11: int = f40c940(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 6, uVar2, 0)
				_pc = 44
			46:
				var _v12: int = f4022e0(m.u16(param_1))
				uVar2 = ((_v12) & 0xffff)
				_pc = 45
			47:
				return ((0x7d) & 0xffffffff)
			48:
				var _v13: int = f40cab0()
				var _v14: int = f5adb10(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _v13, 1, 1, 0xb, uVar4)
				_pc = 47
			49:
				var _v15: int = f56d100(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar4)
				uVar4 = ((_v15) & 0xffffffff)
				_pc = 48
			50:
				var _v16: int = f40cab0()
				uVar4 = ((_v16) & 0xffffffff)
				_pc = 49
			51:
				return ((0x7d) & 0xffffffff)
			52:
				var _v17: int = f40cab0()
				var _v18: int = f5adb10(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _v17, 1, 1, 0xd, _zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 51
			53:
				_pc = 52 if (int(_zp_signed(iVar3, 32) == _zp_signed(2, 32))) != 0 else 47
			54:
				_pc = 50 if (int(_zp_signed(iVar3, 32) == _zp_signed(1, 32))) != 0 else 53
			55:
				var _v19: int = f40cac0()
				iVar3 = _zp_signed(_v19, 32)
				_pc = 54
			56:
				var _v20: int = f40cab0()
				_pc = 55
			57:
				var _v21: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 1
			58:
				_pc = 57 if (int(_zp_signed(iVar3, 32) == _zp_signed(2, 32))) != 0 else 1
			59:
				var _v22: int = f40cac0()
				iVar3 = _zp_signed(_v22, 32)
				_pc = 58
			60:
				var _v23: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v23 == 0x80: _pc = 43
				if _v23 == 0x7f: _pc = 46
				if _v23 == 0x7e: _pc = 56
				if _v23 == 0x7d: _pc = 59
			61:
				_pc = 60 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f585420(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var extraout_var: int = 0
	var uVar4: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f40cab0()
				var _v1: int = f5ada20(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _v0, 1, 0, 0, 0xc, _zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 1
			3:
				return ((0x7f) & 0xffffffff)
			4:
				var _v2: int = f5bf800(0x1a)
				_pc = 3
			5:
				return ((0x7e) & 0xffffffff)
			6:
				var _v3: int = f5af5a0(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), (((_zp_signed((((((uVar4) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)), 0)
				_pc = 5
			7:
				_pc = 6 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed(uVar4, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 4
			8:
				uVar4 = ((((((((((extraout_var) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			10:
				var _v4: int = f570b40(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v4, 32)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			12:
				var _v5: int = f56a000(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v5, 32)
				_pc = 11
			13:
				_pc = 12 if (int((int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 and (int(_zp_signed(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed(0xa55d6a, 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0xd44, 32)), 32), 32)), 32), 32) + _zp_signed(1, 32)), 32)) & 0xffffffff)), 8), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			14:
				return ((0x7e) & 0xffffffff)
			15:
				var _v6: int = f40c940(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 6, uVar1, 0)
				_pc = 14
			16:
				var _v7: int = f4022e0(m.u16(param_1))
				uVar1 = ((_v7) & 0xffff)
				_pc = 15
			17:
				_pc = 16 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 13
			18:
				_pc = 2 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 17
			19:
				_pc = 18 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f585640(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var puVar3: int = 0
	var in_ECX: int = 0
	var uVar4: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f578d00(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar1, 0, 0)
				_pc = 1
			3:
				var _v1: int = f4022e0(_zp_signed((_zp_signed(m.u16(puVar3), 32) & _zp_signed(0xfff, 32)), 32))
				uVar1 = ((_v1) & 0xffff)
				_pc = 2
			4:
				var _v2: int = f40cab0()
				puVar3 = ((((_v2) & 0xffffffff)) & 0xffffffff)
				_pc = 3
			5:
				return ((0x7f) & 0xffffffff)
			6:
				var _v3: int = f5bf800(0x1b)
				_pc = 5
			7:
				return ((0x7e) & 0xffffffff)
			8:
				var _v4: int = f5af5a0(uVar2, (((_zp_signed((((((uVar4) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)), 0)
				_pc = 7
			9:
				_pc = 8 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed(uVar4, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 6
			10:
				uVar4 = ((((((((((_zp_signed((((((((in_ECX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(_zp_signed(m.u8(((((((((((((_zp_signed(0xa55d6a, 32)) & 0xffffffff) + (((((((uVar2) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 8), 32) != _zp_signed(0, 32))) != 0 else 1
			12:
				uVar2 = ((_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xffff), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			14:
				return ((0x7e) & 0xffffffff)
			15:
				var _v5: int = f40c940(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 6, uVar1, 0)
				_pc = 14
			16:
				var _v6: int = f4022e0(m.u16(param_1))
				uVar1 = ((_v6) & 0xffff)
				_pc = 15
			17:
				_pc = 16 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 13
			18:
				_pc = 4 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 17
			19:
				_pc = 18 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f585730(param_1: int) -> int:
	var _stack: int = m.local(256)
	var uVar3: int = 0
	var iVar1: int = 0
	var uVar2: int = 0
	var in_ECX: int = 0
	var extraout_var: int = 0
	var _pc: int = 30
	while true:
		match _pc:
			0:
				return _zp_signed(0, 32)
			1:
				return _zp_signed(0, 32)
			2:
				return _zp_signed((((uVar3) << 16) | ((0x7f) & 0xffff)), 32)
			3:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), (((((2) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffff))
				_pc = 2
			4:
				return _zp_signed(0x6f, 32)
			5:
				return _zp_signed((((((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) != _zp_signed(0, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x1a) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((100) & 0xffffffff))) & 0xffffffff), 32)
			6:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(((((_zp_signed((~(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)))), 32)) & 0xff)) & 0xffff), 32) ^ _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) - _zp_signed(1, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 5
			7:
				var _v0: int = f5b9170((((((((((((((extraout_var) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0x1f) & 0xffffffff))) & 0xffffffff), 0x1a8, m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xffff), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 0)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 4
			9:
				var _v1: int = f576050(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x1a8)
				iVar1 = _zp_signed(_v1, 32)
				_pc = 8
			10:
				return _zp_signed(0x7d, 32)
			11:
				var _v2: int = f5bf9a0(1, 0)
				_pc = 10
			12:
				var _v3: int = f5bf800((_stack + 0))
				_pc = 11
			13:
				var _v4: int = f5bdf40((_stack + 0), 0x1c, uVar2)
				_pc = 12
			14:
				var _v5: int = f402290(uVar2)
				uVar2 = ((_v5) & 0xffffffff)
				_pc = 13
			15:
				var _v6: int = f402460(0x1a8)
				uVar2 = ((_v6) & 0xffffffff)
				_pc = 14
			16:
				return _zp_signed(0x7d, 32)
			17:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 16
			18:
				_pc = 17 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 15
			19:
				return _zp_signed(100, 32)
			20:
				_pc = 19 if (int(_zp_signed(iVar1, 32) < _zp_signed(1, 32))) != 0 else 18
			21:
				var _v7: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar2, 0)
				iVar1 = _zp_signed(_v7, 32)
				_pc = 20
			22:
				var _v8: int = f4022e0((((uVar3) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v8) & 0xffffffff)
				_pc = 21
			23:
				return _zp_signed((((((((((((((-(((int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x1b) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((100) & 0xffffffff))) & 0xffffffff), 32)
			24:
				return _zp_signed(100, 32)
			25:
				var _v9: int = f5bcf20(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32))
				_pc = 24
			26:
				return _zp_signed(10, 32)
			27:
				var _v10: int = f5b9170(((((((((_zp_signed((((((((in_ECX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 26
			28:
				var _v11: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v11 == 0x80: _pc = 3
				if _v11 == 0x7f: _pc = 9
				if _v11 == 0x7e: _pc = 22
				if _v11 == 0x7d: _pc = 23
				if _v11 == 0x6f: _pc = 25
				if _v11 == 100: _pc = 27
			29:
				uVar3 = ((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(100, 32)), 32), 32) >> ((0x10) & 31)), 32)) & 0xffff)) & 0xffff)
				_pc = 28
			30:
				_pc = 29 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f585dc0(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 6
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar3, ((((((((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) >> ((1) & 31)), 32)) << 8) | ((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), ((((((((((((((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xff)) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xd) & 0xffffffff))) & 0xffffffff))
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f402460(0x228)
				uVar3 = ((_v1) & 0xffffffff)
				_pc = 2
			4:
				var _v2: int = f574900(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), uVar2, 1)
				_pc = 3
			5:
				var _v3: int = f4022e0(m.u16(param_1))
				uVar2 = ((_v3) & 0xffff)
				_pc = 4
			6:
				uVar1 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 5
	return 0


func f586330(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var _stack: int = m.local(8)
	var puVar1: int = 0
	var uVar2: int = 0
	var in_EAX: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var extraout_var_01: int = 0
	var uVar7: int = 0
	var uVar8: int = 0
	var _pc: int = 32
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f575800(uVar7, uVar5, uVar3)
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f5747e0(uVar8, (((extraout_var_00) << 16) | ((m.u16(puVar1)) & 0xffff)), uVar3, ((((((((((uVar7) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xd) & 0xffffffff))) & 0xffffffff))
				_pc = 2
			4:
				uVar3 = ((((((((((((uVar6) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((m.u32((_stack + 4))) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 3
			5:
				var _v2: int = f5747e0(uVar7, (((extraout_var) << 16) | ((m.u16(puVar1)) & 0xffff)), uVar5, (((((((((((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xd) & 0xffffffff))) & 0xffffffff))
				_pc = 4
			6:
				uVar5 = ((((((((((((uVar5) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((uVar7) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			7:
				m.set_u32((_stack + 4), (((((m.u16(((_zp_signed((_zp_signed(_zp_signed((_stack + 4), 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) << 16) | ((((((m.u32((_params + 0))) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff))
				_pc = 6
			8:
				m.set_u8(((_zp_signed((_zp_signed(_zp_signed((_params + 0), 32), 32) + _zp_signed(0, 32)), 32)) & 0xffffffff), ((((m.u32((_stack + 0))) & 0xff)) & 0xff))
				_pc = 7
			9:
				var _v3: int = f574900(uVar8, uVar6, uVar2, 1)
				_pc = 8
			10:
				var _v4: int = f4022e0((((extraout_var_01) << 16) | ((m.u16(m.u32((_params + 0)))) & 0xffff)))
				uVar2 = ((_v4) & 0xffff)
				_pc = 9
			11:
				var _v5: int = f574900(uVar7, uVar5, uVar2, 1)
				_pc = 10
			12:
				var _v6: int = f4022e0(m.u16(m.u32((_params + 0))))
				uVar2 = ((_v6) & 0xffff)
				_pc = 11
			13:
				var _v7: int = int((int((((((((m.u32((0xa55d74 + (((((((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar7) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)
				if _v7 != 0:
					uVar3 = ((0) & 0xffffffff)
					_v7 = int((int((((((((m.u32((0xa55d74 + (((((((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((m.u32((_stack + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)
				_pc = 12 if (_v7) != 0 else 1
			14:
				uVar3 = ((0) & 0xffffffff)
				_pc = 13
			15:
				_pc = 14 if (int(((uVar7) & 0xffffffff) != ((uVar8) & 0xffffffff))) != 0 else 1
			16:
				uVar3 = ((m.u32((_stack + 0))) & 0xffffffff)
				_pc = 15
			17:
				uVar8 = (((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 16
			18:
				uVar6 = ((((((((((((m.u32((_stack + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 17
			19:
				uVar7 = ((_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 18
			20:
				uVar5 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 19
			21:
				_pc = 20 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			22:
				uVar3 = ((0) & 0xffffffff)
				_pc = 21
			23:
				var _v8: int = f583470(m.u32((_params + 0)), 0, (_stack + 0))
				iVar4 = _zp_signed(_v8, 32)
				_pc = 22
			24:
				return ((0) & 0xffffffff)
			25:
				_pc = 24 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 23
			26:
				return ((0) & 0xffffffff)
			27:
				_pc = 26 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) != _zp_signed(m.u16(m.u32((_params + 0))), 32))) != 0 else 25
			28:
				uVar5 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 27
			29:
				uVar3 = ((_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 28
			30:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			31:
				_pc = 30 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 29
			32:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 31
	return 0


func f586540(param_1: int) -> int:
	var iVar1: int = 0
	var bVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var unaff_EDI: int = 0
	var _pc: int = 17
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f576940(param_1, uVar4)
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 12 if (int(_zp_signed(iVar5, 32) < _zp_signed(0x20, 32))) != 0 else 2
			4:
				bVar2 = ((_zp_signed((_zp_signed(bVar2, 32) + _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 3
			5:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(0x10, 32)), 32), 32)
				_pc = 4
			6:
				_pc = 10 if (int(_zp_signed(_zp_signed(uVar3, 32), 32) < _zp_signed(5, 32))) != 0 else 5
			7:
				uVar3 = (((((((uVar3) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 6
			8:
				uVar4 = (((((((uVar4) & 0xffffffff) | ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed(iVar5, 8), 32) + _zp_signed(_zp_signed(uVar3, 8), 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 7
			10:
				var _v1: int = f57aaa0(param_1, (((((((((((((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((unaff_EDI) & 0xffffffff))) & 0xffffffff))
				iVar1 = _zp_signed(_v1, 32)
				_pc = 9
			11:
				uVar3 = ((0) & 0xffffffff)
				_pc = 10
			12:
				unaff_EDI = (((((_zp_signed((((((unaff_EDI) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((bVar2) & 0xffff)) & 0xffff))) & 0xffffffff)
				_pc = 11
			13:
				bVar2 = ((0) & 0xff)
				_pc = 12
			14:
				return (((((((param_1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			15:
				_pc = 14 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 13
			16:
				uVar4 = ((0) & 0xffffffff)
				_pc = 15
			17:
				iVar5 = _zp_signed(0, 32)
				_pc = 16
	return 0


func f5865c0(param_1: int) -> int:
	var bVar1: int = 0
	var bVar2: int = 0
	var uVar3: int = 0
	var in_EAX: int = 0
	var iVar4: int = 0
	var pbVar5: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var uVar8: int = 0
	var uVar9: int = 0
	var _pc: int = 47
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f579790(uVar9, m.u16(param_1), (((((((((((((_zp_signed((((((uVar8) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((((_zp_signed((_zp_signed(_zp_signed(uVar8, 8), 32) + _zp_signed(4, 32)), 32)) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff) << ((4) & 31))) & 0xffffffff)) & 0xffffffff) | ((3) & 0xffffffff))) & 0xffffffff))
				_pc = 1
			3:
				uVar8 = ((((((((((_zp_signed(((((((((_zp_signed((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((uVar3) & 0xffff))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((_zp_signed((_zp_signed(_zp_signed((~(((uVar3) & 0xff))), 32), 32) ^ _zp_signed(m.u16(0xa577fa), 32)), 32)) & 0xff))) & 0xffffffff) & ((0xffffff01) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 2
			4:
				_pc = 25 if (1) != 0 else 1
			5:
				return ((0x7f) & 0xffffffff)
			6:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)) & 0xffff))
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(4, 32) < _zp_signed(_zp_signed(uVar8, 32), 32))) != 0 else 4
			8:
				pbVar5 = (((pbVar5 + (0x90) * 1)) & 0xffffffff)
				_pc = 7
			9:
				uVar8 = (((((((uVar8) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 8
			10:
				var _v1: int = f575160(uVar9, uVar8, bVar2)
				_pc = 9
			11:
				var _v2: int = f577880(param_1, uVar9, uVar8)
				_pc = 9
			12:
				_pc = 10 if (int(_zp_signed(uVar3, 32) < _zp_signed(0x5dc, 32))) != 0 else 11
			13:
				var _v3: int = f4027b0(uVar3)
				uVar3 = ((_v3) & 0xffff)
				_pc = 12
			14:
				var _v4: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar9) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xf1) & 0xff)), 0x1e, bVar2, bVar2)
				_pc = 13
			15:
				var _v5: int = f578430(uVar9, uVar3)
				_pc = 14
			16:
				var _v6: int = f575160(uVar9, uVar8, 1)
				_pc = 15
			17:
				_pc = 11
			18:
				_pc = 17 if (int(_zp_signed(0x5db, 32) < _zp_signed(iVar4, 32))) != 0 else 9
			19:
				var _v7: int = f56f690(uVar9, uVar8)
				iVar4 = _zp_signed(_v7, 32)
				_pc = 18
			20:
				_pc = 16 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 19
			21:
				var _v8: int = f5b9170(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32), 32) | _zp_signed(8, 32)), 32), uVar9, ((((((((((uVar8) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff), 0)
				_pc = 20
			22:
				bVar2 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 21
			23:
				bVar1 = ((m.u8(pbVar5)) & 0xff)
				_pc = 22
			24:
				_pc = 23 if (int(_zp_signed(uVar3, 32) != _zp_signed(0, 32))) != 0 else 9
			25:
				uVar3 = ((_zp_signed((_zp_signed(m.u16((((pbVar5 + (_zp_signed((-(6)), 32)) * 1)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 24
			26:
				pbVar5 = (((((0xa55d7a + (((((((((((uVar9) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)) & 0xffffffff)
				_pc = 25
			27:
				uVar8 = ((0) & 0xffffffff)
				_pc = 26
			28:
				_pc = 27 if (int(_zp_signed(uVar7, 32) == _zp_signed(0x80, 32))) != 0 else 1
			29:
				return ((0x7f) & 0xffffffff)
			30:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) + _zp_signed(0x100, 32)), 32), 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 29
			31:
				return ((0x7f) & 0xffffffff)
			32:
				var _v9: int = f579310(uVar9, _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), uVar6, 1)
				_pc = 31
			33:
				var _v10: int = f5700f0(uVar9, 0xb, _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32))
				uVar6 = ((_v10) & 0xffffffff)
				_pc = 32
			34:
				var _v12: int = int((int(_zp_signed(uVar3, 32) < _zp_signed(0x15, 32))) != 0)
				if _v12 != 0:
					var _v11: int = f4027b0(uVar7)
					uVar3 = ((_v11) & 0xffff)
					_v12 = int((int(_zp_signed(0x5db, 32) < _zp_signed(uVar3, 32))) != 0)
				_pc = 33 if (_v12) != 0 else 30
			35:
				var _v13: int = f4025d0(uVar7)
				uVar3 = ((_v13) & 0xffff)
				_pc = 34
			36:
				var _v14: int = f5b9170((((((((((((((-(((int(((uVar9) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x1f) & 0xffffffff))) & 0xffffffff), uVar6, m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff)), 0)
				_pc = 35
			37:
				var _v15: int = f4022e0(uVar7)
				uVar6 = ((_v15) & 0xffffffff)
				_pc = 36
			38:
				var _v16: int = f578430(uVar9, uVar7)
				_pc = 37
			39:
				uVar7 = ((_zp_signed((_zp_signed(m.u16(((((0xa56434 + (((((((((((uVar9) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + (((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 38
			40:
				return ((0x7e) & 0xffffffff)
			41:
				_pc = 40 if (int(_zp_signed(((m.u8((((0xa55d68 + (((((((((((uVar9) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffff), 32) <= _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32))) != 0 else 39
			42:
				_pc = 41 if (int(_zp_signed(uVar7, 32) == _zp_signed(0x7f, 32))) != 0 else 28
			43:
				_pc = 3 if (int(_zp_signed(uVar7, 32) == _zp_signed(0x7e, 32))) != 0 else 42
			44:
				uVar7 = ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)) & 0xffff)
				_pc = 43
			45:
				_pc = 44 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			46:
				uVar9 = ((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(uVar3, 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 45
			47:
				uVar3 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 46
	return 0


func f5868a0(param_1: int) -> int:
	var _stack: int = m.local(24)
	var sVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var bVar6: int = 0
	var uVar7: int = 0
	var uVar8: int = 0
	var _pc: int = 45
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((1) & 0xffffffff)
			2:
				var _v0: int = f577880(param_1, uVar7, uVar5)
				_pc = 1
			3:
				return ((1) & 0xffffffff)
			4:
				var _v1: int = f574f40(param_1, uVar7, uVar5, 0)
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(2000, 32) < _zp_signed(iVar4, 32))) != 0 else 2
			6:
				var _v2: int = f56f6b0(uVar7, uVar5)
				iVar4 = _zp_signed(_v2, 32)
				_pc = 5
			7:
				return ((0) & 0xffffffff)
			8:
				return ((0x7f) & 0xffffffff)
			9:
				var _v3: int = f59deb0((_stack + 4), 0)
				_pc = 8
			10:
				var _v4: int = f59de70((_stack + 4), 0)
				_pc = 9
			11:
				var _v5: int = f59de30((_stack + 4), 0)
				_pc = 10
			12:
				var _v6: int = f578390(uVar7, uVar8, uVar5)
				_pc = 11
			13:
				m.set_u16((_stack + 4), ((uVar8) & 0xffff))
				_pc = 12
			14:
				m.set_u32((_stack + 18), _zp_signed((((((((((((((bVar6) << 8) | ((_zp_signed(iVar4, 8)) & 0xff))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((0x10) & 31))) & 0xffffffff), 32))
				_pc = 13
			15:
				m.set_u16((_stack + 22), ((((bVar6) & 0xffff)) & 0xffff))
				_pc = 14
			16:
				m.set_u16((_stack + 6), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((uVar2) & 0xff), 32) & _zp_signed(1, 32)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((_stack + 0)), 32) & _zp_signed(0x1f, 32)), 32), 32) << ((1) & 31)), 32), 32)), 32), 32) | _zp_signed(0x1000, 32)), 32)) & 0xffff))
				_pc = 15
			17:
				m.set_u16((_stack + 8), _zp_signed(_zp_signed((_zp_signed(_zp_signed(iVar4, 16), 32) * _zp_signed(0x20, 32)), 32), 16))
				_pc = 16
			18:
				m.set_u32((_stack + 14), ((0) & 0xffffffff))
				_pc = 17
			19:
				m.set_u16((_stack + 12), ((0) & 0xffff))
				_pc = 18
			20:
				m.set_u16((_stack + 10), ((0) & 0xffff))
				_pc = 19
			21:
				bVar6 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(3, 32)), 32), 32) << ((4) & 31)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(m.u8((_stack + 0)), 32) & _zp_signed(0xf, 32)), 32), 32)), 32), 32) << ((1) & 31)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(((uVar2) & 0xff), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xff)
				_pc = 20
			22:
				m.set_u8((_stack + 0), (((((((((uVar2) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xff)) & 0xff))
				_pc = 21
			23:
				iVar4 = _zp_signed((((((((((((((((((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 22
			24:
				var _v7: int = f574f40(param_1, uVar7, uVar5, 0)
				_pc = 23
			25:
				return ((0x7f) & 0xffffffff)
			26:
				var _v8: int = f574f40(param_1, uVar7, uVar5, 1)
				_pc = 25
			27:
				_pc = 26 if (int((int(_zp_signed(sVar1, 32) != _zp_signed(0x1cd, 32))) != 0 and (int(_zp_signed(sVar1, 32) != _zp_signed(0x45c, 32))) != 0)) != 0 else 24
			28:
				var _v9: int = f4022e0(uVar8)
				sVar1 = _zp_signed(_v9, 16)
				_pc = 27
			29:
				_pc = 28 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u16((0xa55d7a + (((((((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 2)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16((0xa55d7a + (((((((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 2)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 7
			30:
				_pc = 29 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 7
			31:
				var _v10: int = f583470(param_1, 0, 0)
				iVar4 = _zp_signed(_v10, 32)
				_pc = 30
			32:
				_pc = 31 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 7
			33:
				return ((0x7e) & 0xffffffff)
			34:
				var _v11: int = f59ca20(0xffffffff)
				_pc = 33
			35:
				var _v12: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar7) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xf1) & 0xff)), 0xf, 0, 0)
				_pc = 34
			36:
				var _v13: int = f578430(uVar7, uVar8)
				_pc = 35
			37:
				_pc = 36 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 32
			38:
				_pc = 37 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(126, 32))) != 0 else 6
			39:
				uVar8 = ((_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 38
			40:
				uVar3 = (((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 39
			41:
				uVar5 = ((((((((((((uVar2) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 40
			42:
				uVar7 = (((((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 41
			43:
				var _v14: int = f583440(param_1, 0)
				uVar2 = ((_v14) & 0xffffffff)
				_pc = 42
			44:
				return ((0) & 0xffffffff)
			45:
				_pc = 44 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 43
	return 0


func f586b30(param_1: int, param_2: int) -> int:
	var _stack: int = m.local(8)
	var puVar1: int = 0
	var sVar2: int = 0
	var in_EAX: int = 0
	var uVar3: int = 0
	var puVar4: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var puVar5: int = 0
	var extraout_var_01: int = 0
	var iVar6: int = 0
	var uVar7: int = 0
	var uVar8: int = 0
	var iVar9: int = 0
	var _pc: int = 72
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((((puVar4) & 0xffffffff)) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				puVar4 = ((param_2) & 0xffffffff)
				_pc = 1
			3:
				m.set_u8((((param_2 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u8((((param_2 + (2) * 2)) & 0xffffffff)), 32) | _zp_signed(0x10, 32)), 32)) & 0xff))
				_pc = 2
			4:
				var _v0: int = f577880(param_1, _zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32))
				_pc = 3
			5:
				var _v1: int = f575160(uVar3, puVar5, 0)
				_pc = 4
			6:
				var _v2: int = f5b9170(((((((((extraout_var_01) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0xf1) & 0xffffffff))) & 0xffffffff), 0xf, 0, 0)
				_pc = 5
			7:
				var _v3: int = f578430(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), uVar8)
				_pc = 6
			8:
				var _v4: int = f575160(uVar3, puVar5, 1)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_stack + 4)) + (0x52aebd) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 4
			10:
				_pc = 9 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x15, 32))) != 0 else 3
			11:
				var _v5: int = f4025d0(uVar8)
				sVar2 = _zp_signed(_v5, 16)
				_pc = 10
			12:
				var _v7: int = int((int(_zp_signed(uVar8, 32) != _zp_signed(0, 32))) != 0)
				if _v7 != 0:
					var _v6: int = int((int(((uVar3) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) != 0)
					if _v6 == 0:
						puVar4 = ((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)) & 0xffffffff)
						_v6 = int((int(((puVar5) & 0xffffffff) != ((puVar4) & 0xffffffff))) != 0)
					_v7 = int((_v6) != 0)
				_pc = 11 if (_v7) != 0 else 1
			13:
				puVar4 = ((m.u32((_stack + 4))) & 0xffffffff)
				_pc = 12
			14:
				uVar8 = ((_zp_signed((_zp_signed(m.u16((m.u32((_stack + 4)) + (0x52aeba) * 2)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 13
			15:
				m.set_u32((_stack + 4), (((((((((_zp_signed((_zp_signed(_zp_signed(puVar5, 32), 32) * _zp_signed(0x90, 32)), 32)) & 0xffffffff) + ((((((((((((m.u32((_stack + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff))
				_pc = 14
			16:
				uVar3 = (((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				puVar5 = ((((((((((((((m.u32((_stack + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 16
			18:
				var _v8: int = f583470(param_2, 0, (_stack + 0))
				_pc = 17
			19:
				return ((0) & 0xffffffff)
			20:
				_pc = 19 if (int((int(((puVar4) & 0xffffffff) != ((((0x53) & 0xffffffff)) & 0xffffffff))) != 0 and (int(((puVar4) & 0xffffffff) != ((((0xdf) & 0xffffffff)) & 0xffffffff))) != 0)) != 0 else 18
			21:
				return (((((((((param_2) & 0xffffffff)) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			22:
				m.set_u8((((param_2 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u8((((param_2 + (2) * 2)) & 0xffffffff)), 32) | _zp_signed(0x10, 32)), 32)) & 0xff))
				_pc = 21
			23:
				_pc = 34 if (int(_zp_signed(_zp_signed(param_1, 32), 32) < _zp_signed(2, 32))) != 0 else 22
			24:
				param_1 = ((((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(1, 32)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 23
			25:
				var _v9: int = f575160(uVar7, uVar3, 0)
				_pc = 24
			26:
				var _v10: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((puVar1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0xf1) & 0xffffffff))) & 0xffffffff), 0xf, 0, 0)
				_pc = 25
			27:
				var _v11: int = f578430(_zp_signed((_zp_signed(((m.u16((puVar1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), uVar8)
				_pc = 26
			28:
				var _v12: int = f575160(uVar7, uVar3, 1)
				_pc = 27
			29:
				var _v14: int = int((int(_zp_signed(uVar8, 32) != _zp_signed(0, 32))) != 0)
				if _v14 != 0:
					var _v13: int = f4025d0(uVar8)
					sVar2 = _zp_signed(_v13, 16)
					_v14 = int((int(_zp_signed(sVar2, 32) == _zp_signed(0x15, 32))) != 0)
				_pc = 28 if (int((_v14) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55d7a, 32), 32) + _zp_signed(_zp_signed(m.u32((_stack + 4)), 32), 32)), 32)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 24
			30:
				uVar8 = ((_zp_signed((_zp_signed(m.u16(((((0xa55d74 + (((((((((((m.u32((_stack + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 29
			31:
				m.set_u32((_stack + 4), ((((((((((((((uVar3) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((m.u32((_stack + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff))
				_pc = 30
			32:
				uVar7 = (((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 31
			33:
				uVar3 = ((((((((((((m.u32((_stack + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 32
			34:
				var _v15: int = f583470(param_2, param_1, (_stack + 0))
				_pc = 33
			35:
				param_1 = ((((0x0) & 0xffffffff)) & 0xffffffff)
				_pc = 34
			36:
				_pc = 35 if (int(((puVar4) & 0xffffffff) == ((((0x249) & 0xffffffff)) & 0xffffffff))) != 0 else 20
			37:
				return ((0) & 0xffffffff)
			38:
				_pc = 37 if (int(((puVar4) & 0xffffffff) != ((((0x3ec) & 0xffffffff)) & 0xffffffff))) != 0 else 18
			39:
				_pc = 54
			40:
				_pc = 39 if (int(((puVar4) & 0xffffffff) == ((((0x29f) & 0xffffffff)) & 0xffffffff))) != 0 else 38
			41:
				_pc = 36 if (int(((puVar4) & 0xffffffff) < ((((0x24a) & 0xffffffff)) & 0xffffffff))) != 0 else 40
			42:
				return (((((((((param_2) & 0xffffffff)) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			43:
				m.set_u8((((param_2 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u8((((param_2 + (2) * 2)) & 0xffffffff)), 32) | _zp_signed(0x10, 32)), 32)) & 0xff))
				_pc = 42
			44:
				_pc = 52 if (int(_zp_signed(iVar9, 32) < _zp_signed(0x5a1, 32))) != 0 else 43
			45:
				iVar6 = _zp_signed(_zp_signed((_zp_signed(iVar6, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 44
			46:
				iVar9 = _zp_signed(_zp_signed((_zp_signed(iVar9, 32) + _zp_signed(0x90, 32)), 32), 32)
				_pc = 45
			47:
				var _v16: int = f575160(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), iVar6, 0)
				_pc = 46
			48:
				var _v17: int = f5b9170(((((((((extraout_var_00) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0xf1) & 0xffffffff))) & 0xffffffff), 0xf, 0, 0)
				_pc = 47
			49:
				var _v18: int = f578430(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), uVar8)
				_pc = 48
			50:
				var _v19: int = f575160(uVar3, iVar6, 1)
				_pc = 49
			51:
				var _v21: int = int((int(_zp_signed(uVar8, 32) != _zp_signed(0, 32))) != 0)
				if _v21 != 0:
					var _v20: int = f4025d0(uVar8)
					sVar2 = _zp_signed(_v20, 16)
					_v21 = int((int(_zp_signed(sVar2, 32) == _zp_signed(0x15, 32))) != 0)
				var _v22: int = int((_v21) != 0)
				if _v22 != 0:
					uVar3 = ((_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
					_v22 = int((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((((((((((_zp_signed(0xa55d7a, 32)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((iVar9) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)
				_pc = 50 if (_v22) != 0 else 46
			52:
				uVar8 = ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed(0xa55d74, 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0xd44, 32)), 32), 32)), 32), 32) + _zp_signed(iVar9, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 51
			53:
				iVar9 = _zp_signed(0x2d0, 32)
				_pc = 52
			54:
				iVar6 = _zp_signed(5, 32)
				_pc = 53
			55:
				_pc = 54 if (int(((((0x424) & 0xffffffff)) & 0xffffffff) < ((puVar4) & 0xffffffff))) != 0 else 41
			56:
				return (((((((_zp_signed((_zp_signed(_zp_signed(puVar4, 32), 32) - _zp_signed(0x437, 32)), 32)) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			57:
				_pc = 56 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed(puVar4, 32), 32) - _zp_signed(0x437, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 18
			58:
				_pc = 54
			59:
				_pc = 58 if (int(((puVar4) & 0xffffffff) == ((((0x42b) & 0xffffffff)) & 0xffffffff))) != 0 else 57
			60:
				_pc = 59 if (int(((puVar4) & 0xffffffff) < ((((0x46e) & 0xffffffff)) & 0xffffffff))) != 0 else 18
			61:
				_pc = 1
			62:
				_pc = 61 if (int(((puVar4) & 0xffffffff) != ((((0x609) & 0xffffffff)) & 0xffffffff))) != 0 else 18
			63:
				_pc = 60 if (int(((puVar4) & 0xffffffff) < ((((0x470) & 0xffffffff)) & 0xffffffff))) != 0 else 62
			64:
				_pc = 55 if (int(((puVar4) & 0xffffffff) < ((((0x427) & 0xffffffff)) & 0xffffffff))) != 0 else 63
			65:
				puVar4 = (((((((((uVar3) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 64
			66:
				var _v23: int = f4022e0(m.u16(param_2))
				uVar3 = ((_v23) & 0xffffffff)
				_pc = 65
			67:
				var _v24: int = int((int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_2 + (1) * 2)) & 0xffffffff)), 32) ^ _zp_signed(((uVar8) & 0xff), 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)
				if _v24 != 0:
					puVar4 = ((((_zp_signed((_zp_signed(uVar8, 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)) & 0xffffffff)
					_v24 = int((int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar8, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed(_zp_signed((_zp_signed(uVar8, 32) & _zp_signed(1, 32)), 32), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) == _zp_signed(m.u16(param_1), 32))) != 0)
				_pc = 66 if (_v24) != 0 else 1
			68:
				puVar4 = (((((((_zp_signed((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((uVar8) & 0xffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 67
			69:
				uVar8 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 68
			70:
				_pc = 69 if (int((int(_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (2) * 2))) & 0xff), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 and (int(((param_2) & 0xffffffff) != ((((0x0) & 0xffffffff)) & 0xffffffff))) != 0)) != 0 else 1
			71:
				puVar4 = (((((((_zp_signed((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((((m.u16((param_1 + (2) * 2))) & 0xff)) & 0xff))) & 0xffffffff)) & 0xffffffff)
				_pc = 70
			72:
				puVar1 = ((param_1) & 0xffffffff)
				_pc = 71
	return 0


func f586ef0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var uVar2: int = 0
	var in_EAX: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 13
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), ((((((((_zp_signed((_zp_signed(((uVar1) & 0xff), 32) >> ((1) & 31)), 32)) << 8) | ((m.u8((((((((uVar2) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), m.u32((_params + 0)), 2)
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int((((((((m.u32((0xa55d74 + (((((((((((((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((m.u32((_params + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 1
			4:
				uVar4 = ((0) & 0xffffffff)
				_pc = 3
			5:
				_pc = 4 if (int((((((((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 1
			6:
				uVar4 = ((0) & 0xffffffff)
				_pc = 5
			7:
				uVar1 = ((m.u16((((((((uVar2) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffff)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			9:
				uVar4 = ((0) & 0xffffffff)
				_pc = 8
			10:
				var _v1: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar3 = _zp_signed(_v1, 32)
				_pc = 9
			11:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			12:
				_pc = 11 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 10
			13:
				uVar2 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 12
	return 0


func f586fb0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var bVar1: int = 0
	var in_EAX: int = 0
	var uVar6: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar7: int = 0
	var uVar8: int = 0
	var uVar9: int = 0
	var _pc: int = 21
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f577c60(uVar5, uVar9, uVar7)
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				return (((((((uVar5) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			4:
				var _v1: int = f5749b0(_zp_signed((_zp_signed(m.u16((((((((uVar5) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), (((((((((((((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((uVar4) & 0xffffffff))) & 0xffffffff), ((((((((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((uVar4) & 0xffffffff))) & 0xffffffff), 5)
				uVar5 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				uVar4 = (((((_zp_signed((((((uVar5) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32)) & 0xffff)) & 0xffff))) & 0xffffffff)
				_pc = 4
			6:
				bVar1 = ((((m.u16((((((((uVar5) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xff)) & 0xff)
				_pc = 5
			7:
				var _v2: int = f577ca0(uVar5, uVar9, uVar7, (((((1) & 0xffffffff) - ((uVar9) & 0xffffffff))) & 0xffffffff), uVar3)
				_pc = 6
			8:
				_pc = 7 if (int((int((int((((((((m.u32((0xa55d74 + (((((((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar8) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar4) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar8) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 and (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(_zp_signed(uVar3, 32), 32))) != 0)) != 0 else 2
			9:
				uVar8 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((((((((uVar5) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 8
			10:
				uVar4 = ((_zp_signed((_zp_signed(m.u16((((((((uVar5) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 9
			11:
				var _v3: int = f56a400(_zp_signed((_zp_signed(m.u8((((((((uVar5) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				uVar3 = ((_v3) & 0xffffffff)
				_pc = 10
			12:
				uVar9 = (((((((m.u32((_params + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 11
			13:
				uVar7 = ((((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			14:
				_pc = 13 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			15:
				uVar3 = ((0) & 0xffffffff)
				_pc = 14
			16:
				var _v4: int = f583470(uVar5, 0, (_params + 0))
				iVar2 = _zp_signed(_v4, 32)
				_pc = 15
			17:
				var _v5: int = f5b9170((((((((((((((uVar6) << 16) | ((m.u16((((((((m.u32((_params + 0))) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0x94) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((((((((m.u32((_params + 0))) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 0, 0)
				_pc = 16
			18:
				return (((((((((uVar6) & 0xffffffff)) & 0xffffffff) << ((0x10) & 31))) & 0xffffffff)) & 0xffffffff)
			19:
				_pc = 18 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 17
			20:
				uVar6 = (((((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 19
			21:
				uVar5 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 20
	return 0


func f5870c0(param_1: int) -> int:
	var bVar1: int = 0
	var in_EAX: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var iVar6: int = 0
	var iVar7: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5b9170((((((((((((((_zp_signed((((((in_EAX) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0x94) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 0, 0)
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			4:
				var _v1: int = f5784e0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), uVar4)
				uVar2 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				var _v2: int = f5be050(iVar6)
				uVar4 = ((_v2) & 0xffffffff)
				_pc = 4
			6:
				var _v3: int = f576940(param_1, _zp_signed((_zp_signed(0x1f, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) << ((4) & 31)), 32)) & 31)), 32))
				_pc = 5
			7:
				_pc = 13 if (int(_zp_signed(iVar7, 32) < _zp_signed(0x2d0, 32))) != 0 else 6
			8:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 7
			9:
				iVar7 = _zp_signed(_zp_signed((_zp_signed(iVar7, 32) + _zp_signed(0x90, 32)), 32), 32)
				_pc = 8
			10:
				iVar6 = _zp_signed(_zp_signed((_zp_signed(iVar6, 32) + _zp_signed(iVar3, 32)), 32), 32)
				_pc = 9
			11:
				var _v4: int = f56f690(uVar2, iVar5)
				iVar3 = _zp_signed(_v4, 32)
				_pc = 10
			12:
				_pc = 11 if (int((((((((m.u32(((((((((((((_zp_signed(0xa55d74, 32)) & 0xffffffff) + (((((((uVar2) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((iVar7) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 9
			13:
				uVar2 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 12
			14:
				iVar7 = _zp_signed(0, 32)
				_pc = 13
			15:
				iVar5 = _zp_signed(0, 32)
				_pc = 14
			16:
				iVar6 = _zp_signed(0, 32)
				_pc = 15
			17:
				_pc = 16 if (int((int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) ^ _zp_signed(m.u16(0xa577fa), 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(0xe, 32)), 32), 32) == _zp_signed(2, 32))) != 0)) != 0 else 2
			18:
				bVar1 = ((((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff)) & 0xff)
				_pc = 17
			19:
				_pc = 18 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f5871a0(param_1: int) -> int:
	var _stack: int = m.local(8)
	var uVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var uVar5: int = 0
	var iVar6: int = 0
	var uVar7: int = 0
	var _pc: int = 27
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar7) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5b9170((((((((((((((uVar5) << 16) | ((uVar1) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0x94) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((uVar1) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 0, 0)
				uVar7 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int((((((((uVar7) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 1
			4:
				uVar7 = ((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffffffff)
				_pc = 3
			5:
				uVar1 = ((m.u16((((((((param_1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffff)
				_pc = 4
			6:
				uVar5 = ((extraout_var_00) & 0xffff)
				_pc = 5
			7:
				var _v1: int = f577880(param_1, (((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), m.u32((_stack + 4)))
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(1, 32) < _zp_signed(iVar2, 32))) != 0 else 5
			9:
				uVar5 = ((extraout_var) & 0xffff)
				_pc = 8
			10:
				var _v2: int = f5b9170((((((((((((((_zp_signed((((((uVar4) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((((((((param_1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xe1) & 0xffffffff))) & 0xffffffff), 0, uVar7, _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((((((((param_1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32))
				_pc = 9
			11:
				_pc = 18 if (int(_zp_signed(iVar6, 32) < _zp_signed(3, 32))) != 0 else 10
			12:
				iVar6 = _zp_signed(_zp_signed((_zp_signed(iVar6, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 11
			13:
				uVar4 = ((0) & 0xffffffff)
				_pc = 12
			14:
				iVar2 = _zp_signed(_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 13
			15:
				uVar7 = (((((((uVar7) & 0xffffffff) | ((uVar4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			16:
				uVar4 = ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(((iVar6) & 0xff), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff)
				_pc = 15
			17:
				_pc = 14 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 16
			18:
				var _v3: int = f5bddb0(2)
				iVar3 = _zp_signed(_v3, 32)
				_pc = 17
			19:
				iVar6 = _zp_signed(0, 32)
				_pc = 18
			20:
				iVar2 = _zp_signed(0, 32)
				_pc = 19
			21:
				uVar7 = ((0) & 0xffffffff)
				_pc = 20
			22:
				m.set_u32((_stack + 4), ((((((((((((m.u32((_stack + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 21
			23:
				_pc = 22 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			24:
				uVar7 = ((0) & 0xffffffff)
				_pc = 23
			25:
				var _v4: int = f583470(param_1, 0, (_stack + 0))
				iVar2 = _zp_signed(_v4, 32)
				_pc = 24
			26:
				_pc = 25 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			27:
				uVar7 = ((param_1) & 0xffffffff)
				_pc = 26
	return 0


func f5872b0(param_1: int) -> int:
	var uVar1: int = 0
	var sVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var uVar5: int = 0
	var extraout_var_00: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var uVar8: int = 0
	var _pc: int = 49
	while true:
		match _pc:
			0:
				return _zp_signed(0, 8)
			1:
				return _zp_signed(0, 8)
			2:
				return _zp_signed(127, 8)
			3:
				m.set_u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff), ((0) & 0xff))
				_pc = 2
			4:
				return _zp_signed(126, 8)
			5:
				m.set_u8(0xa55c8c, ((5) & 0xff))
				_pc = 4
			6:
				return _zp_signed(125, 8)
			7:
				var _v0: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar6) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xb1) & 0xff)), uVar8, 1, 0)
				_pc = 6
			8:
				_pc = 7 if (int((int(_zp_signed(sVar2, 32) != _zp_signed(0x603, 32))) != 0 and (int(((uVar4) & 0xffffffff) != ((0) & 0xffffffff))) != 0)) != 0 else 6
			9:
				var _v1: int = f4022e0(_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar8) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32))
				sVar2 = _zp_signed(_v1, 16)
				_pc = 8
			10:
				uVar4 = ((((int(_zp_signed(sVar2, 32) != _zp_signed(0x15, 32))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				var _v2: int = f4025d0(uVar7)
				sVar2 = _zp_signed(_v2, 16)
				_pc = 10
			12:
				uVar4 = ((((int(_zp_signed(sVar2, 32) == _zp_signed(0x15, 32))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			13:
				var _v3: int = f4025d0(uVar7)
				sVar2 = _zp_signed(_v3, 16)
				_pc = 12
			14:
				_pc = 13 if (int((int(_zp_signed(uVar1, 32) == _zp_signed(0x2ef, 32))) != 0 or (int(_zp_signed(uVar1, 32) == _zp_signed(0x409, 32))) != 0)) != 0 else 9
			15:
				_pc = 11 if (int(_zp_signed(uVar1, 32) == _zp_signed(0x482, 32))) != 0 else 14
			16:
				var _v4: int = f598b50(uVar6, uVar8, uVar7)
				uVar4 = ((_v4) & 0xffffffff)
				_pc = 9
			17:
				_pc = 16 if (int(_zp_signed(uVar1, 32) == _zp_signed(0x601, 32))) != 0 else 9
			18:
				_pc = 15 if (int(_zp_signed(uVar1, 32) < _zp_signed(0x483, 32))) != 0 else 17
			19:
				var _v5: int = f4022e0(uVar1)
				uVar1 = ((_v5) & 0xffff)
				_pc = 18
			20:
				uVar4 = ((0) & 0xffffffff)
				_pc = 19
			21:
				_pc = 20 if (int((int(_zp_signed(uVar7, 32) != _zp_signed(0, 32))) != 0 and (int((int((int(((uVar6) & 0xffffffff) != ((uVar4) & 0xffffffff))) != 0 or (int(((uVar8) & 0xffffffff) != ((uVar5) & 0xffffffff))) != 0)) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar8) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0)) != 0 else 6
			22:
				uVar7 = ((_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar8) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 21
			23:
				uVar8 = ((((((((((m.u8(0xa55c8d)) << 8) | ((m.u8(0xa55c8c)) & 0xff))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 22
			24:
				uVar3 = (((((((uVar6) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 23
			25:
				uVar6 = (((((((1) & 0xffffffff) - ((uVar4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 24
			26:
				_pc = 25 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0, 32))) != 0 else 24
			27:
				uVar6 = ((uVar4) & 0xffffffff)
				_pc = 26
			28:
				return _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(int(_zp_signed(uVar1, 32) < _zp_signed(0x200, 32)))), 32), 32) & _zp_signed(7, 32)), 32), 32) + _zp_signed(0x78, 32)), 32), 8)
			29:
				m.set_u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff), ((((_zp_signed((_zp_signed(uVar1, 32) >> ((8) & 31)), 32)) & 0xff)) & 0xff))
				_pc = 28
			30:
				uVar1 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff))) & 0xffff), 32) * _zp_signed(0x100, 32)), 32), 32) + _zp_signed(0x100, 32)), 32)) & 0xffff)
				_pc = 29
			31:
				return _zp_signed(126, 8)
			32:
				_pc = 31 if (int(_zp_signed(m.u8(0xa55c8c), 32) < _zp_signed(0xb, 32))) != 0 else 30
			33:
				m.set_u8(0xa55c8c, ((_zp_signed((_zp_signed(m.u8(0xa55c8c), 32) + _zp_signed(1, 32)), 32)) & 0xff))
				_pc = 32
			34:
				return _zp_signed(0, 8)
			35:
				var _v6: int = f5b9170(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32), 32) | _zp_signed(0x19, 32)), 32), 1, 0, 0)
				_pc = 34
			36:
				_pc = 35 if (int((int(_zp_signed(uVar1, 32) == _zp_signed(0x2ef, 32))) != 0 or (int(_zp_signed(uVar1, 32) == _zp_signed(0x409, 32))) != 0)) != 0 else 1
			37:
				return _zp_signed(0, 8)
			38:
				var _v7: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x1a) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 37
			39:
				_pc = 38 if (int(_zp_signed(uVar1, 32) == _zp_signed(0x482, 32))) != 0 else 36
			40:
				var _v8: int = f5b9170(((((((((extraout_var_00) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x1b) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 1
			41:
				_pc = 40 if (int(_zp_signed(uVar1, 32) == _zp_signed(0x601, 32))) != 0 else 1
			42:
				_pc = 39 if (int(_zp_signed(uVar1, 32) < _zp_signed(0x483, 32))) != 0 else 41
			43:
				var _v9: int = f4022e0(uVar1)
				uVar1 = ((_v9) & 0xffff)
				_pc = 42
			44:
				var _v10: int = _zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x78, 32)), 32)
				_pc = 1
				if _v10 == 8: _pc = 3
				if _v10 == 7: _pc = 5
				if _v10 == 6: _pc = 27
				if _v10 == 5: _pc = 33
				if _v10 == 0: _pc = 43
			45:
				_pc = 44 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (((((((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) == _zp_signed(uVar1, 32))) != 0 else 1
			46:
				uVar5 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 45
			47:
				uVar4 = ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 46
			48:
				uVar1 = ((m.u16(param_1)) & 0xffff)
				_pc = 47
			49:
				_pc = 48 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f5875a0(param_1: int) -> int:
	var uVar1: int = 0
	var bVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var iVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 30
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f5784e0(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), 1000)
				_pc = 1
			3:
				var _v1: int = f5747e0(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), m.u16(param_1), ((((((((m.u8(0xa55c8c)) << 8) | ((((m.u16((param_1 + (1) * 2))) & 0xff)) & 0xff))) & 0xffffffff) & ((0xff01) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(0xd, 32)), 32))
				_pc = 2
			4:
				return ((0) & 0xffffffff)
			5:
				var _v2: int = f579310(uVar3, iVar4, (((0xa56434 + (uVar3) * 4) + (iVar4) * 4) + ((((((uVar3) & 0xffffffff) * ((0x350) & 0xffffffff))) & 0xffffffff)) * 4), 0)
				_pc = 4
			6:
				uVar3 = ((_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 5
			7:
				return ((0x7f) & 0xffffffff)
			8:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), (((((_zp_signed(iVar4, 8)) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffff))
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar5, 32) != _zp_signed(0, 32))) != 0 else 6
			10:
				var _v3: int = f570b40(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32))
				iVar5 = _zp_signed(_v3, 32)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(iVar5, 32) != _zp_signed(0, 32))) != 0 else 6
			12:
				var _v4: int = f56a000(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32))
				iVar5 = _zp_signed(_v4, 32)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar4, 32))) != 0 else 1
			14:
				var _v5: int = f568b30(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(0x1fe0, 32)), 32), 32) >> ((5) & 31)), 32))
				iVar4 = _zp_signed(_v5, 32)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			16:
				return ((0x7e) & 0xffffffff)
			17:
				var _v6: int = f5ada20(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), ((0xa56434 + (((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff)) * 4) + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) * 4), 1, 1, 1, 0xb, ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff))
				_pc = 16
			18:
				m.set_u32(0xa55c8c, (((((((m.u32(0xa55c8c)) & 0xffffffff) ^ ((_zp_signed((_zp_signed(m.u8(0xa55c8c), 32) ^ _zp_signed(bVar2, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 17
			19:
				var _v7: int = f56a030(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32))
				bVar2 = ((_v7) & 0xff)
				_pc = 18
			20:
				_pc = 19 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 15
			21:
				_pc = 3 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 20
			22:
				return ((0) & 0xffffffff)
			23:
				var _v8: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(1, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0x60) & 0xff)), 0, 0, 0)
				_pc = 22
			24:
				var _v9: int = f577ac0(param_1, _zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32))
				_pc = 23
			25:
				var _v10: int = f579790((((((1) & 0xffffffff) - ((uVar6) & 0xffffffff))) & 0xffffffff), m.u16(param_1), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(0x1fe0, 32)), 32), 32) >> ((5) & 31)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(0xd, 32)), 32))
				_pc = 24
			26:
				_pc = 25 if (int((int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (((((((((((uVar6) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) == _zp_signed(m.u16(param_1), 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar6) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			27:
				uVar6 = ((_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 26
			28:
				uVar3 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 27
			29:
				_pc = 21 if (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0x3000, 32)), 32), 32) == _zp_signed(0x2000, 32))) != 0 else 28
			30:
				uVar1 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 29
	return 0


func f5877e0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 43
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f579890()
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 37
			4:
				var _v1: int = f579810()
				_pc = 3
			5:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(uVar2, 32) ^ _zp_signed(((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(1, 32)), 32), 32) ^ _zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32)), 32)) & 0xff), 32)), 32)) & 0xffff))
				_pc = 4
			6:
				m.set_u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((((uVar1) & 0xff)) & 0xff))
				_pc = 5
			7:
				uVar2 = ((m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffff)
				_pc = 6
			8:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)) & 0xffff))
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			10:
				uVar3 = ((0) & 0xffffffff)
				_pc = 9
			11:
				uVar1 = ((m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffff)
				_pc = 10
			12:
				var _v2: int = f56cbd0(uVar6, 800)
				iVar4 = _zp_signed(_v2, 32)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			14:
				uVar3 = ((0) & 0xffffffff)
				_pc = 13
			15:
				var _v3: int = f56cbd0(uVar6, 0x2f4)
				iVar4 = _zp_signed(_v3, 32)
				_pc = 14
			16:
				_pc = 15 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			17:
				uVar3 = ((0) & 0xffffffff)
				_pc = 16
			18:
				var _v4: int = f56cbd0(uVar6, 0x2e1)
				iVar4 = _zp_signed(_v4, 32)
				_pc = 17
			19:
				_pc = 18 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			20:
				uVar3 = ((0) & 0xffffffff)
				_pc = 19
			21:
				var _v5: int = f570b40(uVar6)
				iVar4 = _zp_signed(_v5, 32)
				_pc = 20
			22:
				var _v7: int = int((int(((uVar3) & 0xffffffff) == ((0) & 0xffffffff))) != 0)
				if _v7 != 0:
					var _v6: int = f56a000(uVar6)
					uVar3 = ((_v6) & 0xffffffff)
					_v7 = int((int(_zp_signed(2, 32) < _zp_signed(_zp_signed(uVar3, 32), 32))) != 0)
				_pc = 21 if (_v7) != 0 else 1
			23:
				uVar3 = (((((((uVar3) & 0xffffffff) - ((0x80) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 22
			24:
				return ((_zp_signed((_zp_signed(int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) < _zp_signed(0x300, 32)), 32) + _zp_signed(0x7e, 32)), 32)) & 0xffffffff)
			25:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) + _zp_signed(0x100, 32)), 32), 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 24
			26:
				var _v8: int = f5adb10(uVar6, (_params + 0), 1, 0x20, 0xe, uVar6)
				_pc = 25
			27:
				_pc = 26 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 25
			28:
				var _v9: int = f56cac0(uVar6, uVar5, (_params + 0))
				iVar4 = _zp_signed(_v9, 32)
				_pc = 27
			29:
				var _v10: int = f402460(iVar4)
				uVar5 = ((_v10) & 0xffffffff)
				_pc = 28
			30:
				iVar4 = _zp_signed(0x2e1, 32)
				_pc = 29
			31:
				iVar4 = _zp_signed(0x2f4, 32)
				_pc = 29
			32:
				iVar4 = _zp_signed(800, 32)
				_pc = 29
			33:
				_pc = 32 if (int(_zp_signed(uVar1, 32) == _zp_signed(2, 32))) != 0 else 29
			34:
				iVar4 = _zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32)
				_pc = 33
			35:
				_pc = 31 if (int(_zp_signed(uVar1, 32) == _zp_signed(1, 32))) != 0 else 34
			36:
				_pc = 30 if (int(_zp_signed(uVar1, 32) == _zp_signed(0, 32))) != 0 else 35
			37:
				uVar1 = ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffff)
				_pc = 36
			38:
				_pc = 37 if (int(((uVar3) & 0xffffffff) == ((0x7f) & 0xffffffff))) != 0 else 23
			39:
				_pc = 2 if (int(((uVar3) & 0xffffffff) == ((0x7e) & 0xffffffff))) != 0 else 38
			40:
				uVar3 = ((((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 39
			41:
				_pc = 40 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			42:
				uVar3 = ((0) & 0xffffffff)
				_pc = 41
			43:
				uVar6 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((0xe) & 31)), 32), 32) & _zp_signed(1, 32)), 32), 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffff)
				_pc = 42
	return 0


func f587950(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var puVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 26
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f579890()
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f598590(_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32), 0x10, ((((((((((uVar6) & 0xffffffff) << ((0x10) & 31))) & 0xffffffff)) & 0xffffffff) | (((((((uVar3) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff))
				_pc = 2
			4:
				var _v2: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((puVar1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x43) & 0xffffffff))) & 0xffffffff), uVar3, 1, 0)
				_pc = 3
			5:
				var _v3: int = f5784e0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), uVar3)
				_pc = 4
			6:
				var _v4: int = f577880(puVar1, uVar6, uVar5)
				_pc = 5
			7:
				var _v5: int = f579810()
				_pc = 6
			8:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			9:
				var _v6: int = f579930(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 1, 1)
				uVar4 = ((_v6) & 0xffffffff)
				_pc = 8
			10:
				var _v7: int = f577880(puVar1, uVar6, uVar5)
				_pc = 9
			11:
				_pc = 10 if (int(((uVar4) & 0xffffffff) == ((0x5ab) & 0xffffffff))) != 0 else 1
			12:
				_pc = 7 if (int(((uVar4) & 0xffffffff) == ((0x3ab) & 0xffffffff))) != 0 else 11
			13:
				uVar4 = (((((((uVar4) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			14:
				var _v8: int = f4022e0(m.u16(puVar1))
				uVar4 = ((_v8) & 0xffffffff)
				_pc = 13
			15:
				var _v9: int = f56f690(uVar6, uVar5)
				uVar3 = ((_v9) & 0xffffffff)
				_pc = 14
			16:
				_pc = 15 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32), 32) != _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			17:
				uVar4 = ((((((((((((uVar5) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 16
			18:
				uVar3 = (((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 17
			19:
				uVar6 = (((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 18
			20:
				uVar5 = ((((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 19
			21:
				_pc = 20 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			22:
				uVar4 = ((0) & 0xffffffff)
				_pc = 21
			23:
				var _v10: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar2 = _zp_signed(_v10, 32)
				_pc = 22
			24:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			25:
				_pc = 24 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 23
			26:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 25
	return 0


func f587a90(param_1: int, param_2: int) -> int:
	var _params: int = m.local(8)
	m.set_u32(_params + 0, param_1)
	m.set_u32(_params + 4, param_2)
	var uVar1: int = 0
	var puVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var in_EAX: int = 0
	var uVar5: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var iVar6: int = 0
	var extraout_var_01: int = 0
	var uVar7: int = 0
	var unaff_EDI: int = 0
	var iVar8: int = 0
	var _pc: int = 67
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7c) & 0xffffffff)
			3:
				m.set_u16((m.u32((_params + 0)) + (3) * 2), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) | _zp_signed(((iVar8) & 0xffff), 32)), 32)) & 0xffff))
				_pc = 2
			4:
				var _v0: int = f5b9170((((((((((((((_zp_signed((((((((iVar6) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((m.u32((_params + 0)) + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(((m.u16((m.u32((_params + 0)) + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), iVar8, 0)
				_pc = 3
			5:
				iVar8 = _zp_signed(((((((((_zp_signed((((((((unaff_EDI) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((((((uVar7) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff) << ((8) & 31))) & 0xffffffff), 32)
				_pc = 4
			6:
				_pc = 8 if (int(_zp_signed(iVar6, 32) == _zp_signed(0, 32))) != 0 else 5
			7:
				var _v1: int = f59dc50(m.u32((_params + 0)), _zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar7)
				iVar6 = _zp_signed(_v1, 32)
				_pc = 6
			8:
				uVar7 = ((_zp_signed((_zp_signed(_zp_signed((((((uVar7) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff), 32), 32) % _zp_signed(5, 32)), 32)) & 0xffffffff)
				_pc = 7
			9:
				var _v2: int = f59dc50(m.u32((_params + 0)), _zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) & _zp_signed(1, 32)), 32), uVar7)
				iVar6 = _zp_signed(_v2, 32)
				_pc = 6
			10:
				uVar7 = ((((((((((((m.u32(0xa57840)) & 0xffffffff) >> ((0xb) & 31))) & 0xffffffff)) & 0xffffffff) & ((7) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				return ((0x7f) & 0xffffffff)
			12:
				var _v3: int = f5bf800(0x7c)
				_pc = 11
			13:
				_pc = 12 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(((m.u16((m.u32((_params + 0)) + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 10
			14:
				_pc = 13 if (int(_zp_signed(iVar6, 32) != _zp_signed(0, 32))) != 0 else 1
			15:
				var _v4: int = f59dd90(m.u32((_params + 0)), m.u32((_params + 4)), 0)
				iVar6 = _zp_signed(_v4, 32)
				_pc = 14
			16:
				return ((0x7f) & 0xffffffff)
			17:
				return ((0x7e) & 0xffffffff)
			18:
				m.set_u16((puVar2 + (3) * 2), (((((m.u8(((_zp_signed((_zp_signed(_zp_signed((_params + 0), 32), 32) + _zp_signed(0, 32)), 32)) & 0xffffffff))) << 8) | ((_zp_signed(uVar5, 8)) & 0xff))) & 0xffff))
				_pc = 17
			19:
				m.set_u8(((_zp_signed((_zp_signed(_zp_signed((_params + 0), 32), 32) + _zp_signed(0, 32)), 32)) & 0xffffffff), ((((iVar6) & 0xff)) & 0xff))
				_pc = 18
			20:
				var _v5: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), (((extraout_var_01) << 16) | ((((m.u32(0xa55044)) & 0xffff)) & 0xffff)), (((((((((((((((m.u32(0xa5504c)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | (((((extraout_var) << 16) | ((((((m.u32(0xa55048)) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 19
			21:
				var _v7: int = int((int(_zp_signed(iVar8, 32) != _zp_signed(0, 32))) != 0)
				if _v7 != 0:
					var _v6: int = f5aa480()
					iVar8 = _zp_signed(_v6, 32)
					_v7 = int((int(_zp_signed(iVar8, 32) != _zp_signed(0, 32))) != 0)
				_pc = 20 if (_v7) != 0 else 16
			22:
				var _v8: int = f59dc50(m.u32((_params + 0)), m.u32(0xa55044), iVar6)
				iVar8 = _zp_signed(_v8, 32)
				_pc = 21
			23:
				iVar6 = _zp_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 22
			24:
				_pc = 23 if (int(_zp_signed(iVar6, 32) != _zp_signed(0, 32))) != 0 else 16
			25:
				uVar5 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 24
			26:
				var _v9: int = f5aa440(0xf0)
				iVar6 = _zp_signed(_v9, 32)
				_pc = 25
			27:
				return (((((uVar3) << 16) | ((0x80) & 0xffff))) & 0xffffffff)
			28:
				_pc = 27 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 26
			29:
				return ((0x7d) & 0xffffffff)
			30:
				var _v10: int = f5bf800(0x20)
				_pc = 29
			31:
				return ((0x7c) & 0xffffffff)
			32:
				var _v11: int = f40c940(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 8, uVar3, 0)
				_pc = 31
			33:
				var _v12: int = f4022e0((((_zp_signed((((((((iVar6) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(m.u32((_params + 0)))) & 0xffff)))
				uVar3 = ((_v12) & 0xffff)
				_pc = 32
			34:
				return ((0x7b) & 0xffffffff)
			35:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)) & 0xffff))
				_pc = 34
			36:
				var _v13: int = f5754a0(m.u8((((m.u32((_params + 0)) + (3) * 2)) & 0xffffffff)), m.u8(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) + _zp_signed(7, 32)), 32)) & 0xffffffff)), m.u16(m.u32((_params + 0))))
				_pc = 35
			37:
				var _v14: int = f579810()
				_pc = 36
			38:
				return ((0x7b) & 0xffffffff)
			39:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) + _zp_signed(0x100, 32)), 32), 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 38
			40:
				m.set_u16((m.u32((_params + 0)) + (_zp_signed((_zp_signed(uVar1, 32) + _zp_signed(4, 32)), 32)) * 2), ((_zp_signed((_zp_signed((((((uVar4) << 8) | ((m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff))) & 0xff))) & 0xffff), 32) & _zp_signed(0xff01, 32)), 32)) & 0xffff))
				_pc = 39
			41:
				var _v15: int = f40cab0()
				var _v16: int = f5ada20(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _v15, 0, 1, 0, 0xd, _zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 40
			42:
				var _v17: int = f5b9170(0xf1, 10, 0, 0)
				_pc = 41
			43:
				var _v18: int = f40ccb0(_zp_signed((_zp_signed(uVar1, 32) + _zp_signed(1, 32)), 32))
				_pc = 42
			44:
				var _v19: int = f5af5a0(_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) & _zp_signed(1, 32)), 32), (((_zp_signed((((((uVar7) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(m.u32((_params + 0)))) & 0xffff)), 0)
				_pc = 42
			45:
				_pc = 43 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed(uVar7, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 44
			46:
				uVar7 = ((((((((((extraout_var_00) << 16) | ((m.u16((m.u32((_params + 0)) + (1) * 2))) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 45
			47:
				var _v20: int = f56a030(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				uVar4 = ((_v20) & 0xffffff)
				_pc = 46
			48:
				uVar1 = ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffff)
				_pc = 47
			49:
				return ((0x7a) & 0xffffffff)
			50:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)) & 0xffff))
				_pc = 49
			51:
				var _v21: int = f579890()
				_pc = 50
			52:
				_pc = 51 if (int(_zp_signed(0x1ff, 32) < _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32))) != 0 else 48
			53:
				return ((0x79) & 0xffffffff)
			54:
				_pc = 57 if (int((((((((uVar7) & 0xffffffff) & ((0xff00) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) < ((0x200) & 0xffffffff))) != 0 else 53
			55:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((((uVar7) & 0xffff)) & 0xffff))
				_pc = 54
			56:
				uVar7 = (((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) + _zp_signed(0x100, 32)), 32)) & 0xffffffff) ^ ((((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 55
			57:
				var _v22: int = f5747e0(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(m.u32((_params + 0))), (((_zp_signed((((((uVar7) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((m.u32((_params + 0)) + ((((((((((((((((uVar7) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) * 2))) & 0xffff)), 3)
				_pc = 56
			58:
				_pc = 57 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) < _zp_signed(0x200, 32))) != 0 else 53
			59:
				return ((0x78) & 0xffffffff)
			60:
				var _v23: int = f576170(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) + _zp_signed(0xb, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) + _zp_signed(9, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32), 32)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) + _zp_signed(7, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32), 32)), 32))
				_pc = 59
			61:
				var _v24: int = f5b9170(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) << ((0xf) & 31)), 32), 32) | _zp_signed(0x60, 32)), 32), 0, 0, 0)
				_pc = 1
			62:
				var _v25: int = iVar6
				_pc = 1
				if _v25 == 8: _pc = 15
				if _v25 == 7: _pc = 28
				if _v25 == 6: _pc = 30
				if _v25 == 5: _pc = 33
				if _v25 == 4: _pc = 37
				if _v25 == 3: _pc = 52
				if _v25 == 2: _pc = 58
				if _v25 == 1: _pc = 60
				if _v25 == 0: _pc = 61
			63:
				iVar6 = _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32) - _zp_signed(0x78, 32)), 32), 32)
				_pc = 62
			64:
				uVar7 = (((((uVar3) << 16) | ((m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffff))) & 0xffffffff)
				_pc = 63
			65:
				uVar3 = (((((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 64
			66:
				_pc = 65 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			67:
				puVar2 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 66
	return 0


func f587e80(param_1: int) -> int:
	var puVar1: int = 0
	var _pc: int = 13
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7f) & 0xffffffff)
			2:
				var _v0: int = f5bcea0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 0)
				_pc = 1
			3:
				return ((0) & 0xffffffff)
			4:
				_pc = 3 if (int(_zp_signed(_zp_signed(m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))), 32), 32) - _zp_signed(1, 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 8), 32) == _zp_signed(0, 32))) != 0 else 2
			5:
				return ((0) & 0xffffffff)
			6:
				_pc = 5 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 4
			7:
				return ((0) & 0xffffffff)
			8:
				var _v1: int = f575a80(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), puVar1, 0x81)
				_pc = 7
			9:
				var _v2: int = f579790(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xffff), 32) & _zp_signed(1, 32)), 32), 32)), 32), m.u16(param_1), ((((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((((((m.u32(puVar1)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff), 8), 32) * _zp_signed(2, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed((((((((m.u32(puVar1)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xff), 32) & _zp_signed(1, 32)), 32), 32)), 32)) << 8) | ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((~(((m.u16((param_1 + (1) * 2))) & 0xff))), 32), 32) ^ _zp_signed(m.u16(0xa577fa), 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) + _zp_signed(6, 32)), 32), 32) * _zp_signed(16, 32)), 32)) & 0xff))) & 0xffffffff) | ((3) & 0xffffffff))) & 0xffffffff))
				_pc = 8
			10:
				var _v3: int = f5700f0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 0xb, m.u16(0xa57822))
				puVar1 = ((((_v3) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 6
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 11
	return 0


func f587f90(param_1: int) -> int:
	var _stack: int = m.local(256)
	var uVar1: int = 0
	var sVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var bVar5: int = 0
	var _pc: int = 42
	while true:
		match _pc:
			0:
				return _zp_signed(0, 8)
			1:
				return _zp_signed(100, 8)
			2:
				return _zp_signed(126, 8)
			3:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 2
			4:
				var _v0: int = f5bf800((_stack + 0))
				_pc = 3
			5:
				var _v1: int = f5bdf40((_stack + 0), 0x24, 0x1f5)
				_pc = 4
			6:
				return _zp_signed(126, 8)
			7:
				var _v2: int = f5bf9a0(1, 0)
				_pc = 6
			8:
				var _v3: int = f5bf800(0x23)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(_zp_signed((((((m.u32(0xa55c8a)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 8), 32) != _zp_signed(0, 32))) != 0 else 5
			10:
				_pc = 9 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			11:
				var _v4: int = f580360(param_1)
				iVar3 = _zp_signed(_v4, 32)
				_pc = 10
			12:
				var _v5: int = f579810()
				_pc = 11
			13:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) ^ _zp_signed(bVar5, 32)), 32)) & 0xffff))
				_pc = 12
			14:
				bVar5 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(1, 32)), 32), 32) ^ _zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32)), 32)) & 0xff)
				_pc = 13
			15:
				m.set_u32(0xa55c8a, (((((((m.u32(0xa55c8a)) & 0xffffffff) & ((0xffff00ff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 14
			16:
				return _zp_signed(125, 8)
			17:
				var _v6: int = f5adb10(uVar4, ((0xa56434 + (m.u32(0xa5504c)) * 4) + ((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4), 1, 0, 0xb, m.u32(0xa5504c))
				_pc = 16
			18:
				uVar4 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 17
			19:
				return _zp_signed(126, 8)
			20:
				_pc = 19 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 18
			21:
				var _v7: int = f5aa480()
				iVar3 = _zp_signed(_v7, 32)
				_pc = 20
			22:
				return _zp_signed(126, 8)
			23:
				_pc = 22 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 21
			24:
				var _v8: int = f567a00(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xfff, 32)), 32))
				iVar3 = _zp_signed(_v8, 32)
				_pc = 23
			25:
				return _zp_signed(126, 8)
			26:
				_pc = 25 if (int(_zp_signed(sVar2, 32) != _zp_signed(1, 32))) != 0 else 24
			27:
				var _v9: int = f4025d0(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xfff, 32)), 32))
				sVar2 = _zp_signed(_v9, 16)
				_pc = 26
			28:
				uVar1 = ((m.u16(((((0xa56434 + (m.u32(0xa5504c)) * 4) + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) * 4)) & 0xffffffff))) & 0xffff)
				_pc = 27
			29:
				return _zp_signed(126, 8)
			30:
				_pc = 29 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 28
			31:
				var _v10: int = f5aa440(1)
				iVar3 = _zp_signed(_v10, 32)
				_pc = 30
			32:
				return _zp_signed(127, 8)
			33:
				_pc = 32 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 31
			34:
				_pc = 33 if (int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32))) != 0 else 1
			35:
				return _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(int((((((((uVar4) & 0xffffffff) & ((0xff00) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) < ((0x200) & 0xffffffff)))), 32), 32) & _zp_signed(0x1b, 32)), 32), 32) + _zp_signed(100, 32)), 32), 8)
			36:
				m.set_u32(0xa55c8a, (((((m.u32(0xa55c8c)) << 16) | ((_zp_signed(uVar4, 16)) & 0xffff))) & 0xffffffff))
				_pc = 35
			37:
				uVar4 = (((((((((((((((((m.u32(0xa55c8a)) & 0xffffffff) & ((0xff00) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((0x100) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) ^ (((((((m.u32(0xa55c8a)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 36
			38:
				return _zp_signed(0, 8)
			39:
				var _v11: int = f579890()
				_pc = 38
			40:
				var _v12: int = (((((m.u32(0xa55c8a)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)
				_pc = 38
				if _v12 == 0x7f: _pc = 11
				if _v12 == 0x80: _pc = 15
				if _v12 == 0x7e: _pc = 34
				if _v12 == 0x7d: _pc = 37
				if _v12 == 100: _pc = 39
			41:
				return _zp_signed(0, 8)
			42:
				_pc = 41 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 40
	return 0


func f5881d0(param_1: int) -> int:
	var puVar1: int = 0
	var in_EAX: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var pbVar4: int = 0
	var _pc: int = 15
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				_pc = 11 if (int(_zp_signed(_zp_signed(param_1, 32), 32) < _zp_signed(2, 32))) != 0 else 1
			3:
				param_1 = ((((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(1, 32)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 2
			4:
				_pc = 8 if (int(_zp_signed(iVar3, 32) < _zp_signed(5, 32))) != 0 else 3
			5:
				pbVar4 = (((pbVar4 + (0x90) * 1)) & 0xffffffff)
				_pc = 4
			6:
				iVar3 = _zp_signed(_zp_signed((_zp_signed(iVar3, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 5
			7:
				var _v0: int = f574810(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(puVar1), (((_zp_signed(iVar3, 8)) << 8) | ((_zp_signed(param_1, 8)) & 0xff)), 0xc)
				uVar2 = ((_v0) & 0xffffffff)
				_pc = 6
			8:
				_pc = 7 if (int((int((((((((m.u32((((pbVar4 + (_zp_signed((-(6)), 32)) * 1)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(pbVar4), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 6
			9:
				pbVar4 = (((((0xa55d7a + ((((((uVar2) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)) & 0xffffffff)
				_pc = 8
			10:
				uVar2 = (((((((((param_1) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				iVar3 = _zp_signed(0, 32)
				_pc = 10
			12:
				param_1 = ((((0x0) & 0xffffffff)) & 0xffffffff)
				_pc = 11
			13:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 12
			15:
				puVar1 = ((param_1) & 0xffffffff)
				_pc = 14
	return 0


func f588260(param_1: int) -> int:
	var bVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var local_4: int = 0
	var _pc: int = 29
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				var _v0: int = f578b60(uVar4, 3)
				_pc = 2
			4:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), (((((m.u8((((0xa55d68 + ((((((uVar4) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffff))
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32) == _zp_signed(0x80, 32))) != 0 else 1
			6:
				return ((0x7e) & 0xffffffff)
			7:
				var _v1: int = f5bcdc0(uVar4, iVar5, 0, 0)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(0, 32) < _zp_signed(iVar5, 32))) != 0 else 6
			9:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(_zp_signed((_zp_signed(1, 32) - _zp_signed(iVar3, 32)), 32), 32)), 32), 32)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(1, 32) < _zp_signed(iVar3, 32))) != 0 else 8
			11:
				iVar5 = _zp_signed(((((((((((((bVar1) & 0xffffffff)) & 0xffffffff) - ((((uVar2) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((_zp_signed((-(1)), 32)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 10
			12:
				_pc = 18 if (int(_zp_signed(iVar5, 32) < _zp_signed(_zp_signed(((m.u8((((0xa55d68 + ((((((uVar4) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffffffff), 32), 32))) != 0 else 11
			13:
				iVar3 = _zp_signed(local_4, 32)
				_pc = 12
			14:
				param_1 = (((param_1 + (1) * 4)) & 0xffffffff)
				_pc = 13
			15:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 14
			16:
				local_4 = _zp_signed(_zp_signed((_zp_signed(local_4, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 15
			17:
				_pc = 16 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 15
			18:
				var _v2: int = f570be0(uVar4, param_1)
				iVar3 = _zp_signed(_v2, 32)
				_pc = 17
			19:
				param_1 = (((0xa56434 + ((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)
				_pc = 18
			20:
				_pc = 19 if (int(_zp_signed(bVar1, 32) != _zp_signed(0, 32))) != 0 else 11
			21:
				iVar3 = _zp_signed(0, 32)
				_pc = 20
			22:
				local_4 = _zp_signed(0, 32)
				_pc = 21
			23:
				bVar1 = ((m.u8((((0xa55d68 + ((((((uVar4) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xff)
				_pc = 22
			24:
				uVar2 = ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffff)
				_pc = 23
			25:
				iVar5 = _zp_signed(0, 32)
				_pc = 24
			26:
				_pc = 25 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32) == _zp_signed(0x7f, 32))) != 0 else 5
			27:
				return ((0) & 0xffffffff)
			28:
				_pc = 27 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 26
			29:
				uVar4 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 28
	return 0


func f5883c0(param_1: int) -> int:
	var uVar1: int = 0
	var sVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var iVar5: int = 0
	var iVar6: int = 0
	var local_8: int = 0
	var local_4: int = 0
	var _pc: int = 39
	while true:
		match _pc:
			0:
				return _zp_signed(0, 8)
			1:
				return _zp_signed(0, 8)
			2:
				var _v0: int = f577880(param_1, _zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), local_4)
				_pc = 1
			3:
				var _v1: int = f5b9170(((((((((uVar4) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), (((extraout_var_00) << 16) | ((((m.u32(0xa55044)) & 0xffff)) & 0xffff)), (((((((((((((((m.u32(0xa5504c)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | (((((uVar4) << 16) | ((((((m.u32(0xa55048)) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 2
			4:
				uVar4 = (((((((((((iVar6) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 3
			5:
				_pc = 9
			6:
				var _v3: int = int((int(_zp_signed(iVar5, 32) == _zp_signed(0, 32))) != 0)
				if _v3 == 0:
					var _v2: int = f56f690(uVar1, local_4)
					iVar5 = _zp_signed(_v2, 32)
					_v3 = int((int(_zp_signed(iVar5, 32) != _zp_signed(iVar6, 32))) != 0)
				var _v5: int = int((_v3) != 0)
				if _v5 == 0:
					var _v4: int = f5aa480()
					iVar6 = _zp_signed(_v4, 32)
					_v5 = int((int(_zp_signed(iVar6, 32) == _zp_signed(0, 32))) != 0)
				_pc = 5 if (_v5) != 0 else 4
			7:
				var _v6: int = f59dc50(param_1, m.u32(0xa55044), local_4)
				iVar5 = _zp_signed(_v6, 32)
				_pc = 6
			8:
				local_4 = _zp_signed((((((m.u32(0xa5504c)) & 0xffffffff) + ((m.u32(0xa55048)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 7
			9:
				return _zp_signed(_zp_signed((_zp_signed(int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff)), 32) + _zp_signed(127, 32)), 32), 8)
			10:
				_pc = 9 if (int(_zp_signed(iVar5, 32) == _zp_signed(0, 32))) != 0 else 8
			11:
				uVar1 = ((m.u32(0xa55044)) & 0xffffffff)
				_pc = 10
			12:
				var _v7: int = f5aa440(0xe00000)
				iVar5 = _zp_signed(_v7, 32)
				_pc = 11
			13:
				var _v8: int = f5929d0()
				_pc = 12
			14:
				return _zp_signed(127, 8)
			15:
				var _v9: int = f5bf800(0x62)
				_pc = 14
			16:
				_pc = 15 if (int((int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 and (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0)) != 0 else 2
			17:
				_pc = 13 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 16
			18:
				_pc = 17 if (int(_zp_signed(1, 32) < _zp_signed(local_8, 32))) != 0 else 2
			19:
				_pc = 18 if (int(_zp_signed(local_8, 32) != _zp_signed(0, 32))) != 0 else 1
			20:
				_pc = 34 if (int(_zp_signed(iVar5, 32) < _zp_signed(5, 32))) != 0 else 19
			21:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 20
			22:
				local_8 = _zp_signed(_zp_signed((_zp_signed(local_8, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 21
			23:
				_pc = 27
			24:
				_pc = 23 if (int((int(_zp_signed(iVar6, 32) < _zp_signed(0, 32))) != 0 or (int(_zp_signed(iVar6, 32) < _zp_signed(iVar3, 32))) != 0)) != 0 else 21
			25:
				local_4 = _zp_signed(iVar5, 32)
				_pc = 21
			26:
				iVar6 = _zp_signed(iVar3, 32)
				_pc = 25
			27:
				local_8 = _zp_signed(1, 32)
				_pc = 26
			28:
				_pc = 27 if (int((int(_zp_signed(sVar2, 32) == _zp_signed(0x3e9, 32))) != 0 and (int((int(_zp_signed(iVar6, 32) < _zp_signed(0, 32))) != 0 or (int(_zp_signed(iVar3, 32) < _zp_signed(iVar6, 32))) != 0)) != 0)) != 0 else 21
			29:
				_pc = 24 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x2ad, 32))) != 0 else 28
			30:
				var _v10: int = f4022e0((((extraout_var) << 16) | ((m.u16(param_1)) & 0xffff)))
				sVar2 = _zp_signed(_v10, 16)
				_pc = 29
			31:
				_pc = 22 if (int(_zp_signed(iVar3, 32) == _zp_signed(iVar6, 32))) != 0 else 30
			32:
				var _v11: int = f56f690(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), iVar5)
				iVar3 = _zp_signed(_v11, 32)
				_pc = 31
			33:
				_pc = 32 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 21
			34:
				var _v12: int = f59dc50(param_1, _zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), iVar5)
				iVar3 = _zp_signed(_v12, 32)
				_pc = 33
			35:
				_pc = 34 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			36:
				local_8 = _zp_signed(0, 32)
				_pc = 35
			37:
				local_4 = _zp_signed(_zp_signed((-(1)), 32), 32)
				_pc = 36
			38:
				iVar5 = _zp_signed(0, 32)
				_pc = 37
			39:
				iVar6 = _zp_signed(_zp_signed((-(1)), 32), 32)
				_pc = 38
	return 0


func f5885a0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 15
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f577880(uVar1, uVar6, uVar5)
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int((int(_zp_signed(_zp_signed(uVar4, 16), 32) == _zp_signed(0x15, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			4:
				var _v1: int = f4025d0(uVar4)
				uVar4 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(_zp_signed(uVar4, 16), 32) != _zp_signed(0, 32))) != 0 else 1
			6:
				uVar4 = ((_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffffffff)
				_pc = 5
			7:
				uVar3 = (((((((m.u32((_params + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 6
			8:
				uVar6 = (((((((m.u32((_params + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				uVar5 = ((((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			11:
				uVar4 = ((0) & 0xffffffff)
				_pc = 10
			12:
				var _v2: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar2 = _zp_signed(_v2, 32)
				_pc = 11
			13:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 12
			15:
				uVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 14
	return 0


func f588640(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var iVar2: int = 0
	var in_EAX: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 16
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f576940(iVar2, uVar6)
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 9 if (int(_zp_signed(iVar5, 32) < _zp_signed(_zp_signed(((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) >> ((0xd) & 31)), 32)) & 0xffffffff), 32), 32))) != 0 else 2
			4:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 3
			5:
				uVar6 = (((((((uVar6) & 0xffffffff) | ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((((((((_zp_signed(m.u32((_params + 0)), 32)) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 8), 32) + _zp_signed(_zp_signed(_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) << ((4) & 31)), 32), 8), 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 4
			6:
				_pc = 1
			7:
				_pc = 6 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 5
			8:
				uVar4 = ((0) & 0xffffffff)
				_pc = 7
			9:
				var _v1: int = f583470(iVar2, iVar5, (_params + 0))
				iVar3 = _zp_signed(_v1, 32)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xe000, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 2
			11:
				iVar5 = _zp_signed(0, 32)
				_pc = 10
			12:
				uVar6 = ((0) & 0xffffffff)
				_pc = 11
			13:
				_pc = 12 if (int((int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xe000, 32)), 32), 32) == _zp_signed(0x6000, 32))) != 0)) != 0 else 1
			14:
				uVar4 = (((((_zp_signed((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((uVar1) & 0xffff))) & 0xffffffff)
				_pc = 13
			15:
				uVar1 = ((m.u16(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32) + _zp_signed(4, 32)), 32)) & 0xffffffff))) & 0xffff)
				_pc = 14
			16:
				iVar2 = _zp_signed(_zp_signed(m.u32((_params + 0)), 32), 32)
				_pc = 15
	return 0


func f5886c0(param_1: int, param_2: int) -> int:
	var _params: int = m.local(8)
	m.set_u32(_params + 0, param_1)
	m.set_u32(_params + 4, param_2)
	var puVar1: int = 0
	var uVar2: int = 0
	var in_EAX: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var extraout_var: int = 0
	var uVar5: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(m.u32((_params + 0))), ((((((((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff))) << 8) | ((m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0xff01) & 0xffffffff))) & 0xffffffff), 0xd)
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				return (((((uVar5) << 16) | ((0x7f) & 0xffff))) & 0xffffffff)
			4:
				uVar5 = ((extraout_var) & 0xffff)
				_pc = 3
			5:
				var _v1: int = f5adb10(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), (_params + 0), 1, 0x20, 0xe, (((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff))
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 3
			7:
				uVar5 = ((0) & 0xffff)
				_pc = 6
			8:
				var _v2: int = f56cb40(((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff), (_params + 0))
				iVar4 = _zp_signed(_v2, 32)
				_pc = 7
			9:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), (((((uVar2) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffff))
				_pc = 8
			10:
				var _v3: int = f56a030(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				uVar2 = ((_v3) & 0xff)
				_pc = 9
			11:
				uVar3 = (((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff)
				_pc = 10
			12:
				m.set_u32((_params + 0), ((m.u32((((puVar1 + (3) * 2)) & 0xffffffff))) & 0xffffffff))
				_pc = 11
			13:
				_pc = 12 if (int((int(((in_EAX) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16((puVar1 + (2) * 2)), 32) & _zp_signed(0xe000, 32)), 32), 32) == _zp_signed(0x4000, 32))) != 0)) != 0 else 1
			14:
				var _v4: int = f59dd90(m.u32((_params + 0)), m.u32((_params + 4)), 0)
				in_EAX = ((_v4) & 0xffffffff)
				_pc = 13
			15:
				_pc = 14 if (int(((in_EAX) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 1
			16:
				in_EAX = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x80, 32)), 32)) & 0xffffffff)
				_pc = 15
			17:
				_pc = 2 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x7f, 32))) != 0 else 16
			18:
				_pc = 17 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			19:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 18
	return 0


func f5887c0(param_1: int) -> int:
	var bVar1: int = 0
	var sVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 14
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((((param_1) & 0xffffffff)) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f578b60(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32), uVar4)
				param_1 = ((((_v0) & 0xffffffff)) & 0xffffffff)
				_pc = 1
			3:
				uVar4 = ((1) & 0xffffffff)
				_pc = 2
			4:
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x5a7, 32))) != 0 else 2
			6:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			7:
				var _v1: int = f578b60(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32), 2)
				uVar3 = ((_v1) & 0xffffffff)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x3f2, 32))) != 0 else 5
			9:
				_pc = 3 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x21b, 32))) != 0 else 8
			10:
				var _v2: int = f4022e0(m.u16(param_1))
				sVar2 = _zp_signed(_v2, 16)
				_pc = 9
			11:
				_pc = 1
			12:
				_pc = 11 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 10
			13:
				bVar1 = ((m.u8((((param_1 + (3) * 2)) & 0xffffffff))) & 0xff)
				_pc = 12
			14:
				uVar4 = ((0) & 0xffffffff)
				_pc = 13
	return 0


func f588830(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var puVar5: int = 0
	var _pc: int = 22
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) + _zp_signed(0x100, 32)), 32), 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 2
			4:
				var _v0: int = f575fe0(uVar4, puVar5, int(((_zp_signed((_zp_signed(m.u8((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) != ((uVar4) & 0xffffffff)))
				_pc = 3
			5:
				uVar4 = ((((((((((((m.u32(puVar5)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 4
			6:
				var _v1: int = f5700f0((((((uVar4) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), 0xe, (((((uVar4) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff))
				puVar5 = ((((_v1) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(_zp_signed((((((uVar4) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 8), 32) == _zp_signed(14, 32))) != 0 else 3
			8:
				var _v2: int = f5687d0(m.u16(((((((((((((uVar1) & 0xffffffff) + ((6) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((((_zp_signed((_zp_signed(m.u16((((((((uVar1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) >> ((0xd) & 31)), 32)) & 0xffffffff)) & 0xffffffff) - (((((((uVar4) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((_zp_signed((-(1)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)))
				uVar4 = ((_v2) & 0xffffffff)
				_pc = 7
			9:
				var _v3: int = f577950(uVar1, (((((m.u32((_params + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), ((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 3
			10:
				_pc = 9 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 3
			11:
				var _v4: int = f583470(uVar1, (((((uVar4) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), (_params + 0))
				iVar2 = _zp_signed(_v4, 32)
				_pc = 10
			12:
				_pc = 8 if (int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0 else 11
			13:
				_pc = 12 if (int((((((((uVar4) & 0xffffffff) & ((0xff00) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) < ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((((((((uVar1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(0xe000, 32)), 32), 32) >> ((5) & 31)), 32)) & 0xffffffff))) != 0 else 1
			14:
				uVar4 = ((((m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 13
			15:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((((uVar4) & 0xffff)) & 0xffff))
				_pc = 13
			16:
				uVar4 = (((((((m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffffffff) & ((0xffff00ff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				return ((0) & 0xffffffff)
			18:
				_pc = 17 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 16
			19:
				_pc = 14 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 18
			20:
				var _v6: int = int((int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((uVar1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0)
				if _v6 != 0:
					var _v5: int = f570bb0(_zp_signed((_zp_signed(m.u8((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
					iVar3 = _zp_signed(_v5, 32)
					_v6 = int((int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0)
				_pc = 19 if (_v6) != 0 else 1
			21:
				var _v7: int = f5709d0(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x60f)
				iVar2 = _zp_signed(_v7, 32)
				_pc = 20
			22:
				uVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 21
	return 0


func f5889a0(param_1: int) -> int:
	var in_EAX: int = 0
	var uVar1: int = 0
	var extraout_var: int = 0
	var iVar2: int = 0
	var uVar4: int = 0
	var uVar3: int = 0
	var extraout_var_00: int = 0
	var extraout_var_01: int = 0
	var _pc: int = 27
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((uVar4) << 16) | ((0x7f) & 0xffff))) & 0xffffffff)
			2:
				return (((((((uVar1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			3:
				var _v0: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(1, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0x1f) & 0xff)), uVar3, _zp_signed(m.u32(0xa5504c), 16), 0)
				uVar1 = ((_v0) & 0xffffffff)
				_pc = 2
			4:
				var _v1: int = f4022e0(uVar3)
				uVar3 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				var _v2: int = f570230(m.u32(0xa55044), m.u32(0xa55048), m.u32(0xa5504c))
				uVar3 = ((_v2) & 0xffffffff)
				_pc = 4
			6:
				var _v3: int = f578430(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), uVar3)
				_pc = 5
			7:
				var _v4: int = f570230(m.u32(0xa55044), m.u32(0xa55048), m.u32(0xa5504c))
				uVar3 = ((_v4) & 0xffffffff)
				_pc = 6
			8:
				var _v5: int = f5b9170(((((((((uVar4) << 16) | ((_zp_signed((_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), (((extraout_var_00) << 16) | ((((m.u32(0xa55044)) & 0xffff)) & 0xffff)), (((((((((((((((m.u32(0xa5504c)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | (((((uVar4) << 16) | ((((((m.u32(0xa55048)) & 0xff)) & 0xffff)) & 0xffff))) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 7
			9:
				uVar4 = (((((((((((iVar2) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			11:
				uVar4 = ((0) & 0xffff)
				_pc = 10
			12:
				var _v6: int = f5aa480()
				iVar2 = _zp_signed(_v6, 32)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			14:
				uVar4 = ((0) & 0xffff)
				_pc = 13
			15:
				var _v7: int = f5aa440(0x10000)
				iVar2 = _zp_signed(_v7, 32)
				_pc = 14
			16:
				uVar4 = ((extraout_var) & 0xffff)
				_pc = 1
			17:
				var _v8: int = f5bf800(0xf4)
				_pc = 16
			18:
				return (((((((uVar1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			19:
				_pc = 18 if (int(((uVar1) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 17
			20:
				uVar1 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x80, 32)), 32)) & 0xffffffff)
				_pc = 19
			21:
				_pc = 15 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x7f, 32))) != 0 else 20
			22:
				return ((0) & 0xffffffff)
			23:
				_pc = 22 if (int(_zp_signed(_zp_signed(m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))), 32), 32) - _zp_signed(1, 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 8), 32) == _zp_signed(0, 32))) != 0 else 21
			24:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			25:
				_pc = 24 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)), 32) ^ _zp_signed(((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff), 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 23
			26:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			27:
				_pc = 26 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 25
	return 0


func f588ae0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var puVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var _pc: int = 12
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f574810(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(puVar1), m.u32((_params + 0)), 0xc)
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0 and (int((((((((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)) != 0 else 1
			4:
				uVar4 = ((((((((((((uVar5) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 3
			5:
				uVar3 = (((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 4
			6:
				uVar5 = ((((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			8:
				uVar4 = ((0) & 0xffffffff)
				_pc = 7
			9:
				var _v1: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar2 = _zp_signed(_v1, 32)
				_pc = 8
			10:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			11:
				_pc = 10 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 9
			12:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 11
	return 0


func f588b70(param_1: int, param_2: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var _pc: int = 46
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0) & 0xffffffff)
			3:
				return ((0x7e) & 0xffffffff)
			4:
				m.set_u16(0xa57804, ((_zp_signed((_zp_signed(m.u16(0xa57804), 32) & _zp_signed(0xfffe, 32)), 32)) & 0xffff))
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(0xa57804), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 3
			6:
				_pc = 5 if (int(_zp_signed(iVar1, 32) == _zp_signed(0, 32))) != 0 else 2
			7:
				var _v0: int = f59df40(int(_zp_signed(_zp_signed((_zp_signed(m.u8(0xa57804), 32) & _zp_signed(0x78, 32)), 32), 32) == _zp_signed(0, 32)), 0, 0)
				iVar1 = _zp_signed(_v0, 32)
				_pc = 6
			8:
				return ((0x7e) & 0xffffffff)
			9:
				_pc = 8 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(0xa57804), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 7
			10:
				var _v1: int = f5bf4b0()
				_pc = 9
			11:
				m.set_u16(0xa57808, ((_zp_signed((_zp_signed(m.u16(0xa57808), 32) & _zp_signed(0xff00, 32)), 32)) & 0xffff))
				_pc = 10
			12:
				var _v2: int = f5b8910()
				_pc = 9
			13:
				_pc = 11 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(0xa57804), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 12
			14:
				return ((0x80) & 0xffffffff)
			15:
				var _v3: int = f5bf4b0()
				_pc = 14
			16:
				_pc = 15 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 13
			17:
				m.set_u16(0xa57804, ((_zp_signed((_zp_signed(m.u16(0xa57804), 32) & _zp_signed(0xfffe, 32)), 32)) & 0xffff))
				_pc = 16
			18:
				var _v4: int = f5b88a0()
				_pc = 13
			19:
				m.set_u16(0xa57804, ((_zp_signed((_zp_signed(m.u16(0xa57804), 32) ^ _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(int(_zp_signed(m.u16(0xa57806), 32) != _zp_signed(0, 32)), 32) ^ _zp_signed(m.u8(0xa57804), 32)), 32), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 18
			20:
				var _v5: int = f5aab90(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), uVar2)
				m.set_u16(0xa57806, ((_v5) & 0xffff))
				_pc = 19
			21:
				var _v6: int = f5beeb0()
				uVar2 = ((_v6) & 0xffffffff)
				_pc = 20
			22:
				_pc = 21 if (int((int(((m.u32(0xa55044)) & 0xffffffff) == ((_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) != 0 and (int(((m.u32(0xa55048)) & 0xffffffff) == ((0xb) & 0xffffffff))) != 0)) != 0 else 18
			23:
				m.set_u16(0xa57808, ((_zp_signed((_zp_signed(m.u16(0xa57808), 32) & _zp_signed(0xff00, 32)), 32)) & 0xffff))
				_pc = 22
			24:
				var _v7: int = f5bf4b0()
				_pc = 23
			25:
				_pc = 24 if (int((int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 or (int(_zp_signed(_zp_signed((_zp_signed(m.u16(0xa57804), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 18
			26:
				var _v8: int = f5b88d0()
				iVar1 = _zp_signed(_v8, 32)
				_pc = 25
			27:
				_pc = 17 if (int(_zp_signed(iVar1, 32) == _zp_signed(0, 32))) != 0 else 26
			28:
				var _v9: int = f5beed0()
				iVar1 = _zp_signed(_v9, 32)
				_pc = 27
			29:
				_pc = 28 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(0xa57804), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 7
			30:
				return ((0) & 0xffffffff)
			31:
				return ((0x7e) & 0xffffffff)
			32:
				m.set_u16(0xa57808, ((_zp_signed((_zp_signed(m.u16(0xa57808), 32) & _zp_signed(0xff00, 32)), 32)) & 0xffff))
				_pc = 31
			33:
				m.set_u16(0xa57804, ((_zp_signed((_zp_signed(m.u16(0xa57804), 32) & _zp_signed(0xfffc, 32)), 32)) & 0xffff))
				_pc = 32
			34:
				var _v10: int = f5bf800(0x27)
				_pc = 33
			35:
				_pc = 34 if (int(_zp_signed(iVar1, 32) == _zp_signed(2, 32))) != 0 else 30
			36:
				var _v11: int = f580870(param_1, param_2, 0)
				iVar1 = _zp_signed(_v11, 32)
				_pc = 35
			37:
				return ((0) & 0xffffffff)
			38:
				_pc = 37 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 36
			39:
				_pc = 38 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(126, 32))) != 0 else 29
			40:
				_pc = 39 if (int(_zp_signed(m.u16((param_1 + (3) * 2)), 32) != _zp_signed(0, 32))) != 0 else 1
			41:
				return ((0) & 0xffffffff)
			42:
				_pc = 41 if (int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 40
			43:
				return ((0) & 0xffffffff)
			44:
				_pc = 43 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) != _zp_signed(m.u16(param_1), 32))) != 0 else 42
			45:
				return ((0) & 0xffffffff)
			46:
				_pc = 45 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 44
	return 0


func f588d90(param_1: int, param_2: int) -> int:
	var cVar1: int = 0
	var bVar2: int = 0
	var in_EAX: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var _pc: int = 53
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				_pc = 34
			3:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			4:
				var _v0: int = f576940(param_1, _zp_signed((_zp_signed(_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32)) & 0xff), 32) & _zp_signed(0x1f, 32)), 32), 32) + _zp_signed(cVar1, 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(0x1f, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(0x10, 32) - _zp_signed(cVar1, 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32), 32)), 32))
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 3
			5:
				cVar1 = _zp_signed(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), 32) << ((4) & 31)), 32), 8), 8)
				_pc = 4
			6:
				m.set_u16((param_2 + (2) * 2), ((_zp_signed((_zp_signed(m.u16((param_2 + (2) * 2)), 32) | _zp_signed(4, 32)), 32)) & 0xffff))
				_pc = 5
			7:
				var _v1: int = int((int(_zp_signed(_zp_signed(in_EAX, 16), 32) == _zp_signed(0x150, 32))) != 0)
				if _v1 != 0:
					bVar2 = ((_zp_signed((_zp_signed(m.u8((((param_2 + (1) * 2)) & 0xffffffff)), 32) ^ _zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32)), 32)) & 0xff)
					in_EAX = (((((_zp_signed((((((in_EAX) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((bVar2) & 0xff))) & 0xffffffff)
					_v1 = int((int(_zp_signed(_zp_signed((_zp_signed(bVar2, 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)
				_pc = 6 if (_v1) != 0 else 1
			8:
				var _v2: int = f4022e0((((extraout_var_00) << 16) | ((m.u16(param_2)) & 0xffff)))
				in_EAX = ((_v2) & 0xffffffff)
				_pc = 7
			9:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			10:
				var _v3: int = f5b9170(((((((((((in_EAX) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb1) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar2, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 1, 0)
				uVar3 = ((_v3) & 0xffffffff)
				_pc = 9
			11:
				m.set_u16((param_2 + (2) * 2), ((_zp_signed((_zp_signed(m.u16((param_2 + (2) * 2)), 32) | _zp_signed(4, 32)), 32)) & 0xffff))
				_pc = 10
			12:
				_pc = 11 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) ^ _zp_signed(bVar2, 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 1
			13:
				bVar2 = ((((m.u16((param_2 + (1) * 2))) & 0xff)) & 0xff)
				_pc = 12
			14:
				in_EAX = (((((_zp_signed((((((in_EAX) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_2 + (1) * 2))) & 0xffff))) & 0xffffffff)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(_zp_signed(in_EAX, 16), 32) == _zp_signed(0x3f0, 32))) != 0 else 1
			16:
				var _v4: int = f4022e0(m.u16(param_2))
				in_EAX = ((_v4) & 0xffffffff)
				_pc = 15
			17:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			18:
				var _v5: int = f576940(param_1, _zp_signed((_zp_signed(0x1f, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(_zp_signed((-(0x10)), 32), 32)), 32), 32) + _zp_signed(0x10, 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32))
				uVar3 = ((_v5) & 0xffffffff)
				_pc = 17
			19:
				m.set_u16((param_2 + (2) * 2), ((_zp_signed((_zp_signed(m.u16((param_2 + (2) * 2)), 32) | _zp_signed(4, 32)), 32)) & 0xffff))
				_pc = 18
			20:
				var _v6: int = int((int(_zp_signed(_zp_signed(in_EAX, 16), 32) == _zp_signed(0x14f, 32))) != 0)
				if _v6 != 0:
					bVar2 = ((_zp_signed((_zp_signed(m.u8((((param_2 + (1) * 2)) & 0xffffffff)), 32) ^ _zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32)), 32)) & 0xff)
					in_EAX = (((((_zp_signed((((((in_EAX) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((bVar2) & 0xff))) & 0xffffffff)
					_v6 = int((int(_zp_signed(_zp_signed((_zp_signed(bVar2, 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)
				_pc = 19 if (_v6) != 0 else 1
			21:
				var _v7: int = f4022e0((((extraout_var_00) << 16) | ((m.u16(param_2)) & 0xffff)))
				in_EAX = ((_v7) & 0xffffffff)
				_pc = 20
			22:
				var _v8: int = uVar3
				_pc = 1
				if _v8 == 0x406: _pc = 2
				if _v8 == 0x405: _pc = 2
				if _v8 == 0x3fe: _pc = 8
				if _v8 == 0x3fd: _pc = 16
				if _v8 == 0x3fb: _pc = 21
			23:
				uVar4 = (((((((((in_EAX) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 22
			24:
				in_EAX = (((((((uVar3) & 0xffffffff) - ((0x3fb) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 23
			25:
				_pc = 1
			26:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			27:
				var _v9: int = f576940(param_1, _zp_signed((_zp_signed(0x7e0, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(_zp_signed((-(0x10)), 32), 32)), 32), 32) + _zp_signed(0x10, 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32))
				uVar3 = ((_v9) & 0xffffffff)
				_pc = 26
			28:
				m.set_u16((param_2 + (2) * 2), ((_zp_signed((_zp_signed(m.u16((param_2 + (2) * 2)), 32) | _zp_signed(4, 32)), 32)) & 0xffff))
				_pc = 27
			29:
				_pc = 28 if (int((int(_zp_signed(_zp_signed(in_EAX, 16), 32) == _zp_signed(0x29f, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_2 + (1) * 2)) & 0xffffffff)), 32) ^ _zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 25
			30:
				var _v10: int = f4022e0((((extraout_var) << 16) | ((m.u16(param_2)) & 0xffff)))
				in_EAX = ((_v10) & 0xffffffff)
				_pc = 29
			31:
				_pc = 30 if (int(((uVar3) & 0xffffffff) == ((0x426) & 0xffffffff))) != 0 else 24
			32:
				var _v11: int = f5778b0(param_1, _zp_signed((_zp_signed(m.u16((param_2 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_2 + (1) * 2))) & 0xffff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32))
				in_EAX = ((_v11) & 0xffffffff)
				_pc = 1
			33:
				m.set_u8((((param_2 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u8((((param_2 + (2) * 2)) & 0xffffffff)), 32) | _zp_signed(0xe, 32)), 32)) & 0xff))
				_pc = 32
			34:
				var _v12: int = f5b9170((((((((((((((uVar4) << 16) | ((m.u16((param_2 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb1) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_2 + (1) * 2))) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 1, 0)
				_pc = 33
			35:
				return ((((((((((((uVar3) & 0xffffffff) - ((0x5fb) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			36:
				_pc = 35 if (int((((((((uVar3) & 0xffffffff) - ((0x5fb) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 34
			37:
				uVar4 = ((0) & 0xffff)
				_pc = 36
			38:
				_pc = 1
			39:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			40:
				m.set_u8((((param_2 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u8((((param_2 + (2) * 2)) & 0xffffffff)), 32) | _zp_signed(0xe, 32)), 32)) & 0xff))
				_pc = 39
			41:
				_pc = 40 if (int(((uVar3) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 38
			42:
				in_EAX = ((0) & 0xffffffff)
				_pc = 41
			43:
				var _v13: int = f567620(m.u16(param_2), 0xffffffff)
				uVar3 = ((_v13) & 0xffffffff)
				_pc = 42
			44:
				_pc = 43 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + ((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32)) & 0xffffffff) + (((((((in_EAX) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) == _zp_signed(m.u16(param_1), 32))) != 0 else 38
			45:
				in_EAX = ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 44
			46:
				_pc = 45 if (int(((uVar3) & 0xffffffff) == ((0x5fa) & 0xffffffff))) != 0 else 37
			47:
				_pc = 46 if (int(((uVar3) & 0xffffffff) != ((0x5f5) & 0xffffffff))) != 0 else 34
			48:
				uVar4 = ((0) & 0xffff)
				_pc = 47
			49:
				_pc = 31 if (int(((uVar3) & 0xffffffff) < ((0x427) & 0xffffffff))) != 0 else 48
			50:
				uVar3 = (((((((uVar3) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 49
			51:
				var _v14: int = f4022e0(m.u16(param_1))
				uVar3 = ((_v14) & 0xffffffff)
				_pc = 50
			52:
				_pc = 1
			53:
				_pc = 52 if (int((int((int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 or (int(((param_2) & 0xffffffff) == ((((0x0) & 0xffffffff)) & 0xffffffff))) != 0)) != 0 or (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0)) != 0 else 51
	return 0


func f589030(param_1: int, param_2: int) -> int:
	var bVar1: int = 0
	var iVar2: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xff)
			1:
				return ((0) & 0xff)
			2:
				return ((0x7d) & 0xff)
			3:
				var _v0: int = f5bf800(0x29)
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((bVar1) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 2
			5:
				m.set_u32(0xa55c8a, (((((m.u32(0xa55c8c)) << 16) | (((((3) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffff))) & 0xffffffff))
				_pc = 4
			6:
				return ((0x7e) & 0xff)
			7:
				m.set_u16(0xa558b4, ((0) & 0xffff))
				_pc = 6
			8:
				return ((0x7e) & 0xff)
			9:
				var _v1: int = f5bf9a0(1, 0)
				_pc = 8
			10:
				var _v2: int = f5bf800(0x28)
				_pc = 9
			11:
				_pc = 10 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((bVar1) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 7
			12:
				var _v4: int = int((int(_zp_signed(_zp_signed((((((m.u32(0xa55c8a)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 8), 32) != _zp_signed(0, 32))) != 0)
				if _v4 != 0:
					var _v3: int = f580de0(param_1)
					iVar2 = _zp_signed(_v3, 32)
					_v4 = int((int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0)
				_pc = 11 if (_v4) != 0 else 1
			13:
				return ((_zp_signed((_zp_signed(_zp_signed((-(int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32)))), 32), 32) & _zp_signed(0x7d, 32)), 32)) & 0xff)
			14:
				return ((0x7f) & 0xff)
			15:
				m.set_u32(0xa55c8a, (((((m.u32(0xa55c8c)) << 16) | ((_zp_signed((_zp_signed(((((_zp_signed((~(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)))), 32)) & 0xff)) & 0xffff), 32) ^ _zp_signed(((((((((((((m.u32(0xa55c8a)) & 0xffffffff) & ((0xff00) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffff), 32)), 32)) & 0xffff))) & 0xffffffff))
				_pc = 14
			16:
				var _v5: int = f5bcdc0(bVar1, 1, 1, 0)
				_pc = 15
			17:
				var _v6: int = (((((m.u32(0xa55c8a)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)
				_pc = 1
				if _v6 == 0x80: _pc = 5
				if _v6 == 0x7f: _pc = 12
				if _v6 == 0x7e: _pc = 13
				if _v6 == 0x7d: _pc = 16
			18:
				_pc = 17 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			19:
				bVar1 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 18
	return 0


func f589160(param_1: int) -> int:
	var in_EAX: int = 0
	var uVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var _pc: int = 16
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				_pc = 11 if (int(_zp_signed(_zp_signed(uVar4, 32), 32) < _zp_signed(2, 32))) != 0 else 1
			3:
				uVar4 = (((((((uVar4) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 2
			4:
				_pc = 9 if (int(_zp_signed(iVar5, 32) < _zp_signed(5, 32))) != 0 else 3
			5:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 4
			6:
				var _v0: int = f577c60(param_1, uVar1, iVar5)
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 5
			8:
				uVar3 = ((0) & 0xffffffff)
				_pc = 7
			9:
				var _v1: int = f56db30(uVar1, iVar5, 0x3f0)
				iVar2 = _zp_signed(_v1, 32)
				_pc = 8
			10:
				iVar5 = _zp_signed(0, 32)
				_pc = 9
			11:
				uVar1 = (((((((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) ^ ((uVar4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 10
			12:
				uVar4 = ((0) & 0xffffffff)
				_pc = 11
			13:
				return ((0) & 0xffffffff)
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) != _zp_signed(m.u16(param_1), 32))) != 0 else 12
			15:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			16:
				_pc = 15 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 14
	return 0


func f589200(param_1: int) -> int:
	var _stack: int = m.local(4)
	var uVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var extraout_var: int = 0
	var uVar4: int = 0
	var _pc: int = 15
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(uVar3, m.u16(param_1), (((((m.u32((_stack + 0))) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(3, 32)), 32))
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f574900(uVar3, uVar4, uVar1, 1)
				_pc = 2
			4:
				var _v2: int = f4022e0((((extraout_var) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar1 = ((_v2) & 0xffff)
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			6:
				in_EAX = ((0) & 0xffffffff)
				_pc = 5
			7:
				var _v3: int = f583510(param_1, uVar3, uVar4)
				iVar2 = _zp_signed(_v3, 32)
				_pc = 6
			8:
				var _v4: int = int((int(((uVar3) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) != 0)
				if _v4 != 0:
					in_EAX = ((0) & 0xffffffff)
					_v4 = int((int((((((((m.u32((0xa55d74 + (((((((((((uVar4) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((m.u32((_stack + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)
				_pc = 7 if (_v4) != 0 else 1
			9:
				in_EAX = ((m.u32((_stack + 0))) & 0xffffffff)
				_pc = 8
			10:
				uVar3 = (((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				uVar4 = ((((((((((((m.u32((_stack + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 10
			12:
				_pc = 11 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			13:
				in_EAX = ((0) & 0xffffffff)
				_pc = 12
			14:
				var _v5: int = f583470(param_1, 0, (_stack + 0))
				iVar2 = _zp_signed(_v5, 32)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f5892d0(param_1: int) -> int:
	var iVar1: int = 0
	var in_ECX: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var _pc: int = 16
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((100) & 0xffffffff)
			2:
				var _v0: int = f5bf800(0x15)
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 1
			4:
				return ((100) & 0xffffffff)
			5:
				var _v1: int = f5b9170((((((((((((((extraout_var_00) << 16) | ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0x1f) & 0xffffffff))) & 0xffffffff), 0x40a, m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 0)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 3
			7:
				var _v2: int = f576050(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x40a)
				iVar1 = _zp_signed(_v2, 32)
				_pc = 6
			8:
				return ((100) & 0xffffffff)
			9:
				var _v3: int = f5b9170((((((((((((((extraout_var) << 16) | ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0x1f) & 0xffffffff))) & 0xffffffff), 0x3eb, m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 0)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 7
			11:
				var _v4: int = f576050(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x3eb)
				iVar1 = _zp_signed(_v4, 32)
				_pc = 10
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 11
			14:
				return ((1) & 0xffffffff)
			15:
				var _v5: int = f5b9170(((((((((_zp_signed((((((((in_ECX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zp_signed((_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 14
			16:
				_pc = 15 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(100, 32))) != 0 else 13
	return 0


func f589400(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var _pc: int = 10
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5751e0(uVar1, (((((m.u32((_params + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar3, 0, 0)
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2) + (((((((((((m.u32((_params + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			4:
				in_EAX = ((0) & 0xffffffff)
				_pc = 3
			5:
				uVar3 = ((((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			7:
				in_EAX = ((0) & 0xffffffff)
				_pc = 6
			8:
				var _v1: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar2 = _zp_signed(_v1, 32)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			10:
				uVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 9
	return 0


func f589480(param_1: int) -> int:
	var _stack: int = m.local(92)
	var iVar1: int = 0
	var uVar2: int = 0
	var sVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var piVar6: int = 0
	var iVar7: int = 0
	var puVar8: int = 0
	var _pc: int = 40
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((((param_1) & 0xffffffff)) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				return (((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			3:
				_pc = 14 if (int(_zp_signed(_zp_signed(m.u32((_stack + 0)), 32), 32) < _zp_signed(2, 32))) != 0 else 2
			4:
				m.set_u32((_stack + 0), (((((((m.u32((_stack + 0))) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 3
			5:
				_pc = 9 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar5, 32))) != 0 else 4
			6:
				piVar6 = (((piVar6 + (_zp_signed((-(1)), 32)) * 4)) & 0xffffffff)
				_pc = 5
			7:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 32)
				_pc = 6
			8:
				var _v0: int = f575160(uVar4, iVar5, 0)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(_zp_signed(m.u32(piVar6), 32), 32) != _zp_signed(0, 32))) != 0 else 7
			10:
				piVar6 = ((((_stack + 44) + ((((((uVar4) & 0xffffffff) * ((0xb) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)
				_pc = 9
			11:
				iVar5 = _zp_signed(10, 32)
				_pc = 10
			12:
				uVar4 = ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 11
			13:
				uVar4 = ((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 11
			14:
				_pc = 12 if (int(((m.u32((_stack + 0))) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 13
			15:
				m.set_u32((_stack + 0), ((0) & 0xffffffff))
				_pc = 14
			16:
				var _v1: int = f5b9170(((((((((_zp_signed((((((m.u32((_stack + 0))) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0xf1) & 0xffffffff))) & 0xffffffff), 0x3c, 0, 0)
				_pc = 15
			17:
				_pc = 38 if (int(_zp_signed(_zp_signed(m.u32((_stack + 0)), 32), 32) < _zp_signed(2, 32))) != 0 else 16
			18:
				m.set_u32((_stack + 0), (((((((m.u32((_stack + 0))) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 17
			19:
				_pc = 29 if (int(_zp_signed(iVar7, 32) < _zp_signed(0x5a1, 32))) != 0 else 18
			20:
				puVar8 = (((puVar8 + (1) * 4)) & 0xffffffff)
				_pc = 19
			21:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 20
			22:
				iVar7 = _zp_signed(_zp_signed((_zp_signed(iVar7, 32) + _zp_signed(0x90, 32)), 32), 32)
				_pc = 21
			23:
				var _v2: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar4) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xf1) & 0xff)), 0xf, 0, 0)
				_pc = 22
			24:
				var _v3: int = f575160(uVar4, iVar5, 1)
				_pc = 23
			25:
				m.set_u32(puVar8, ((1) & 0xffffffff))
				_pc = 24
			26:
				var _v4: int = int((int((int(_zp_signed(sVar3, 32) != _zp_signed(0x49f, 32))) != 0 or (int(((uVar4) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) != 0)) != 0)
				if _v4 != 0:
					iVar1 = _zp_signed((((((iVar7) & 0xffffffff) + ((((((((((((uVar4) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), 32)
					_v4 = int((int((((((((m.u32(((_zp_signed((_zp_signed(_zp_signed(0xa55d74, 32), 32) + _zp_signed(iVar1, 32)), 32)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)
				_pc = 25 if (int((_v4) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55d7a, 32), 32) + _zp_signed(iVar1, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 22
			27:
				var _v5: int = f4022e0(uVar2)
				sVar3 = _zp_signed(_v5, 16)
				_pc = 26
			28:
				m.set_u32(puVar8, ((0) & 0xffffffff))
				_pc = 27
			29:
				uVar2 = ((m.u16(param_1)) & 0xffff)
				_pc = 28
			30:
				puVar8 = ((((_stack + 4) + ((((((uVar4) & 0xffffffff) * ((0xb) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)
				_pc = 29
			31:
				iVar7 = _zp_signed(0, 32)
				_pc = 30
			32:
				uVar4 = ((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 31
			33:
				iVar5 = _zp_signed(0, 32)
				_pc = 32
			34:
				puVar8 = ((((_stack + 4) + ((((((uVar4) & 0xffffffff) * ((0xb) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)
				_pc = 29
			35:
				iVar7 = _zp_signed(0, 32)
				_pc = 34
			36:
				uVar4 = ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 35
			37:
				iVar5 = _zp_signed(0, 32)
				_pc = 36
			38:
				_pc = 33 if (int(((m.u32((_stack + 0))) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 37
			39:
				m.set_u32((_stack + 0), ((0) & 0xffffffff))
				_pc = 38
			40:
				_pc = 39 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f589610(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var in_EAX: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var _pc: int = 25
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				var _v0: int = f5bf800(0x30)
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 2
			5:
				var _v1: int = f5797c0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar2, 0)
				_pc = 4
			6:
				var _v2: int = f4022e0((((extraout_var) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v2) & 0xffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			8:
				var _v3: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar4, 0)
				iVar3 = _zp_signed(_v3, 32)
				_pc = 7
			9:
				var _v4: int = f4022e0(m.u16(param_1))
				uVar4 = ((_v4) & 0xffffffff)
				_pc = 8
			10:
				var _v6: int = int((int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0)
				if _v6 != 0:
					var _v5: int = f56a000(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
					iVar3 = _zp_signed(_v5, 32)
					_v6 = int((int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0)
				_pc = 9 if (_v6) != 0 else 1
			11:
				var _v7: int = f570b40(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32))
				iVar3 = _zp_signed(_v7, 32)
				_pc = 10
			12:
				return ((0x7e) & 0xffffffff)
			13:
				var _v8: int = f40c940(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 6, uVar2, 0)
				_pc = 12
			14:
				var _v9: int = f4022e0((((uVar2) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v9) & 0xffff)
				_pc = 13
			15:
				return ((0x7d) & 0xffffffff)
			16:
				var _v10: int = f40cab0()
				var _v11: int = f5adb10(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _v10, 1, 0, 0xd, _zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32))
				_pc = 15
			17:
				var _v12: int = f5b9170((((((((((((((uVar2) << 16) | ((uVar1) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 1
			18:
				var _v13: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v13 == 0x80: _pc = 11
				if _v13 == 0x7f: _pc = 14
				if _v13 == 0x7e: _pc = 16
				if _v13 == 0x7c: _pc = 17
			19:
				return ((0) & 0xffffffff)
			20:
				var _v14: int = f5bf800(0xa2)
				_pc = 19
			21:
				_pc = 20 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 1
			22:
				var _v15: int = f579790(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), m.u16(param_1), 3)
				_pc = 21
			23:
				_pc = 18 if (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0x3000, 32)), 32), 32) == _zp_signed(0x2000, 32))) != 0 else 22
			24:
				uVar2 = (((((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 23
			25:
				uVar1 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 24
	return 0


func f589860(param_1: int) -> int:
	var iVar1: int = 0
	var in_EAX: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var puVar4: int = 0
	var iVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 22
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((param_1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				_pc = 18 if (int(_zp_signed(_zp_signed(param_1, 32), 32) < _zp_signed(2, 32))) != 0 else 1
			3:
				param_1 = (((((((param_1) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 2
			4:
				_pc = 13 if (int(_zp_signed(iVar5, 32) < _zp_signed(5, 32))) != 0 else 3
			5:
				puVar4 = (((puVar4 + (0x48) * 2)) & 0xffffffff)
				_pc = 4
			6:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 5
			7:
				var _v0: int = f579990(uVar6, iVar5, 0x11, 1)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 6
			9:
				var _v1: int = f5751e0(iVar1, uVar6, iVar5, uVar2, 1)
				iVar3 = _zp_signed(_v1, 32)
				_pc = 8
			10:
				uVar2 = ((0) & 0xffffffff)
				_pc = 9
			11:
				uVar2 = ((1) & 0xffffffff)
				_pc = 9
			12:
				_pc = 10 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u16(puVar4), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0 or (int(_zp_signed(_zp_signed((_zp_signed(m.u16(puVar4), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 11
			13:
				_pc = 12 if (int((((((((m.u32((((puVar4 + (_zp_signed((-(3)), 32)) * 2)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 6
			14:
				puVar4 = (((0xa55d7a + (((((((((((uVar6) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)
				_pc = 13
			15:
				iVar5 = _zp_signed(0, 32)
				_pc = 14
			16:
				uVar6 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 15
			17:
				uVar6 = ((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 15
			18:
				_pc = 16 if (int(((param_1) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 17
			19:
				param_1 = ((0) & 0xffffffff)
				_pc = 18
			20:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			21:
				_pc = 20 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 19
			22:
				iVar1 = _zp_signed(param_1, 32)
				_pc = 21
	return 0


func f5899a0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var puVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 13
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u8((((puVar1 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(((m.u16((puVar1 + (2) * 2))) & 0xff), 32) | _zp_signed(8, 32)), 32)) & 0xff))
				_pc = 1
			3:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			4:
				var _v0: int = f574990(uVar4, ((((((((_zp_signed((_zp_signed(((m.u16((puVar1 + (1) * 2))) & 0xff), 32) >> ((1) & 31)), 32)) << 8) | ((_zp_signed(m.u16((puVar1 + (1) * 2)), 8)) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), (((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff))
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 3
			5:
				_pc = 4 if (int((int((((((((m.u32((0xa55d74 + ((((((((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + (((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 2
			6:
				_pc = 5 if (int((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((uVar4) & 0xffffffff))) != 0 else 2
			7:
				uVar4 = ((_zp_signed((_zp_signed(m.u16((puVar1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 6
			8:
				uVar3 = ((((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			10:
				var _v1: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar2 = _zp_signed(_v1, 32)
				_pc = 9
			11:
				return ((0) & 0xffffffff)
			12:
				_pc = 11 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) != _zp_signed(m.u16(m.u32((_params + 0))), 32))) != 0 else 10
			13:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 12
	return 0


func f589a90(param_1: int) -> int:
	var bVar1: int = 0
	var bVar2: int = 0
	var _pc: int = 12
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f575970(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), m.u16(0xa57822), 1)
				_pc = 1
			3:
				return ((0x7f) & 0xffffffff)
			4:
				var _v1: int = f5bcec0(bVar1)
				_pc = 3
			5:
				return ((0) & 0xffffffff)
			6:
				var _v2: int = f5bcdc0(bVar2, 1, 0, 0)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(bVar2, 32) == _zp_signed(bVar1, 32))) != 0 else 4
			8:
				bVar1 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			10:
				_pc = 2 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 9
			11:
				_pc = 10 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			12:
				bVar2 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 11
	return 0


func f589b10(param_1: int) -> int:
	var bVar1: int = 0
	var _pc: int = 10
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7e) & 0xffffffff)
			2:
				var _v0: int = f5bcdc0(bVar1, 1, 0, 1)
				_pc = 1
			3:
				return ((0x7f) & 0xffffffff)
			4:
				var _v1: int = f5bce50(bVar1, 1, 1)
				_pc = 3
			5:
				return ((0) & 0xffffffff)
			6:
				_pc = 5 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 4
			7:
				_pc = 6 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(127, 32))) != 0 else 2
			8:
				return ((0) & 0xffffffff)
			9:
				_pc = 8 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 7
			10:
				bVar1 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 9
	return 0


func f589b70(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var _pc: int = 12
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f574f40(uVar1, (((((m.u32((_params + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar3, 0)
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2) + (((((((((((m.u32((_params + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 1
			4:
				in_EAX = ((0) & 0xffffffff)
				_pc = 3
			5:
				uVar3 = ((((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			7:
				in_EAX = ((0) & 0xffffffff)
				_pc = 6
			8:
				var _v1: int = f583470(uVar1, 0, (_params + 0))
				iVar2 = _zp_signed(_v1, 32)
				_pc = 7
			9:
				_pc = 8 if (int(((in_EAX) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 1
			10:
				var _v2: int = f5699c0(0x47f)
				in_EAX = ((_v2) & 0xffffffff)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			12:
				uVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 11
	return 0


func f589c00(param_1: int, param_2: int) -> int:
	var _params: int = m.local(8)
	m.set_u32(_params + 0, param_1)
	m.set_u32(_params + 4, param_2)
	var uVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var _pc: int = 8
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(m.u32((_params + 4)), 32), 32) + _zp_signed(6, 32)), 32)) & 0xffffffff), ((m.u16((((((((uVar1) & 0xffffffff) + ((6) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffff))
				_pc = 1
			3:
				in_EAX = ((0) & 0xffffffff)
				_pc = 2
			4:
				var _v0: int = int((int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0)
				if _v0 != 0:
					in_EAX = ((((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
					_v0 = int((int((((((((m.u32((0xa55d74 + (((((((((((in_EAX) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((m.u32((_params + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)
				_pc = 3 if (_v0) != 0 else 1
			5:
				in_EAX = ((0) & 0xffffffff)
				_pc = 4
			6:
				var _v1: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar2 = _zp_signed(_v1, 32)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			8:
				uVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 7
	return 0


func f589c70(param_1: int, param_2: int) -> int:
	var _stack: int = m.local(8)
	var uVar1: int = 0
	var sVar2: int = 0
	var in_EAX: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var _pc: int = 31
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f574ac0(m.u32((_stack + 0)), m.u32((_stack + 4)))
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 1
			4:
				return (((((((param_1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			5:
				m.set_u16(((_zp_signed((_zp_signed(param_2, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff), ((m.u16((((((((param_1) & 0xffffffff) + ((8) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffff))
				_pc = 4
			6:
				var _v1: int = int((int(((uVar7) & 0xffffffff) == (((((((in_EAX) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) != 0)
				if _v1 != 0:
					in_EAX = ((((((((((((in_EAX) & 0xffffffff) & ((0x3e) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff)
					_v1 = int((int(((uVar5) & 0xffffffff) == ((in_EAX) & 0xffffffff))) != 0)
				_pc = 5 if (_v1) != 0 else 3
			7:
				in_EAX = ((((m.u16(((_zp_signed((_zp_signed(param_2, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(sVar2, 32) == _zp_signed(_zp_signed((-(1)), 32), 32))) != 0 else 2
			9:
				var _v2: int = f56fb40(uVar7, uVar5)
				sVar2 = _zp_signed(_v2, 16)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55e00 + ((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + (((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 2
			11:
				_pc = 10 if (int(((in_EAX) & 0xffffffff) != ((m.u32((_stack + 4))) & 0xffffffff))) != 0 else 1
			12:
				in_EAX = (((((((uVar4) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 11
			13:
				var _v3: int = f56fb40(uVar7, uVar5)
				uVar4 = ((_v3) & 0xffffffff)
				_pc = 12
			14:
				_pc = 13 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			15:
				in_EAX = ((0) & 0xffffffff)
				_pc = 14
			16:
				var _v4: int = f56fc50(uVar7, uVar5, uVar6, (((((uVar4) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				iVar3 = _zp_signed(_v4, 32)
				_pc = 15
			17:
				_pc = 16 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			18:
				in_EAX = ((0) & 0xffffffff)
				_pc = 17
			19:
				var _v5: int = f57b3b0(param_1, m.u32((_stack + 0)))
				iVar3 = _zp_signed(_v5, 32)
				_pc = 18
			20:
				uVar6 = (((((((m.u32((_stack + 4))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 19
			21:
				uVar7 = (((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 20
			22:
				uVar4 = (((((((m.u32((_stack + 4))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff)
				_pc = 21
			23:
				uVar5 = ((((((((((((m.u32((_stack + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 22
			24:
				_pc = 23 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			25:
				in_EAX = ((0) & 0xffffffff)
				_pc = 24
			26:
				uVar1 = ((m.u32((_stack + 0))) & 0xffffffff)
				_pc = 25
			27:
				var _v6: int = f583470(param_1, 1, (_stack + 4))
				iVar3 = _zp_signed(_v6, 32)
				_pc = 26
			28:
				_pc = 27 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			29:
				in_EAX = ((0) & 0xffffffff)
				_pc = 28
			30:
				var _v7: int = f583470(param_1, 0, (_stack + 0))
				iVar3 = _zp_signed(_v7, 32)
				_pc = 29
			31:
				_pc = 30 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f589db0(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var bVar3: int = 0
	var puVar4: int = 0
	var bVar5: int = 0
	var _pc: int = 18
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7f) & 0xffffffff)
			2:
				var _v0: int = f5bcec0(bVar3)
				_pc = 1
			3:
				return ((0x7f) & 0xffffffff)
			4:
				var _v1: int = f5bcee0(bVar3, m.u16(param_1))
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(bVar5, 32) == _zp_signed(bVar3, 32))) != 0 else 2
			6:
				bVar3 = ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 5
			7:
				return ((0) & 0xffffffff)
			8:
				_pc = 7 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 6
			9:
				return ((100) & 0xffffffff)
			10:
				var _v2: int = f5b9170((((((((((((((-(((int(((((((((((((uVar1) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 9
			11:
				var _v3: int = f5758a0(bVar5, uVar2, 1)
				_pc = 10
			12:
				uVar1 = ((m.u32(puVar4)) & 0xffffffff)
				_pc = 11
			13:
				var _v4: int = f5700f0(bVar5, 0xb, m.u16(0xa57822))
				puVar4 = ((((_v4) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			14:
				_pc = 13 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 8
			15:
				return ((0) & 0xffffffff)
			16:
				_pc = 15 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 14
			17:
				bVar5 = ((_zp_signed((_zp_signed(m.u8((((param_1 + (3) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 16
			18:
				uVar2 = ((m.u16(0xa57822)) & 0xffff)
				_pc = 17
	return 0


func f589eb0(param_1: int, param_2: int) -> int:
	var _stack: int = m.local(268)
	var bVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var puVar6: int = 0
	var extraout_var: int = 0
	var puVar7: int = 0
	var _pc: int = 39
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				var _v0: int = f5bf800(0x2b)
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 2
			5:
				_pc = 4 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			6:
				var _v1: int = f581600(param_1)
				iVar4 = _zp_signed(_v1, 32)
				_pc = 5
			7:
				return ((0x7e) & 0xffffffff)
			8:
				var _v2: int = f40c940(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0xb, uVar3, 0)
				_pc = 7
			9:
				var _v3: int = f4022e0(m.u16(param_1))
				uVar3 = ((_v3) & 0xffff)
				_pc = 8
			10:
				return ((0x7d) & 0xffffffff)
			11:
				var _v4: int = f5792a0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 10
			12:
				return ((0x7c) & 0xffffffff)
			13:
				var _v5: int = f5bcfe0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32), 32)), 32), m.u16(param_1), (_stack + 0), 5)
				_pc = 12
			14:
				_pc = 19 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 13
			15:
				iVar4 = _zp_signed(_zp_signed((_zp_signed(iVar4, 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 32)
				_pc = 14
			16:
				puVar7 = (((puVar7 + (1) * 2)) & 0xffffffff)
				_pc = 15
			17:
				m.set_u16(puVar7, ((_zp_signed((_zp_signed(uVar2, 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff))
				_pc = 16
			18:
				puVar6 = (((puVar6 + (2) * 2)) & 0xffffffff)
				_pc = 17
			19:
				uVar2 = ((m.u16(puVar6)) & 0xffff)
				_pc = 18
			20:
				puVar6 = (((((0xa56574 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) * 4)) & 0xffffffff)) & 0xffffffff)
				_pc = 19
			21:
				iVar4 = _zp_signed(5, 32)
				_pc = 20
			22:
				puVar7 = (((_stack + 0)) & 0xffffffff)
				_pc = 21
			23:
				bVar1 = ((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xff)
				_pc = 22
			24:
				return ((0x7b) & 0xffffffff)
			25:
				var _v6: int = f5bf800((_stack + 12))
				_pc = 24
			26:
				var _v7: int = f5bdf40((_stack + 12), 0x108, uVar5)
				_pc = 25
			27:
				var _v8: int = f402290(m.u16(0xa57822))
				uVar5 = ((_v8) & 0xffffffff)
				_pc = 26
			28:
				_pc = 27 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 24
			29:
				return ((0x7a) & 0xffffffff)
			30:
				var _v9: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x1f) & 0xffffffff))) & 0xffffffff), uVar5, m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 0)
				_pc = 29
			31:
				var _v10: int = f4022e0(m.u16(0xa57822))
				uVar5 = ((_v10) & 0xffffffff)
				_pc = 30
			32:
				var _v11: int = f576050(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar5)
				_pc = 31
			33:
				var _v12: int = f4022e0(m.u16(0xa57822))
				uVar5 = ((_v12) & 0xffffffff)
				_pc = 32
			34:
				return ((100) & 0xffffffff)
			35:
				var _v13: int = f578bb0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 4, 0)
				_pc = 34
			36:
				return ((99) & 0xffffffff)
			37:
				var _v14: int = f5b9170(((((((((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(100, 32)), 32), 32) >> ((0x10) & 31)), 32), 16)) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 36
			38:
				var _v15: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v15 == 0x80: _pc = 6
				if _v15 == 0x7f: _pc = 9
				if _v15 == 0x7e: _pc = 11
				if _v15 == 0x7d: _pc = 23
				if _v15 == 0x7c: _pc = 28
				if _v15 == 0x7b: _pc = 33
				if _v15 == 0x7a: _pc = 35
				if _v15 == 100: _pc = 37
			39:
				_pc = 38 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58a170(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var pbVar1: int = 0
	var uVar2: int = 0
	var puVar3: int = 0
	var in_EAX: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var extraout_var: int = 0
	var _pc: int = 11
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f579790(_zp_signed((_zp_signed(m.u8((((puVar3 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), (((extraout_var) << 16) | ((m.u16(puVar3)) & 0xffff)), (((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff), 8), 32) * _zp_signed(2, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xff), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xff)) & 0xffffff)) << 8) | ((3) & 0xff)))
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(iVar5, 32) != _zp_signed(0, 32))) != 0 else 1
			4:
				uVar4 = ((0) & 0xffffffff)
				_pc = 3
			5:
				var _v1: int = f575e80(puVar3, _zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(pbVar1), 32) & _zp_signed(1, 32)), 32), 32)), 32), (_params + 0))
				iVar5 = _zp_signed(_v1, 32)
				_pc = 4
			6:
				m.set_u32((_params + 0), ((((m.u32((((m.u32((_params + 0)) + (3) * 2)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 5
			7:
				pbVar1 = (((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)) & 0xffffffff)
				_pc = 6
			8:
				var _v2: int = int((int(_zp_signed(_zp_signed((_zp_signed(uVar2, 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0)
				if _v2 != 0:
					uVar4 = ((_zp_signed((_zp_signed(uVar2, 32) & _zp_signed(0xe000, 32)), 32)) & 0xffffffff)
					_v2 = int((int(((uVar4) & 0xffffffff) == ((0x4000) & 0xffffffff))) != 0)
				_pc = 7 if (_v2) != 0 else 1
			9:
				uVar4 = (((((_zp_signed((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((uVar2) & 0xffff))) & 0xffffffff)
				_pc = 8
			10:
				uVar2 = ((m.u16((m.u32((_params + 0)) + (2) * 2))) & 0xffff)
				_pc = 9
			11:
				puVar3 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 10
	return 0


func f58a2c0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var puVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var _pc: int = 30
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				var _v0: int = f577880(puVar1, (((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), ((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 2
			5:
				var _v1: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar2 = _zp_signed(_v1, 32)
				_pc = 4
			6:
				return ((0x7e) & 0xffffffff)
			7:
				m.set_u16(0xa558b4, ((0) & 0xffff))
				_pc = 6
			8:
				return ((0x7e) & 0xffffffff)
			9:
				var _v2: int = f5bf9a0(1, 0)
				_pc = 8
			10:
				var _v3: int = f5bf800(0x2d)
				_pc = 9
			11:
				_pc = 10 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 7
			12:
				_pc = 19 if (1) != 0 else 11
			13:
				return ((0) & 0xffffffff)
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed(((m.u8((((0xa55d68 + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffffffff), 32), 32) <= _zp_signed(iVar2, 32))) != 0 else 12
			15:
				uVar3 = ((_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 14
			16:
				iVar2 = _zp_signed(_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 15
			17:
				var _v5: int = int((int(_zp_signed(iVar4, 32) == _zp_signed(0, 32))) != 0)
				if _v5 != 0:
					var _v4: int = f5685c0((((((uVar3) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff))
					iVar4 = _zp_signed(_v4, 32)
					_v5 = int((int(_zp_signed(iVar4, 32) == _zp_signed(0, 32))) != 0)
				_pc = 11 if (_v5) != 0 else 16
			18:
				var _v6: int = f402690((((((uVar3) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff))
				iVar4 = _zp_signed(_v6, 32)
				_pc = 17
			19:
				uVar3 = ((m.u32((0xa56434 + ((((((iVar2) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)
				_pc = 18
			20:
				_pc = 12 if (int(_zp_signed(_zp_signed(m.u8((((0xa55d68 + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 8), 32) != _zp_signed(0, 32))) != 0 else 1
			21:
				uVar3 = ((_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 20
			22:
				iVar2 = _zp_signed(0, 32)
				_pc = 21
			23:
				var _v8: int = int((int(_zp_signed(_zp_signed(m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 8), 32) != _zp_signed(0, 32))) != 0)
				if _v8 != 0:
					var _v7: int = f56a400(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
					iVar2 = _zp_signed(_v7, 32)
					_v8 = int((int(_zp_signed(iVar2, 32) != _zp_signed(_zp_signed((-(1)), 32), 32))) != 0)
				_pc = 22 if (_v8) != 0 else 1
			24:
				return ((0x7d) & 0xffffffff)
			25:
				var _v9: int = f5bcee0(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(m.u32((_params + 0))))
				_pc = 24
			26:
				_pc = 25 if (int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32))) != 0 else 1
			27:
				var _v10: int = f5796c0(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(0xa57822), 0)
				_pc = 1
			28:
				var _v11: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v11 == 0x80: _pc = 5
				if _v11 == 0x7f: _pc = 23
				if _v11 == 0x7e: _pc = 26
				if _v11 == 0x7d: _pc = 27
			29:
				_pc = 28 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			30:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 29
	return 0


func f58a4a0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var puVar1: int = 0
	var uVar2: int = 0
	var puVar3: int = 0
	var bVar4: int = 0
	var sVar5: int = 0
	var iVar6: int = 0
	var uVar7: int = 0
	var uVar8: int = 0
	var _pc: int = 35
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f579890()
				_pc = 1
			3:
				return ((0) & 0xffffffff)
			4:
				m.set_u8((((puVar3 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(((m.u16((puVar3 + (2) * 2))) & 0xff), 32) | _zp_signed(8, 32)), 32)) & 0xff))
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(sVar5, 32) == _zp_signed(3, 32))) != 0 else 1
			6:
				var _v1: int = f402700(m.u16(puVar3))
				sVar5 = _zp_signed(_v1, 16)
				_pc = 5
			7:
				return ((0x7f) & 0xffffffff)
			8:
				var _v2: int = f5ada20(bVar4, (_params + 0), 1, 0, 0x20, 0xe, bVar4)
				_pc = 7
			9:
				bVar4 = ((_zp_signed((_zp_signed(((m.u16((puVar3 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 8
			10:
				var _v3: int = f579810()
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(iVar6, 32) != _zp_signed(0, 32))) != 0 else 6
			12:
				var _v4: int = f570b40(_zp_signed((_zp_signed(((m.u16((puVar3 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32))
				iVar6 = _zp_signed(_v4, 32)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(iVar6, 32) != _zp_signed(0, 32))) != 0 else 6
			14:
				var _v5: int = f56a000(_zp_signed((_zp_signed(((m.u16((puVar3 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32))
				iVar6 = _zp_signed(_v5, 32)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(iVar6, 32) != _zp_signed(0, 32))) != 0 else 6
			16:
				var _v6: int = f56cb40(uVar7, (_params + 0))
				iVar6 = _zp_signed(_v6, 32)
				_pc = 15
			17:
				_pc = 16 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u16(puVar1), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16(puVar1), 32) & _zp_signed(0xe000, 32)), 32), 32) == _zp_signed(0x4000, 32))) != 0)) != 0 else 6
			18:
				m.set_u32((_params + 0), ((((uVar2) & 0xffffffff)) & 0xffffffff))
				_pc = 17
			19:
				puVar1 = (((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)
				_pc = 18
			20:
				uVar2 = ((m.u32((((m.u32((_params + 0)) + (3) * 2)) & 0xffffffff))) & 0xffffffff)
				_pc = 19
			21:
				_pc = 20 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			22:
				return ((100) & 0xffffffff)
			23:
				var _v7: int = f5747e0(_zp_signed((_zp_signed(m.u16((puVar3 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((puVar3 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(uVar8, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((_zp_signed((_zp_signed(m.u16(0xa55080), 32) >> ((1) & 31)), 32)) & 0xff), 32) & _zp_signed(0x1f, 32)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(uVar8, 32)), 32), 6)
				_pc = 22
			24:
				uVar8 = ((((_zp_signed((_zp_signed(((m.u16((puVar3 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32)) & 0xffff)) & 0xffff)
				_pc = 23
			25:
				return ((100) & 0xffffffff)
			26:
				var _v8: int = f574990(_zp_signed((_zp_signed(m.u16((puVar3 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((puVar3 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(uVar8, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((_zp_signed((_zp_signed(m.u16(0xa55080), 32) >> ((1) & 31)), 32)) & 0xff), 32) & _zp_signed(0x1f, 32)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(uVar8, 32)), 32))
				_pc = 25
			27:
				uVar8 = ((((_zp_signed((_zp_signed(((m.u16((puVar3 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32)) & 0xffff)) & 0xffff)
				_pc = 26
			28:
				_pc = 27 if (int(_zp_signed(sVar5, 32) == _zp_signed(0x488, 32))) != 0 else 22
			29:
				_pc = 24 if (int(_zp_signed(sVar5, 32) == _zp_signed(0x447, 32))) != 0 else 28
			30:
				var _v9: int = f4022e0(m.u16(m.u32((_params + 0))))
				sVar5 = _zp_signed(_v9, 16)
				_pc = 29
			31:
				_pc = 30 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 21
			32:
				_pc = 2 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(100, 32))) != 0 else 31
			33:
				_pc = 32 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + ((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32)) & 0xffffffff) + (((((((uVar7) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) == _zp_signed(m.u16(m.u32((_params + 0))), 32))) != 0 else 1
			34:
				uVar7 = ((_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 33
			35:
				puVar3 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 34
	return 0


func f58a690(param_1: int) -> int:
	var _stack: int = m.local(264)
	var uVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var bVar4: int = 0
	var iVar5: int = 0
	var pbVar6: int = 0
	var uVar7: int = 0
	var _pc: int = 40
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				var _v0: int = f5bcf80(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 2, 0xff)
				_pc = 2
			4:
				return ((0x7e) & 0xffffffff)
			5:
				var _v1: int = f5bcf80(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 1, m.u16(0xa57822))
				_pc = 4
			6:
				return ((0x7d) & 0xffffffff)
			7:
				var _v2: int = f5bf800((_stack + 8))
				_pc = 6
			8:
				var _v3: int = f5bdf40((_stack + 8), 0x108, uVar1)
				_pc = 7
			9:
				var _v4: int = f4025b0(iVar5)
				uVar1 = ((_v4) & 0xffffffff)
				_pc = 8
			10:
				_pc = 12 if (int((((((((((m.u16(0xa57822)) & 0xffffffff)) & 0xffffffff) & ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(bVar4, 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 9
			11:
				bVar4 = ((_zp_signed((_zp_signed(bVar4, 32) + _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 10
			12:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 11
			13:
				bVar4 = ((0) & 0xff)
				_pc = 12
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(0xa57822), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 9
			15:
				iVar5 = _zp_signed(1, 32)
				_pc = 14
			16:
				_pc = 15 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 6
			17:
				return ((0) & 0xffffffff)
			18:
				var _v5: int = f576940(param_1, m.u32((_stack + 0)))
				_pc = 17
			19:
				_pc = 30 if (int(_zp_signed(_zp_signed(m.u32((_stack + 4)), 32), 32) < _zp_signed(2, 32))) != 0 else 18
			20:
				m.set_u32((_stack + 4), _zp_signed(_zp_signed((_zp_signed(_zp_signed(m.u32((_stack + 4)), 32), 32) + _zp_signed(1, 32)), 32), 32))
				_pc = 19
			21:
				_pc = 25 if (int(_zp_signed(iVar5, 32) < _zp_signed(5, 32))) != 0 else 20
			22:
				pbVar6 = (((pbVar6 + (0x90) * 1)) & 0xffffffff)
				_pc = 21
			23:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 22
			24:
				m.set_u32((_stack + 0), (((((((m.u32((_stack + 0))) & 0xffffffff) | ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((((((uVar2) & 0xffffffff) << ((4) & 31))) & 0xffffffff), 8), 32) + _zp_signed(_zp_signed(iVar5, 8), 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 23
			25:
				var _v7: int = int((int((int((((((((m.u32((((pbVar6 + (_zp_signed((-(6)), 32)) * 1)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(pbVar6), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0)
				if _v7 != 0:
					var _v6: int = f56f9e0(uVar2, iVar5)
					uVar3 = ((_v6) & 0xffffffff)
					_v7 = int((int((((((((uVar3) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((uVar7) & 0xffffffff))) != 0)
				_pc = 24 if (_v7) != 0 else 23
			26:
				pbVar6 = (((((0xa55d7a + (((((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)) & 0xffffffff)
				_pc = 25
			27:
				iVar5 = _zp_signed(0, 32)
				_pc = 26
			28:
				uVar2 = ((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 27
			29:
				uVar2 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 27
			30:
				_pc = 28 if (int(_zp_signed(_zp_signed(m.u32((_stack + 4)), 32), 32) == _zp_signed(0, 32))) != 0 else 29
			31:
				m.set_u32((_stack + 4), _zp_signed(0, 32))
				_pc = 30
			32:
				_pc = 34 if (int((((((((((m.u16(0xa57822)) & 0xffffffff)) & 0xffffffff) & ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(bVar4, 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 31
			33:
				bVar4 = ((_zp_signed((_zp_signed(bVar4, 32) + _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 32
			34:
				uVar7 = (((((((uVar7) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 33
			35:
				bVar4 = ((0) & 0xff)
				_pc = 34
			36:
				_pc = 35 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(0xa57822), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 31
			37:
				m.set_u32((_stack + 0), ((0) & 0xffffffff))
				_pc = 36
			38:
				uVar7 = ((1) & 0xffffffff)
				_pc = 37
			39:
				var _v8: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v8 == 0x80: _pc = 3
				if _v8 == 0x7f: _pc = 5
				if _v8 == 0x7e: _pc = 16
				if _v8 == 0x7d: _pc = 38
			40:
				_pc = 39 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58a880(param_1: int) -> int:
	var puVar1: int = 0
	var bVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var iVar6: int = 0
	var uVar7: int = 0
	var uVar8: int = 0
	var uVar9: int = 0
	var unaff_EDI: int = 0
	var uVar10: int = 0
	var _pc: int = 66
	while true:
		match _pc:
			0:
				return _zp_signed(0, 8)
			1:
				return _zp_signed(122, 8)
			2:
				return _zp_signed(127, 8)
			3:
				var _v0: int = f578030(param_1, 1)
				_pc = 2
			4:
				var _v1: int = f578030(param_1, 0)
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xfc0, 32)), 32), 32) == _zp_signed(0x500, 32))) != 0 else 2
			6:
				var _v2: int = f576940(param_1, 0x1f001f)
				_pc = 5
			7:
				return _zp_signed(126, 8)
			8:
				var _v3: int = f579810()
				_pc = 7
			9:
				var _v4: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) != _zp_signed(0, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xf1) & 0xff)), 0x1e, 0, 0)
				_pc = 8
			10:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0xc, 32)), 32)) & 0xffffffff), ((uVar3) & 0xffff))
				_pc = 9
			11:
				var _v5: int = f570b40(1)
				uVar3 = ((_v5) & 0xffff)
				_pc = 10
			12:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(10, 32)), 32)) & 0xffffffff), ((uVar3) & 0xffff))
				_pc = 11
			13:
				var _v6: int = f570b40(0)
				uVar3 = ((_v6) & 0xffff)
				_pc = 12
			14:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff), ((0) & 0xffff))
				_pc = 13
			15:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(8, 32)), 32)) & 0xffffffff), ((0) & 0xffff))
				_pc = 14
			16:
				m.set_u32(0xa55c8c, ((((((((((((m.u32(0xa55c8c)) & 0xffffffff) & ((0xffffff05) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((5) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 15
			17:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((((((((((m.u16(0xa577fa)) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0x1ff) & 0xffffffff))) & 0xffffffff)) & 0xffff))
				_pc = 16
			18:
				return _zp_signed(124, 8)
			19:
				return _zp_signed(122, 8)
			20:
				var _v7: int = f578bb0(uVar9, 1, 0)
				_pc = 19
			21:
				return _zp_signed(125, 8)
			22:
				var _v8: int = f5675c0(0xa55c90, (0xa56574 + ((((((uVar5) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4))
				_pc = 21
			23:
				_pc = 22 if (int((int(_zp_signed(0, 32) < _zp_signed(iVar6, 32))) != 0 and (int(_zp_signed(_zp_signed(m.u16((((((((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(10, 32)), 32)) & 0xffffffff) + (((((((uVar8) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 16), 32) != _zp_signed(0, 32))) != 0)) != 0 else 20
			24:
				var _v9: int = f56a000(uVar8)
				iVar6 = _zp_signed(_v9, 32)
				_pc = 23
			25:
				var _v11: int = int((int(_zp_signed(iVar6, 32) != _zp_signed(0, 32))) != 0)
				if _v11 != 0:
					var _v10: int = f4026c0(uVar10)
					uVar4 = ((_v10) & 0xffff)
					_v11 = int((int(_zp_signed(uVar4, 32) < _zp_signed(5, 32))) != 0)
				var _v13: int = int((_v11) != 0)
				if _v13 != 0:
					var _v12: int = f567a00(uVar10)
					iVar6 = _zp_signed(_v12, 32)
					_v13 = int((int(_zp_signed(iVar6, 32) == _zp_signed(0, 32))) != 0)
				_pc = 24 if (_v13) != 0 else 18
			26:
				var _v14: int = f402690(uVar10)
				iVar6 = _zp_signed(_v14, 32)
				_pc = 25
			27:
				var _v15: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar9) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xf1) & 0xff)), 0x1e, 0, 0)
				_pc = 26
			28:
				var _v16: int = f5b9170((((((((((((((-(((int(((uVar9) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x20) & 0xffffffff))) & 0xffffffff), uVar7, 0xd, 0)
				_pc = 27
			29:
				var _v17: int = f4022e0(uVar10)
				uVar7 = ((_v17) & 0xffffffff)
				_pc = 28
			30:
				_pc = 29 if (int(_zp_signed(iVar6, 32) == _zp_signed(0, 32))) != 0 else 27
			31:
				var _v18: int = f570be0(uVar9, (0xa56574 + ((((((uVar5) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4))
				iVar6 = _zp_signed(_v18, 32)
				_pc = 30
			32:
				var _v19: int = f578430(uVar9, uVar10)
				_pc = 31
			33:
				uVar8 = ((((((((((((((m.u32((0xa56574 + ((((((uVar5) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 32
			34:
				uVar10 = ((((((((((_zp_signed((((((((unaff_EDI) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((((0xa56574 + ((((((uVar5) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff))) & 0xffff))) & 0xffffffff) & ((0xffff0fff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 33
			35:
				uVar5 = (((((((uVar9) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 34
			36:
				_pc = 35 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16((0xa55d68 + (((((((((((uVar9) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)), 32) & _zp_signed(0xff00, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 1
			37:
				uVar9 = ((((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 36
			38:
				return _zp_signed(122, 8)
			39:
				m.set_u16(puVar1, ((_zp_signed((_zp_signed(m.u16(puVar1), 32) | _zp_signed(((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(bVar2, 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffff), 32)), 32)) & 0xffff))
				_pc = 38
			40:
				puVar1 = (((((((((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff) + (((((((uVar9) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 39
			41:
				var _v20: int = f56a030(uVar9)
				bVar2 = ((_v20) & 0xff)
				_pc = 40
			42:
				var _v21: int = f5adb10(uVar9, 0xa55c90, 0, 0, 0xd, _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32))
				_pc = 41
			43:
				uVar9 = ((((((((((((m.u32(0xa55c90)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 42
			44:
				var _v22: int = f5b9170((((((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) != _zp_signed(0, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x61) & 0xffffffff))) & 0xffffffff), 1, 1, 0)
				_pc = 1
			45:
				return _zp_signed(126, 8)
			46:
				return _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(int(_zp_signed(_zp_signed((_zp_signed(uVar4, 32) >> ((8) & 31)), 32), 32) != _zp_signed(_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32), 32)))), 32), 32) & _zp_signed(6, 32)), 32), 32) + _zp_signed(0x78, 32)), 32), 8)
			47:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(uVar4, 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 46
			48:
				m.set_u32(0xa55c8c, (((((m.u16(0xa55c8e)) << 16) | ((_zp_signed((((_zp_signed((_zp_signed((((((((m.u32(0xa55c8c)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0xff, 32)), 32)) << 8) | ((5) & 0xff)), 16)) & 0xffff))) & 0xffffffff))
				_pc = 47
			49:
				uVar4 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) * _zp_signed(_zp_signed((-(0x100)), 32), 32)), 32), 32) + _zp_signed(0x100, 32)), 32)) & 0xffff)
				_pc = 48
			50:
				_pc = 49 if (int((((((((m.u32(0xa55c8c)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 45
			51:
				m.set_u32(0xa55c8c, ((_zp_signed((_zp_signed(uVar4, 32) ^ _zp_signed(((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(0xa55c8c), 32) - _zp_signed(1, 32)), 32), 32) ^ _zp_signed(m.u8(0xa55c8c), 32)), 32)) & 0xff), 32)), 32)) & 0xffffffff))
				_pc = 50
			52:
				return _zp_signed(0, 8)
			53:
				var _v23: int = f579890()
				_pc = 52
			54:
				_pc = 56 if (int(_zp_signed(_zp_signed(uVar9, 32), 32) < _zp_signed(2, 32))) != 0 else 53
			55:
				uVar9 = (((((((uVar9) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 54
			56:
				var _v24: int = f5797e0((((((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) ^ ((uVar9) & 0xffffffff))) & 0xffffffff))
				_pc = 55
			57:
				uVar9 = ((0) & 0xffffffff)
				_pc = 56
			58:
				_pc = 61 if (int(_zp_signed(_zp_signed(uVar9, 32), 32) < _zp_signed(2, 32))) != 0 else 57
			59:
				uVar9 = (((((((uVar9) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 58
			60:
				var _v25: int = f576170(uVar5, m.u16((((((((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)))
				_pc = 59
			61:
				uVar5 = (((((((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) ^ ((uVar9) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 60
			62:
				uVar9 = ((0) & 0xffffffff)
				_pc = 61
			63:
				var _v26: int = _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)
				_pc = 52
				if _v26 == 0x80: _pc = 6
				if _v26 == 0x7f: _pc = 17
				if _v26 == 0x7e: _pc = 37
				if _v26 == 0x7d: _pc = 43
				if _v26 == 0x7c: _pc = 44
				if _v26 == 0x7a: _pc = 51
				if _v26 == 0x78: _pc = 62
			64:
				uVar4 = ((m.u32(0xa55c8c)) & 0xffff)
				_pc = 63
			65:
				return _zp_signed(0, 8)
			66:
				_pc = 65 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 64
	return 0


func f58ac10(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var uVar4: int = 0
	var _pc: int = 29
	while true:
		match _pc:
			0:
				return ((0) & 0xff)
			1:
				return ((0) & 0xff)
			2:
				return ((1) & 0xff)
			3:
				return ((1) & 0xff)
			4:
				var _v0: int = f5bf800(0x15)
				_pc = 3
			5:
				_pc = 4 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 2
			6:
				return ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(int(_zp_signed(iVar2, 32) < _zp_signed(0, 32)), 32) - _zp_signed(1, 32)), 32), 32) & _zp_signed(0x7d, 32)), 32)) & 0xff)
			7:
				var _v1: int = f5af5a0(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), (((_zp_signed((((((uVar4) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)), 0)
				iVar2 = _zp_signed(_v1, 32)
				_pc = 6
			8:
				return ((0x7f) & 0xff)
			9:
				var _v2: int = f5bf9a0(1, 0)
				_pc = 8
			10:
				var _v3: int = f5bf800(0x2f)
				_pc = 9
			11:
				_pc = 10 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed(uVar4, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 7
			12:
				uVar4 = ((((((((((extraout_var_00) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 5
			14:
				var _v4: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar3, 0)
				iVar2 = _zp_signed(_v4, 32)
				_pc = 13
			15:
				var _v5: int = f4022e0(m.u16(param_1))
				uVar3 = ((_v5) & 0xffffffff)
				_pc = 14
			16:
				var _v7: int = int((int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0)
				if _v7 != 0:
					var _v6: int = f570b40(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
					iVar2 = _zp_signed(_v6, 32)
					_v7 = int((int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0)
				_pc = 15 if (_v7) != 0 else 1
			17:
				var _v8: int = f56a000(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v8, 32)
				_pc = 16
			18:
				return ((_zp_signed((_zp_signed(_zp_signed((-(int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32)))), 32), 32) & _zp_signed(0x7e, 32)), 32)) & 0xff)
			19:
				return ((0x7d) & 0xff)
			20:
				var _v9: int = f40c940(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 6, uVar1, 0)
				_pc = 19
			21:
				var _v10: int = f4022e0((((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x7b, 32)), 32), 32) >> ((0x10) & 31)), 32), 16)) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar1 = ((_v10) & 0xffff)
				_pc = 20
			22:
				return ((0x7c) & 0xff)
			23:
				return ((0x7b) & 0xff)
			24:
				var _v11: int = f40cab0()
				var _v12: int = f5ada20(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _v11, 1, 0, 0, 0xd, _zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 23
			25:
				return ((100) & 0xff)
			26:
				var _v13: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 25
			27:
				var _v14: int = _zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x7b, 32)), 32)
				_pc = 1
				if _v14 == 5: _pc = 17
				if _v14 == 4: _pc = 18
				if _v14 == 3: _pc = 21
				if _v14 == 2: _pc = 22
				if _v14 == 1: _pc = 24
				if _v14 == 0: _pc = 26
			28:
				_pc = 27 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			29:
				var _v15: int = f40cab0()
				_pc = 28
	return 0


func f58add0(param_1: int) -> int:
	var sVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var puVar5: int = 0
	var extraout_var: int = 0
	var uVar6: int = 0
	var extraout_var_00: int = 0
	var in_EDX: int = 0
	var _pc: int = 40
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((1) & 0xffffffff)
			3:
				var _v0: int = f5bf800(0x15)
				_pc = 2
			4:
				_pc = 3 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 1
			5:
				return ((0x7f) & 0xffffffff)
			6:
				var _v1: int = f5bf9a0(1, 0)
				_pc = 5
			7:
				var _v2: int = f5bf800(uVar3)
				_pc = 6
			8:
				uVar3 = ((0x31) & 0xffffffff)
				_pc = 7
			9:
				uVar3 = ((0x32) & 0xffffffff)
				_pc = 7
			10:
				return ((0) & 0xffffffff)
			11:
				_pc = 10 if (int(_zp_signed(sVar1, 32) != _zp_signed(0x462, 32))) != 0 else 9
			12:
				_pc = 8 if (int(_zp_signed(sVar1, 32) == _zp_signed(0x455, 32))) != 0 else 11
			13:
				var _v3: int = f4022e0(m.u16(param_1))
				sVar1 = _zp_signed(_v3, 16)
				_pc = 12
			14:
				return ((0x7d) & 0xffffffff)
			15:
				var _v4: int = f5af5a0(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), (((_zp_signed((((((uVar6) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)), 0)
				_pc = 14
			16:
				_pc = 15 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed(uVar6, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 13
			17:
				uVar6 = ((((((((((extraout_var) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 4
			19:
				var _v5: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar3, 0)
				iVar4 = _zp_signed(_v5, 32)
				_pc = 18
			20:
				var _v6: int = f4022e0(m.u16(param_1))
				uVar3 = ((_v6) & 0xffffffff)
				_pc = 19
			21:
				return ((0x7e) & 0xffffffff)
			22:
				var _v7: int = f5bf800(0x33)
				_pc = 21
			23:
				_pc = 22 if (int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32))) != 0 else 1
			24:
				return ((0x7d) & 0xffffffff)
			25:
				var _v8: int = f40c940(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 6, uVar2, 0)
				_pc = 24
			26:
				var _v9: int = f4022e0((((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x7c, 32)), 32), 32) >> ((0x10) & 31)), 32), 16)) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v9) & 0xffff)
				_pc = 25
			27:
				return ((0x7c) & 0xffffffff)
			28:
				var _v10: int = f5b9170(((((((((extraout_var_00) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x1f) & 0xffffffff))) & 0xffffffff), uVar3, m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 0)
				_pc = 27
			29:
				var _v11: int = f4022e0(_zp_signed((_zp_signed(m.u16(puVar5), 32) & _zp_signed(0xfff, 32)), 32))
				uVar3 = ((_v11) & 0xffffffff)
				_pc = 28
			30:
				var _v12: int = f40cab0()
				puVar5 = ((((_v12) & 0xffffffff)) & 0xffffffff)
				_pc = 29
			31:
				var _v13: int = f578430(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(m.u16(puVar5), 32) & _zp_signed(0xfff, 32)), 32))
				_pc = 30
			32:
				var _v14: int = f40cab0()
				puVar5 = ((((_v14) & 0xffffffff)) & 0xffffffff)
				_pc = 31
			33:
				_pc = 32 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 27
			34:
				var _v15: int = f576050(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar3)
				iVar4 = _zp_signed(_v15, 32)
				_pc = 33
			35:
				var _v16: int = f4022e0(_zp_signed((_zp_signed(m.u16(puVar5), 32) & _zp_signed(0xfff, 32)), 32))
				uVar3 = ((_v16) & 0xffffffff)
				_pc = 34
			36:
				var _v17: int = f40cab0()
				puVar5 = ((((_v17) & 0xffffffff)) & 0xffffffff)
				_pc = 35
			37:
				return ((1) & 0xffffffff)
			38:
				var _v18: int = f5b9170(((((((((_zp_signed((((((((in_EDX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 37
			39:
				var _v19: int = _zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x7c, 32)), 32)
				_pc = 1
				if _v19 == 4: _pc = 20
				if _v19 == 3: _pc = 23
				if _v19 == 2: _pc = 26
				if _v19 == 1: _pc = 36
				if _v19 == 0: _pc = 38
			40:
				_pc = 39 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58b040(param_1: int) -> int:
	var _stack: int = m.local(256)
	var bVar1: int = 0
	var sVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var uVar5: int = 0
	var extraout_var_00: int = 0
	var extraout_var_01: int = 0
	var extraout_var_02: int = 0
	var extraout_var_03: int = 0
	var uVar6: int = 0
	var _pc: int = 71
	while true:
		match _pc:
			0:
				return _zp_signed(0, 32)
			1:
				return _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(1, 32)), 32), 32)
			2:
				var _v0: int = f5bf9a0(1, 0)
				_pc = 1
			3:
				var _v1: int = f5bf800((_stack + 0))
				_pc = 2
			4:
				var _v2: int = f5bdf40((_stack + 0), uVar6, uVar4)
				_pc = 3
			5:
				uVar6 = ((0x35) & 0xffffffff)
				_pc = 4
			6:
				var _v3: int = f402290((((extraout_var_02) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar4 = ((_v3) & 0xffffffff)
				_pc = 5
			7:
				uVar6 = ((0x34) & 0xffffffff)
				_pc = 4
			8:
				var _v4: int = f402290((((extraout_var_03) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar4 = ((_v4) & 0xffffffff)
				_pc = 7
			9:
				_pc = 3
			10:
				_pc = 9 if (int((int(_zp_signed(sVar2, 32) != _zp_signed(0x45b, 32))) != 0 and (int(_zp_signed(sVar2, 32) != _zp_signed(0x51b, 32))) != 0)) != 0 else 8
			11:
				_pc = 6 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x45a, 32))) != 0 else 10
			12:
				var _v5: int = f4022e0((((_zp_signed((((((uVar5) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)))
				sVar2 = _zp_signed(_v5, 16)
				_pc = 11
			13:
				return _zp_signed(0x7e, 32)
			14:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 13
			15:
				_pc = 14 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed(uVar5, 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 12
			16:
				uVar5 = ((((((((((extraout_var_01) << 16) | ((((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xffff)) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				_pc = 21
			18:
				_pc = 17 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 16
			19:
				var _v6: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar4, 0)
				iVar3 = _zp_signed(_v6, 32)
				_pc = 18
			20:
				var _v7: int = f4022e0((((extraout_var_00) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar4 = ((_v7) & 0xffffffff)
				_pc = 19
			21:
				return _zp_signed(_zp_signed((_zp_signed(int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) < _zp_signed(100, 32)), 32) + _zp_signed(99, 32)), 32), 32)
			22:
				_pc = 21 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 20
			23:
				var _v8: int = f56a000(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar3 = _zp_signed(_v8, 32)
				_pc = 22
			24:
				var _v9: int = f579810()
				_pc = 23
			25:
				return _zp_signed(1, 32)
			26:
				var _v10: int = f5bf800(0x15)
				_pc = 25
			27:
				_pc = 26 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 24
			28:
				var _v11: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar4, 0)
				iVar3 = _zp_signed(_v11, 32)
				_pc = 27
			29:
				var _v12: int = f4022e0((((_zp_signed((((((uVar5) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar4 = ((_v12) & 0xffffffff)
				_pc = 28
			30:
				_pc = 29 if (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((~((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed(uVar5, 8)) & 31))) & 0xffffffff)) & 0xff))), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 24
			31:
				uVar5 = ((((((((((extraout_var) << 16) | ((((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xffff)) & 0xffff))) & 0xffffffff) & ((0xffff0001) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 30
			32:
				return _zp_signed(0, 32)
			33:
				_pc = 32 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 31
			34:
				var _v13: int = f570b40(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar3 = _zp_signed(_v13, 32)
				_pc = 33
			35:
				return _zp_signed(0, 32)
			36:
				_pc = 35 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 34
			37:
				var _v14: int = f56a000(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar3 = _zp_signed(_v14, 32)
				_pc = 36
			38:
				return _zp_signed(0x7f, 32)
			39:
				var _v15: int = f5784e0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 500)
				_pc = 38
			40:
				return _zp_signed(0x7f, 32)
			41:
				var _v16: int = f5787f0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 1000)
				_pc = 40
			42:
				_pc = 41 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x45b, 32))) != 0 else 38
			43:
				_pc = 39 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x45a, 32))) != 0 else 42
			44:
				var _v17: int = f4022e0((((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x1a, 32)), 32), 32) >> ((0x10) & 31)), 32), 16)) << 16) | ((m.u16(param_1)) & 0xffff)))
				sVar2 = _zp_signed(_v17, 16)
				_pc = 43
			45:
				return _zp_signed(0x1b, 32)
			46:
				var _v18: int = f5ada20(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32), 0xa55c90, uVar4, uVar6, 0, 0xd, _zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32))
				_pc = 45
			47:
				uVar4 = ((1) & 0xffffffff)
				_pc = 46
			48:
				uVar6 = ((0) & 0xffffffff)
				_pc = 47
			49:
				bVar1 = ((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xff)
				_pc = 48
			50:
				uVar4 = ((0) & 0xffffffff)
				_pc = 46
			51:
				uVar6 = ((1) & 0xffffffff)
				_pc = 50
			52:
				bVar1 = ((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xff)
				_pc = 51
			53:
				return _zp_signed(0x1b, 32)
			54:
				return _zp_signed(100, 32)
			55:
				var _v19: int = f5ada20(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0xa55c90, 0, 1, 0, 0xd, _zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 54
			56:
				_pc = 55 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x51b, 32))) != 0 else 53
			57:
				_pc = 56 if (int(_zp_signed(sVar2, 32) != _zp_signed(0x45b, 32))) != 0 else 52
			58:
				_pc = 49 if (int(_zp_signed(sVar2, 32) == _zp_signed(0x45a, 32))) != 0 else 57
			59:
				var _v20: int = f4022e0(m.u16(param_1))
				sVar2 = _zp_signed(_v20, 16)
				_pc = 58
			60:
				return _zp_signed(0, 32)
			61:
				var _v21: int = f579890()
				_pc = 60
			62:
				var _v22: int = f5b9170(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32), 32) | _zp_signed(0x60, 32)), 32), 1, 0, 0)
				_pc = 61
			63:
				return _zp_signed(0, 32)
			64:
				_pc = 23
			65:
				_pc = 21
			66:
				return _zp_signed(0x7d, 32)
			67:
				var _v23: int = f568fa0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(param_1), 0xa55c90)
				_pc = 66
			68:
				_pc = 67 if (int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32))) != 0 else 65
			69:
				var _v24: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 63
				if _v24 == 0x80: _pc = 44
				if _v24 == 0x7f: _pc = 37
				if _v24 == 0x7d: _pc = 59
				if _v24 == 99: _pc = 61
				if _v24 == 100: _pc = 62
				if _v24 == 0x1b: _pc = 64
				if _v24 == 0x7e: _pc = 68
				if _v24 == 0x1a: _pc = 68
			70:
				return _zp_signed(0, 32)
			71:
				_pc = 70 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 69
	return 0


func f58b400(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var puVar1: int = 0
	var bVar2: int = 0
	var uVar3: int = 0
	var sVar4: int = 0
	var iVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 27
	while true:
		match _pc:
			0:
				return _zp_signed(0, 8)
			1:
				return _zp_signed(0, 8)
			2:
				return _zp_signed(127, 8)
			3:
				var _v0: int = f579810()
				_pc = 2
			4:
				m.set_u32(0xa55c8c, (((((m.u16(0xa55c8e)) << 16) | ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(((_zp_signed((_zp_signed(bVar2, 32) ^ _zp_signed(m.u8(0xa55c8c), 32)), 32)) & 0xffff), 32) ^ _zp_signed(((m.u32(0xa55c8c)) & 0xffff), 32)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar3, 32) & _zp_signed(0x7f, 32)), 32), 32) << ((1) & 31)), 32), 32)), 32)) & 0xffff))) & 0xffffffff))
				_pc = 3
			5:
				var _v1: int = f570b40(1)
				uVar3 = ((_v1) & 0xffff)
				_pc = 4
			6:
				var _v2: int = f570b40(0)
				bVar2 = ((_v2) & 0xff)
				_pc = 5
			7:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)) & 0xffff))
				_pc = 6
			8:
				return _zp_signed(126, 8)
			9:
				var _v3: int = f5adb10(uVar6, (_params + 0), int(_zp_signed(iVar5, 32) != _zp_signed(0, 32)), 0x20, 0xe, uVar6)
				_pc = 8
			10:
				var _v4: int = f567a00((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff))
				iVar5 = _zp_signed(_v4, 32)
				_pc = 9
			11:
				return _zp_signed(126, 8)
			12:
				var _v5: int = f5ada20(uVar6, (_params + 0), 0, 1, 0x20, 0xe, uVar6)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(sVar4, 32) == _zp_signed(0x487, 32))) != 0 else 8
			14:
				_pc = 10 if (int(_zp_signed(sVar4, 32) == _zp_signed(0x45c, 32))) != 0 else 13
			15:
				var _v6: int = f4022e0(m.u16(puVar1))
				sVar4 = _zp_signed(_v6, 16)
				_pc = 14
			16:
				_pc = 15 if (int(_zp_signed(iVar5, 32) != _zp_signed(0, 32))) != 0 else 8
			17:
				var _v7: int = f56cb40(uVar6, (_params + 0))
				iVar5 = _zp_signed(_v7, 32)
				_pc = 16
			18:
				m.set_u32((_params + 0), (((((((m.u16((puVar1 + (((((((((((uVar6) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) * 2))) << 16) | ((m.u16((puVar1 + (((((((((((uVar6) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2))) & 0xffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 17
			19:
				_pc = 18 if (int((int((int(_zp_signed(iVar5, 32) != _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(0xa55c8c), 32) >> ((_zp_signed((_zp_signed(((uVar6) & 0xff), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 and (int(_zp_signed(m.u16((puVar1 + (((((((((((uVar6) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2)), 32) != _zp_signed(0, 32))) != 0)) != 0 else 8
			20:
				var _v8: int = f56a000(uVar6)
				iVar5 = _zp_signed(_v8, 32)
				_pc = 19
			21:
				return _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) < _zp_signed(0x200, 32)))), 32), 32) & _zp_signed(0x1b, 32)), 32), 32) + _zp_signed(100, 32)), 32), 8)
			22:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) + _zp_signed(0x100, 32)), 32), 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 21
			23:
				var _v9: int = f579890()
				_pc = 1
			24:
				var _v10: int = _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)
				_pc = 1
				if _v10 == 0x80: _pc = 7
				if _v10 == 0x7f: _pc = 20
				if _v10 == 0x7e: _pc = 22
				if _v10 == 100: _pc = 23
			25:
				_pc = 24 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			26:
				uVar6 = (((((((((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff)) & 0xffffffff) ^ ((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 25
			27:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 26
	return 0


func f58b5e0(param_1: int) -> int:
	var uVar1: int = 0
	var sVar2: int = 0
	var in_EAX: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var uVar5: int = 0
	var pbVar6: int = 0
	var uVar7: int = 0
	var iVar8: int = 0
	var bVar9: int = 0
	var local_4: int = 0
	var _pc: int = 47
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5b9170(((((((((uVar4) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x17) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				return (((((((uVar5) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			4:
				var _v1: int = f5b9170(((((((((extraout_var_00) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x18) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				uVar5 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				return (((((((uVar5) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			6:
				var _v2: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x16) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				uVar5 = ((_v2) & 0xffffffff)
				_pc = 5
			7:
				return (((((((uVar5) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			8:
				var _v3: int = f5b9170(((((((((uVar4) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x15) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				uVar5 = ((_v3) & 0xffffffff)
				_pc = 7
			9:
				var _v4: int = in_EAX
				_pc = 1
				if _v4 == 3: _pc = 2
				if _v4 == 2: _pc = 4
				if _v4 == 1: _pc = 6
				if _v4 == 0: _pc = 8
			10:
				uVar4 = (((((((((in_EAX) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 9
			11:
				in_EAX = ((((((((((((uVar5) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) - ((0x470) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 10
			12:
				var _v5: int = f4022e0(m.u16(param_1))
				uVar5 = ((_v5) & 0xffffffff)
				_pc = 11
			13:
				_pc = 42 if (1) != 0 else 1
			14:
				return (((((_zp_signed((((((((local_4) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((0x7f) & 0xffff))) & 0xffffffff)
			15:
				_pc = 14 if (int(_zp_signed(1, 32) < _zp_signed(local_4, 32))) != 0 else 13
			16:
				local_4 = _zp_signed(_zp_signed((_zp_signed(local_4, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 15
			17:
				_pc = 37 if (int(_zp_signed(iVar8, 32) < _zp_signed(0xb, 32))) != 0 else 16
			18:
				pbVar6 = (((pbVar6 + (0x90) * 1)) & 0xffffffff)
				_pc = 17
			19:
				iVar8 = _zp_signed(_zp_signed((_zp_signed(iVar8, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 18
			20:
				_pc = 23
			21:
				var _v7: int = int((int(_zp_signed(sVar2, 32) == _zp_signed(4, 32))) != 0)
				if _v7 != 0:
					var _v6: int = f4025d0(uVar7)
					sVar2 = _zp_signed(_v6, 16)
					_v7 = int((int(_zp_signed(sVar2, 32) == _zp_signed(0x15, 32))) != 0)
				_pc = 20 if (_v7) != 0 else 19
			22:
				var _v8: int = f402700(uVar7)
				sVar2 = _zp_signed(_v8, 16)
				_pc = 21
			23:
				var _v9: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar5) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xb1) & 0xff)), iVar8, 1, 0)
				_pc = 19
			24:
				var _v11: int = int((bVar9) != 0)
				if _v11 != 0:
					var _v10: int = f4025d0(uVar7)
					sVar2 = _zp_signed(_v10, 16)
					_v11 = int((int(_zp_signed(sVar2, 32) == _zp_signed(0x16, 32))) != 0)
				_pc = 23 if (_v11) != 0 else 19
			25:
				bVar9 = ((int(_zp_signed(sVar2, 32) == _zp_signed(4, 32))) & 0xff)
				_pc = 24
			26:
				var _v12: int = f402700(uVar7)
				sVar2 = _zp_signed(_v12, 16)
				_pc = 25
			27:
				_pc = 24
			28:
				bVar9 = ((int(_zp_signed(sVar2, 32) == _zp_signed(2, 32))) & 0xff)
				_pc = 27
			29:
				var _v13: int = f402700(uVar7)
				sVar2 = _zp_signed(_v13, 16)
				_pc = 28
			30:
				_pc = 23
			31:
				var _v15: int = int((int(_zp_signed(sVar2, 32) != _zp_signed(3, 32))) != 0)
				if _v15 != 0:
					var _v14: int = f4025d0(uVar7)
					uVar1 = ((_v14) & 0xffff)
					_v15 = int((int(_zp_signed(0x14, 32) < _zp_signed(uVar1, 32))) != 0)
				_pc = 19 if (_v15) != 0 else 30
			32:
				var _v16: int = f402700(uVar7)
				sVar2 = _zp_signed(_v16, 16)
				_pc = 31
			33:
				var _v17: int = ((((((((((uVar3) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) - ((0x470) & 0xffffffff))) & 0xffffffff)
				_pc = 19
				if _v17 == 3: _pc = 22
				if _v17 == 2: _pc = 26
				if _v17 == 1: _pc = 29
				if _v17 == 0: _pc = 32
			34:
				var _v18: int = f4022e0(m.u16(param_1))
				uVar3 = ((_v18) & 0xffffffff)
				_pc = 33
			35:
				_pc = 19
			36:
				_pc = 35 if (int((int(((uVar7) & 0xffffffff) == ((0) & 0xffffffff))) != 0 or (int(_zp_signed(_zp_signed((_zp_signed(m.u8(pbVar6), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 34
			37:
				uVar7 = (((((((m.u32((((pbVar6 + (_zp_signed((-(6)), 32)) * 1)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 36
			38:
				pbVar6 = (((0xa5604a + (((((((((((uVar5) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) * 1)) & 0xffffffff)
				_pc = 37
			39:
				iVar8 = _zp_signed(5, 32)
				_pc = 38
			40:
				uVar5 = ((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 39
			41:
				uVar5 = ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 39
			42:
				_pc = 40 if (int(_zp_signed(local_4, 32) == _zp_signed(0, 32))) != 0 else 41
			43:
				local_4 = _zp_signed(0, 32)
				_pc = 42
			44:
				_pc = 43 if (int(((in_EAX) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 1
			45:
				in_EAX = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x80, 32)), 32)) & 0xffffffff)
				_pc = 44
			46:
				_pc = 12 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x7f, 32))) != 0 else 45
			47:
				_pc = 46 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58b810(param_1: int) -> int:
	var in_EAX: int = 0
	var uVar3: int = 0
	var uVar1: int = 0
	var extraout_var: int = 0
	var uVar2: int = 0
	var extraout_var_00: int = 0
	var extraout_var_01: int = 0
	var extraout_var_02: int = 0
	var iVar4: int = 0
	var _pc: int = 29
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				_pc = 6 if (int(_zp_signed(iVar4, 32) < _zp_signed(_zp_signed(uVar1, 32), 32))) != 0 else 1
			3:
				var _v0: int = f56cbd0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar2)
				uVar1 = ((_v0) & 0xffffffff)
				_pc = 2
			4:
				var _v1: int = f4022e0((((extraout_var_02) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				iVar4 = _zp_signed(_zp_signed((_zp_signed(iVar4, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 4
			6:
				var _v2: int = f5787f0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 500)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(0, 32) < _zp_signed(_zp_signed(uVar1, 32), 32))) != 0 else 1
			8:
				var _v3: int = f56cbd0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar2)
				uVar1 = ((_v3) & 0xffffffff)
				_pc = 7
			9:
				var _v4: int = f4022e0((((extraout_var_01) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v4) & 0xffffffff)
				_pc = 8
			10:
				iVar4 = _zp_signed(0, 32)
				_pc = 9
			11:
				var _v5: int = f5787f0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 1000)
				_pc = 10
			12:
				return (((((((uVar1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			13:
				_pc = 17 if (int(_zp_signed(iVar4, 32) < _zp_signed(_zp_signed(uVar1, 32), 32))) != 0 else 12
			14:
				var _v6: int = f56cbd0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar2)
				uVar1 = ((_v6) & 0xffffffff)
				_pc = 13
			15:
				var _v7: int = f4022e0((((extraout_var_00) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v7) & 0xffffffff)
				_pc = 14
			16:
				iVar4 = _zp_signed(_zp_signed((_zp_signed(iVar4, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 15
			17:
				var _v8: int = f5784e0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 300)
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(0, 32) < _zp_signed(_zp_signed(uVar1, 32), 32))) != 0 else 1
			19:
				var _v9: int = f56cbd0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar2)
				uVar1 = ((_v9) & 0xffffffff)
				_pc = 18
			20:
				var _v10: int = f4022e0((((extraout_var) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar2 = ((_v10) & 0xffffffff)
				_pc = 19
			21:
				iVar4 = _zp_signed(0, 32)
				_pc = 20
			22:
				var _v11: int = f5784e0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 700)
				_pc = 21
			23:
				_pc = 22 if (int(((uVar1) & 0xffffffff) == ((0x518) & 0xffffffff))) != 0 else 1
			24:
				_pc = 11 if (int(((uVar1) & 0xffffffff) == ((0x474) & 0xffffffff))) != 0 else 23
			25:
				uVar1 = (((((((uVar1) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 24
			26:
				var _v12: int = f4022e0((((uVar3) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar1 = ((_v12) & 0xffffffff)
				_pc = 25
			27:
				return (((((((((uVar3) & 0xffffffff)) & 0xffffffff) << ((0x10) & 31))) & 0xffffffff)) & 0xffffffff)
			28:
				_pc = 27 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 26
			29:
				uVar3 = (((((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 28
	return 0


func f58b9a0(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 14
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f5bcdc0((((((1) & 0xffffffff) - ((uVar3) & 0xffffffff))) & 0xffffffff), uVar4, 0, 1)
				_pc = 1
			3:
				uVar4 = ((((m.u8((((0xa55d68 + (((((((((((((((((((-(uVar3))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 2
			4:
				_pc = 3 if (int(((((m.u8((((0xa55d68 + (((((((((((((((((((-(uVar3))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) <= ((_zp_signed((_zp_signed(m.u16(((((0xa55d7c + ((((((uVar2) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) * 1) + ((((((uVar3) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) * 1)) & 0xffffffff)), 32) + _zp_signed(1, 32)), 32)) & 0xffffffff))) != 0 else 2
			5:
				uVar4 = ((_zp_signed((_zp_signed(m.u16(((((0xa55d7c + ((((((uVar2) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) * 1) + ((((((uVar3) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) * 1)) & 0xffffffff)), 32) + _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 4
			6:
				return ((0x7f) & 0xffffffff)
			7:
				var _v1: int = f579990(uVar3, uVar2, 4, 0)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			9:
				_pc = 5 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 8
			10:
				_pc = 9 if (int((int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar2) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) == _zp_signed(m.u16(param_1), 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0x3000, 32)), 32), 32) == _zp_signed(0x1000, 32))) != 0)) != 0 else 1
			11:
				uVar2 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 10
			12:
				uVar3 = ((_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 11
			13:
				uVar1 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 12
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58ba80(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var _pc: int = 9
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x80) & 0xffffffff)
			3:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xe000, 32)), 32), 32) - _zp_signed(1, 32)), 32), 32) ^ _zp_signed(_zp_signed((_zp_signed(_zp_signed((~(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)))), 32), 32) & _zp_signed(0x1fff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 2
			4:
				var _v0: int = f575d50(param_1, _zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar3)
				_pc = 3
			5:
				var _v1: int = f5700f0(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0xe, iVar2)
				uVar3 = ((_v1) & 0xffffffff)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar2, 32))) != 0 else 3
			7:
				var _v2: int = f568ad0(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16((((((((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff) + (((((((((_zp_signed((_zp_signed(uVar1, 32) >> ((0xd) & 31)), 32)) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)))
				iVar2 = _zp_signed(_v2, 32)
				_pc = 6
			8:
				_pc = 7 if (int((int((int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 and (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0)) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xe000, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			9:
				uVar1 = ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff))) & 0xffff)
				_pc = 8
	return 0


func f58bb10(param_1: int) -> int:
	var bVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var iVar8: int = 0
	var iVar9: int = 0
	var uVar10: int = 0
	var local_8: int = 0
	var local_4: int = 0
	var _pc: int = 77
	while true:
		match _pc:
			0:
				return _zp_signed(0, 8)
			1:
				return _zp_signed(0, 8)
			2:
				return _zp_signed(127, 8)
			3:
				_pc = 14 if (int(_zp_signed(_zp_signed(local_8, 32), 32) < _zp_signed(2, 32))) != 0 else 2
			4:
				local_8 = (((((((local_8) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 3
			5:
				_pc = 12 if (int(_zp_signed(iVar8, 32) < _zp_signed(0x2d0, 32))) != 0 else 4
			6:
				iVar9 = _zp_signed(_zp_signed((_zp_signed(iVar9, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 5
			7:
				iVar8 = _zp_signed(_zp_signed((_zp_signed(iVar8, 32) + _zp_signed(0x90, 32)), 32), 32)
				_pc = 6
			8:
				m.set_u16((param_1 + ((((((((((((((((m.u32(((((((((((((_zp_signed(0xa55d74, 32)) & 0xffffffff) + ((((((((((((local_8) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((iVar8) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2), ((_zp_signed((_zp_signed(m.u16((param_1 + ((((((((((((((((m.u32(((((((((((((_zp_signed(0xa55d74, 32)) & 0xffffffff) + ((((((((((((local_8) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((iVar8) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2)), 32) + _zp_signed(1, 32)), 32)) & 0xffff))
				_pc = 7
			9:
				var _v5: int = int((int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0)
				if _v5 != 0:
					var _v0: int = f4022e0(uVar10)
					uVar2 = ((_v0) & 0xffff)
					var _v2: int = int((int(_zp_signed(uVar2, 32) < _zp_signed(0x780, 32))) != 0)
					if _v2 == 0:
						var _v1: int = f4022e0(uVar10)
						uVar2 = ((_v1) & 0xffff)
						_v2 = int((int(_zp_signed(0x783, 32) < _zp_signed(uVar2, 32))) != 0)
					var _v4: int = int((_v2) != 0)
					if _v4 != 0:
						var _v3: int = f567ad0(uVar10)
						iVar4 = _zp_signed(_v3, 32)
						_v4 = int((int(_zp_signed(iVar4, 32) == _zp_signed(0, 32))) != 0)
					_v5 = int((_v4) != 0)
				_pc = 8 if (_v5) != 0 else 7
			10:
				var _v6: int = f402690(uVar10)
				iVar4 = _zp_signed(_v6, 32)
				_pc = 9
			11:
				uVar10 = (((((((m.u32(((((((((((((_zp_signed(0xa55d74, 32)) & 0xffffffff) + ((((((((((((local_8) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((iVar8) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 10
			12:
				_pc = 11 if (int((((((((uVar7) & 0xffffffff) & ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(((iVar9) & 0xff), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 7
			13:
				iVar9 = _zp_signed((((((local_8) & 0xffffffff) << ((4) & 31))) & 0xffffffff), 32)
				_pc = 12
			14:
				iVar8 = _zp_signed(0, 32)
				_pc = 13
			15:
				local_8 = ((0) & 0xffffffff)
				_pc = 14
			16:
				var _v7: int = f577a40(param_1, 0x1f001f)
				uVar7 = ((_v7) & 0xffffffff)
				_pc = 15
			17:
				m.set_u16((param_1 + (5) * 2), ((0) & 0xffff))
				_pc = 16
			18:
				m.set_u16((param_1 + (6) * 2), ((0) & 0xffff))
				_pc = 17
			19:
				m.set_u16((param_1 + (3) * 2), ((0) & 0xffff))
				_pc = 18
			20:
				m.set_u16((param_1 + (4) * 2), ((0) & 0xffff))
				_pc = 19
			21:
				_pc = 20 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			22:
				return _zp_signed(126, 8)
			23:
				var _v8: int = f579810()
				_pc = 22
			24:
				m.set_u32(0xa55c8c, (((((m.u16(0xa55c8e)) << 16) | ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(((_zp_signed((_zp_signed(bVar1, 32) ^ _zp_signed(m.u8(0xa55c8c), 32)), 32)) & 0xffff), 32) ^ _zp_signed(((m.u32(0xa55c8c)) & 0xffff), 32)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar2, 32) & _zp_signed(0x7f, 32)), 32), 32) << ((1) & 31)), 32), 32)), 32)) & 0xffff))) & 0xffffffff))
				_pc = 23
			25:
				var _v9: int = f570b40(1)
				uVar2 = ((_v9) & 0xffff)
				_pc = 24
			26:
				var _v10: int = f570b40(0)
				bVar1 = ((_v10) & 0xff)
				_pc = 25
			27:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)) & 0xffff))
				_pc = 26
			28:
				return _zp_signed(120, 8)
			29:
				return _zp_signed(125, 8)
			30:
				_pc = 29 if (int(_zp_signed(_zp_signed(uVar5, 16), 32) != _zp_signed(0, 32))) != 0 else 28
			31:
				m.set_u16((param_1 + ((((((uVar7) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2), ((_zp_signed(uVar5, 16)) & 0xffff))
				_pc = 30
			32:
				uVar5 = ((uVar10) & 0xffffffff)
				_pc = 31
			33:
				_pc = 32 if (int(_zp_signed(_zp_signed(uVar10, 32), 32) < _zp_signed(_zp_signed(((((m.u16((param_1 + ((((((uVar7) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2))) & 0xffff)) & 0xffffffff), 32), 32))) != 0 else 31
			34:
				uVar5 = ((((((m.u16((param_1 + ((((((uVar7) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2))) & 0xffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 33
			35:
				var _v11: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar7) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xf1) & 0xff)), 0x3c, 0, 0)
				_pc = 34
			36:
				_pc = 35 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(((uVar7) & 0xff), 32) & _zp_signed(0x1f, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 34
			37:
				var _v12: int = f579930(uVar7, 4, 1)
				_pc = 36
			38:
				var _v13: int = f579930(uVar7, 3, 1)
				_pc = 37
			39:
				var _v14: int = f56a000(uVar7)
				uVar10 = ((_v14) & 0xffffffff)
				_pc = 38
			40:
				_pc = 39 if (int(_zp_signed(iVar8, 32) <= _zp_signed(_zp_signed(uVar10, 32), 32))) != 0 else 38
			41:
				var _v15: int = f56a000(uVar7)
				iVar8 = _zp_signed(_v15, 32)
				_pc = 40
			42:
				_pc = 49 if (int(_zp_signed(iVar8, 32) < _zp_signed(_zp_signed(((m.u8((((0xa55d68 + ((((((uVar5) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffffffff), 32), 32))) != 0 else 41
			43:
				uVar10 = ((local_8) & 0xffffffff)
				_pc = 42
			44:
				local_4 = (((local_4 + (2) * 2)) & 0xffffffff)
				_pc = 43
			45:
				iVar8 = _zp_signed(_zp_signed((_zp_signed(iVar8, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 44
			46:
				local_8 = (((((((local_8) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 45
			47:
				var _v17: int = int((int(_zp_signed(iVar9, 32) != _zp_signed(0, 32))) != 0)
				if _v17 != 0:
					var _v16: int = f4026c0(uVar2)
					uVar3 = ((_v16) & 0xffff)
					_v17 = int((int(_zp_signed(uVar3, 32) < _zp_signed(5, 32))) != 0)
				var _v20: int = int((_v17) != 0)
				if _v20 != 0:
					var _v19: int = int((int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(0xa55c8c), 32) >> ((_zp_signed((_zp_signed(((uVar7) & 0xff), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)
					if _v19 != 0:
						var _v18: int = f567a00(uVar2)
						iVar9 = _zp_signed(_v18, 32)
						_v19 = int((int(_zp_signed(iVar9, 32) == _zp_signed(0, 32))) != 0)
					_v20 = int((_v19) != 0)
				_pc = 46 if (_v20) != 0 else 45
			48:
				var _v21: int = f402690(uVar2)
				iVar9 = _zp_signed(_v21, 32)
				_pc = 47
			49:
				uVar2 = ((_zp_signed((_zp_signed(m.u16(local_4), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 48
			50:
				local_4 = (((((0xa56434 + ((((((uVar5) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)) & 0xffffffff)
				_pc = 49
			51:
				_pc = 50 if (int(_zp_signed(_zp_signed(m.u8((((0xa55d68 + ((((((uVar5) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 8), 32) != _zp_signed(0, 32))) != 0 else 41
			52:
				uVar10 = ((0) & 0xffffffff)
				_pc = 51
			53:
				local_8 = ((0) & 0xffffffff)
				_pc = 52
			54:
				iVar8 = _zp_signed(0, 32)
				_pc = 53
			55:
				uVar5 = (((((((uVar7) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 54
			56:
				_pc = 55 if (int(_zp_signed(m.u16((param_1 + ((((((uVar7) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2)), 32) != _zp_signed(0, 32))) != 0 else 28
			57:
				return _zp_signed(124, 8)
			58:
				var _v22: int = f5bcf40(uVar7, 0x47d)
				_pc = 57
			59:
				return _zp_signed(123, 8)
			60:
				var _v23: int = f5bcee0(uVar7, m.u16(param_1))
				_pc = 59
			61:
				return _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(int(_zp_signed(m.u16((param_1 + ((((((uVar7) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2)), 32) != _zp_signed(0, 32)))), 32), 32) & _zp_signed(4, 32)), 32), 32) + _zp_signed(0x78, 32)), 32), 8)
			62:
				m.set_u16((param_1 + ((((((uVar7) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2), ((_zp_signed((_zp_signed(m.u16((param_1 + ((((((uVar7) & 0xffffffff) + ((3) & 0xffffffff))) & 0xffffffff)) * 2)), 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32)) & 0xffff))
				_pc = 61
			63:
				m.set_u16((param_1 + ((((((uVar7) & 0xffffffff) + ((5) & 0xffffffff))) & 0xffffffff)) * 2), ((_zp_signed((_zp_signed(m.u16((param_1 + ((((((uVar7) & 0xffffffff) + ((5) & 0xffffffff))) & 0xffffffff)) * 2)), 32) | _zp_signed(((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffff), 32)), 32)) & 0xffff))
				_pc = 62
			64:
				var _v24: int = f56a030(uVar7)
				bVar1 = ((_v24) & 0xff)
				_pc = 63
			65:
				var _v25: int = f5ada20(uVar7, ((0xa56434 + (((m.u16(0xa57822)) & 0xffffffff)) * 4) + (((((((((((uVar7) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4), 0, 1, 0, 0xb, ((m.u16(0xa57822)) & 0xffffffff))
				_pc = 64
			66:
				return _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) < _zp_signed(0x200, 32)))), 32), 32) & _zp_signed(7, 32)), 32), 32) + _zp_signed(0x77, 32)), 32), 8)
			67:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff00, 32)), 32), 32) + _zp_signed(0x100, 32)), 32), 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 66
			68:
				var _v26: int = f579930(uVar7, 3, uVar6)
				_pc = 67
			69:
				var _v27: int = f56d3f0(uVar7)
				uVar6 = ((_v27) & 0xffffffff)
				_pc = 68
			70:
				var _v28: int = f579890()
				_pc = 1
			71:
				_pc = 74 if (int(_zp_signed(_zp_signed(uVar7, 32), 32) < _zp_signed(2, 32))) != 0 else 70
			72:
				uVar7 = (((((((uVar7) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 71
			73:
				var _v29: int = f576170(uVar10, m.u16((param_1 + ((((((uVar10) & 0xffffffff) + ((5) & 0xffffffff))) & 0xffffffff)) * 2)))
				_pc = 72
			74:
				uVar10 = (((((((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) ^ ((uVar7) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 73
			75:
				uVar7 = ((0) & 0xffffffff)
				_pc = 74
			76:
				var _v30: int = _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)
				_pc = 1
				if _v30 == 0x80: _pc = 21
				if _v30 == 0x7f: _pc = 27
				if _v30 == 0x7e: _pc = 56
				if _v30 == 0x7d: _pc = 58
				if _v30 == 0x7c: _pc = 60
				if _v30 == 0x7b: _pc = 65
				if _v30 == 0x78: _pc = 69
				if _v30 == 0x77: _pc = 75
			77:
				uVar7 = (((((((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) ^ ((((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 76
	return 0


func f58bf40(param_1: int) -> int:
	var iVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var puVar5: int = 0
	var puVar6: int = 0
	var _pc: int = 32
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f5784e0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), _zp_signed((_zp_signed(iVar2, 32) * _zp_signed(500, 32)), 32))
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(0, 32) < _zp_signed(iVar2, 32))) != 0 else 1
			4:
				_pc = 12 if (int(_zp_signed(_zp_signed(uVar3, 32), 32) < _zp_signed(2, 32))) != 0 else 3
			5:
				uVar3 = (((((((uVar3) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 4
			6:
				_pc = 10 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 5
			7:
				iVar4 = _zp_signed(_zp_signed((_zp_signed(iVar4, 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 32)
				_pc = 6
			8:
				puVar5 = (((puVar5 + (0x24) * 4)) & 0xffffffff)
				_pc = 7
			9:
				iVar2 = _zp_signed(_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 8
			10:
				var _v2: int = int((int((int((((((((m.u32(puVar5)) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(puVar5, 32), 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0)
				if _v2 != 0:
					var _v1: int = f567990(_zp_signed((_zp_signed(((m.u32(puVar5)) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32))
					iVar1 = _zp_signed(_v1, 32)
					_v2 = int((int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0)
				_pc = 9 if (_v2) != 0 else 8
			11:
				puVar5 = (((0xa55d74 + (((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)
				_pc = 10
			12:
				iVar4 = _zp_signed(5, 32)
				_pc = 11
			13:
				uVar3 = ((0) & 0xffffffff)
				_pc = 12
			14:
				iVar2 = _zp_signed(0, 32)
				_pc = 13
			15:
				return ((0x7f) & 0xffffffff)
			16:
				_pc = 28 if (int(_zp_signed(iVar2, 32) < _zp_signed(2, 32))) != 0 else 15
			17:
				iVar2 = _zp_signed(_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 16
			18:
				_pc = 23 if (int(_zp_signed(iVar4, 32) < _zp_signed(5, 32))) != 0 else 17
			19:
				puVar6 = (((puVar6 + (0x48) * 2)) & 0xffffffff)
				_pc = 18
			20:
				iVar4 = _zp_signed(_zp_signed((_zp_signed(iVar4, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 19
			21:
				var _v3: int = f574f40(param_1, uVar3, iVar4, 0)
				_pc = 20
			22:
				_pc = 21 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u16(puVar6), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16(puVar6), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 20
			23:
				_pc = 22 if (int((((((((m.u32((((puVar6 + (_zp_signed((-(3)), 32)) * 2)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 20
			24:
				puVar6 = (((0xa55d7a + (((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)
				_pc = 23
			25:
				iVar4 = _zp_signed(0, 32)
				_pc = 24
			26:
				uVar3 = ((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 25
			27:
				uVar3 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 25
			28:
				_pc = 26 if (int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0 else 27
			29:
				iVar2 = _zp_signed(0, 32)
				_pc = 28
			30:
				_pc = 29 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			31:
				_pc = 14 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 30
			32:
				_pc = 31 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58c080(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var puVar1: int = 0
	var uVar2: int = 0
	var sVar3: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var extraout_var: int = 0
	var in_EDX: int = 0
	var uVar8: int = 0
	var uVar9: int = 0
	var _pc: int = 37
	while true:
		match _pc:
			0:
				return _zp_signed(0, 32)
			1:
				return _zp_signed(0, 32)
			2:
				return _zp_signed(0x7f, 32)
			3:
				var _v1: int = int((int(_zp_signed(uVar4, 32) < _zp_signed(0x15, 32))) != 0)
				if _v1 != 0:
					var _v0: int = f567620(uVar2, 0xffffffff)
					iVar5 = _zp_signed(_v0, 32)
					_v1 = int((int(_zp_signed(iVar5, 32) != _zp_signed(0, 32))) != 0)
				_pc = 2 if (_v1) != 0 else 1
			4:
				var _v2: int = f4025d0(uVar2)
				uVar4 = ((_v2) & 0xffff)
				_pc = 3
			5:
				return _zp_signed((((((((((((((-(((int(_zp_signed(sVar3, 32) != _zp_signed(0x15, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0xffffff81) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((0x7f) & 0xffffffff))) & 0xffffffff), 32)
			6:
				var _v3: int = f4025d0(uVar2)
				sVar3 = _zp_signed(_v3, 16)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(sVar3, 32) == _zp_signed(0x486, 32))) != 0 else 1
			8:
				_pc = 4 if (int(_zp_signed(sVar3, 32) == _zp_signed(0x485, 32))) != 0 else 7
			9:
				var _v4: int = f4022e0((((extraout_var) << 16) | ((m.u16(puVar1)) & 0xffff)))
				sVar3 = _zp_signed(_v4, 16)
				_pc = 8
			10:
				var _v5: int = f577950(puVar1, uVar9, uVar8, 0)
				_pc = 9
			11:
				var _v6: int = f578430(uVar9, uVar2)
				_pc = 10
			12:
				var _v7: int = f574f40(puVar1, uVar9, uVar8, 0)
				_pc = 11
			13:
				m.set_u16((puVar1 + (4) * 2), ((uVar2) & 0xffff))
				_pc = 12
			14:
				uVar2 = ((_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar6) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar8) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 13
			15:
				var _v9: int = int((int((int((((((((m.u32((0xa55d74 + (((((((((((uVar6) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar8) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar6) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar8) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0)
				if _v9 != 0:
					var _v8: int = f583510(puVar1, uVar9, uVar8)
					iVar5 = _zp_signed(_v8, 32)
					_v9 = int((int(_zp_signed(iVar5, 32) != _zp_signed(0, 32))) != 0)
				_pc = 14 if (_v9) != 0 else 1
			16:
				uVar6 = (((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				uVar9 = (((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 16
			18:
				uVar8 = ((((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 17
			19:
				_pc = 18 if (int(_zp_signed(iVar5, 32) != _zp_signed(0, 32))) != 0 else 1
			20:
				var _v10: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar5 = _zp_signed(_v10, 32)
				_pc = 19
			21:
				return _zp_signed(0x7e, 32)
			22:
				var _v11: int = f579020(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar7, 1, 0)
				_pc = 21
			23:
				var _v12: int = f4022e0(m.u16((m.u32((_params + 0)) + (4) * 2)))
				uVar7 = ((_v12) & 0xffffffff)
				_pc = 22
			24:
				return _zp_signed(0x7d, 32)
			25:
				var _v13: int = f579020(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), uVar7, 1, 1)
				_pc = 24
			26:
				var _v14: int = f4022e0(m.u16((m.u32((_params + 0)) + (4) * 2)))
				uVar7 = ((_v14) & 0xffffffff)
				_pc = 25
			27:
				return _zp_signed(0x7c, 32)
			28:
				var _v15: int = f5bcf20(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 27
			29:
				return _zp_signed(0x7b, 32)
			30:
				var _v16: int = f5bcf20(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32))
				_pc = 29
			31:
				return _zp_signed(0x7a, 32)
			32:
				var _v17: int = f5b9170(((((((((_zp_signed((((((((in_EDX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zp_signed((_zp_signed(m.u16((m.u32((_params + 0)) + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 31
			33:
				return _zp_signed(1, 32)
			34:
				var _v18: int = f5b9170((((((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(1, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 33
			35:
				var _v19: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 1
				if _v19 == 0x80: _pc = 20
				if _v19 == 0x7f: _pc = 23
				if _v19 == 0x7e: _pc = 26
				if _v19 == 0x7d: _pc = 28
				if _v19 == 0x7c: _pc = 30
				if _v19 == 0x7b: _pc = 32
				if _v19 == 0x7a: _pc = 34
			36:
				_pc = 35 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			37:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 36
	return 0


func f58c2e0(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var in_EAX: int = 0
	var extraout_var: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 13
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5b9170((((((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(1, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x1f) & 0xffffffff))) & 0xffffffff), uVar3, uVar4, 0)
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f4022e0(uVar2)
				uVar3 = ((_v1) & 0xffffffff)
				_pc = 2
			4:
				var _v2: int = f578430(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), uVar2)
				_pc = 3
			5:
				var _v3: int = f5b9170((((((((((((((extraout_var) << 16) | ((_zp_signed(m.u16((param_1 + (1) * 2)), 16)) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(((_zp_signed(m.u16((param_1 + (1) * 2)), 16)) & 0xff), 32) & _zp_signed(1, 32)), 32), 32)), 32), (((((((((((((((uVar4) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 4
			6:
				var _v4: int = f5b9170((((((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(1, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x21) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 5
			7:
				var _v5: int = f570230(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 0xb, uVar4)
				uVar2 = ((_v5) & 0xffff)
				_pc = 6
			8:
				var _v6: int = f5bddb0((((((in_EAX) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				uVar4 = ((_v6) & 0xffffffff)
				_pc = 7
			9:
				var _v7: int = int((int((int(_zp_signed(_zp_signed(in_EAX, 16), 32) == _zp_signed(_zp_signed(m.u16(param_1), 16), 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0x3000, 32)), 32), 32) == _zp_signed(0x1000, 32))) != 0)) != 0)
				if _v7 != 0:
					in_EAX = ((((((m.u16((0xa55d68 + (((((((((((((((((((-(uVar4))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2))) & 0xffff)) & 0xffffffff)) & 0xffffffff)
					_v7 = int((int(_zp_signed(_zp_signed(m.u16((0xa55d68 + (((((((((((((((((((-(uVar4))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)), 8), 32) != _zp_signed(0, 32))) != 0)
				_pc = 8 if (_v7) != 0 else 1
			10:
				in_EAX = (((((((m.u32((0xa55d74 + ((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32)) & 0xffffffff) + (((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				uVar4 = ((_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 10
			12:
				uVar1 = ((_zp_signed(m.u16((param_1 + (1) * 2)), 16)) & 0xffff)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58c490(param_1: int) -> int:
	var psVar1: int = 0
	var puVar2: int = 0
	var bVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var iVar6: int = 0
	var uVar7: int = 0
	var iVar8: int = 0
	var uVar9: int = 0
	var iVar10: int = 0
	var uVar11: int = 0
	var uVar12: int = 0
	var unaff_EDI: int = 0
	var puVar13: int = 0
	var uVar14: int = 0
	var bVar15: int = 0
	var _pc: int = 79
	while true:
		match _pc:
			0:
				return _zp_signed(0, 8)
			1:
				return _zp_signed(123, 8)
			2:
				return _zp_signed(127, 8)
			3:
				_pc = 7 if (int(_zp_signed(_zp_signed(uVar12, 32), 32) < _zp_signed(2, 32))) != 0 else 2
			4:
				uVar12 = (((((((uVar12) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 3
			5:
				var _v0: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar7) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0x60) & 0xff)), 1, 0, 0)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(_zp_signed(m.u16((((((((_zp_signed((_zp_signed(iVar8, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff) + (((((((uVar7) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 16), 32) != _zp_signed(0, 32))) != 0 else 4
			7:
				uVar7 = (((((((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) ^ ((uVar12) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 6
			8:
				uVar12 = ((0) & 0xffffffff)
				_pc = 7
			9:
				var _v1: int = f577aa0(iVar8, 0x1f001f)
				_pc = 8
			10:
				_pc = 21 if (int(_zp_signed(_zp_signed(param_1, 32), 32) < _zp_signed(2, 32))) != 0 else 9
			11:
				param_1 = (((((((param_1) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 10
			12:
				_pc = 19 if (int(_zp_signed(iVar10, 32) != _zp_signed(0, 32))) != 0 else 11
			13:
				iVar10 = _zp_signed(_zp_signed((_zp_signed(iVar10, 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 32)
				_pc = 12
			14:
				puVar13 = (((puVar13 + (0x24) * 4)) & 0xffffffff)
				_pc = 13
			15:
				m.set_u16(psVar1, _zp_signed(_zp_signed((_zp_signed(_zp_signed(m.u16(psVar1), 16), 32) + _zp_signed(1, 32)), 32), 16))
				_pc = 14
			16:
				psVar1 = (((((((((_zp_signed((_zp_signed(iVar8, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff) + (((((((((((((((((m.u32(puVar13)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				var _v7: int = int((int(_zp_signed(iVar6, 32) != _zp_signed(0, 32))) != 0)
				if _v7 != 0:
					var _v2: int = f4022e0(uVar5)
					uVar4 = ((_v2) & 0xffff)
					var _v4: int = int((int(_zp_signed(uVar4, 32) < _zp_signed(0x780, 32))) != 0)
					if _v4 == 0:
						var _v3: int = f4022e0(uVar5)
						uVar4 = ((_v3) & 0xffff)
						_v4 = int((int(_zp_signed(0x783, 32) < _zp_signed(uVar4, 32))) != 0)
					var _v6: int = int((_v4) != 0)
					if _v6 != 0:
						var _v5: int = f567ad0(uVar5)
						iVar6 = _zp_signed(_v5, 32)
						_v6 = int((int(_zp_signed(iVar6, 32) == _zp_signed(0, 32))) != 0)
					_v7 = int((_v6) != 0)
				_pc = 16 if (_v7) != 0 else 14
			18:
				var _v8: int = f402690(uVar5)
				iVar6 = _zp_signed(_v8, 32)
				_pc = 17
			19:
				uVar5 = ((_zp_signed((_zp_signed(((m.u32(puVar13)) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32)) & 0xffff)
				_pc = 18
			20:
				puVar13 = (((0xa55d74 + (((((((((((param_1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)
				_pc = 19
			21:
				iVar10 = _zp_signed(5, 32)
				_pc = 20
			22:
				param_1 = ((0) & 0xffffffff)
				_pc = 21
			23:
				m.set_u16((((((((param_1) & 0xffffffff) + ((8) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((0) & 0xffff))
				_pc = 22
			24:
				m.set_u16((((((((param_1) & 0xffffffff) + ((6) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((0) & 0xffff))
				_pc = 23
			25:
				return _zp_signed(126, 8)
			26:
				var _v9: int = f579810()
				_pc = 25
			27:
				m.set_u32(0xa55c8c, (((((m.u16(0xa55c8e)) << 16) | ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(((_zp_signed((_zp_signed(bVar3, 32) ^ _zp_signed(m.u8(0xa55c8c), 32)), 32)) & 0xffff), 32) ^ _zp_signed(((m.u32(0xa55c8c)) & 0xffff), 32)), 32), 32) | _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar5, 32) & _zp_signed(0x7f, 32)), 32), 32) << ((1) & 31)), 32), 32)), 32)) & 0xffff))) & 0xffffffff))
				_pc = 26
			28:
				var _v10: int = f570b40(1)
				uVar5 = ((_v10) & 0xffff)
				_pc = 27
			29:
				var _v11: int = f570b40(0)
				bVar3 = ((_v11) & 0xff)
				_pc = 28
			30:
				m.set_u16((((((((param_1) & 0xffffffff) + ((0xc) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((0) & 0xffff))
				_pc = 29
			31:
				m.set_u16((((((((param_1) & 0xffffffff) + ((10) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((0) & 0xffff))
				_pc = 30
			32:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((((((((((m.u16(0xa577fa)) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0x1ff) & 0xffffffff))) & 0xffffffff)) & 0xffff))
				_pc = 31
			33:
				return _zp_signed(124, 8)
			34:
				return _zp_signed(125, 8)
			35:
				var _v12: int = f5675c0(0xa55c90, (0xa56574 + ((((((uVar7) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4))
				_pc = 34
			36:
				var _v14: int = int((int(_zp_signed(uVar5, 32) < _zp_signed(5, 32))) != 0)
				if _v14 != 0:
					var _v13: int = f570b70(uVar12, uVar14)
					iVar8 = _zp_signed(_v13, 32)
					_v14 = int((int(_zp_signed(iVar8, 32) != _zp_signed(0, 32))) != 0)
				var _v16: int = int((_v14) != 0)
				if _v16 != 0:
					var _v15: int = f56a000(uVar11)
					iVar8 = _zp_signed(_v15, 32)
					_v16 = int((int((int(_zp_signed(0, 32) < _zp_signed(iVar8, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(0xa55c8c), 32) >> ((_zp_signed(uVar11, 8)) & 31)), 32), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0)
				_pc = 35 if (_v16) != 0 else 33
			37:
				var _v17: int = f4026c0(uVar14)
				uVar5 = ((_v17) & 0xffff)
				_pc = 36
			38:
				m.set_u16(psVar1, _zp_signed(_zp_signed((_zp_signed(_zp_signed(m.u16(psVar1), 16), 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 16))
				_pc = 37
			39:
				psVar1 = ((((((((((((((param_1) & 0xffffffff) + ((6) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar12) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 38
			40:
				_pc = 39 if (int(_zp_signed(iVar8, 32) != _zp_signed(0, 32))) != 0 else 33
			41:
				var _v18: int = f402690(uVar14)
				iVar8 = _zp_signed(_v18, 32)
				_pc = 40
			42:
				var _v19: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar12) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0xf1) & 0xff)), 0x1e, 0, 0)
				_pc = 41
			43:
				var _v20: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(((uVar12) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0x20) & 0xff)), uVar9, 0xd, 0)
				_pc = 42
			44:
				var _v21: int = f4022e0(uVar14)
				uVar9 = ((_v21) & 0xffffffff)
				_pc = 43
			45:
				_pc = 44 if (int(_zp_signed(iVar8, 32) == _zp_signed(0, 32))) != 0 else 42
			46:
				var _v22: int = f570be0(uVar12, (0xa56574 + ((((((uVar7) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4))
				iVar8 = _zp_signed(_v22, 32)
				_pc = 45
			47:
				var _v23: int = f578430(uVar12, uVar14)
				_pc = 46
			48:
				uVar11 = ((((((((((((((m.u32((0xa56574 + ((((((uVar7) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 47
			49:
				uVar14 = ((((((((((_zp_signed((((((((unaff_EDI) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((((0xa56574 + ((((((uVar7) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff))) & 0xffff))) & 0xffffffff) & ((0xffff0fff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 48
			50:
				uVar7 = (((((((uVar12) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 49
			51:
				_pc = 50 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u16((0xa55d68 + (((((((((((uVar12) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)), 32) & _zp_signed(0xff00, 32)), 32), 32) != _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed(m.u16(((((((((((((param_1) & 0xffffffff) + ((6) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar12) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 16), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			52:
				uVar12 = ((((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 51
			53:
				m.set_u16(puVar2, ((_zp_signed((_zp_signed(m.u16(puVar2), 32) | _zp_signed(((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(bVar3, 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffff), 32)), 32)) & 0xffff))
				_pc = 1
			54:
				puVar2 = ((((((((((((((param_1) & 0xffffffff) + ((10) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar12) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
				_pc = 53
			55:
				var _v24: int = f56a030(uVar12)
				bVar3 = ((_v24) & 0xff)
				_pc = 54
			56:
				var _v25: int = f5ada20(uVar12, 0xa55c90, uVar9, 1, 0, 0xd, _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32))
				_pc = 55
			57:
				var _v26: int = f567a00((((((m.u32(0xa55c90)) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff))
				uVar9 = ((_v26) & 0xffffffff)
				_pc = 56
			58:
				uVar12 = ((((((((((((m.u32(0xa55c90)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 57
			59:
				return _zp_signed(126, 8)
			60:
				return _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(bVar15)), 32), 32) & _zp_signed(6, 32)), 32), 32) + _zp_signed(0x78, 32)), 32), 8)
			61:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((uVar4) & 0xffff))
				_pc = 60
			62:
				bVar15 = ((int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32), 32))) & 0xff)
				_pc = 61
			63:
				m.set_u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff), ((((_zp_signed((_zp_signed(uVar5, 32) >> ((8) & 31)), 32)) & 0xff)) & 0xff))
				_pc = 62
			64:
				uVar4 = ((m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffff)
				_pc = 63
			65:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(uVar5, 32) ^ _zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32), 32)), 32)) & 0xffff))
				_pc = 64
			66:
				uVar5 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) * _zp_signed(_zp_signed((-(0x100)), 32), 32)), 32), 32) + _zp_signed(0x100, 32)), 32)) & 0xffff)
				_pc = 65
			67:
				_pc = 66 if (int(_zp_signed(_zp_signed(m.u16(((((((((((((param_1) & 0xffffffff) + ((6) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 16), 32) == _zp_signed(0, 32))) != 0 else 59
			68:
				var _v27: int = f578bb0(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 1, int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) != _zp_signed(_zp_signed((_zp_signed(m.u8((((((((param_1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)))
				_pc = 67
			69:
				return _zp_signed(0, 8)
			70:
				var _v28: int = f579890()
				_pc = 69
			71:
				_pc = 74 if (int(_zp_signed(_zp_signed(uVar12, 32), 32) < _zp_signed(2, 32))) != 0 else 70
			72:
				uVar12 = (((((((uVar12) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 71
			73:
				var _v29: int = f576170(uVar7, m.u16(((((((((((((param_1) & 0xffffffff) + ((10) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar7) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)))
				_pc = 72
			74:
				uVar7 = (((((((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) ^ ((uVar12) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 73
			75:
				uVar12 = ((0) & 0xffffffff)
				_pc = 74
			76:
				var _v30: int = _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)
				_pc = 69
				if _v30 == 0x80: _pc = 24
				if _v30 == 0x7f: _pc = 32
				if _v30 == 0x7e: _pc = 52
				if _v30 == 0x7d: _pc = 58
				if _v30 == 0x7b: _pc = 67
				if _v30 == 0x7c: _pc = 68
				if _v30 == 0x78: _pc = 75
			77:
				return _zp_signed(0, 8)
			78:
				_pc = 77 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((param_1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 76
			79:
				iVar8 = _zp_signed(param_1, 32)
				_pc = 78
	return 0


func f58c890(param_1: int) -> int:
	var uVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var iVar5: int = 0
	var iVar6: int = 0
	var _pc: int = 16
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				_pc = 11 if (int(_zp_signed(iVar6, 32) < _zp_signed(0x2d0, 32))) != 0 else 1
			3:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 2
			4:
				iVar6 = _zp_signed(_zp_signed((_zp_signed(iVar6, 32) + _zp_signed(0x90, 32)), 32), 32)
				_pc = 3
			5:
				var _v0: int = f5751e0(param_1, _zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), iVar5, 0, 0)
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 4
			6:
				var _v3: int = int((int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)
				if _v3 != 0:
					var _v2: int = int((int((int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0 or (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0)
					if _v2 == 0:
						var _v1: int = f56f6d0(_zp_signed((_zp_signed(iVar4, 32) + _zp_signed(1, 32)), 32), iVar5)
						uVar3 = ((_v1) & 0xffffffff)
						_v2 = int((int(_zp_signed(_zp_signed(uVar3, 16), 32) != _zp_signed(1, 32))) != 0)
					_v3 = int((_v2) != 0)
				_pc = 5 if (_v3) != 0 else 4
			7:
				uVar3 = (((((_zp_signed((((((uVar3) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((uVar1) & 0xffff))) & 0xffffffff)
				_pc = 6
			8:
				uVar1 = ((m.u16((((((((_zp_signed(0xa55d7a, 32)) & 0xffffffff) + ((uVar3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffff)
				_pc = 7
			9:
				_pc = 8 if (int((((((((m.u32((((((((_zp_signed(0xa55d74, 32)) & 0xffffffff) + ((uVar3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 4
			10:
				uVar3 = ((_zp_signed((_zp_signed(iVar6, 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(iVar4, 32) - _zp_signed(1, 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0xd44, 32)), 32), 32)), 32)) & 0xffffffff)
				_pc = 9
			11:
				iVar4 = _zp_signed(_zp_signed((-(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))), 32), 32)
				_pc = 10
			12:
				iVar5 = _zp_signed(0, 32)
				_pc = 11
			13:
				var _v4: int = f5699c0(0x148)
				iVar2 = _zp_signed(_v4, 32)
				_pc = 12
			14:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			15:
				_pc = 14 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 13
			16:
				iVar6 = _zp_signed(0, 32)
				_pc = 15
	return 0


func f58c950(param_1: int) -> int:
	var _stack: int = m.local(8)
	var uVar1: int = 0
	var uVar2: int = 0
	var in_EAX: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f574810(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar6, m.u32((_stack + 4)), 0x10c)
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f574810(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar6, m.u32((_stack + 0)), 0xc)
				_pc = 2
			4:
				uVar6 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(iVar3, 32) / _zp_signed(5, 32)), 32), 32) | _zp_signed(0x4000, 32)), 32)) & 0xffffffff)
				_pc = 3
			5:
				var _v2: int = int((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar5) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2) + (((((((((((uVar6) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)
				if _v2 != 0:
					in_EAX = ((0) & 0xffffffff)
					_v2 = int((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + (((((((((((uVar1) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2) + (((((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)
				_pc = 4 if (_v2) != 0 else 1
			6:
				in_EAX = ((0) & 0xffffffff)
				_pc = 5
			7:
				var _v3: int = f5be050(uVar4)
				iVar3 = _zp_signed(_v3, 32)
				_pc = 6
			8:
				var _v4: int = f56f690((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar5)
				uVar4 = ((_v4) & 0xffffffff)
				_pc = 7
			9:
				uVar1 = (((((((m.u32((_stack + 4))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff)
				_pc = 8
			10:
				uVar5 = ((((((((((((m.u32((_stack + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			12:
				in_EAX = ((0) & 0xffffffff)
				_pc = 11
			13:
				uVar6 = ((m.u32((_stack + 0))) & 0xffffffff)
				_pc = 12
			14:
				uVar2 = ((m.u32((_stack + 4))) & 0xffffffff)
				_pc = 13
			15:
				var _v5: int = f583470(param_1, 1, (_stack + 4))
				iVar3 = _zp_signed(_v5, 32)
				_pc = 14
			16:
				_pc = 15 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			17:
				in_EAX = ((0) & 0xffffffff)
				_pc = 16
			18:
				var _v6: int = f583470(param_1, 0, (_stack + 0))
				iVar3 = _zp_signed(_v6, 32)
				_pc = 17
			19:
				_pc = 18 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58ca70(param_1: int) -> int:
	var puVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar5: int = 0
	var uVar4: int = 0
	var puVar6: int = 0
	var puVar7: int = 0
	var puVar8: int = 0
	var _pc: int = 27
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((((uVar5) & 0xffffffff)) & 0xffffffff) << ((0x10) & 31))) & 0xffffffff)) & 0xffffffff)
			2:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			3:
				_pc = 7 if (int(_zp_signed(_zp_signed(param_1, 32), 32) < _zp_signed(5, 32))) != 0 else 2
			4:
				puVar8 = (((puVar8 + (0x24) * 4)) & 0xffffffff)
				_pc = 3
			5:
				param_1 = ((((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(1, 32)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 4
			6:
				var _v0: int = f574810(_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), (((_zp_signed((((((((param_1) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(puVar1)) & 0xffff)), (((_zp_signed(param_1, 8)) << 8) | ((_zp_signed(puVar6, 8)) & 0xff)), (((((((((((((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xc) & 0xffffffff))) & 0xffffffff))
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(puVar8, 32), 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0 and (int((((((((m.u32(puVar8)) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)) != 0 else 5
			8:
				puVar8 = (((0xa55d74 + ((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)
				_pc = 7
			9:
				param_1 = ((((0x0) & 0xffffffff)) & 0xffffffff)
				_pc = 8
			10:
				uVar4 = (((((((((puVar6) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				var _v1: int = f5b9170((((((((((((((_zp_signed((((((((iVar2) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((((puVar7) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), uVar3, _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 0)
				_pc = 10
			12:
				puVar7 = ((((0xe2) & 0xffffffff)) & 0xffffffff)
				_pc = 11
			13:
				puVar6 = ((((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 12
			14:
				iVar2 = _zp_signed(0, 32)
				_pc = 13
			15:
				puVar7 = ((((0xe3) & 0xffffffff)) & 0xffffffff)
				_pc = 11
			16:
				puVar6 = ((((_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				_pc = 16 if (int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0 else 11
			18:
				puVar7 = ((param_1) & 0xffffffff)
				_pc = 17
			19:
				puVar6 = ((param_1) & 0xffffffff)
				_pc = 18
			20:
				iVar2 = _zp_signed(((((((((((uVar4) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) - ((0x4b4) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 19
			21:
				_pc = 14 if (int((((((((uVar4) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0x4b3) & 0xffffffff))) != 0 else 20
			22:
				var _v2: int = f4022e0((((uVar5) << 16) | ((m.u16(param_1)) & 0xffff)))
				uVar4 = ((_v2) & 0xffffffff)
				_pc = 21
			23:
				_pc = 22 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			24:
				uVar5 = (((((((((uVar3) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 23
			25:
				uVar3 = ((_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 24
			26:
				var _v3: int = f5bddb0(6)
				iVar2 = _zp_signed(_v3, 32)
				_pc = 25
			27:
				puVar1 = ((param_1) & 0xffffffff)
				_pc = 26
	return 0


func f58cb70(param_1: int) -> int:
	var uVar1: int = 0
	var in_EDX: int = 0
	var uVar2: int = 0
	var _pc: int = 16
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7f) & 0xffffffff)
			2:
				var _v0: int = f5bcec0(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 1
			3:
				return ((0) & 0xffffffff)
			4:
				_pc = 3 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 2
			5:
				return ((0x7e) & 0xffffffff)
			6:
				var _v1: int = f5bcec0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32))
				_pc = 5
			7:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff), ((m.u16(0xa57822)) & 0xffff))
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 4
			9:
				return ((100) & 0xffffffff)
			10:
				var _v2: int = f5b9170(((((((((uVar2) << 16) | ((_zp_signed((_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((199) & 0xffffffff))) & 0xffffffff), uVar1, (((uVar2) << 16) | ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff))) & 0xffff)), 0)
				_pc = 9
			11:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(8, 32)), 32)) & 0xffffffff), ((m.u16(0xa57822)) & 0xffff))
				_pc = 10
			12:
				uVar2 = (((((((((((in_EDX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) & 0xffff)) & 0xffff)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 8
			14:
				return ((0) & 0xffffffff)
			15:
				_pc = 14 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 13
			16:
				uVar1 = ((m.u16(0xa57822)) & 0xffff)
				_pc = 15
	return 0


func f58cc00(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 11
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				_pc = 10 if (int(_zp_signed(_zp_signed(uVar4, 32), 32) < _zp_signed(2, 32))) != 0 else 1
			3:
				uVar4 = (((((((uVar4) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 2
			4:
				var _v0: int = f577950(param_1, _zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), uVar3, 0)
				uVar2 = ((_v0) & 0xffffffff)
				_pc = 3
			5:
				_pc = 4 if (int((((((((((((((((((((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((uVar2) & 0xffffffff))) != 0 else 3
			6:
				uVar2 = ((((_zp_signed((_zp_signed(uVar1, 32) >> ((8) & 31)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			7:
				uVar3 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(7, 32)), 32)) & 0xffffffff)
				_pc = 6
			8:
				var _v1: int = f578250(param_1, uVar4, 0)
				uVar2 = ((_v1) & 0xffffffff)
				_pc = 3
			9:
				_pc = 7 if (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0x10, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 8
			10:
				uVar1 = ((m.u16((((0xa57844 + (((((((((((_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) ^ ((uVar4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x10) & 0xffffffff))) & 0xffffffff)) * 1)) & 0xffffffff))) & 0xffff)
				_pc = 9
			11:
				uVar4 = ((0) & 0xffffffff)
				_pc = 10
	return 0


func f58cca0(param_1: int) -> int:
	var bVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 25
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				m.set_u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) | _zp_signed(8, 32)), 32)) & 0xff))
				_pc = 1
			3:
				return ((0) & 0xffffffff)
			4:
				var _v0: int = f574990(uVar4, ((((((((_zp_signed((_zp_signed(((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff), 32) >> ((1) & 31)), 32)) << 8) | ((m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), uVar3)
				_pc = 3
			5:
				_pc = 4 if (int(((uVar4) & 0xffffffff) == (((((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) != 0 else 2
			6:
				uVar4 = ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int((int((((((((m.u32((0xa55d74 + ((((((((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar4) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + (((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar4) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 2
			8:
				uVar4 = ((((((((((((uVar3) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				var _v1: int = f583440(param_1, 0)
				uVar3 = ((_v1) & 0xffffffff)
				_pc = 8
			10:
				return ((0) & 0xffffffff)
			11:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(uVar2, 32) | _zp_signed(8, 32)), 32)) & 0xffff))
				_pc = 10
			12:
				_pc = 11 if (int(_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(10, 32)), 32)) & 0xffffffff)), 16), 32) == _zp_signed(1, 32))) != 0 else 9
			13:
				return ((0x7f) & 0xffffffff)
			14:
				var _v2: int = f5751e0(param_1, bVar1, uVar3, 0, 0)
				_pc = 13
			15:
				_pc = 14 if (int((int((int((((((((m.u32((0xa55d74 + ((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2) + ((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(bVar1, 32))) != 0)) != 0 else 13
			16:
				uVar3 = ((((m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x11, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 15
			17:
				bVar1 = ((m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x10, 32)), 32)) & 0xffffffff))) & 0xff)
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(10, 32)), 32)) & 0xffffffff)), 16), 32) != _zp_signed(2, 32))) != 0 else 13
			19:
				return ((0) & 0xffffffff)
			20:
				_pc = 19 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 18
			21:
				_pc = 20 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(127, 32))) != 0 else 12
			22:
				return ((0) & 0xffffffff)
			23:
				m.set_u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff), ((_zp_signed((_zp_signed(uVar2, 32) | _zp_signed(8, 32)), 32)) & 0xffff))
				_pc = 22
			24:
				_pc = 23 if (int(_zp_signed(_zp_signed((_zp_signed(uVar2, 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 21
			25:
				uVar2 = ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff))) & 0xffff)
				_pc = 24
	return 0


func f58ceb0(param_1: int) -> int:
	var uVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 14
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5ada20(((((((((((uVar1) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff), uVar4, 1, ((((((((((uVar1) & 0xffffffff) >> ((0xd) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff), 0x20, 0xe, (((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f5700f0((((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), 0xe, (((((uVar3) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff))
				uVar4 = ((_v1) & 0xffffffff)
				_pc = 2
			4:
				_pc = 3 if (int(((((((((((((uVar3) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0xe) & 0xffffffff))) != 0 else 1
			5:
				var _v2: int = f5687d0((((((uVar1) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				uVar3 = ((_v2) & 0xffffffff)
				_pc = 4
			6:
				uVar1 = ((m.u32(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x10, 32)), 32)) & 0xffffffff))) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			8:
				uVar3 = ((0) & 0xffffffff)
				_pc = 7
			9:
				var _v3: int = f570b40(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v3, 32)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			11:
				uVar3 = ((0) & 0xffffffff)
				_pc = 10
			12:
				var _v4: int = f56a000(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v4, 32)
				_pc = 11
			13:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 12
	return 0


func f58cfd0(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var extraout_var: int = 0
	var uVar4: int = 0
	var iVar5: int = 0
	var puVar6: int = 0
	var uVar7: int = 0
	var local_8: int = 0
	var _pc: int = 43
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7e) & 0xffffffff)
			3:
				_pc = 9 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar5, 32))) != 0 else 2
			4:
				puVar6 = (((puVar6 + (_zp_signed((-(2)), 32)) * 2)) & 0xffffffff)
				_pc = 3
			5:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 32)
				_pc = 4
			6:
				var _v0: int = f579310(uVar7, iVar5, uVar3, int(((uVar7) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)))
				_pc = 5
			7:
				var _v1: int = f5700f0(uVar7, 0xb, iVar5)
				uVar3 = ((_v1) & 0xffffffff)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 5
			9:
				var _v2: int = f5674e0(_zp_signed((_zp_signed(m.u16(puVar6), 32) & _zp_signed(0xfff, 32)), 32), uVar4)
				iVar2 = _zp_signed(_v2, 32)
				_pc = 8
			10:
				puVar6 = ((((((0xa56434 + (iVar5) * 4) + (((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar5, 32))) != 0 else 2
			12:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(m.u8((((0xa55d68 + (((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) - _zp_signed(1, 32)), 32), 32)
				_pc = 11
			13:
				return ((0x7d) & 0xffffffff)
			14:
				_pc = 19 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar5, 32))) != 0 else 13
			15:
				puVar6 = (((puVar6 + (_zp_signed((-(2)), 32)) * 2)) & 0xffffffff)
				_pc = 14
			16:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 32)
				_pc = 15
			17:
				var _v3: int = f579690(uVar7, iVar5, int(((uVar7) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)))
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 16
			19:
				var _v4: int = f5674e0(_zp_signed((_zp_signed(m.u16(puVar6), 32) & _zp_signed(0xfff, 32)), 32), uVar4)
				iVar2 = _zp_signed(_v4, 32)
				_pc = 18
			20:
				puVar6 = ((((((0xa566b4 + (iVar5) * 4) + ((((((uVar1) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)) & 0xffffffff)
				_pc = 19
			21:
				_pc = 20 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar5, 32))) != 0 else 13
			22:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((0xa55d6a + ((((((uVar1) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2))) & 0xffff), 32) >> ((8) & 31)), 32), 32) - _zp_signed(1, 32)), 32), 32)
				_pc = 21
			23:
				_pc = 28 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar5, 32))) != 0 else 22
			24:
				local_8 = (((local_8 + (_zp_signed((-(2)), 32)) * 2)) & 0xffffffff)
				_pc = 23
			25:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 32)
				_pc = 24
			26:
				var _v5: int = f579660(uVar7, iVar5, int(((uVar7) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)))
				_pc = 25
			27:
				_pc = 26 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 25
			28:
				var _v6: int = f5674e0(_zp_signed((_zp_signed(m.u16(local_8), 32) & _zp_signed(0xfff, 32)), 32), uVar4)
				iVar2 = _zp_signed(_v6, 32)
				_pc = 27
			29:
				local_8 = ((((((0xa56574 + (iVar5) * 4) + ((((((uVar1) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)) & 0xffffffff)
				_pc = 28
			30:
				_pc = 29 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(iVar5, 32))) != 0 else 22
			31:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((0xa55d68 + ((((((uVar1) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2))) & 0xffff), 32) >> ((8) & 31)), 32), 32) - _zp_signed(1, 32)), 32), 32)
				_pc = 30
			32:
				uVar1 = (((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 31
			33:
				return ((0x78) & 0xffffffff)
			34:
				var _v7: int = f5b9170((((((uVar1) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 33
			35:
				var _v8: int = f5b9170((((_zp_signed((((((uVar1) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((0xf1) & 0xff)), 10, 0, 0)
				_pc = 34
			36:
				uVar1 = ((((((((((-(((int(((uVar7) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 35
			37:
				_pc = 36 if (int(_zp_signed(iVar5, 32) == _zp_signed(0, 32))) != 0 else 33
			38:
				var _v9: int = f567ad0(uVar4)
				iVar5 = _zp_signed(_v9, 32)
				_pc = 37
			39:
				var _v10: int = _zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x7d, 32)), 32)
				_pc = 1
				if _v10 == 3: _pc = 12
				if _v10 == 2: _pc = 12
				if _v10 == 1: _pc = 32
				if _v10 == 0: _pc = 38
			40:
				_pc = 39 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			41:
				uVar7 = (((((((uVar1) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 40
			42:
				uVar4 = (((((extraout_var) << 16) | ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(8, 32)), 32)) & 0xffffffff))) & 0xffff))) & 0xffffffff)
				_pc = 41
			43:
				var _v11: int = f583440(param_1, 0)
				uVar1 = ((_v11) & 0xffffffff)
				_pc = 42
	return 0


func f58d220(param_1: int, param_2: int) -> int:
	var bVar1: int = 0
	var bVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var _pc: int = 21
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f5bd030(1)
				_pc = 1
			3:
				return ((0x7f) & 0xffffffff)
			4:
				var _v1: int = f5b9170((((((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(1, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x33) & 0xffffffff))) & 0xffffffff), m.u8(((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(0x11, 32)), 32)) & 0xffffffff)), ((bVar2) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), 32) + _zp_signed(1, 32)), 32))
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			6:
				var _v2: int = f56b730(m.u8((((param_1 + (8) * 2)) & 0xffffffff)), m.u8(((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(0x11, 32)), 32)) & 0xffffffff)), 0)
				iVar4 = _zp_signed(_v2, 32)
				_pc = 5
			7:
				var _v3: int = f575750(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar3, ((((((((((((bVar2) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) & 0xffffffff))
				_pc = 6
			8:
				var _v4: int = f5747e0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(param_1), uVar3, _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(3, 32)), 32))
				_pc = 7
			9:
				var _v5: int = f56a030(_zp_signed((_zp_signed(bVar1, 32) & _zp_signed(1, 32)), 32))
				bVar2 = ((_v5) & 0xff)
				_pc = 8
			10:
				bVar1 = ((m.u8((((param_1 + (1) * 2)) & 0xffffffff))) & 0xff)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			12:
				var _v6: int = f57b0e0(param_1, uVar3)
				iVar4 = _zp_signed(_v6, 32)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			14:
				var _v7: int = f583470(param_1, 0, 0)
				iVar4 = _zp_signed(_v7, 32)
				_pc = 13
			15:
				_pc = 14 if (int((int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 and (int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)) != 0 else 1
			16:
				_pc = 15 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			17:
				var _v8: int = f581210(param_1, param_2, 0)
				iVar4 = _zp_signed(_v8, 32)
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			19:
				_pc = 2 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 18
			20:
				_pc = 19 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			21:
				var _v9: int = f583440(param_1, 0)
				uVar3 = ((_v9) & 0xffffffff)
				_pc = 20
	return 0


func f58d380(param_1: int) -> int:
	var uVar1: int = 0
	var bVar2: int = 0
	var sVar3: int = 0
	var in_EAX: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var _pc: int = 26
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar5) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f577880(param_1, uVar7, uVar6)
				uVar5 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 1
			4:
				_pc = 3 if (int((bVar2) == 0)) != 0 else 2
			5:
				uVar5 = ((0) & 0xffffffff)
				_pc = 4
			6:
				bVar2 = ((int(_zp_signed(iVar4, 32) < _zp_signed(0x1f5, 32))) & 0xff)
				_pc = 5
			7:
				var _v1: int = f56f6b0(uVar7, uVar6)
				iVar4 = _zp_signed(_v1, 32)
				_pc = 6
			8:
				_pc = 5
			9:
				bVar2 = ((int(_zp_signed(999, 32) < _zp_signed(iVar4, 32))) & 0xff)
				_pc = 8
			10:
				var _v2: int = f56f690(uVar7, uVar6)
				iVar4 = _zp_signed(_v2, 32)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(sVar3, 32) == _zp_signed(0x3ea, 32))) != 0 else 2
			12:
				_pc = 5
			13:
				bVar2 = ((int(_zp_signed(iVar4, 32) < _zp_signed(0x1f5, 32))) & 0xff)
				_pc = 12
			14:
				var _v3: int = f56f690(uVar7, uVar6)
				iVar4 = _zp_signed(_v3, 32)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(sVar3, 32) == _zp_signed(0x2a9, 32))) != 0 else 11
			16:
				_pc = 7 if (int(_zp_signed(sVar3, 32) == _zp_signed(0x2a8, 32))) != 0 else 15
			17:
				var _v4: int = f4022e0(m.u16(param_1))
				sVar3 = _zp_signed(_v4, 16)
				_pc = 16
			18:
				_pc = 1
			19:
				var _v5: int = int((int((int((((((((uVar5) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 or (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar7) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar6) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0)
				if _v5 == 0:
					uVar5 = (((((((((((((((((uVar5) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((uVar5) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
					_v5 = int((int(((uVar5) & 0xffffffff) != ((_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xff, 32)), 32)) & 0xffffffff))) != 0)
				_pc = 18 if (_v5) != 0 else 17
			20:
				uVar5 = ((m.u32((0xa55d74 + (((((((((((uVar7) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)
				_pc = 19
			21:
				_pc = 1
			22:
				_pc = 21 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 20
			23:
				uVar6 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((9) & 31)), 32), 32) & _zp_signed(0xf, 32)), 32)) & 0xffffffff)
				_pc = 22
			24:
				uVar7 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((8) & 31)), 32), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 23
			25:
				uVar5 = (((((_zp_signed((((((((in_EAX) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((m.u8((((param_1 + (2) * 2)) & 0xffffffff))) & 0xff))) & 0xffffffff)
				_pc = 24
			26:
				uVar1 = ((m.u16((param_1 + (8) * 2))) & 0xffff)
				_pc = 25
	return 0


func f58d480(param_1: int, param_2: int) -> int:
	var uVar1: int = 0
	var in_EAX: int = 0
	var uVar2: int = 0
	var _pc: int = 16
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5778b0(param_1, _zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x10, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0x100, 32)), 32), 32) >> ((8) & 31)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x10, 32)), 32)) & 0xffffffff)), 32) >> ((9) & 31)), 32), 32) & _zp_signed(0xf, 32)), 32))
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f5b9170(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xff01, 32)), 32), 32) << ((7) & 31)), 32), 32) | _zp_signed(0xb1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0x1e00, 32)), 32), 32) >> ((9) & 31)), 32), 1, 0)
				_pc = 2
			4:
				_pc = 3 if (int((((((((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((9) & 31)), 32), 32) & _zp_signed(0xf, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((8) & 31)), 32), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 1
			5:
				in_EAX = ((0) & 0xffffffff)
				_pc = 4
			6:
				uVar1 = ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x10, 32)), 32)) & 0xffffffff))) & 0xffff)
				_pc = 5
			7:
				_pc = 6 if (int((int(((0x1f) & 0xffffffff) < ((in_EAX) & 0xffffffff))) != 0 and (int(((in_EAX) & 0xffffffff) < ((0x23) & 0xffffffff))) != 0)) != 0 else 1
			8:
				in_EAX = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xfc0, 32)), 32), 32) >> ((6) & 31)), 32)) & 0xffffffff)
				_pc = 7
			9:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			10:
				var _v2: int = f5778b0(param_1, _zp_signed((_zp_signed(m.u16((param_2 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_2 + (1) * 2))) & 0xffff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32))
				uVar2 = ((_v2) & 0xffffffff)
				_pc = 9
			11:
				m.set_u8((((param_2 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u8((((param_2 + (2) * 2)) & 0xffffffff)), 32) | _zp_signed(0xe, 32)), 32)) & 0xff))
				_pc = 10
			12:
				var _v3: int = f5b9170(((((((((((((((m.u16((param_2 + (1) * 2))) & 0xffff)) & 0xffffffff)) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb1) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_2 + (1) * 2))) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 1, 0)
				_pc = 11
			13:
				_pc = 12 if (int((int(_zp_signed(0x14, 32) < _zp_signed(uVar1, 32))) != 0 and (int(_zp_signed(uVar1, 32) < _zp_signed(0x17, 32))) != 0)) != 0 else 8
			14:
				var _v4: int = f4025d0(m.u16(param_2))
				uVar1 = ((_v4) & 0xffff)
				_pc = 13
			15:
				_pc = 14 if (int(((param_2) & 0xffffffff) != ((((0x0) & 0xffffffff)) & 0xffffffff))) != 0 else 8
			16:
				_pc = 15 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58d660(param_1: int) -> int:
	var bVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var pbVar5: int = 0
	var uVar6: int = 0
	var extraout_var: int = 0
	var iVar7: int = 0
	var uVar8: int = 0
	var _pc: int = 39
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			3:
				var _v0: int = f5784e0(uVar8, uVar4)
				uVar2 = ((_v0) & 0xffffffff)
				_pc = 2
			4:
				var _v1: int = f56f690(uVar8, uVar6)
				uVar4 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				var _v2: int = f5b9170((((((((((((((-(((int(((uVar8) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x3b) & 0xffffffff))) & 0xffffffff), uVar6, 0, 0)
				_pc = 4
			6:
				var _v3: int = int((int((int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 and (int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)) != 0)
				if _v3 != 0:
					uVar3 = (((((((uVar8) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
					uVar2 = ((((((((((((uVar6) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
					_v3 = int((int((((((((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)
				_pc = 5 if (int((_v3) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar6) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			7:
				uVar2 = ((0) & 0xffffffff)
				_pc = 6
			8:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			9:
				var _v4: int = f5787f0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar4)
				uVar2 = ((_v4) & 0xffffffff)
				_pc = 8
			10:
				var _v5: int = f56f690(uVar8, uVar6)
				uVar4 = ((_v5) & 0xffffffff)
				_pc = 9
			11:
				var _v6: int = int((int((int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 and (int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)) != 0)
				if _v6 != 0:
					uVar3 = (((((((uVar8) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
					uVar2 = ((((((((((((uVar6) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
					_v6 = int((int((int((((((((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar6) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0)
				_pc = 10 if (_v6) != 0 else 1
			12:
				uVar2 = ((0) & 0xffffffff)
				_pc = 11
			13:
				_pc = 12 if (int(((uVar2) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 1
			14:
				uVar2 = (((((((uVar2) & 0xffffffff) - ((0x44a) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 13
			15:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			16:
				var _v7: int = f576940(param_1, uVar2)
				uVar2 = ((_v7) & 0xffffffff)
				_pc = 15
			17:
				_pc = 21 if (int(_zp_signed(iVar7, 32) < _zp_signed(5, 32))) != 0 else 16
			18:
				pbVar5 = (((pbVar5 + (0x90) * 1)) & 0xffffffff)
				_pc = 17
			19:
				iVar7 = _zp_signed(_zp_signed((_zp_signed(iVar7, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 18
			20:
				uVar2 = (((((((uVar2) & 0xffffffff) | ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(bVar1, 32) * _zp_signed(16, 32)), 32), 32) + _zp_signed(_zp_signed(iVar7, 8), 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 19
			21:
				_pc = 20 if (int((int((((((((m.u32((((pbVar5 + (_zp_signed((-(6)), 32)) * 1)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(pbVar5), 32) & _zp_signed(1, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 19
			22:
				pbVar5 = (((((0xa55d7a + (((((((((((uVar8) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)) & 0xffffffff)
				_pc = 21
			23:
				iVar7 = _zp_signed(0, 32)
				_pc = 22
			24:
				uVar2 = ((0) & 0xffffffff)
				_pc = 23
			25:
				_pc = 24 if (int(((uVar2) & 0xffffffff) == ((0x420) & 0xffffffff))) != 0 else 14
			26:
				_pc = 7 if (int(((uVar2) & 0xffffffff) == ((0x4be) & 0xffffffff))) != 0 else 25
			27:
				var _v8: int = f5747e0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(param_1), (((extraout_var) << 16) | ((m.u16((param_1 + (8) * 2))) & 0xffff)), 0xc)
				uVar2 = ((_v8) & 0xffffffff)
				_pc = 1
			28:
				_pc = 27 if (int((int((((((((m.u32((0xa55d74 + (((((((((((uVar8) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar8) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar6) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			29:
				uVar2 = ((((((((((((uVar6) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar8) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 28
			30:
				uVar8 = (((((((uVar8) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 29
			31:
				_pc = 30 if (int(((uVar2) & 0xffffffff) == ((0x587) & 0xffffffff))) != 0 else 1
			32:
				_pc = 26 if (int(((uVar2) & 0xffffffff) < ((0x4bf) & 0xffffffff))) != 0 else 31
			33:
				uVar2 = (((((((uVar2) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 32
			34:
				var _v9: int = f4022e0(m.u16(param_1))
				uVar2 = ((_v9) & 0xffffffff)
				_pc = 33
			35:
				_pc = 34 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			36:
				uVar2 = ((0) & 0xffffffff)
				_pc = 35
			37:
				uVar6 = ((((m.u8(((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(0x11, 32)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 36
			38:
				uVar8 = ((((bVar1) & 0xffffffff)) & 0xffffffff)
				_pc = 37
			39:
				bVar1 = ((m.u8((((param_1 + (8) * 2)) & 0xffffffff))) & 0xff)
				_pc = 38
	return 0


func f58d860(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var bVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 13
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar5) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), ((((((((_zp_signed((_zp_signed(bVar3, 32) >> ((1) & 31)), 32)) << 8) | ((bVar3) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), uVar2, 6)
				uVar5 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				bVar3 = ((((m.u16((param_1 + (1) * 2))) & 0xff)) & 0xff)
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(_zp_signed(uVar5, 32), 32) < _zp_signed(0, 32))) != 0 else 1
			5:
				var _v1: int = f56dc10(uVar4, m.u8(((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(0x11, 32)), 32)) & 0xffffffff)), uVar5, uVar6)
				uVar5 = ((_v1) & 0xffffffff)
				_pc = 4
			6:
				_pc = 5 if (int((int((int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + (((((((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar5) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) == _zp_signed(m.u16(param_1), 32))) != 0 and (int(((uVar4) & 0xffffffff) != ((uVar5) & 0xffffffff))) != 0)) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xfc0, 32)), 32), 32) == _zp_signed(0x480, 32))) != 0)) != 0 else 1
			7:
				uVar6 = ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 0xffffffff)
				_pc = 6
			8:
				uVar5 = ((_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 7
			9:
				uVar1 = ((m.u16((param_1 + (1) * 2))) & 0xffff)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			11:
				uVar5 = ((0) & 0xffffffff)
				_pc = 10
			12:
				uVar2 = ((m.u16((param_1 + (8) * 2))) & 0xffff)
				_pc = 11
			13:
				uVar4 = ((((((m.u16((param_1 + (8) * 2))) & 0xff)) & 0xffffffff)) & 0xffffffff)
				_pc = 12
	return 0


func f58d970(param_1: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var extraout_ECX: int = 0
	var _pc: int = 9
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f5bd030(1)
				_pc = 1
			3:
				return ((0x7f) & 0xffffffff)
			4:
				var _v1: int = f5b9170((((((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(1, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x33) & 0xffffffff))) & 0xffffffff), m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x11, 32)), 32)) & 0xffffffff)), ((((((((_zp_signed((((((((uVar2) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((_zp_signed((((((((uVar2) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 8)) & 0xff))) & 0xffffffff) & ((0xffff00ff) & 0xffffffff))) & 0xffffffff), (((((((((((((_zp_signed((((((((extraout_ECX) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((_zp_signed(uVar2, 8)) & 0xff))) & 0xffffffff) & ((0xffff00ff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff))
				_pc = 3
			5:
				var _v2: int = f583440(param_1, 0)
				uVar2 = ((_v2) & 0xffffffff)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 1
			7:
				var _v3: int = f583470(param_1, 0, 0)
				iVar1 = _zp_signed(_v3, 32)
				_pc = 6
			8:
				_pc = 7 if (int((int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 1
			9:
				_pc = 2 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 8
	return 0


func f58da00(param_1: int) -> int:
	var in_EAX: int = 0
	var iVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var _pc: int = 10
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5751e0(param_1, (((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar3, 1, 0)
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u16((0xa55d7a + (((((((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 2)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16((0xa55d7a + (((((((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 2)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 1
			4:
				in_EAX = ((0) & 0xffffffff)
				_pc = 3
			5:
				uVar3 = ((((((((((((uVar2) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 4
			6:
				var _v1: int = f583440(param_1, 0)
				uVar2 = ((_v1) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 1
			8:
				in_EAX = ((0) & 0xffffffff)
				_pc = 7
			9:
				var _v2: int = f583470(param_1, 0, 0)
				iVar1 = _zp_signed(_v2, 32)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58da80(param_1: int) -> int:
	var bVar1: int = 0
	var uVar2: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var _pc: int = 24
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7f) & 0xffffffff)
			2:
				var _v0: int = f5bf9a0(7, 0)
				_pc = 1
			3:
				var _v1: int = f5bf800(0x38)
				_pc = 2
			4:
				return ((0x7f) & 0xffffffff)
			5:
				var _v2: int = f5bddb0(2)
				m.set_u16(0xa558b4, ((_v2) & 0xffff))
				_pc = 4
			6:
				_pc = 5 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff), 8)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 3
			7:
				return ((0) & 0xffffffff)
			8:
				_pc = 7 if (int(_zp_signed(((((m.u16((param_1 + (8) * 2))) & 0xff)) & 0xffff), 32) == _zp_signed((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffff), 32))) != 0 else 6
			9:
				return ((0) & 0xffffffff)
			10:
				_pc = 9 if (int((((((((uVar2) & 0xffffffff) & ((0xfc0) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0x480) & 0xffffffff))) != 0 else 8
			11:
				return ((0) & 0xffffffff)
			12:
				_pc = 11 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 10
			13:
				return ((10) & 0xffffffff)
			14:
				var _v3: int = f5747e0(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), ((((((((_zp_signed((_zp_signed(bVar1, 32) >> ((1) & 31)), 32)) << 8) | ((bVar1) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), (((extraout_var) << 16) | ((m.u16((param_1 + (8) * 2))) & 0xffff)), 6)
				_pc = 13
			15:
				bVar1 = ((((m.u16((param_1 + (1) * 2))) & 0xff)) & 0xff)
				_pc = 14
			16:
				_pc = 15 if (int(((uVar2) & 0xffffffff) == ((m.u16(0xa558b4)) & 0xffffffff))) != 0 else 13
			17:
				var _v4: int = f5b9170((((((((((((((_zp_signed((((((uVar2) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xe0) & 0xffffffff))) & 0xffffffff), (((extraout_var_00) << 16) | ((m.u16(0xa558b4)) & 0xffff)), uVar2, _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32))
				_pc = 16
			18:
				var _v5: int = f5bddb0(2)
				uVar2 = ((_v5) & 0xffffffff)
				_pc = 17
			19:
				_pc = 18 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 12
			20:
				return ((0) & 0xffffffff)
			21:
				_pc = 20 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + ((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32)) & 0xffffffff) + ((((((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) != _zp_signed(m.u16(param_1), 32))) != 0 else 19
			22:
				uVar2 = ((((m.u16((param_1 + (1) * 2))) & 0xffffffff)) & 0xffffffff)
				_pc = 21
			23:
				return ((0) & 0xffffffff)
			24:
				_pc = 23 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 22
	return 0


func f58dcc0(param_1: int) -> int:
	var bVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var uVar5: int = 0
	var extraout_EDX: int = 0
	var extraout_EDX_00: int = 0
	var uVar6: int = 0
	var uVar7: int = 0
	var _pc: int = 26
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f5bd030(0)
				_pc = 1
			3:
				return ((0x7f) & 0xffffffff)
			4:
				var _v1: int = f5b9170((((((((((((((-(((int(((uVar7) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x33) & 0xffffffff))) & 0xffffffff), uVar4, ((((((((_zp_signed((((((((uVar6) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((bVar1) & 0xff))) & 0xffffffff) & ((0xffff00ff) & 0xffffffff))) & 0xffffffff), ((((((((uVar5) << 16) | ((((m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x12, 32)), 32)) & 0xffffffff))) & 0xffff)) & 0xffff))) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff))
				_pc = 3
			5:
				return ((0x7f) & 0xffffffff)
			6:
				var _v2: int = f5b9170((((((((((((((-(((int(((uVar7) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x34) & 0xffffffff))) & 0xffffffff), uVar4, 1, 0)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(4, 32) < _zp_signed(bVar1, 32))) != 0 else 4
			8:
				bVar1 = ((((_zp_signed((_zp_signed(((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x12, 32)), 32)) & 0xffffffff))) & 0xffff), 32) >> ((8) & 31)), 32)) & 0xff)) & 0xff)
				_pc = 7
			9:
				uVar5 = ((extraout_var_00) & 0xffff)
				_pc = 8
			10:
				uVar6 = ((extraout_EDX_00) & 0xffffffff)
				_pc = 9
			11:
				var _v3: int = f5751e0(param_1, uVar7, uVar4, 0, 0)
				_pc = 10
			12:
				_pc = 11 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar4) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 8
			13:
				uVar5 = ((extraout_var) & 0xffff)
				_pc = 12
			14:
				uVar6 = ((extraout_EDX) & 0xffffffff)
				_pc = 13
			15:
				var _v4: int = f5798f0(1, 0)
				_pc = 14
			16:
				var _v5: int = f5b9170((((_zp_signed((_zp_signed(((((((((((-(((int(_zp_signed(_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x10, 32)), 32)) & 0xffffffff)), 8), 32) != _zp_signed(0, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0x80, 32)), 32)) << 8) | ((0x35) & 0xff)), m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(0x11, 32)), 32)) & 0xffffffff)), 1, 0)
				_pc = 15
			17:
				_pc = 16 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar3) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar4) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0 and (int((((((((m.u32((0xa55d74 + (((((((((((uVar3) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar4) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)) != 0 else 1
			18:
				uVar3 = (((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 17
			19:
				uVar4 = ((((((((((((uVar3) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 18
			20:
				uVar7 = (((((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 19
			21:
				var _v6: int = f583440(param_1, 0)
				uVar3 = ((_v6) & 0xffffffff)
				_pc = 20
			22:
				_pc = 21 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			23:
				var _v7: int = f583470(param_1, 0, 0)
				iVar2 = _zp_signed(_v7, 32)
				_pc = 22
			24:
				_pc = 23 if (int((int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 and (int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)) != 0 else 1
			25:
				_pc = 24 if (int((int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 else 1
			26:
				_pc = 2 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 25
	return 0


func f58de30(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var in_EDX: int = 0
	var _pc: int = 8
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), (((_zp_signed((((((uVar2) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16(param_1)) & 0xffff)), ((((((((_zp_signed(uVar2, 8)) << 8) | ((_zp_signed(m.u16((((0xa57854 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(_zp_signed((-(0x10)), 32), 32)), 32)) * 1)) & 0xffffffff)), 8)) & 0xff))) & 0xffffffff) & ((0xff01) & 0xffffffff))) & 0xffffffff), 3)
				uVar2 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				uVar2 = ((((((((((_zp_signed(((((((((_zp_signed((((((((in_EDX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((uVar1) & 0xffff))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((_zp_signed((_zp_signed(((uVar1) & 0xff), 32) >> ((1) & 31)), 32)) & 0xff))) & 0xffffffff) & ((0xffffff07) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 2
			4:
				_pc = 3 if (int((((((((uVar2) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 1
			5:
				uVar2 = ((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) >> ((1) & 31)), 32), 32) & _zp_signed(7, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffffffff)
				_pc = 4
			6:
				uVar1 = ((m.u16((((0xa57854 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(0xa577fa), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(_zp_signed((-(0x10)), 32), 32)), 32)) * 1)) & 0xffffffff))) & 0xffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			8:
				uVar2 = ((0) & 0xffffffff)
				_pc = 7
	return 0


func f58dec0(param_1: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var in_EDX: int = 0
	var _pc: int = 22
	while true:
		match _pc:
			0:
				return ((0) & 0xff)
			1:
				return ((0) & 0xff)
			2:
				var _v0: int = f579930(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x15, 1)
				_pc = 1
			3:
				var _v1: int = f579930(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x14, 1)
				_pc = 2
			4:
				return ((_zp_signed((_zp_signed(_zp_signed((-(int(_zp_signed(iVar1, 32) != _zp_signed(0, 32)))), 32), 32) & _zp_signed(0x7f, 32)), 32)) & 0xff)
			5:
				var _v2: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar2, 0)
				iVar1 = _zp_signed(_v2, 32)
				_pc = 4
			6:
				var _v3: int = f4022e0(m.u16(param_1))
				uVar2 = ((_v3) & 0xffffffff)
				_pc = 5
			7:
				return ((0) & 0xff)
			8:
				_pc = 7 if (int((((((((m.u32((((0xa56430 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0xd44, 32)), 32)) * 1)) & 0xffffffff))) & 0xffffffff) & ((0x10000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 6
			9:
				return ((0) & 0xff)
			10:
				_pc = 9 if (int(_zp_signed(iVar1, 32) == _zp_signed(0, 32))) != 0 else 8
			11:
				var _v4: int = f56a000(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar1 = _zp_signed(_v4, 32)
				_pc = 10
			12:
				return ((0) & 0xff)
			13:
				_pc = 12 if (int(_zp_signed(iVar1, 32) == _zp_signed(0, 32))) != 0 else 11
			14:
				var _v5: int = f570b40(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar1 = _zp_signed(_v5, 32)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 3
			16:
				return ((0x7e) & 0xff)
			17:
				var _v6: int = f5adb10(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0xa582a4, 1, 0, 0xd, _zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 15
			19:
				return ((0x7d) & 0xff)
			20:
				var _v7: int = f5b9170(((((((((_zp_signed((((((((in_EDX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 19
			21:
				_pc = 20 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 18
			22:
				_pc = 21 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 3
	return 0


func f58dfe0(param_1: int) -> int:
	var _stack: int = m.local(12)
	var uVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var _pc: int = 23
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f575750(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar2, (((((((((((((((uVar4) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((m.u32((_stack + 0))) & 0xffffffff))) & 0xffffffff))
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(_zp_signed(uVar4, 32), 32))) != 0 else 1
			4:
				var _v1: int = f56a030(uVar5)
				uVar4 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				_pc = 4 if (int((((((((m.u32((0xa55d74 + (((((((((((uVar4) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 3
			6:
				_pc = 5 if (int(_zp_signed(iVar3, 32) == _zp_signed(0, 32))) != 0 else 1
			7:
				var _v2: int = f56c460((((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), ((((((((((uVar2) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				iVar3 = _zp_signed(_v2, 32)
				_pc = 6
			8:
				var _v3: int = f5747e0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(param_1), uVar2, (((((((((((((((uVar1) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xd) & 0xffffffff))) & 0xffffffff))
				_pc = 7
			9:
				m.set_u32((_stack + 0), ((((((((((m.u16(((_zp_signed((_zp_signed(_zp_signed((_stack + 0), 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) << 16) | ((_zp_signed(uVar1, 16)) & 0xffff))) & 0xffffffff) & ((0xffff00ff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 8
			10:
				return ((0x7f) & 0xffffffff)
			11:
				var _v4: int = f577880(param_1, uVar5, uVar4)
				_pc = 10
			12:
				_pc = 11 if (int((int(((uVar5) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) != 0 and (int((((((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) != 0)) != 0 else 1
			13:
				_pc = 12 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			14:
				var _v5: int = f583470(param_1, 1, 0)
				iVar3 = _zp_signed(_v5, 32)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			16:
				var _v6: int = f583470(param_1, 0, 0)
				iVar3 = _zp_signed(_v6, 32)
				_pc = 15
			17:
				_pc = 16 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			18:
				_pc = 9 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 17
			19:
				uVar5 = (((((((uVar1) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 18
			20:
				uVar4 = ((((((((((((uVar1) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 19
			21:
				var _v7: int = f583440(param_1, 1)
				uVar2 = ((_v7) & 0xffffffff)
				_pc = 20
			22:
				var _v8: int = f583440(param_1, 0)
				uVar1 = ((_v8) & 0xffffffff)
				_pc = 21
			23:
				_pc = 22 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (2) * 2)), 32) & _zp_signed(0xe000, 32)), 32), 32) == _zp_signed(0x4000, 32))) != 0)) != 0 else 1
	return 0


func f58e160(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var _pc: int = 12
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar4) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), (((extraout_var) << 16) | ((m.u16(param_1)) & 0xffff)), (((((uVar1) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) << ((8) & 31)), 32), 32) | _zp_signed(3, 32)), 32))
				uVar4 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			4:
				uVar4 = ((0) & 0xffffffff)
				_pc = 3
			5:
				var _v1: int = f583470(param_1, 0, 0)
				iVar2 = _zp_signed(_v1, 32)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			7:
				uVar4 = (((((_zp_signed((((((((uVar3) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 24)) << 8) | ((m.u8((((param_1 + (2) * 2)) & 0xffffffff))) & 0xff))) & 0xffffffff)
				_pc = 6
			8:
				var _v2: int = f579930(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x12, 1)
				uVar3 = ((_v2) & 0xffffffff)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			10:
				uVar4 = ((0) & 0xffffffff)
				_pc = 9
			11:
				var _v3: int = f583510(param_1, (((((uVar1) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), ((((((((((uVar1) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				iVar2 = _zp_signed(_v3, 32)
				_pc = 10
			12:
				var _v4: int = f583440(param_1, 0)
				uVar1 = ((_v4) & 0xffffffff)
				_pc = 11
	return 0


func f58e1f0(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var _pc: int = 21
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				_pc = 9 if (int(_zp_signed(_zp_signed(uVar3, 32), 32) < _zp_signed(2, 32))) != 0 else 2
			4:
				uVar3 = (((((((uVar3) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 3
			5:
				uVar2 = (((((((uVar2) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 6 if (int(_zp_signed(_zp_signed((-(1)), 32), 32) < _zp_signed(_zp_signed(uVar2, 32), 32))) != 0 else 4
			6:
				var _v0: int = f575970(uVar1, uVar2, int(((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff) != ((uVar1) & 0xffffffff)))
				_pc = 5
			7:
				uVar2 = ((((m.u8((((0xa55d68 + (((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			8:
				m.set_u16((((((((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff) + (((((((uVar1) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff), ((((m.u8((((0xa55d68 + (((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff))) & 0xffff)) & 0xffff))
				_pc = 7
			9:
				uVar1 = ((((((((((((m.u32(0xa577fa)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) ^ ((uVar3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 8
			10:
				uVar3 = ((0) & 0xffffffff)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			12:
				return ((0x7e) & 0xffffffff)
			13:
				var _v1: int = f578b60((((((m.u32(0xa577fa)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff), m.u16((((((((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff) + ((((((((((((m.u32(0xa577fa)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)))
				_pc = 12
			14:
				var _v2: int = f579810()
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 11
			16:
				return ((0x7d) & 0xffffffff)
			17:
				var _v3: int = f579890()
				_pc = 16
			18:
				var _v4: int = f578b60((((((1) & 0xffffffff) - (((((((m.u32(0xa577fa)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), m.u16((((((((param_1) & 0xffffffff) + ((((((((((((4) & 0xffffffff) - (((((((m.u32(0xa577fa)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)))
				_pc = 17
			19:
				_pc = 18 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 15
			20:
				return ((0) & 0xffffffff)
			21:
				_pc = 20 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 19
	return 0


func f58e2f0(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var iVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f579890()
				_pc = 1
			3:
				return ((0x7f) & 0xffffffff)
			4:
				var _v1: int = f579810()
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			6:
				return ((0x7e) & 0xffffffff)
			7:
				return ((0x7f) & 0xffffffff)
			8:
				var _v2: int = f5ada20(uVar4, (_params + 0), 1, 1, 1, 0, 0)
				_pc = 7
			9:
				m.set_u32((_params + 0), ((((((((((((uVar4) & 0xffffffff) << ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) | (((((((uVar3) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 8
			10:
				uVar4 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 9
			11:
				var _v3: int = f402460(0x781)
				uVar3 = ((_v3) & 0xffffffff)
				_pc = 10
			12:
				_pc = 11 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 6
			13:
				var _v4: int = f56a000(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v4, 32)
				_pc = 12
			14:
				_pc = 13 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 5
			15:
				_pc = 2 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 14
			16:
				_pc = 15 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			17:
				var _v5: int = f570b40(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v5, 32)
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			19:
				iVar1 = _zp_signed(m.u32((_params + 0)), 32)
				_pc = 18
	return 0


func f58e3a0(param_1: int) -> int:
	var _stack: int = m.local(256)
	var iVar1: int = 0
	var uVar2: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f5b9170(((((((((extraout_var_00) << 16) | ((_zp_signed((_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 1
			3:
				var _v1: int = f5b9170((((((((((((((extraout_var) << 16) | ((m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0x1f) & 0xffffffff))) & 0xffffffff), 0x2ea, m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff)), 0)
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 1
			5:
				var _v2: int = f576050(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x2ea)
				iVar1 = _zp_signed(_v2, 32)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32))) != 0 else 1
			7:
				return ((0x7f) & 0xffffffff)
			8:
				var _v3: int = f5bf9a0(1, 0)
				_pc = 7
			9:
				var _v4: int = f5bf800((_stack + 0))
				_pc = 8
			10:
				var _v5: int = f5bdf40((_stack + 0), 0x41, uVar2)
				_pc = 9
			11:
				var _v6: int = f402290(uVar2)
				uVar2 = ((_v6) & 0xffffffff)
				_pc = 10
			12:
				var _v7: int = f402460(0x2ea)
				uVar2 = ((_v7) & 0xffffffff)
				_pc = 11
			13:
				return ((0x7f) & 0xffffffff)
			14:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 13
			15:
				_pc = 14 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 12
			16:
				_pc = 15 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 1
			17:
				var _v8: int = f599e30(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x4d8, 0)
				iVar1 = _zp_signed(_v8, 32)
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			19:
				_pc = 6 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 18
	return 0


func f58e4e0(param_1: int, param_2: int) -> int:
	var _params: int = m.local(8)
	m.set_u32(_params + 0, param_1)
	m.set_u32(_params + 4, param_2)
	var iVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var extraout_var: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 13
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				return (((((uVar3) << 16) | ((0x7f) & 0xffff))) & 0xffffffff)
			3:
				uVar3 = ((extraout_var) & 0xffff)
				_pc = 2
			4:
				var _v0: int = f5adb10(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), (_params + 0), 1, 0x20, 0xe, uVar4)
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 2
			6:
				uVar3 = ((0) & 0xffff)
				_pc = 5
			7:
				var _v1: int = f56cb40(uVar4, (_params + 0))
				iVar2 = _zp_signed(_v1, 32)
				_pc = 6
			8:
				uVar4 = ((((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				m.set_u32((_params + 0), ((m.u32(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff))) & 0xffffffff))
				_pc = 8
			10:
				_pc = 9 if (int((int(((in_EAX) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xe000, 32)), 32), 32) == _zp_signed(0x4000, 32))) != 0)) != 0 else 1
			11:
				var _v2: int = f59dd90(m.u32((_params + 0)), m.u32((_params + 4)), 0)
				in_EAX = ((_v2) & 0xffffffff)
				_pc = 10
			12:
				_pc = 11 if (int((int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 and (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0)) != 0 else 1
			13:
				iVar1 = _zp_signed(m.u32((_params + 0)), 32)
				_pc = 12
	return 0


func f58e580(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var uVar2: int = 0
	var uVar3: int = 0
	var iVar4: int = 0
	var uVar5: int = 0
	var bVar6: int = 0
	var local_4: int = 0
	var _pc: int = 20
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f574990(_zp_signed((_zp_signed(m.u8((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), ((((((((local_4) << 8) | ((m.u8((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0xff01) & 0xffffffff))) & 0xffffffff), (((((uVar2) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff))
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				local_4 = ((((uVar5) & 0xff)) & 0xff)
				_pc = 2
			4:
				var _v1: int = f576110(bVar6, 0xe, _zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((((((((uVar1) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(0x1fe0, 32)), 32), 32) >> ((5) & 31)), 32), bVar6, uVar5, 1, 0)
				_pc = 3
			5:
				bVar6 = ((_zp_signed((_zp_signed(m.u8((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xff)
				_pc = 4
			6:
				var _v2: int = f56a400(_zp_signed((_zp_signed(m.u8((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				uVar5 = ((_v2) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			8:
				uVar3 = ((0) & 0xffffffff)
				_pc = 7
			9:
				var _v3: int = f59dc50(uVar1, (((((m.u32((_params + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), ((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				iVar4 = _zp_signed(_v3, 32)
				_pc = 8
			10:
				_pc = 9 if (int(_zp_signed(iVar4, 32) != _zp_signed(0, 32))) != 0 else 1
			11:
				uVar3 = ((0) & 0xffffffff)
				_pc = 10
			12:
				uVar2 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 11
			13:
				var _v4: int = f583470(uVar1, 0, (_params + 0))
				iVar4 = _zp_signed(_v4, 32)
				_pc = 12
			14:
				return ((0xffff0000) & 0xffffffff)
			15:
				_pc = 14 if (int(_zp_signed(iVar4, 32) == _zp_signed(_zp_signed((-(1)), 32), 32))) != 0 else 13
			16:
				var _v5: int = f56a400(_zp_signed((_zp_signed(m.u8((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar4 = _zp_signed(_v5, 32)
				_pc = 15
			17:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			18:
				_pc = 17 if (int(_zp_signed(_zp_signed(uVar3, 32), 32) < _zp_signed(0, 32))) != 0 else 16
			19:
				var _v6: int = f568ad0(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(0x1fe0, 32)), 32), 32) >> ((5) & 31)), 32))
				uVar3 = ((_v6) & 0xffffffff)
				_pc = 18
			20:
				uVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 19
	return 0


func f58e670(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var iVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 22
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f579930(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x15, 1)
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				var _v1: int = f579930(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x14, 1)
				_pc = 2
			4:
				return ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(1, 32)), 32)) & 0xffffffff)
			5:
				var _v2: int = f5ada20(uVar4, (_params + 0), 1, 1, 1, 0, 0)
				_pc = 4
			6:
				m.set_u32((_params + 0), ((((((((((((uVar4) & 0xffffffff) << ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) | (((((((uVar3) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 5
			7:
				uVar4 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 6
			8:
				var _v3: int = f402460(0x782)
				uVar3 = ((_v3) & 0xffffffff)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 3
			10:
				var _v4: int = f56a000(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v4, 32)
				_pc = 9
			11:
				var _v5: int = f579810()
				_pc = 10
			12:
				_pc = 1
			13:
				var _v6: int = int((int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0)
				if _v6 == 0:
					uVar3 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
					_v6 = int((int((((((((m.u32((((0xa56430 + ((((((uVar3) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) * 1)) & 0xffffffff))) & 0xffffffff) & ((0x10000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)
				_pc = 12 if (_v6) != 0 else 11
			14:
				uVar3 = ((0) & 0xffffffff)
				_pc = 13
			15:
				var _v7: int = f570b40(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(iVar1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar2 = _zp_signed(_v7, 32)
				_pc = 14
			16:
				_pc = 1
			17:
				_pc = 16 if (int(_zp_signed(_zp_signed(uVar3, 32), 32) < _zp_signed(4, 32))) != 0 else 15
			18:
				var _v8: int = f56a000(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				uVar3 = ((_v8) & 0xffffffff)
				_pc = 17
			19:
				var _v9: int = f579890()
				_pc = 3
			20:
				var _v10: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 3
				if _v10 == 0x7f: _pc = 10
				if _v10 == 0x7e: _pc = 10
				if _v10 == 0x7d: _pc = 10
				if _v10 == 0x80: _pc = 18
				if _v10 == 0x7c: _pc = 19
			21:
				_pc = 20 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((((((m.u32((_params + 0))) & 0xffffffff) + ((4) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 3
			22:
				iVar1 = _zp_signed(m.u32((_params + 0)), 32)
				_pc = 21
	return 0


func f58e790(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var uVar1: int = 0
	var bVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 11
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar5) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(_zp_signed((_zp_signed(m.u16((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32), 32) | _zp_signed(0x6000, 32)), 32), ((((((((_zp_signed((_zp_signed(bVar2, 32) >> ((1) & 31)), 32)) << 8) | ((bVar2) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), 0xb)
				uVar5 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				bVar2 = ((((m.u16((((((((uVar1) & 0xffffffff) + ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xff)) & 0xff)
				_pc = 2
			4:
				_pc = 3 if (int((int((((((((m.u32((0xa55d74 + (((((((((((uVar4) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar6) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((((0xa55d7a + ((((((uVar4) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2) + ((((((uVar6) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			5:
				uVar5 = ((0) & 0xffffffff)
				_pc = 4
			6:
				uVar4 = (((((((m.u32((_params + 0))) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			7:
				uVar6 = ((((((((((((m.u32((_params + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			9:
				uVar5 = ((0) & 0xffffffff)
				_pc = 8
			10:
				var _v1: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar3 = _zp_signed(_v1, 32)
				_pc = 9
			11:
				uVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 10
	return 0


func f58e850(param_1: int) -> int:
	var _stack: int = m.local(8)
	var uVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var pbVar4: int = 0
	var uVar5: int = 0
	var _pc: int = 23
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f576940(param_1, uVar1)
				uVar1 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 9 if (int(_zp_signed(iVar2, 32) < _zp_signed(5, 32))) != 0 else 2
			4:
				pbVar4 = (((pbVar4 + (0x90) * 1)) & 0xffffffff)
				_pc = 3
			5:
				iVar2 = _zp_signed(_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 4
			6:
				uVar1 = (((((((uVar1) & 0xffffffff) | ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed(iVar2, 8), 32) - _zp_signed(_zp_signed((((((uVar5) & 0xffffffff) << ((4) & 31))) & 0xffffffff), 8), 32)), 32), 32) + _zp_signed(0x10, 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar3, 32) <= _zp_signed(_zp_signed(m.u32((_stack + 4)), 32), 32))) != 0 else 5
			8:
				var _v1: int = f56f6b0((((((1) & 0xffffffff) - ((uVar5) & 0xffffffff))) & 0xffffffff), iVar2)
				iVar3 = _zp_signed(_v1, 32)
				_pc = 7
			9:
				_pc = 8 if (int((int((((((((m.u32((((pbVar4 + (_zp_signed((-(6)), 32)) * 1)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(pbVar4), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 5
			10:
				pbVar4 = (((((0xa55d7a + (((((((((((((((((((-(uVar5))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				iVar2 = _zp_signed(0, 32)
				_pc = 10
			12:
				uVar1 = ((0) & 0xffffffff)
				_pc = 11
			13:
				var _v2: int = f56f690(uVar5, ((((((((((m.u32((_stack + 0))) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				m.set_u32((_stack + 4), _zp_signed(_v2, 32))
				_pc = 12
			14:
				_pc = 13 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			15:
				uVar1 = ((0) & 0xffffffff)
				_pc = 14
			16:
				var _v3: int = f57b860(param_1, m.u32((_stack + 0)))
				iVar2 = _zp_signed(_v3, 32)
				_pc = 15
			17:
				uVar5 = (((((((m.u32((_stack + 0))) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 16
			18:
				_pc = 17 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			19:
				uVar1 = ((0) & 0xffffffff)
				_pc = 18
			20:
				var _v4: int = f583470(param_1, 0, (_stack + 0))
				iVar2 = _zp_signed(_v4, 32)
				_pc = 19
			21:
				return (((((((uVar1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			22:
				_pc = 21 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 20
			23:
				var _v5: int = f579930(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x12, 1)
				uVar1 = ((_v5) & 0xffffffff)
				_pc = 22
	return 0


func f58e950(param_1: int) -> int:
	var _params: int = m.local(4)
	m.set_u32(_params + 0, param_1)
	var puVar1: int = 0
	var puVar2: int = 0
	var in_EAX: int = 0
	var iVar3: int = 0
	var puVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 15
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((((puVar4) & 0xffffffff)) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(uVar5, m.u16(puVar1), (((((((puVar2) & 0xffffffff)) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff), (((((((((((((m.u8((((puVar1 + (1) * 2)) & 0xffffffff))) << 8) | ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((~(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)))), 32), 32) ^ _zp_signed(m.u16(0xa577fa), 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) + _zp_signed(1, 32)), 32), 32) * _zp_signed(16, 32)), 32)) & 0xff))) & 0xffffffff) & ((0x1ff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((3) & 0xffffffff))) & 0xffffffff))
				puVar4 = ((((_v0) & 0xffffffff)) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(_zp_signed(puVar4, 16), 32) == _zp_signed(7, 32))) != 0 else 1
			4:
				var _v1: int = f56f6d0(uVar5, uVar6)
				puVar4 = ((((_v1) & 0xffffffff)) & 0xffffffff)
				_pc = 3
			5:
				var _v2: int = int((int(((uVar5) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u8((((puVar1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff))) != 0)
				if _v2 != 0:
					puVar4 = ((((((((((((((uVar6) & 0xffffffff) * ((0x90) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)) & 0xffffffff)
					_v2 = int((int((((((((m.u32((((puVar4 + (0x52aeba) * 2)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0)
				_pc = 4 if (int((_v2) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((puVar4 + (0x52aebd) * 2)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			6:
				puVar4 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 5
			7:
				uVar5 = (((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 6
			8:
				uVar6 = ((((((((((((((m.u32((_params + 0))) & 0xffffffff)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			10:
				puVar4 = ((((0x0) & 0xffffffff)) & 0xffffffff)
				_pc = 9
			11:
				puVar2 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 10
			12:
				var _v3: int = f583470(m.u32((_params + 0)), 0, (_params + 0))
				iVar3 = _zp_signed(_v3, 32)
				_pc = 11
			13:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((m.u32((_params + 0)) + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 12
			15:
				puVar1 = ((m.u32((_params + 0))) & 0xffffffff)
				_pc = 14
	return 0


func f58ea30(param_1: int) -> int:
	var uVar1: int = 0
	var _pc: int = 13
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7e) & 0xffffffff)
			2:
				var _v0: int = f5bcdc0((((((1) & 0xffffffff) - ((uVar1) & 0xffffffff))) & 0xffffffff), 1, 0, 1)
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(_zp_signed(m.u8((((0xa55d68 + (((((((((((((((((((-(uVar1))) & 0xffffffff)) & 0xffffffff) - ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 8), 32) != _zp_signed(0, 32))) != 0 else 1
			4:
				uVar1 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 3
			5:
				return ((0x7f) & 0xffffffff)
			6:
				var _v1: int = f5bcdc0(uVar1, 1, 0, 0)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(_zp_signed(m.u8((((0xa55d68 + ((((((uVar1) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 8), 32) != _zp_signed(0, 32))) != 0 else 5
			8:
				uVar1 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 7
			9:
				return ((0) & 0xffffffff)
			10:
				_pc = 9 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 8
			11:
				_pc = 10 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(127, 32))) != 0 else 4
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 11
	return 0


func f58eae0(param_1: int) -> int:
	var uVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var extraout_var: int = 0
	var _pc: int = 21
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x78) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				var _v1: int = int((int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0)
				if _v1 != 0:
					var _v0: int = f583470(param_1, 0, 0)
					iVar3 = _zp_signed(_v0, 32)
					_v1 = int((int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0)
				var _v3: int = int((_v1) != 0)
				if _v3 != 0:
					var _v2: int = f57a470(param_1, uVar2)
					iVar3 = _zp_signed(_v2, 32)
					_v3 = int((int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0)
				_pc = 2 if (_v3) != 0 else 1
			4:
				var _v4: int = f56a430(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar4)
				iVar3 = _zp_signed(_v4, 32)
				_pc = 3
			5:
				var _v5: int = f402460(0x4ea)
				uVar4 = ((_v5) & 0xffffffff)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			7:
				var _v6: int = f569300(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x4ea)
				iVar3 = _zp_signed(_v6, 32)
				_pc = 6
			8:
				return ((0x7e) & 0xffffffff)
			9:
				var _v7: int = f5791d0(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x4ea, uVar1)
				_pc = 8
			10:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), (((((uVar1) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffff))
				_pc = 9
			11:
				var _v8: int = f56a400(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				uVar1 = ((_v8) & 0xff)
				_pc = 10
			12:
				return ((0x7d) & 0xffffffff)
			13:
				var _v9: int = f574990(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), ((((((((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(3, 32)), 32)) & 0xffffffff))) << 8) | ((m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0xff01) & 0xffffffff))) & 0xffffffff), uVar2)
				_pc = 12
			14:
				return ((1) & 0xffffffff)
			15:
				var _v10: int = f598d70()
				_pc = 14
			16:
				return ((1) & 0xffffffff)
			17:
				var _v11: int = f578d00(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x4ea, 0, 0)
				_pc = 16
			18:
				return ((0) & 0xffffffff)
			19:
				var _v12: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 18
			20:
				var _v13: int = m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))
				_pc = 18
				if _v13 == 0x80: _pc = 7
				if _v13 == 0x7f: _pc = 11
				if _v13 == 0x7e: _pc = 13
				if _v13 == 0x7d: _pc = 15
				if _v13 == 0x78: _pc = 17
				if _v13 == 1: _pc = 19
			21:
				var _v14: int = f583440(param_1, 0)
				uVar2 = ((_v14) & 0xffffffff)
				_pc = 20
	return 0


func f58ed20(param_1: int) -> int:
	var uVar1: int = 0
	var extraout_var: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7f) & 0xffffffff)
			2:
				var _v0: int = f5bf9a0(7, 0)
				_pc = 1
			3:
				var _v1: int = f5bf800(0x38)
				_pc = 2
			4:
				return ((0x7f) & 0xffffffff)
			5:
				var _v2: int = f5bddb0(2)
				m.set_u16(0xa558b4, ((_v2) & 0xffff))
				_pc = 4
			6:
				_pc = 5 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 3
			7:
				return ((0) & 0xffffffff)
			8:
				_pc = 7 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 6
			9:
				return ((10) & 0xffffffff)
			10:
				return ((10) & 0xffffffff)
			11:
				var _v3: int = f578b60(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(5, 32) - _zp_signed(_zp_signed((_zp_signed(((m.u16((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2))) & 0xffff), 32) & _zp_signed(0xff, 32)), 32), 32)), 32))
				_pc = 10
			12:
				_pc = 11 if (int(_zp_signed(((m.u16((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2))) & 0xff), 32) < _zp_signed(5, 32))) != 0 else 9
			13:
				var _v4: int = f579790(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(param_1), 0x23)
				_pc = 9
			14:
				_pc = 12 if (int(((uVar1) & 0xffffffff) == ((m.u16(0xa558b4)) & 0xffffffff))) != 0 else 13
			15:
				var _v5: int = f5b9170((((((((((((((_zp_signed((((((uVar1) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xe0) & 0xffffffff))) & 0xffffffff), (((extraout_var) << 16) | ((m.u16(0xa558b4)) & 0xffff)), uVar1, _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32))
				_pc = 14
			16:
				var _v6: int = f5bddb0(2)
				uVar1 = ((_v6) & 0xffffffff)
				_pc = 15
			17:
				_pc = 16 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 8
			18:
				return ((0) & 0xffffffff)
			19:
				_pc = 18 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 17
	return 0


func f58eee0(param_1: int) -> int:
	var in_EAX: int = 0
	var uVar1: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var iVar4: int = 0
	var _pc: int = 15
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				_pc = 11 if (int(_zp_signed(iVar4, 32) < _zp_signed(0x2d0, 32))) != 0 else 1
			3:
				iVar3 = _zp_signed(_zp_signed((_zp_signed(iVar3, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 2
			4:
				iVar4 = _zp_signed(_zp_signed((_zp_signed(iVar4, 32) + _zp_signed(0x90, 32)), 32), 32)
				_pc = 3
			5:
				var _v0: int = f574810(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(iVar2, 32) / _zp_signed(5, 32)), 32), 32) | _zp_signed(0x8000, 32)), 32), ((((((((_zp_signed(iVar3, 8)) << 8) | ((m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffffffff) & ((0xff01) & 0xffffffff))) & 0xffffffff), 0xc)
				uVar1 = ((_v0) & 0xffffffff)
				_pc = 4
			6:
				var _v1: int = f56f690(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), iVar3)
				iVar2 = _zp_signed(_v1, 32)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(_zp_signed(uVar1, 16), 32) == _zp_signed(7, 32))) != 0 else 4
			8:
				var _v2: int = f56f6d0(uVar1, iVar3)
				uVar1 = ((_v2) & 0xffffffff)
				_pc = 7
			9:
				_pc = 8 if (int((int((((((((m.u32(((_zp_signed((_zp_signed(_zp_signed(0xa55d74, 32), 32) + _zp_signed(iVar2, 32)), 32)) & 0xffffffff))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55d7a, 32), 32) + _zp_signed(iVar2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 4
			10:
				iVar2 = _zp_signed((((((iVar4) & 0xffffffff) + (((((((uVar1) & 0xffffffff) * ((0xd44) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), 32)
				_pc = 9
			11:
				uVar1 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 10
			12:
				iVar4 = _zp_signed(0, 32)
				_pc = 11
			13:
				iVar3 = _zp_signed(0, 32)
				_pc = 12
			14:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			15:
				_pc = 14 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 13
	return 0


func f58ef90(param_1: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var in_EDX: int = 0
	var uVar3: int = 0
	var _pc: int = 25
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), (((((m.u8((((0xa55d68 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x6a2, 32)), 32)) * 2)) & 0xffffffff))) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffff))
				_pc = 2
			4:
				m.set_u32(0xa55c8c, (((((((m.u32(0xa55c8c)) & 0xffffffff) & ((0xffffff00) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))
				_pc = 3
			5:
				var _v1: int = int((int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0)
				if _v1 != 0:
					var _v0: int = f577a60(param_1, (((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar3)
					iVar1 = _zp_signed(_v0, 32)
					_v1 = int((int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0)
				_pc = 4 if (_v1) != 0 else 1
			6:
				var _v2: int = f583510(param_1, (((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar3)
				iVar1 = _zp_signed(_v2, 32)
				_pc = 5
			7:
				uVar3 = ((((((((((((uVar2) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 6
			8:
				var _v3: int = f583440(param_1, 0)
				uVar2 = ((_v3) & 0xffffffff)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 1
			10:
				var _v4: int = f583470(param_1, 0, 0)
				iVar1 = _zp_signed(_v4, 32)
				_pc = 9
			11:
				return ((0x7f) & 0xffffffff)
			12:
				var _v5: int = f5758a0(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0, 1)
				_pc = 11
			13:
				m.set_u32(0xa55c8c, (((((m.u16(0xa55c8e)) << 16) | ((_zp_signed((((_zp_signed((_zp_signed((((((((m.u32(0xa55c8c)) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffff), 32) & _zp_signed(0xff, 32)), 32)) << 8) | ((1) & 0xff)), 16)) & 0xffff))) & 0xffffffff))
				_pc = 12
			14:
				_pc = 13 if (int(((((((((((((((m.u32((0xa56434 + ((((((uVar2) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((uVar2) & 0xffffffff))) != 0 else 12
			15:
				return ((0x7e) & 0xffffffff)
			16:
				_pc = 15 if (int(_zp_signed(_zp_signed(m.u8((((0xa55d68 + ((((((uVar2) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) * 2)) & 0xffffffff)), 8), 32) == _zp_signed(0, 32))) != 0 else 14
			17:
				uVar2 = ((_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 16
			18:
				return ((0x7d) & 0xffffffff)
			19:
				var _v6: int = f5b9170((((((((((((((-(((int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(1, 32))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 18
			20:
				_pc = 19 if (int(_zp_signed(m.u8(0xa55c8c), 32) != _zp_signed(0, 32))) != 0 else 18
			21:
				var _v7: int = f5b9170(((((((((_zp_signed((((((((in_EDX) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((_zp_signed((_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 20
			22:
				return ((0x7c) & 0xffffffff)
			23:
				var _v8: int = f578b60(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32))
				_pc = 22
			24:
				var _v9: int = _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)
				_pc = 1
				if _v9 == 0x80: _pc = 10
				if _v9 == 0x7f: _pc = 17
				if _v9 == 0x7e: _pc = 21
				if _v9 == 0x7d: _pc = 23
			25:
				_pc = 24 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58f140(param_1: int, param_2: int) -> int:
	var in_EAX: int = 0
	var uVar1: int = 0
	var _pc: int = 14
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((uVar1) & 0xffffffff)
			2:
				var _v0: int = f58d970(param_1)
				uVar1 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				return ((0) & 0xffffffff)
			4:
				_pc = 3 if (int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 2
			5:
				return ((0) & 0xffffffff)
			6:
				_pc = 5 if (int((((((((m.u32(0xa577ec)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 4
			7:
				return (((((((uVar1) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			8:
				_pc = 7 if (int(((uVar1) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 6
			9:
				uVar1 = ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(8, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(2, 32)), 32)) & 0xffffffff)
				_pc = 8
			10:
				return ((uVar1) & 0xffffffff)
			11:
				var _v1: int = f589c00(param_1, param_2)
				uVar1 = ((_v1) & 0xffffffff)
				_pc = 10
			12:
				_pc = 11 if (int(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(8, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(1, 32))) != 0 else 9
			13:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			14:
				_pc = 13 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 12
	return 0


func f58f1a0(param_1: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var _pc: int = 13
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				var _v0: int = f5bf800(0x30)
				_pc = 2
			4:
				var _v2: int = int((int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xe000, 32)), 32), 32) == _zp_signed(0x2000, 32))) != 0)
				if _v2 != 0:
					var _v1: int = f570b40(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
					iVar1 = _zp_signed(_v1, 32)
					_v2 = int((int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0)
				var _v4: int = int((_v2) != 0)
				if _v4 != 0:
					var _v3: int = f56a000(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
					iVar1 = _zp_signed(_v3, 32)
					_v4 = int((int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0)
				var _v6: int = int((_v4) != 0)
				if _v6 != 0:
					var _v5: int = f599e30(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0x526, m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)))
					iVar1 = _zp_signed(_v5, 32)
					_v6 = int((int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0)
				_pc = 3 if (_v6) != 0 else 1
			5:
				return ((0x7e) & 0xffffffff)
			6:
				var _v7: int = f40c940(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 6, 0x526, m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)))
				_pc = 5
			7:
				return ((0x7c) & 0xffffffff)
			8:
				var _v8: int = f40cab0()
				var _v9: int = f5adb10(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _v8, 1, 0, 0xd, _zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				_pc = 7
			9:
				return ((100) & 0xffffffff)
			10:
				var _v10: int = f5b9170(((((((((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x7c, 32)), 32), 32) >> ((0x10) & 31)), 32), 16)) << 16) | ((_zp_signed((_zp_signed(_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 16), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 0, 0, 0)
				_pc = 9
			11:
				var _v11: int = _zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) - _zp_signed(0x7c, 32)), 32)
				_pc = 1
				if _v11 == 4: _pc = 4
				if _v11 == 3: _pc = 6
				if _v11 == 2: _pc = 8
				if _v11 == 1: _pc = 8
				if _v11 == 0: _pc = 10
			12:
				_pc = 11 if (int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
			13:
				var _v12: int = f40cab0()
				_pc = 12
	return 0


func f58f2d0(param_1: int) -> int:
	var uVar1: int = 0
	var in_EAX: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var uVar5: int = 0
	var uVar6: int = 0
	var _pc: int = 23
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f579790(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), m.u16(param_1), ((((((((((((((((((((uVar4) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((uVar6) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x100) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0x23) & 0xffffffff))) & 0xffffffff))
				in_EAX = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 1
			4:
				_pc = 3 if (int(_zp_signed(((in_EAX) & 0xffff), 32) < _zp_signed(0x784, 32))) != 0 else 2
			5:
				var _v1: int = f4022e0(_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + (((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32))
				in_EAX = ((_v1) & 0xffffffff)
				_pc = 4
			6:
				_pc = 5 if (int(_zp_signed(0x77f, 32) < _zp_signed(uVar1, 32))) != 0 else 2
			7:
				var _v2: int = f4022e0(_zp_signed((_zp_signed(m.u16(((((0xa55d74 + ((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4) + (((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32))
				uVar1 = ((_v2) & 0xffff)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			9:
				in_EAX = ((0) & 0xffffffff)
				_pc = 8
			10:
				var _v3: int = f577950(param_1, (((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar5, 0x40)
				iVar2 = _zp_signed(_v3, 32)
				_pc = 9
			11:
				uVar4 = (((((((in_EAX) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff)
				_pc = 10
			12:
				uVar6 = (((((((in_EAX) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff)
				_pc = 11
			13:
				_pc = 12 if (int((((((((in_EAX) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 1
			14:
				in_EAX = ((m.u32((0xa55d74 + (((((((((((uVar5) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((((((((((((uVar3) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff)
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			16:
				in_EAX = ((0) & 0xffffffff)
				_pc = 15
			17:
				var _v4: int = f583510(param_1, (((((uVar3) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff), uVar5)
				iVar2 = _zp_signed(_v4, 32)
				_pc = 16
			18:
				uVar5 = ((((((((((((uVar3) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 17
			19:
				var _v5: int = f583440(param_1, 0)
				uVar3 = ((_v5) & 0xffffffff)
				_pc = 18
			20:
				_pc = 19 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			21:
				in_EAX = ((0) & 0xffffffff)
				_pc = 20
			22:
				var _v6: int = f583470(param_1, 0, 0)
				iVar2 = _zp_signed(_v6, 32)
				_pc = 21
			23:
				_pc = 22 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0 else 1
	return 0


func f58f3d0(param_1: int) -> int:
	var psVar1: int = 0
	var in_EAX: int = 0
	var pbVar2: int = 0
	var _pc: int = 11
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				in_EAX = ((0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 7 if (int(((param_1) & 0xffffffff) != ((((0x0) & 0xffffffff)) & 0xffffffff))) != 0 else 2
			4:
				param_1 = ((((_zp_signed((_zp_signed(_zp_signed(param_1, 32), 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32)) & 0xffffffff)) & 0xffffffff)
				_pc = 3
			5:
				pbVar2 = (((pbVar2 + (2) * 1)) & 0xffffffff)
				_pc = 4
			6:
				var _v0: int = f579790(m.u8(pbVar2), ((((((((_zp_signed((_zp_signed(m.u8((((psVar1 + (1) * 2)) & 0xffffffff)), 32) >> ((1) & 31)), 32)) << 8) | ((_zp_signed(_zp_signed(m.u16((psVar1 + (1) * 2)), 16), 8)) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), ((((((((((((m.u8((pbVar2 + (1) * 1))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((2) & 0xffffffff))) & 0xffffffff))
				_pc = 5
			7:
				_pc = 6 if (int((((((((m.u32((0xa55d74 + (((((((((((((m.u8((pbVar2 + (1) * 1))) & 0xffffffff)) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(pbVar2), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) == ((0) & 0xffffffff))) != 0 else 5
			8:
				param_1 = ((((0x2) & 0xffffffff)) & 0xffffffff)
				_pc = 7
			9:
				pbVar2 = (((((param_1 + (3) * 2)) & 0xffffffff)) & 0xffffffff)
				_pc = 8
			10:
				var _v1: int = int((int(_zp_signed(_zp_signed((_zp_signed(_zp_signed(m.u16((param_1 + (2) * 2)), 16), 32) & _zp_signed(4, 32)), 32), 32) == _zp_signed(0, 32))) != 0)
				if _v1 != 0:
					in_EAX = (((((((m.u32((0xa55d74 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((_zp_signed(m.u16((param_1 + (1) * 2)), 16)) & 0xffff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32), 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(((_zp_signed(m.u16((param_1 + (1) * 2)), 16)) & 0xffff), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32), 32)), 32)) * 4))) & 0xffffffff) & ((0xfff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
					_v1 = int((int(_zp_signed(_zp_signed(in_EAX, 16), 32) == _zp_signed(_zp_signed(m.u16(param_1), 16), 32))) != 0)
				_pc = 9 if (int((_v1) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(_zp_signed(m.u16((param_1 + (2) * 2)), 16), 32) & _zp_signed(0xe000, 32)), 32), 32) == _zp_signed(0x4000, 32))) != 0)) != 0 else 1
			11:
				psVar1 = ((param_1) & 0xffffffff)
				_pc = 10
	return 0


func f58f4b0(param_1: int, param_2: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var _pc: int = 24
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7e) & 0xffffffff)
			2:
				return ((0) & 0xffffffff)
			3:
				var _v0: int = f5bce00(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 1, 0, 1)
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(m.u16(0xa57822), 32) != _zp_signed(0, 32))) != 0 else 1
			5:
				return ((0x7f) & 0xffffffff)
			6:
				var _v1: int = f5bcf40(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 0x529)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 1
			8:
				var _v2: int = f57f130(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), 1, 0, 0, 1)
				iVar1 = _zp_signed(_v2, 32)
				_pc = 7
			9:
				return ((0x7e) & 0xffffffff)
			10:
				_pc = 9 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 8
			11:
				var _v3: int = f5699c0(0x49c)
				iVar1 = _zp_signed(_v3, 32)
				_pc = 10
			12:
				return ((0) & 0xffffffff)
			13:
				_pc = 12 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 11
			14:
				_pc = 4 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 13
			15:
				return ((0) & 0xffffffff)
			16:
				var _v4: int = f5778b0(param_1, _zp_signed((_zp_signed(m.u16((param_2 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_2 + (1) * 2))) & 0xffff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32))
				_pc = 15
			17:
				var _v5: int = f5b9170((((((((((((((_zp_signed((((((((uVar2) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_2 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb1) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(_zp_signed((_zp_signed(((m.u16((param_2 + (1) * 2))) & 0xff), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 1, 0)
				_pc = 16
			18:
				m.set_u8((((param_2 + (2) * 2)) & 0xffffffff), ((_zp_signed((_zp_signed(m.u8((((param_2 + (2) * 2)) & 0xffffffff)), 32) | _zp_signed(0xe, 32)), 32)) & 0xff))
				_pc = 17
			19:
				_pc = 18 if (int(_zp_signed(_zp_signed(uVar2, 16), 32) == _zp_signed(0x16, 32))) != 0 else 15
			20:
				var _v6: int = f4025d0(m.u16(param_2))
				uVar2 = ((_v6) & 0xffffffff)
				_pc = 19
			21:
				_pc = 20 if (int(((param_2) & 0xffffffff) != ((((0x0) & 0xffffffff)) & 0xffffffff))) != 0 else 15
			22:
				_pc = 21 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 14
			23:
				return ((0) & 0xffffffff)
			24:
				_pc = 23 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 22
	return 0


func f58f640(param_1: int) -> int:
	var _stack: int = m.local(256)
	var uVar1: int = 0
	var iVar2: int = 0
	var extraout_var: int = 0
	var extraout_var_00: int = 0
	var extraout_var_01: int = 0
	var extraout_var_02: int = 0
	var _pc: int = 26
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0x7f) & 0xffffffff)
			2:
				var _v0: int = f5bf9a0(1, 0)
				_pc = 1
			3:
				var _v1: int = f5bf800((_stack + 0))
				_pc = 2
			4:
				var _v2: int = f5bdf40((_stack + 0), 0x47, uVar1)
				_pc = 3
			5:
				var _v3: int = f402290(uVar1)
				uVar1 = ((_v3) & 0xffffffff)
				_pc = 4
			6:
				var _v4: int = f402460(0x2fa)
				uVar1 = ((_v4) & 0xffffffff)
				_pc = 5
			7:
				return ((0x7f) & 0xffffffff)
			8:
				m.set_u16(0xa558b4, ((1) & 0xffff))
				_pc = 7
			9:
				_pc = 8 if (int(((((((((((((((((((((((m.u32(0xa54e5c)) & 0xffffffff) >> ((1) & 31))) & 0xffffffff)) & 0xffffffff) & ((3) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) >> ((_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32)) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 6
			10:
				return ((0) & 0xffffffff)
			11:
				_pc = 10 if (int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0 else 9
			12:
				var _v5: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar1, 0)
				iVar2 = _zp_signed(_v5, 32)
				_pc = 11
			13:
				var _v6: int = f4022e0(m.u16(param_1))
				uVar1 = ((_v6) & 0xffffffff)
				_pc = 12
			14:
				return ((0) & 0xffffffff)
			15:
				var _v7: int = f5b9170(((((((((extraout_var) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x20) & 0xffffffff))) & 0xffffffff), 0x2fa, 0xd, 0)
				_pc = 14
			16:
				var _v8: int = f5b9170(((((((((extraout_var_02) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0xf1) & 0xffffffff))) & 0xffffffff), 0xf, 0, 0)
				_pc = 15
			17:
				var _v9: int = f5b9170(((((((((extraout_var_00) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x20) & 0xffffffff))) & 0xffffffff), 0x2fa, 0xd, 0)
				_pc = 16
			18:
				var _v10: int = f5b9170(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32), 32) | _zp_signed(0x6c, 32)), 32), 0xd, (((((((((((((((m.u32(0xa582a4)) & 0xffffffff) >> ((0xc) & 31))) & 0xffffffff)) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((((((((((((m.u32(0xa582a4)) & 0xffffffff) >> ((0x18) & 31))) & 0xffffffff)) & 0xffffffff) & ((0x7f) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 17
			19:
				var _v11: int = f5b9170(((((((((extraout_var_01) << 16) | ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) << ((0xf) & 31)), 32)) & 0xffff))) & 0xffffffff) | ((0x60) & 0xffffffff))) & 0xffffffff), 1, 0, 0)
				_pc = 18
			20:
				_pc = 19 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 14
			21:
				var _v12: int = f599e30(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar1, 0)
				iVar2 = _zp_signed(_v12, 32)
				_pc = 20
			22:
				var _v13: int = f4022e0(m.u16(param_1))
				uVar1 = ((_v13) & 0xffffffff)
				_pc = 21
			23:
				_pc = 22 if (int(_zp_signed(m.u16(0xa558b4), 32) != _zp_signed(0, 32))) != 0 else 14
			24:
				_pc = 23 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) != _zp_signed(0x80, 32))) != 0 else 13
			25:
				return ((0) & 0xffffffff)
			26:
				_pc = 25 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 24
	return 0


func f58f830(param_1: int) -> int:
	var uVar1: int = 0
	var iVar2: int = 0
	var uVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 19
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				var _v0: int = f575160(uVar4, uVar3, 0)
				_pc = 1
			3:
				return ((0) & 0xffffffff)
			4:
				var _v1: int = f577880(param_1, uVar4, uVar3)
				_pc = 3
			5:
				_pc = 4 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 2
			6:
				var _v2: int = f567990(_zp_signed((_zp_signed(m.u16(((((0xa55d74 + (((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32))
				iVar2 = _zp_signed(_v2, 32)
				_pc = 5
			7:
				return ((0x7f) & 0xffffffff)
			8:
				var _v3: int = f575160(uVar4, uVar3, 1)
				_pc = 7
			9:
				_pc = 8 if (int((int((int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16((0xa55d7a + ((((((((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 2)), 32) & _zp_signed(2, 32)), 32), 32) == _zp_signed(0, 32))) != 0)) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16((0xa55d7a + ((((((((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x6a2) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) + (((((((uVar3) & 0xffffffff) * ((0x48) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 2)), 32) & _zp_signed(1, 32)), 32), 32) != _zp_signed(0, 32))) != 0)) != 0 else 1
			10:
				var _v4: int = f583470(param_1, 0, 0)
				iVar2 = _zp_signed(_v4, 32)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(0x80, 32))) != 0 else 1
			12:
				return ((0x7e) & 0xffffffff)
			13:
				var _v5: int = f5b9170((((((((((((((-(((int(((uVar4) & 0xffffffff) != ((0) & 0xffffffff))) & 0xffffffff)))) & 0xffffffff)) & 0xffffffff) & ((0x8000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) | ((0xf1) & 0xffffffff))) & 0xffffffff), 0xf, 0, 0)
				_pc = 12
			14:
				var _v6: int = f578430(uVar4, _zp_signed((_zp_signed(m.u16(((((0xa55d74 + (((((((((((uVar1) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar3) & 0xffffffff) * ((0x24) & 0xffffffff))) & 0xffffffff)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32))
				_pc = 13
			15:
				_pc = 14 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(127, 32))) != 0 else 11
			16:
				_pc = 6 if (int(_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) == _zp_signed(126, 32))) != 0 else 15
			17:
				uVar3 = ((((((((((((uVar1) & 0xffffffff) >> ((8) & 31))) & 0xffffffff)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 16
			18:
				uVar4 = (((((((uVar1) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 17
			19:
				var _v7: int = f583440(param_1, 0)
				uVar1 = ((_v7) & 0xffffffff)
				_pc = 18
	return 0


func f58f940(param_1: int) -> int:
	var iVar1: int = 0
	var sVar2: int = 0
	var in_EAX: int = 0
	var uVar3: int = 0
	var cVar4: int = 0
	var iVar5: int = 0
	var local_4: int = 0
	var _pc: int = 15
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar3) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f576940(param_1, local_4)
				uVar3 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 10 if (int(_zp_signed(iVar5, 32) < _zp_signed(0x2d0, 32))) != 0 else 2
			4:
				cVar4 = _zp_signed(_zp_signed((_zp_signed(cVar4, 32) + _zp_signed(1, 32)), 32), 8)
				_pc = 3
			5:
				iVar5 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(0x90, 32)), 32), 32)
				_pc = 4
			6:
				local_4 = (((((((local_4) & 0xffffffff) | ((_zp_signed((_zp_signed(1, 32) << ((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(cVar4, 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(_zp_signed((-(0x10)), 32), 32)), 32), 32)), 32), 32) + _zp_signed(0x10, 32)), 32), 32) & _zp_signed(0x1f, 32)), 32)) & 31)), 32)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(sVar2, 32) == _zp_signed(4, 32))) != 0 else 5
			8:
				var _v1: int = f4026c0(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55d74, 32), 32) + _zp_signed(iVar1, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32))
				sVar2 = _zp_signed(_v1, 16)
				_pc = 7
			9:
				_pc = 8 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55d7a, 32), 32) + _zp_signed(iVar1, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(2, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 5
			10:
				iVar1 = _zp_signed(_zp_signed((_zp_signed(iVar5, 32) + _zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((-(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))), 32), 32) - _zp_signed(1, 32)), 32), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0xd44, 32)), 32), 32)), 32), 32)
				_pc = 9
			11:
				iVar5 = _zp_signed(0, 32)
				_pc = 10
			12:
				return (((((((in_EAX) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			13:
				_pc = 12 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 11
			14:
				local_4 = ((0) & 0xffffffff)
				_pc = 13
			15:
				cVar4 = _zp_signed(0, 8)
				_pc = 14
	return 0


func f58f9f0(param_1: int) -> int:
	var iVar1: int = 0
	var uVar2: int = 0
	var _pc: int = 9
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5adb10(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), ((0xa566f0 + (((((((((((uVar2) & 0xffffffff) & ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) * 4) + ((((((uVar2) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff)) * 4), 1, 0x20, 0xe, (((((uVar2) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff))
				uVar2 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				_pc = 2 if (int(_zp_signed(_zp_signed((((((uVar2) & 0xffffffff) >> ((8) & 31))) & 0xffffffff), 8), 32) == _zp_signed(14, 32))) != 0 else 1
			4:
				var _v1: int = f5687d0(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(6, 32)), 32)) & 0xffffffff)))
				uVar2 = ((_v1) & 0xffffffff)
				_pc = 3
			5:
				_pc = 4 if (int((int(((uVar2) & 0xffffffff) != ((0) & 0xffffffff))) != 0 and (int(_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(4, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xe000, 32)), 32), 32) == _zp_signed(0x2000, 32))) != 0)) != 0 else 1
			6:
				var _v2: int = f56a000(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				uVar2 = ((_v2) & 0xffffffff)
				_pc = 5
			7:
				_pc = 6 if (int(_zp_signed(iVar1, 32) != _zp_signed(0, 32))) != 0 else 1
			8:
				uVar2 = ((0) & 0xffffffff)
				_pc = 7
			9:
				var _v3: int = f570b40(_zp_signed((_zp_signed(m.u8(((_zp_signed((_zp_signed(param_1, 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32))
				iVar1 = _zp_signed(_v3, 32)
				_pc = 8
	return 0


func f58fa90(param_1: int, param_2: int) -> int:
	var _stack: int = m.local(256)
	var uVar1: int = 0
	var extraout_AX: int = 0
	var iVar2: int = 0
	var iVar3: int = 0
	var extraout_var: int = 0
	var uVar6: int = 0
	var uVar4: int = 0
	var puVar5: int = 0
	var puVar7: int = 0
	var uVar8: int = 0
	var _pc: int = 95
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return ((0) & 0xffffffff)
			2:
				return ((0x7f) & 0xffffffff)
			3:
				var _v0: int = f5bf800(0x49)
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 1
			5:
				var _v1: int = f5829d0(param_1, param_2, 0)
				iVar2 = _zp_signed(_v1, 32)
				_pc = 4
			6:
				return ((0x7f) & 0xffffffff)
			7:
				return ((0x7e) & 0xffffffff)
			8:
				m.set_u16((param_1 + (3) * 2), ((((m.u32(0xa5504c)) & 0xffff)) & 0xffff))
				_pc = 7
			9:
				var _v2: int = f5b9170((((((((((((((_zp_signed((((((((iVar2) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), (((((((((((((((m.u32(0xa5504c)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 8
			10:
				var _v4: int = int((int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0)
				if _v4 != 0:
					var _v3: int = f570b70(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), _zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xfff, 32)), 32))
					iVar2 = _zp_signed(_v3, 32)
					_v4 = int((int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0)
				var _v6: int = int((_v4) != 0)
				if _v6 != 0:
					var _v5: int = f5aa480()
					iVar2 = _zp_signed(_v5, 32)
					_v6 = int((int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0)
				_pc = 9 if (_v6) != 0 else 6
			11:
				var _v7: int = f402690(_zp_signed((_zp_signed(uVar1, 32) & _zp_signed(0xfff, 32)), 32))
				iVar2 = _zp_signed(_v7, 32)
				_pc = 10
			12:
				uVar1 = ((m.u16(((((0xa56434 + (m.u32(0xa5504c)) * 4) + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) * 4)) & 0xffffffff))) & 0xffff)
				_pc = 11
			13:
				_pc = 12 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 6
			14:
				var _v8: int = f5aa440(1)
				iVar2 = _zp_signed(_v8, 32)
				_pc = 13
			15:
				return ((0x80) & 0xffffffff)
			16:
				_pc = 15 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 14
			17:
				return ((0x7d) & 0xffffffff)
			18:
				var _v9: int = f5bf800((_stack + 0))
				_pc = 17
			19:
				var _v10: int = f5bdfc0((_stack + 0), 0x4b, 2)
				_pc = 18
			20:
				return ((0x7d) & 0xffffffff)
			21:
				return ((0x7b) & 0xffffffff)
			22:
				m.set_u16((param_1 + (4) * 2), ((((m.u32(0xa5504c)) & 0xffff)) & 0xffff))
				_pc = 21
			23:
				var _v11: int = f5b9170((((((((((((((_zp_signed((((((((iVar2) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), (((((((((((((((m.u32(0xa5504c)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 22
			24:
				_pc = 23 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 20
			25:
				var _v12: int = f5aa480()
				iVar2 = _zp_signed(_v12, 32)
				_pc = 24
			26:
				return ((0x7d) & 0xffffffff)
			27:
				_pc = 26 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 25
			28:
				var _v13: int = f402690(_zp_signed((_zp_signed(m.u16(((((0xa56434 + (m.u32(0xa5504c)) * 4) + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32))
				iVar2 = _zp_signed(_v13, 32)
				_pc = 27
			29:
				return ((0x7d) & 0xffffffff)
			30:
				_pc = 29 if (int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0 else 28
			31:
				var _v14: int = f5aa440(1)
				iVar2 = _zp_signed(_v14, 32)
				_pc = 30
			32:
				return ((0x7e) & 0xffffffff)
			33:
				_pc = 32 if (int((((((((m.u32(0xa54e54)) & 0xffffffff) & ((0x102) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) != ((0) & 0xffffffff))) != 0 else 31
			34:
				return ((0x7a) & 0xffffffff)
			35:
				m.set_u16((param_1 + (5) * 2), ((((m.u32(0xa5504c)) & 0xffff)) & 0xffff))
				_pc = 34
			36:
				var _v15: int = f5b9170((((((((((((((_zp_signed((((((((iVar2) & 0xffffffff)) & 0xffffffff) >> ((0x10) & 31))) & 0xffffffff), 16)) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), (((((((((((((((m.u32(0xa5504c)) & 0xffffffff) & ((0xff) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 35
			37:
				return ((0x7b) & 0xffffffff)
			38:
				_pc = 37 if (int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0 else 36
			39:
				var _v16: int = f5aa480()
				iVar2 = _zp_signed(_v16, 32)
				_pc = 38
			40:
				return ((0x7b) & 0xffffffff)
			41:
				_pc = 40 if (int(((m.u32(0xa5504c)) & 0xffffffff) == ((((m.u16((param_1 + (4) * 2))) & 0xffff)) & 0xffffffff))) != 0 else 39
			42:
				return ((0x7b) & 0xffffffff)
			43:
				_pc = 42 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 41
			44:
				var _v17: int = f402690(_zp_signed((_zp_signed(m.u16(((((0xa56434 + (m.u32(0xa5504c)) * 4) + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32) * _zp_signed(0x351, 32)), 32)) * 4)) & 0xffffffff)), 32) & _zp_signed(0xfff, 32)), 32))
				iVar2 = _zp_signed(_v17, 32)
				_pc = 43
			45:
				return ((0x7b) & 0xffffffff)
			46:
				_pc = 45 if (int(_zp_signed(iVar2, 32) == _zp_signed(0, 32))) != 0 else 44
			47:
				var _v18: int = f5aa440(1)
				iVar2 = _zp_signed(_v18, 32)
				_pc = 46
			48:
				return ((0x79) & 0xffffffff)
			49:
				var _v19: int = f5bcfe0(_zp_signed((_zp_signed(1, 32) - _zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 32)), 32), m.u16(param_1), (param_1 + (3) * 2), 3)
				_pc = 48
			50:
				_pc = 56 if (int(_zp_signed(0, 32) < _zp_signed(iVar2, 32))) != 0 else 49
			51:
				puVar7 = (((puVar7 + (_zp_signed((-(1)), 32)) * 2)) & 0xffffffff)
				_pc = 50
			52:
				iVar2 = _zp_signed(_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(_zp_signed((-(1)), 32), 32)), 32), 32)
				_pc = 51
			53:
				m.set_u16(puVar7, ((uVar6) & 0xffff))
				_pc = 52
			54:
				m.set_u16((param_1 + (_zp_signed((_zp_signed(iVar3, 32) + _zp_signed(3, 32)), 32)) * 2), ((m.u16(puVar7)) & 0xffff))
				_pc = 53
			55:
				uVar6 = ((m.u16((param_1 + (_zp_signed((_zp_signed(iVar3, 32) + _zp_signed(3, 32)), 32)) * 2))) & 0xffff)
				_pc = 54
			56:
				var _v20: int = f5bddb0(_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(1, 32)), 32))
				iVar3 = _zp_signed(_v20, 32)
				_pc = 55
			57:
				puVar7 = (((param_1 + (5) * 2)) & 0xffffffff)
				_pc = 56
			58:
				iVar2 = _zp_signed(2, 32)
				_pc = 57
			59:
				return ((0x78) & 0xffffffff)
			60:
				var _v21: int = f5b9170((((((((((((((uVar6) << 16) | ((m.u16((param_1 + (1) * 2))) & 0xffff))) & 0xffffffff) << ((0xf) & 31))) & 0xffffffff)) & 0xffffffff) | ((8) & 0xffffffff))) & 0xffffffff), _zp_signed((_zp_signed(((m.u16((param_1 + (1) * 2))) & 0xff), 32) & _zp_signed(1, 32)), 32), ((((((((((((m.u8(((((param_1 + (_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) * 2) + (3) * 2)) & 0xffffffff))) & 0xffffffff)) & 0xffffffff) << ((8) & 31))) & 0xffffffff)) & 0xffffffff) | ((0xb) & 0xffffffff))) & 0xffffffff), 0)
				_pc = 59
			61:
				_pc = 68 if (int(_zp_signed(iVar2, 32) < _zp_signed(3, 32))) != 0 else 60
			62:
				uVar6 = ((extraout_var) & 0xffff)
				_pc = 61
			63:
				puVar7 = (((puVar7 + (1) * 2)) & 0xffffffff)
				_pc = 62
			64:
				iVar2 = _zp_signed(_zp_signed((_zp_signed(iVar2, 32) + _zp_signed(1, 32)), 32), 32)
				_pc = 63
			65:
				m.set_u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff), (((((_zp_signed(iVar2, 8)) << 8) | ((m.u8(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff))) & 0xff))) & 0xffff))
				_pc = 60
			66:
				uVar6 = ((0) & 0xffff)
				_pc = 65
			67:
				_pc = 66 if (int(_zp_signed(extraout_AX, 32) == _zp_signed(m.u16(0xa57822), 32))) != 0 else 64
			68:
				var _v22: int = f570230(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0xb, m.u16(puVar7))
				_pc = 67
			69:
				puVar7 = (((param_1 + (3) * 2)) & 0xffffffff)
				_pc = 68
			70:
				iVar2 = _zp_signed(0, 32)
				_pc = 69
			71:
				return ((0x77) & 0xffffffff)
			72:
				var _v23: int = f5bf800((_stack + 0))
				_pc = 71
			73:
				var _v24: int = f5bdf40((_stack + 0), 0x108, uVar4)
				_pc = 72
			74:
				var _v25: int = f402290(uVar4)
				uVar4 = ((_v25) & 0xffffffff)
				_pc = 73
			75:
				var _v26: int = f570230(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0xb, m.u16((param_1 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) + _zp_signed(3, 32)), 32)) * 2)))
				uVar4 = ((_v26) & 0xffffffff)
				_pc = 74
			76:
				return ((0x76) & 0xffffffff)
			77:
				_pc = 83 if (int(_zp_signed(_zp_signed(uVar8, 32), 32) < _zp_signed(3, 32))) != 0 else 76
			78:
				puVar5 = (((puVar5 + (1) * 2)) & 0xffffffff)
				_pc = 77
			79:
				uVar8 = (((((((uVar8) & 0xffffffff) + ((1) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
				_pc = 78
			80:
				m.set_u16((param_1 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) + _zp_signed(3, 32)), 32)) * 2), ((_zp_signed((_zp_signed(m.u16((param_1 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) + _zp_signed(3, 32)), 32)) * 2)), 32) - _zp_signed(((int(_zp_signed(m.u16(puVar5), 32) < _zp_signed(((m.u16((param_1 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) + _zp_signed(3, 32)), 32)) * 2))) & 0xffff), 32))) & 0xffff), 32)), 32)) & 0xffff))
				_pc = 79
			81:
				var _v27: int = f575af0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), uVar4, 0)
				_pc = 80
			82:
				var _v28: int = f5700f0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0xb, m.u16(puVar5))
				uVar4 = ((_v28) & 0xffffffff)
				_pc = 81
			83:
				_pc = 82 if (int(((uVar8) & 0xffffffff) != ((_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32)) & 0xffffffff))) != 0 else 79
			84:
				puVar5 = (((param_1 + (3) * 2)) & 0xffffffff)
				_pc = 83
			85:
				uVar8 = ((0) & 0xffffffff)
				_pc = 84
			86:
				var _v29: int = f575af0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), puVar5, 0)
				_pc = 1
			87:
				return ((0) & 0xffffffff)
			88:
				var _v30: int = f5adb10(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), puVar5, 1, 0, 0xb, uVar6)
				_pc = 87
			89:
				_pc = 88 if (int(_zp_signed(iVar2, 32) != _zp_signed(0, 32))) != 0 else 86
			90:
				var _v31: int = f402690(_zp_signed((_zp_signed(m.u16(puVar5), 32) & _zp_signed(0xfff, 32)), 32))
				iVar2 = _zp_signed(_v31, 32)
				_pc = 89
			91:
				var _v32: int = f5700f0(_zp_signed((_zp_signed(m.u8((((param_1 + (1) * 2)) & 0xffffffff)), 32) & _zp_signed(1, 32)), 32), 0xb, uVar6)
				puVar5 = ((((_v32) & 0xffffffff)) & 0xffffffff)
				_pc = 90
			92:
				uVar6 = ((m.u16((param_1 + (_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) >> ((8) & 31)), 32), 32) + _zp_signed(3, 32)), 32)) * 2))) & 0xffff)
				_pc = 91
			93:
				var _v33: int = _zp_signed((_zp_signed(m.u16(((_zp_signed((_zp_signed(_zp_signed(0xa55c88, 32), 32) + _zp_signed(2, 32)), 32)) & 0xffffffff)), 32) & _zp_signed(0xff, 32)), 32)
				_pc = 1
				if _v33 == 0x80: _pc = 5
				if _v33 == 0x7f: _pc = 16
				if _v33 == 0x7e: _pc = 19
				if _v33 == 0x7d: _pc = 33
				if _v33 == 0x7b: _pc = 47
				if _v33 == 0x7a: _pc = 58
				if _v33 == 0x79: _pc = 70
				if _v33 == 0x78: _pc = 75
				if _v33 == 0x77: _pc = 85
				if _v33 == 0x76: _pc = 92
			94:
				return ((0) & 0xffffffff)
			95:
				_pc = 94 if (int(_zp_signed(_zp_signed((_zp_signed(m.u8((((param_1 + (2) * 2)) & 0xffffffff)), 32) & _zp_signed(4, 32)), 32), 32) != _zp_signed(0, 32))) != 0 else 93
	return 0


func f58ff70(param_1: int) -> int:
	var bVar1: int = 0
	var uVar2: int = 0
	var iVar3: int = 0
	var uVar4: int = 0
	var _pc: int = 12
	while true:
		match _pc:
			0:
				return ((0) & 0xffffffff)
			1:
				return (((((((uVar2) & 0xffffffff) & ((0xffff0000) & 0xffffffff))) & 0xffffffff)) & 0xffffffff)
			2:
				var _v0: int = f5747e0(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32), ((((((((_zp_signed((_zp_signed(bVar1, 32) >> ((1) & 31)), 32)) << 8) | ((bVar1) & 0xff))) & 0xffffffff) & ((0x1f01) & 0xffffffff))) & 0xffffffff), uVar4, 2)
				uVar2 = ((_v0) & 0xffffffff)
				_pc = 1
			3:
				bVar1 = ((((m.u16((param_1 + (1) * 2))) & 0xff)) & 0xff)
				_pc = 2
			4:
				_pc = 3 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			5:
				uVar2 = ((0) & 0xffffffff)
				_pc = 4
			6:
				var _v1: int = f57c060(param_1, (((((uVar4) & 0xffffffff) & ((0xffff) & 0xffffffff))) & 0xffffffff))
				iVar3 = _zp_signed(_v1, 32)
				_pc = 5
			7:
				var _v2: int = f583440(param_1, 0)
				uVar4 = ((_v2) & 0xffffffff)
				_pc = 6
			8:
				_pc = 7 if (int(_zp_signed(iVar3, 32) != _zp_signed(0, 32))) != 0 else 1
			9:
				uVar2 = ((0) & 0xffffffff)
				_pc = 8
			10:
				var _v3: int = f583470(param_1, 0, 0)
				iVar3 = _zp_signed(_v3, 32)
				_pc = 9
			11:
				_pc = 10 if (int(_zp_signed(_zp_signed((_zp_signed(((m.u32((0xa55d74 + ((((((_zp_signed((_zp_signed(_zp_signed((_zp_signed(_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) >> ((1) & 31)), 32), 32) & _zp_signed(0x1f, 32)), 32), 32) * _zp_signed(0x24, 32)), 32)) & 0xffffffff) + (((((((uVar2) & 0xffffffff) * ((0x351) & 0xffffffff))) & 0xffffffff)) & 0xffffffff))) & 0xffffffff)) * 4))) & 0xffff), 32) & _zp_signed(0xfff, 32)), 32), 32) == _zp_signed(m.u16(param_1), 32))) != 0 else 1
			12:
				uVar2 = ((_zp_signed((_zp_signed(m.u16((param_1 + (1) * 2)), 32) & _zp_signed(1, 32)), 32)) & 0xffffffff)
				_pc = 11
	return 0
