#!/usr/bin/env bash
# Contrôles qualité : format, linter, tests et couverture.
# À exécuter avant chaque commit / PR de fonctionnalité.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Dépendances =="
flutter pub get

echo "== Format (dart format, vérification) =="
dart format --output=none --set-exit-if-changed lib test

echo "== Analyse statique (flutter analyze) =="
flutter analyze

echo "== Tests + couverture =="
flutter test --coverage

echo "== Seuil de couverture (≥ 95 %) =="
python3 tool/check_coverage.py

echo "OK — format, linter, tests et couverture."
