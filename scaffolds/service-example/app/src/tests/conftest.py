"""Fixtures compartilhadas — evita pings reais na suíte local."""

import os

os.environ.setdefault("SKIP_DEPENDENCY_PINGS", "true")
