# Guide pour agents et développeurs — RPG

Application **Flutter** hors ligne : fiches de personnages, coulisses (classes réutilisables), espace meneur de jeu (monstres), lancer de dés. Données persistées via **SharedPreferences** (JSON).

Documentation produit détaillée : [README.md](README.md).

## Stack

| Élément | Détail |
|--------|--------|
| SDK | Dart ^3.12 (`pubspec.yaml`) |
| UI | Material 3, thèmes clair/sombre (`lib/theme.dart`) |
| Persistance | `shared_preferences` |
| Tests | `flutter_test`, couverture `lcov`, seuil **≥ 95 %** sur `lib/` (hors `lib/main.dart`) |
| CI | [.github/workflows/ci.yml](.github/workflows/ci.yml) |
| Linter | `flutter_lints` via [analysis_options.yaml](analysis_options.yaml) |
| Formatage | **`dart format`** (équivalent Prettier pour Dart ; pas de Prettier sur ce dépôt) |

## Architecture actuelle

Le projet n’utilise pas encore une stack MVVM complète : l’état métier vit dans des **modèles mutables** et une **`Bibliotheque`** (`ChangeNotifier`).

```
lib/
  main.dart              → ApplicationRpg + BibliothequeScope
  theme.dart
  modeles/               → personnage, partie, bibliotheque, competence, etc.
  ecrans/                → un fichier ≈ un écran ou flux navigation
  widgets/               → champs réutilisables, compétences, formes de dés
```

- **`BibliothequeScope`** (`InheritedNotifier<Bibliotheque>`) : accès via `BibliothequeScope.de(context)`.
- **Sauvegarde** : `bibliotheque.modifier(...)` / `modifierCoulisses(...)` déclenchent persistance + `notifyListeners()`.
- **Navigation** : `MaterialPageRoute`, pas de routeur déclaratif.
- **Nommage** : français dans le code UI et les tests (aligné sur l’app).

Pour une **nouvelle fonctionnalité**, rester cohérent avec ce modèle sauf refactor explicite. Pour structurer un gros ajout ou une refonte, lire le skill [Architecture Flutter](.claude/skills/flutter-architecture/SKILL.md).

## Écrans (rappel)

1. Accueil — parties + coulisses  
2. Partie en cours — `TabBarView` héros / meneur  
3. Fiche personnage / monstre  
4. Coulisses + fiche classe  
5. Lancer de dés  

## Tests

| Type | Emplacement | Rôle |
|------|-------------|------|
| Modèles / bibliothèque | `test/*_test.dart`, `widget_test.dart` | JSON, migrations, règles métier |
| Parcours UI | `test/parcours_test.dart`, `parcours_coulisses_test.dart`, `couverture_etendue_test.dart` | `testWidgets`, `SharedPreferences.setMockInitialValues` |
| Captures Play Store | `test/captures_boutique_test.dart` | **Ignoré** sauf `GENERER_CAPTURES=1` |

Conventions widgets :

- Viewport téléphone : `420×900`, `devicePixelRatio: 1.0`.
- Page d’accueil scrollable : **`scrollUntilVisible`** avant de taper les boutons bas de liste (« Démarrer la partie », « Coulisses »).
- Fiches longues : helper `defilerJusqua` (drag sur le `Scrollable` de la `ListView`).

Détails : [Tests Flutter RPG](.claude/skills/flutter-tests-rpg/SKILL.md).

```bash
flutter test
flutter test --coverage && python3 tool/check_coverage.py
```

## Qualité — obligatoire à chaque nouvelle fonctionnalité

Avant de considérer une fonctionnalité terminée (commit / PR), **tout doit passer** :

1. **Formatage** — `dart format` (via `./tool/format.sh` ou `./tool/quality.sh`)
2. **Linter / analyse statique** — `flutter analyze`
3. **Tests + couverture** — `flutter test --coverage` puis `python3 tool/check_coverage.py`

Script tout-en-un :

```bash
./tool/quality.sh
```

La CI exécute les mêmes contrôles (format, analyze, tests, seuil de couverture).

## Bonnes pratiques (règles à suivre)

1. **Portée minimale** — un diff focalisé ; pas de refacto opportuniste.
2. **Conventions du dépôt** — mêmes patterns que les fichiers voisins (nommage français, widgets existants dans `lib/widgets/`).
3. **Pas de sur-ingénierie** — pas d’abstraction pour une seule utilisation ; pas de gestion d’erreurs pour des cas impossibles.
4. **Persistance** — toute mutation utilisateur passe par `Bibliotheque.modifier` / `modifierCoulisses` ; prévoir migration JSON si le schéma change (tests de reprise).
5. **UI** — réutiliser `SectionFiche`, `CompteurEntier`, `ListeTextes`, `ZoneDeDanger`, etc.
6. **Tests** — toute logique nouvelle ou branche métier : test unitaire ou widget ; viser de ne **pas** baisser la couverture sous 95 %.
7. **Commentaires** — seulement pour règles métier non évidentes ou contraintes techniques (scroll en test, migration).
8. **Secrets** — ne jamais committer `android/key.properties`, clés, `.env`.
9. **Commits** — uniquement si demandé ; messages en français clair, orientés « pourquoi ».

Pour le développement au quotidien sur ce repo : [Conventions Flutter RPG](.claude/skills/flutter-rpg-conventions/SKILL.md).

## Skills agent (`.claude/skills/`)

Lire le skill pertinent **avant** d’implémenter :

| Skill | Fichier | Quand l’utiliser |
|-------|---------|------------------|
| Conventions RPG | [.claude/skills/flutter-rpg-conventions/SKILL.md](.claude/skills/flutter-rpg-conventions/SKILL.md) | Toute modification dans `lib/` ou `test/` |
| Tests | [.claude/skills/flutter-tests-rpg/SKILL.md](.claude/skills/flutter-tests-rpg/SKILL.md) | Ajout / correction de tests, parcours UI |
| Architecture | [.claude/skills/flutter-architecture/SKILL.md](.claude/skills/flutter-architecture/SKILL.md) | Refactor, feature large, séparation UI / données |

## Commandes utiles

```bash
flutter pub get
flutter run
flutter analyze
dart format lib test
./tool/format.sh      # formate lib/ et test/
./tool/quality.sh     # format (vérif) + analyze + tests + couverture
flutter build appbundle --release
```

Publication Android : [store/fiche-play.md](store/fiche-play.md), keystore via `android/key.properties.example`.
