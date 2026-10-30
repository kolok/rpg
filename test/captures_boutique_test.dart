import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg/ecrans/accueil.dart';
import 'package:rpg/ecrans/coulisses.dart';
import 'package:rpg/main.dart';
import 'package:rpg/modeles/bibliotheque.dart';
import 'package:rpg/modeles/competence.dart';
import 'package:rpg/modeles/modele_classe.dart';
import 'package:rpg/modeles/monstre.dart';
import 'package:rpg/modeles/partie.dart';
import 'package:rpg/modeles/personnage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Génère les captures téléphone pour la fiche Google Play.
///
/// ```bash
/// GENERER_CAPTURES=1 flutter test test/captures_boutique_test.dart
/// ```
void main() {
  testWidgets('génère les captures Play Store', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(_sauvegardeVitrine());
    final bibliotheque = await Bibliotheque.charger();
    await tester.pumpWidget(ApplicationRpg(bibliotheque: bibliotheque));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await _enregistrer(tester, '01-accueil');

    await tester.tap(find.text('La table du dragon'));
    await tester.pumpAndSettle();
    await _enregistrer(tester, '02-les-heros');

    await tester.tap(find.text('Aria'));
    await tester.pumpAndSettle();
    await _enregistrer(tester, '03-fiche-personnage');

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meneur de jeu'));
    await tester.pumpAndSettle();
    await _enregistrer(tester, '04-meneur-de-jeu');

    await tester.tap(find.text('Lancer les dés'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'd20').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'd6').first);
    await tester.tap(find.widgetWithText(InkWell, 'd6').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('2. Appuyez sur les dés pour les lancer'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await _enregistrer(tester, '05-lancer-de-des');

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();

    final accueil = tester.element(find.byType(EcranAccueil));
    Navigator.of(accueil).push(
      MaterialPageRoute<void>(builder: (_) => const EcranCoulisses()),
    );
    await tester.pumpAndSettle();
    await _enregistrer(tester, '06-coulisses');
  }, skip: Platform.environment['GENERER_CAPTURES'] != '1');
}

Future<void> _enregistrer(WidgetTester tester, String nom) async {
  await tester.pump();
  await tester.runAsync(() async {
    final image = await captureImage(tester.element(find.byType(MaterialApp)));
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final fichier = File('store/captures/$nom.png');
    await fichier.parent.create(recursive: true);
    await fichier.writeAsBytes(png!.buffer.asUint8List());
  });
}

Map<String, Object> _sauvegardeVitrine() {
  const gardienId = 'gardien';
  const elementalisteId = 'elementaliste';

  final gardien = ModeleClasse(
    id: gardienId,
    nom: 'Gardien',
    atouts: ['Armure lourde', 'Bouclier'],
    competences: [
      Competence(
        nom: 'Frappe vigoureuse',
        description: 'Une attaque puissante au corps à corps.',
        ncMax: 5,
      ),
      Competence(
        nom: 'Provocation',
        description: 'Attire l’attention des ennemis.',
        ncMax: 3,
      ),
      Competence(
        nom: 'Garde rapprochée',
        description: 'Protège un allié adjacent.',
        ncMax: 4,
      ),
    ],
    competenceHeroique: Competence(
      nom: 'Rempart',
      description: 'Devient inébranlable jusqu’à la fin du tour.',
      ncMax: 1,
    ),
  );

  final elementaliste = ModeleClasse(
    id: elementalisteId,
    nom: 'Élémentaliste',
    atouts: ['Grimoire', 'Affinité élémentaire'],
    competences: [
      Competence(
        nom: 'Boule de feu',
        description: 'Projette une explosion enflammée.',
        ncMax: 5,
      ),
      Competence(
        nom: 'Éclair',
        description: 'Frappe une cible d’un trait électrique.',
        ncMax: 4,
      ),
    ],
    sorts: [
      Sort(nom: 'Étincelle', description: 'Une flamme brève, à portée de main.'),
    ],
    competenceHeroique: Competence(
      nom: 'Tempête intérieure',
      description: 'Libère les quatre éléments d’un coup.',
      ncMax: 1,
    ),
  );

  final aria = Personnage(
    nom: 'Aria',
    niveau: 12,
    pointsDeReussite: 5,
    zenits: 250,
    pvMax: 45,
    pvActuels: 38,
    pmMax: 28,
    pmActuels: 22,
    piMax: 8,
    piActuels: 3,
    defense: 11,
    defenseMagique: 9,
    initiative: -2,
    caracteristiques: {
      Caracteristique.puissance: 10,
      Caracteristique.dexterite: 8,
      Caracteristique.volonte: 6,
      Caracteristique.intuition: 12,
    },
    classes: [
      Classe(
        nom: 'Gardien',
        modeleId: gardienId,
        competences: [
          Competence(nom: 'Frappe vigoureuse', nc: 2, ncMax: 5),
          Competence(nom: 'Provocation', nc: 1, ncMax: 3),
          Competence(nom: 'Garde rapprochée', nc: 0, ncMax: 4),
          Competence(nom: 'Rempart', nc: 0, ncMax: 1),
        ],
      ),
    ],
    equipement: ['Épée longue', 'Bouclier en chêne'],
    inventaire: ['Potion', 'Corde'],
  );

  final kael = Personnage(
    nom: 'Kael',
    niveau: 11,
    pointsDeReussite: 4,
    zenits: 180,
    pvMax: 32,
    pvActuels: 32,
    pmMax: 44,
    pmActuels: 19,
    piMax: 6,
    piActuels: 6,
    defense: 8,
    defenseMagique: 12,
    initiative: 3,
    caracteristiques: {
      Caracteristique.puissance: 6,
      Caracteristique.dexterite: 8,
      Caracteristique.volonte: 12,
      Caracteristique.intuition: 10,
    },
    classes: [
      Classe(
        nom: 'Élémentaliste',
        modeleId: elementalisteId,
        competences: [
          Competence(nom: 'Boule de feu', nc: 3, ncMax: 5),
          Competence(nom: 'Éclair', nc: 2, ncMax: 4),
          Competence(nom: 'Tempête intérieure', nc: 0, ncMax: 1),
        ],
        sorts: [Sort(nom: 'Étincelle', description: 'Une flamme brève.')],
      ),
    ],
    equipement: ['Bâton runique'],
    inventaire: ['Composantes', 'Carnet de sorts'],
  );

  final table = Partie(
    id: 'table-dragon',
    nom: 'La table du dragon',
    modifiee: DateTime(2026, 8, 21, 21, 15),
    personnages: [aria, kael],
    monstres: [
      Monstre(
        nom: 'Gobelin éclaireur',
        niveau: 3,
        pvMax: 18,
        pvActuels: 11,
        pmMax: 8,
        pmActuels: 8,
        equipement: ['Dague de fortune'],
        competences: ['Embuscade', 'Fuite précipitée'],
      ),
      Monstre(
        nom: 'Troll des grottes',
        niveau: 8,
        pvMax: 60,
        pvActuels: 44,
        pmMax: 12,
        pmActuels: 6,
        equipement: ['Massue noueuse'],
        competences: ['Régénération', 'Coup écrasant'],
      ),
    ],
  );

  final hiver = Partie(
    id: 'campagne-hiver',
    nom: 'Campagne d’hiver',
    modifiee: DateTime(2026, 7, 3, 18, 40),
    personnages: [
      Personnage(nom: 'Nim', niveau: 4),
      Personnage(nom: 'Orok', niveau: 5),
      Personnage(nom: 'Sila', niveau: 4),
    ],
  );

  return {
    'parties': jsonEncode([table.versJson(), hiver.versJson()]),
    'coulisses': jsonEncode([gardien.versJson(), elementaliste.versJson()]),
  };
}
