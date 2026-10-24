"""Safety and offline reuse contracts for the launcher-managed Android kit."""
import hashlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import zipfile

from pocx import android_toolchain as kit


class AndroidToolchainTests(unittest.TestCase):
    def test_license_required_before_network_or_install(self):
        with tempfile.TemporaryDirectory() as temporary, patch.object(kit.urllib.request, "urlopen") as network:
            with self.assertRaisesRegex(ValueError, "licencia"):
                kit.prepare(Path(temporary), private_build=True)
            network.assert_not_called()

    def test_corrupted_download_never_activated_and_partial_removed(self):
        with tempfile.TemporaryDirectory() as temporary:
            response = io.BytesIO(b"bad download")
            response.headers = {}
            target = Path(temporary) / "tool.zip"
            with patch.object(kit.urllib.request, "urlopen", return_value=response):
                with self.assertRaisesRegex(ValueError, "SHA-256"):
                    kit.fetch("https://example.invalid/tools.zip", target, "0" * 64)
            self.assertFalse(target.exists())
            self.assertFalse(target.with_suffix(".part").exists())

    def test_archive_cannot_escape_kit(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for unsafe in ("../outside", "/absolute", "C:/drive", "file:stream", "..\\outside"):
                archive = root / "bad.zip"
                with zipfile.ZipFile(archive, "w") as zipped:
                    zipped.writestr(unsafe, "bad")
                with self.assertRaises(ValueError):
                    kit.extract(archive, root / "kit")
            self.assertFalse((root / "outside").exists())

    def test_bundled_source_keeps_audited_manifest_for_runtime_verification(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            payload = b"synthetic source file"
            manifest = json.dumps({"files": {"game/project.godot": hashlib.sha256(payload).hexdigest()}}).encode()
            archive = io.BytesIO()
            with zipfile.ZipFile(archive, "w") as zipped:
                zipped.writestr("source-revision/game/project.godot", payload)
                zipped.writestr("source-revision/PUBLICATION_MANIFEST.json", manifest)
            archive.seek(0)
            with patch.object(kit, "SOURCE_MANIFEST_SHA256", hashlib.sha256(manifest).hexdigest()), \
                 patch.object(kit.urllib.request, "urlopen", return_value=archive):
                output = root / "android-source.zip"
                kit.bundle_source(output)
                kit.extract(output, root / "unpacked")
                kit._verify_source(root / "unpacked")

    def test_installed_tools_and_signing_key_reused_without_network(self):
        with tempfile.TemporaryDirectory() as temporary:
            launcher = Path(temporary)
            storage = launcher / "PoC Data/android"
            root = storage / "tools/kit-1"
            root.mkdir(parents=True)
            (storage / "sdk-license.accepted").write_text("accepted")
            locations = {"templates": f"godot/editor_data/export_templates/{kit.VERSION}.stable",
                         "build-tools": "sdk/build-tools/35.0.1", "platform-tools": "sdk/platform-tools"}
            for name, (_, expected) in kit.PACKAGES.items():
                component = root / locations.get(name, name)
                component.mkdir(parents=True, exist_ok=True)
                (component / ".verified").write_text(expected)
                required = {"godot": [f"Godot_v{kit.VERSION}-stable_win64_console.exe", f"Godot_v{kit.VERSION}-stable_win64.exe"],
                            "templates": ["android_debug.apk", "android_release.apk"], "java": ["bin/keytool.exe"],
                            "build-tools": ["apksigner.bat", "zipalign.exe", "aapt.exe"], "platform-tools": ["adb.exe"]}
                for relative in required[name]:
                    path = component / relative
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.touch()
            source = root / ("source-" + kit.SOURCE_COMMIT[:12])
            source.mkdir()
            key = storage / "signing/debug.keystore"
            key.parent.mkdir()
            key.write_bytes(b"existing unique signing key")
            with patch.object(kit.urllib.request, "urlopen") as network, patch.object(kit.subprocess, "run") as execute:
                execute.return_value.stdout = b"existing certificate"
                config = kit.prepare(launcher, private_build=True)
            network.assert_not_called()
            self.assertEqual(execute.call_count, 1)  # Verify identity; do not regenerate the key.
            self.assertIn("-exportcert", execute.call_args.args[0])
            self.assertEqual(config["keystore"].read_bytes(), b"existing unique signing key")
            self.assertTrue(all(p.is_relative_to(storage) for p in config.values()))
            self.assertFalse((storage / "progress.json").exists())
            # Losing or replacing the key must never silently generate a new identity.
            key.unlink()
            with patch.object(kit.urllib.request, "urlopen") as network, patch.object(kit.subprocess, "run") as execute:
                with self.assertRaisesRegex(ValueError, "firma Android anterior"):
                    kit.prepare(launcher, private_build=True)
                network.assert_not_called()
                execute.assert_not_called()
            key.write_bytes(b"replacement key")
            with patch.object(kit.subprocess, "run") as execute:
                execute.return_value.stdout = b"a different certificate"
                with self.assertRaisesRegex(ValueError, "firma Android cambió"):
                    kit.prepare(launcher, private_build=True)

    def _public_fixture(self, launcher):
        storage = launcher / "PoC Data/android"
        root = storage / "tools/kit-1"
        godot = root / "godot" / f"Godot_v{kit.VERSION}-stable_win64_console.exe"
        godot.parent.mkdir(parents=True)
        godot.touch()
        (godot.parent / ".verified").write_text(kit.PACKAGES["godot"][1])
        source = root / ("source-" + kit.SOURCE_COMMIT[:12])
        (source / "game").mkdir(parents=True)
        (source / "game/project.godot").write_text("synthetic audited source")
        manifest = source / "PUBLICATION_MANIFEST.json"
        manifest.write_text(json.dumps({"files": {"game/project.godot": kit.digest(source / "game/project.godot")}}))
        apk = storage / "official" / f"PowerOfChaos-Android-{kit.PUBLIC_APK_VERSION}.apk"
        apk.parent.mkdir()
        apk.write_bytes(b"public APK from stable maintainer signing key")
        key = storage / "signing/debug.keystore"
        key.parent.mkdir()
        key.write_bytes(b"personal key must remain untouched")
        return storage, source, apk, key, kit.digest(manifest), kit.digest(apk)

    def test_public_default_reuses_verified_sources_and_apk_without_sdk_or_signing(self):
        with tempfile.TemporaryDirectory() as temporary:
            launcher = Path(temporary)
            storage, source, apk, key, source_hash, apk_hash = self._public_fixture(launcher)
            with patch.object(kit, "SOURCE_MANIFEST_SHA256", source_hash), \
                 patch.object(kit, "PUBLIC_APK_SHA256", apk_hash), \
                 patch.object(kit, "fetch") as fetch, patch.object(kit.subprocess, "run") as execute:
                config = kit.prepare(launcher)
            fetch.assert_not_called()
            execute.assert_not_called()
            self.assertEqual(config["root"], source)
            self.assertEqual(config["public_apk"], apk)
            self.assertEqual(config["public_apk_sha256"], apk_hash)
            self.assertNotIn("keystore", config)
            self.assertFalse((storage / "sdk-license.accepted").exists())
            self.assertFalse((storage / "tools/kit-1/sdk").exists())
            self.assertFalse((storage / "progress.json").exists())
            self.assertEqual(key.read_bytes(), b"personal key must remain untouched")

    def test_public_missing_apk_downloads_only_pinned_public_file(self):
        with tempfile.TemporaryDirectory() as temporary:
            launcher = Path(temporary)
            storage, _, apk, key, source_hash, apk_hash = self._public_fixture(launcher)
            payload = apk.read_bytes()
            apk.unlink()
            def fetched(url, target, expected, progress=None):
                self.assertEqual(url, kit.PUBLIC_APK_URL)
                self.assertEqual(expected, apk_hash)
                target.write_bytes(payload)
            with patch.object(kit, "SOURCE_MANIFEST_SHA256", source_hash), \
                 patch.object(kit, "PUBLIC_APK_SHA256", apk_hash), \
                 patch.object(kit, "fetch", side_effect=fetched) as fetch, \
                 patch.object(kit.subprocess, "run") as execute:
                config = kit.prepare(launcher)
            self.assertEqual(fetch.call_count, 1)
            execute.assert_not_called()
            self.assertEqual(kit.digest(config["public_apk"]), apk_hash)
            self.assertEqual(key.read_bytes(), b"personal key must remain untouched")

    def test_public_source_tampering_is_rejected_before_apk_fetch(self):
        with tempfile.TemporaryDirectory() as temporary:
            launcher = Path(temporary)
            _, source, _, _, source_hash, apk_hash = self._public_fixture(launcher)
            (source / "game/project.godot").write_text("modified source")
            with patch.object(kit, "SOURCE_MANIFEST_SHA256", source_hash), \
                 patch.object(kit, "PUBLIC_APK_SHA256", apk_hash), patch.object(kit, "fetch") as fetch:
                with self.assertRaisesRegex(ValueError, "Fuente Android no válida"):
                    kit.prepare(launcher)
            fetch.assert_not_called()

    def test_public_missing_audited_hash_fails_before_any_download(self):
        with tempfile.TemporaryDirectory() as temporary, patch.object(kit, "PUBLIC_APK_SHA256", "PENDING"), \
             patch.object(kit, "fetch") as fetch:
            with self.assertRaisesRegex(ValueError, "SHA-256 auditado"):
                kit.prepare(Path(temporary))
            fetch.assert_not_called()


if __name__ == "__main__":
    unittest.main()
