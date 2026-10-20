"""Synthetic checks only: no original game resources embedded here."""
import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import unittest
from unittest.mock import patch

from pocx.archive import Archive
from pocx.import_games import import_games, locate


class ImportTests(unittest.TestCase):
    def _synthetic_import(self, root, game, output, base=None):
        from pocx.__main__ import GAMES, STARTER_TABLES
        installation = root / (game + "-source")
        installation.mkdir(exist_ok=True)
        names = {}
        for name in ("Data.dat", "Voice.dat", "Region.dat", STARTER_TABLES[game][0]):
            path = installation / name
            path.write_bytes(b"synthetic")
            names[name.lower()] = path

        def converted(src, destination):
            for name, contents in {
                "inventory.json": {"games": {game: {}}, "master": game, "card_pools": {}, "cards_total": 1, "cards_with_art": 1},
                "voice_manifest.json": {"games": {game: {"languages": ["e"], "default": "e", "sources": []}}},
                "color_keys.json": {},
                "common/db/cards.json": [game],
                f"{game}/file/starter_deck.json": {"main": [1]},
            }.items():
                path = destination / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(json.dumps(contents))

        def audio(src, destination, games):
            (destination / "common/audio_native.json").write_text(json.dumps({game: 100}))

        with patch("pocx.import_games.unpack", return_value=installation), \
             patch("pocx.import_games.installation", return_value=names), \
             patch("pocx.import_games.extract", side_effect=converted), \
             patch("pocx.import_games.export_audio", side_effect=audio):
            import_games({game: installation}, output, base=base)

    def test_each_game_can_be_imported_alone(self):
        for game in ("yugi", "kaiba", "joey"):
            with self.subTest(game=game), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                output = root / "data"
                self._synthetic_import(root, game, output)
                self.assertEqual(set(json.loads((output / "inventory.json").read_text())["games"]), {game})

    def test_adding_games_preserves_base_and_uses_newest_shared_resources(self):
        for first, second in (("yugi", "joey"), ("joey", "yugi")):
            with self.subTest(first=first), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                base, output = root / "base", root / "combined"
                self._synthetic_import(root, first, base)
                before = {p.relative_to(base): p.read_bytes() for p in base.rglob("*") if p.is_file()}
                self._synthetic_import(root, second, output, base=base)
                self.assertEqual(before, {p.relative_to(base): p.read_bytes() for p in base.rglob("*") if p.is_file()})
                self.assertEqual(json.loads((output / "common/db/cards.json").read_text()), ["joey"])
                self.assertEqual(set(json.loads((output / "inventory.json").read_text())["games"]), {first, second})
                self.assertEqual(set(json.loads((output / "common/audio_native.json").read_text())), {first, second})

    def test_empty_selection_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "al menos un juego"):
                import_games({}, Path(directory) / "data")

    def test_existing_game_is_not_replaced(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self._synthetic_import(root, "yugi", root / "base")
            with self.assertRaisesRegex(ValueError, "ya está preparado"):
                self._synthetic_import(root, "yugi", root / "new", base=root / "base")
            self.assertFalse((root / "new").exists())

    def test_voice_pack_can_be_added_without_reimporting_game(self):
        from test_media_import import archive
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self._synthetic_import(root, "joey", root / "base")
            voice = root / "Spanish.dat"
            archive(voice, {"joey/spanish/internal/attack.wav": b"synthetic sample"})
            before = (root / "base/voice_manifest.json").read_bytes()
            import_games({}, root / "new", [("joey", voice)], base=root / "base")
            pack = json.loads((root / "new/voice_manifest.json").read_text())["games"]["joey"]
            self.assertEqual(pack["languages"], ["e", "s"])
            self.assertEqual((root / "base/voice_manifest.json").read_bytes(), before)

    def test_wrong_or_missing_game_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "encontradas: 0"):
                locate(Path(directory), "yugi")

    def test_archive_cannot_escape_destination(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Data.dat"
            name = b"../outside.bmp"
            encoded = bytes(((c << 4) | (c >> 4)) & 255 for c in name)
            path.write_bytes(b"KCEJYUGI\0"[:8] + struct.pack("<I", 1)
                             + encoded.ljust(256, b"\0") + struct.pack("<III", 280, 0, 0))
            with self.assertRaisesRegex(ValueError, "Ruta no segura"):
                Archive(path)

    def test_truncated_archive_releases_input(self):
        for raw in (b"KCEJYUGI", b"KCEJYUGI" + struct.pack("<I", 10)):
            with self.subTest(raw=raw), tempfile.TemporaryDirectory() as directory:
                path = Path(directory) / "Data.dat"
                path.write_bytes(raw)
                with self.assertRaises(ValueError):
                    Archive(path)
                # Windows refuses this rename when the reader leaks its open handle.
                path.rename(path.with_suffix(".moved"))

    def test_archive_resource_offsets_are_bounded(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Data.dat"
            path.write_bytes(b"KCEJYUGI" + struct.pack("<I", 1)
                             + b"\0" * 256 + struct.pack("<III", 280, 1024, 1024))
            with self.assertRaisesRegex(ValueError, "límites"):
                Archive(path)

    def test_existing_output_is_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "data"
            output.mkdir()
            marker = output / "personal"
            marker.write_text("keep")
            with self.assertRaisesRegex(ValueError, "ya existe"):
                import_games({}, output)
            self.assertEqual(marker.read_text(), "keep")

    def test_failed_import_removes_only_staging(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "data"
            with patch("pocx.import_games.unpack", side_effect=ValueError("bad media")):
                with self.assertRaisesRegex(ValueError, "bad media"):
                    import_games({"yugi": Path(directory)}, output)
            self.assertFalse(output.exists())
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_public_allowlist_excludes_private_material(self):
        path = Path(__file__).resolve().parents[1] / "prepare_public.py"
        spec = importlib.util.spec_from_file_location("prepare_public", path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        for name in ("data/common/audio_native.json", "game/assets/backgrounds/art.png",
                     "game/tests/fixtures/native.json", ".git/config", "re/out/source.c",
                     "game/scenarios/duel.json", "saves/system.json", "tools/pocx/private.bin"):
            self.assertFalse(module.allowed(Path(name)), name)
        for name in ("game/project.godot", "game/scenes/title/yugi_title_puzzle.gdshader",
                     "game/scenes/launcher/content_setup.gd", "tools/pocx/import_games.py",
                     "game/assets/music/launcher_theme.mp3", "game/assets/backgrounds/yugi_duel.jpg",
                     "game/assets/backgrounds/joey_duel.png"):
            self.assertTrue(module.allowed(Path(name)), name)


if __name__ == "__main__":
    unittest.main()
