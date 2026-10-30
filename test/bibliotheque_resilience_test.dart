import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('une sauvegarde de parties illisible repart à vide', () async {
    SharedPreferences.setMockInitialValues({'parties': '{pas du json'});

    final bibliotheque = await Bibliotheque.charger();

    expect(bibliotheque.parties, isEmpty);
    expect(bibliotheque.coulisses, isEmpty);
  });

  test('une sauvegarde de coulisses illisible repart à vide', () async {
    SharedPreferences.setMockInitialValues({'coulisses': '[1, 2, 3'});

    final bibliotheque = await Bibliotheque.charger();

    expect(bibliotheque.coulisses, isEmpty);
  });

  test('une ancienne sauvegarde illisible est ignorée', () async {
    SharedPreferences.setMockInitialValues({
      'partie_en_cours': '<<<',
    });

    final bibliotheque = await Bibliotheque.charger();

    expect(bibliotheque.parties, isEmpty);
  });
}
