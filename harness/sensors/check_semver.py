#!/usr/bin/env python3
"""Valida versão semântica no pyproject.toml ou package.json."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

SEMVER = re.compile(r"^\d+\.\d+\.\d+([.-][0-9A-Za-z.-]+)?$")


def read_pyproject(path: Path) -> str | None:
    text = path.read_text(encoding="utf-8")
    match = re.search(r'^version\s*=\s*"([^"]+)"', text, re.M)
    return match.group(1) if match else None


def read_package_json(path: Path) -> str | None:
    data = json.loads(path.read_text(encoding="utf-8"))
    return data.get("version")


def main() -> int:
    root = Path.cwd()
    version = None
    if (root / "pyproject.toml").exists():
        version = read_pyproject(root / "pyproject.toml")
    elif (root / "package.json").exists():
        version = read_package_json(root / "package.json")
    else:
        print("FAIL: no pyproject.toml or package.json in cwd")
        return 1

    if not version or not SEMVER.match(version):
        print(
            f"FAIL: version '{version}' is not semantic. "
            "Use MAJOR.MINOR.PATCH (optional pre-release)."
        )
        return 1

    print(f"OK: semantic version {version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
