"""Antialiasing de sprites con color clave.

Los sprites del original tienen alfa binaria (clave si/no), asi que al escalarlos a
resoluciones modernas el contorno se ve dentado. Aqui se reconstruye un contorno suave:

1. La mascara binaria se amplia con Scale2x (EPX) dos veces: redondea las diagonales y
   conserva las esquinas rectas de textos y marcos, a diferencia de un desenfoque.
2. Esa mascara a 4x se reduce con promedio de area a la escala de salida: los pixeles del
   borde quedan con cobertura parcial (antialiasing por supermuestreo).
3. El color se extiende bajo los pixeles transparentes (para que el filtrado no arrastre
   el verde/magenta de la clave) y se quita el tinte de clave del borde (despill).
"""
from __future__ import annotations

import numpy as np
from PIL import Image

SUPERSAMPLE = 4          # dos pasadas de Scale2x
BLEED_PASSES = 4
DESPILL_DISTANCE = 140.0  # pixeles del borde a menos de esta distancia RGB de la clave


def scale2x(mask: np.ndarray) -> np.ndarray:
    """EPX/Scale2x sobre una matriz booleana o de etiquetas."""
    p = np.pad(mask, 1, mode="edge")
    a, b, c, d = p[:-2, 1:-1], p[1:-1, 2:], p[1:-1, :-2], p[2:, 1:-1]   # arriba, der, izq, abajo
    e = mask
    e0 = np.where((c == a) & (c != d) & (a != b), a, e)
    e1 = np.where((a == b) & (a != c) & (b != d), b, e)
    e2 = np.where((d == c) & (d != b) & (c != a), c, e)
    e3 = np.where((b == d) & (b != a) & (d != c), d, e)
    h, w = mask.shape
    out = np.empty((h * 2, w * 2), dtype=mask.dtype)
    out[0::2, 0::2], out[0::2, 1::2] = e0, e1
    out[1::2, 0::2], out[1::2, 1::2] = e2, e3
    return out


def smooth_alpha(alpha: np.ndarray, scale: float) -> np.ndarray:
    """Alfa binaria (h, w) -> alfa antialiasada a (h*scale, w*scale), float 0..1."""
    hi = alpha > 0
    for _ in range(int(np.log2(SUPERSAMPLE))):
        hi = scale2x(hi)
    h, w = alpha.shape
    size = (round(w * scale), round(h * scale))
    cover = Image.fromarray((hi * 255).astype(np.uint8)).resize(size, Image.Resampling.BOX)
    return np.asarray(cover, dtype=np.float32) / 255.0


def bleed_color(rgb: np.ndarray, opaque: np.ndarray, passes: int = BLEED_PASSES) -> np.ndarray:
    """Rellena los pixeles transparentes con el promedio de sus vecinos opacos."""
    rgb = rgb.astype(np.float32).copy()
    known = opaque.copy()
    for _ in range(passes):
        acc = np.zeros_like(rgb)
        cnt = np.zeros(known.shape, np.float32)
        for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)):
            shifted_k = np.roll(known, (dy, dx), axis=(0, 1))
            shifted_c = np.roll(rgb, (dy, dx), axis=(0, 1))
            acc += shifted_c * shifted_k[..., None]
            cnt += shifted_k
        fill = (~known) & (cnt > 0)
        rgb[fill] = acc[fill] / cnt[fill][:, None]
        known = known | fill
    return rgb


def despill(rgb: np.ndarray, opaque: np.ndarray, key: tuple[int, int, int]) -> np.ndarray:
    """Quita el tinte de la clave a los pixeles opacos del borde que se le parecen."""
    transparent = ~opaque
    edge = opaque & (np.roll(transparent, 1, 0) | np.roll(transparent, -1, 0)
                     | np.roll(transparent, 1, 1) | np.roll(transparent, -1, 1))
    k = np.array(key, np.float32)
    dist = np.linalg.norm(rgb - k, axis=-1)
    target = edge & (dist < DESPILL_DISTANCE)
    if not target.any():
        return rgb
    # sustituye por el color medio de los vecinos opacos que no son borde
    interior = opaque & ~edge
    replacement = bleed_color(np.where(interior[..., None], rgb, 0), interior, passes=2)
    out = rgb.copy()
    out[target] = replacement[target]
    return out


def antialias_sprite(im: Image.Image, scale: float,
                     key: tuple[int, int, int] | None = None) -> Image.Image:
    """Sprite RGBA con alfa binaria -> sprite RGBA escalado con contorno antialiasado."""
    a = np.asarray(im.convert("RGBA"))
    opaque = a[..., 3] > 0
    rgb = a[..., :3].astype(np.float32)
    if key is not None:
        rgb = despill(rgb, opaque, key)
    rgb = bleed_color(rgb, opaque)
    h, w = opaque.shape
    size = (round(w * scale), round(h * scale))
    rgb_img = Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8)).resize(
        size, Image.Resampling.LANCZOS)
    alpha = smooth_alpha(a[..., 3], scale)
    out = np.dstack([np.asarray(rgb_img), (alpha * 255).astype(np.uint8)])
    return Image.fromarray(out, "RGBA")
