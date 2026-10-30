---
name: flutter-rpg-conventions
description: Conventions de développement pour l'app Flutter RPG (fiches, bibliothèque, coulisses). À lire avant toute modification dans lib/ ou test/.
---

# Conventions — RPG (Flutter)

## État et persistance

- Source de vérité : `Bibliotheque` (`lib/modeles/bibliotheque.dart`), injectée via `BibliothequeScope` dans `ApplicationRpg`.
- Mutations partie ouverte : `bibliotheque.modifier(() { ... })`.
- Mutations coulisses : `bibliotheque.modifierCoulisses(() { ... })`.
- Ne pas écrire directement dans `SharedPreferences` depuis les écrans.

## Structure des fichiers

- **modeles/** : classes de données + `versJson` / `depuisJson`, migrations d’anciens formats.
- **ecrans/** : `Scaffold`, navigation, branchement sur `BibliothequeScope`.
- **widgets/** : composants réutilisables sans logique de persistance lourde.

## UI

- Thème : `themeClair()` / `themeSombre()` dans `lib/theme.dart`.
- Textes utilisateur en **français**.
- Actions destructives : `ZoneDeDanger` + dialogue de confirmation (`confirmerSuppression` dans `champs.dart`).

## Nouvelle fonctionnalité — checklist

1. Implémenter en respectant l’architecture existante (pas de nouveau state management sans accord).
2. `./tool/quality.sh` doit passer (format, analyze, tests, couverture ≥ 95 %).
3. Si le schéma JSON change : test de reprise + migration dans `depuisJson` ou `_lire`.

## Anti-patterns

- Dupliquer la logique de sauvegarde hors de `Bibliotheque`.
- Widgets monolithiques de plusieurs centaines de lignes sans extraire vers `widgets/`.
- Tests qui tapent des boutons en bas de la page d’accueil sans `scrollUntilVisible`.
