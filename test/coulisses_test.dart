import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:rpg/modeles/competence.dart';
import 'package:rpg/modeles/modele_classe.dart';
import 'package:rpg/modeles/personnage.dart';
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
        ncMax: 3,
      )
      ..sorts.add(Sort(nom: 'Bouclier', description: 'Protège un allié.'))
      ..competenceHeroique = Competence(
        nom: 'Garde du rempart',
        description: 'Encaisse pour tous.',
        ncMax: 1,
      );

    final copie = ModeleClasse.depuisJson(origine.versJson());

    expect(copie.id, origine.id);
    expect(copie.nom, 'Gardien');
    expect(copie.atouts, ['+5 PV maximum']);
    expect(copie.competences, hasLength(competencesParClasse));
    expect(copie.competences.first.nom, 'Frappe vigoureuse');
    expect(copie.competences.first.description, 'Frappe fort.');
    expect(copie.competences.first.ncMax, 3);
    expect(copie.sorts, hasLength(1));
    expect(copie.sorts.first.nom, 'Bouclier');
    expect(copie.sorts.first.description, 'Protège un allié.');
    expect(copie.competenceHeroique.nom, 'Garde du rempart');
    expect(copie.competenceHeroique.ncMax, 1);
  });

  test('les coulisses survivent au redémarrage, hors des parties', () async {
    final bibliotheque = await Bibliotheque.charger();
    final classe = bibliotheque.ajouterClasseCoulisses();
    bibliotheque.modifierCoulisses(() {
      classe.nom = 'Élémentaliste';
      classe.competences.first.nom = 'Boule de feu';
      classe.competences.first.ncMax = 2;
    });
    await bibliotheque.sauvegarderCoulisses();

    // Redémarrage de l'application : aucune partie n'a été créée.
    final rechargee = await Bibliotheque.charger();
    expect(rechargee.parties, isEmpty);
    expect(rechargee.coulisses, hasLength(1));
    expect(rechargee.coulisses.first.nom, 'Élémentaliste');
    expect(rechargee.coulisses.first.competences.first.ncMax, 2);

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
      ncMax: 5,
    );

    final surLaFiche = modele.pourFiche();

    expect(surLaFiche.nom, 'Frappe vigoureuse');
    expect(surLaFiche.description, 'Frappe fort.');
    // Le NC des coulisses est un plafond : le personnage part de zéro.
    expect(surLaFiche.nc, 0);
    expect(surLaFiche.ncMax, 5);
    // Et la modifier ne récrit pas la classe des coulisses.
    surLaFiche.nom = 'Autre chose';
    expect(modele.nom, 'Frappe vigoureuse');
  });

  test(
    'copier une classe reprend ses compétences, ses sorts et sa compétence héroïque',
    () {
      final modele = ModeleClasse.neuve()
        ..nom = 'Gardien'
        ..atouts = ['+5 PV maximum']
        ..competences[0] = Competence(nom: 'Frappe vigoureuse', ncMax: 3)
        ..sorts.addAll([
          Sort(nom: 'Bouclier', description: 'Protège un allié.'),
          Sort(),
        ])
        ..competenceHeroique = Competence(nom: 'Garde du rempart', ncMax: 1);

      final classe = Classe.depuisModele(modele);

      expect(classe.nom, 'Gardien');
      expect(classe.modeleId, modele.id);
      // Les compétences sans nom des coulisses ne remplissent pas la fiche.
      expect(classe.competences.map((c) => c.nom), ['Frappe vigoureuse']);
      expect(classe.competences.single.nc, 0);
      expect(classe.competences.single.ncMax, 3);
      // Les sorts nommés suivent aussi, sans être liés à ceux des coulisses.
      expect(classe.sorts.map((s) => s.nom), ['Bouclier']);
      expect(classe.sorts.single.description, 'Protège un allié.');
      classe.sorts.single.nom = 'Autre chose';
      expect(modele.sorts.first.nom, 'Bouclier');

      // La compétence héroïque a son propre bloc, au NC zéro elle aussi.
      expect(classe.competencesHeroiques.map((c) => c.nom), [
        'Garde du rempart',
      ]);
      expect(classe.competencesHeroiques.single.nc, 0);
      expect(classe.competencesHeroiques.single.ncMax, 1);
      classe.competencesHeroiques.single.nom = 'Autre chose';
      expect(modele.competenceHeroique.nom, 'Garde du rempart');
    },
  );

  test('une compétence héroïque sans nom n\'est pas recopiée', () {
    final classe = Classe.depuisModele(ModeleClasse.neuve()..nom = 'Gardien');
    expect(classe.competencesHeroiques, isEmpty);
  });

  test('recopier deux fois une classe ne double pas ses compétences', () {
    final modele = ModeleClasse.neuve()
      ..nom = 'Gardien'
      ..competences[0] = Competence(nom: 'Frappe vigoureuse', ncMax: 3)
      ..sorts.add(Sort(nom: 'Bouclier'))
      ..competenceHeroique = Competence(nom: 'Garde du rempart', ncMax: 1);

    final classe = Classe.depuisModele(modele);
    classe.competences.first.nc = 2;
    classe.competencesHeroiques.first.nc = 1;
    classe.reprendre(modele);

    expect(classe.competences, hasLength(1));
    expect(classe.sorts, hasLength(1));
    expect(classe.competencesHeroiques, hasLength(1));
    // Ce que le personnage a acquis n'est pas écrasé.
    expect(classe.competences.first.nc, 2);
    expect(classe.competencesHeroiques.first.nc, 1);
  });

  test('le résumé compte la compétence héroïque quand elle a un nom', () {
    final classe = ModeleClasse.neuve()
      ..competences[0] = Competence(nom: 'Frappe vigoureuse');
    expect(classe.resume, '1\u00A0compétence');

    classe.competenceHeroique = Competence(nom: 'Garde du rempart');
    // Chaque morceau reste d'un seul tenant : seul le séparateur se coupe.
    expect(
      classe.resume,
      '1\u00A0compétence · 1\u00A0compétence\u00A0héroïque',
    );
  });
}
