"""Base de datos de cartas (bin#/card_*.bin) y mazos (.ydc / deck_*.txt)."""
from __future__ import annotations

import collections
import re
import struct
from dataclasses import asdict, dataclass, field

from .archive import Archive

NAME_SIZE = 64
INTID_SLOTS = 2048
LANGS = ("spa", "eng", "fra", "ger", "ita", "jpn")
TEXT_ENCODING = {"jpn": "cp932"}

# card_pack.bin: campo de bits con el juego en el que se puede conseguir la carta
PACK_YUGI = 1
PACK_KAIBA = 2
PACK_JOEY = 4

# card_prop.bin (u32): def/10 (9 bits) | atk/10 (9) | clase (2) | tipo (5) | nivel (4) | atributo (3)
MONSTER_KIND = {0: "normal", 1: "effect", 2: "fusion", 3: "ritual"}
ATTRIBUTE = {0: "none", 1: "light", 2: "dark", 3: "water", 4: "fire", 5: "earth", 6: "wind"}
TYPE_TRAP = 21
TYPE_SPELL = 22


def _text(data: bytes, lang: str) -> str:
    return data.decode(TEXT_ENCODING.get(lang, "cp1252"), "replace")


def _decode_password(value: int) -> str:
    # BCD: los 4 bytes en little endian forman los 8 digitos
    return "".join(f"{b:02x}" for b in value.to_bytes(4, "little"))


@dataclass
class Card:
    index: int
    internal_id: int
    password: str
    names: dict[str, str] = field(default_factory=dict)
    descriptions: dict[str, str] = field(default_factory=dict)
    atk: int = 0
    defense: int = 0
    level: int = 0
    attribute: str = ""
    type_id: int = 0
    kind_bits: int = 0
    category: str = ""          # monster / spell / trap
    pack: int = 0               # bits PACK_*
    image: str | None = None    # nombre del BMP en card/ y mini/; None si no tiene arte

    @property
    def games(self) -> list[str]:
        return [g for bit, g in ((PACK_YUGI, "yugi"), (PACK_KAIBA, "kaiba"), (PACK_JOEY, "joey"))
                if self.pack & bit]


def _read_strings(names_blob: bytes, count: int, lang: str) -> list[str]:
    return [_text(names_blob[i * NAME_SIZE:(i + 1) * NAME_SIZE].split(b"\0", 1)[0], lang)
            for i in range(count)]


def _read_descriptions(index_blob: bytes, desc_blob: bytes, count: int, lang: str) -> list[str]:
    offsets = struct.unpack(f"<{len(index_blob) // 4}I", index_blob)
    out = []
    for i in range(count):
        start = offsets[i]
        end = desc_blob.find(b"\0", start)
        out.append(_text(desc_blob[start:end], lang).replace("\r\n", "\n"))
    return out


def load_cards(archive: Archive) -> list[Card]:
    ids_blob = archive.read("bin#/card_id.bin")
    count = len(ids_blob) // 2
    ids = struct.unpack(f"<{count}H", ids_blob)
    packs = struct.unpack(f"<{count}H", archive.read("bin#/card_pack.bin"))
    props = struct.unpack(f"<{count}I", archive.read("bin#/card_prop.bin"))
    passwords = struct.unpack(f"<{count}I", archive.read("bin#/card_pass.bin"))
    listing = archive.read("card/list_card.txt").decode("cp1252")
    images = {int(i): f for i, f in re.findall(r"//\t(\d+):\[\d+\]\r?\n(\S+)", listing)}
    # Las cartas sin arte apuntan todas a un mismo comodin (card_ura.bmp en Yugi/Kaiba,
    # token_sl.bmp en Joey); el arte real se usa una sola vez.
    uses = collections.Counter(images.values())

    names = {lang: _read_strings(archive.read(f"bin#/card_name{lang}.bin"), count, lang)
             for lang in LANGS}
    descs = {lang: _read_descriptions(archive.read(f"bin#/card_indx{lang}.bin"),
                                      archive.read(f"bin#/card_desc{lang}.bin"), count, lang)
             for lang in LANGS}

    cards = []
    for i in range(1, count):
        p = props[i]
        type_id = (p >> 20) & 0x1F
        category = "trap" if type_id == TYPE_TRAP else "spell" if type_id == TYPE_SPELL else "monster"
        image = images.get(i)
        if image and uses[image] > 1 and not names["eng"][i].endswith(" Token"):
            image = None
        cards.append(Card(
            index=i,
            internal_id=ids[i],
            password=_decode_password(passwords[i]),
            names={lang: names[lang][i] for lang in LANGS},
            descriptions={lang: descs[lang][i] for lang in LANGS},
            atk=((p >> 9) & 0x1FF) * 10,
            defense=(p & 0x1FF) * 10,
            level=(p >> 25) & 0xF,
            attribute=ATTRIBUTE.get((p >> 29) & 0x7, "?") if category == "monster" else category,
            type_id=type_id,
            kind_bits=(p >> 18) & 0x3,
            category=category,
            pack=packs[i],
            image=image,
        ))
    return cards


def card_to_dict(card: Card) -> dict:
    d = asdict(card)
    d["games"] = card.games
    if card.category == "monster":
        d["monster_kind"] = MONSTER_KIND[card.kind_bits]
    return d


@dataclass
class Deck:
    main: list[int]
    fusion: list[int]
    side: list[int]


def parse_ydc(data: bytes) -> Deck:
    """Formato YDC: u32 version, u32 checksum, y tres listas (u16 n + n*u16 id interno)."""
    offset = 8
    parts = []
    for _ in range(3):
        (n,) = struct.unpack_from("<H", data, offset)
        offset += 2
        parts.append(list(struct.unpack_from(f"<{n}H", data, offset)))
        offset += 2 * n
    return Deck(*parts)


def parse_deck_txt(text: str) -> Deck:
    """deck_y/k/j.txt: el mazo del rival principal escrito a mano por los desarrolladores."""
    numbers = [int(m) for m in re.findall(r"^\s*(\d+)\s*,", text, re.MULTILINE)]
    parts, pos = [], 0
    for _ in range(3):
        n = numbers[pos]
        parts.append(numbers[pos + 1:pos + 1 + n])
        pos += 1 + n
    return Deck(*parts)
