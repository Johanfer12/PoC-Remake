"""Fuente de mapa de bits del texto de las ventanas del duelo, generada con GDI como el original.

El texto de los cuadros (FUN_00465d90) lo dibuja el motor de texto del exe con GDI: para los
idiomas occidentales cada palabra se mide con GetTextExtentPoint32W (FUN_0051b3c0: ancho + 4,
alto + 3) y se pinta con TextOutW en (0, 0) de un DIB propio (FUN_00534490 -> FUN_0051b6d0),
con CreateFontA(alto, 0, 0, 0, peso, cursiva, subrayado, tachado, DEFAULT_CHARSET, 0, 0,
NONANTIALIASED_QUALITY, 0, cara) (FUN_0051b2b0(4) -> calidad 3). El resultado es texto sin
suavizado que luego se copia con color clave. TextOutW coloca cada glifo en la suma de los
avances (sin kerning), asi que un atlas de glifos sueltos con su avance reproduce la palabra
pixel a pixel; la generacion lo comprueba con frases de prueba.

Uso (solo en Windows):
    poetry run python -m pocx gdifont --data ../data
"""
from __future__ import annotations

import ctypes
import json
from ctypes import wintypes
from pathlib import Path

from PIL import Image

# Cuadros de dialogo: FUN_00465d90 -> FUN_00536330(0x12), negrita (+0x58) y cara 1 (Arial) con
# idioma no japones (FUN_0053fcd0 != 0; FUN_0051b890).
FACE = "Arial"
HEIGHT = 18
WEIGHT = 700

DEFAULT_CHARSET = 1
NONANTIALIASED_QUALITY = 3
TRANSPARENT = 1
PAD = 24

gdi32 = ctypes.WinDLL("gdi32", use_last_error=True)


class BITMAPINFOHEADER(ctypes.Structure):
    _fields_ = [("biSize", wintypes.DWORD), ("biWidth", wintypes.LONG), ("biHeight", wintypes.LONG),
                ("biPlanes", wintypes.WORD), ("biBitCount", wintypes.WORD),
                ("biCompression", wintypes.DWORD), ("biSizeImage", wintypes.DWORD),
                ("biXPelsPerMeter", wintypes.LONG), ("biYPelsPerMeter", wintypes.LONG),
                ("biClrUsed", wintypes.DWORD), ("biClrImportant", wintypes.DWORD)]


class TEXTMETRICW(ctypes.Structure):
    _fields_ = [("tmHeight", wintypes.LONG), ("tmAscent", wintypes.LONG), ("tmDescent", wintypes.LONG),
                ("tmInternalLeading", wintypes.LONG), ("tmExternalLeading", wintypes.LONG),
                ("tmAveCharWidth", wintypes.LONG), ("tmMaxCharWidth", wintypes.LONG),
                ("tmWeight", wintypes.LONG), ("tmOverhang", wintypes.LONG),
                ("tmDigitizedAspectX", wintypes.LONG), ("tmDigitizedAspectY", wintypes.LONG),
                ("tmFirstChar", wintypes.WCHAR), ("tmLastChar", wintypes.WCHAR),
                ("tmDefaultChar", wintypes.WCHAR), ("tmBreakChar", wintypes.WCHAR),
                ("tmItalic", ctypes.c_byte), ("tmUnderlined", ctypes.c_byte),
                ("tmStruckOut", ctypes.c_byte), ("tmPitchAndFamily", ctypes.c_byte),
                ("tmCharSet", ctypes.c_byte)]


gdi32.CreateCompatibleDC.restype = wintypes.HDC
gdi32.CreateCompatibleDC.argtypes = [wintypes.HDC]
gdi32.CreateFontW.restype = wintypes.HFONT
gdi32.CreateFontW.argtypes = [ctypes.c_int] * 5 + [wintypes.DWORD] * 8 + [wintypes.LPCWSTR]
gdi32.SelectObject.restype = wintypes.HGDIOBJ
gdi32.SelectObject.argtypes = [wintypes.HDC, wintypes.HGDIOBJ]
gdi32.CreateDIBSection.restype = wintypes.HBITMAP
gdi32.CreateDIBSection.argtypes = [wintypes.HDC, ctypes.c_void_p, wintypes.UINT,
                                   ctypes.POINTER(ctypes.c_void_p), wintypes.HANDLE, wintypes.DWORD]
gdi32.GetTextExtentPoint32W.argtypes = [wintypes.HDC, wintypes.LPCWSTR, ctypes.c_int,
                                        ctypes.POINTER(wintypes.SIZE)]
gdi32.TextOutW.argtypes = [wintypes.HDC, ctypes.c_int, ctypes.c_int, wintypes.LPCWSTR, ctypes.c_int]
gdi32.SetTextColor.argtypes = [wintypes.HDC, wintypes.COLORREF]
gdi32.SetBkMode.argtypes = [wintypes.HDC, ctypes.c_int]
gdi32.GetTextMetricsW.argtypes = [wintypes.HDC, ctypes.POINTER(TEXTMETRICW)]
gdi32.DeleteObject.argtypes = [wintypes.HGDIOBJ]
gdi32.DeleteDC.argtypes = [wintypes.HDC]
gdi32.GdiFlush.restype = wintypes.BOOL


class _Gdi:
    def __init__(self, face: str, height: int, weight: int) -> None:
        self.dc = gdi32.CreateCompatibleDC(None)
        self.font = gdi32.CreateFontW(height, 0, 0, 0, weight, 0, 0, 0, DEFAULT_CHARSET, 0, 0,
                                      NONANTIALIASED_QUALITY, 0, face)
        if not self.font:
            raise OSError("CreateFontW fallo")
        gdi32.SelectObject(self.dc, self.font)
        self.bitmap = None

    def metrics(self) -> TEXTMETRICW:
        tm = TEXTMETRICW()
        gdi32.GetTextMetricsW(self.dc, ctypes.byref(tm))
        return tm

    def extent(self, text: str) -> tuple[int, int]:
        size = wintypes.SIZE()
        gdi32.GetTextExtentPoint32W(self.dc, text, len(text), ctypes.byref(size))
        return size.cx, size.cy

    def render(self, text: str, width: int, height: int, x: int) -> Image.Image:
        """TextOutW blanco sobre negro en (x, 0) de un DIB de 32 bits; devuelve la imagen."""
        info = BITMAPINFOHEADER()
        info.biSize = ctypes.sizeof(BITMAPINFOHEADER)
        info.biWidth = width
        info.biHeight = -height
        info.biPlanes = 1
        info.biBitCount = 32
        bits = ctypes.c_void_p()
        bmp = gdi32.CreateDIBSection(self.dc, ctypes.byref(info), 0, ctypes.byref(bits), None, 0)
        old = gdi32.SelectObject(self.dc, bmp)
        ctypes.memset(bits, 0, width * height * 4)
        gdi32.SetTextColor(self.dc, 0xFFFFFF)
        gdi32.SetBkMode(self.dc, TRANSPARENT)
        gdi32.TextOutW(self.dc, x, 0, text, len(text))
        gdi32.GdiFlush()
        raw = ctypes.string_at(bits, width * height * 4)
        gdi32.SelectObject(self.dc, old)
        gdi32.DeleteObject(bmp)
        return Image.frombuffer("RGBA", (width, height), raw, "raw", "BGRA", 0, 1)

    def close(self) -> None:
        gdi32.DeleteObject(self.font)
        gdi32.DeleteDC(self.dc)


def _charset() -> list[str]:
    """Caracteres de la pagina 1252 (los textos y nombres de cartas son ANSI)."""
    out = []
    for b in range(0x20, 0x100):
        try:
            out.append(bytes([b]).decode("cp1252"))
        except UnicodeDecodeError:
            pass
    return out


def _lit(im: Image.Image) -> list[tuple[int, int]]:
    w, h = im.size
    px = im.load()
    return [(x, y) for y in range(h) for x in range(w) if px[x, y][0] > 127]


def build(out: Path, face: str = FACE, height: int = HEIGHT, weight: int = WEIGHT) -> Path:
    gdi = _Gdi(face, height, weight)
    tm = gdi.metrics()
    glyphs: dict[str, dict] = {}
    masks: list[tuple[str, list[tuple[int, int]], int, int]] = []
    for ch in _charset():
        cx, cy = gdi.extent(ch)
        im = gdi.render(ch, cx + PAD * 2, cy + 4, PAD)
        lit = _lit(im)
        glyphs[str(ord(ch))] = {"adv": cx}
        masks.append((ch, lit, cx, cy))
    # Atlas: una fila por glifo con su caja de pixeles encendidos.
    cell_w = max((max(x for x, _ in m) - min(x for x, _ in m) + 1) if m else 1 for _, m, _, _ in masks)
    cell_h = tm.tmHeight + 4
    cols = 16
    rows = (len(masks) + cols - 1) // cols
    atlas = Image.new("RGBA", (cols * (cell_w + 1), rows * (cell_h + 1)), (255, 255, 255, 0))
    apx = atlas.load()
    for n, (ch, lit, cx, cy) in enumerate(masks):
        g = glyphs[str(ord(ch))]
        ax = (n % cols) * (cell_w + 1)
        ay = (n // cols) * (cell_h + 1)
        if lit:
            x0 = min(x for x, _ in lit)
            x1 = max(x for x, _ in lit)
            for x, y in lit:
                apx[ax + x - x0, ay + y] = (255, 255, 255, 255)
            g.update({"x": ax, "y": ay, "w": x1 - x0 + 1, "h": cell_h, "ox": x0 - PAD})
        else:
            g.update({"x": ax, "y": ay, "w": 0, "h": 0, "ox": 0})
    # Comprobacion: la palabra compuesta con el atlas coincide con TextOutW de la cadena.
    samples = ["Para Llamar a este monstruo se requiere 1 Tributo. ",
               "¿Deseas Llamar?", "Mago Oscuro ", "AVATAR WAV fi ff", "¿Capitulas?"]
    for s in samples:
        cx, cy = gdi.extent(s)
        if cx != sum(glyphs[str(ord(c))]["adv"] for c in s):
            raise RuntimeError(f"GetTextExtentPoint32W no es la suma de avances en {s!r}")
        ref = gdi.render(s, cx + 4, cy + 3, 0)
        mine = Image.new("RGBA", (cx + 4, cy + 3), (0, 0, 0, 255))
        mpx = mine.load()
        pen = 0
        for c in s:
            g = glyphs[str(ord(c))]
            for yy in range(g["h"]):
                for xx in range(g["w"]):
                    if apx[g["x"] + xx, g["y"] + yy][3]:
                        tx, ty = pen + g["ox"] + xx, yy
                        if 0 <= tx < cx + 4 and 0 <= ty < cy + 3:
                            mpx[tx, ty] = (255, 255, 255, 255)
            pen += g["adv"]
        if _lit(ref) != _lit(mine):
            raise RuntimeError(f"el atlas no reproduce TextOutW en {s!r}")
    name = f"gdi_{face.lower().replace(' ', '_')}_{height}{'_bold' if weight >= 700 else ''}"
    out_dir = out / "common" / "font"
    out_dir.mkdir(parents=True, exist_ok=True)
    atlas.save(out_dir / f"{name}.png")
    meta = {"face": face, "height": height, "weight": weight, "quality": "NONANTIALIASED_QUALITY",
            "tm_height": tm.tmHeight, "tm_ascent": tm.tmAscent, "glyphs": glyphs}
    (out_dir / f"{name}.json").write_text(json.dumps(meta, ensure_ascii=False), encoding="utf-8")
    gdi.close()
    print(f"{out_dir / name}.png: {len(glyphs)} glifos, tmHeight {tm.tmHeight}, tmAscent {tm.tmAscent}")
    return out_dir / f"{name}.png"
