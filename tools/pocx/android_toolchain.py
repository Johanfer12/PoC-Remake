"""Private, portable Android tools, prepared by the launcher on first use."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tempfile
import urllib.request
import zipfile

VERSION = "4.7.2"
SOURCE_COMMIT = "0bae59c3894b17934d146813bbcfdff80b7d720d"
SOURCE_MANIFEST_SHA256 = "064cadb7a4a159f2beef0cbde5610c9ba1cb42c8e3082f6d2c2413871f1990bc"
SDK_LICENSE_URL = "https://developer.android.com/studio/terms"
GODOT_BASE = f"https://github.com/godotengine/godot-builds/releases/download/{VERSION}-stable/"
PACKAGES = {
    "godot": (GODOT_BASE + f"Godot_v{VERSION}-stable_win64.exe.zip",
              "731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953"),
    "templates": (GODOT_BASE + f"Godot_v{VERSION}-stable_export_templates.tpz",
                  "f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011"),
    "java": ("https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.9%2B10/"
             "OpenJDK21U-jdk_x64_windows_hotspot_21.0.9_10.zip",
             "1c67df516e9795c0b09f5714bfe151da2e3cc988082042f5bbb60d75e4e63fb5"),
    # Official Google repository archives; hashes are pinned, never obtained at runtime.
    "build-tools": ("https://dl.google.com/android/repository/build-tools_r35.0.1_windows.zip",
                    "79748cb4ab64b61fa678af21639985c7e394d874a4e31f082f4026d5c57e01a3"),
    "platform-tools": ("https://dl.google.com/android/repository/platform-tools_r37.0.1-win.zip",
                       "45f4d63113e895ebde0c90f194099a4676b6ac653bd28d54314a9e022bbc1a99"),
}


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def fetch(url: str, target: Path, expected: str, progress=None) -> None:
    partial = target.with_suffix(".part")
    try:
        request = urllib.request.Request(url, headers={"User-Agent": "PowerOfChaos-AndroidBuilder"})
        with urllib.request.urlopen(request, timeout=120) as response, partial.open("wb") as output:
            total = int(response.headers.get("Content-Length", 0))
            received = 0
            while chunk := response.read(1024 * 1024):
                output.write(chunk)
                received += len(chunk)
                if progress:
                    progress(received, total)
        if digest(partial) != expected:
            raise ValueError(f"La descarga no supera SHA-256: {url}")
        partial.replace(target)
    finally:
        partial.unlink(missing_ok=True)


def extract(archive: Path, target: Path, select=None, strip=0) -> None:
    """Reject traversal, links and Windows drive/alternate stream names."""
    target = target.resolve()
    with zipfile.ZipFile(archive) as zipped:
        for member in zipped.infolist():
            parts = PurePosixPath(member.filename.replace("\\", "/")).parts
            if (not parts or member.filename.startswith(("/", "\\")) or
                    any(p in ("..", ".") or ":" in p for p in parts) or
                    (member.external_attr >> 16) & 0o170000 == 0o120000):
                raise ValueError("Ruta insegura en el kit Android: " + member.filename)
            if member.is_dir() or (select and not select(member.filename)) or len(parts) <= strip:
                continue
            destination = target.joinpath(*parts[strip:])
            if not destination.resolve().is_relative_to(target):
                raise ValueError("Ruta fuera del kit Android")
            destination.parent.mkdir(parents=True, exist_ok=True)
            with zipped.open(member) as source, destination.open("wb") as output:
                shutil.copyfileobj(source, output)


def bundle_source(target: Path) -> None:
    """Build-time: pin and verify the public, source-only Android snapshot."""
    with tempfile.TemporaryDirectory(prefix="android-source-") as temporary:
        work = Path(temporary)
        archive = work / "source.zip"
        url = f"https://codeload.github.com/Johanfer12/Yu-Gi-Oh-Power-of-Chaos-Remake/zip/{SOURCE_COMMIT}"
        with urllib.request.urlopen(url, timeout=120) as source, archive.open("wb") as output:
            shutil.copyfileobj(source, output)
        extract(archive, work / "source", strip=1)
        root = work / "source"
        manifest = root / "PUBLICATION_MANIFEST.json"
        if digest(manifest) != SOURCE_MANIFEST_SHA256:
            raise ValueError("El manifiesto Android no coincide con la revisión auditada")
        files = json.loads(manifest.read_text(encoding="utf8"))["files"]
        with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as output:
            for name, expected in files.items():
                path = root / name
                if not path.resolve().is_relative_to(root.resolve()) or digest(path) != expected:
                    raise ValueError("Fuente Android no válida: " + name)
                output.write(path, name)


def prepare(launcher: Path) -> dict:
    storage = launcher / "PoC Data/android"
    if not (storage / "sdk-license.accepted").is_file():
        raise ValueError("Acepta la licencia del SDK Android desde Crear APK en el launcher: " + SDK_LICENSE_URL)
    root = storage / "tools" / "kit-1"
    root.mkdir(parents=True, exist_ok=True)
    progress_file = storage / "progress.json"

    def status(message):
        temporary = progress_file.with_suffix(".tmp")
        temporary.write_text(json.dumps({"message": message}), encoding="utf8")
        try:
            temporary.replace(progress_file)
        except PermissionError:
            # The UI may be reading the previous progress snapshot on Windows.
            temporary.unlink(missing_ok=True)
        print(message, flush=True)

    try:
        # Each component activates atomically; successful downloads survive another component's failure.
        locations = {"templates": f"godot/editor_data/export_templates/{VERSION}.stable",
                     "build-tools": "sdk/build-tools/35.0.1", "platform-tools": "sdk/platform-tools"}
        required = {"godot": [f"Godot_v{VERSION}-stable_win64_console.exe", f"Godot_v{VERSION}-stable_win64.exe"],
                    "templates": ["android_debug.apk", "android_release.apk"], "java": ["bin/keytool.exe"],
                    "build-tools": ["apksigner.bat", "zipalign.exe", "aapt.exe"], "platform-tools": ["adb.exe"]}
        for name, (url, expected) in PACKAGES.items():
            component = root / locations.get(name, name)
            marker = component / ".verified"
            if marker.is_file() and marker.read_text() == expected and all((component / p).is_file() for p in required[name]):
                continue
            with tempfile.TemporaryDirectory(prefix=f"{name}-", dir=root) as temporary:
                work = Path(temporary)
                archive = work / "download.zip"
                last_percent = [-1]
                def report(received, total):
                    current = received * 100 // total if total else received // 1048576
                    if current == last_percent[0]:
                        return
                    last_percent[0] = current
                    percent = f" {received * 100 // total}%" if total else f" {received // 1048576} MB"
                    status(f"Android: {name}{percent}")
                fetch(url, archive, expected, report)
                installed = work / "installed"
                installed.mkdir()
                if name == "templates":
                    extract(archive, installed, lambda n: n.endswith(("/android_debug.apk", "/android_release.apk")), strip=1)
                else:
                    extract(archive, installed, strip=0 if name == "godot" else 1)
                if not all((installed / p).is_file() for p in required[name]):
                    raise ValueError("El archivo oficial no contiene las herramientas esperadas: " + name)
                (installed / ".verified").write_text(expected)
                if component.exists():
                    # Only this managed kit component; never a user's SDK installation.
                    assert component.resolve().is_relative_to(root.resolve())
                    shutil.rmtree(component)
                component.parent.mkdir(parents=True, exist_ok=True)
                installed.rename(component)
        source_zip = Path(__file__).with_name("android-source.zip")
        source = root / ("source-" + SOURCE_COMMIT[:12])
        if not source.is_dir():
            status("Android: preparando el motor táctil incluido…")
            if not source_zip.is_file():
                raise ValueError("Faltan las fuentes Android incluidas en esta compilación del launcher")
            with tempfile.TemporaryDirectory(prefix="source-", dir=root) as temporary:
                stage = Path(temporary) / "source"
                extract(source_zip, stage)
                stage.rename(source)
        sdk = root / "sdk"
        sdk.mkdir(exist_ok=True)
        godot = root / "godot" / f"Godot_v{VERSION}-stable_win64_console.exe"
        # Portable editor keeps settings/templates beside the launcher, off the system profile.
        (godot.parent / "_sc_").touch()
        editor = godot.parent / "editor_data"
        key = storage / "signing/debug.keystore"
        key.parent.mkdir(parents=True, exist_ok=True)
        identity = key.with_suffix(".sha256")
        if not key.exists():
            if identity.exists() or any((storage / "apks").glob("*.apk")):
                raise ValueError("Falta tu firma Android anterior. Restaura PoC Data/android/signing de tu respaldo para actualizar tus APK.")
            status("Android: creando tu firma local…")
            temporary_key = key.with_suffix(".tmp")
            try:
                subprocess.run([str(root / "java/bin/keytool.exe"), "-genkeypair", "-noprompt",
                                "-keystore", str(temporary_key), "-storepass", "android", "-keypass", "android",
                                "-alias", "androiddebugkey", "-keyalg", "RSA", "-keysize", "2048",
                                "-validity", "10000", "-dname", "CN=Power of Chaos local build"],
                               check=True, capture_output=True)
                temporary_key.rename(key)
            finally:
                temporary_key.unlink(missing_ok=True)
        # Detect accidental replacement before creating APKs that cannot update an installed app.
        certificate = subprocess.run([str(root / "java/bin/keytool.exe"), "-exportcert", "-keystore", str(key),
                                      "-storepass", "android", "-alias", "androiddebugkey"],
                                     check=True, capture_output=True)
        certificate_hash = hashlib.sha256(certificate.stdout).hexdigest()
        if identity.is_file() and identity.read_text() != certificate_hash:
            raise ValueError("La firma Android cambió. Restaura tu clave anterior de PoC Data/android/signing.")
        identity.write_text(certificate_hash)
        settings = editor / "editor_settings-4.7.tres"
        def gd(path):
            return json.dumps(path.resolve().as_posix())
        editor.mkdir(exist_ok=True)
        settings.write_text('[gd_resource type="EditorSettings" format=3]\n\n[resource]\n' +
                            f'export/android/java_sdk_path = {gd(root / "java")}\n' +
                            f'export/android/android_sdk_path = {gd(sdk)}\n' +
                            f'export/android/debug_keystore = {gd(key)}\n' +
                            'export/android/debug_keystore_user = "androiddebugkey"\n' +
                            'export/android/debug_keystore_pass = "android"\n', encoding="utf8")
        status("Android: herramientas listas; preparando tus juegos…")
        config = dict(root=source, godot=godot, java=root / "java", sdk=sdk, keystore=key)
        previous = sorted((storage / "apks").glob("PowerOfChaos-Android-*.apk"))
        if previous:
            config["previous"] = previous[-1]
        return config
    finally:
        try:
            progress_file.unlink(missing_ok=True)
        except PermissionError:
            pass  # A final UI read must not turn a completed setup into an error.
