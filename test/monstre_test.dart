import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/modeles/monstre.dart';
import 'package:rpg/modeles/partie.dart';
import 'package:rpg/modeles/personnage.dart';

void main() {
  test('une fiche de monstre neuve a ses réserves pleines', () {
    final monstre = Monstre(nom: 'Loup des cendres');
    expect(monstre.pvActuels, monstre.pvMax);
    expect(monstre.pmActuels, monstre.pmMax);
    expect(monstre.niveau, 0);
    expect(monstre.equipement, isEmpty);
    expect(monstre.competences, isEmpty);
  });

  test('la fiche de monstre survit à un aller-retour JSON', () {
    final origine = Monstre(
      nom: 'Loup des cendres',
      niveau: 12,
      pvMax: 60,
      pvActuels: 41,
      pmMax: 20,
      pmActuels: 5,
      equipement: ['Griffes acérées'],
      competences: ['Souffle de givre', 'Morsure venimeuse'],
    );

    final copie = Monstre.depuisJson(origine.versJson());

    expect(copie.nom, 'Loup des cendres');
    expect(copie.niveau, 12);
    expect(copie.pvMax, 60);
    expect(copie.pvActuels, 41);
    expect(copie.pmMax, 20);
    expect(copie.pmActuels, 5);
    expect(copie.equipement, ['Griffes acérées']);
    expect(copie.competences, ['Souffle de givre', 'Morsure venimeuse']);
  });

  test('les monstres suivent la partie dans la sauvegarde', () {
    final partie = Partie.neuve(nombreJoueurs: 2, nom: 'Les ruines de Vesper');
    expect(partie.monstres, isEmpty);
    partie.monstres.add(Monstre(nom: 'Loup des cendres', niveau: 12));

    final copie = Partie.depuisJson(partie.versJson());

    expect(copie.personnages, hasLength(2));
    expect(copie.monstres, hasLength(1));
    expect(copie.monstres.first.nom, 'Loup des cendres');
    expect(copie.monstres.first.niveau, 12);
  });

  test(
    'une partie enregistrée avant l\'espace meneur s\'ouvre sans monstre',
    () {
      final ancienne = {
        'nom': 'La couronne d\'ambre',
        'personnages': [Personnage(nom: 'Aria').versJson()],
      };

      final partie = Partie.depuisJson(ancienne);

      expect(partie.personnages, hasLength(1));
      expect(partie.monstres, isEmpty);
    },
  );

  test('un monstre ajouté prend le premier numéro libre', () {
    final partie = Partie.neuve(nombreJoueurs: 2);
    partie.monstres.add(Monstre(nom: partie.nomLibreMonstre()));
    partie.monstres.add(Monstre(nom: partie.nomLibreMonstre()));
    expect(partie.monstres.map((m) => m.nom), ['Monstre 1', 'Monstre 2']);

    // Après une suppression, le nom libéré ne crée pas d'homonyme.
    partie.monstres.removeAt(0);
    partie.monstres.add(Monstre(nom: partie.nomLibreMonstre()));
    expect(partie.monstres.map((m) => m.nom), ['Monstre 2', 'Monstre 3']);
  });
}
