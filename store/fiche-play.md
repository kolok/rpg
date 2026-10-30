# Dossier Google Play — RPG

Tout ce qu’il faut coller dans la Play Console pour créer l’application
`com.kolok.rpg`. La version à téléverser est un **Android App Bundle**
signé (`.aab`), pas un APK.

## Identité

| Champ | Valeur |
| --- | --- |
| Nom de l’application (installée) | RPG |
| Identifiant | `com.kolok.rpg` |
| Version | `1.0.0` (versionCode `1`) |
| Langue par défaut | Français (France) |
| Catégorie | Applications → **Outils** |
| Étiquettes | jeu de rôle, fiche, dés, hors ligne |
| E-mail de contact | nicolas@oudard.org |
| Publicité dans l’application | Non |
| Achats in-app | Non |

Titre de la fiche Play (30 caractères max) :

```
RPG — fiches et dés
```

Description courte (80 caractères max) :

```
Fiches de perso, coulisses, monstres et dés. Tout reste sur l’appareil.
```

## Description longue

```
RPG tient la table : fiches de personnages, classes des coulisses, fiches de monstres et lancer de dés. Aucune connexion internet n’est nécessaire. Les parties restent sur l’appareil, même si vous fermez l’application en pleine session.

Page de garde
Présentation, liste de vos parties et bouton Nouvelle partie. Vous donnez un nom à la table et choisissez de 2 à 15 joueurs : une fiche vierge est créée pour chacun. Le bouton Coulisses ouvre la bibliothèque de classes, indépendante des parties.

Pendant la partie
Deux pages, que l’on fait défiler d’un balayage latéral.
• Les héros — toutes les fiches, avec le niveau à droite du nom et un aperçu des PV, PM, PI et points de réussite. En bas, Ajouter un personnage.
• Meneur de jeu — ouvrez-le en balayant de la droite vers la gauche. Ajoutez et tenez vos fiches de monstres.

Fiche de personnage
Tout est modifiable à tout moment : nom, niveau, points de réussite, jauges PV / PM / PI, défenses, initiative (qui peut être négative), caractéristiques (d6, d8, d10 ou d12), classes, compétences, sorts, équipement, inventaire et zénits. Une fiche neuve n’a aucune classe : vous en copiez une depuis les coulisses, ou vous en créez une vierge. La copie vit ensuite sur la fiche, sans modifier les coulisses.

Fiche de monstre
Une fiche plus courte pour le feu de l’action : nom, niveau, PV, PM, équipement et compétences.

Coulisses
Votre bibliothèque de classes, écrite une fois pour toutes. Nom, atouts gratuits, compétences (avec un NC maximum), sorts facultatifs et compétence héroïque. Ces pages survivent à la suppression d’une partie et servent à toutes les tables.

Lancer de dés
d4, d6, d8, d10, d12 et d20. Plusieurs dés, y compris plusieurs fois le même. Le détail de chaque dé et le total s’affichent.

Plusieurs parties en parallèle
Autant de tables que vous voulez. L’enregistrement est automatique à la moindre modification. Vous pouvez renommer, quitter (la partie est conservée) ou supprimer une table depuis la page de garde.

L’application ne contient ni publicité, ni compte, ni achat.
```

Notes de version (1.0.0) :

```
Première version : fiches de personnages, coulisses, espace meneur de jeu et lancer de dés, entièrement hors ligne.
```

## Visuels

Déposer dans *Fiche Play Store principale* :

| Élément | Fichier | Format |
| --- | --- | --- |
| Icône haute résolution | `store/icone-512.png` | 512 × 512, PNG 32 bits |
| Graphique vedette | `store/graphique-vedette.png` | 1024 × 500, PNG |
| Captures téléphone | `store/captures/*.png` | 1080 × 1920, au moins 2 |

Regénérer les captures :

```bash
GENERER_CAPTURES=1 flutter test test/captures_boutique_test.dart
```

## Signature (même clé que pierrot_la_nouille)

La clé d’**upload** est celle déjà utilisée pour l’autre application,
`/Users/nicolasoudard/upload-keystore.jks`, alias `upload`.

Le fichier `android/key.properties` (non versionné) pointe vers cette
clé, sur le même modèle que `counter_mobile_app`. Un exemple se trouve
dans `android/key.properties.example`.

Empreinte SHA-256 du certificat d’upload :

```
9A:E4:C5:C4:06:3F:67:86:78:6A:0F:42:2F:8E:12:0B:98:4B:3A:15:A1:8B:A9:B4:88:C1:5C:51:37:64:FE:BE
```

À la création de l’application, laisser **Play App Signing** activé
(obligatoire pour une application neuve). Google gardera la clé de
signature de distribution ; la clé locale ne sert qu’à téléverser les
bundles.

Construire le bundle :

```bash
flutter build appbundle --release
```

Le fichier à envoyer :

`build/app/outputs/bundle/release/app-release.aab`

## Politique de confidentialité

Play exige une **URL publique**. Le texte est dans
`docs/politique-de-confidentialite.html`.

Pour la servir depuis ce dépôt GitHub :

1. Sur github.com/kolok/rpg → *Settings* → *Pages*
2. Source : branche `main`, dossier `/docs`
3. URL à coller dans la console :

```
https://kolok.github.io/rpg/politique-de-confidentialite.html
```

Tant que Pages n’est pas activé, cette adresse renverra une 404 et Play
refusera la fiche.

## Sécurité des données

*L’application collecte-t-elle ou partage-t-elle des données utilisateur
requises ?* **Non.**

- Pas de SDK d’analyse, de crash, de pub ni de connexion
- Les fiches restent sur l’appareil et ne quittent jamais le téléphone
- Identifiant publicitaire : non utilisé
- Chiffrement en transit : sans objet (aucun réseau)
- Suppression de compte : sans objet (pas de compte)

## Questionnaire IARC / classification du contenu

Répondre **Non** à la violence graphique, aux achats, aux publicités, au
partage en ligne, à la localisation, aux communications utilisateurs et
aux contenus générés visibles par d’autres personnes.

Les noms et notes de jeu restent **locaux** : ce n’est pas du contenu
généré destiné à d’autres utilisateurs.

Public cible : **13 ans et plus** (ne pas cocher moins de 13 ans, pour
éviter les règles COPPA). L’application n’est pas conçue pour les
enfants.

- Publicité : non
- Store : Google Play uniquement pour cette publication
- Accès à l’application : **toutes les fonctionnalités sont disponibles**
  sans compte ni identifiants de test

## Déclarations diverses

| Question | Réponse |
| --- | --- |
| Application gouvernementale | Non |
| Application d’actualité | Non |
| Fonctionnalités financières | Non |
| Santé / Fitness | Non |
| VPN / proxy | Non |
| Android TV, Wear, Auto, XR | Non |
| Appareils photo / micro | Non |
| Données de santé | Non |

## Piste de publication

Pour la première version : piste **Production**, ou **Tests internes**
puis promotion. Un compte de test n’est pas nécessaire : il n’y a ni
connexion ni contenu verrouillé.
