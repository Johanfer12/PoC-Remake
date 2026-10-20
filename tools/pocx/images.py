"""Decodificacion de imagenes YGA (BGRA comprimido con LZSS) y BMP."""
from __future__ import annotations

import collections
import io
import struct
from dataclasses import dataclass

from PIL import Image, ImageChops

from .archive import lzss_decompress

YGA_MAGIC = b"yga\0"


def decode_yga(data: bytes) -> Image.Image:
    if data[:4] != YGA_MAGIC:
        raise ValueError("no es un YGA")
    width, height, _frames, raw_size, packed_size = struct.unpack("<5I", data[4:24])
    pixels = lzss_decompress(data[24:24 + packed_size], raw_size)
    return Image.frombuffer("RGBA", (width, height), pixels, "raw", "BGRA", 0, 1)


def decode_bmp(data: bytes) -> Image.Image:
    return Image.open(io.BytesIO(data)).convert("RGB")


@dataclass(frozen=True)
class ColorKey:
    color: tuple[int, int, int] | None   # None = opaca
    rule: str                            # que regla decidio (para revisar y ajustar)
    border_ratio: float                  # fraccion del borde con el color de la esquina
    pixel_ratio: float                   # fraccion de la imagen con el color de la esquina

    @property
    def keyed(self) -> bool:
        return self.color is not None


# El ejecutable no contiene los colores clave (ni en el codigo ni en tablas): salen de cada
# imagen, y los artistas usaron verdes, magentas y morados ligeramente distintos. Que imagenes
# se dibujan con clave lo decide cada llamada de dibujo del motor, asi que aqui se infiere
# con reglas validadas visualmente. Las excepciones van en color_key_overrides.json.
TINY_SIDE = 4
CHROMA_MIN_SPREAD = 120      # max(canal) - min(canal)
CHROMA_MIN_PEAK = 150
CHROMA_MIN_BORDER = 0.03
DOMINANT_MIN_RATIO = 0.2
DOMINANT_STRONG_RATIO = 0.5  # a partir de aqui gana al color de la esquina
DOMINANT_MIN_BORDER = 0.05   # el color de fondo tiene que tocar el borde (no el relleno de un texto)
PURE_LOW = 60
PURE_HIGH = 200
# Negro o blanco en la esquina: solo en sprites; los fondos de 800x600 son opacos
NEUTRAL_MIN_BORDER = 0.5
NEUTRAL_MIN_PIXELS = 0.05
SCREEN_W, SCREEN_H = 800, 600


def _is_chroma(c: tuple[int, int, int]) -> bool:
    return max(c) - min(c) >= CHROMA_MIN_SPREAD and max(c) >= CHROMA_MIN_PEAK


def _is_pure(c: tuple[int, int, int]) -> bool:
    """Color "de relleno" tipico de clave: cada canal casi apagado o casi al maximo."""
    return all(v <= PURE_LOW or v >= PURE_HIGH for v in c)


def detect_color_key(im: Image.Image) -> ColorKey:
    w, h = im.size
    corner = im.getpixel((0, 0))
    counts = {c: n for n, c in im.getcolors(w * h)}
    border_counts: collections.Counter = collections.Counter()
    for strip in (im.crop((0, 0, w, 1)), im.crop((0, h - 1, w, h)),
                  im.crop((0, 0, 1, h)), im.crop((w - 1, 0, w, h))):
        border_counts.update({c: n for n, c in strip.getcolors(max(w, h))})
    border_len = 2 * (w + h)
    border_ratio = round(border_counts[corner] / border_len, 3)
    pixel_ratio = round(counts.get(corner, 0) / (w * h), 3)

    def result(color, rule):
        return ColorKey(color, rule, border_ratio, pixel_ratio)

    if w <= TINY_SIDE or h <= TINY_SIDE:
        return result(None, "tiny")
    dominant, dominant_n = max(counts.items(), key=lambda kv: kv[1])
    # Marcos de seleccion (waku_*): la esquina es el propio marco y el relleno verde del
    # interior, que ocupa casi toda la imagen, es la clave.
    if _is_chroma(dominant) and _is_pure(dominant) and dominant_n / (w * h) >= DOMINANT_STRONG_RATIO:
        return result(dominant, "chroma_dominant")
    if _is_chroma(corner) and border_ratio >= CHROMA_MIN_BORDER:
        return result(corner, "chroma_corner")
    if (_is_chroma(dominant) and _is_pure(dominant) and dominant_n / (w * h) >= DOMINANT_MIN_RATIO
            and border_counts[dominant] / border_len >= DOMINANT_MIN_BORDER):
        return result(dominant, "chroma_dominant")
    fullscreen = w >= SCREEN_W and h >= SCREEN_H
    if not fullscreen and border_ratio >= NEUTRAL_MIN_BORDER and pixel_ratio >= NEUTRAL_MIN_PIXELS:
        return result(corner, "neutral_corner")
    return result(None, "opaque")


def apply_color_key(im: Image.Image, key: tuple[int, int, int]) -> Image.Image:
    # 255 en los pixeles que coinciden con la clave en los tres canales
    r, g, b = (ch.point(lambda v, k=k: 255 if v == k else 0) for ch, k in zip(im.split(), key))
    is_key = ImageChops.multiply(ImageChops.multiply(r, g), b)
    rgba = im.convert("RGBA")
    rgba.putalpha(ImageChops.invert(is_key))
    return rgba


def decode_image(name: str, data: bytes) -> Image.Image:
    if name.lower().endswith(".yga"):
        return decode_yga(data)
    return decode_bmp(data)
