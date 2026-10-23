"""Portable import transactions and compressed-resource contracts; synthetic media only."""
import json
from pathlib import Path
import tempfile
import unittest
import numpy as np
from PIL import Image
import soundfile as sf
from pocx.compact import optimize_tree
from pocx.import_games import import_games, ImportFailure
from pocx.voices import export_voice
from test_media_import import archive


class CompactImportTests(unittest.TestCase):
    def library(self, root):
        root.mkdir()
        (root / "inventory.json").write_text(json.dumps({"games": {"yugi": {}}, "master": "yugi"}))
        return root

    def test_webp_preserves_rgba_including_invisible_pixels(self):
        with tempfile.TemporaryDirectory() as folder:
            root = self.library(Path(folder) / "resources")
            rgba = Image.new("RGBA", (256, 256), (67, 27, 98, 0))
            for y in range(30, 220):
                for x in range(50, 200):
                    rgba.putpixel((x, y), (210, 150, 40, 127))
            rgba.save(root / "image.png")
            optimize_tree(root)
            self.assertFalse((root / "image.png").exists())
            self.assertEqual(Image.open(root / "image.webp").convert("RGBA").tobytes(), rgba.tobytes())

    def test_ogg_timing_channels_and_short_effects(self):
        with tempfile.TemporaryDirectory() as folder:
            root = self.library(Path(folder) / "resources")
            samples = (np.sin(np.arange(48000) * 0.11) * 0.4).astype("float32")
            sf.write(root / "voice.wav", np.column_stack([samples, samples * 0.5]), 16000, subtype="PCM_16")
            sf.write(root / "click.wav", samples[:1000], 16000, subtype="PCM_16")
            original = (root / "click.wav").read_bytes()
            report = optimize_tree(root)
            ogg = sf.info(root / "voice.ogg")
            self.assertEqual((ogg.frames, ogg.samplerate, ogg.channels), (48000, 16000, 2))
            self.assertEqual((root / "click.wav").read_bytes(), original)
            self.assertLess(report["output_bytes"], report["source_bytes"])

    def test_failed_compaction_preserves_existing_library(self):
        with tempfile.TemporaryDirectory() as folder:
            root = self.library(Path(folder) / "resources")
            (root / "broken.png").write_bytes(b"invalid PNG")
            before = {p.name: p.read_bytes() for p in root.iterdir()}
            with self.assertRaises(ImportFailure) as caught:
                import_games({}, root, base=root, compact=True, replace=True)
            self.assertEqual(caught.exception.stage, "compact")
            self.assertIsNone(caught.exception.game)
            self.assertEqual({p.name: p.read_bytes() for p in root.iterdir()}, before)
            self.assertEqual(list(Path(folder).glob(".poc-*")), [])

    def test_in_place_update_removes_stale_alternative_and_old_copies(self):
        with tempfile.TemporaryDirectory() as folder:
            root = self.library(Path(folder) / "resources")
            Image.new("RGBA", (256, 256), "red").save(root / "image.webp", lossless=True)
            Image.new("RGBA", (256, 256), "blue").save(root / "image.png")
            import_games({}, root, base=root, compact=True, replace=True)
            self.assertFalse((root / "image.png").exists())
            self.assertEqual(Image.open(root / "image.webp").convert("RGBA").getpixel((0, 0)), (0, 0, 255, 255))
            self.assertEqual(list(Path(folder).glob(".poc-*")), [])
            before = (root / "image.webp").read_bytes()
            import_games({}, root, base=root, compact=True, replace=True)
            self.assertEqual((root / "image.webp").read_bytes(), before)

    def test_voice_identity_survives_compression(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder); root = self.library(base / "resources")
            wav = base / "voice.wav"
            sf.write(wav, np.sin(np.arange(48000)*0.2)*0.3, 16000, subtype="PCM_16")
            pack = base / "Voice.dat"
            archive(pack, {"yugi/english/internal/line.wav": wav.read_bytes()})
            manifest = {}
            self.assertEqual(export_voice(pack, root, "yugi", manifest), 1)
            optimize_tree(root)
            self.assertEqual(export_voice(pack, root, "yugi", manifest), 0)
            sf.write(wav, np.zeros(48000), 16000, subtype="PCM_16")
            archive(pack, {"yugi/english/internal/line.wav": wav.read_bytes()})
            with self.assertRaisesRegex(ValueError, "dos paquetes"):
                export_voice(pack, root, "yugi", manifest)


if __name__ == "__main__":
    unittest.main()
