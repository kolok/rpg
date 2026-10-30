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
Fiches de perso et dés, sans pub ni compte. Vos données restent sur l’appareil.
```

## Description longue

```
RPG est le compagnon de votre table de jeu de rôle : fiches de personnages, classes réutilisables, fiches de monstres et lancer de dés, dans une seule application.

★ Sans publicité, sans compte, sans collecte de données ★
• Aucune publicité, jamais. Ni bannière, ni vidéo, ni achat intégré.
• Aucun compte à créer, aucune adresse e-mail demandée.
• Aucune donnée personnelle collectée ni partagée : pas de statistiques, pas de traceur, pas de service tiers.
• Tout reste sur votre téléphone. Vos parties ne quittent jamais l'appareil.
• Fonctionne entièrement hors ligne, même au fond d'une cave sans réseau.

Des fiches de personnages complètes
Nom, niveau, points de réussite, jauges PV / PM / PI, défense, défense magique, initiative (même négative), caractéristiques (d6 à d12), équipement, inventaire et zénits. Tout se modifie d'un geste pendant la partie, et tout est enregistré automatiquement.

Des classes claires
Sur la fiche, chaque classe tient dans un petit résumé : son nom et ses compétences avec leur niveau (NC). Un appui sur « Modifier » ouvre la classe en plein écran pour changer les compétences, leurs descriptions, leurs niveaux, les sorts et les compétences héroïques.

Les coulisses : vos classes écrites une fois pour toutes
Créez votre bibliothèque de classes (atouts, compétences avec NC maximum, sorts, compétence héroïque) et copiez-la sur n'importe quelle fiche, dans n'importe quelle partie.

L'espace du meneur de jeu
Un balayage suffit pour passer des héros aux monstres. Ajoutez et suivez vos créatures : niveau, PV, PM, équipement et compétences.

Le lancer de dés
d4, d6, d8, d10, d12 et d20. Combinez plusieurs dés, y compris plusieurs fois le même : le détail de chaque dé et le total s'affichent aussitôt.

Plusieurs parties en parallèle
De 2 à 15 joueurs par table, autant de tables que vous voulez. Renommez, quittez ou supprimez une partie depuis la page d'accueil. Vous pouvez ajouter ou retirer un joueur en pleine partie.

Votre table, vos données
RPG ne demande aucune autorisation sensible : ni localisation, ni contacts, ni appareil photo, ni micro. Désinstaller l'application efface vos parties de l'appareil : personne d'autre n'en a jamais eu de copie.

Bonne partie !
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
| Captures téléphone | `store/captures/*.png` | 1080 × 1920, 8 captures |

Ordre conseillé des captures (c’est l’ordre des noms de fichiers) :

1. `01-accueil.png` — page de garde et liste des parties
2. `02-les-heros.png` — les fiches de la table, niveau à droite du nom
3. `03-fiche-personnage.png` — identité, points de réussite, réserves
4. `04-resume-classe.png` — résumé de classe en lecture seule
5. `05-page-classe.png` — page « Modifier » : compétences, descriptions, NC
6. `06-meneur-de-jeu.png` — fiches de monstres
7. `07-lancer-de-des.png` — lancer de dés et total
8. `08-coulisses.png` — bibliothèque de classes

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
