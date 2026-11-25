#!/usr/bin/env python3
"""Verify the official stable MoonBit toolchain meets the tested compiler floor."""
import re
import subprocess

MIN_COMPILER = (0, 10, 22)
output = subprocess.check_output(["moon", "version", "--all"], text=True)
print(output, end="")
compiler = re.search(r"(?m)^moonc v(\d+)\.(\d+)\.(\d+)", output)
if not compiler:
    raise SystemExit("Could not determine moonc version")
actual = tuple(map(int, compiler.groups()))
if actual < MIN_COMPILER:
    required = ".".join(map(str, MIN_COMPILER))
    raise SystemExit(f"moonc >= {required} is required")
