import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/echange.dart';
import '../modeles/modele_classe.dart';

/// Importe un fichier reçu d'une autre application, qu'il contienne des
/// classes ou une partie.
Future<void> importerFichierRecu(BuildContext context, Uint8List octets) {
  final ContenuEchange contenu;
  try {
    contenu = Echange.contenuDe(octets);
  } on FormatException catch (e) {
    _signalerEchec(context, e);
    return Future.value();
  }
  return switch (contenu) {
    ContenuEchange.classes => importerClassesDuFichier(context, octets),
    ContenuEchange.partie => importerPartieDuFichier(context, octets),
  };
}

/// Range dans les coulisses les classes d'un fichier JSON. Avant de
/// remplacer une classe déjà présente, on demande confirmation.
Future<void> importerClassesDuFichier(
  BuildContext context,
  Uint8List octets,
) async {
  final bibliotheque = BibliothequeScope.de(context);
  final messager = ScaffoldMessenger.of(context);

  final List<ModeleClasse> classes;
  try {
    classes = Echange.importerClasses(octets);
  } on FormatException catch (e) {
    _signalerEchec(context, e);
    return;
  }
  if (classes.isEmpty) {
    messager.showSnackBar(
      const SnackBar(content: Text('Ce fichier ne contient aucune classe.')),
    );
    return;
  }

  final aRemplacer = classes
      .map((c) => bibliotheque.classeCoulisses(c.id))
      .whereType<ModeleClasse>()
      .toList();
  if (aRemplacer.isNotEmpty) {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remplacer des classes ?'),
        content: Text(
          'Ces classes sont déjà dans les coulisses et seront remplacées '
          'par celles du fichier :\n'
          '${aRemplacer.map((c) => '• ${c.nomAffiche}').join('\n')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remplacer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;
  }

  final remplacees = bibliotheque.importerClasses(classes);
  final ajoutees = classes.length - remplacees;
  messager.showSnackBar(
    SnackBar(
      content: Text(
        [
          if (ajoutees > 0)
            ajoutees > 1 ? '$ajoutees classes ajoutées' : '1 classe ajoutée',
          if (remplacees > 0)
            remplacees > 1
                ? '$remplacees classes remplacées'
                : '1 classe remplacée',
        ].join(', '),
      ),
    ),
  );
}

/// Ajoute aux parties enregistrées celle d'un fichier JSON.
Future<void> importerPartieDuFichier(
  BuildContext context,
  Uint8List octets,
) async {
  final bibliotheque = BibliothequeScope.de(context);
  try {
    final partie = bibliotheque.importerPartie(Echange.importerPartie(octets));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('« ${partie.nom} » importée.')));
  } on FormatException catch (e) {
    _signalerEchec(context, e);
  }
}

void _signalerEchec(BuildContext context, FormatException e) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('Import impossible : ${e.message}')));
}
