"""Puente del launcher al compilador de la copia Android, sin modificar datos PC."""
from __future__ import annotations

import json
import os
from pathlib import Path
import runpy
import shutil
import sys
import tempfile
from datetime import datetime


def configuration(launcher: Path) -> dict:
    config = launcher / "android-builder.json"
    if config.is_file():
        values = json.loads(config.read_text(encoding="utf8"))
        return {key: (launcher / value).resolve() for key, value in values.items()}
    if getattr(sys, "frozen", False):
        from .android_toolchain import prepare
        return prepare(launcher)
    # Desarrollo: buscar la copia hermana, incluso desde artifacts/.../windows.
    for parent in (launcher, *launcher.parents):
        root = parent / "PortTesting-Android"
        if (root / "tools/android/build_apk.py").is_file():
            return dict(root=root, godot=parent / "Herramientas/Godot/godot_console.exe",
                        sdk=parent / "Herramientas/AndroidSdk", java=parent / "Herramientas/JDK21",
                        keystore=parent / "FirmaAndroid/debug.keystore",
                        previous=root / "artifacts/android/PowerOfChaos-tablet-v17.apk")
    from .android_toolchain import prepare
    return prepare(launcher)


def preflight(config: dict) -> None:
    for key, relative in (("root", "tools/android/build_apk.py"), ("root", "game/project.godot"),
                          ("java", "bin/keytool.exe"), ("sdk", "build-tools")):
        if not (config[key] / relative).exists():
            raise ValueError(f"Falta una herramienta Android: {config[key] / relative}")
    for key in ("godot", "keystore"):
        if not config[key].is_file():
            raise ValueError(f"Falta {key}: {config[key]}")
    if "previous" in config and not config["previous"].is_file():
        raise ValueError(f"Falta el APK de referencia: {config['previous']}")


def create_apk(sources: dict, launcher: Path, extra_voices=None, base: Path | None = None) -> Path:
    from .import_games import import_games
    from .compact import optimize_tree

    launcher = launcher.resolve()
    config = configuration(launcher)
    preflight(config)  # Fallar antes de extraer ISO grandes.
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    evidence = launcher / "PoC Data/android/builds" / stamp
    evidence.mkdir(parents=True, exist_ok=False)
    target = launcher / "PoC Data/android/apks" / f"PowerOfChaos-Android-{stamp}.apk"
    target.parent.mkdir(parents=True, exist_ok=True)
    # Publicar solo el APK completamente verificado. Un fallo no deja un APK instalable.
    staged_apk = evidence / target.name
    old_env = {key: os.environ.get(key) for key in ("JAVA_HOME", "ANDROID_HOME", "ANDROID_SDK_ROOT", "PATH")}
    old_argv = sys.argv[:]
    try:
        os.environ.update(JAVA_HOME=str(config["java"]), ANDROID_HOME=str(config["sdk"]),
                          ANDROID_SDK_ROOT=str(config["sdk"]))
        os.environ["PATH"] = str(config["java"] / "bin") + os.pathsep + os.environ.get("PATH", "")
        with tempfile.TemporaryDirectory(prefix="resources-", dir=evidence) as temporary:
            data = Path(temporary) / "data"
            if sources or extra_voices:
                import_games(sources, data, extra_voices, base=base, compact=True)
            elif base is not None:
                shutil.copytree(base, data)
                optimize_tree(data)
            else:
                raise ValueError("Selecciona un ISO o prepara un juego antes de crear el APK")
            sys.argv = [str(config["root"] / "tools/android/build_apk.py"),
                        "--data", str(data), "--work", str(evidence / "build"),
                        "--output", str(staged_apk), "--godot", str(config["godot"]),
                        "--sdk", str(config["sdk"]), "--debug-keystore", str(config["keystore"])]
            if "previous" in config:
                sys.argv += ["--previous-apk", str(config["previous"])]
            else:
                sys.argv += ["--first-build"]
            print("Compilando con los controles de la copia Android…", flush=True)
            runpy.run_path(sys.argv[0], run_name="__main__")
        manifests = list((evidence / "build").glob("*-build-manifest.json"))
        if len(manifests) != 1:
            raise ValueError("La compilación no generó un único informe de validación")
        manifest = manifests[0]
        report = json.loads(manifest.read_text(encoding="utf8"))
        report["apk"] = str(target)
        report["android_source"] = str(config["root"])
        manifest.write_text(json.dumps(report, indent=2), encoding="utf8")
        shutil.copyfile(manifest, target.with_suffix(".json"))
        staged_apk.rename(target)
        print(f"APK creado: {target}", flush=True)
        return target
    finally:
        sys.argv = old_argv
        for key, value in old_env.items():
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value
        if staged_apk.exists():
            staged_apk.unlink()
        # Solo la copia generada por esta llamada. Los registros y manifiestos quedan.
        project = evidence / "build/project"
        if project.is_dir() and project.resolve().parent == (evidence / "build").resolve():
            shutil.rmtree(project)
        for validation in (evidence / "build").glob("*-validation"):
            for name in ("pack-save", "bundle-save"):
                save = validation / name
                if save.is_dir() and save.resolve().parent == validation.resolve():
                    shutil.rmtree(save)
