"""Compact a private staging copy: exact WebP pixels and timed Vorbis audio."""
from __future__ import annotations
from concurrent.futures import ThreadPoolExecutor
import hashlib
import io
import json
import threading
from pathlib import Path
from PIL import Image
import soundfile as sf


def optimize_tree(root: Path) -> dict:
    root = root.resolve()
    if not (root / "inventory.json").is_file():
        raise ValueError("La optimización requiere datos convertidos")
    paths = sorted(p for p in root.rglob("*") if p.is_file() and p.name != "optimization.json")

    def convert(path: Path) -> dict:
        before = path.stat().st_size
        target = path
        kind = "copy"
        if path.suffix.lower() == ".png":
            with Image.open(path) as image:
                rgba = image.convert("RGBA")
                buffer = io.BytesIO()
                rgba.save(buffer, "WEBP", lossless=True, exact=True, method=6)
                raw = buffer.getvalue()
                with Image.open(io.BytesIO(raw)) as decoded:
                    if decoded.convert("RGBA").tobytes() != rgba.tobytes():
                        raise ValueError("WebP cambia píxeles: " + str(path))
            alternate = path.with_suffix(".webp")
            if len(raw) < before:
                target = alternate
                target.write_bytes(raw)
                path.unlink()
                kind = "webp"
            elif alternate.exists():
                alternate.unlink()  # A newly imported PNG supersedes an older shared asset.
        elif path.suffix.lower() == ".wav":
            info = sf.info(str(path))
            music = "stream" in path.relative_to(root).parts
            alternate = path.with_suffix(".ogg")
            if music or info.duration >= 2.0:
                # libsndfile's Vorbis writer needs bounded blocks (whole songs can
                # exhaust its native stack on Windows even with a larger stack).
                with sf.SoundFile(str(path)) as source, sf.SoundFile(
                        str(alternate), mode="w", samplerate=info.samplerate,
                        channels=info.channels, format="OGG", subtype="VORBIS",
                        compression_level=0.6 if music else 0.7) as encoded:
                    for samples in source.blocks(blocksize=4096, dtype="float32", always_2d=True):
                        encoded.write(samples)
                result = sf.info(str(alternate))
                if (result.frames, result.samplerate, result.channels) != (info.frames, info.samplerate, info.channels):
                    raise ValueError("OGG cambia duración o canales: " + str(path))
                if alternate.stat().st_size < before:
                    target = alternate
                    path.unlink()
                    kind = "ogg"
                else:
                    alternate.unlink()
            elif alternate.exists():
                alternate.unlink()
        return {"path": target.relative_to(root).as_posix(), "kind": kind,
                "before": before, "after": target.stat().st_size,
                "sha256": hashlib.sha256(target.read_bytes()).hexdigest()}

    # Existing alternatives are superseded by an incoming PNG/WAV; do not race those files.
    paths = [p for p in paths if not (p.suffix.lower() in {".webp", ".ogg"} and
             p.with_suffix(".png" if p.suffix.lower() == ".webp" else ".wav").exists())]
    # Vorbis on Windows needs more native stack than Python worker threads' default.
    previous_stack = threading.stack_size()
    threading.stack_size(4 * 1024 * 1024)
    try:
        with ThreadPoolExecutor(max_workers=4) as pool:
            rows = []
            for index, row in enumerate(pool.map(convert, paths), 1):
                rows.append(row)
                if index % 250 == 0:
                    print(f"Optimizando recursos: {index}/{len(paths)}", flush=True)
    finally:
        threading.stack_size(previous_stack)
    report = {"format": 1, "image_format": "lossless WebP when smaller",
              "audio_format": "Vorbis OGG; short effects retain PCM WAV",
              "source_bytes": sum(r["before"] for r in rows),
              "output_bytes": sum(r["after"] for r in rows), "files": rows}
    (root / "optimization.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("Recursos optimizados: %d -> %d bytes" % (report["source_bytes"], report["output_bytes"]), flush=True)
    return report
