import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/modeles/competence.dart';
import 'package:rpg/modeles/modele_classe.dart';

void main() {
  test('le résumé d\'une classe compte les compétences et les sorts', () {
    final une = ModeleClasse.neuve()
      ..nom = 'Gardien'
      ..competences[0].nom = 'Frappe';
    expect(une.resume, '1 compétence');

    final plusieurs = ModeleClasse.neuve()
      ..competences[0].nom = 'A'
      ..competences[1].nom = 'B'
      ..sorts.add(Sort(nom: 'Bouclier'));
    expect(plusieurs.resume, '2 compétences · 1 sorts');
  });

  test('ModeleClasse.depuisJson tolère des champs absents', () {
    final classe = ModeleClasse.depuisJson({'nom': 'Voleur'});

    expect(classe.nom, 'Voleur');
    expect(classe.id, isNotEmpty);
    expect(classe.atouts, isEmpty);
  });

  test('Sort.listeDepuisJson accepte des chaînes brutes', () {
    final sorts = Sort.listeDepuisJson(['Boule de feu', 'Éclair']);

    expect(sorts.map((s) => s.nom), ['Boule de feu', 'Éclair']);
  });
}
