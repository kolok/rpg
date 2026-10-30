import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/main.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:rpg/widgets/champs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Complète la couverture des écrans et widgets peu parcourus par les parcours
/// principaux.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final defilement = find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  Future<void> defilerJusqua(WidgetTester tester, Finder cible) async {
    for (var i = 0; i < 40 && cible.evaluate().isEmpty; i++) {
      await tester.drag(defilement, const Offset(0, -200));
      await tester.pumpAndSettle();
    }
    expect(cible, findsWidgets);
    await tester.ensureVisible(cible.first);
    await tester.pumpAndSettle();
  }

  Future<Bibliotheque> demarrer(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final bibliotheque = await Bibliotheque.charger();
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle();
    return bibliotheque;
  }

  Future<void> tapPlusCompteur(WidgetTester tester, String libelle) async {
    final zone = find.ancestor(
      of: find.text(libelle),
      matching: find.byType(CompteurEntier),
    );
    await tester.tap(
      find.descendant(of: zone, matching: find.byIcon(Icons.add)),
    );
    await tester.pumpAndSettle();
  }

  /// Le bouton de démarrage est en bas de la page d'accueil : il faut faire
  /// défiler la liste avant de taper, sinon le centre du bouton sort de l'écran.
  Future<void> ouvrirDialogueNouvellePartie(WidgetTester tester) async {
    final bouton = find.text('Démarrer la partie');
    await tester.scrollUntilVisible(
      bouton,
      120,
      scrollable: defilement,
    );
    await tester.pumpAndSettle();
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  Future<void> ouvrirCoulisses(WidgetTester tester) async {
    final bouton = find.text('Coulisses');
    await tester.scrollUntilVisible(
      bouton,
      120,
      scrollable: defilement,
    );
    await tester.pumpAndSettle();
    await tester.tap(bouton);
    await tester.pumpAndSettle();
  }

  Future<void> creerPartieMinimale(WidgetTester tester) async {
    await ouvrirDialogueNouvellePartie(tester);
    await tester.tap(find.byIcon(Icons.remove));
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer les fiches'));
    await tester.pumpAndSettle();
  }

  testWidgets('supprimer une partie depuis la page de garde', (tester) async {
    final bibliotheque = await demarrer(tester);
    bibliotheque.demarrer(nombreJoueurs: 2, nom: 'La couronne d\'ambre');
    bibliotheque.fermer();
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle();

    final options = find.byTooltip('Options de la partie');
    await tester.ensureVisible(options);
    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer « La couronne d\'ambre » ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(bibliotheque.parties, hasLength(1));

    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(bibliotheque.parties, isEmpty);
    expect(find.text('Vos parties'), findsNothing);
  });

  testWidgets('le dialogue de nouvelle partie accepte le slider et l\'annulation',
      (tester) async {
    await demarrer(tester);
    await ouvrirDialogueNouvellePartie(tester);

    final dialogue = find.byType(AlertDialog);
    await tester.drag(
      find.descendant(of: dialogue, matching: find.byType(Slider)),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Personnage 1'), findsNothing);
  });

  testWidgets('ouvrir une classe depuis la liste des coulisses', (tester) async {
    final bibliotheque = await demarrer(tester);
    final gardien = bibliotheque.ajouterClasseCoulisses();
    bibliotheque.modifierCoulisses(() {
      gardien.nom = 'Gardien';
      gardien.competences.first.nom = 'Frappe';
    });
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle();

    await ouvrirCoulisses(tester);
    expect(find.text('1 compétence'), findsOneWidget);

    await tester.tap(find.text('Gardien'));
    await tester.pumpAndSettle();
    expect(find.text('ATOUTS GRATUITS'), findsOneWidget);
  });

  testWidgets('supprimer une classe des coulisses depuis sa fiche', (
    tester,
  ) async {
    final bibliotheque = await demarrer(tester);
    final gardien = bibliotheque.ajouterClasseCoulisses();
    bibliotheque.modifierCoulisses(() => gardien.nom = 'Gardien');
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle();

    await ouvrirCoulisses(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gardien'));
    await tester.pumpAndSettle();

    final bouton = find.text('Supprimer cette classe');
    await defilerJusqua(tester, bouton);
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(bibliotheque.coulisses, hasLength(1));

    await tester.tap(bouton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(bibliotheque.coulisses, isEmpty);
    expect(find.text('Créer une classe'), findsOneWidget);
  });

  testWidgets('les coulisses vides et l\'annulation du choix de classe', (
    tester,
  ) async {
    await demarrer(tester);
    await creerPartieMinimale(tester);
    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();

    final ajouter = find.text('Ajouter une classe');
    await defilerJusqua(tester, ajouter);
    await tester.tap(ajouter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copier une classe des coulisses'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Les coulisses sont vides'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    await tester.tap(ajouter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucune classe sur cette fiche'), findsOneWidget);
  });

  testWidgets('retirer des dés et tout effacer', (tester) async {
    await demarrer(tester);
    await creerPartieMinimale(tester);
    await tester.tap(find.text('Lancer les dés'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(InkWell, 'd6').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('×1'), findsNothing);

    await tester.tap(find.widgetWithText(InkWell, 'd20').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tout effacer'));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL'), findsNothing);
  });

  testWidgets('la fiche personnage couvre réserves, listes et compteurs', (
    tester,
  ) async {
    final bibliotheque = await demarrer(tester);
    await creerPartieMinimale(tester);
    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Lancer les dés'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await defilerJusqua(tester, find.text('Points de réussite'));
    await tapPlusCompteur(tester, 'Points de réussite');

    await defilerJusqua(tester, find.text('Zénits'));
    await tapPlusCompteur(tester, 'Zénits');
    expect(bibliotheque.courante!.personnages.first.zenits, 10);

    final equipement = find.text('Équipement'.toUpperCase());
    await defilerJusqua(tester, equipement);
    await tester.tap(find.text('Ajouter').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Épée');
    await tester.pumpAndSettle();

    final inventaire = find.text('Inventaire'.toUpperCase());
    await defilerJusqua(tester, inventaire);
    await tester.tap(find.text('Ajouter').last);
    await tester.pumpAndSettle();

    final ajouterClasse = find.text('Ajouter une classe');
    await defilerJusqua(tester, ajouterClasse);
    await tester.tap(ajouterClasse);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer une classe vierge'));
    await tester.pumpAndSettle();

    final supprimerClasse = find.byTooltip('Supprimer cette classe');
    await defilerJusqua(tester, supprimerClasse);
    await tester.tap(supprimerClasse);
    await tester.pumpAndSettle();
    expect(bibliotheque.courante!.personnages.first.classes, isEmpty);
  });

  testWidgets('la fiche monstre couvre PM, équipement et compétences', (
    tester,
  ) async {
    await demarrer(tester);
    await creerPartieMinimale(tester);
    await tester.drag(find.byType(TabBarView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter un monstre'));
    await tester.pumpAndSettle();

    await defilerJusqua(tester, find.text('PM max'));
    await tapPlusCompteur(tester, 'PM max');
    await tapPlusCompteur(tester, 'PM actuels');

    final equipement = find.text('Équipement'.toUpperCase());
    await defilerJusqua(tester, equipement);
    final zoneEquipement = find.ancestor(
      of: equipement,
      matching: find.byType(SectionFiche),
    );
    await tester.tap(
      find.descendant(of: zoneEquipement, matching: find.text('Ajouter')),
    );
    await tester.pumpAndSettle();

    final competences = find.text('Compétences'.toUpperCase());
    await defilerJusqua(tester, competences);
    expect(find.text('Aucune compétence.'), findsOneWidget);
    final zoneCompetences = find.ancestor(
      of: competences,
      matching: find.byType(SectionFiche),
    );
    await tester.tap(
      find.descendant(of: zoneCompetences, matching: find.text('Ajouter')),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('une classe des coulisses sans compétence affiche le message vide',
      (tester) async {
    final bibliotheque = await demarrer(tester);
    final vide = bibliotheque.ajouterClasseCoulisses();
    bibliotheque.modifierCoulisses(() {
      vide.nom = 'Vide';
      vide.competences.clear();
    });
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle();

    await ouvrirCoulisses(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vide'));
    await tester.pumpAndSettle();

    expect(
      find.text('Aucune compétence pour cette classe.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Les sorts sont facultatifs'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ajouter une compétence'));
    await tester.pumpAndSettle();

    final ajouterSort = find.text('Ajouter un sort');
    await defilerJusqua(tester, ajouterSort);
    await tester.tap(ajouterSort);
    await tester.pumpAndSettle();

    final supprimerSort = find.byTooltip('Supprimer ce sort');
    await defilerJusqua(tester, supprimerSort);
    await tester.tap(supprimerSort);
    await tester.pumpAndSettle();
    expect(find.text('0/10'), findsOneWidget);
  });
}
