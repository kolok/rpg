#!/usr/bin/env python3
"""Vérifie que la couverture de lib/ atteint le seuil demandé."""

from __future__ import annotations

import sys
from pathlib import Path

SEUIL = 95.0
# Point d'entrée Flutter : testé indirectement via ApplicationRpg.
EXCLUS = frozenset({'lib/main.dart'})


def couverture(lcov: Path) -> tuple[float, int, int]:
    text = lcov.read_text(encoding='utf-8')
    current: str | None = None
    hit = miss = 0

    for line in text.splitlines():
        if line.startswith('SF:'):
            current = line[3:]
            continue
        if not line.startswith('DA:') or current is None:
            continue
        if current in EXCLUS:
            continue
        _, rest = line.split(':', 1)
        count = int(rest.split(',')[1])
        if count > 0:
            hit += 1
        else:
            miss += 1

    total = hit + miss
    pct = 100.0 * hit / total if total else 100.0
    return pct, hit, total


def main() -> int:
    lcov = Path('coverage/lcov.info')
    if not lcov.is_file():
        print('Fichier coverage/lcov.info introuvable.', file=sys.stderr)
        return 1

    pct, hit, total = couverture(lcov)
    print(f'Couverture lib/ (hors {", ".join(sorted(EXCLUS))}) : '
          f'{pct:.1f}% ({hit}/{total})')

    if pct < SEUIL:
        print(f'Seuil non atteint : {SEUIL}% requis.', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
