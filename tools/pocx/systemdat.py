"""Partida guardada del original: system.dat (carpeta "Yu-Gi-Oh! Power of Chaos Common").

La comparten Yugi, Kaiba y Joey. Rutinas de Yugi_Pc.exe (Kaiba y Joey usan el mismo formato):

- 0x4628e0 lee, 0x4627c0 escribe. Dos codificadores en cadena (vtables 0x59a760 y 0x59a758):
  * 0x442820 / 0x442770: antepone 8 bytes (byte 0 = 1; u32 en +4 = valor del objeto,
    p. ej. 0x6ac5020d) y al leer exige que coincidan.
  * 0x42d5e0 / 0x42d620: cada byte b se cambia por b^5 mod 299 (0x42d290, exponenciacion
    modular; al leer, ^53 mod 299) y los valores de 9 bits se empaquetan de 8 en 8 en grupos
    de 9 bytes (0x42d310 / 0x42d3d0). Delante, 4 bytes de suma (0x42d470 / 0x42d510): para
    cada carril j = 0..3, byte j = -(base_j + suma de los bytes 4+j, 8+j, ... < 4+0x118c).
  Resultado: 4 + (0x1190 / 8) * 9 = 5.062 bytes.
- El bloque descifrado (0x1188 bytes) se copia a 0xa10120 en Yugi (0xa13140 Kaiba,
  0xa53cc0 Joey). 0x53fc40 lo valida: u16 0xfba5 en +0x1182 y en +0x1184 el complemento a
  dos de la suma de los 0x8c2 u16 anteriores; si falla se crea una partida nueva (0x53fd00).

Campos del bloque (desplazamiento desde el inicio):
  +0x006 u16  volumen de opciones << 4 (0x466e70 / 0x467000); 0xff en partida nueva
  +0x008 u16  modo de pantalla: 0 ventana, 16/24/32 bits (DAT_005aa178)
  +0x00a u16  total de cartas obtenidas (0x540240)
  +0x00c u16[0x45b]  una entrada por indice de carta (CARD_ID): bits 0-7 copias, 8-9 copias
              en el mazo principal, 10-11 en el side, 12-13 en fusion (estado de ejecucion
              del editor, 0x5402c0/0x540330/0x5403a0), bit 14 vista (sin "NEW")
  +0x10ed..+0x10f4  progreso de Joey: +0x10ef ultimo resultado (1 gana el jugador, 2 no),
              +0x10f0 racha, +0x10f1 iniciado, +0x10f2 nivel mostrado, +0x10f3 nivel,
              +0x10f4 cartas de juegos anteriores (0x446df0, 0x5bee30)
  +0x10f5 u8  Yugi/Kaiba: ultimo resultado; +0x10f6 u8 racha (0x433e50)
  +0x10f8 u32[] estadisticas por ranura (DAT_005aed1c, siempre 0): bits 0-10 victorias,
              11-21 derrotas, 22-31 empates (0x5406f0/0x540720/0x540760). La ranura 0 la
              comparten los tres juegos.
  +0x1178 u16 bit 0: regla de limite desactivada salvo prohibidas (0x53fd30)
  +0x117a 8   "YUGIOH01" (0x53fc20)
  +0x1182 u16 0xfba5, +0x1184 u16 suma
"""
from __future__ import annotations

import base64
import struct
from pathlib import Path
from collections import Counter

from .carddb import parse_ydc

FILE_SIZE = 5062
PLAIN_SIZE = 0x1190          # 8 bytes de cabecera + bloque
BLOCK_SIZE = 0x1188
CARD_SLOTS = 0x45b
MODULUS, E_ENC, E_DEC = 299, 5, 53
SUM_BASE = (0x7D, 0x13, 0x8A, 0xBB)
MAGIC = 0xFBA5
GAMES = ("yugi", "kaiba", "joey")
EXE_GAME = {"yugi_pc.exe": "yugi", "kaiba_pc.exe": "kaiba", "joey_pc.exe": "joey"}


class SystemDatError(ValueError):
    pass


def _lane_sums(raw: bytes) -> bytes:
    return bytes((-(SUM_BASE[j] + sum(raw[4 + j:PLAIN_SIZE:4]))) & 0xFF for j in range(4))


def decode(raw: bytes) -> tuple[bytes, bytes]:
    """system.dat -> (cabecera de 8 bytes, bloque de 0x1188 bytes). Valida las dos sumas."""
    if len(raw) != FILE_SIZE:
        raise SystemDatError(f"tamano {len(raw)}, se esperaba {FILE_SIZE}")
    if raw[:4] != _lane_sums(raw):
        raise SystemDatError("suma de la cabecera incorrecta (0x42d510)")
    bits = int.from_bytes(raw[4:], "little")
    plain = bytes(pow((bits >> (9 * i)) & 0x1FF, E_DEC, MODULUS) for i in range(PLAIN_SIZE))
    head, block = plain[:8], plain[8:]
    if head[0] != 1:
        raise SystemDatError("cabecera interna no reconocida (0x442750)")
    if not block_valid(block):
        raise SystemDatError("suma del bloque incorrecta (0x53fc40)")
    return head, block


def encode(head: bytes, block: bytes) -> bytes:
    """Inverso de decode (0x4627c0); sirve para comprobar que la lectura es exacta."""
    if len(head) != 8 or head[0] != 1 or not block_valid(block):
        raise SystemDatError("cabecera o bloque no valido para exportar")
    plain = head + block
    bits = 0
    for i, b in enumerate(plain):
        bits |= pow(b, E_ENC, MODULUS) << (9 * i)
    raw = bytearray(4) + bits.to_bytes(FILE_SIZE - 4, "little")
    raw[:4] = _lane_sums(bytes(raw))
    return bytes(raw)


def block_valid(block: bytes) -> bool:
    if len(block) != BLOCK_SIZE:
        return False
    words = struct.unpack_from(f"<{0x8C2}H", block)
    magic, check = struct.unpack_from("<HH", block, 0x1182)
    return magic == MAGIC and check == (-sum(words)) & 0xFFFF


def find_decks(system_dat: Path) -> dict[str, Path]:
    """Deck.ydc de cada juego instalado junto a la carpeta Common (se reconoce por su exe)."""
    found = {}
    for folder in system_dat.resolve().parent.parent.iterdir():
        if not folder.is_dir():
            continue
        names = {p.name.lower(): p for p in folder.iterdir() if p.is_file()}
        for exe, game in EXE_GAME.items():
            if exe in names and "deck.ydc" in names:
                found[game] = names["deck.ydc"]
    return found


def to_save(block: bytes, cards: list[dict], decks: dict[str, dict] | None = None) -> dict:
    """Bloque descifrado -> diccionario con la forma de SaveData (game/autoload/save_data.gd)."""
    by_index = {int(c["index"]): int(c["internal_id"]) for c in cards}
    u8 = lambda o: block[o]
    u16 = lambda o: struct.unpack_from("<H", block, o)[0]
    u32 = lambda o: struct.unpack_from("<I", block, o)[0]

    collection, seen = {}, {}
    for index in range(1, CARD_SLOTS):
        entry = u16(0xC + index * 2)
        internal_id = by_index.get(index)
        if internal_id is None:
            continue
        if entry & 0xFF:
            collection[str(internal_id)] = entry & 0xFF
        if entry & 0x4000:
            seen[str(internal_id)] = True

    record = u32(0x10F8)
    totals = {"wins": record & 0x7FF, "losses": (record >> 11) & 0x7FF, "draws": record >> 22}
    stats = {}
    for game in GAMES:
        stats[game] = dict(totals)
        last, run = (u8(0x10EF), u8(0x10F0)) if game == "joey" else (u8(0x10F5), u8(0x10F6))
        if last:
            stats[game]["streak_last"] = last
            stats[game]["streak"] = run
    if u8(0x10F1):
        stats["joey"]["started"] = True
        stats["joey"]["level"] = u8(0x10F3)
        stats["joey"]["shown_level"] = u8(0x10F2)

    volume = u16(0x6)
    options = {game: {"volume": min(15, volume >> 4), "display": u16(0x8)} for game in GAMES}
    options["joey"].update(card_set_full=bool(u8(0x10F4)), limited=bool(u8(0x10EE)))
    return {
        "version": 2,
        "collection": collection,
        "seen": seen,
        "decks": decks or {},
        "stats": stats,
        "options": options,
        "native_system": {
            "block": base64.b64encode(block).decode("ascii"),
            "limit_flags": u16(0x1178),
            "total_cards": u16(0xA),
        },
    }


def deck_from_ydc(data: bytes) -> dict:
    deck = parse_ydc(data)
    return {"main": deck.main, "fusion": deck.fusion, "side": deck.side}


def import_system(system_dat: Path, cards: list[dict]) -> dict:
    head, block = decode(system_dat.read_bytes())
    decks = {game: deck_from_ydc(path.read_bytes()) for game, path in find_decks(system_dat).items()}
    save = to_save(block, cards, decks)
    save["native_system"]["header"] = base64.b64encode(head).decode("ascii")
    return save


def from_save(save: dict, cards: list[dict], game: str = "yugi") -> bytes:
    """Actualiza campos conocidos, conservando el resto del bloque del original."""
    if game not in GAMES:
        raise SystemDatError("juego de exportacion no reconocido")
    native = save.get("native_system", {})
    original = base64.b64decode(native.get("block", ""))
    block = bytearray(original if len(original) == BLOCK_SIZE else bytes(BLOCK_SIZE))
    if len(original) != BLOCK_SIZE:
        block[0x117A:0x1182] = b"YUGIOH01"
    by_index = {int(c["index"]): int(c["internal_id"]) for c in cards}
    deck = save.get("decks", {}).get(game, {})
    counts = {part: Counter(map(int, deck.get(part, []))) for part in ("main", "side", "fusion")}
    total = 0
    for index in range(1, CARD_SLOTS):
        if index not in by_index:
            continue
        card = by_index[index]
        copies = int(save.get("collection", {}).get(str(card), 0))
        if not 0 <= copies <= 255:
            raise SystemDatError(f"las copias de {card} no caben en el byte nativo")
        offset = 0xC + index * 2
        entry = (struct.unpack_from("<H", block, offset)[0] & 0x8000) | copies
        for part, shift in [("main", 8), ("side", 10), ("fusion", 12)]:
            count = counts[part][card]
            if count > 3:
                raise SystemDatError(f"copias de {card} en {part} exceden los dos bits nativos")
            entry |= count << shift
        if str(card) in save.get("seen", {}):
            entry |= 0x4000
        struct.pack_into("<H", block, offset, entry)
        total += copies
    if total > 0xFFFF:
        raise SystemDatError("el total de copias no cabe en la palabra nativa")
    struct.pack_into("<H", block, 0xA, total)
    options = save.get("options", {})
    current = options.get(game, {})
    volume = min(15, max(0, int(current.get("volume", 15))))
    if volume != min(15, struct.unpack_from("<H", block, 6)[0] >> 4):
        struct.pack_into("<H", block, 6, volume << 4)
    struct.pack_into("<H", block, 8, int(current.get("display", 0)))
    struct.pack_into("<H", block, 0x1178, int(native.get("limit_flags", 0)))
    own = options.get("joey", {})
    block[0x10EE] = bool(own.get("limited", block[0x10EE]))
    block[0x10F4] = bool(own.get("card_set_full", block[0x10F4]))
    stats = save.get("stats", {})
    common = stats.get(game, {})
    record = min(0x7FF, max(0, int(common.get("wins", 0))))
    record |= min(0x7FF, max(0, int(common.get("losses", 0)))) << 11
    record |= min(0x3FF, max(0, int(common.get("draws", 0)))) << 22
    struct.pack_into("<I", block, 0x10F8, record)
    old, joey = stats.get("yugi", {}), stats.get("joey", {})
    for offset, row, field in [(0x10F5, old, "streak_last"), (0x10F6, old, "streak"),
                               (0x10EF, joey, "streak_last"), (0x10F0, joey, "streak")]:
        block[offset] = min(255, max(0, int(row.get(field, 0))))
    block[0x10F1] = bool(joey.get("started", "level" in joey))
    if "level" in joey:
        block[0x10F2] = int(joey.get("shown_level", joey["level"])) & 0xFF
        block[0x10F3] = int(joey["level"]) & 0xFF
    struct.pack_into("<H", block, 0x1182, MAGIC)
    struct.pack_into("<H", block, 0x1184, (-sum(struct.unpack_from(f"<{0x8C2}H", block))) & 0xFFFF)
    return bytes(block)


def export_system(save: dict, cards: list[dict], game: str = "yugi", header_key: int | None = None) -> bytes:
    head = base64.b64decode(save.get("native_system", {}).get("header", ""))
    if header_key is not None:
        head = struct.pack("<II", 1, header_key & 0xFFFFFFFF)
    if len(head) != 8:
        raise SystemDatError("importar la cabecera o indicar --system-dat-key (flcrc)")
    return encode(head, from_save(save, cards, game))
