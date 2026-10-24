"""Contratos del puente Android: aislado, publicacion tras validar y fallos seguros."""
import json
import hashlib
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from pocx.android_builder import configuration, create_apk, preflight


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

    def test_public_configuration_keeps_hash_as_text(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            expected = "a" * 64
            (root / "android-builder.json").write_text(json.dumps({"public_apk": "official.apk", "public_apk_sha256": expected}))
            self.assertEqual(configuration(root)["public_apk_sha256"], expected)
            self.assertEqual(configuration(root)["public_apk"], root / "official.apk")

    def test_public_bad_apk_hash_fails_before_extracting_private_games(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "tools/android").mkdir(parents=True)
            (root / "tools/android/build_apk.py").touch()
            (root / "game").mkdir()
            (root / "game/project.godot").touch()
            (root / "godot.exe").touch()
            (root / "public.apk").write_bytes(b"tampered APK")
            config = dict(root=root, godot=root / "godot.exe", public_apk=root / "public.apk", public_apk_sha256="0" * 64)
            with patch("pocx.android_builder.configuration", return_value=config), \
                 patch("pocx.import_games.import_games") as importer:
                with self.assertRaisesRegex(ValueError, "SHA-256"):
                    create_apk({"yugi": root / "private.iso"}, root)
                importer.assert_not_called()
            self.assertFalse((root / "PoC Data/android/builds").exists())

    def _public_build(self, failure=None):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            original = root / "pc-resources"
            original.mkdir()
            original_text = '{"games":{"yugi":{}}}'
            (original / "inventory.json").write_text(original_text)
            apk = root / "official.apk"
            apk.write_bytes(b"official stable signed APK, unchanged")
            config = dict(root=root / "source", godot=root / "godot.exe", public_apk=apk,
                          public_apk_sha256=hashlib.sha256(apk.read_bytes()).hexdigest())
            (config["root"] / "tools/android").mkdir(parents=True)
            (config["root"] / "tools/android/build_apk.py").touch()
            (config["root"] / "game").mkdir()
            (config["root"] / "game/project.godot").touch()
            config["godot"].touch()
            preflight(config)  # No SDK, Java, signing key or license exists.
            outputs = root / "PoC Data/android/apks"
            outputs.mkdir(parents=True)
            old_apk = outputs / "existing-personal.apk"
            old_apk.write_bytes(b"preserve earlier private build")
            key = root / "PoC Data/android/signing/debug.keystore"
            key.parent.mkdir()
            key.write_bytes(b"preserve personal signing key")
            content = b"synthetic validated private PCK"

            def build(*_args, **_kwargs):
                import sys
                args = sys.argv
                self.assertIn("--content-only", args)
                self.assertNotIn("--debug-keystore", args)
                self.assertNotIn("--sdk", args)
                target = Path(args[args.index("--content-output") + 1])
                target.write_bytes(content)
                work = Path(args[args.index("--work") + 1])
                work.mkdir()
                self.assertEqual(list(outputs.iterdir()), [old_apk])
                if failure == "build":
                    raise RuntimeError("packing failed")
                report = {"content_pack": str(target), "sha256": hashlib.sha256(content).hexdigest()}
                if failure == "hash":
                    report["sha256"] = "0" * 64
                (work / "content-build-manifest.json").write_text(json.dumps(report))

            before_env = dict(os.environ)
            real_rename = Path.rename
            def rename(source, target):
                if failure == "publish" and source.suffix == ".apk":
                    raise OSError("APK destination unavailable")
                return real_rename(source, target)

            with patch("pocx.android_builder.configuration", return_value=config), \
                 patch("pocx.compact.optimize_tree"), \
                 patch("pocx.android_builder.runpy.run_path", side_effect=build), \
                 patch.object(Path, "rename", rename):
                if failure:
                    with self.assertRaises((RuntimeError, ValueError, OSError)):
                        create_apk({}, root, base=original)
                    self.assertEqual(list(outputs.iterdir()), [old_apk])
                else:
                    target = create_apk({}, root, base=original)
                    self.assertEqual(target.read_bytes(), apk.read_bytes())
                    report = json.loads(target.with_suffix(".json").read_text())
                    self.assertEqual(Path(report["content_pack"]).read_bytes(), content)
                    self.assertEqual(report["apk_sha256"], config["public_apk_sha256"])
                    self.assertTrue(report["public_apk_unchanged"])
                    self.assertFalse(report["apk_original_game_data_included"])
            self.assertEqual(dict(os.environ), before_env)
            self.assertEqual((original / "inventory.json").read_text(), original_text)
            self.assertEqual(key.read_bytes(), b"preserve personal signing key")
            self.assertEqual(old_apk.read_bytes(), b"preserve earlier private build")
            self.assertFalse(list(root.rglob("resources-*")))

    def test_public_pair_preserves_official_apk_hash_and_personal_key(self):
        self._public_build()

    def test_public_pack_failure_publishes_neither_file(self):
        self._public_build("build")

    def test_public_pack_bad_hash_publishes_neither_file(self):
        self._public_build("hash")

    def test_public_pair_publication_failure_rolls_back_both_files(self):
        self._public_build("publish")

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
