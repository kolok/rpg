---
name: flutter-architecture
description: Bonnes pratiques d'architecture Flutter (couches UI / logique / données). Pour RPG, à adapter au modèle Bibliotheque actuel ou pour refactor progressif.
---

# Architecture Flutter — bonnes pratiques

## Principes

1. **Séparation des responsabilités** — UI ne parle pas directement à la persistance brute ; logique métier testable hors widgets.
2. **Single source of truth** — une couche (ici `Bibliotheque`) orchestre lectures/écritures.
3. **Tests** — logique dans des classes testables sans `BuildContext` quand c’est possible.

## État actuel de RPG

- **Proche « data + UI »** : modèles mutables + `Bibliotheque` (ChangeNotifier) + écrans qui appellent `modifier`.
- **Pas de ViewModels séparés** par écran : acceptable pour la taille actuelle ; éviter d’ajouter Provider/Riverpod/bloc sans besoin.

## Évolution recommandée (si la app grossit)

| Besoin | Piste |
|--------|--------|
| Logique complexe sur une fiche | Extraire des méthodes sur `Personnage` / `Partie` ou un petit service dans `modeles/` |
| Plusieurs sources de données | Repository au-dessus de `SharedPreferences` |
| Écrans très chargés | Sous-widgets + éventuellement ViewModel `Listenable` par feature |

## Structure cible (feature-first, optionnelle)

```
lib/
  modeles/          # domaine + JSON (existant)
  data/             # futur : wrappers persistance
  ecrans/           # views (existant)
  widgets/          # composants (existant)
```

Refactor **incrémental** : ne pas réécrire toute l’app pour coller à MVVM d’un coup.

## Nouvelle feature (workflow)

1. Clarifier données (modèle / champs JSON).
2. Étendre `Bibliotheque` si persistance ou règles transverses.
3. Écran + widgets réutilisés.
4. Tests unitaires (modèle) + widget (parcours minimal).
5. `./tool/quality.sh`.

Référence générale MVVM / repositories : patterns classiques Flutter (ViewModels `ChangeNotifier`, repositories pour I/O).
