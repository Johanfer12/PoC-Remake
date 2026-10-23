"""Exercise the actual Windows helper with harmless generated test executables."""
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import time
import unittest
import os

ROOT = Path(__file__).resolve().parents[2]
SHELL = str(Path(os.environ.get("SystemRoot", "C:/Windows")) / "System32/WindowsPowerShell/v1.0/powershell.exe")


@unittest.skipUnless(os.name == "nt", "Windows replacement helper")
class UpdaterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="poc-update-test-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name) / "Carpeta con espacios & apóstrofo '"
        self.base.mkdir()
        self.updates = self.base / "PoC Data" / "updates"
        self.updates.mkdir(parents=True)
        self.target = self.base / "PowerOfChaos.exe"
        self.source = self.updates / "PowerOfChaos.download"
        self.script = self.updates / "apply-update.ps1"
        self.script.write_text((ROOT / "game/core/update_helper.gd").read_text(encoding="utf-8").split('"""')[1], encoding="utf-8-sig")
        (self.base / "PoC Data" / "preserve.txt").write_text("resources and saves")

    def compile_stub(self, destination, marker):
        code = 'public class Program { public static void Main() { System.IO.File.WriteAllText(System.IO.Path.Combine(System.AppDomain.CurrentDomain.BaseDirectory, "started.txt"), "' + marker + '"); } }'
        config = self.base / "compile.json"
        config.write_text(json.dumps({"code": code, "output": str(destination)}), encoding="utf-8")
        compiler = self.base / "compile.ps1"
        compiler.write_text("$c = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'compile.json') -Raw -Encoding UTF8 | ConvertFrom-Json\nAdd-Type -TypeDefinition $c.code -OutputAssembly $c.output -OutputType ConsoleApplication -ErrorAction Stop", encoding="utf-8-sig")
        result = subprocess.run([SHELL, "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", str(compiler)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def apply(self, digest=None):
        settings = {"pid": 999999999, "target": self.target.as_posix(), "source": self.source.as_posix(),
                    "sha256": digest or hashlib.sha256(self.source.read_bytes()).hexdigest()}
        (self.updates / "update.json").write_text(json.dumps(settings), encoding="utf-8")
        result = subprocess.run([SHELL, "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", str(self.script)], capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.base / "PoC Data" / "preserve.txt").read_text(), "resources and saves")

    def marker(self):
        path = self.base / "started.txt"
        for _ in range(50):
            if path.exists():
                return path.read_text()
            time.sleep(.1)
        self.fail("replacement executable did not start")

    def test_replace_and_restart_preserving_storage(self):
        self.target.write_bytes(b"old executable")
        new = self.base / "new.exe"
        self.compile_stub(new, "new")
        self.source.write_bytes(new.read_bytes())
        self.apply()
        self.assertEqual(self.target.read_bytes(), new.read_bytes())
        self.assertEqual(self.marker(), "new")
        self.assertFalse(Path(str(self.target) + ".update-backup").exists())
        self.assertFalse(self.source.exists())
        self.assertFalse(self.script.exists())

    def test_checksum_failure_never_replaces_executable(self):
        self.target.write_bytes(b"original")
        self.source.write_bytes(b"corrupt download")
        self.apply("0" * 64)
        self.assertEqual(self.target.read_bytes(), b"original")
        self.assertIn("SHA-256 mismatch", (self.updates / "last-update.log").read_text(encoding="utf-8-sig"))

    def test_failed_launch_rolls_back_and_restarts_old_version(self):
        self.compile_stub(self.target, "old")
        original = self.target.read_bytes()
        self.source.write_bytes(b"not a Windows executable")
        self.apply()
        self.assertEqual(self.target.read_bytes(), original)
        self.assertEqual(self.marker(), "old")


if __name__ == "__main__":
    unittest.main()
