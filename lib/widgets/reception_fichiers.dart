import 'package:flutter/material.dart';

import '../modeles/fichiers.dart';
import 'import.dart';

/// Importe les fichiers ouverts avec l'application depuis une autre : au
/// lancement, puis à chaque fois qu'on en ouvre un pendant qu'elle tourne.
///
/// Placé autour de la page de garde, qui reste toujours en bas de la pile :
/// les dialogues et messages s'affichent par-dessus l'écran ouvert.
class ReceptionFichiers extends StatefulWidget {
  const ReceptionFichiers({super.key, required this.child});

  final Widget child;

  @override
  State<ReceptionFichiers> createState() => _ReceptionFichiersState();
}

class _ReceptionFichiersState extends State<ReceptionFichiers> {
  final Fichiers _fichiers = Fichiers.actuel;

  @override
  void initState() {
    super.initState();
    _fichiers.ecouterFichiersRecus(_relever);
    // Un fichier qui a lancé l'application attend que l'écran soit prêt.
    WidgetsBinding.instance.addPostFrameCallback((_) => _relever());
  }

  @override
  void dispose() {
    _fichiers.ecouterFichiersRecus(null);
    super.dispose();
  }

  Future<void> _relever() async {
    final octets = await _fichiers.fichierRecu();
    if (octets == null || !mounted) return;
    await importerFichierRecu(context, octets);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
