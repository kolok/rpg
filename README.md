# RPG — Fiches de personnages & dés

Application mobile Flutter pour jouer à **RPG** : elle crée les fiches
de personnages de la table et sert de lanceur de dés.

**Aucune connexion internet n'est nécessaire.** Les parties sont enregistrées
sur l'appareil, donc rien n'est perdu si l'application est fermée en pleine
session.

## Les quatre écrans

1. **Page de garde** — présentation de l'application, liste de vos parties
   enregistrées et bouton *Nouvelle partie*. À la création, on donne un **nom**
   à la partie et on choisit le nombre de joueurs, de 2 à 15 ; une fiche vierge
   est créée pour chacun.
2. **Liste des héros** — toutes les fiches de la partie, avec un aperçu des PV,
   PM, PI et points de réussite. Le nom de la partie est affiché en haut, avec les
   boutons *renommer* et *quitter*. En bas de la liste, *Ajouter un
   personnage* crée une fiche vierge et l'ouvre. Bouton *Lancer les dés*.
3. **Fiche de personnage** — accessible en touchant une ligne de la liste.
   Tout y est modifiable à tout moment pendant la partie. Tout en bas, une
   **zone de danger** permet de supprimer le personnage, après confirmation.
4. **Lancer de dés** — on sélectionne un ou plusieurs dés, puis on appuie sur
   les dés pour les lancer.

## Contenu d'une fiche

Les rubriques apparaissent dans cet ordre :

| # | Élément | Type |
| --- | --- | --- |
| 1 | Nom et points d'expérience | texte libre, entier |
| 2 | Points de réussite | entier |
| 3 | PV max et PV actuels | deux entiers + jauge |
| 4 | PM max et PM actuels | deux entiers + jauge |
| 5 | PI max et PI actuels | deux entiers + jauge |
| 6 | Défense, défense magique, initiative | entiers (**l'initiative peut être négative**) |
| 7 | Puissance, Dextérité, Volonté, Intuition | un dé au choix : d6, d8, d10 ou d12 |
| 8… | Classes | chaque classe a son nom **et ses propres compétences** |
| | Équipement | liste de textes libres |
| | Inventaire | liste de textes libres, sans limite |
| | Zénits | entier (pas de 10) |

Les *max* sont le plafond du personnage ; les *actuels* sont ce qu'il perd et
récupère en jeu. La jauge montre où il en est.

Une fiche vierge comporte trois classes, chacune avec sa liste de compétences.
On peut en supprimer ou en ajouter d'autres.

On peut **ajouter ou retirer des personnages** à tout moment, même une partie
bien entamée : le bouton d'ajout est au bas de la liste des héros, et la
suppression se fait depuis la zone de danger en fin de fiche, derrière une
demande de confirmation — la fiche effacée ne revient pas.

Les entiers se règlent avec les boutons − / + (pratique pour retirer des PV en
plein combat) ou en tapant directement la valeur au clavier.

## Les dés

Dés disponibles pour les lancers : **d4, d6, d8, d10, d12 et d20**.
On peut en sélectionner plusieurs, et plusieurs fois le même (ex. 2d6 + 1d20) ;
le détail de chaque dé et le total sont affichés.

Les caractéristiques du personnage, elles, utilisent l'échelle du jeu
(d6 → d12).

## Plusieurs parties en parallèle

Vous pouvez mener **autant de parties que vous voulez en même temps** : en
démarrer une nouvelle ne touche jamais aux précédentes. Chaque partie porte le
nom que vous lui avez donné à sa création, et la page de garde les liste de la
plus récemment jouée à la plus ancienne.

- **Enregistrement** — automatique, à la moindre modification : chaque frappe
  dans un champ, chaque appui sur − / +. Il n'y a rien à enregistrer à la main.
- **Renommer** — depuis la partie, ou depuis le menu ⋮ de la page de garde.
- **Quitter** — ramène à la page de garde. **La partie est conservée** et peut
  être reprise plus tard, telle qu'elle était.
- **Supprimer** — depuis le menu ⋮ de la page de garde, après confirmation.
  Les autres parties ne sont pas touchées.

## Développement

```bash
flutter pub get
flutter run              # sur un appareil ou un émulateur connecté
flutter test             # tests unitaires + parcours des écrans
flutter analyze
flutter build apk        # Android
flutter build ios        # iOS
```

### Organisation du code

```
lib/
  main.dart                    point d'entrée, chargement de la bibliothèque
  theme.dart                   palette encre bleu nuit & Material 3
  modeles/
    personnage.dart            la fiche et sa sérialisation JSON
    partie.dart                une partie : nom, date, fiches
    bibliotheque.dart          toutes les parties + sauvegarde locale
  ecrans/
    accueil.dart               écran 1
    liste_personnages.dart     écran 2
    fiche_personnage.dart      écran 3
    des.dart                   écran 4
  widgets/
    champs.dart                sections, champs texte, compteurs, listes
    forme_de.dart              silhouettes des dés (triangle, losange…)
```

L'état est partagé via `PartieScope`, un `InheritedNotifier` : chaque
modification d'une fiche rafraîchit l'affichage et sauvegarde la partie.
