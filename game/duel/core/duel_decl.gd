class_name DuelDecl
extends DuelBase
## GENERADO por re/scripts/gen_decl.py; no editar a mano.
## Declaraciones de todas las funciones portadas o pendientes del motor (ver PORTING.md).

func f401a20(_index: int) -> int:
	return _unported(0x401a20)

func f401a70(_index: int) -> int:
	return _unported(0x401a70)

func f401ad0(_card_id: int) -> int:
	return _unported(0x401ad0)

func f401b50(_index: int) -> int:
	return _unported(0x401b50)

func f401ca0(_p: int, _card_id: int) -> int:
	return _unported(0x401ca0)

func f4024c0(_p: int, __a2: int, _delta: int) -> int:
	return _unported(0x4024c0)

func f402610(_p: int, _card_id: int) -> int:
	return _unported(0x402610)

func f4026b0(_p: int, _delta: int) -> int:
	return _unported(0x4026b0)

func f4027e0() -> int:
	return _unported(0x4027e0)

func f402840(_phase: int) -> int:
	return _unported(0x402840)

func f4028d0() -> int:
	return _unported(0x4028d0)

func f4029d0() -> int:
	return _unported(0x4029d0)

func f402a00() -> int:
	return _unported(0x402a00)

func f402ab0() -> int:
	return _unported(0x402ab0)

func f402ad0() -> int:
	return _unported(0x402ad0)

func f402b30() -> int:
	return _unported(0x402b30)

func f402ba0() -> int:
	return _unported(0x402ba0)

func f402c00() -> int:
	return _unported(0x402c00)

func f402c30() -> int:
	return _unported(0x402c30)

func f402c90() -> int:
	return _unported(0x402c90)

func f402cd0() -> int:
	return _unported(0x402cd0)

func f402d30() -> int:
	return _unported(0x402d30)

func f402ec0() -> int:
	return _unported(0x402ec0)

func f402f20() -> int:
	return _unported(0x402f20)

func f402f70() -> int:
	return _unported(0x402f70)

func f402fa0() -> int:
	return _unported(0x402fa0)

func f403010(_entries: int, _resolving: int) -> int:
	return _unported(0x403010)

func f4030a0() -> int:
	return _unported(0x4030a0)

func f4030b0() -> int:
	return _unported(0x4030b0)

func f4030f0() -> int:
	return _unported(0x4030f0)

func f403150(_p: int) -> int:
	return _unported(0x403150)

func f403180() -> int:
	return _unported(0x403180)

func f4032e0() -> int:
	return _unported(0x4032e0)

func f403390() -> int:
	return _unported(0x403390)

func f403420() -> int:
	return _unported(0x403420)

func f4034c0() -> int:
	return _unported(0x4034c0)

func f4035a0() -> int:
	return _unported(0x4035a0)

func f403680() -> int:
	var previous := step()
	next_step()
	if previous >= cmd_a(): finish()
	return 0

func f4036c0() -> int:
	return _unported(0x4036c0)

func f403760() -> int:
	return _unported(0x403760)

func f403940() -> int:
	present("battle_cursor", {"zone": cmd_a()})
	present("battle_aim")
	finish()
	return 0

func f403960() -> int:
	return _unported(0x403960)

func f4039b0() -> int:
	return _unported(0x4039b0)

func f4039c0() -> int:
	return _unported(0x4039c0)

func f403a60() -> int:
	return _unported(0x403a60)

func f403cb0() -> int:
	return _unported(0x403cb0)

func f403e00() -> int:
	return _unported(0x403e00)

func f403ea0() -> int:
	return _unported(0x403ea0)

func f404070() -> int:
	return _unported(0x404070)

func f4040f0() -> int:
	return _unported(0x4040f0)

func f404270(_gain: int) -> int:
	return _unported(0x404270)

func f404430() -> int:
	return _unported(0x404430)

func f404480() -> int:
	present("tutorial_portrait", {"side": cmd_a(), "visible": true})
	finish()
	return 0

func f4044e0() -> int:
	present("tutorial_portrait", {"visible": false})
	finish()
	return 0

func f404530() -> int:
	present("tutorial_bubble", {"text": cmd_a(), "position": cmd_b(), "manual": cmd_c() == 0})
	finish()
	return 0

func f404660() -> int:
	present("tutorial_bubble_close")
	finish()
	return 0

func f4046b0() -> int:
	present("tutorial_spotlight", {"rectangle": cmd_player() != 0, "a": cmd_a(), "b": cmd_b(), "c": cmd_c()})
	finish()
	return 0

func f4047d0() -> int:
	present("tutorial_spotlight_close")
	finish()
	return 0

func f404820() -> int:
	present("tutorial_cursor_action", {"action": cmd_a(), "p": cmd_player(), "loc": cmd_b() & 15, "i": cmd_c() & 511})
	finish()
	return 0

func f404890() -> int:
	return _unported(0x404890)

func f4049b0() -> int:
	return _unported(0x4049b0)

func f404a10() -> int:
	present("tutorial_background", {"index": cmd_a()})
	finish()
	return 0

func f404a40() -> int:
	return _unported(0x404a40)

func f405190() -> int:
	return _unported(0x405190)

func f405230() -> int:
	return _unported(0x405230)

func f4052b0() -> int:
	return _unported(0x4052b0)

func f4054b0() -> int:
	return _unported(0x4054b0)

func f405750() -> int:
	return _unported(0x405750)

func f405950() -> int:
	return _unported(0x405950)

func f405c10() -> int:
	return _unported(0x405c10)

func f405d10() -> int:
	return _unported(0x405d10)

func f405f90() -> int:
	return _unported(0x405f90)

func f4061c0() -> int:
	return _unported(0x4061c0)

func f4062b0() -> int:
	return _unported(0x4062b0)

func f406450() -> int:
	return _unported(0x406450)

func f406540() -> int:
	return _unported(0x406540)

func f406710() -> int:
	return _unported(0x406710)

func f4067f0() -> int:
	return _unported(0x4067f0)

func f4068c0() -> int:
	return _unported(0x4068c0)

func f406a30() -> int:
	return _unported(0x406a30)

func f406c40() -> int:
	return _unported(0x406c40)

func f406d20() -> int:
	return _unported(0x406d20)

func f406f30() -> int:
	return _unported(0x406f30)

func f406ff0() -> int:
	return _unported(0x406ff0)

func f4070c0() -> int:
	return _unported(0x4070c0)

func f407190() -> int:
	return _unported(0x407190)

func f4073a0(_index: int) -> int:
	return _unported(0x4073a0)

func f4073b0() -> int:
	return _unported(0x4073b0)

func f4073c0() -> int:
	return _unported(0x4073c0)

func f4073e0() -> int:
	return _unported(0x4073e0)

func f4073f0(_i: int) -> int:
	return _unported(0x4073f0)

func f407570(_i: int) -> int:
	return _unported(0x407570)

func f407580(_p: int, _loc: int, _a3: int, _a4: int) -> int:
	return _unported(0x407580)

func f40fe20() -> int:
	return _unported(0x40fe20)

func f413f50(__index: int, __loc_addr: int) -> int:
	return _unported(0x413f50)

func f42e820(_a1: int, _kind: int, _a3: int) -> int:
	return _unported(0x42e820)

func f42fda0(_answer: int) -> int:
	return _unported(0x42fda0)

func f431ee0(_text: int) -> int:
	return _unported(0x431ee0)

func f432050(_text: int, _n: int, _default: int) -> int:
	return _unported(0x432050)

func f437530() -> int:
	return _unported(0x437530)

func f4376e0() -> int:
	return _unported(0x4376e0)

func f4457d0(_index: int) -> int:
	return _unported(0x4457d0)

func f445810(_index: int) -> int:
	return _unported(0x445810)

func f445850(_index: int) -> int:
	return _unported(0x445850)

func f460f80() -> int:
	return _unported(0x460f80)

func f461350() -> int:
	return _unported(0x461350)

func f4613d0() -> int:
	return _unported(0x4613d0)

func f465480(_p: int, _a2: int, _a3: int) -> int:
	return _unported(0x465480)

func f465550(_p: int, _a2: int, _a3: int) -> int:
	return _unported(0x465550)

func f465640(_p: int, _z: int, _v: int) -> int:
	return _unported(0x465640)

func f465720(_p: int, _z: int) -> int:
	return _unported(0x465720)

func f465740(_p: int, _z: int) -> int:
	return _unported(0x465740)

func f465760(_p: int, _z: int, _v: int) -> int:
	return _unported(0x465760)

func f539a60() -> int:
	return _unported(0x539a60)

func f539ac0(_p: int, _zero_attack: int) -> int:
	return _unported(0x539ac0)

func f53a130() -> int:
	return _unported(0x53a130)

func f53a160() -> int:
	return _unported(0x53a160)

func f53a1a0() -> int:
	return _unported(0x53a1a0)

func f53a400() -> int:
	return _unported(0x53a400)

func f53aa20() -> int:
	return _unported(0x53aa20)

func f53aa70(_op: int, _a: int, _b: int, _c: int) -> int:
	return _unported(0x53aa70)

func f53ac40(_op: int, _a: int, _b: int, _c: int) -> int:
	return _unported(0x53ac40)

func f53aca0() -> int:
	return _unported(0x53aca0)

func f53b4e0() -> int:
	return _unported(0x53b4e0)

func f53b650() -> int:
	return _unported(0x53b650)

func f53b6f0() -> int:
	return _unported(0x53b6f0)

func f53b790() -> int:
	return _unported(0x53b790)

func f53b880(_index: int) -> int:
	return _unported(0x53b880)

func f53b8b0() -> int:
	return _unported(0x53b8b0)

func f53b930(_entry: int) -> int:
	return _unported(0x53b930)

func f53b960(_list: int, _code: int, _extra: int) -> int:
	return _unported(0x53b960)

func f53baa0(_code: int, _extra: int) -> int:
	return _unported(0x53baa0)

func f53bac0(_a: int, _b: int) -> int:
	return _unported(0x53bac0)

func f53bae0(_active: int, _src: int) -> int:
	return _unported(0x53bae0)

func f53bb70(_entry: int) -> int:
	return _unported(0x53bb70)

func f53bc40(_effect: int, _p: int, _loc: int, _index: int) -> int:
	return _unported(0x53bc40)

func f53bd50(_effect: int, _p: int) -> int:
	return _unported(0x53bd50)

func f53c2a0() -> int:
	return _unported(0x53c2a0)

func f53ca00() -> int:
	return _unported(0x53ca00)

func f53d550() -> int:
	return _unported(0x53d550)

func f53d650() -> int:
	return _unported(0x53d650)

func f53d660(_p: int) -> int:
	return _unported(0x53d660)

func f53d6c0(_p: int) -> int:
	return _unported(0x53d6c0)

func f53d730(_force: int) -> int:
	return _unported(0x53d730)

func f53d970() -> int:
	return _unported(0x53d970)

func f53d9d0() -> int:
	return _unported(0x53d9d0)

func f53db10(_kind: int) -> int:
	return _unported(0x53db10)

func f53db50(_all_commands: int) -> int:
	return _unported(0x53db50)

func f53dbb0() -> int:
	return _unported(0x53dbb0)

func f53dbf0() -> int:
	return _unported(0x53dbf0)

func f53de40(_p: int, _id: int, _z: int) -> int:
	return _unported(0x53de40)

func f53dee0(_p: int) -> int:
	return _unported(0x53dee0)

func f53e100(__p: int, _card: int) -> int:
	return _unported(0x53e100)

func f53e180(_p: int) -> int:
	return _unported(0x53e180)

func f53e220(__p: int, _excluded: int) -> int:
	return _unported(0x53e220)

func f53e2a0(_p: int, _excluded: int) -> int:
	return _unported(0x53e2a0)

func f53e370() -> int:
	return _unported(0x53e370)

func f53e6c0() -> int:
	return _unported(0x53e6c0)

func f53e760(_p: int, _action: int, _a: int, _b: int) -> int:
	return _unported(0x53e760)

func f53e7c0(_p: int, _action: int, _src: int, _count: int) -> int:
	return _unported(0x53e7c0)

func f53e830(_p: int, _a: int, _flag1: int, _flag2: int) -> int:
	return _unported(0x53e830)

func f53e870(_p: int, _a: int, _flag1: int, _flag2: int) -> int:
	return _unported(0x53e870)

func f53e8b0(_p: int, _a: int, _b: int) -> int:
	return _unported(0x53e8b0)

func f53e8f0(_p: int, _b: int) -> int:
	return _unported(0x53e8f0)

func f53e930(_p: int) -> int:
	return _unported(0x53e930)

func f53e950(_p: int) -> int:
	return _unported(0x53e950)

func f53e970(_p: int) -> int:
	return _unported(0x53e970)

func f53ea40(_a0: int, _a1: int, _a2: int) -> int:
	return _unported(0x53ea40)

func f53ea90() -> int:
	return _unported(0x53ea90)

func f53ed60(_a0: int, _a1: int, _a2: int, _a3: int) -> int:
	return _unported(0x53ed60)

func f53eda0() -> int:
	return _unported(0x53eda0)

func f53f7e0(_p: int, _loc: int, _i: int) -> int:
	return _unported(0x53f7e0)

func f53f860(_index: int) -> int:
	return _unported(0x53f860)

func f53f8b0() -> int:
	return _unported(0x53f8b0)

func f53f980(_dst: int, _size: int) -> int:
	return _unported(0x53f980)

func f53f9a0(_dst: int, _src: int, _size: int) -> int:
	return _unported(0x53f9a0)

func f53fbd0(_x: int) -> int:
	return _unported(0x53fbd0)

func f53fbf0(_a0: int) -> int:
	return _unported(0x53fbf0)

func f53fc10() -> int:
	return _unported(0x53fc10)

func f53fc20() -> int:
	return _unported(0x53fc20)

func f53fc40() -> int:
	return _unported(0x53fc40)

func f53fc90() -> int:
	return _unported(0x53fc90)

func f53fcd0() -> int:
	return _unported(0x53fcd0)

func f53fce0(_value: int) -> int:
	return _unported(0x53fce0)

func f53fcf0() -> int:
	return _unported(0x53fcf0)

func f53fd00() -> int:
	return _unported(0x53fd00)

func f53fd30(_index: int) -> int:
	return _unported(0x53fd30)

func f53fd90(_index: int) -> int:
	return _unported(0x53fd90)

func f540240(_index: int) -> int:
	return _unported(0x540240)

func f540270(_index: int, _count: int) -> int:
	return _unported(0x540270)

func f5402c0(_index: int) -> int:
	return _unported(0x5402c0)

func f540330(_index: int) -> int:
	return _unported(0x540330)

func f5403a0(_index: int) -> int:
	return _unported(0x5403a0)

func f540410() -> int:
	return _unported(0x540410)

func f540430(_game_index: int) -> int:
	return _unported(0x540430)

func f540450(_game_index: int) -> int:
	return _unported(0x540450)

func f5406b0() -> int:
	return _unported(0x5406b0)

func f5406f0(_opponent: int) -> int:
	return _unported(0x5406f0)

func f540720(_opponent: int) -> int:
	return _unported(0x540720)

func f540760(_opponent: int) -> int:
	return _unported(0x540760)

func f5407b0() -> int:
	return _unported(0x5407b0)

func f5407d0() -> int:
	return _unported(0x5407d0)

func f5407e0() -> int:
	return _unported(0x5407e0)

func f5407f0() -> int:
	return _unported(0x5407f0)

func f540a50() -> int:
	return _unported(0x540a50)

func f540a70() -> int:
	return _unported(0x540a70)

func f540b90(_action: int) -> int:
	return _unported(0x540b90)

func f540bb0() -> int:
	return _unported(0x540bb0)

func f540c00(_p: int, _loc: int, _i: int, _p2: int, _loc2: int) -> int:
	return _unported(0x540c00)

func f540d60(_kind: int, _value: int) -> int:
	return _unported(0x540d60)

func f540d80(_answer: int) -> int:
	return _unported(0x540d80)

func f540db0() -> int:
	return _unported(0x540db0)

func f5417e0(_msg: int) -> int:
	return _unported(0x5417e0)

func f541850(_opts: int) -> int:
	return _unported(0x541850)

func f541890() -> int:
	return _unported(0x541890)

func f5418a0(_opts: int, _rand_seed: int) -> int:
	return _unported(0x5418a0)

func f541950(_index: int) -> int:
	return _unported(0x541950)

func f5419b0(_p: int, _loc: int, _i: int) -> int:
	return _unported(0x5419b0)

func f541a90(_p: int, _loc: int, _i: int) -> int:
	return _unported(0x541a90)

func f541b90(_base: int, _p: int, _amount: int) -> int:
	return _unported(0x541b90)

func f541bd0(_addr: int) -> int:
	return _unported(0x541bd0)

func f541be0(_p: int, _z: int) -> int:
	return _unported(0x541be0)

func f541c10(_a: int, _b: int) -> int:
	return _unported(0x541c10)

func f541cb0(_dst: int, _src: int) -> int:
	return _unported(0x541cb0)

func f541cc0(_a: int, _b: int) -> int:
	return _unported(0x541cc0)

func f541ce0(_card_id: int) -> int:
	return _unported(0x541ce0)

func f541d10(_id: int, _mode: int) -> int:
	return _unported(0x541d10)

func f542150(_index: int) -> int:
	return _unported(0x542150)

func f5421c0(_index: int) -> int:
	return _unported(0x5421c0)

func f542280(_index: int) -> int:
	return _unported(0x542280)

func f5422b0(_p: int, _z: int, _entry_addr: int, _a4: int, _a5: int) -> int:
	return _unported(0x5422b0)

func f5423a0(_p: int, _z: int, _entry_addr: int, _a4: int) -> int:
	return _unported(0x5423a0)

func f542520(_p: int, _entry_addr: int) -> int:
	return _unported(0x542520)

func f5425a0(_p: int, _entry_addr: int) -> int:
	return _unported(0x5425a0)

func f5425e0(_p: int, _entry_addr: int) -> int:
	return _unported(0x5425e0)

func f542630(_p: int, _card_id: int, _limit: int) -> int:
	return _unported(0x542630)

func f5426d0(_p: int, _mult: int) -> int:
	return _unported(0x5426d0)

func f542790(_p: int, _i: int, _out_addr: int) -> int:
	return _unported(0x542790)

func f542810(_p: int, _entry_addr: int) -> int:
	return _unported(0x542810)

func f5428a0(_p: int, _card_id: int, _out_addr: int) -> int:
	return _unported(0x5428a0)

func f542960(_p: int) -> int:
	return _unported(0x542960)

func f542990(_p: int, _entry_addr: int) -> int:
	return _unported(0x542990)

func f542a20(_p: int) -> int:
	return _unported(0x542a20)

func f542b50(_p: int) -> int:
	return _unported(0x542b50)

func f542c40(_p: int, _z: int) -> int:
	return _unported(0x542c40)

func f542c70(_p: int, _z: int, _i: int) -> int:
	return _unported(0x542c70)

func f542ce0(_card_id: int) -> int:
	return _unported(0x542ce0)

func f542da0(_p: int, _card_id: int) -> int:
	return _unported(0x542da0)

func f542e00(_p: int, _id: int) -> int:
	return _unported(0x542e00)

func f542e60(_p: int, _card_id: int, _skip: int) -> int:
	return _unported(0x542e60)

func f542f30(_p: int, _card_id: int) -> int:
	return _unported(0x542f30)

func f542f50(_p: int, _card_id: int) -> int:
	return _unported(0x542f50)

func f542fb0(_p: int) -> int:
	return _unported(0x542fb0)

func f543010(_p: int, _card_id: int) -> int:
	return _unported(0x543010)

func f543070(_p: int, _id: int) -> int:
	return _unported(0x543070)

func f5430d0(_p: int, _id: int) -> int:
	return _unported(0x5430d0)

func f543130(_p: int, _card_id: int, _pos: int) -> int:
	return _unported(0x543130)

func f5431b0(_p: int) -> int:
	return _unported(0x5431b0)

func f5431f0(_p: int, _face_up: int, _not_bit0: int) -> int:
	return _unported(0x5431f0)

func f543260(_p: int, _z: int) -> int:
	return _unported(0x543260)

func f543330(_p: int) -> int:
	return _unported(0x543330)

func f543360(_p: int) -> int:
	return _unported(0x543360)

func f543390(_p: int, _z: int) -> int:
	return _unported(0x543390)

func f543400(_p: int, _skip: int) -> int:
	return _unported(0x543400)

func f543480(_p: int, _face_up: int, _face_down: int, _with_field: int) -> int:
	return _unported(0x543480)

func f543520(_p: int, _z: int) -> int:
	return _unported(0x543520)

func f543570(_p: int) -> int:
	return _unported(0x543570)

func f5435a0(_p: int, _index: int) -> int:
	return _unported(0x5435a0)

func f543610(_p: int, _z: int, _banish: int) -> int:
	return _unported(0x543610)

func f543670(_p: int, _z: int) -> int:
	return _unported(0x543670)

func f543740(_p: int, _z: int) -> int:
	return _unported(0x543740)

func f543780(_p: int, _z: int) -> int:
	return _unported(0x543780)

func f5437c0(_p: int, _z: int) -> int:
	return _unported(0x5437c0)

func f543840(_p: int, _z: int) -> int:
	return _unported(0x543840)

func f5438c0(_p: int) -> int:
	return _unported(0x5438c0)

func f543930(_p: int) -> int:
	return _unported(0x543930)

func f5439a0(_base: int, _p: int, _card_id: int) -> int:
	return _unported(0x5439a0)

func f543a30(_p: int, _card_id: int) -> int:
	return _unported(0x543a30)

func f543a50(_p: int, _kind: int) -> int:
	return _unported(0x543a50)

func f543ab0(_p: int, _kind: int) -> int:
	return _unported(0x543ab0)

func f543b40(_p: int) -> int:
	return _unported(0x543b40)

func f543b90(_base: int, _p: int, _id: int) -> int:
	return _unported(0x543b90)

func f543c60(_p: int, _id: int) -> int:
	return _unported(0x543c60)

func f543cd0(_p: int, _id: int) -> int:
	return _unported(0x543cd0)

func f543cf0(_p: int, _z: int) -> int:
	return _unported(0x543cf0)

func f543dd0(_location: int, _reference: int) -> int:
	return _unported(0x543dd0)

func f543e20(_where: int, _link: int, _kind: int) -> int:
	return _unported(0x543e20)

func f543ee0(_where: int, _link: int, _kind: int) -> int:
	return _unported(0x543ee0)

func f543f80(_where: int, _i: int, _link: int, _kind: int) -> int:
	return _unported(0x543f80)

func f543fc0() -> int:
	return _unported(0x543fc0)

func f544000(_p: int, _z: int) -> int:
	return _unported(0x544000)

func f544100(_p: int, _z: int) -> int:
	return _unported(0x544100)

func f544210(_p: int, _z: int) -> int:
	return _unported(0x544210)

func f544280(_p: int, _skip: int) -> int:
	return _unported(0x544280)

func f544300(_entry_addr: int) -> int:
	return _unported(0x544300)

func f5443a0(_entry_addr: int) -> int:
	return _unported(0x5443a0)

func f544450(_entry_addr: int, _zone_i: int) -> int:
	return _unported(0x544450)

func f544520(_p: int, _z: int) -> int:
	return _unported(0x544520)

func f544610(_entry_addr: int) -> int:
	return _unported(0x544610)

func f5446c0(_p: int, _i: int) -> int:
	return _unported(0x5446c0)

func f544740(_p: int, _i: int, _out_addr: int) -> int:
	return _unported(0x544740)

func f5447d0(_p: int, _entry_addr: int) -> int:
	return _unported(0x5447d0)

func f544830(_p: int, _index: int) -> int:
	return _unported(0x544830)

func f544890(_p: int, _index: int) -> int:
	return _unported(0x544890)

func f544950(_p: int, _index: int, _out_addr: int) -> int:
	return _unported(0x544950)

func f5449b0(_p: int, _entry: int) -> int:
	return _unported(0x5449b0)

func f544a00(_p: int, _card_id: int) -> int:
	return _unported(0x544a00)

func f544a80(_p: int, _i: int) -> int:
	return _unported(0x544a80)

func f544b20(_p: int, _entry_addr: int) -> int:
	return _unported(0x544b20)

func f544b70(_p: int) -> int:
	return _unported(0x544b70)

func f544be0(_p: int) -> int:
	return _unported(0x544be0)

func f544c50(_p: int, _entry_addr: int) -> int:
	return _unported(0x544c50)

func f544d10(_p: int, _entry_addr: int) -> int:
	return _unported(0x544d10)

func f544db0(_p: int, _entry_addr: int) -> int:
	return _unported(0x544db0)

func f544e00(_p: int) -> int:
	return _unported(0x544e00)

func f544eb0(_p: int) -> int:
	return _unported(0x544eb0)

func f544f30(_p: int) -> int:
	return _unported(0x544f30)

func f544fb0(_p: int) -> int:
	return _unported(0x544fb0)

func f545060(_p: int, _card_id: int) -> int:
	return _unported(0x545060)

func f5450e0(_p: int) -> int:
	return _unported(0x5450e0)

func f5451a0(_p: int, _z: int) -> int:
	return _unported(0x5451a0)

func f5451f0(_p: int, _z: int) -> int:
	return _unported(0x5451f0)

func f545240(_p: int, _z: int) -> int:
	return _unported(0x545240)

func f545510(_p: int, _z: int, _only_spell: int, _only_equip: int) -> int:
	return _unported(0x545510)

func f545620(_p: int, _z: int, _card_id: int) -> int:
	return _unported(0x545620)

func f545730(_p: int, _z: int, _card_id: int) -> int:
	return _unported(0x545730)

func f545810(_p: int, _z: int, _id: int) -> int:
	return _unported(0x545810)

func f545890(_p: int, _z: int, _id: int) -> int:
	return _unported(0x545890)

func f545930(_p: int, _z: int, _target_p: int, _target_z: int) -> int:
	return _unported(0x545930)

func f545959(_a0: int, _a1: int, _a2: int, _a3: int) -> int:
	return _unported(0x545959)

func f5459b0(_p: int, _id: int) -> int:
	return _unported(0x5459b0)

func f545a10(_p: int, _id: int) -> int:
	return _unported(0x545a10)

func f545a70(_p: int, _z: int) -> int:
	return _unported(0x545a70)

func f545aa6(_a0: int, _a1: int, _a2: int) -> int:
	return _unported(0x545aa6)

func f545c40(_p: int, _z: int) -> int:
	return _unported(0x545c40)

func f545e70(_p: int, _z: int) -> int:
	return _unported(0x545e70)

func f545fb0(_p: int, _z: int, _target_p: int, _target_z: int) -> int:
	return _unported(0x545fb0)

func f546020(_p: int, _z: int) -> int:
	return _unported(0x546020)

func f5460a0(_out: int, _index: int, _atk_addr: int, _def_addr: int) -> int:
	return _unported(0x5460a0)

func f546470(_p: int, _z: int, _out: int) -> int:
	return _unported(0x546470)

func f547ba0(_p: int, _z: int, _target_p: int, _target_z: int) -> int:
	return _unported(0x547ba0)

func f547c60(_p: int, _z: int) -> int:
	return _unported(0x547c60)

func f547c80(_p: int, _z: int) -> int:
	return _unported(0x547c80)

func f547ca0() -> int:
	return _unported(0x547ca0)

func f547d40() -> int:
	return _unported(0x547d40)

func f547d70() -> int:
	return _unported(0x547d70)

func f547dd0() -> int:
	return _unported(0x547dd0)

func f547e50() -> int:
	return _unported(0x547e50)

func f547ec0() -> int:
	return _unported(0x547ec0)

func f547f30() -> int:
	return _unported(0x547f30)

func f547f50() -> int:
	return _unported(0x547f50)

func f547fc0() -> int:
	return _unported(0x547fc0)

func f548000() -> int:
	return _unported(0x548000)

func f548060() -> int:
	return _unported(0x548060)

func f548140() -> int:
	return _unported(0x548140)

func f548280() -> int:
	return _unported(0x548280)

func f5484b0() -> int:
	return _unported(0x5484b0)

func f548690(_old: int, _new: int) -> int:
	return _unported(0x548690)

func f548730() -> int:
	return _unported(0x548730)

func f548910() -> int:
	return _unported(0x548910)

func f548b70() -> int:
	return _unported(0x548b70)

func f548bb0() -> int:
	return _unported(0x548bb0)

func f548c00() -> int:
	return _unported(0x548c00)

func f548c40() -> int:
	return _unported(0x548c40)

func f548c90() -> int:
	return _unported(0x548c90)

func f548ce0() -> int:
	return _unported(0x548ce0)

func f548d40() -> int:
	return _unported(0x548d40)

func f548db0() -> int:
	return _unported(0x548db0)

func f548df0() -> int:
	return _unported(0x548df0)

func f548e80() -> int:
	return _unported(0x548e80)

func f548fd0() -> int:
	return _unported(0x548fd0)

func f5490e0() -> int:
	return _unported(0x5490e0)

func f549220() -> int:
	return _unported(0x549220)

func f549370() -> int:
	return _unported(0x549370)

func f5493e0() -> int:
	return _unported(0x5493e0)

func f549550() -> int:
	return _unported(0x549550)

func f549660() -> int:
	return _unported(0x549660)

func f549780() -> int:
	return _unported(0x549780)

func f549890() -> int:
	return _unported(0x549890)

func f549900() -> int:
	return _unported(0x549900)

func f549960() -> int:
	return _unported(0x549960)

func f5499a0() -> int:
	return _unported(0x5499a0)

func f549a00() -> int:
	return _unported(0x549a00)

func f549bc0() -> int:
	return _unported(0x549bc0)

func f549ca0() -> int:
	return _unported(0x549ca0)

func f549d80() -> int:
	return _unported(0x549d80)

func f549ea0() -> int:
	return _unported(0x549ea0)

func f549f00() -> int:
	return _unported(0x549f00)

func f54a070() -> int:
	return _unported(0x54a070)

func f54a1c0() -> int:
	return _unported(0x54a1c0)

func f54a2c0() -> int:
	return _unported(0x54a2c0)

func f54a310() -> int:
	return _unported(0x54a310)

func f54a350() -> int:
	return _unported(0x54a350)

func f54a4a0() -> int:
	return _unported(0x54a4a0)

func f54a4e0() -> int:
	return _unported(0x54a4e0)

func f54a590() -> int:
	return _unported(0x54a590)

func f54a6c0() -> int:
	return _unported(0x54a6c0)

func f54a810() -> int:
	return _unported(0x54a810)

func f54a960() -> int:
	return _unported(0x54a960)

func f54a9c0() -> int:
	return _unported(0x54a9c0)

func f54a9f0() -> int:
	return _unported(0x54a9f0)

func f54aa50() -> int:
	return _unported(0x54aa50)

func f54ab60() -> int:
	return _unported(0x54ab60)

func f54ac50() -> int:
	return _unported(0x54ac50)

func f54af20() -> int:
	return _unported(0x54af20)

func f54af30() -> int:
	return _unported(0x54af30)

func f54af40() -> int:
	return _unported(0x54af40)

func f54afa0() -> int:
	return _unported(0x54afa0)

func f54b050() -> int:
	return _unported(0x54b050)

func f54b0f0() -> int:
	return _unported(0x54b0f0)

func f54b140() -> int:
	return _unported(0x54b140)

func f54b270() -> int:
	return _unported(0x54b270)

func f54b2b0() -> int:
	return _unported(0x54b2b0)

func f54b300() -> int:
	return _unported(0x54b300)

func f54b350() -> int:
	return _unported(0x54b350)

func f54b3a0() -> int:
	return _unported(0x54b3a0)

func f54b3e0() -> int:
	return _unported(0x54b3e0)

func f54b460() -> int:
	return _unported(0x54b460)

func f54b500() -> int:
	return _unported(0x54b500)

func f54b610() -> int:
	return _unported(0x54b610)

func f54b710() -> int:
	return _unported(0x54b710)

func f54b7c0() -> int:
	return _unported(0x54b7c0)

func f54b8c0() -> int:
	return _unported(0x54b8c0)

func f54b910(_p: int, _amount: int) -> int:
	return _unported(0x54b910)

func f54b950() -> int:
	return _unported(0x54b950)

func f54bab0() -> int:
	return _unported(0x54bab0)

func f54bdb0() -> int:
	return _unported(0x54bdb0)

func f54c2a0() -> int:
	return _unported(0x54c2a0)

func f54c2d0() -> int:
	return _unported(0x54c2d0)

func f54c300() -> int:
	return _unported(0x54c300)

func f54c330() -> int:
	return _unported(0x54c330)

func f54c370() -> int:
	return _unported(0x54c370)

func f54c3b0() -> int:
	return _unported(0x54c3b0)

func f54c400() -> int:
	return _unported(0x54c400)

func f54c440() -> int:
	return _unported(0x54c440)

func f54c460() -> int:
	return _unported(0x54c460)

func f54c490() -> int:
	return _unported(0x54c490)

func f54c530() -> int:
	return _unported(0x54c530)

func f54c570() -> int:
	return _unported(0x54c570)

func f54c6a0() -> int:
	return _unported(0x54c6a0)

func f54c6e0(_p: int, _z: int, _temporary: int) -> int:
	return _unported(0x54c6e0)

func f54c860(_p: int, _a: int, _b: int, _c: int) -> int:
	return _unported(0x54c860)

func f54c880(_p: int, _a: int, _b: int, _c: int) -> int:
	return _unported(0x54c880)

func f54c8a0(_p1: int, _z: int, _pl: int, _zz: int) -> int:
	return _unported(0x54c8a0)

func f54c930(_p: int, _z: int) -> int:
	return _unported(0x54c930)

func f54ca50(_p: int, _z: int, _flag: int) -> int:
	return _unported(0x54ca50)

func f54cbb0(_p: int, _card_id: int) -> int:
	return _unported(0x54cbb0)

func f54cc10(_source: int, _p: int, _both: int, _include_spells: int, _eligible_only: int) -> int:
	return _unported(0x54cc10)

func f54cec0(_p: int, _z: int, _entry: int) -> int:
	return _unported(0x54cec0)

func f54cf50(_source_p: int, _p: int, _z: int, _entry: int) -> int:
	return _unported(0x54cf50)

func f54d2d0(_p: int, _z: int, _trigger_effect: int, _visual_effect: int) -> int:
	return _unported(0x54d2d0)

func f54d420(_p: int, _z: int, _position: int, _flip_effect: int, _mode: int) -> int:
	return _unported(0x54d420)

func f54d570(__source: int, _origin: int, _target: int) -> int:
	return _unported(0x54d570)

func f54d6c0(_source: int, _origin: int, _target: int) -> int:
	return _unported(0x54d6c0)

func f54d900(_p: int, _a: int, _b: int) -> int:
	return _unported(0x54d900)

func f54d930(_p: int, _hand: int, _entry: int, _trigger: int, _a: int, _b: int) -> int:
	return _unported(0x54d930)

func f54da50(_p: int, _id: int) -> int:
	return _unported(0x54da50)

func f54daf0(_p: int, _id: int, _out: int) -> int:
	return _unported(0x54daf0)

func f54dba0(_p: int, _entry: int) -> int:
	return _unported(0x54dba0)

func f54dbd0(_p: int, _id: int, _out: int) -> int:
	return _unported(0x54dbd0)

func f54dc60(_p: int, _id: int) -> int:
	return _unported(0x54dc60)

func f54dcf0(_p: int, _z: int) -> int:
	return _unported(0x54dcf0)

func f54de00(_p: int, _z: int, _a3: int, _a4: int) -> int:
	return _unported(0x54de00)

func f54e250(_p: int, _z: int, _a3: int) -> int:
	return _unported(0x54e250)

func f54e340(_p: int, _z: int, _mode: int) -> int:
	return _unported(0x54e340)

func f54e420(_p: int, _z: int, _argument: int) -> int:
	return _unported(0x54e420)

func f54e510(_p: int, _z: int) -> int:
	return _unported(0x54e510)

func f54e5d0(_p: int, _shuffle: int) -> int:
	return _unported(0x54e5d0)

func f54e640(_p: int, _z: int, _effect: int) -> int:
	return _unported(0x54e640)

func f54e660(_p: int, _z: int, _position: int, _flip_effect: int) -> int:
	return _unported(0x54e660)

func f54e680(_p: int, _hand: int, _trigger: int, _argument: int) -> int:
	return _unported(0x54e680)

func f54e6b0(_p: int, _z: int) -> int:
	return _unported(0x54e6b0)

func f54e730(_p: int, _origin: int, _target: int) -> int:
	return _unported(0x54e730)

func f54e850(_origin: int, _target: int) -> int:
	return _unported(0x54e850)

func f54e8a0(_p: int, _z: int) -> int:
	return _unported(0x54e8a0)

func f54e9e0(_p: int, _z: int) -> int:
	return _unported(0x54e9e0)

func f54ea40(_p: int, _z: int) -> int:
	return _unported(0x54ea40)

func f54ec80(_p: int, _z: int) -> int:
	return _unported(0x54ec80)

func f54eea0(_p: int, _index: int) -> int:
	return _unported(0x54eea0)

func f54eed0(_p: int, _index: int, _b: int) -> int:
	return _unported(0x54eed0)

func f54ef00(_p: int, _index: int) -> int:
	return _unported(0x54ef00)

func f54ef30(_p: int, _index: int) -> int:
	return _unported(0x54ef30)

func f54ef60(_p: int, _index: int) -> int:
	return _unported(0x54ef60)

func f54ef90(_p: int, _amount: int) -> int:
	return _unported(0x54ef90)

func f54efe0(_p: int, _amount: int, _origin: int, _target: int) -> int:
	return _unported(0x54efe0)

func f54f0d0(_p: int, _amount: int) -> int:
	return _unported(0x54f0d0)

func f54f140(_p: int, _count: int, _discard_spells: int) -> int:
	return _unported(0x54f140)

func f54f470(_p: int, _count: int) -> int:
	return _unported(0x54f470)

func f54f490(_p: int, _count: int) -> int:
	return _unported(0x54f490)

func f54f4c0(_p: int, _count: int, _trigger: int) -> int:
	return _unported(0x54f4c0)

func f54f5f0(_p: int, _id: int, _trigger: int) -> int:
	return _unported(0x54f5f0)

func f54f750(_p: int, _id: int) -> int:
	return _unported(0x54f750)

func f54f7d0(_p: int, _id: int, _argument: int) -> int:
	return _unported(0x54f7d0)

func f54f880(_p: int, _id: int) -> int:
	return _unported(0x54f880)

func f54f910(_source_index: int, _p: int, _z: int) -> int:
	return _unported(0x54f910)

func f54f9f0(_p: int, _z: int) -> int:
	return _unported(0x54f9f0)

func f54fa60(_effect: int, _location: int) -> int:
	return _unported(0x54fa60)

func f54fbb0(__effect: int, _location: int) -> int:
	return _unported(0x54fbb0)

func f54fc20(_effect: int, _location: int) -> int:
	return _unported(0x54fc20)

func f54fc80(_effect: int, _location: int) -> int:
	return _unported(0x54fc80)

func f550390(_effect: int, _location: int) -> int:
	return _unported(0x550390)

func f550400(_effect: int, _location: int) -> int:
	return _unported(0x550400)

func f550490(_effect: int, _location: int) -> int:
	return _unported(0x550490)

func f550530(_effect: int, _location: int) -> int:
	return _unported(0x550530)

func f5505b0(_effect: int, _location: int) -> int:
	return _unported(0x5505b0)

func f550610(_effect: int, _location: int) -> int:
	return _unported(0x550610)

func f550660(_effect: int, _location: int) -> int:
	return _unported(0x550660)

func f550830(__effect: int, _location: int) -> int:
	return _unported(0x550830)

func f550880(_effect: int, _location: int) -> int:
	return _unported(0x550880)

func f5508e0(_effect: int, _location: int) -> int:
	return _unported(0x5508e0)

func f550970(_effect: int, _location: int) -> int:
	return _unported(0x550970)

func f5509f0(_effect: int, _location: int) -> int:
	return _unported(0x5509f0)

func f550a40(__effect: int, _location: int) -> int:
	return _unported(0x550a40)

func f550aa0(_effect: int, _location: int) -> int:
	return _unported(0x550aa0)

func f550b10(__effect: int, _location: int) -> int:
	return _unported(0x550b10)

func f550c30(_effect: int, _location: int) -> int:
	return _unported(0x550c30)

func f550c80(_effect: int, _location: int) -> int:
	return _unported(0x550c80)

func f550ce0(__effect: int, _location: int) -> int:
	return _unported(0x550ce0)

func f550d20(_effect: int, _location: int) -> int:
	return _unported(0x550d20)

func f550d90(_effect: int, _location: int) -> int:
	return _unported(0x550d90)

func f550e00(_effect: int, _location: int) -> int:
	return _unported(0x550e00)

func f550ea0(_effect: int, _location: int) -> int:
	return _unported(0x550ea0)

func f550f50(_effect: int, _location: int) -> int:
	return _unported(0x550f50)

func f550fe0(_effect: int, _location: int) -> int:
	return _unported(0x550fe0)

func f551050(__effect: int, _loc: int) -> int:
	return _unported(0x551050)

func f5510b0(_effect: int, _loc: int) -> int:
	return _unported(0x5510b0)

func f551100(__effect: int, _loc: int) -> int:
	return _unported(0x551100)

func f551150(__effect: int, _loc: int) -> int:
	return _unported(0x551150)

func f5511a0(_effect: int, _loc: int) -> int:
	return _unported(0x5511a0)

func f551230(_p: int, _idx: int) -> int:
	return _unported(0x551230)

func f551390(_effect: int) -> int:
	return _unported(0x551390)

func f5513d0(_effect: int) -> int:
	return _unported(0x5513d0)

func f551400(_effect: int) -> int:
	return _unported(0x551400)

func f551450(_e: int) -> int:
	return _unported(0x551450)

func f5515a0(_effect: int) -> int:
	return _unported(0x5515a0)

func f551670(_e: int) -> int:
	return _unported(0x551670)

func f551740() -> int:
	return _unported(0x551740)

func f551840() -> int:
	return _unported(0x551840)

func f5518e0(_e: int) -> int:
	return _unported(0x5518e0)

func f551910(_e: int) -> int:
	return _unported(0x551910)

func f551950(_e: int) -> int:
	return _unported(0x551950)

func f551990(_index: int) -> int:
	return _unported(0x551990)

func f551a40(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x551a40)

func f551c40(_p: int, _idx: int, _location: int) -> int:
	return _unported(0x551c40)

func f551cb0(_p: int, _z: int, _reason: int) -> int:
	return _unported(0x551cb0)

func f551d40(_p: int, _z: int) -> int:
	return _unported(0x551d40)

func f551dc0(_other: int, _p: int, _z: int) -> int:
	return _unported(0x551dc0)

func f551f50(_other: int, _p: int, _i: int) -> int:
	return _unported(0x551f50)

func f552090(_other: int, _p: int) -> int:
	return _unported(0x552090)

func f5521a0(_p: int, _count: int) -> int:
	return _unported(0x5521a0)

func f552260(_e: int, __unused: int, _from_hand: int) -> int:
	return _unported(0x552260)

func f5522d0(_e: int, __unused: int, _from_hand: int) -> int:
	return _unported(0x5522d0)

func f552310(_e: int) -> int:
	return _unported(0x552310)

func f552390() -> int:
	return _unported(0x552390)

func f5523d0(_e: int) -> int:
	return _unported(0x5523d0)

func f552410(_e: int) -> int:
	return _unported(0x552410)

func f552460(_e: int) -> int:
	return _unported(0x552460)

func f5524b0(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x5524b0)

func f552560(_e: int) -> int:
	return _unported(0x552560)

func f552600(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x552600)

func f552610(_e: int, __unused: int, _from_hand: int) -> int:
	return _unported(0x552610)

func f552650() -> int:
	return _unported(0x552650)

func f552680(_e: int, __unused: int, _from_hand: int) -> int:
	return _unported(0x552680)

func f552700(_e: int) -> int:
	return _unported(0x552700)

func f55272f(_e: int) -> int:
	return _unported(0x55272f)

func f5527d0(_e: int) -> int:
	return _unported(0x5527d0)

func f552800(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x552800)

func f5529b0(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x5529b0)

func f552a20(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x552a20)

func f552ab0(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x552ab0)

func f552b60(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x552b60)

func f552b90(_e: int) -> int:
	return _unported(0x552b90)

func f552bb0(_e: int) -> int:
	return _unported(0x552bb0)

func f552cc0(_e: int) -> int:
	return _unported(0x552cc0)

func f552d30(_e: int) -> int:
	return _unported(0x552d30)

func f552e00(_e: int) -> int:
	return _unported(0x552e00)

func f552eb0(_e: int) -> int:
	return _unported(0x552eb0)

func f552f00(_e: int) -> int:
	return _unported(0x552f00)

func f552f90(_e: int) -> int:
	return _unported(0x552f90)

func f552ff0(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x552ff0)

func f5530f0(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x5530f0)

func f553280(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x553280)

func f5532b0(_e: int) -> int:
	return _unported(0x5532b0)

func f553300(_e: int) -> int:
	return _unported(0x553300)

func f553390(_e: int) -> int:
	return _unported(0x553390)

func f5533d0(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x5533d0)

func f553490(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x553490)

func f553520(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x553520)

func f5535a0(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x5535a0)

func f553630(_e: int) -> int:
	return _unported(0x553630)

func f553660(_e: int) -> int:
	return _unported(0x553660)

func f5536a0(_e: int) -> int:
	return _unported(0x5536a0)

func f553710(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x553710)

func f5538e0(_e: int) -> int:
	return _unported(0x5538e0)

func f553920(_e: int) -> int:
	return _unported(0x553920)

func f553970(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x553970)

func f5539d0(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x5539d0)

func f553a00(_e: int) -> int:
	return _unported(0x553a00)

func f553a60(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x553a60)

func f553ac0(_e: int) -> int:
	return _unported(0x553ac0)

func f553ae0(_e: int) -> int:
	return _unported(0x553ae0)

func f553b80(_e: int) -> int:
	return _unported(0x553b80)

func f553be0(_e: int) -> int:
	return _unported(0x553be0)

func f553c30(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x553c30)

func f553f80(_e: int) -> int:
	return _unported(0x553f80)

func f554010() -> int:
	return _unported(0x554010)

func f554070(_e: int) -> int:
	return _unported(0x554070)

func f5540d0(_e: int) -> int:
	return _unported(0x5540d0)

func f554100(_e: int) -> int:
	return _unported(0x554100)

func f554130() -> int:
	return _unported(0x554130)

func f554160(_e: int) -> int:
	return _unported(0x554160)

func f5541c0(_e: int) -> int:
	return _unported(0x5541c0)

func f5541f0(_e: int) -> int:
	return _unported(0x5541f0)

func f554220(_e: int, __unused: int, _cost: int) -> int:
	return _unported(0x554220)

func f554270(_e: int) -> int:
	return _unported(0x554270)

func f5542f0(_e: int) -> int:
	return _unported(0x5542f0)

func f554370(_e: int) -> int:
	return _unported(0x554370)

func f5543c0(_e: int) -> int:
	return _unported(0x5543c0)

func f5545b0(_e: int) -> int:
	return _unported(0x5545b0)

func f554600(_e: int) -> int:
	return _unported(0x554600)

func f554640() -> int:
	return _unported(0x554640)

func f554650(_e: int) -> int:
	return _unported(0x554650)

func f554680(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x554680)

func f5546e0(_e: int) -> int:
	return _unported(0x5546e0)

func f554720(_e: int) -> int:
	return _unported(0x554720)

func f5547b0(_a0: int) -> int:
	return _unported(0x5547b0)

func f554910(_a0: int) -> int:
	return _unported(0x554910)

func f554b30(_id: int, _other: int, _p: int, _z: int) -> int:
	return _unported(0x554b30)

func f554bc0(_id: int, _p: int, _other: int) -> int:
	return _unported(0x554bc0)

func f554c60(_e: int, _other: int) -> int:
	return _unported(0x554c60)

func f554cf0() -> int:
	return _unported(0x554cf0)

func f554d10(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x554d10)

func f554d60(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x554d60)

func f554e00(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x554e00)

func f554e45(_player_offset: int, _entry: int, _zone_offset: int) -> int:
	return _unported(0x554e45)

func f554e70(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x554e70)

func f554f50(_e: int) -> int:
	return _unported(0x554f50)

func f554f90() -> int:
	return _unported(0x554f90)

func f554fa0(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x554fa0)

func f554fe0(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x554fe0)

func f555060(_e: int) -> int:
	return _unported(0x555060)

func f5550b0(_e: int) -> int:
	return _unported(0x5550b0)

func f5550e0(_e: int) -> int:
	return _unported(0x5550e0)

func f555130(_e: int) -> int:
	return _unported(0x555130)

func f555160(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x555160)

func f5551a0() -> int:
	return _unported(0x5551a0)

func f5551d0(__e: int, _other: int, _hand: int) -> int:
	return _unported(0x5551d0)

func f555240(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x555240)

func f555380(_e: int) -> int:
	return _unported(0x555380)

func f5553d0(_e: int, _other: int, _hand: int) -> int:
	return _unported(0x5553d0)

func f5553e3(_e: int) -> int:
	return _unported(0x5553e3)

func f5554c0(_e: int, __unused: int, _hand: int) -> int:
	return _unported(0x5554c0)

func f555520(_e: int) -> int:
	return _unported(0x555520)

func f555570(_p: int, _z: int) -> int:
	return _unported(0x555570)

func f555620(_e: int) -> int:
	return _unported(0x555620)

func f555730(_e: int) -> int:
	return _unported(0x555730)

func f555980(_e: int) -> int:
	return _unported(0x555980)

func f555a80(_e: int) -> int:
	return _unported(0x555a80)

func f555b70(_e: int) -> int:
	return _unported(0x555b70)

func f555c20(_e: int) -> int:
	return _unported(0x555c20)

func f555d00(_e: int) -> int:
	return _unported(0x555d00)

func f555d30(_e: int) -> int:
	return _unported(0x555d30)

func f555db0(_e: int) -> int:
	return _unported(0x555db0)

func f555e20(_e: int) -> int:
	return _unported(0x555e20)

func f555e60(_e: int) -> int:
	return _unported(0x555e60)

func f555ee0(_e: int) -> int:
	return _unported(0x555ee0)

func f555f40(_e: int) -> int:
	return _unported(0x555f40)

func f556070(_e: int, __unused: int) -> int:
	return _unported(0x556070)

func f5561d0(_a: int) -> int:
	return _unported(0x5561d0)

func f556210(_a: int, __b: int) -> int:
	return _unported(0x556210)

func f556330(_a: int, __b: int) -> int:
	return _unported(0x556330)

func f556380(_a: int) -> int:
	return _unported(0x556380)

func f556680(_a: int) -> int:
	return _unported(0x556680)

func f556770(_a: int) -> int:
	return _unported(0x556770)

func f556820(_a: int) -> int:
	return _unported(0x556820)

func f556910(_a: int) -> int:
	return _unported(0x556910)

func f556950(_a: int) -> int:
	return _unported(0x556950)

func f556990(_a: int) -> int:
	return _unported(0x556990)

func f556a30(_a: int) -> int:
	return _unported(0x556a30)

func f556ad0(_a: int) -> int:
	return _unported(0x556ad0)

func f556c30(_a: int) -> int:
	return _unported(0x556c30)

func f556c4c(_a: int) -> int:
	return _unported(0x556c4c)

func f556cd0(_a: int) -> int:
	return _unported(0x556cd0)

func f556d40(_a: int) -> int:
	return _unported(0x556d40)

func f556db0(_a: int) -> int:
	return _unported(0x556db0)

func f556df0(_a: int) -> int:
	return _unported(0x556df0)

func f556eb0(_a: int) -> int:
	return _unported(0x556eb0)

func f557070(_a: int) -> int:
	return _unported(0x557070)

func f5572c0(_a: int) -> int:
	return _unported(0x5572c0)

func f557330(_a: int) -> int:
	return _unported(0x557330)

func f557350(_a: int) -> int:
	return _unported(0x557350)

func f557440(_a: int) -> int:
	return _unported(0x557440)

func f557480(_a: int) -> int:
	return _unported(0x557480)

func f557550(_a: int) -> int:
	return _unported(0x557550)

func f557600(_a: int) -> int:
	return _unported(0x557600)

func f557660(_a: int, _b: int) -> int:
	return _unported(0x557660)

func f5577b0(_a: int) -> int:
	return _unported(0x5577b0)

func f5577e0(_a: int) -> int:
	return _unported(0x5577e0)

func f557830(_a: int) -> int:
	return _unported(0x557830)

func f5578c0(_a: int) -> int:
	return _unported(0x5578c0)

func f5578f0(_a: int) -> int:
	return _unported(0x5578f0)

func f5579e0(_a: int) -> int:
	return _unported(0x5579e0)

func f557ab0(_a: int) -> int:
	return _unported(0x557ab0)

func f557b30(_a: int) -> int:
	return _unported(0x557b30)

func f557c10(_a: int) -> int:
	return _unported(0x557c10)

func f557c80(_a: int) -> int:
	return _unported(0x557c80)

func f557d10(_a: int) -> int:
	return _unported(0x557d10)

func f557e80(_a: int) -> int:
	return _unported(0x557e80)

func f557f60(_a: int) -> int:
	return _unported(0x557f60)

func f557ff0(_a: int) -> int:
	return _unported(0x557ff0)

func f558270(_a: int) -> int:
	return _unported(0x558270)

func f558310(_a: int) -> int:
	return _unported(0x558310)

func f558470(_a: int) -> int:
	return _unported(0x558470)

func f5584a0(_a: int, _b: int) -> int:
	return _unported(0x5584a0)

func f558750(_a: int) -> int:
	return _unported(0x558750)

func f5587f0(_a: int) -> int:
	return _unported(0x5587f0)

func f5589a0(_a: int) -> int:
	return _unported(0x5589a0)

func f558ac0(_a: int) -> int:
	return _unported(0x558ac0)

func f558d50(_a: int) -> int:
	return _unported(0x558d50)

func f558dc0(_a: int) -> int:
	return _unported(0x558dc0)

func f558f10(_a: int) -> int:
	return _unported(0x558f10)

func f559010(_a: int) -> int:
	return _unported(0x559010)

func f5593f0(_a: int) -> int:
	return _unported(0x5593f0)

func f5595f0(_a: int) -> int:
	return _unported(0x5595f0)

func f559640(_a: int) -> int:
	return _unported(0x559640)

func f559670(_a: int) -> int:
	return _unported(0x559670)

func f5596c0(_a: int) -> int:
	return _unported(0x5596c0)

func f5599a0(_a: int) -> int:
	return _unported(0x5599a0)

func f5599e0(_a: int) -> int:
	return _unported(0x5599e0)

func f559a70(_a: int) -> int:
	return _unported(0x559a70)

func f559be0(_a: int) -> int:
	return _unported(0x559be0)

func f559c20(_a: int, _b: int) -> int:
	return _unported(0x559c20)

func f559cf0(_a: int) -> int:
	return _unported(0x559cf0)

func f559f00(_a: int) -> int:
	return _unported(0x559f00)

func f55a000(_a: int) -> int:
	return _unported(0x55a000)

func f55a080(_a: int) -> int:
	return _unported(0x55a080)

func f55a120(_a: int) -> int:
	return _unported(0x55a120)

func f55a230(_a: int) -> int:
	return _unported(0x55a230)

func f55a2a0(_a: int) -> int:
	return _unported(0x55a2a0)

func f55a420(_a: int) -> int:
	return _unported(0x55a420)

func f55a4e0(_a: int) -> int:
	return _unported(0x55a4e0)

func f55a550(_a: int, _b: int) -> int:
	return _unported(0x55a550)

func f55aa20(_a: int) -> int:
	return _unported(0x55aa20)

func f55aa80(_a: int, _b: int) -> int:
	return _unported(0x55aa80)

func f55ae30(_a: int, _b: int) -> int:
	return _unported(0x55ae30)

func f55afa0(_a: int) -> int:
	return _unported(0x55afa0)

func f55b030(_a: int) -> int:
	return _unported(0x55b030)

func f55b150(_a: int, _b: int) -> int:
	return _unported(0x55b150)

func f55b290(_a: int) -> int:
	return _unported(0x55b290)

func f55b320(_a: int) -> int:
	return _unported(0x55b320)

func f55b370(_a: int) -> int:
	return _unported(0x55b370)

func f55b400(_a: int) -> int:
	return _unported(0x55b400)

func f55b450(_a: int) -> int:
	return _unported(0x55b450)

func f55b5f0(_a: int) -> int:
	return _unported(0x55b5f0)

func f55b610(_a: int, _b: int) -> int:
	return _unported(0x55b610)

func f55b710(_a: int) -> int:
	return _unported(0x55b710)

func f55b740(_a: int) -> int:
	return _unported(0x55b740)

func f55bac0(_a: int) -> int:
	return _unported(0x55bac0)

func f55bb10(_a: int) -> int:
	return _unported(0x55bb10)

func f55bbf0(_a: int) -> int:
	return _unported(0x55bbf0)

func f55bcb0(_e: int) -> int:
	return _unported(0x55bcb0)

func f55bd00(_e: int) -> int:
	return _unported(0x55bd00)

func f55be00(_e: int) -> int:
	return _unported(0x55be00)

func f55bf00(_e: int) -> int:
	return _unported(0x55bf00)

func f55bf70(_e: int) -> int:
	return _unported(0x55bf70)

func f55bfe0(_e: int) -> int:
	return _unported(0x55bfe0)

func f55c030(_e: int, _out: int) -> int:
	return _unported(0x55c030)

func f55c080(_e: int) -> int:
	return _unported(0x55c080)

func f55c180(_e: int) -> int:
	return _unported(0x55c180)

func f55c220(_e: int) -> int:
	return _unported(0x55c220)

func f55c2a0(_e: int, _argument: int) -> int:
	return _unported(0x55c2a0)

func f55c4a0(_e: int) -> int:
	return _unported(0x55c4a0)

func f55c4e0(_e: int) -> int:
	return _unported(0x55c4e0)

func f55c560(_e: int) -> int:
	return _unported(0x55c560)

func f55c610(_e: int) -> int:
	return _unported(0x55c610)

func f55c800(_e: int) -> int:
	return _unported(0x55c800)

func f55ca80(_e: int) -> int:
	return _unported(0x55ca80)

func f55cab0(_e: int) -> int:
	return _unported(0x55cab0)

func f55cb70(_e: int) -> int:
	return _unported(0x55cb70)

func f55cfe0(_e: int) -> int:
	return _unported(0x55cfe0)

func f55d1b0(_e: int) -> int:
	return _unported(0x55d1b0)

func f55d3b0(_e: int) -> int:
	return _unported(0x55d3b0)

func f55d3e0(_e: int) -> int:
	return _unported(0x55d3e0)

func f55d7a0(_e: int) -> int:
	return _unported(0x55d7a0)

func f55d9f0(_e: int) -> int:
	return _unported(0x55d9f0)

func f55dae0(_e: int) -> int:
	return _unported(0x55dae0)

func f55db90(_e: int) -> int:
	return _unported(0x55db90)

func f55dc20(_e: int) -> int:
	return _unported(0x55dc20)

func f55dd80(_e: int) -> int:
	return _unported(0x55dd80)

func f55deb0(_e: int) -> int:
	return _unported(0x55deb0)

func f55df90(_e: int) -> int:
	return _unported(0x55df90)

func f55e1f0(_e: int) -> int:
	return _unported(0x55e1f0)

func f55e370(_e: int) -> int:
	return _unported(0x55e370)

func f55e3b0(_e: int) -> int:
	return _unported(0x55e3b0)

func f55e740(_e: int) -> int:
	return _unported(0x55e740)

func f55e810(_e: int) -> int:
	return _unported(0x55e810)

func f55e840(_e: int) -> int:
	return _unported(0x55e840)

func f55e910(_e: int) -> int:
	return _unported(0x55e910)

func f55ea40(_e: int) -> int:
	return _unported(0x55ea40)

func f55eb40(_e: int) -> int:
	return _unported(0x55eb40)

func f55ebf0(_e: int) -> int:
	return _unported(0x55ebf0)

func f55f250(_e: int) -> int:
	return _unported(0x55f250)

func f55f350(_e: int) -> int:
	return _unported(0x55f350)

func f55f440(_e: int) -> int:
	return _unported(0x55f440)

func f55f520(_e: int) -> int:
	return _unported(0x55f520)

func f55f600(_e: int, _argument: int) -> int:
	return _unported(0x55f600)

func f55fec0(_e: int) -> int:
	return _unported(0x55fec0)

func f560000(_e: int) -> int:
	return _unported(0x560000)

func f560060(_e: int) -> int:
	return _unported(0x560060)

func f560150(_e: int) -> int:
	return _unported(0x560150)

func f5603e0(_e: int) -> int:
	return _unported(0x5603e0)

func f560480(_e: int) -> int:
	return _unported(0x560480)

func f560540(_e: int, _copied: int) -> int:
	return _unported(0x560540)

func f560690(_e: int) -> int:
	return _unported(0x560690)

func f5607a0(_e: int) -> int:
	return _unported(0x5607a0)

func f560880(_e: int) -> int:
	return _unported(0x560880)

func f560920(_e: int) -> int:
	return _unported(0x560920)

func f560b70(_e: int) -> int:
	return _unported(0x560b70)

func f560bc0(_e: int) -> int:
	return _unported(0x560bc0)

func f560cc0(_e: int) -> int:
	return _unported(0x560cc0)

func f560d00(_e: int) -> int:
	return _unported(0x560d00)

func f560d60(_e: int) -> int:
	return _unported(0x560d60)

func f560e00(_e: int) -> int:
	return _unported(0x560e00)

func f560ef0(_e: int, _out: int) -> int:
	return _unported(0x560ef0)

func f560f70(_e: int) -> int:
	return _unported(0x560f70)

func f561090(_e: int) -> int:
	return _unported(0x561090)

func f5610f0(_e: int) -> int:
	return _unported(0x5610f0)

func f561170(_e: int, _entry: int) -> int:
	return _unported(0x561170)

func f561230(_e: int) -> int:
	return _unported(0x561230)

func f561260(_e: int) -> int:
	return _unported(0x561260)

func f5612e0(_e: int) -> int:
	return _unported(0x5612e0)

func f5613d0(_e: int) -> int:
	return _unported(0x5613d0)

func f561420(_e: int) -> int:
	return _unported(0x561420)

func f561500(_e: int) -> int:
	return _unported(0x561500)

func f5615d0(_e: int) -> int:
	return _unported(0x5615d0)

func f561680(_e: int, _argument: int) -> int:
	return _unported(0x561680)

func f561a40(_e: int) -> int:
	return _unported(0x561a40)

func f561b00(_e: int) -> int:
	return _unported(0x561b00)

func f561bc0(_e: int) -> int:
	return _unported(0x561bc0)

func f561c70(_e: int) -> int:
	return _unported(0x561c70)

func f561e90(_e: int) -> int:
	return _unported(0x561e90)

func f561fb0(_e: int) -> int:
	return _unported(0x561fb0)

func f561ff0(_e: int) -> int:
	return _unported(0x561ff0)

func f562020(_e: int) -> int:
	return _unported(0x562020)

func f5620d0(_e: int) -> int:
	return _unported(0x5620d0)

func f562170(_e: int) -> int:
	return _unported(0x562170)

func f5622b0(_e: int) -> int:
	return _unported(0x5622b0)

func f562400(_e: int) -> int:
	return _unported(0x562400)

func f5625d0(_e: int) -> int:
	return _unported(0x5625d0)

func f5627b0(_e: int) -> int:
	return _unported(0x5627b0)

func f562920(_e: int) -> int:
	return _unported(0x562920)

func f5629d0(_e: int) -> int:
	return _unported(0x5629d0)

func f562b80(_e: int) -> int:
	return _unported(0x562b80)

func f562bf0(_e: int) -> int:
	return _unported(0x562bf0)

func f562cf0(_e: int, _other: int) -> int:
	return _unported(0x562cf0)

func f562d80(_e: int) -> int:
	return _unported(0x562d80)

func f562ec0(_e: int) -> int:
	return _unported(0x562ec0)

func f563170(_e: int) -> int:
	return _unported(0x563170)

func f563250(_e: int) -> int:
	return _unported(0x563250)

func f5632e0(_e: int) -> int:
	return _unported(0x5632e0)

func f563340(_e: int) -> int:
	return _unported(0x563340)

func f5633a0(_e: int) -> int:
	return _unported(0x5633a0)

func f563820(_e: int) -> int:
	return _unported(0x563820)

func f563a00(_e: int, __unused: int) -> int:
	return _unported(0x563a00)

func f563b10(_e: int) -> int:
	return _unported(0x563b10)

func f563b40(_card_id: int) -> int:
	return _unported(0x563b40)

func f563b70(_a: int, _b: int) -> int:
	return _unported(0x563b70)

func f563c20(_p: int, _card_id: int, _ex1: int, _ex2: int) -> int:
	return _unported(0x563c20)

func f563df0(_p: int, _code: int) -> int:
	return _unported(0x563df0)

func f563e50(_p: int, _index: int, _out_addr: int) -> int:
	return _unported(0x563e50)

func f5640f0(_idx: int) -> int:
	return _unported(0x5640f0)

func f564170(_idx: int) -> int:
	return _unported(0x564170)

func f564250(_e: int, __unused: int) -> int:
	return _unported(0x564250)

func f564e20() -> int:
	return _unported(0x564e20)

func f564e40(_e: int, _loc: int) -> int:
	return _unported(0x564e40)

func f564e70(_e: int, _p: int, _z: int) -> int:
	return _unported(0x564e70)

func f564ef0(_e: int, _p: int, _z: int) -> int:
	return _unported(0x564ef0)

func f564f30(_e: int, _p: int, _atk: int, _defense: int, _exclude: int) -> int:
	return _unported(0x564f30)

func f5650a0(_e: int) -> int:
	return _unported(0x5650a0)

func f565220(_e: int) -> int:
	return _unported(0x565220)

func f565380(_e: int) -> int:
	return _unported(0x565380)

func f565430(_e: int) -> int:
	return _unported(0x565430)

func f565580(_e: int) -> int:
	return _unported(0x565580)

func f565800(_e: int) -> int:
	return _unported(0x565800)

func f565880(_e: int) -> int:
	return _unported(0x565880)

func f565900(_e: int) -> int:
	return _unported(0x565900)

func f565aa0(_e: int) -> int:
	return _unported(0x565aa0)

func f565c80(_e: int) -> int:
	return _unported(0x565c80)

func f565df0(_e: int, _other: int) -> int:
	return _unported(0x565df0)

func f565f40(_e: int) -> int:
	return _unported(0x565f40)

func f565fc0(_e: int, __unused: int) -> int:
	return _unported(0x565fc0)

func f566170(_e: int, _other: int) -> int:
	return _unported(0x566170)

func f566440(_e: int) -> int:
	return _unported(0x566440)

func f5666a0(_e: int) -> int:
	return _unported(0x5666a0)

func f566740(_e: int) -> int:
	return _unported(0x566740)

func f566810(_e: int) -> int:
	return _unported(0x566810)

func f566900(_e: int) -> int:
	return _unported(0x566900)

func f5669d0(_e: int) -> int:
	return _unported(0x5669d0)

func f566ae0(_e: int) -> int:
	return _unported(0x566ae0)

func f566be0(_e: int) -> int:
	return _unported(0x566be0)

func f566cb0(_e: int) -> int:
	return _unported(0x566cb0)

func f566ef0(_e: int) -> int:
	return _unported(0x566ef0)

func f567060(_e: int) -> int:
	return _unported(0x567060)

func f567210(_e: int) -> int:
	return _unported(0x567210)

func f5672e0(_e: int, _other: int) -> int:
	return _unported(0x5672e0)

func f567450(_e: int) -> int:
	return _unported(0x567450)

func f567720(_e: int) -> int:
	return _unported(0x567720)

func f5678b0(_e: int) -> int:
	return _unported(0x5678b0)

func f567940(_e: int) -> int:
	return _unported(0x567940)

func f5679f0(_e: int) -> int:
	return _unported(0x5679f0)

func f567a50(_e: int) -> int:
	return _unported(0x567a50)

func f567b30(_e: int) -> int:
	return _unported(0x567b30)

func f567c40(_e: int) -> int:
	return _unported(0x567c40)

func f567c8c(_e: int) -> int:
	return _unported(0x567c8c)

func f567ce0(_e: int) -> int:
	return _unported(0x567ce0)

func f567e20(_e: int) -> int:
	return _unported(0x567e20)

func f567f30(_e: int) -> int:
	return _unported(0x567f30)

func f5681f0(_e: int) -> int:
	return _unported(0x5681f0)

func f568300(_e: int) -> int:
	return _unported(0x568300)

func f568470(_e: int) -> int:
	return _unported(0x568470)

func f568560(_e: int) -> int:
	return _unported(0x568560)

func f568660(_e: int) -> int:
	return _unported(0x568660)

func f5687a0(_e: int) -> int:
	return _unported(0x5687a0)

func f5688f0(_e: int) -> int:
	return _unported(0x5688f0)

func f568990(_e: int) -> int:
	return _unported(0x568990)

func f568ac0(_e: int) -> int:
	return _unported(0x568ac0)

func f568bc0(_e: int, _option: int) -> int:
	return _unported(0x568bc0)

func f568cf0(_e: int) -> int:
	return _unported(0x568cf0)

func f568d80(_e: int) -> int:
	return _unported(0x568d80)

func f568fe0(_e: int) -> int:
	return _unported(0x568fe0)

func f569070(_e: int) -> int:
	return _unported(0x569070)

func f569100(_e: int) -> int:
	return _unported(0x569100)

func f5691b0(_entry: int, _p: int, _z: int) -> int:
	return _unported(0x5691b0)

func f569370(_entry: int, _p: int, _hand: int) -> int:
	return _unported(0x569370)

func f569440(_entry: int, _p: int, _loc: int, _index: int) -> int:
	return _unported(0x569440)

func f569500(_p: int, _index: int, _kind: int) -> int:
	return _unported(0x569500)

func f5697e0(_p: int) -> int:
	return _unported(0x5697e0)

func f569940(_e: int, _text_buffer: int) -> int:
	return _unported(0x569940)

func f569c30() -> int:
	return _unported(0x569c30)

func f56a380(_p: int, _kind: int, _data: int) -> int:
	return _unported(0x56a380)

func f56a430() -> int:
	return _unported(0x56a430)

func f56a460() -> int:
	return _unported(0x56a460)

func f56a950() -> int:
	return _unported(0x56a950)

func f56a9b0() -> int:
	return _unported(0x56a9b0)

func f56a9e0() -> int:
	return _unported(0x56a9e0)

func f56ac20(_index: int) -> int:
	return _unported(0x56ac20)

func f56ac80(_p: int, _row: int) -> int:
	return _unported(0x56ac80)

func f56ad10(_p: int, _excluded: int) -> int:
	return _unported(0x56ad10)

func f56adf0(_p: int) -> int:
	return _unported(0x56adf0)

func f56ae90(_list: int, _last: int, _required: int, _limit: int) -> int:
	return _unported(0x56ae90)

func f56aef0() -> int:
	return _unported(0x56aef0)

func f56af00(_p: int, _location: int, _chosen: int) -> int:
	return _unported(0x56af00)

func f56b290() -> int:
	return _unported(0x56b290)

func f56b490(_e: int) -> int:
	return _unported(0x56b490)

func f56b5f0(_e: int) -> int:
	return _unported(0x56b5f0)

func f56b9e0(_p: int, _i: int) -> int:
	return _unported(0x56b9e0)

func f56ba50(_p: int, _card_id: int, _a3: int) -> int:
	return _unported(0x56ba50)

func f56db20(_p: int, _z: int) -> int:
	return _unported(0x56db20)

func f56dc40(_p: int) -> int:
	return _unported(0x56dc40)

func f56dd40(_p: int) -> int:
	return _unported(0x56dd40)

func f56dde0(_p: int) -> int:
	return _unported(0x56dde0)

func f56def0(_p: int) -> int:
	return _unported(0x56def0)

func f56dfd0() -> int:
	return _unported(0x56dfd0)

func f56e050(_p: int, _amount: int) -> int:
	return _unported(0x56e050)

func f56e0b0(_p: int) -> int:
	return _unported(0x56e0b0)

func f56e120() -> int:
	return _unported(0x56e120)

func f56e1c0(_p: int, _z: int) -> int:
	return _unported(0x56e1c0)

func f56e230(_p: int) -> int:
	return _unported(0x56e230)

func f56e280(_p: int, _amount: int) -> int:
	return _unported(0x56e280)

func f56e2e0(_p: int, _a2: int) -> int:
	return _unported(0x56e2e0)

func f56e350(_p: int, _index: int, _mode: int) -> int:
	return _unported(0x56e350)

func f56e3b0(_p: int, _owner: int, _z: int) -> int:
	return _unported(0x56e3b0)

func f56e460(_p: int) -> int:
	return _unported(0x56e460)

func f56e540(_index: int) -> int:
	return _unported(0x56e540)

func f56e5b0(_a0: int, _a1: int, _a2: int) -> int:
	return _unported(0x56e5b0)

func f56e600(_p: int) -> int:
	return _unported(0x56e600)

func f56e660(_p: int) -> int:
	return _unported(0x56e660)

func f56e6e0(_mode: int, _alternate: int) -> int:
	return _unported(0x56e6e0)

func f56ffe0() -> int:
	return _unported(0x56ffe0)

func f570040(_activate: int, _chained: int, _effect: int) -> int:
	return _unported(0x570040)

func f570350(_action: int) -> int:
	return _unported(0x570350)

func f5703c0() -> int:
	return _unported(0x5703c0)

func f570450(_p: int, _hand: int, _index: int) -> int:
	return _unported(0x570450)

func f570850(_index: int, _z: int, _p: int = -1) -> int:
	return _unported(0x570850)

func f570cb0(_index: int, _p: int) -> int:
	return _unported(0x570cb0)

func f570e50(_p: int = -1, _z: int = -1, _index: int = -1) -> int:
	return _unported(0x570e50)

func f571080(_mask: int, _index: int) -> int:
	return _unported(0x571080)

func f5710d0(_opponent: int, _mask: int, _index: int) -> int:
	return _unported(0x5710d0)

func f5712b0() -> int:
	return _unported(0x5712b0)

func f571330(_p: int, _loc: int) -> int:
	return _unported(0x571330)

func f5713b0() -> int:
	return _unported(0x5713b0)

func f571510() -> int:
	return _unported(0x571510)

func f571530() -> int:
	return _unported(0x571530)

func f5715c0(_p: int, _z: int) -> int:
	return _unported(0x5715c0)

func f571600(_p: int, _z: int) -> int:
	return _unported(0x571600)

func f571780(_race: int) -> int:
	return _unported(0x571780)

func f571810(_p: int, _z: int, _a3: int) -> int:
	return _unported(0x571810)

func f571c30(_base: int, _p: int, __a3: int, _a4: int) -> int:
	return _unported(0x571c30)

func f571d30(_p: int) -> int:
	return _unported(0x571d30)

func f571d90(_p: int) -> int:
	return _unported(0x571d90)

func f572070(_p: int) -> int:
	return _unported(0x572070)

func f5720d0(_p: int) -> int:
	return _unported(0x5720d0)

func f572100(_p: int) -> int:
	return _unported(0x572100)

func f572340(_p: int) -> int:
	return _unported(0x572340)

func f572b00(_p: int) -> int:
	return _unported(0x572b00)

func f572fc0(_p: int) -> int:
	return _unported(0x572fc0)

func f573090(_p: int) -> int:
	return _unported(0x573090)

func f5732e0() -> int:
	return _unported(0x5732e0)

func f5736f0(_p: int) -> int:
	return _unported(0x5736f0)

func f574420(_p: int) -> int:
	return _unported(0x574420)

func f574c50(_p: int) -> int:
	return _unported(0x574c50)

func f574d20(_p: int) -> int:
	return _unported(0x574d20)

func f575750(_p: int) -> int:
	return _unported(0x575750)

func f575880(_p: int) -> int:
	return _unported(0x575880)

func f575d50(_p: int) -> int:
	return _unported(0x575d50)

func f575e50(_p: int) -> int:
	return _unported(0x575e50)

func f575ed0() -> int:
	return _unported(0x575ed0)

func f575f80(_p: int) -> int:
	return _unported(0x575f80)

func f575ff0(_p: int) -> int:
	return _unported(0x575ff0)

func f5761c0(_p: int) -> int:
	return _unported(0x5761c0)

func f576350() -> int:
	return _unported(0x576350)

func f576ba0(_p: int) -> int:
	return _unported(0x576ba0)

func f576c90() -> int:
	return _unported(0x576c90)

func f576e40() -> int:
	return _unported(0x576e40)

func f577000(_a0: int) -> int:
	return _unported(0x577000)

func f577040(_p: int, _z: int) -> int:
	return _unported(0x577040)

func f5770d0(_p: int) -> int:
	return _unported(0x5770d0)

func f577670() -> int:
	return _unported(0x577670)

func f578340() -> int:
	return _unported(0x578340)

func f578500() -> int:
	return _unported(0x578500)

func f5786a0() -> int:
	return _unported(0x5786a0)

func f578720() -> int:
	return _unported(0x578720)

func f5787a0() -> int:
	return _unported(0x5787a0)

func f5788f0() -> int:
	return _unported(0x5788f0)

func f578a70() -> int:
	return _unported(0x578a70)

func f578b00(_monster: int, _mode: int, _no_spell: int) -> int:
	return _unported(0x578b00)

func f578bd0() -> int:
	return _unported(0x578bd0)

func f578be0() -> int:
	return _unported(0x578be0)

func f578c40(_p: int, _count: int, __unused: int, _mode: int) -> int:
	return _unported(0x578c40)

func f578da0(_p: int, _count: int, __unused: int, _mode: int) -> int:
	return _unported(0x578da0)

func f578ee0(_p: int, _mode: int, _count: int) -> int:
	return _unported(0x578ee0)

func f578fb0(_p: int, _mode: int, _count: int) -> int:
	return _unported(0x578fb0)

func f579090(_p: int, _mode: int, _count: int) -> int:
	return _unported(0x579090)

func f579160(_p: int) -> int:
	return _unported(0x579160)

func f579260(_p: int) -> int:
	return _unported(0x579260)

func f579370(_p: int, _idx: int, _mode: int) -> int:
	return _unported(0x579370)

func f579460() -> int:
	return _unported(0x579460)

func f5794a0() -> int:
	return _unported(0x5794a0)

func f5794e0() -> int:
	return _unported(0x5794e0)

func f579540(_p: int) -> int:
	return _unported(0x579540)

func f579630(_p: int, _z: int, _i: int, _mask: int) -> int:
	return _unported(0x579630)

func f579890() -> int:
	return _unported(0x579890)

func f5798a0() -> int:
	return _unported(0x5798a0)

func f579fe0() -> int:
	return _unported(0x579fe0)

func f57a060(_mask: int) -> int:
	return _unported(0x57a060)

func f57a0a0(_p: int) -> int:
	return _unported(0x57a0a0)

func f57a1d0(_p: int) -> int:
	return _unported(0x57a1d0)

func f57a250(_p: int, _idx: int) -> int:
	return _unported(0x57a250)

func f57a490(_p: int, _idx: int) -> int:
	return _unported(0x57a490)

func f57a7c0(_reason: int) -> int:
	return _unported(0x57a7c0)

func f57aca0() -> int:
	return _unported(0x57aca0)

func f57b140() -> int:
	return _unported(0x57b140)

func f57b6e0() -> int:
	return _unported(0x57b6e0)

func f57bb60() -> int:
	return _unported(0x57bb60)

func f57bd40() -> int:
	return _unported(0x57bd40)

func f57c050(_index: int) -> int:
	return _unported(0x57c050)

func f57c0c0() -> int:
	return _unported(0x57c0c0)

func f57c440() -> int:
	return _unported(0x57c440)

func f57c710() -> int:
	return _unported(0x57c710)

func f57c7a0() -> int:
	return _unported(0x57c7a0)

func f57c800(_p: int, _hand: int, _zone: int, _pos: int, _mode: int) -> int:
	return _unported(0x57c800)

func f57c9a0(_p: int, _hand: int, _zone: int, _pos: int) -> int:
	return _unported(0x57c9a0)

func f57cad0(_p: int, _z: int) -> int:
	return _unported(0x57cad0)

func f57cb60(_p: int, _card: int, _a: int, _b: int, _flags: int, _lo: int, _hi: int) -> int:
	return _unported(0x57cb60)

func f57cc50(_p: int, _card: int, _a: int, _flags: int, _lo: int, _hi: int) -> int:
	return _unported(0x57cc50)

func f57cd30(_p: int, _hand: int, _zone: int, _pos: int, _mode: int) -> int:
	return _unported(0x57cd30)

func f57ce60(_p: int) -> int:
	return _unported(0x57ce60)

func f57ceb0(_exclude: int, _permissive: int) -> int:
	return _unported(0x57ceb0)

func f57d060(_idx: int) -> int:
	return _unported(0x57d060)

func f57d110(_exclude: int) -> int:
	return _unported(0x57d110)

func f57d250(_p: int, _id: int, _limit: int) -> int:
	return _unported(0x57d250)

func f57d2c0(_p: int, _id: int) -> int:
	return _unported(0x57d2c0)

func f57d330(_idx: int) -> int:
	return _unported(0x57d330)

func f57d6f0(_p: int, _exclude: int, _atk: int, _defense: int) -> int:
	return _unported(0x57d6f0)

func f57d7d0(_p: int, _exclude: int, _atk: int, _defense: int) -> int:
	return _unported(0x57d7d0)

func f57d8b0(_card: int, _p: int, _exclude: int) -> int:
	return _unported(0x57d8b0)

func f57da00(_p: int) -> int:
	return _unported(0x57da00)

func f57da30(_idx: int, _mode: int) -> int:
	return _unported(0x57da30)

func f57dad0() -> int:
	return _unported(0x57dad0)

func f57db20() -> int:
	return _unported(0x57db20)

func f57dbb0(_priority: int, _id: int) -> int:
	return _unported(0x57dbb0)

func f57de50(_base: int, _player: int) -> int:
	return _unported(0x57de50)

func f57e1c0(_base: int, _player: int) -> int:
	return _unported(0x57e1c0)

func f57e380() -> int:
	return _unported(0x57e380)

func f57e440(_attacker: int, _target: int, _out: int) -> int:
	return _unported(0x57e440)

func f57e540(_attacker: int, _out: int) -> int:
	return _unported(0x57e540)

func f57e690(_attack: int, _target: int) -> int:
	return _unported(0x57e690)

func f57e6e0(_attack: int) -> int:
	return _unported(0x57e6e0)

func f57e740() -> int:
	return _unported(0x57e740)

func f57e8d0() -> int:
	return _unported(0x57e8d0)

func f57e8f0() -> int:
	return _unported(0x57e8f0)

func f57e910() -> int:
	return _unported(0x57e910)

func f57e980(_hand: int, _tributes: int) -> int:
	return _unported(0x57e980)

func f57ea80() -> int:
	return _unported(0x57ea80)

func f57eb90(_flip: int) -> int:
	return _unported(0x57eb90)

func f57ebc0(_out_damage: int) -> int:
	return _unported(0x57ebc0)

func f57eef0() -> int:
	return _unported(0x57eef0)

func f57f090(_effect: int) -> int:
	return _unported(0x57f090)

func f57f9c0(_effect: int, _id: int) -> int:
	return _unported(0x57f9c0)

func f57fb00(_effect: int) -> int:
	return _unported(0x57fb00)

func f5802d0(_id: int) -> int:
	return _unported(0x5802d0)

func f580370(_id: int) -> int:
	return _unported(0x580370)

func f5806d0() -> int:
	return _unported(0x5806d0)

func f5808b0() -> int:
	return _unported(0x5808b0)

func f5808c0() -> int:
	return _unported(0x5808c0)

func f580940() -> int:
	return _unported(0x580940)

func f581430() -> int:
	return _unported(0x581430)

func f581580() -> int:
	return _unported(0x581580)

func f581bf0(_attack: int, _defense: int) -> int:
	return _unported(0x581bf0)

func f581cd0(_index: int, _fallback: int) -> int:
	return _unported(0x581cd0)

func f581e00() -> int:
	return _unported(0x581e00)

func f581e40() -> int:
	return _unported(0x581e40)

func f582190(_slot: int) -> int:
	return _unported(0x582190)

func f582360() -> int:
	return _unported(0x582360)

func f583250() -> int:
	return _unported(0x583250)

func f583840() -> int:
	return _unported(0x583840)

func f583c80() -> int:
	return _unported(0x583c80)

func f583cf0() -> int:
	return _unported(0x583cf0)

func f583e00(__index: int) -> int:
	return _unported(0x583e00)
