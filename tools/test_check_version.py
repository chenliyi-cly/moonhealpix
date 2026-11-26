import json
import subprocess
import sys
import unittest
from pathlib import Path

from check_version import installer_version, parse_versions


class CheckVersionTests(unittest.TestCase):
    def test_parses_all_expected_components(self):
        output = "\n".join([
            "moon 0.1.20261119 /opt/moon/bin/moon",
            "moonc v0.10.22+124d61d05 /opt/moon/bin/moonc",
            "moonrun 0.1.20261119 /opt/moon/bin/moonrun",
        ])
        self.assertEqual(parse_versions(output), {
            "moon": "0.1.20261119",
            "moonc": "0.10.22+124d61d05",
            "moonrun": "0.1.20261119",
        })

    def test_installer_uses_compiler_release_not_cli_date(self):
        self.assertEqual(installer_version({
            "moon": "0.1.20261119",
            "moonc": "0.10.22+124d61d05",
            "moonrun": "0.1.20261119",
        }), "0.10.22+124d61d05")

    def test_installer_does_not_fall_back_to_cli_date(self):
        with self.assertRaises(KeyError):
            installer_version({"moon": "0.1.20261119"})

    def test_installer_cli_outputs_only_locked_compiler_version(self):
        tool = Path(__file__).with_name("check_version.py")
        expected = json.loads(tool.with_name("moonbit-toolchain.json").read_text(encoding="utf-8"))
        output = subprocess.check_output(
            [sys.executable, str(tool), "--installer-version"], text=True)
        self.assertEqual(output, expected["moonc"] + "\n")

    def test_missing_component_is_not_fabricated(self):
        self.assertEqual(parse_versions("moon 0.1.20261119\n"), {
            "moon": "0.1.20261119",
        })


if __name__ == "__main__":
    unittest.main()
