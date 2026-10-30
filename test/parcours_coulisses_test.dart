import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/main.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:rpg/widgets/competences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Les coulisses : écrire une classe une fois, la reprendre sur une fiche.
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

  Future<Bibliotheque> demarrerApplication(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final bibliotheque = await Bibliotheque.charger();
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle();
    return bibliotheque;
  }

  /// Ouvre les coulisses depuis la page de garde.
  Future<void> ouvrirCoulisses(WidgetTester tester) async {
    final bouton = find.text('Coulisses');
    await tester.ensureVisible(bouton);
    await tester.pumpAndSettle();
    await tester.tap(bouton);
    await tester.pumpAndSettle();
  }

  /// Démarre une partie depuis la page de garde et ouvre la première fiche.
  /// Une fiche neuve n'ayant aucune classe, on en crée une vierge sauf si le
  /// test veut justement passer par la copie.
  Future<void> ouvrirPremiereFiche(
    WidgetTester tester, {
    bool avecClasseVierge = true,
  }) async {
    final demarrer = find.text('Démarrer la partie');
    await tester.ensureVisible(demarrer);
    await tester.pumpAndSettle();
    await tester.tap(demarrer);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer les fiches'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();

    if (!avecClasseVierge) return;
    final ajouter = find.text('Ajouter une classe');
    await defilerJusqua(tester, ajouter);
    await tester.tap(ajouter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer une classe vierge'));
    await tester.pumpAndSettle();
  }

  /// Écrit dans les coulisses une classe « Gardien » avec une compétence.
  Future<void> ecrireClasseGardien(WidgetTester tester) async {
    await ouvrirCoulisses(tester);
    await tester.tap(find.text('Créer une classe'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nom de la classe'),
      'Gardien',
    );
    await tester.pumpAndSettle();
    expect(find.text('ATOUTS GRATUITS'), findsOneWidget);

    final premiere = find.widgetWithText(TextField, 'Compétence 1');
    await defilerJusqua(tester, premiere);
    await tester.enterText(premiere.first, 'Frappe vigoureuse');
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Description').first,
      'Frappe fort.',
    );
    await tester.pumpAndSettle();

    // Dans la carte, les champs se suivent : le nom, le NC max, la
    // description. Ce NC est le plafond de la compétence.
    await tester.enterText(
      find
          .descendant(
            of: find.byType(CarteCompetence).first,
            matching: find.byType(TextField),
          )
          .at(1),
      '3',
    );
    await tester.pumpAndSettle();
  }

  testWidgets('la page de garde mène aux coulisses', (tester) async {
    await demarrerApplication(tester);
    await ouvrirCoulisses(tester);

    expect(
      find.text(
        'Aucune classe enregistrée.\n'
        'Écrivez-les une fois : elles seront ensuite à portée de '
        'main sur toutes vos fiches de personnages.',
      ),
      findsOneWidget,
    );
    expect(find.text('Créer une classe'), findsOneWidget);
  });

  testWidgets('une page de classe porte tout ce qu\'on y écrit', (
    tester,
  ) async {
    final bibliotheque = await demarrerApplication(tester);
    await ecrireClasseGardien(tester);

    // Les rubriques se suivent de haut en bas ; la page étant une liste, on
    // ne peut les voir qu'en descendant.
    expect(find.text('COMPÉTENCES'), findsOneWidget);
    // Le NC saisi ici est le plafond de la compétence.
    expect(find.text('NC max'), findsWidgets);
    // Cinq compétences vierges au départ.
    await defilerJusqua(tester, find.widgetWithText(TextField, 'Compétence 5'));
    // Les sorts sont facultatifs : aucun au départ.
    await defilerJusqua(tester, find.text('SORTS'));
    expect(find.text('0/10'), findsOneWidget);
    await defilerJusqua(tester, find.text('COMPÉTENCE HÉROÏQUE'));

    await tester.pageBack();
    await tester.pumpAndSettle();

    // La classe est listée dans les coulisses, et enregistrée.
    expect(find.text('Gardien'), findsOneWidget);
    final enregistree = bibliotheque.coulisses.single;
    expect(enregistree.nom, 'Gardien');
    expect(enregistree.competences.first.nom, 'Frappe vigoureuse');
    expect(enregistree.competences.first.description, 'Frappe fort.');
  });

  testWidgets('les sorts s\'ajoutent jusqu\'à dix', (tester) async {
    final bibliotheque = await demarrerApplication(tester);
    await ouvrirCoulisses(tester);
    await tester.tap(find.text('Créer une classe'));
    await tester.pumpAndSettle();

    final ajouterSort = find.text('Ajouter un sort');
    for (var i = 0; i < 10; i++) {
      await defilerJusqua(tester, ajouterSort);
      await tester.tap(ajouterSort);
      await tester.pumpAndSettle();
    }
    expect(bibliotheque.coulisses.single.sorts, hasLength(10));

    // Au dixième, le bouton s'éteint.
    await defilerJusqua(tester, ajouterSort);
    expect(
      tester
          .widget<TextButton>(
            find.ancestor(of: ajouterSort, matching: find.byType(TextButton)),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('une fiche copie une classe des coulisses', (tester) async {
    final bibliotheque = await demarrerApplication(tester);
    await ecrireClasseGardien(tester);
    // Retour à la page de garde.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Une partie, puis la fiche du premier personnage, encore sans classe.
    await ouvrirPremiereFiche(tester, avecClasseVierge: false);

    final ajouter = find.text('Ajouter une classe');
    await defilerJusqua(tester, ajouter);
    await tester.tap(ajouter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copier une classe des coulisses'));
    await tester.pumpAndSettle();
    expect(find.text('Classes des coulisses'), findsOneWidget);
    await tester.tap(find.text('Gardien').last);
    await tester.pumpAndSettle();

    // Le nom et la compétence sont sur la fiche, au NC zéro.
    final classe = bibliotheque.courante!.personnages.first.classes.single;
    expect(classe.nom, 'Gardien');
    expect(classe.competences, hasLength(1));
    expect(classe.competences.first.nom, 'Frappe vigoureuse');
    expect(classe.competences.first.nc, 0);
    expect(classe.competences.first.ncMax, 3);
    // Les sorts, eux, ne suivent pas.
    expect(classe.sorts, isEmpty);

    // Sur la fiche, la compétence tient en deux lignes : son nom, puis son
    // niveau borné par le plafond des coulisses. Pas de description.
    final ligne = find.byType(LigneCompetenceFiche);
    await defilerJusqua(tester, ligne);
    expect(
      find.descendant(of: ligne, matching: find.text('Description')),
      findsNothing,
    );
    expect(
      find.descendant(of: ligne, matching: find.text('NC')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: ligne, matching: find.text('/ 3')),
      findsOneWidget,
    );
  });

  testWidgets('une classe de la fiche reçoit des sorts à la main', (
    tester,
  ) async {
    final bibliotheque = await demarrerApplication(tester);
    await ouvrirPremiereFiche(tester);

    final ajouterSort = find.text('Ajouter un sort');
    await defilerJusqua(tester, ajouterSort);
    await tester.tap(ajouterSort);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Sort 1'),
      'Bouclier',
    );
    await tester.pumpAndSettle();

    final classe = bibliotheque.courante!.personnages.first.classes.single;
    expect(classe.sorts.single.nom, 'Bouclier');
  });
}
