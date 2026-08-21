import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/main.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renommer une partie, depuis la page de garde et depuis la partie ouverte.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<Bibliotheque> demarrer(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final bibliotheque = await Bibliotheque.charger();
    bibliotheque.demarrer(nombreJoueurs: 2, nom: 'La couronne d\'ambre');
    bibliotheque.fermer();
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle();
    return bibliotheque;
  }

  testWidgets('renommer depuis la page de garde', (tester) async {
    final bibliotheque = await demarrer(tester);

    final options = find.byTooltip('Options de la partie');
    await tester.ensureVisible(options);
    await tester.pumpAndSettle();
    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Renommer'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Les ruines de Vesper');
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(bibliotheque.parties.first.nom, 'Les ruines de Vesper');
    expect(find.text('Les ruines de Vesper'), findsOneWidget);
  });

  testWidgets('renommer depuis la partie ouverte', (tester) async {
    final bibliotheque = await demarrer(tester);

    await tester.tap(find.text('La couronne d\'ambre'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Renommer la partie'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Les ruines de Vesper');
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(bibliotheque.courante!.nom, 'Les ruines de Vesper');
    // Le titre de l'écran suit le nouveau nom.
    expect(find.text('Les ruines de Vesper'), findsOneWidget);
  });

  testWidgets('annuler le renommage ne change rien', (tester) async {
    final bibliotheque = await demarrer(tester);

    final options = find.byTooltip('Options de la partie');
    await tester.ensureVisible(options);
    await tester.pumpAndSettle();
    await tester.tap(options);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Renommer'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Peu importe');
    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(bibliotheque.parties.first.nom, 'La couronne d\'ambre');
  });
}
