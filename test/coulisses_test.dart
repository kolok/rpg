import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:rpg/modeles/competence.dart';
import 'package:rpg/modeles/modele_classe.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('une classe neuve a cinq compétences et aucun sort', () {
    final classe = ModeleClasse.neuve();
    expect(classe.competences, hasLength(competencesParClasse));
    expect(classe.competences.every((c) => c.nom.isEmpty), isTrue);
    expect(classe.sorts, isEmpty);
    expect(classe.atouts, isEmpty);
    expect(classe.competenceHeroique.nom, isEmpty);
    expect(classe.nomAffiche, 'Classe sans nom');
  });

  test('la page de classe survit à un aller-retour JSON', () {
    final origine = ModeleClasse.neuve()
      ..nom = 'Gardien'
      ..atouts = ['+5 PV maximum']
      ..competences[0] = Competence(
        nom: 'Frappe vigoureuse',
        description: 'Frappe fort.',
        nc: 3,
      )
      ..sorts.add(Sort(nom: 'Bouclier', description: 'Protège un allié.'))
      ..competenceHeroique = Competence(
        nom: 'Garde du rempart',
        description: 'Encaisse pour tous.',
        nc: 1,
      );

    final copie = ModeleClasse.depuisJson(origine.versJson());

    expect(copie.id, origine.id);
    expect(copie.nom, 'Gardien');
    expect(copie.atouts, ['+5 PV maximum']);
    expect(copie.competences, hasLength(competencesParClasse));
    expect(copie.competences.first.nom, 'Frappe vigoureuse');
    expect(copie.competences.first.description, 'Frappe fort.');
    expect(copie.competences.first.nc, 3);
    expect(copie.sorts, hasLength(1));
    expect(copie.sorts.first.nom, 'Bouclier');
    expect(copie.sorts.first.description, 'Protège un allié.');
    expect(copie.competenceHeroique.nom, 'Garde du rempart');
    expect(copie.competenceHeroique.nc, 1);
  });

  test('les coulisses survivent au redémarrage, hors des parties', () async {
    final bibliotheque = await Bibliotheque.charger();
    final classe = bibliotheque.ajouterClasseCoulisses();
    bibliotheque.modifierCoulisses(() {
      classe.nom = 'Élémentaliste';
      classe.competences.first.nom = 'Boule de feu';
      classe.competences.first.nc = 2;
    });
    await bibliotheque.sauvegarderCoulisses();

    // Redémarrage de l'application : aucune partie n'a été créée.
    final rechargee = await Bibliotheque.charger();
    expect(rechargee.parties, isEmpty);
    expect(rechargee.coulisses, hasLength(1));
    expect(rechargee.coulisses.first.nom, 'Élémentaliste');
    expect(rechargee.coulisses.first.competences.first.nc, 2);

    // On retrouve la classe par son identifiant, comme le fait une fiche.
    expect(rechargee.classeCoulisses(classe.id)?.nom, 'Élémentaliste');
    expect(rechargee.classeCoulisses('inconnu'), isNull);
    expect(rechargee.classeCoulisses(null), isNull);
  });

  test('supprimer une classe des coulisses ne touche pas les autres', () async {
    final bibliotheque = await Bibliotheque.charger();
    final gardien = bibliotheque.ajouterClasseCoulisses();
    final voleur = bibliotheque.ajouterClasseCoulisses();
    bibliotheque.modifierCoulisses(() {
      gardien.nom = 'Gardien';
      voleur.nom = 'Voleur';
    });

    bibliotheque.supprimerClasseCoulisses(gardien);

    expect(bibliotheque.coulisses.map((c) => c.nom), ['Voleur']);
  });

  test('une compétence reprise arrive sur la fiche avec un NC à zéro', () {
    final modele = Competence(
      nom: 'Frappe vigoureuse',
      description: 'Frappe fort.',
      nc: 5,
    );

    final surLaFiche = modele.pourFiche();

    expect(surLaFiche.nom, 'Frappe vigoureuse');
    expect(surLaFiche.description, 'Frappe fort.');
    // Le NC des coulisses est celui du modèle, pas celui du personnage.
    expect(surLaFiche.nc, 0);
    // Et la modifier ne récrit pas la classe des coulisses.
    surLaFiche.nom = 'Autre chose';
    expect(modele.nom, 'Frappe vigoureuse');
  });
}
