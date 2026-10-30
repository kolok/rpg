import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/main.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:rpg/modeles/echange.dart';
import 'package:rpg/modeles/fichiers.dart';
import 'package:rpg/modeles/modele_classe.dart';
import 'package:rpg/modeles/partie.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remplace les dialogues du système : garde ce qu'on enregistre et sert le
/// fichier qu'on lui donne à ouvrir.
class _FauxFichiers extends Fichiers {
  String? nomEnregistre;
  Uint8List? enregistre;
  Uint8List? aOuvrir;

  @override
  Future<bool> enregistrer({
    required String nom,
    required Uint8List octets,
  }) async {
    nomEnregistre = nom;
    enregistre = octets;
    return true;
  }

  String? nomPartage;
  Uint8List? partage;

  @override
  Future<bool> partager({
    required String nom,
    required Uint8List octets,
    Rect? origine,
  }) async {
    nomPartage = nom;
    partage = octets;
    return true;
  }

  @override
  Future<Uint8List?> ouvrir() async => aOuvrir;

  /// Fichier ouvert avec l'application depuis une autre.
  Uint8List? recu;
  VoidCallback? prevenir;

  @override
  Future<Uint8List?> fichierRecu() async {
    final octets = recu;
    recu = null;
    return octets;
  }

  @override
  void ecouterFichiersRecus(VoidCallback? auxNouvelles) =>
      prevenir = auxNouvelles;
}

void main() {
  late _FauxFichiers fichiers;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fichiers = _FauxFichiers();
    Fichiers.actuel = fichiers;
  });
  tearDown(() => Fichiers.actuel = const Fichiers());

  ModeleClasse classe(String nom) => ModeleClasse.neuve()..nom = nom;

  group('format', () {
    test('les classes survivent à un export puis un import', () {
      final gardien = classe('Gardien')..atouts = ['+5 PV'];
      final copies = Echange.importerClasses(
        Echange.exporterClasses([gardien, classe('Mage')]),
      );
      expect(copies.map((c) => c.nom), ['Gardien', 'Mage']);
      expect(copies.first.id, gardien.id);
      expect(copies.first.atouts, ['+5 PV']);
    });

    test('une partie survit à un export puis un import', () {
      final partie = Partie.neuve(nombreJoueurs: 3, nom: 'La couronne');
      final copie = Echange.importerPartie(Echange.exporterPartie(partie));
      expect(copie.nom, 'La couronne');
      expect(copie.personnages, hasLength(3));
    });

    test('on ne confond pas un fichier de partie et un de classes', () {
      final partie = Echange.exporterPartie(Partie.neuve(nombreJoueurs: 2));
      final classes = Echange.exporterClasses([classe('Gardien')]);
      expect(() => Echange.importerClasses(partie), throwsFormatException);
      expect(() => Echange.importerPartie(classes), throwsFormatException);
    });

    test('un fichier étranger ou abîmé est refusé', () {
      expect(
        () => Echange.importerClasses(utf8.encode('pas du json')),
        throwsFormatException,
      );
      expect(
        () => Echange.importerClasses(utf8.encode('{"classes": []}')),
        throwsFormatException,
      );
      expect(
        () => Echange.importerClasses(
          utf8.encode(
            '{"application": "rpg", "type": "classes", '
            '"classes": [42]}',
          ),
        ),
        throwsFormatException,
      );
    });

    test('le nom de fichier proposé est sans caractère interdit', () {
      expect(
        Echange.nomDeFichier('La couronne / d\'ambre'),
        'La_couronne_d\'ambre.json',
      );
      expect(Echange.nomDeFichier('  '), 'export.json');
    });
  });

  group('bibliothèque', () {
    test(
      'importer une classe connue la remplace, une inconnue s\'ajoute',
      () async {
        final bibliotheque = await Bibliotheque.charger();
        final gardien = bibliotheque.ajouterClasseCoulisses()..nom = 'Gardien';
        final importee = Echange.importerClasses(
          Echange.exporterClasses([
            gardien..nom = 'Gardien v2',
            classe('Mage'),
          ]),
        );
        gardien.nom = 'Gardien';

        expect(bibliotheque.importerClasses(importee), 1);
        expect(bibliotheque.coulisses.map((c) => c.nom), [
          'Gardien v2',
          'Mage',
        ]);
      },
    );

    test('importer une partie déjà présente en fait une copie', () async {
      final bibliotheque = await Bibliotheque.charger();
      final partie = bibliotheque.demarrer(nombreJoueurs: 2, nom: 'Table');
      final copie = bibliotheque.importerPartie(
        Echange.importerPartie(Echange.exporterPartie(partie)),
      );
      expect(copie.id, isNot(partie.id));
      expect(bibliotheque.parties, hasLength(2));
    });
  });

  group('écrans', () {
    Future<Bibliotheque> demarrer(WidgetTester tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final bibliotheque = await Bibliotheque.charger();
      await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
      await tester.pumpAndSettle();
      return bibliotheque;
    }

    Future<void> ouvrirMenuCoulisses(WidgetTester tester) async {
      final bouton = find.text('Coulisses');
      await tester.ensureVisible(bouton);
      await tester.pumpAndSettle();
      await tester.tap(bouton);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Options des coulisses'));
      await tester.pumpAndSettle();
    }

    testWidgets('on choisit les classes à exporter, toutes cochées au départ', (
      tester,
    ) async {
      final bibliotheque = await demarrer(tester);
      bibliotheque.importerClasses([classe('Gardien'), classe('Mage')]);
      await tester.pumpAndSettle();

      await ouvrirMenuCoulisses(tester);
      await tester.tap(find.text('Exporter des classes'));
      await tester.pumpAndSettle();
      expect(find.text('Exporter (2)'), findsOneWidget);

      // La case générale décoche tout, puis recoche tout.
      await tester.tap(find.text('Toutes les classes'));
      await tester.pumpAndSettle();
      expect(find.text('Exporter (0)'), findsOneWidget);
      await tester.tap(find.text('Toutes les classes'));
      await tester.pumpAndSettle();
      expect(find.text('Exporter (2)'), findsOneWidget);

      await tester.tap(find.text('Mage').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exporter (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer sur l\'appareil'));
      await tester.pumpAndSettle();

      final exportees = Echange.importerClasses(fichiers.enregistre!);
      expect(exportees.map((c) => c.nom), ['Gardien']);
      expect(fichiers.nomEnregistre, 'Classe_Gardien.json');
      expect(find.text('1 classe exportée.'), findsOneWidget);
    });

    testWidgets('on partage les classes en pièce jointe', (tester) async {
      final bibliotheque = await demarrer(tester);
      bibliotheque.importerClasses([classe('Gardien'), classe('Mage')]);
      await tester.pumpAndSettle();

      await ouvrirMenuCoulisses(tester);
      await tester.tap(find.text('Exporter des classes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exporter (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Partager…'));
      await tester.pumpAndSettle();

      expect(fichiers.enregistre, isNull);
      expect(fichiers.nomPartage, 'Classes.json');
      expect(Echange.importerClasses(fichiers.partage!), hasLength(2));
      expect(find.text('2 classes exportées.'), findsOneWidget);
    });

    testWidgets('on importe des classes depuis les coulisses', (tester) async {
      final bibliotheque = await demarrer(tester);
      fichiers.aOuvrir = Echange.exporterClasses([classe('Druide')]);

      await ouvrirMenuCoulisses(tester);
      await tester.tap(find.text('Importer des classes'));
      await tester.pumpAndSettle();

      expect(bibliotheque.coulisses.single.nom, 'Druide');
      expect(find.text('1 classe ajoutée'), findsOneWidget);
    });

    testWidgets(
      'on exporte puis réimporte une partie depuis la page de garde',
      (tester) async {
        final bibliotheque = await demarrer(tester);
        bibliotheque
          ..demarrer(nombreJoueurs: 3, nom: 'La couronne')
          ..fermer();
        await tester.pumpAndSettle();

        final options = find.byTooltip('Options de la partie');
        await tester.ensureVisible(options);
        await tester.pumpAndSettle();
        await tester.tap(options);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Exporter'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Enregistrer sur l\'appareil'));
        await tester.pumpAndSettle();
        expect(fichiers.nomEnregistre, 'La_couronne.json');

        fichiers.aOuvrir = fichiers.enregistre;
        // La confirmation de l'export recouvre le bas de la page.
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();
        final importer = find.text('Importer une partie');
        await tester.ensureVisible(importer);
        await tester.pumpAndSettle();
        await tester.tap(importer);
        await tester.pumpAndSettle();

        expect(bibliotheque.parties, hasLength(2));
        expect(find.text('« La couronne » importée.'), findsOneWidget);
      },
    );

    testWidgets('un fichier qui lance l\'application est importé', (
      tester,
    ) async {
      fichiers.recu = Echange.exporterPartie(
        Partie.neuve(nombreJoueurs: 2, nom: 'Reçue par mail'),
      );
      final bibliotheque = await demarrer(tester);

      expect(bibliotheque.parties.single.nom, 'Reçue par mail');
      expect(find.text('« Reçue par mail » importée.'), findsOneWidget);
    });

    testWidgets('un fichier ouvert pendant la partie est importé', (
      tester,
    ) async {
      final bibliotheque = await demarrer(tester);
      bibliotheque.demarrer(nombreJoueurs: 2);
      await tester.pumpAndSettle();

      fichiers.recu = Echange.exporterClasses([classe('Barde')]);
      fichiers.prevenir!();
      await tester.pumpAndSettle();

      expect(bibliotheque.coulisses.single.nom, 'Barde');
      expect(find.text('1 classe ajoutée'), findsOneWidget);
    });

    testWidgets('un fichier étranger est refusé sans planter', (tester) async {
      fichiers.recu = Uint8List.fromList(utf8.encode('{"autre": true}'));
      final bibliotheque = await demarrer(tester);

      expect(bibliotheque.parties, isEmpty);
      expect(find.textContaining('Import impossible'), findsOneWidget);
    });
  });
}
