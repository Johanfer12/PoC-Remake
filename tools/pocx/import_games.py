"""Import local user-owned installations/media. Never run game executables."""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import uuid

from .__main__ import (GAMES, STARTER_TABLES, _read_va, extract,
                       export_duel_image)
from .archive import Archive
from .executable import validate
from .voices import add_voice
from .compact import optimize_tree


def locate(root: Path, game: str) -> dict[str, Path]:
    """Find one coherent installation, accepting mixed-case filenames."""
    exe_name = STARTER_TABLES[game][0].lower()
    matches = []
    for directory, _, files in os.walk(root):
        names = {name.lower(): Path(directory) / name for name in files}
        required = {exe_name, "data.dat", "voice.dat", "region.dat"}
        if required <= names.keys():
            matches.append(names)
    if len(matches) != 1:
        raise ValueError(f"{game}: se esperaba una instalación con Data.dat, Voice.dat, "
                         f"Region.dat y {exe_name}; encontradas: {len(matches)}")
    names = matches[0]
    for archive_name in ("data.dat", "voice.dat"):
        with Archive(names[archive_name]) as archive:
            if not archive.entries:
                raise ValueError(f"{game}: {archive_name} vacío")
            if archive_name == "data.dat" and f"{GAMES[game]}/file/deck_{GAMES[game]}.txt" not in archive.by_name:
                raise ValueError(f"{game}: el archivo pertenece a otro juego")
    validate(names[exe_name].read_bytes(), game)
    return names


def find_sevenzip() -> str:
    bundled = os.environ.get("POC_7ZIP", "")
    if bundled and Path(bundled).is_file():
        return bundled
    for command in ("7z", "7zz"):
        if found := shutil.which(command):
            return found
    for variable in ("ProgramFiles", "ProgramFiles(x86)"):
        if os.environ.get(variable):
            path = Path(os.environ[variable]) / "7-Zip/7z.exe"
            if path.is_file():
                return str(path)
    raise ValueError("No se encuentra 7-Zip. Instálalo o selecciona una carpeta instalada.")


def unpack(source: Path, destination: Path) -> Path:
    if source.is_dir():
        return source
    if source.suffix.lower() != ".iso" or not source.is_file():
        raise ValueError("Selecciona una carpeta instalada o un archivo .iso")
    sevenzip = find_sevenzip()
    result = subprocess.run([sevenzip, "x", str(source), f"-o{destination}", "-y"],
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode != 0:
        raise ValueError("La ISO está incompleta o dañada. No se importó; selecciona otra imagen o una carpeta instalada.")
    return destination


def installation(root: Path, game: str, workspace: Path) -> dict[str, Path]:
    try:
        return locate(root, game)
    except ValueError as error:
        cabinets = [p for p in root.rglob("*") if p.is_file() and p.name.lower() == "data1.cab"]
        for index, cabinet in enumerate(cabinets):
            sevenzip = find_sevenzip()
            destination = workspace / f"cab-{index}"
            # Standard Microsoft CAB embedded in the original MSI discs. No MSI execution.
            result = subprocess.run([sevenzip, "x", str(cabinet), f"-o{destination}", "-y"],
                                    stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
            if result.returncode == 0:
                try:
                    return locate(destination, game)
                except ValueError:
                    pass
        # Only extract recognized Inno installers; never launch setup.exe.
        candidates = [p for p in root.rglob("*") if p.suffix.lower() == ".exe" and p.stem.lower().startswith(("setup", "install"))]
        if not candidates:
            raise error
        inno = shutil.which("innoextract")
        if not inno:
            raise ValueError("El medio contiene un instalador. Instala innoextract en PATH o selecciona el juego ya instalado.") from error
        for index, candidate in enumerate(candidates):
            dest = workspace / f"installer-{index}"
            result = subprocess.run([inno, "--extract", "--output-dir", str(dest), str(candidate)],
                                    stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
            if result.returncode == 0:
                try:
                    return locate(dest, game)
                except ValueError:
                    pass
        raise ValueError(f"{game}: no se encontró una instalación compatible en el medio") from error


def export_audio(src: Path, out: Path, games=None) -> None:
    import struct
    tables = {"yugi": (0x5AD3D0, 0x5ADA40), "kaiba": (0x5B03D8, 0x5B0A48),
              "joey": (0x5EFD48, 0x5F0A30)}
    result = {}
    for game in (games if games is not None else GAMES):
        addresses = tables[game]
        exe = (src / game / "app" / STARTER_TABLES[game][0]).read_bytes()
        for kind, address in zip(("internal", "stream"), addresses):
            for index in range(256):
                ptr, loop, channel, volume = struct.unpack("<4I", _read_va(exe, address + index * 16, 16))
                if ptr == 0:
                    break
                name = bytearray()
                for offset in range(256):
                    byte = _read_va(exe, ptr + offset, 1)
                    if byte == b"\0":
                        break
                    name.extend(byte)
                wav = name.decode("ascii").lower()
                if not wav.endswith(".wav") or volume > 127 or channel != (1 if kind == "internal" else 2):
                    raise ValueError(f"{game}: tabla de audio incompatible")
                result[f"{game}/voice/{kind}/{wav}"] = {"volume": volume, "loop": bool(loop)}
            else:
                raise ValueError(f"{game}: tabla de audio sin terminador")
    (out / "common/audio_native.json").write_text(json.dumps(result, indent=2), encoding="utf-8")


def import_games(sources: dict[str, Path], output: Path, extra_voices: list[tuple[str, Path]] | None = None, base: Path | None = None,
                 compact: bool = False, replace: bool = False) -> None:
    output = output.resolve()
    if output.exists() and not replace:
        raise ValueError("La carpeta de destino ya existe; se conserva intacta. Selecciona un destino nuevo.")
    if output.is_symlink() or (output.exists() and not (output / "inventory.json").is_file()):
        raise ValueError("El destino no es una biblioteca de recursos compatible")
    if (not sources and not (base is not None and (extra_voices or compact))) or not set(sources) <= GAMES.keys():
        raise ValueError("Selecciona al menos un juego compatible")
    previous = None
    if base is not None:
        base = base.resolve()
        if output.is_relative_to(base) and not (replace and output == base):
            raise ValueError("El destino debe estar fuera de los datos existentes")
        previous = json.loads((base / "inventory.json").read_text(encoding="utf-8"))
        if set(sources) & previous["games"].keys():
            raise ValueError("Ese juego ya está preparado")
    output.parent.mkdir(parents=True, exist_ok=True)
    # Same volume: rename publishes only a fully converted installation.
    with tempfile.TemporaryDirectory(prefix=".poc-import-", dir=output.parent) as temporary:
        work = Path(temporary)
        if not sources:
            converted = work / "converted"
            shutil.copytree(base, converted)
            for game, voice_path in extra_voices or []:
                if game not in previous["games"]:
                    raise ValueError(f"{game}: prepara el juego antes de añadir voces")
                add_voice(voice_path, converted, game)
            _publish(converted, output, compact, replace)
            return
        for game in sources:
            print(f"Validando {game}…", flush=True)
            root = unpack(sources[game].resolve(), work / f"media-{game}")
            names = installation(root, game, work / game)
            app = work / "sources" / game / "app"
            app.mkdir(parents=True)
            for name in ("Data.dat", "Voice.dat", "Region.dat", STARTER_TABLES[game][0]):
                shutil.copyfile(names[name.lower()], app / name)
        converted = work / "converted"
        extract(work / "sources", converted)
        for game, voice_path in extra_voices or []:
            if game in sources:
                add_voice(voice_path, converted, game)
            elif previous is None or game not in previous["games"]:
                raise ValueError(f"Juego no reconocido para voces: {game}")
        export_audio(work / "sources", converted, sources)
        if base is None:
            _publish(converted, output, compact, replace)
        else:
            merged = work / "merged"
            shutil.copytree(base, merged)
            current = json.loads((converted / "inventory.json").read_text(encoding="utf-8"))
            old_master = previous.get("master", next(g for g in reversed(GAMES) if g in previous["games"]))
            new_master = current["master"]
            promote = list(GAMES).index(new_master) > list(GAMES).index(old_master)
            # The most recent installed game owns the shared card tables and artwork.
            for path in converted.rglob("*"):
                if not path.is_file():
                    continue
                relative = path.relative_to(converted)
                if relative.parts[0] == "common" and relative.parts[1] != "duel" and not promote:
                    continue
                destination = merged / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, destination)
            for name, field in (("inventory.json", "games"), ("voice_manifest.json", "games")):
                old = json.loads((base / name).read_text(encoding="utf-8"))
                new = json.loads((converted / name).read_text(encoding="utf-8"))
                old[field].update(new[field])
                if name == "inventory.json":
                    if promote:
                        for key in ("card_pools", "cards_total", "cards_with_art"):
                            old[key] = new[key]
                    old["master"] = new_master if promote else old_master
                    old.setdefault("duel_images", {}).update(new.get("duel_images", {}))
                (merged / name).write_text(json.dumps(old, indent=2), encoding="utf-8")
            keys = json.loads((base / "color_keys.json").read_text(encoding="utf-8"))
            incoming_keys = json.loads((converted / "color_keys.json").read_text(encoding="utf-8"))
            keys.update({k: v for k, v in incoming_keys.items() if promote or not k.startswith("common/")})
            (merged / "color_keys.json").write_text(json.dumps(keys, indent=1), encoding="utf-8")
            audio = json.loads((base / "common/audio_native.json").read_text(encoding="utf-8"))
            audio.update(json.loads((converted / "common/audio_native.json").read_text(encoding="utf-8")))
            (merged / "common/audio_native.json").write_text(json.dumps(audio, indent=2), encoding="utf-8")
            for game, voice_path in extra_voices or []:
                if game not in sources:
                    add_voice(voice_path, merged, game)
            _publish(merged, output, compact, replace)
    print("Importación completa.", flush=True)


def _publish(staging: Path, output: Path, compact: bool, replace: bool) -> None:
    if compact:
        optimize_tree(staging)
    backup = output.with_name(".poc-previous-" + uuid.uuid4().hex)
    if output.exists():
        if not replace:
            raise ValueError("El destino ya existe")
        output.rename(backup)
    try:
        staging.rename(output)
    except OSError:
        if backup.exists():
            backup.rename(output)
        raise
    if backup.exists():
        shutil.rmtree(backup)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    for game in GAMES:
        parser.add_argument(f"--{game}", type=Path)
    parser.add_argument("--base", type=Path, help="datos existentes que se conservarán")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--replace", action="store_true", help="actualiza atómicamente una biblioteca existente")
    parser.add_argument("--no-compact", action="store_true", help="conserva PNG/WAV para herramientas de desarrollo")
    parser.add_argument("--voice", action="append", default=[], metavar="GAME=VOICE.DAT",
                        help="añade otro doblaje; repetible, sin reemplazar idiomas distintos")
    args = parser.parse_args()
    try:
        extra = []
        for spec in args.voice:
            if "=" not in spec:
                raise ValueError("Usa --voice juego=ruta/Voice.dat")
            game, path = spec.split("=", 1)
            extra.append((game, Path(path)))
        import_games({game: getattr(args, game) for game in GAMES if getattr(args, game) is not None}, args.out, extra, args.base,
                     compact=not args.no_compact, replace=args.replace)
    except (OSError, ValueError, KeyError, RuntimeError, subprocess.SubprocessError, SystemExit) as error:
        parser.exit(1, f"No se pudo importar: {error}\n")


if __name__ == "__main__":
    main()
