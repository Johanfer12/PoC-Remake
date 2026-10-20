"""Recorta el logo de Yugi del splash de titulo para el selector de juego.

Kaiba y Joey traen el logo como imagen suelta; Yugi solo lo tiene pintado sobre el fondo
(title2g, el de la version comercial). El logo lleva un halo lavanda que es lo unico que sube
el azul respecto al fondo sin logo (title1), asi que ese halo delimita la placa: se rellenan
sus huecos (las letras),
se suaviza el borde y dentro se aclara el halo para que no se vean los jeroglificos.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SPLASH = "yugi/title/title2g.png"   # version comercial (Region.dat, 0x40a830); title2e es la "jump"
BACKGROUND = "yugi/title/title1.png"
OUT = "yugi/title/yugi_logo.png"
LOGO_BOTTOM = 300      # el logo ocupa la mitad superior del splash
GLOW_BLUE = 35         # subida minima del canal azul que cuenta como halo
GLOW_TINT = (238, 225, 255)


def build(data: Path) -> Path:
    splash = Image.open(data / SPLASH).convert("RGB")
    c = np.asarray(splash).astype(float)
    b = np.asarray(Image.open(data / BACKGROUND).convert("RGB")).astype(float)
    glow = c[..., 2] - b[..., 2] > GLOW_BLUE
    glow[LOGO_BOTTOM:] = False

    # cierre morfologico para unir el halo y relleno de los huecos desde el borde
    mask = Image.fromarray((glow * 255).astype(np.uint8))
    for f in (ImageFilter.MaxFilter(9),) * 2 + (ImageFilter.MinFilter(9),) * 2:
        mask = mask.filter(f)
    padded = Image.new("L", (mask.width + 2, mask.height + 2), 0)
    padded.paste(mask, (1, 1))
    ImageDraw.floodfill(padded, (0, 0), 128)
    plate = np.asarray(padded)[1:-1, 1:-1] != 128
    alpha = (Image.fromarray((plate * 255).astype(np.uint8))
             .filter(ImageFilter.MinFilter(5)).filter(ImageFilter.GaussianBlur(5)))

    haze = Image.fromarray((glow * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.5))
    k = (np.asarray(haze).astype(float) / 255 * 0.75)[..., None]
    rgb = c * (1 - k) + np.array(GLOW_TINT, float) * k
    rgba = np.concatenate([rgb, np.asarray(alpha).astype(float)[..., None]], 2)
    logo = Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA").crop(alpha.getbbox())
    dest = data / OUT
    logo.save(dest)
    return dest
