#!/usr/bin/env python3
"""Verify the exact MoonBit release pinned by CI and its compiler version."""
import re
import subprocess

EXPECTED_MOON = "0.1.20261119"
EXPECTED_COMPILER = (0, 10, 22)
output = subprocess.check_output(["moon", "version", "--all"], text=True)
print(output, end="")
moon = re.search(r"(?m)^moon (\S+)", output)
compiler = re.search(r"(?m)^moonc v(\d+)\.(\d+)\.(\d+)", output)
if not moon or moon.group(1) != EXPECTED_MOON:
    raise SystemExit(f"Moon CLI {EXPECTED_MOON} is required")
if not compiler or tuple(map(int, compiler.groups())) != EXPECTED_COMPILER:
    raise SystemExit("moonc 0.10.22 (from the pinned MoonBit release) is required")
