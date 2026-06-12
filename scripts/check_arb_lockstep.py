#!/usr/bin/env python3
"""Verify that app_en.arb and app_es.arb have identical key sets.

Exits with code 1 and prints the diff if they diverge.
Run in CI after flutter analyze to catch missing translations early.
"""
from __future__ import annotations
import json
import sys
from pathlib import Path


def load_keys(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k for k in data if not k.startswith("@")}


def main() -> None:
    root = Path(__file__).parent.parent
    en_path = root / "lib" / "l10n" / "app_en.arb"
    es_path = root / "lib" / "l10n" / "app_es.arb"

    en_keys = load_keys(en_path)
    es_keys = load_keys(es_path)

    only_en = sorted(en_keys - es_keys)
    only_es = sorted(es_keys - en_keys)

    if only_en or only_es:
        if only_en:
            print(f"Keys in app_en.arb but NOT in app_es.arb ({len(only_en)}):")
            for k in only_en:
                print(f"  - {k}")
        if only_es:
            print(f"Keys in app_es.arb but NOT in app_en.arb ({len(only_es)}):")
            for k in only_es:
                print(f"  - {k}")
        sys.exit(1)

    print(f"OK — both ARBs have {len(en_keys)} keys in lockstep.")


if __name__ == "__main__":
    main()
