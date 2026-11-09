#!/usr/bin/env python3
"""Print actual toolchain versions and enforce the declared minimum compiler."""
import re
import subprocess

output = subprocess.check_output(["moon", "version", "--all"], text=True)
print(output, end="")
match = re.search(r"moonc v(\d+)\.(\d+)\.(\d+)", output)
if not match or tuple(map(int, match.groups())) < (0, 10, 16):
    raise SystemExit("moonc >= 0.10.16 is required")
