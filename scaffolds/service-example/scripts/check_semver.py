#!/usr/bin/env python3
"""Valida versão semântica no pyproject.toml."""

from __future__ import annotations

import re
import sys
from pathlib import Path

SEMVER = re.compile(r"^\d+\.\d+\.\d+([.-][0-9A-Za-z.-]+)?$")


def main() -> int:
    text = Path("pyproject.toml").read_text(encoding="utf-8")
    match = re.search(r'^version\s*=\s*"([^"]+)"', text, re.M)
    version = match.group(1) if match else None
    if not version or not SEMVER.match(version):
        print(f"FAIL: version '{version}' is not semantic (MAJOR.MINOR.PATCH).")
        return 1
    print(f"OK: semantic version {version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
