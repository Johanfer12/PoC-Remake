"""A shared PC edit must not silently leave the bundled Android source stale."""
import json
from pathlib import Path
import tempfile
import unittest
from check_android_sync import audit, source_files


class AndroidSyncTests(unittest.TestCase):
    def test_shared_change_and_new_file_require_review(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'game').mkdir()
            (root / 'docs').mkdir()
            script = root / 'game/rules.gd'
            script.write_text('extends Node\n', encoding='utf-8')
            files = {name: {'pc_sha256': value, 'review': 'shared'}
                     for name, value in source_files(root).items()}
            (root / 'docs/ANDROID_SYNC.json').write_text(json.dumps({'files': files}), encoding='utf-8')
            audit(root)
            script.write_text('extends Node\nvar changed = true\n', encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'Review and port'):
                audit(root)
            script.write_text('extends Node\n', encoding='utf-8')
            (root / 'game/new_shared.gd').write_text('extends Node\n', encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'new_shared.gd'):
                audit(root)

    def test_release_number_and_windows_only_code_do_not_require_port(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'game').mkdir()
            (root / 'docs').mkdir()
            project = root / 'game/project.godot'
            project.write_text('config/version="0.1.0-alpha.16"\n', encoding='utf-8')
            windows = root / 'game/windows_only.gd'
            windows.write_text('extends Node\n', encoding='utf-8')
            files = {name: {'pc_sha256': value, 'review': 'android-adapted' if name.endswith('.godot') else 'desktop-only'}
                     for name, value in source_files(root).items()}
            (root / 'docs/ANDROID_SYNC.json').write_text(json.dumps({'files': files}), encoding='utf-8')
            project.write_text('config/version="0.1.0-alpha.17"\n', encoding='utf-8')
            windows.write_text('extends Node\nvar windows_change = true\n', encoding='utf-8')
            audit(root)
