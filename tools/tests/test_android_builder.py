"""Contratos del puente Android: aislado, publicacion tras validar y fallos seguros."""
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from pocx.android_builder import configuration, create_apk


class AndroidBuilderTests(unittest.TestCase):
    def test_missing_kit_fails_before_import(self):
        with tempfile.TemporaryDirectory() as temporary, patch("pocx.import_games.import_games") as importer, \
             patch("pocx.android_builder.configuration", side_effect=ValueError("Falta el kit")):
            with self.assertRaisesRegex(ValueError, "Falta el kit"):
                create_apk({"yugi": Path("source.iso")}, Path(temporary))
            importer.assert_not_called()

    def test_relative_configuration(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            (root / "android-builder.json").write_text(json.dumps({"root": "kit/source"}))
            self.assertEqual(configuration(root)["root"], root / "kit/source")

    def _build(self, fail, first=False):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            original = root / "pc-resources"
            original.mkdir()
            (original / "inventory.json").write_text('{"games":{"yugi":{}}}')
            before = (original / "inventory.json").read_bytes()
            env_before = os.environ.get("JAVA_HOME")
            config = {key: root / key for key in ("root", "godot", "sdk", "java", "keystore", "previous")}

            if first:
                config.pop("previous")

            def build(*_args, **_kwargs):
                import sys
                args = sys.argv
                self.assertEqual("--first-build" in args, first)
                self.assertEqual("--previous-apk" in args, not first)
                apk = Path(args[args.index("--output") + 1])
                apk.write_bytes(b"validated-apk")
                self.assertFalse(list(root.glob("*.apk")))
                work = Path(args[args.index("--work") + 1])
                (work / "v18-validation/bundle-save").mkdir(parents=True)
                if fail:
                    raise RuntimeError("firma rechazada")
                work = Path(args[args.index("--work") + 1])
                (work / "project").mkdir(parents=True)
                (work / "v18-build-manifest.json").write_text('{"signature_verified":true}')

            with patch("pocx.android_builder.configuration", return_value=config), \
                 patch("pocx.android_builder.preflight"), \
                 patch("pocx.compact.optimize_tree"), \
                 patch("pocx.android_builder.runpy.run_path", side_effect=build):
                if fail:
                    with self.assertRaisesRegex(RuntimeError, "firma rechazada"):
                        create_apk({}, root, base=original)
                    self.assertFalse(list(root.glob("*.apk")))
                else:
                    output = create_apk({}, root, base=original)
                    self.assertEqual(output.parent, root / "PoC Data/android/apks")
                    self.assertEqual(output.read_bytes(), b"validated-apk")
                    self.assertTrue(output.with_suffix(".json").is_file())
            self.assertEqual((original / "inventory.json").read_bytes(), before)
            self.assertEqual(os.environ.get("JAVA_HOME"), env_before)
            self.assertFalse(list(root.rglob("project")))
            self.assertFalse(list(root.rglob("resources-*")))
            self.assertFalse(list(root.rglob("bundle-save")))

    def test_success_preserves_pc_and_cleans_generated_resources(self):
        self._build(False)

    def test_first_install_uses_own_key_without_previous_apk(self):
        self._build(False, first=True)

    def test_failure_does_not_publish_apk_or_change_pc(self):
        self._build(True)


if __name__ == "__main__":
    unittest.main()
