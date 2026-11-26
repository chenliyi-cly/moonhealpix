import unittest

from check_version import parse_versions


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

    def test_missing_component_is_not_fabricated(self):
        self.assertEqual(parse_versions("moon 0.1.20261119\n"), {
            "moon": "0.1.20261119",
        })


if __name__ == "__main__":
    unittest.main()
