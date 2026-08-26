import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/main.dart';
import 'package:rpg/modeles/bibliotheque.dart';
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
  Future<void> ouvrirPremiereFiche(WidgetTester tester) async {
    final demarrer = find.text('Démarrer la partie');
    await tester.ensureVisible(demarrer);
    await tester.pumpAndSettle();
    await tester.tap(demarrer);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer les fiches'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personnage 1'));
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
    // Le NC accompagne chaque compétence.
    expect(find.text('NC'), findsWidgets);
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

  testWidgets('une fiche reprend une classe puis sa compétence', (
    tester,
  ) async {
    final bibliotheque = await demarrerApplication(tester);
    await ecrireClasseGardien(tester);
    // Retour à la page de garde.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Une partie, puis la fiche du premier personnage.
    await ouvrirPremiereFiche(tester);

    // Reprendre la classe des coulisses remplit son nom.
    final reprendre = find.text('Reprendre une classe des coulisses');
    await defilerJusqua(tester, reprendre);
    await tester.tap(reprendre.first);
    await tester.pumpAndSettle();
    expect(find.text('Classes des coulisses'), findsOneWidget);
    await tester.tap(find.text('Gardien').last);
    await tester.pumpAndSettle();

    final classe = bibliotheque.courante!.personnages.first.classes.first;
    expect(classe.nom, 'Gardien');

    // Puis piocher une compétence dans cette même classe.
    final depuisCoulisses = find.text('Depuis les coulisses');
    await defilerJusqua(tester, depuisCoulisses);
    await tester.tap(depuisCoulisses.first);
    await tester.pumpAndSettle();
    expect(find.text('Compétences de Gardien'), findsOneWidget);
    await tester.tap(find.text('Frappe vigoureuse').last);
    await tester.pumpAndSettle();

    expect(classe.competences, hasLength(1));
    expect(classe.competences.first.nom, 'Frappe vigoureuse');
    expect(classe.competences.first.description, 'Frappe fort.');
    // Le personnage démarre la compétence au NC zéro.
    expect(classe.competences.first.nc, 0);
  });

  testWidgets('sans classe reprise, la fiche dit où puiser', (tester) async {
    await demarrerApplication(tester);
    await ouvrirPremiereFiche(tester);

    final depuisCoulisses = find.text('Depuis les coulisses');
    await defilerJusqua(tester, depuisCoulisses);
    await tester.tap(depuisCoulisses.first);
    await tester.pumpAndSettle();

    expect(
      find.text('Choisissez d\'abord la classe dans les coulisses.'),
      findsOneWidget,
    );
  });
}
