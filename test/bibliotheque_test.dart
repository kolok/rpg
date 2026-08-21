import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:rpg/modeles/personnage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('plusieurs parties coexistent et survivent au redémarrage', () async {
    final bibliotheque = await Bibliotheque.charger();

    bibliotheque.demarrer(nombreJoueurs: 3, nom: 'La couronne d\'ambre');
    bibliotheque.modifier(
      () => bibliotheque.courante!.personnages.first.nom = 'Aria',
    );
    bibliotheque.demarrer(nombreJoueurs: 5, nom: 'Les ruines de Vesper');

    expect(bibliotheque.parties, hasLength(2));
    // La nouvelle partie est ouverte, l'autre reste intacte.
    expect(bibliotheque.courante!.nom, 'Les ruines de Vesper');
    await bibliotheque.sauvegarder();

    // Redémarrage de l'application.
    final rechargee = await Bibliotheque.charger();
    expect(rechargee.courante, isNull);
    expect(
      rechargee.parties.map((p) => p.nom),
      containsAll(['La couronne d\'ambre', 'Les ruines de Vesper']),
    );

    final ambre = rechargee.parties.firstWhere(
      (p) => p.nom == 'La couronne d\'ambre',
    );
    expect(ambre.personnages, hasLength(3));
    expect(ambre.personnages.first.nom, 'Aria');
    expect(
      rechargee.parties
          .firstWhere((p) => p.nom == 'Les ruines de Vesper')
          .personnages,
      hasLength(5),
    );
  });

  test('quitter une partie la garde, la supprimer l\'efface', () async {
    final bibliotheque = await Bibliotheque.charger();
    bibliotheque.demarrer(nombreJoueurs: 2, nom: 'La couronne d\'ambre');

    bibliotheque.fermer();
    expect(bibliotheque.courante, isNull);
    expect(bibliotheque.parties, hasLength(1));

    bibliotheque.supprimer(bibliotheque.parties.first);
    expect(bibliotheque.parties, isEmpty);
  });

  test('une sauvegarde de l\'ancienne version devient une partie', () async {
    // L'ancienne version ne gardait qu'une partie, sous une autre clé.
    final personnages = [
      Personnage(nom: 'Aria').versJson(),
      Personnage(nom: 'Bran').versJson(),
    ];
    SharedPreferences.setMockInitialValues({
      'flutter.partie_en_cours': jsonEncode(personnages),
    });

    final bibliotheque = await Bibliotheque.charger();

    expect(bibliotheque.parties, hasLength(1));
    expect(bibliotheque.parties.first.personnages.map((p) => p.nom), [
      'Aria',
      'Bran',
    ]);

    // La reprise ne se rejoue pas au redémarrage suivant.
    final rechargee = await Bibliotheque.charger();
    expect(rechargee.parties, hasLength(1));
  });

  test('ajouter et supprimer des fiches dans une partie existante', () async {
    final bibliotheque = await Bibliotheque.charger();
    bibliotheque.demarrer(nombreJoueurs: 3, nom: 'La couronne d\'ambre');

    bibliotheque.supprimerPersonnage(bibliotheque.courante!.personnages[1]);
    expect(
      bibliotheque.courante!.personnages.map((p) => p.nom),
      ['Personnage 1', 'Personnage 3'],
    );

    // Le nom proposé évite l'homonyme laissé libre par la suppression.
    final ajoute = bibliotheque.ajouterPersonnage();
    expect(ajoute!.nom, 'Personnage 4');
    expect(bibliotheque.courante!.personnages.last, same(ajoute));

    await bibliotheque.sauvegarder();
    final rechargee = await Bibliotheque.charger();
    expect(
      rechargee.parties.single.personnages.map((p) => p.nom),
      ['Personnage 1', 'Personnage 3', 'Personnage 4'],
    );
  });
}
