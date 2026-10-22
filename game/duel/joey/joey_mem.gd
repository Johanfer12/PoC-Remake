class_name JoeyMem
extends RefCounted
## Memoria nativa del motor de duelo de Joey_Pc.exe (plan: docs/duel/PLAN_MOTOR_JOEY.md).
##
## Como DuelMem para Yugi: la memoria de datos del ejecutable (.rdata, .data y su zona sin
## inicializar) se modela entera con las direcciones originales, para que las rutinas portadas
## usen los mismos desplazamientos y tablas. La imagen inicial la genera tools/pocx
## (`duelimage --game joey`) en data/common/duel/joey_image.bin; es de Konami y no va al
## repositorio. El estado del duelo vive en STATE..STATE_END, el mismo rango que vuelca la
## sonda Frida de Joey y que compara el oraculo.

## .rdata (0x5da000) hasta el final de .rsrc (0xa5d660), redondeado a pagina: .rsrc va en la
## imagen porque las lecturas fuera de rango del original (zonas mas alla de la 11) caen ahi.
const BASE := 0x5da000
const END := 0xa5e000
## Variables locales cuya direccion se pasa a otra rutina (la pila del original), en anillo y
## fuera de la imagen, para no pisar lo que el original tendria en esas direcciones.
const STACK := 0xa5e000
const STACK_SIZE := 0x10000

## Estado del duelo que comparan el oraculo y la sonda (14.168 bytes).
const STATE := 0xa54e50
const STATE_END := 0xa585a8

## Modo de la partida: bits 7-8 repeticion/red; bits 1-2 jugadores controlados en local.
const MODE := 0xa54e5c

## Comando en curso: u16 opcode (bit 15 = jugador) + 3 x u16 (5b9ca0 lo copia de la cola).
const CMD := 0xa550a0
## Cola de comandos (5b9170): 256 entradas de 8 bytes y su contador u16.
const QUEUE := 0xa550a8
const QUEUE_COUNT := 0xa558a8
const QUEUE_MAX := 0x100
## Estado del comando en curso: bits 0-6 paso, bit 14 en ejecucion.
const CMD_STATE := 0xa558ac
const CMD_RUNNING := 0x4000

## Bloque de cada jugador (0xd44 bytes); el jugador 1 empieza en PLAYER + PLAYER_SIZE.
const PLAYER := 0xa55d60
const PLAYER_SIZE := 0xd44
## Desplazamientos dentro del bloque del jugador.
const P_LP := 0x04          ## u16 puntos de vida
const P_HAND_N := 0x08      ## u8 cartas en la mano
const P_DECK_N := 0x09      ## u8 cartas en el mazo
const P_GRAVE_N := 0x0a     ## u8 cartas en el cementerio
const P_FUSION_N := 0x0b    ## u8 cartas en el mazo de fusion
const P_BANISH_N := 0x0c    ## u8 cartas excluidas
const P_ZONES := 0x14       ## 12 objetos de 0x90: 0-4 monstruos, 5-9 magia/trampa, 10 campo, 11 jugador
const ZONE_SIZE := 0x90
const P_HAND := 0x6d4       ## u32[80] (5700f0, ubicacion 0xb)
const P_DECK := 0x814       ## u32[80] (0xd), la carta de arriba es la 0
const P_FUSION := 0x954     ## u32[15] (0xc)
const P_GRAVE := 0x990      ## u32 (0xe)
const P_BANISH := 0xb0c     ## u32 (0xf)

## Objeto de zona (0x90 bytes): +0 u32 entrada, +4 u16 numero de colocacion, +6 u16 banderas,
## +8 u16 contador, +0xa u16 vinculos, +0xc u16[32] referencias, +0x4c u16[32] tipos,
## +0x8c u32 estado.
const Z_FLAGS := 0x06
const Z_COUNTER := 0x08
const Z_LINKS_N := 0x0a
const Z_LINK_REF := 0x0c
const Z_LINK_KIND := 0x4c
const Z_STATUS := 0x8c

## Carta separada del campo (5700f0 con zona+i >= 11) y objeto vacio que devuelve sin ella.
const DETACHED := 0xa57864
const DETACHED_EMPTY := 0xa578f4

## Turno, fase y combate (ver INVENTARIO_MOTOR_JOEY.md).
const TURN := 0xa577fa
const PHASE_STEP := 0xa577fc
const BATTLE := 0xa57840

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


static func pl(p: int) -> int:
	return PLAYER + (p & 1) * PLAYER_SIZE


static func zone(p: int, z: int) -> int:
	return PLAYER + (p & 1) * PLAYER_SIZE + P_ZONES + z * ZONE_SIZE



## Identidad de una entrada: propietario (bit 12) + numero de colocacion (bits 24-30) * 2.
static func ident(entry: int) -> int:
	return ((entry >> 12) & 1) + ((entry >> 24) & 0x7f) * 2

## Copia del estado del duelo (STATE..STATE_END).
func state() -> PackedByteArray:
	return bytes.slice(STATE - BASE, STATE_END - BASE)


func set_state(raw: PackedByteArray) -> void:
	for i in mini(raw.size(), STATE_END - STATE):
		bytes[STATE - BASE + i] = raw[i]


## Reserva `size` bytes (a cero) para una variable local cuya direccion se pasa a otra rutina.
func local(size: int) -> int:
	size = (size + 3) & ~3
	if _stack_top + size > STACK_SIZE:
		_stack_top = 0
	var addr := STACK + _stack_top
	_stack_top += size
	clear(addr, size)
	return addr


func clear(addr: int, size: int) -> void:
	var off := addr - BASE
	for i in size:
		bytes[off + i] = 0


func copy(dst: int, src: int, size: int) -> void:
	var tmp := bytes.slice(src - BASE, src - BASE + size)
	for i in size:
		bytes[dst - BASE + i] = tmp[i]


## Las direcciones se reducen a 32 bits como en la CPU: un indice negativo sin acotar (zona -1)
## lee el hueco anterior igual que el original.
func u8(addr: int) -> int:
	return bytes[(addr & 0xffffffff) - BASE]


func s8(addr: int) -> int:
	return bytes.decode_s8((addr & 0xffffffff) - BASE)


func u16(addr: int) -> int:
	return bytes.decode_u16((addr & 0xffffffff) - BASE)


func s16(addr: int) -> int:
	return bytes.decode_s16((addr & 0xffffffff) - BASE)


func u32(addr: int) -> int:
	return bytes.decode_u32((addr & 0xffffffff) - BASE)


func set_u8(addr: int, value: int) -> void:
	bytes[(addr & 0xffffffff) - BASE] = value & 0xff


func set_u16(addr: int, value: int) -> void:
	bytes.encode_u16((addr & 0xffffffff) - BASE, value & 0xffff)


func set_u32(addr: int, value: int) -> void:
	bytes.encode_u32((addr & 0xffffffff) - BASE, value & 0xffffffff)
