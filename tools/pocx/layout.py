"""Scripts de maquetacion (.txt) del motor de Power of Chaos.

Gramatica, igual en los tres juegos:

    recurso [numero]    // comentario

- El motor lee las lineas **por posicion**: lo que significa cada numero depende del archivo
  y del orden de la linea, y lo documentan los comentarios en japones de los desarrolladores.
- `numero` se guarda como texto porque los ceros a la izquierda importan ("000206" = 000,206).
  La codificacion mas comun son grupos de 3 digitos: XXXYYY (esquina superior izquierda en
  800x600), XXXYYYYYY (X, Y del jugador 2, Y del jugador 1), etc.
- En el nombre del recurso `?` es la letra de idioma (e, f, g, i, s) y `#` forma parte del
  nombre real del archivo.
- Un recurso `.txt` es un sub-script (por ejemplo la barra de scroll de las listas).
"""
from __future__ import annotations

from dataclasses import asdict, dataclass, field
from pathlib import Path

LANG_LETTERS = {"eng": "e", "fra": "f", "ger": "g", "ita": "i", "spa": "s"}


@dataclass
class LayoutEntry:
    line: int                 # numero de linea en el archivo (1-based), util para depurar
    resource: str | None      # None si la linea solo tiene comentario
    value: str | None         # numero tal cual, con signo y ceros
    comment: str

    def resolve(self, lang: str = "spa") -> str | None:
        if self.resource is None:
            return None
        return self.resource.replace("?", LANG_LETTERS[lang])

    def groups(self, size: int = 3) -> list[int]:
        """Divide el numero en grupos de `size` digitos empezando por la derecha
        ("95188" -> [95, 188]), porque el motor pierde los ceros iniciales en algunos casos."""
        if not self.value:
            return []
        digits = self.value.lstrip("-")
        out = []
        while digits:
            out.insert(0, int(digits[-size:]))
            digits = digits[:-size]
        return out

    def xy(self) -> tuple[int, int] | None:
        g = self.groups()
        return (g[0], g[1]) if len(g) == 2 else None


@dataclass
class Layout:
    path: str
    header: list[str] = field(default_factory=list)     # comentarios antes de la primera entrada
    entries: list[LayoutEntry] = field(default_factory=list)

    @property
    def items(self) -> list[LayoutEntry]:
        """Solo las lineas con recurso, en orden: es lo que indexa el motor."""
        return [e for e in self.entries if e.resource]


def parse_layout(text: str, path: str = "") -> Layout:
    layout = Layout(path)
    for number, raw in enumerate(text.splitlines(), start=1):
        line = raw.strip()
        if not line:
            continue
        body_text, _, comment = line.partition("//")
        body = body_text.split()
        comment = comment.strip()
        resource = body[0] if body else None
        value = body[1] if len(body) > 1 else None
        if resource is None and not layout.items:
            layout.header.append(comment)
        layout.entries.append(LayoutEntry(number, resource, value, comment))
    return layout


def load_layout(path: Path, root: Path) -> Layout:
    return parse_layout(path.read_text(encoding="utf-8"), path.relative_to(root).as_posix())


def layout_to_dict(layout: Layout) -> dict:
    return asdict(layout)
