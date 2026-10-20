class_name DuelMem
extends RefCounted
## Estado del duelo con la misma disposicion de memoria que Yugi_Pc.exe.
##
## Las rutinas del original leen y escriben los mismos bytes con tamanos distintos (un
## contador de un byte que a la vez es la parte baja de un u16 de banderas, campos de bits
## dentro de la entrada de una carta...). Para portarlas sin cambiar su comportamiento, la
## memoria de datos del ejecutable (.rdata, .data y su zona sin inicializar) se modela entera
## con las direcciones originales: las rutinas portadas usan los mismos desplazamientos y leen
## las mismas tablas constantes. La imagen inicial la genera tools/pocx (comando "duelimage")
## en data/common/duel/yugi_image.bin; es de Konami y no va al repositorio.
## Ver docs/duel/README.md.

## Primera y ultima direccion modeladas: .rdata (0x59a000) hasta el final de .data (0xa17580).
const BASE := 0x59a000
const END := 0xa18000
## Zona de variables locales cuya direccion se pasa a otra rutina (en el original, la pila).
## Se reparte en anillo: los datos solo viven lo que dura la llamada.
const STACK := 0xa18000
const STACK_SIZE := 0x10000

## Mazos de la partida (0xe2 bytes por jugador): principal u16[80] en +0x00, side u16[15]
## en +0xa0, fusion u16[15] en +0xbe; contadores u16 en +0xdc, +0xde, +0xe0.
const DECKS := 0xa112c0
const DECK_SIZE := 0xe2

## Bloque de cada jugador (0xd54 bytes). Jugador 1 = PLAYER + PLAYER_SIZE.
const PLAYER := 0xa11944
const PLAYER_SIZE := 0xd54
## Desplazamientos dentro del bloque del jugador.
const P_LP := 0x00          ## u16 puntos de vida
const P_HAND_N := 0x02      ## u8 cartas en la mano
const P_DECK_N := 0x03      ## u8 cartas en el mazo
const P_GRAVE_N := 0x04     ## u8 cartas en el cementerio
const P_FUSION_N := 0x05    ## u8 cartas en el mazo de fusion
const P_BANISH_N := 0x06    ## u8 cartas excluidas (el byte siguiente lleva banderas)
const P_ZONES := 0x18       ## 11 zonas de 0x94 bytes: 0-4 monstruos, 5-9 magia/trampa, 10 campo
const ZONE_SIZE := 0x94
const P_HAND := 0x674       ## u32[80]
const P_DECK := 0x7b4       ## u32[80], la carta de arriba es la 0
const P_GRAVE := 0x8f4      ## u32[80]
const P_FUSION := 0xa34     ## u32[80]
const P_BANISH := 0xb74     ## u32[80]

## Codigos de ubicacion que usan las rutinas (FUN_005419b0): 0-10 zonas del campo y estas listas.
const LOC_HAND := 0xb
const LOC_FUSION := 0xc
const LOC_DECK := 0xd
const LOC_GRAVE := 0xe
const LOC_BANISH := 0xf

## Contador global de colocaciones en el campo (u16), justo antes del bloque del jugador 0.
const PLACE_SEQ := 0xa11940

## Comando en curso: u16 opcode (bit 15 = jugador) + 3 x u16 argumentos.
const CMD := 0xa14f20
## Cola de comandos pendientes: 256 entradas de 8 bytes y su contador u16 en COUNT.
const QUEUE := 0xa14f28
const QUEUE_COUNT := 0xa15728
const QUEUE_MAX := 0x100
## Estado del comando en curso: bits 0-6 paso, bit 28 = en ejecucion.
const CMD_STATE := 0xa1572c
const CMD_RUNNING := 0x10000000
## Carta "en mano" de la rutina en curso (la que se esta moviendo).
const MOVING_CARD := 0xa15730

var bytes := PackedByteArray()
var _stack_top := 0


func _init() -> void:
	bytes.resize(END - BASE + STACK_SIZE)


## Carga la imagen de datos del ejecutable (rdata + data inicializada) en su direccion.
func load_image(image: PackedByteArray) -> bool:
	if image.size() > END - BASE:
		return false
	bytes = image.duplicate()
	bytes.resize(END - BASE + STACK_SIZE)
	return true


## Reserva `size` bytes (a cero) para una variable local cuya direccion se pasa a otra rutina.
func local(size: int) -> int:
	size = (size + 3) & ~3
	if _stack_top + size > STACK_SIZE:
		_stack_top = 0
	var addr := STACK + _stack_top
	_stack_top += size
	clear(addr, size)
	return addr


## memset(addr, 0, size) (FUN_0053f980).
func clear(addr: int, size: int) -> void:
	var off := addr - BASE
	for i in size:
		bytes[off + i] = 0


## memcpy(dst, src, size) (FUN_0053f9a0).
func copy(dst: int, src: int, size: int) -> void:
	var tmp := bytes.slice(src - BASE, src - BASE + size)
	for i in size:
		bytes[dst - BASE + i] = tmp[i]


func u8(addr: int) -> int:
	return bytes[addr - BASE]


func s8(addr: int) -> int:
	return bytes.decode_s8(addr - BASE)


func u16(addr: int) -> int:
	return bytes.decode_u16(addr - BASE)


func s16(addr: int) -> int:
	return bytes.decode_s16(addr - BASE)


func u32(addr: int) -> int:
	return bytes.decode_u32(addr - BASE)


func set_u8(addr: int, value: int) -> void:
	bytes[addr - BASE] = value & 0xff


func set_u16(addr: int, value: int) -> void:
	bytes.encode_u16(addr - BASE, value & 0xffff)


func set_u32(addr: int, value: int) -> void:
	bytes.encode_u32(addr - BASE, value & 0xffffffff)


## Direccion del bloque del jugador (solo cuenta el bit 0, como en el original).
static func pl(p: int) -> int:
	return PLAYER + (p & 1) * PLAYER_SIZE


## Direccion de la zona z (0-10) del jugador p.
static func zone(p: int, z: int) -> int:
	return PLAYER + (p & 1) * PLAYER_SIZE + P_ZONES + z * ZONE_SIZE
