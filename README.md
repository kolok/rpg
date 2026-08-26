# RPG — Fiches de personnages & dés

Application mobile Flutter pour jouer à **RPG** : elle crée les fiches
de personnages de la table et sert de lanceur de dés.

**Aucune connexion internet n'est nécessaire.** Les parties sont enregistrées
sur l'appareil, donc rien n'est perdu si l'application est fermée en pleine
session.

## Les écrans

1. **Page de garde** — présentation de l'application, liste de vos parties
   enregistrées et bouton *Nouvelle partie*. À la création, on donne un **nom**
   à la partie et on choisit le nombre de joueurs, de 2 à 15 ; une fiche vierge
   est créée pour chacun. Juste en dessous, le bouton *Coulisses* ouvre la
   bibliothèque de classes.
2. **La partie** — deux pages que l'on fait défiler d'un balayage latéral, et
   que les onglets du haut rappellent. Le nom de la partie est affiché en haut,
   avec les boutons *renommer* et *quitter*, et le bouton *Lancer les dés* est
   présent sur les deux.
   - **Les héros** — toutes les fiches de la partie, avec le niveau à droite du
     nom et un aperçu des PV, PM, PI et points de réussite. En bas de la liste,
     *Ajouter un personnage* crée une fiche vierge et l'ouvre.
   - **Meneur de jeu** — on l'ouvre en **balayant de la droite vers la
     gauche**. Le meneur y tient ses **fiches de monstres** : *Ajouter un
     monstre* en bas de la liste, suppression depuis la fiche.
3. **Fiche de personnage** — accessible en touchant une ligne de la liste.
   Tout y est modifiable à tout moment pendant la partie. Tout en bas, une
   **zone de danger** permet de supprimer le personnage, après confirmation.
4. **Fiche de monstre** — la même chose, en plus court : voir ci-dessous.
5. **Coulisses** — les classes que vous écrivez une fois pour toutes ; on y
   entre depuis la page de garde. *Créer une classe* ouvre une page vierge.
6. **Page de classe** — le détail d'une classe des coulisses : voir ci-dessous.
7. **Lancer de dés** — on sélectionne un ou plusieurs dés, puis on appuie sur
   les dés pour les lancer.

## Contenu d'une fiche

Les rubriques apparaissent dans cet ordre :

| # | Élément | Type |
| --- | --- | --- |
| 1 | Nom et niveau | texte libre, entier |
| 2 | Points de réussite | entier |
| 3 | PV max et PV actuels | deux entiers + jauge |
| 4 | PM max et PM actuels | deux entiers + jauge |
| 5 | PI max et PI actuels | deux entiers + jauge |
| 6 | Défense, défense magique, initiative | entiers (**l'initiative peut être négative**) |
| 7 | Puissance, Dextérité, Volonté, Intuition | un dé au choix : d6, d8, d10 ou d12 |
| 8… | Classes | chaque classe a son nom **et ses propres compétences**, chacune avec sa description et son **NC** |
| | Équipement | liste de textes libres |
| | Inventaire | liste de textes libres, sans limite |
| | Zénits | entier (pas de 10) |

Les *max* sont le plafond du personnage ; les *actuels* sont ce qu'il perd et
récupère en jeu. La jauge montre où il en est.

Une fiche vierge comporte trois classes, chacune avec sa liste de compétences.
On peut en supprimer ou en ajouter d'autres.

Chaque compétence porte un **NC** (niveau de compétence), réglé au − / + comme
les autres compteurs, et une description. Deux boutons évitent de tout retaper :
*Reprendre une classe des coulisses* remplit le nom de la classe, puis *Depuis
les coulisses* propose les compétences de cette même classe — sa compétence
héroïque comprise. Ce qui est repris est une **copie** : la retoucher sur la
fiche ne modifie pas les coulisses, et le NC repart de zéro, puisque c'est
celui du personnage et non celui du modèle.

On peut **ajouter ou retirer des personnages** à tout moment, même une partie
bien entamée : le bouton d'ajout est au bas de la liste des héros, et la
suppression se fait depuis la zone de danger en fin de fiche, derrière une
demande de confirmation — la fiche effacée ne revient pas.

Les entiers se règlent avec les boutons − / + (pratique pour retirer des PV en
plein combat) ou en tapant directement la valeur au clavier.

## Les coulisses

Les coulisses sont votre bibliothèque de classes. Elles vivent **en dehors des
parties** : une classe écrite une fois est disponible sur toutes les tables et
survit à la suppression d'une partie.

Une page de classe se présente ainsi :

| # | Élément | Type |
| --- | --- | --- |
| 1 | Nom de la classe | texte libre |
| 2 | Atouts gratuits | liste de textes libres |
| 3 | Compétences | nom, **NC** et description — cinq à remplir sur une page neuve, à ajouter ou retirer librement |
| 4 | Sorts | nom et description, **facultatifs**, jusqu'à dix |
| 5 | Compétence héroïque | présentée exactement comme une compétence ordinaire |

Supprimer une classe des coulisses efface sa page, derrière la **zone de
danger** habituelle ; les fiches de personnages gardent ce qui y a déjà été
recopié.

## L'espace meneur de jeu

Les monstres sont enregistrés **dans la partie**, comme les héros : ils sont
retrouvés tels quels à la reprise, et une partie créée avant l'arrivée de cet
espace s'ouvre simplement sans monstre.

Une fiche de monstre est une fiche de personnage réduite à ce qui sert en
pleine rencontre :

| # | Élément | Type |
| --- | --- | --- |
| 1 | Nom et niveau | texte libre, entier |
| 2 | PV max et PV actuels | deux entiers + jauge |
| 3 | PM max et PM actuels | deux entiers + jauge |
| 4 | Équipement | liste de textes libres |
| 5 | Compétences | liste de textes libres |

Ni PI, ni dés de caractéristiques, ni classes, ni inventaire, ni zénits. La
suppression se fait comme pour un héros, depuis la **zone de danger** en fin de
fiche, après confirmation.

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
    competence.dart            compétences (nom, NC, description) et sorts
    modele_classe.dart         une classe enregistrée dans les coulisses
    monstre.dart               la fiche de monstre du meneur de jeu
    partie.dart                une partie : nom, date, fiches, monstres
    bibliotheque.dart          parties + coulisses, sauvegarde locale
  ecrans/
    accueil.dart               écran 1
    partie_en_cours.dart       écran 2 : les deux pages et leur balayage
    liste_personnages.dart     page « Les héros »
    meneur_de_jeu.dart         page « Meneur de jeu »
    fiche_personnage.dart      écran 3
    fiche_monstre.dart         écran 4
    coulisses.dart             écran 5, et les choix puisés dans les coulisses
    fiche_classe.dart          écran 6
    des.dart                   écran 7
  widgets/
    champs.dart                sections, champs texte, compteurs, listes,
                               pastilles et zone de danger
    competences.dart           cartes de compétence (avec NC) et de sort
    forme_de.dart              silhouettes des dés (triangle, losange…)
```

L'état est partagé via `PartieScope`, un `InheritedNotifier` : chaque
modification d'une fiche rafraîchit l'affichage et sauvegarde la partie.
