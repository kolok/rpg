import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/modeles/competence.dart';
import 'package:rpg/modeles/personnage.dart';

void main() {
  test('une fiche neuve a un dé par caractéristique', () {
    final personnage = Personnage(nom: 'Aria');
    expect(personnage.caracteristiques.length, Caracteristique.values.length);
    for (final de in personnage.caracteristiques.values) {
      expect(desCaracteristiques, contains(de));
    }
  });

  test('une fiche neuve a ses réserves pleines et aucune classe', () {
    final personnage = Personnage(nom: 'Aria');
    expect(personnage.pvActuels, personnage.pvMax);
    expect(personnage.pmActuels, personnage.pmMax);
    expect(personnage.piActuels, personnage.piMax);
    expect(personnage.classes, isEmpty);
  });

  test('la fiche survit à un aller-retour JSON', () {
    final origine = Personnage(
      nom: 'Aria',
      classes: [
        Classe(
          nom: 'Gardien',
          competences: [
            Competence(
              nom: 'Frappe vigoureuse',
              description: 'Frappe fort.',
              nc: 2,
              ncMax: 5,
            ),
          ],
          sorts: [Sort(nom: 'Bouclier', description: 'Protège un allié.')],
          competencesHeroiques: [
            Competence(nom: 'Garde du rempart', nc: 1, ncMax: 1),
          ],
        ),
        Classe(
          nom: 'Élémentaliste',
          competences: [
            Competence(nom: 'Boule de feu'),
            Competence(nom: 'Éclair'),
          ],
        ),
      ],
      pointsDeReussite: 5,
      zenits: 250,
      equipement: ['Épée longue'],
      inventaire: ['Potion', 'Corde'],
      niveau: 12,
      pvMax: 45,
      pvActuels: 38,
      pmMax: 40,
      pmActuels: 12,
      piMax: 8,
      piActuels: 3,
      defense: 11,
      defenseMagique: 9,
      initiative: -2,
      caracteristiques: {
        Caracteristique.puissance: 10,
        Caracteristique.dexterite: 8,
        Caracteristique.volonte: 6,
        Caracteristique.intuition: 12,
      },
    );

    final copie = Personnage.depuisJson(origine.versJson());

    expect(copie.nom, 'Aria');
    expect(copie.pointsDeReussite, 5);
    expect(copie.zenits, 250);
    expect(copie.equipement, ['Épée longue']);
    expect(copie.inventaire, ['Potion', 'Corde']);
    expect(copie.niveau, 12);
    expect(copie.pvMax, 45);
    expect(copie.pvActuels, 38);
    expect(copie.pmMax, 40);
    expect(copie.pmActuels, 12);
    expect(copie.piMax, 8);
    expect(copie.piActuels, 3);
    expect(copie.defense, 11);
    expect(copie.defenseMagique, 9);
    expect(copie.initiative, -2);
    expect(copie.caracteristiques[Caracteristique.puissance], 10);
    expect(copie.caracteristiques[Caracteristique.intuition], 12);

    expect(copie.classes, hasLength(2));
    expect(copie.classes[0].nom, 'Gardien');
    expect(copie.classes[0].competences.first.nom, 'Frappe vigoureuse');
    expect(copie.classes[0].competences.first.description, 'Frappe fort.');
    // Le NC atteint et son plafond suivent la compétence dans la sauvegarde.
    expect(copie.classes[0].competences.first.nc, 2);
    expect(copie.classes[0].competences.first.ncMax, 5);
    // Les sorts appris dans la classe aussi.
    expect(copie.classes[0].sorts.single.nom, 'Bouclier');
    expect(copie.classes[0].sorts.single.description, 'Protège un allié.');
    expect(copie.classes[1].sorts, isEmpty);
    // Et les compétences héroïques, avec leur NC.
    expect(
      copie.classes[0].competencesHeroiques.single.nom,
      'Garde du rempart',
    );
    expect(copie.classes[0].competencesHeroiques.single.nc, 1);
    expect(copie.classes[1].competencesHeroiques, isEmpty);
    expect(copie.classes[1].nom, 'Élémentaliste');
    expect(copie.classes[1].competences.map((c) => c.nom), [
      'Boule de feu',
      'Éclair',
    ]);
  });

  test('une ancienne sauvegarde est reprise sans rien perdre', () {
    // Format précédent : un seul compteur PV/PM, classes en simples textes,
    // compétences hors des classes, et les anciens noms des points de
    // réussite et du niveau.
    final ancienne = {
      'nom': 'Aria',
      'classes': ['Gardien', 'Élémentaliste'],
      'competences': ['Frappe vigoureuse'],
      'pointsFabula': 4,
      'experience': 7,
      'pv': 35,
      'pm': 20,
      'zenits': 100,
      'initiative': 3,
    };

    final copie = Personnage.depuisJson(ancienne);

    expect(copie.nom, 'Aria');
    // Le compteur unique devient le maximum, réserve pleine.
    expect(copie.pvMax, 35);
    expect(copie.pvActuels, 35);
    expect(copie.pmMax, 20);
    expect(copie.pmActuels, 20);
    expect(copie.zenits, 100);
    expect(copie.pointsDeReussite, 4);
    // Les points d'expérience d'alors sont le niveau d'aujourd'hui.
    expect(copie.niveau, 7);
    // Les compétences orphelines sont rattachées à la première classe.
    expect(copie.classes.map((c) => c.nom), ['Gardien', 'Élémentaliste']);
    // Une compétence n'était alors qu'une ligne de texte : elle devient une
    // compétence sans description, au NC à zéro.
    expect(copie.classes[0].competences.map((c) => c.nom), [
      'Frappe vigoureuse',
    ]);
    expect(copie.classes[0].competences.first.description, isEmpty);
    expect(copie.classes[0].competences.first.nc, 0);
    expect(copie.classes[0].competences.first.ncMax, 0);
    expect(copie.classes[1].competences, isEmpty);
    // Les sorts n'existaient pas sur la fiche : les classes en sont dépourvues.
    expect(copie.classes[0].sorts, isEmpty);
  });

  test('l\'inventaire n\'a pas de limite de nombre d\'objets', () {
    final personnage = Personnage(nom: 'Aria');
    personnage.inventaire.addAll(List.filled(20, 'Potion'));

    final copie = Personnage.depuisJson(personnage.versJson());
    expect(copie.inventaire, hasLength(20));
  });
}
