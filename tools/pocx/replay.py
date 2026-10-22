"""Repeticiones del duelo (.ydr) y mensajes del duelo (dlg_text/dlg_indx).

Formato .ydr (serializador en Yugi_Pc.exe 0x436f60, ver docs/duel/README.md):
    char[4]  "YGR\\0"
    u32      version (1)
    u32      marca del mazo (igual que en los .ydc)
    u32      version del duelo: (FUN_004098b0() + 1) * 100 = 100
    u32      opciones del duelo; bit 0 = jugador que empieza
    u32      semilla de srand(): time(NULL) al empezar el duelo
    Joey >=1001 intercala u32 jugador local antes de opciones (28 bytes).
    mazo del jugador 0 y mazo del jugador 1 en orden absoluto, cada uno con tres listas
             (principal, fusion, side) de u16 n + n * u16 id interno
    u32      numero de comandos
    comandos de 8 bytes: u16 opcode (bit 15 = jugador, bits 0-11 = comando) + 3 * u16
"""
from __future__ import annotations

import struct
from dataclasses import dataclass, field

MAGIC = b"YGR\0"
PLAYER_BIT = 0x8000
OPCODE_MASK = 0xFFF


@dataclass
class Command:
    player: int
    op: int
    args: tuple[int, int, int]

    def to_dict(self) -> dict:
        return {"p": self.player, "op": f"0x{self.op:02x}", "args": list(self.args)}


@dataclass
class Replay:
    version: int
    deck_mark: int
    duel_version: int
    options: int
    seed: int
    decks: list[dict[str, list[int]]] = field(default_factory=list)
    commands: list[Command] = field(default_factory=list)
    local_player: int = 0
    legacy_missing_local_player: bool = False

    @property
    def first_player(self) -> int:
        return self.options & 1

    def to_dict(self) -> dict:
        return {
            "version": self.version,
            "deck_mark": f"0x{self.deck_mark:08x}",
            "duel_version": self.duel_version,
            "options": self.options,
            "seed": self.seed,
            "local_player": self.local_player,
            "legacy_missing_local_player": self.legacy_missing_local_player,
            "decks": self.decks,
            "commands": [c.to_dict() for c in self.commands],
        }


def parse_ydr(data: bytes) -> Replay:
    if data[:4] != MAGIC:
        raise ValueError("no es una repeticion YGR")
    if len(data) < 24:
        raise ValueError("cabecera YGR truncada")
    duel_version = struct.unpack_from("<I", data, 12)[0]
    if duel_version >= 1001:
        try:
            return _parse_layout(data, True)
        except (ValueError, struct.error):
            result = _parse_layout(data, False)
            result.legacy_missing_local_player = True
            return result
    return _parse_layout(data, False)


def _parse_layout(data: bytes, has_local: bool) -> Replay:
    version, mark, duel_version = struct.unpack_from("<3I", data, 4)
    local = struct.unpack_from("<I", data, 16)[0] if has_local else 0
    if local > 1:
        raise ValueError("jugador local YGR invalido")
    options, seed = struct.unpack_from("<2I", data, 20 if has_local else 16)
    offset = 28 if has_local else 24
    decks = []
    try:
        for _ in range(2):
            lists = []
            for _ in range(3):
                (n,) = struct.unpack_from("<H", data, offset)
                offset += 2
                lists.append(list(struct.unpack_from(f"<{n}H", data, offset)))
                offset += 2 * n
            decks.append(dict(zip(("main", "fusion", "side"), lists)))
        (count,) = struct.unpack_from("<I", data, offset)
        offset += 4
        if offset + 8 * count != len(data):
            raise ValueError(f"tamano inesperado: {len(data)} bytes, se esperaban {offset + 8 * count}")
        commands = []
        for i in range(count):
            op, a, b, c = struct.unpack_from("<4H", data, offset + 8 * i)
            commands.append(Command(op >> 15, op & OPCODE_MASK, (a, b, c)))
    except struct.error as exc:
        raise ValueError("repeticion YGR truncada") from exc
    return Replay(version, mark, duel_version, options, seed, decks, commands, local)


def parse_dialogs(index_blob: bytes, text_blob: bytes, encoding: str = "cp1252") -> list[str]:
    """dlg_indx: u32 desplazamientos; dlg_text: cadenas terminadas en cero (cp932 en japones)."""
    offsets = struct.unpack(f"<{len(index_blob) // 4}I", index_blob)
    out = []
    for start in offsets:
        end = text_blob.find(b"\0", start)
        out.append(text_blob[start:end].decode(encoding, "replace").replace("\r\n", "\n"))
    return out
