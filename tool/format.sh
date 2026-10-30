#!/usr/bin/env bash
# Formate le code Dart (équivalent Prettier pour Flutter).
set -euo pipefail
cd "$(dirname "$0")/.."
dart format lib test
