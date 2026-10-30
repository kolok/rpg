import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../modeles/fichiers.dart';

/// Façons de sortir un fichier exporté de l'application.
enum _Sortie { enregistrer, partager }

/// Propose d'enregistrer le fichier sur l'appareil ou de le partager en
/// pièce jointe (mail, messagerie, Drive…), puis confirme par [confirmation].
Future<void> exporterFichier(
  BuildContext context, {
  required String nom,
  required Uint8List octets,
  required String confirmation,
}) async {
  final messager = ScaffoldMessenger.of(context);
  final fichiers = Fichiers.actuel;

  // La bulle de partage de l'iPad s'accroche à l'écran qui exporte.
  final boite = context.findRenderObject() as RenderBox?;
  final origine = boite == null
      ? null
      : boite.localToGlobal(Offset.zero) & boite.size;

  final sortie = fichiers.partageDisponible
      ? await showModalBottomSheet<_Sortie>(
          context: context,
          showDragHandle: true,
          builder: (feuilleContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('Enregistrer sur l\'appareil'),
                  subtitle: Text(nom),
                  onTap: () =>
                      Navigator.of(feuilleContext).pop(_Sortie.enregistrer),
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Partager…'),
                  subtitle: const Text('En pièce jointe : mail, messagerie…'),
                  onTap: () =>
                      Navigator.of(feuilleContext).pop(_Sortie.partager),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        )
      : _Sortie.enregistrer;
  if (sortie == null) return;

  final fait = switch (sortie) {
    _Sortie.enregistrer => await fichiers.enregistrer(nom: nom, octets: octets),
    _Sortie.partager => await fichiers.partager(
      nom: nom,
      octets: octets,
      origine: origine,
    ),
  };
  if (!fait) return;
  messager.showSnackBar(SnackBar(content: Text(confirmation)));
}
