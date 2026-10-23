"""Safety and offline reuse contracts for the launcher-managed Android kit."""
import hashlib
import io
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
                kit.prepare(Path(temporary))
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
                config = kit.prepare(launcher)
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
                    kit.prepare(launcher)
                network.assert_not_called()
                execute.assert_not_called()
            key.write_bytes(b"replacement key")
            with patch.object(kit.subprocess, "run") as execute:
                execute.return_value.stdout = b"a different certificate"
                with self.assertRaisesRegex(ValueError, "firma Android cambió"):
                    kit.prepare(launcher)


if __name__ == "__main__":
    unittest.main()
