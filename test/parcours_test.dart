import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/main.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:rpg/modeles/partie.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Parcourt les quatre écrans de l'application.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Le défilement de la fiche. Chaque champ texte contient lui aussi un
  /// `Scrollable`, il faut donc désigner celui de la liste.
  final defilementFiche = find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  /// Fait défiler la fiche jusqu'à ce que [cible] soit construite et visible.
  /// La fiche étant une `ListView`, les éléments hors écran n'existent pas
  /// encore dans l'arbre : on descend jusqu'à les faire apparaître.
  Future<void> defilerJusqua(WidgetTester tester, Finder cible) async {
    for (var i = 0; i < 40 && cible.evaluate().isEmpty; i++) {
      await tester.drag(defilementFiche, const Offset(0, -200));
      await tester.pumpAndSettle();
    }
    expect(cible, findsWidgets);
    await tester.ensureVisible(cible.first);
    await tester.pumpAndSettle();
  }

  Future<void> demarrerApplication(WidgetTester tester) async {
    // Surface équivalente à un téléphone, plus haute que les 800×600 par défaut.
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final bibliotheque = await Bibliotheque.charger();
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle();
  }

  /// Crée une partie depuis la page de garde et l'ouvre.
  Future<void> creerPartie(
    WidgetTester tester, {
    String? nom,
    int? joueursEnMoins,
  }) async {
    final bouton = find.text('Démarrer la partie').evaluate().isNotEmpty
        ? find.text('Démarrer la partie')
        : find.text('Nouvelle partie');
    // Avec plusieurs parties listées, le bouton passe sous le bas de l'écran.
    await tester.ensureVisible(bouton);
    await tester.pumpAndSettle();
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    if (nom != null) {
      // Le premier champ du dialogue est le nom de la partie.
      await tester.enterText(find.byType(TextField).first, nom);
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < (joueursEnMoins ?? 0); i++) {
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Créer les fiches'));
    await tester.pumpAndSettle();
  }

  testWidgets('démarrer une partie crée une fiche par joueur', (tester) async {
    await demarrerApplication(tester);

    expect(find.text('RPG'), findsOneWidget);
    await tester.tap(find.text('Démarrer la partie'));
    await tester.pumpAndSettle();

    // Le dialogue propose 4 joueurs par défaut ; on passe à 3.
    expect(find.text('Nombre de joueurs'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer les fiches'));
    await tester.pumpAndSettle();

    // Sans nom saisi, la partie prend celui proposé par défaut.
    expect(find.text(Partie.nomParDefaut(DateTime.now())), findsOneWidget);
    expect(find.text('Personnage 1'), findsOneWidget);
    expect(find.text('Personnage 3'), findsOneWidget);
    expect(find.text('Personnage 4'), findsNothing);
  });

  testWidgets('une fiche neuve annonce qu\'elle n\'a aucune classe', (
    tester,
  ) async {
    await demarrerApplication(tester);
    await creerPartie(tester);

    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();

    final message = find.textContaining('Aucune classe sur cette fiche');
    await defilerJusqua(tester, message);
    expect(find.text('Classe 1'), findsNothing);

    // Le bouton d'ajout demande d'abord d'où vient la classe.
    await tester.tap(find.text('Ajouter une classe'));
    await tester.pumpAndSettle();
    expect(find.text('Copier une classe des coulisses'), findsOneWidget);
    await tester.tap(find.text('Créer une classe vierge'));
    await tester.pumpAndSettle();

    expect(message, findsNothing);
    // La fiche n'en montre qu'un résumé, sans champ à remplir.
    expect(find.text('CLASSE 1'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Classe 1'), findsNothing);

    // « Modifier » ouvre la page plein écran de la classe.
    await defilerJusqua(tester, find.text('Modifier'));
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Classe 1'), findsOneWidget);
  });

  testWidgets('modifier une fiche puis revenir à la liste', (tester) async {
    await demarrerApplication(tester);
    await creerPartie(tester);

    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();

    // Renommer le personnage.
    await tester.enterText(find.byType(TextField).first, 'Aria');
    await tester.pumpAndSettle();

    // Choisir un dé pour la Puissance (le premier des quatre sélecteurs).
    final de12 = find.widgetWithText(SegmentedButton<int>, 'd12');
    await defilerJusqua(tester, de12);
    await tester.tap(de12.first);
    await tester.pumpAndSettle();

    // La fiche est vierge : il faut d'abord créer une classe.
    final ajouterClasse = find.text('Ajouter une classe');
    await defilerJusqua(tester, ajouterClasse);
    await tester.tap(ajouterClasse);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer une classe vierge'));
    await tester.pumpAndSettle();

    // Ouvrir la classe, la nommer, puis lui associer une compétence.
    await defilerJusqua(tester, find.text('Modifier'));
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    final champClasse = find.widgetWithText(TextField, 'Classe 1');
    await defilerJusqua(tester, champClasse);
    await tester.enterText(champClasse, 'Gardien');
    await tester.pumpAndSettle();

    final ajouterCompetence = find.text('Ajouter une compétence');
    await defilerJusqua(tester, ajouterCompetence);
    await tester.tap(ajouterCompetence.first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Compétence 1').first,
      'Frappe vigoureuse',
    );
    await tester.pumpAndSettle();

    // De retour sur la fiche, le résumé reprend la classe et sa compétence.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('GARDIEN'), findsOneWidget);
    expect(find.text('Frappe vigoureuse'), findsOneWidget);
    expect(find.text('NC 0'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Aria'), findsOneWidget);
    expect(find.text('Gardien'), findsOneWidget);

    // La compétence est bien rattachée à la classe.
    await tester.tap(find.text('Aria'));
    await tester.pumpAndSettle();
    final modifier = find.text('Modifier');
    await defilerJusqua(tester, modifier);
    await tester.tap(modifier);
    await tester.pumpAndSettle();
    final champCompetence = find.widgetWithText(TextField, 'Compétence 1');
    await defilerJusqua(tester, champCompetence);
    expect(
      tester.widget<TextField>(champCompetence.first).controller?.text,
      'Frappe vigoureuse',
    );
  });

  testWidgets('les réserves PV, PM et PI ont chacune deux compteurs', (
    tester,
  ) async {
    await demarrerApplication(tester);
    await creerPartie(tester);
    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();

    for (final sigle in ['PV', 'PM', 'PI']) {
      final maximum = find.text('$sigle max');
      await defilerJusqua(tester, maximum);
      expect(maximum, findsOneWidget);
      expect(find.text('$sigle actuels'), findsOneWidget);
    }
  });

  testWidgets('l\'initiative accepte une valeur négative', (tester) async {
    await demarrerApplication(tester);
    await creerPartie(tester);
    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();

    final initiative = find.text('Initiative (peut être négative)');
    await defilerJusqua(tester, initiative);

    // Le champ de saisie voisin du libellé « Initiative ».
    final champ = find.descendant(
      of: find.ancestor(of: initiative, matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    );
    await tester.enterText(champ, '-3');
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();
    await defilerJusqua(tester, initiative);

    final champRelu = find.descendant(
      of: find.ancestor(of: initiative, matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(champRelu).controller?.text, '-3');
  });

  testWidgets('sélectionner des dés et les lancer affiche un total', (
    tester,
  ) async {
    await demarrerApplication(tester);
    await creerPartie(tester);

    await tester.tap(find.text('Lancer les dés'));
    await tester.pumpAndSettle();

    expect(find.text('Lancer de dés'), findsOneWidget);
    expect(find.text('TOTAL'), findsNothing);

    // Sélectionner un d20 et deux d6.
    await tester.tap(find.widgetWithText(InkWell, 'd20').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'd6').first);
    await tester.tap(find.widgetWithText(InkWell, 'd6').first);
    await tester.pumpAndSettle();

    expect(find.text('×2'), findsOneWidget);

    // Appuyer sur la zone des dés pour les lancer.
    await tester.tap(find.text('2. Appuyez sur les dés pour les lancer'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('TOTAL'), findsOneWidget);
  });

  testWidgets('quitter la partie la garde dans la bibliothèque', (
    tester,
  ) async {
    await demarrerApplication(tester);
    await creerPartie(tester, nom: 'La couronne d\'ambre');

    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();

    // Retour à la page de garde : la partie y est toujours listée.
    expect(find.text('RPG'), findsOneWidget);
    expect(find.text('Vos parties'), findsOneWidget);
    expect(find.text('La couronne d\'ambre'), findsOneWidget);
    expect(find.text('Nouvelle partie'), findsOneWidget);
  });

  testWidgets('une deuxième partie ne remplace pas la première', (
    tester,
  ) async {
    await demarrerApplication(tester);

    await creerPartie(tester, nom: 'La couronne d\'ambre');
    expect(find.text('La couronne d\'ambre'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();

    await creerPartie(tester, nom: 'Les ruines de Vesper');
    expect(find.text('Les ruines de Vesper'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();

    // Les deux parties coexistent sur la page de garde.
    expect(find.text('La couronne d\'ambre'), findsOneWidget);
    expect(find.text('Les ruines de Vesper'), findsOneWidget);
  });

  testWidgets('on reprend une partie enregistrée là où on l\'a laissée', (
    tester,
  ) async {
    await demarrerApplication(tester);
    await creerPartie(tester, nom: 'La couronne d\'ambre');

    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Aria');
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();

    // On rouvre la partie depuis la page de garde.
    final partie = find.text('La couronne d\'ambre');
    await tester.ensureVisible(partie);
    await tester.pumpAndSettle();
    await tester.tap(partie);
    await tester.pumpAndSettle();
    expect(find.text('Aria'), findsOneWidget);
  });

  testWidgets('ajouter un personnage à une partie déjà commencée', (
    tester,
  ) async {
    await demarrerApplication(tester);
    await creerPartie(tester, joueursEnMoins: 2);
    expect(find.text('Personnage 3'), findsNothing);

    final ajouter = find.text('Ajouter un personnage');
    await tester.ensureVisible(ajouter);
    await tester.pumpAndSettle();
    await tester.tap(ajouter);
    await tester.pumpAndSettle();

    // La fiche neuve s'ouvre directement pour être remplie.
    expect(find.text('Personnage 3'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'Aria');
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Elle est ajoutée à la suite des autres.
    expect(find.text('Personnage 1'), findsOneWidget);
    expect(find.text('Aria'), findsOneWidget);
  });

  testWidgets('le niveau se lit dans la liste des héros', (tester) async {
    await demarrerApplication(tester);
    await creerPartie(tester, joueursEnMoins: 2);
    // Les fiches neuves partent du niveau 0.
    expect(find.text('Niv. 0'), findsNWidgets(2));

    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();
    // Dans l'identité, le nom vient d'abord, le niveau juste après.
    await tester.enterText(find.byType(TextField).at(1), '7');
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Le niveau s'affiche à droite du nom, sans ouvrir la fiche.
    expect(find.text('Niv. 7'), findsOneWidget);
    expect(find.text('Niv. 0'), findsOneWidget);
  });

  /// Ouvre l'espace meneur de jeu en balayant la partie de la droite vers
  /// la gauche.
  Future<void> ouvrirEspaceMeneur(WidgetTester tester) async {
    await tester.drag(find.byType(TabBarView), const Offset(-400, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('un balayage vers la gauche ouvre l\'espace meneur de jeu', (
    tester,
  ) async {
    await demarrerApplication(tester);
    await creerPartie(tester, joueursEnMoins: 2);
    expect(find.text('Personnage 1'), findsOneWidget);

    await ouvrirEspaceMeneur(tester);

    // Les héros laissent la place aux monstres, la partie reste la même.
    expect(find.text('Personnage 1'), findsNothing);
    expect(find.text('Ajouter un monstre'), findsOneWidget);

    // Et un balayage en sens inverse ramène aux héros.
    await tester.drag(find.byType(TabBarView), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Personnage 1'), findsOneWidget);
  });

  testWidgets('le meneur crée une fiche de monstre', (tester) async {
    await demarrerApplication(tester);
    await creerPartie(tester, joueursEnMoins: 2);
    await ouvrirEspaceMeneur(tester);

    await tester.tap(find.text('Ajouter un monstre'));
    await tester.pumpAndSettle();

    // La fiche neuve s'ouvre directement : nom, niveau, réserves, équipement
    // et compétences, et rien d'autre.
    expect(find.text('Monstre 1'), findsWidgets);
    expect(find.text('Réserves'.toUpperCase()), findsOneWidget);
    expect(find.text('Équipement'.toUpperCase()), findsOneWidget);
    expect(find.text('Compétences'.toUpperCase()), findsOneWidget);
    expect(find.text('Inventaire'.toUpperCase()), findsNothing);
    expect(find.text('Zénits'.toUpperCase()), findsNothing);
    expect(find.text('Dés'.toUpperCase()), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'Loup des cendres');
    await tester.pumpAndSettle();
    // Dans l'identité, le niveau vient juste après le nom.
    await tester.enterText(find.byType(TextField).at(1), '12');
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Le monstre est listé avec son niveau, comme les héros.
    expect(find.text('Loup des cendres'), findsOneWidget);
    expect(find.text('Niv. 12'), findsOneWidget);
  });

  testWidgets('supprimer un monstre demande confirmation', (tester) async {
    await demarrerApplication(tester);
    await creerPartie(tester, joueursEnMoins: 2);
    await ouvrirEspaceMeneur(tester);

    await tester.tap(find.text('Ajouter un monstre'));
    await tester.pumpAndSettle();

    final bouton = find.text('Supprimer ce monstre');
    await defilerJusqua(tester, bouton);
    await tester.tap(bouton);
    await tester.pumpAndSettle();

    // Annuler ne supprime rien.
    expect(find.text('Supprimer ce monstre ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Monstre 1'), findsOneWidget);

    // Confirmer efface la fiche et ramène à l'espace meneur.
    await tester.tap(find.text('Monstre 1'));
    await tester.pumpAndSettle();
    await defilerJusqua(tester, bouton);
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Monstre 1'), findsNothing);
    expect(find.text('Ajouter un monstre'), findsOneWidget);
  });

  testWidgets('supprimer un personnage demande confirmation', (tester) async {
    await demarrerApplication(tester);
    await creerPartie(tester, joueursEnMoins: 2);

    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();

    final bouton = find.text('Supprimer ce personnage');
    await defilerJusqua(tester, bouton);
    await tester.tap(bouton);
    await tester.pumpAndSettle();

    // Annuler ne supprime rien.
    expect(find.text('Supprimer ce personnage ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Personnage 1'), findsOneWidget);

    // Confirmer supprime la fiche et ramène à la liste.
    await tester.tap(find.text('Personnage 1'));
    await tester.pumpAndSettle();
    await defilerJusqua(tester, bouton);
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Personnage 1'), findsNothing);
    expect(find.text('Personnage 2'), findsOneWidget);
  });
}
