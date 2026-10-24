"""Gate shared PC changes until their Android counterpart has been reviewed."""
from pathlib import Path
import hashlib
import json
import re
from prepare_public import allowed


def source_files(root: Path) -> dict[str, str]:
    result = {}
    for path in (root / 'game').rglob('*'):
        relative = path.relative_to(root)
        if not path.is_file() or 'assets' in relative.parts or not allowed(relative):
            continue
        data = path.read_bytes().replace(b'\r\n', b'\n')
        if relative.as_posix() == 'game/project.godot':
            data = re.sub(rb'config/version="[^"\n]+"', b'config/version="release"', data)
        result[relative.as_posix()] = hashlib.sha256(data).hexdigest()
    return result


def audit(root: Path) -> None:
    record = json.loads((root / 'docs/ANDROID_SYNC.json').read_text(encoding='utf-8'))
    expected = record['files']
    actual = source_files(root)
    changed = sorted(set(actual) ^ set(expected))
    changed += [name for name in actual.keys() & expected.keys()
                if expected[name]['review'] != 'desktop-only' and actual[name] != expected[name]['pc_sha256']]
    if changed:
        raise ValueError('Review and port shared changes to Android before release; update docs/ANDROID_SYNC.json: '
                         + ', '.join(changed))
    print('Android parity review: shared PC source hashes match the recorded Android integration.')


if __name__ == '__main__':
    audit(Path(__file__).resolve().parents[1])
