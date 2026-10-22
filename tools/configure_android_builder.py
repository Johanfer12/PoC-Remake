"""Conecta un launcher local al código Android y sus herramientas instaladas."""
import argparse
import json
from pathlib import Path
from pocx.android_builder import configuration, preflight


def configure(launcher: Path, explicit: dict | None = None) -> None:
    launcher = launcher.resolve()
    if explicit:
        values = {key: value.resolve() for key, value in explicit.items()}
    else:
        try:
            values = configuration(launcher)
        except ValueError:
            values = configuration(Path(__file__).resolve().parents[2])
    preflight(values)
    config = launcher / "android-builder.json"
    config.write_text(json.dumps({key: str(value) for key, value in values.items()}, indent=2), encoding="utf8")
    print(config)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--launcher-dir", type=Path, required=True)
    for name in ("android-root", "godot", "sdk", "java", "keystore", "previous-apk"):
        parser.add_argument("--" + name, type=Path)
    args = parser.parse_args()
    values = {key: getattr(args, name) for key, name in (("root", "android_root"),
              ("godot", "godot"), ("sdk", "sdk"), ("java", "java"),
              ("keystore", "keystore"), ("previous", "previous_apk"))
              if getattr(args, name) is not None}
    if values and not {"root", "godot", "sdk", "java", "keystore"} <= values.keys():
        parser.error("Indica --android-root, --godot, --sdk, --java y --keystore juntos")
    configure(args.launcher_dir, values)
