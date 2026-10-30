import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import 'accueil.dart';
import 'des.dart';
import 'liste_personnages.dart';
import 'meneur_de_jeu.dart';

/// Écran 2 — la partie ouverte, en deux pages que l'on balaie latéralement :
/// la liste des héros, puis l'espace meneur de jeu et ses monstres.
class EcranPartieEnCours extends StatelessWidget {
  const EcranPartieEnCours({super.key});

  Future<void> _renommer(BuildContext context) async {
    final bibliotheque = BibliothequeScope.de(context);
    final partie = bibliotheque.courante;
    if (partie == null) return;
    final nom = await demanderNomPartie(context, nomActuel: partie.nom);
    if (nom == null) return;
    bibliotheque.renommer(partie, nom);
  }

  /// Quitte la partie : elle reste enregistrée dans la bibliothèque.
  void _quitter(BuildContext context) {
    BibliothequeScope.de(context).fermer();
    // Retour à la page de garde, d'où une autre partie peut être lancée.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final partie = BibliothequeScope.de(context).courante;

    // Deux onglets : le balayage de la droite vers la gauche ouvre l'espace
    // meneur de jeu, et les onglets disent qu'il est là.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(partie?.nom ?? 'Les héros'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Renommer la partie',
              onPressed: () => _renommer(context),
              icon: const Icon(Icons.drive_file_rename_outline),
            ),
            IconButton(
              tooltip: 'Quitter la partie',
              onPressed: () => _quitter(context),
              icon: const Icon(Icons.exit_to_app),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.groups), text: 'Les héros'),
              Tab(icon: Icon(Icons.pest_control), text: 'Meneur de jeu'),
            ],
          ),
        ),
        body: const TabBarView(children: [PageListeHeros(), PageMeneurDeJeu()]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EcranDes())),
          icon: const Icon(Icons.casino),
          label: const Text('Lancer les dés'),
        ),
      ),
    );
  }
}
