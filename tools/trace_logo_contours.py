"""Trace only the outer alpha boundaries of user-provided logos into GDScript vectors."""
from __future__ import annotations
import argparse
import hashlib
from pathlib import Path
import numpy as np
from PIL import Image


def simplify(points, epsilon=0.35):
    def rdp(part):
        if len(part) <= 2:
            return part
        a, b = np.array(part[0], float), np.array(part[-1], float)
        delta = b - a
        length = np.linalg.norm(delta)
        values = np.array(part[1:-1], float) - a
        distances = (np.abs(delta[0] * values[:, 1] - delta[1] * values[:, 0]) / length
                     if length else np.linalg.norm(values, axis=1))
        at = int(np.argmax(distances)) + 1
        if distances[at - 1] <= epsilon:
            return [part[0], part[-1]]
        return rdp(part[:at + 1])[:-1] + rdp(part[at:])
    opposite = max(range(len(points)), key=lambda i: sum((points[i][j] - points[0][j]) ** 2 for j in (0, 1)))
    return rdp(points[:opposite + 1])[:-1] + rdp(points[opposite:] + [points[0]])[:-1]


def trace(path: Path):
    image = Image.open(path).convert("RGBA")
    mask = np.asarray(image.getchannel("A")) >= 128
    height, width = mask.shape
    padded = np.pad(mask, 1)
    edges = set()
    # Clockwise exposed pixel edges; RGB and inner holes are not included.
    for y, x in np.argwhere(mask):
        x, y = int(x), int(y)
        if not padded[y, x + 1]:
            edges.add(((x, y), (x + 1, y)))
        if not padded[y + 1, x + 2]:
            edges.add(((x + 1, y), (x + 1, y + 1)))
        if not padded[y + 2, x + 1]:
            edges.add(((x + 1, y + 1), (x, y + 1)))
        if not padded[y + 1, x]:
            edges.add(((x, y + 1), (x, y)))
    exits = {}
    for a, b in edges:
        exits.setdefault(a, set()).add(b)
    loops = []
    while edges:
        start, following = min(edges)
        points = [start]
        previous, current = start, following
        edges.remove((start, following))
        exits[start].remove(following)
        while current != start:
            points.append(current)
            options = exits.get(current, set())
            if not options:
                raise ValueError("Open alpha contour")
            dx, dy = current[0] - previous[0], current[1] - previous[1]
            def priority(point):
                vx, vy = point[0] - current[0], point[1] - current[1]
                cross, dot = dx * vy - dy * vx, dx * vx + dy * vy
                return (0 if cross > 0 else 1 if dot > 0 else 2 if cross < 0 else 3, point)
            following = min(options, key=priority)
            edges.remove((current, following))
            exits[current].remove(following)
            previous, current = current, following
        area = sum(a[0] * b[1] - b[0] * a[1] for a, b in zip(points, points[1:] + points[:1])) / 2
        if area > 1:  # Negative winding describes a hole inside a letter/plate.
            loops.append(simplify(points))
    if not loops:
        raise ValueError("The logo has no visible alpha contour")
    return (width, height), loops


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for game in ("yugi", "kaiba", "joey"):
        parser.add_argument("--" + game, required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    lines = ["class_name LogoContours", "extends RefCounted",
             "## User-requested silhouette geometry traced from alpha, without logo RGB/artwork.",
             "## Alpha threshold 128; simplification error <= 0.35 source pixels.", "const DATA := {"]
    for game in ("yugi", "kaiba", "joey"):
        source = getattr(args, game)
        (width, height), loops = trace(source)
        lines.append(f'\t"{game}": {{"size": Vector2({width}, {height}), "loops": [')
        for loop in loops:
            lines.append("\t\t[" + ", ".join(f"Vector2({x}, {y})" for x, y in loop) + "],")
        lines.append("\t]},")
        print(f"{game}: {len(loops)} contours, {sum(len(p) for p in loops)} vertices; input SHA256 {hashlib.sha256(source.read_bytes()).hexdigest()}")
    lines.append("}")
    args.out.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
