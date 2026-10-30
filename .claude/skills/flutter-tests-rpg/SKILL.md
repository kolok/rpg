---
name: flutter-tests-rpg
description: Écrire et maintenir les tests Flutter (unitaires et widgets) pour RPG — mocks SharedPreferences, parcours UI, couverture 95 %.
---

# Tests — RPG (Flutter)

## Lancer

```bash
flutter test
flutter test --coverage && python3 tool/check_coverage.py
flutter test test/parcours_test.dart   # un fichier
```

Seuil : **≥ 95 %** lignes sur `lib/`, **`lib/main.dart` exclu** (`tool/check_coverage.py`).

## Setup standard

```dart
setUp(() => SharedPreferences.setMockInitialValues({}));
```

Application under test :

```dart
final bibliotheque = await Bibliotheque.charger();
await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
await tester.pumpAndSettle();
```

## Widget tests — viewport et scroll

```dart
tester.view.physicalSize = const Size(420, 900);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.reset);
```

Page d’accueil (boutons en bas) :

```dart
final scrollable = find.descendant(
  of: find.byType(ListView),
  matching: find.byType(Scrollable),
).first;
await tester.scrollUntilVisible(find.text('Démarrer la partie'), 120, scrollable: scrollable);
```

Fiches (`ListView`) : boucle de drag vers le haut jusqu’à ce que le finder soit présent, puis `ensureVisible`.

## Où placer les tests

| Sujet | Fichier suggéré |
|-------|-----------------|
| Modèle / JSON | `test/widget_test.dart`, `test/coulisses_test.dart`, `test/bibliotheque_*` |
| Parcours utilisateur | `test/parcours_test.dart`, `test/parcours_coulisses_test.dart` |
| Cas UI complémentaires | `test/couverture_etendue_test.dart` |

## Captures boutique

`test/captures_boutique_test.dart` — ne s’exécute que si :

```bash
GENERER_CAPTURES=1 flutter test test/captures_boutique_test.dart
```

## Avant merge

Toujours exécuter `./tool/quality.sh` avec la nouvelle fonctionnalité.
