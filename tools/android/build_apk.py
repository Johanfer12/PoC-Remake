"""Build the tablet APK using the existing Spanish/WebP/OGG data copy.

Run from PortTesting-Android: python tools/android/build_apk.py
The original PC data is never converted or changed by this command.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts/android"
STAGE = OUT / "v17-project"
DATA = OUT / "spanish-data"


def run(command, log, cwd=None, bootstrap=False):
    result = subprocess.run(command, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    try:
        text = result.stdout.decode("utf8")
    except UnicodeDecodeError:
        text = result.stdout.decode("cp1252")
    (OUT / log).write_text(text, encoding="utf8")
    if result.returncode or (not bootstrap and ("SCRIPT ERROR" in text or "ERROR:" in text)):
        raise RuntimeError(f"{log}: {text[-5000:]}")
    print("PASS", log, flush=True)
    return text


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def verify_signing_key(tools, previous_apk, keystore):
    previous = run([str(tools / "apksigner.bat"), "verify", "--print-certs",
                    str(previous_apk.resolve())], "v17-previous-signature.log", cwd=OUT)
    expected = next(line.split(": ", 1)[1] for line in previous.splitlines()
                    if line.startswith("Signer #1 certificate SHA-256 digest:"))
    if signing_key_digest(keystore) != expected:
        raise RuntimeError("Keystore differs from the installed APK certificate; use --debug-keystore")
    return expected


def signing_key_digest(keystore):
    exported = subprocess.run(["keytool", "-exportcert", "-keystore", str(keystore),
                               "-storepass", "android", "-alias", "androiddebugkey"],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    return hashlib.sha256(exported.stdout).hexdigest()


def main():
    global STAGE
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=shutil.which("godot_console") or "godot_console")
    parser.add_argument("--sdk", type=Path, default=Path(os.environ["LOCALAPPDATA"]) / "Android/Sdk")
    # Codex de Microsoft Store conserva el certificado establecido en Roaming virtualizado.
    established_key = Path(os.environ["LOCALAPPDATA"]) / "Packages/OpenAI.Codex_2p2nqsd0c76g0/LocalCache/Roaming/Godot/keystores/debug.keystore"
    parser.add_argument("--debug-keystore", type=Path, default=established_key if established_key.is_file()
                        else Path(os.environ["APPDATA"]) / "Godot/keystores/debug.keystore")
    parser.add_argument("--previous-apk", type=Path, default=OUT / "PowerOfChaos-tablet-v16.apk")
    parser.add_argument("--data", type=Path, default=DATA)
    parser.add_argument("--work", type=Path, help="directorio nuevo para proyecto y evidencias")
    parser.add_argument("--output", type=Path, default=OUT / "PowerOfChaos-tablet-v17.apk")
    parser.add_argument("--first-build", action="store_true", help="primera instalación con tu propia firma, sin APK previo")
    args = parser.parse_args()
    # Los valores históricos siguen siendo los predeterminados del flujo Android.
    data = args.data.resolve()
    work = args.work.resolve() if args.work else OUT
    STAGE = work / "project" if args.work else STAGE
    apk = args.output.resolve()
    if args.work:
        if work.exists():
            raise RuntimeError(f"El directorio de compilación debe ser nuevo: {work}")
        work.mkdir(parents=True)
    # run() conserva todos los registros dentro de esta compilación.
    globals()["OUT"] = work
    if apk.resolve() == args.previous_apk.resolve():
        raise RuntimeError("Output APK must differ from the previous APK")
    if apk.exists():
        raise RuntimeError(f"Inspect the existing APK before replacing {apk}")
    assert args.debug_keystore.is_file(), "Missing established Android debug keystore"
    if not args.first_build:
        assert args.previous_apk.is_file(), "Missing previous APK for certificate comparison"
    assert (data / "inventory.json").is_file(), "Missing optimized data"
    if STAGE.exists():
        raise RuntimeError(f"Inspect the previous build before replacing {STAGE}")
    OUT.mkdir(parents=True, exist_ok=True)
    tools = sorted((args.sdk / "build-tools").iterdir(), key=lambda p: tuple(map(int, p.name.split('.'))))[-1]
    signing_certificate = (signing_key_digest(args.debug_keystore) if args.first_build else
                           verify_signing_key(tools, args.previous_apk, args.debug_keystore))
    shutil.copytree(ROOT / "game", STAGE, ignore=shutil.ignore_patterns(
        ".godot", "tests", "temp", "artifacts", "unused", "*.uid", "share_smoke.gd"))
    validation = OUT / "v17-validation"
    validation.mkdir(exist_ok=True)
    # El empaquetado solo necesita Paths, sin arrancar los autoloads del juego.
    # Permite compilar recursos nuevos incluso sin una importación previa local.
    project = STAGE / "project.godot"
    original_project = project.read_bytes()
    project.write_text('config_version=5\n[autoload]\nPaths="*res://autoload/paths.gd"\n', encoding='utf8')
    try:
        run([args.godot, "--headless", "--path", str(STAGE), "--script",
             str(ROOT / "tools/android/pack_data.gd"), "--", f"--data={data.as_posix()}",
             f"--pack-output={(STAGE / 'bundled_data.pck').as_posix()}",
             f"--save={(validation / 'pack-save').as_posix()}"], "v17-pack.log")
    finally:
        project.write_bytes(original_project)
    run([args.godot, "--headless", "--path", str(STAGE), "--editor", "--import"], "v17-bootstrap.log", bootstrap=True)
    run([args.godot, "--headless", "--path", str(STAGE), "--editor", "--import"], "v17-import.log")
    run([args.godot, "--headless", "--path", str(STAGE), "--export-debug", "Android Tablet", str(apk)], "v17-export.log")
    run([args.godot, "--headless", "--path", str(STAGE), "--script",
         str(ROOT / "game/tests/android_bundle_test.gd"), "--",
         f"--save={(validation / 'bundle-save').as_posix()}",
         f"--report={(validation / 'bundle.json').as_posix()}"], "v17-bundle.log")
    # Conservar el certificado existente aunque cambie el Godot instalado.
    run([str(tools / "apksigner.bat"), "sign", "--ks", str(args.debug_keystore.resolve()),
         "--ks-key-alias", "androiddebugkey", "--ks-pass", "pass:android",
         "--key-pass", "pass:android", str(apk)], "v17-sign.log", cwd=OUT)
    signed = run([str(tools / "apksigner.bat"), "verify", "--verbose", "--print-certs", str(apk)], "v17-signature.log", cwd=OUT)
    previous = "" if args.first_build else run([str(tools / "apksigner.bat"), "verify", "--print-certs", str(args.previous_apk.resolve())], "v17-previous-signature.log", cwd=OUT)
    def certificate(text):
        return next(line for line in text.splitlines() if line.startswith("Signer #1 certificate SHA-256 digest:"))
    assert certificate(signed).split(": ", 1)[1] == signing_certificate, "Unexpected signing certificate"
    if previous:
        assert certificate(signed) == certificate(previous), "Certificate changed; update would require uninstalling"
    run([str(tools / "zipalign.exe"), "-c", "-P", "16", "-v", "4", str(apk)], "v17-alignment.log")
    run([str(tools / "aapt.exe"), "dump", "badging", str(apk)], "v17-package.log", cwd=OUT)
    with zipfile.ZipFile(apk) as archive:
        assert archive.testzip() is None
        with archive.open("assets/bundled_data.pck") as stream:
            assert hashlib.file_digest(stream, "sha256").hexdigest() == digest(STAGE / "bundled_data.pck")
    source_hashes = {}
    for path in sorted(STAGE.rglob('*')):
        if path.is_file() and '.godot' not in path.relative_to(STAGE).parts and path.suffix in ['.gd', '.cfg', '.godot', '.svg']:
            source = ROOT / 'game' / path.relative_to(STAGE)
            assert digest(path) == digest(source), f"Stale source: {path}"
            source_hashes[source.relative_to(ROOT).as_posix()] = digest(path)
    data_files = [p for p in data.rglob('*') if p.is_file()]
    report = dict(version=17, apk=apk.as_posix(), bytes=apk.stat().st_size,
                  sha256=digest(apk), optimized_data_files=len(data_files),
                  optimized_data_bytes=sum(p.stat().st_size for p in data_files),
                  data_format='Selected local games; lossless WebP, OGG and short WAV',
                  source_sha256=source_hashes, signature_verified=True, same_signing_certificate_as_previous=True if previous else None, alignment_16kb_verified=True,
                  signing_certificate_sha256=signing_certificate, device_tested=False)
    (OUT / 'v17-build-manifest.json').write_text(json.dumps(report, indent=2), encoding='utf8')
    for temporary in [validation / 'pack-save', validation / 'bundle-save']:
        assert temporary.resolve().parent == validation.resolve()
        if temporary.exists():
            shutil.rmtree(temporary)
    print(json.dumps({key: value for key, value in report.items() if key != 'source_sha256'}, indent=2), flush=True)


if __name__ == '__main__':
    main()
