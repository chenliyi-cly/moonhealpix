#!/usr/bin/env python3
"""Require the exact tested MoonBit toolchain recorded in moonbit-toolchain.json."""
import argparse
import json
import re
import subprocess
from pathlib import Path
from typing import Dict

LOCK = Path(__file__).with_name("moonbit-toolchain.json")


def parse_versions(output: str) -> Dict[str, str]:
    patterns = {
        "moon": r"(?m)^moon ([^\s]+)",
        "moonc": r"(?m)^moonc v([^\s]+)",
        "moonrun": r"(?m)^moonrun ([^\s]+)",
    }
    return {name: match.group(1) for name, pattern in patterns.items()
            if (match := re.search(pattern, output))}


def installer_version(versions: Dict[str, str]) -> str:
    # Official binary/core archives use the compiler release, not the moon CLI date.
    return versions["moonc"]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--installer-version", action="store_true",
                        help="print the official compiler archive version without running moon")
    args = parser.parse_args()
    expected = json.loads(LOCK.read_text(encoding="utf-8"))
    if args.installer_version:
        print(installer_version(expected))
        return 0
    output = subprocess.check_output(["moon", "version", "--all"], text=True)
    print(output, end="")
    actual = parse_versions(output)
    failures = [f"{name}: expected {value}, got {actual.get(name, 'missing')}"
                for name, value in expected.items() if actual.get(name) != value]
    if failures:
        raise SystemExit("MoonBit toolchain mismatch:\n" + "\n".join(failures))
    print(f"Verified exact MoonBit toolchain from {LOCK.name}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
