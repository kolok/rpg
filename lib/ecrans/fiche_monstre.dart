import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/monstre.dart';
import '../widgets/champs.dart';

/// Fiche d'un monstre, dans l'espace meneur de jeu.
///
/// Volontairement plus courte qu'une fiche de personnage : le meneur en tient
/// plusieurs à la fois, il n'y met que le nom, le niveau, les réserves,
/// l'équipement et les compétences.
class EcranFicheMonstre extends StatelessWidget {
  const EcranFicheMonstre({super.key, required this.monstre});

  final Monstre monstre;

  /// Retire la fiche de la partie, après confirmation, et revient à la liste.
  Future<void> _supprimer(BuildContext context) async {
    final bibliotheque = BibliothequeScope.de(context);
    final navigateur = Navigator.of(context);
    final nom = monstre.nom.trim().isEmpty
        ? 'cette fiche sans nom'
        : '« ${monstre.nom.trim()} »';
    final confirme = await confirmerSuppression(
      context,
      titre: 'Supprimer ce monstre ?',
      message:
          'La fiche de $nom sera définitivement effacée de la partie. '
          'Cette action est irréversible.',
    );
    if (!confirme) return;
    bibliotheque.supprimerMonstre(monstre);
    navigateur.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bibliotheque = BibliothequeScope.de(context);

    // Applique une modification à la fiche puis sauvegarde la partie.
    void modifier(void Function() changement) =>
        bibliotheque.modifier(changement);

    return Scaffold(
      appBar: AppBar(
        title: Text(monstre.nom.trim().isEmpty ? 'Monstre' : monstre.nom),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // 1. Le nom et le niveau.
          SectionFiche(
            titre: 'Identité',
            icone: Icons.pest_control,
            enfant: Column(
              children: [
                ChampTexte(
                  libelle: 'Nom du monstre',
                  valeur: monstre.nom,
                  indication: 'Ex. : Loup des cendres',
                  auChangement: (v) => modifier(() => monstre.nom = v),
                ),
                const SizedBox(height: 16),
                CompteurEntier(
                  libelle: 'Niveau',
                  icone: Icons.star,
                  valeur: monstre.niveau,
                  auChangement: (v) => modifier(() => monstre.niveau = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Les réserves : PV puis PM.
          SectionFiche(
            titre: 'Réserves',
            icone: Icons.favorite,
            enfant: Column(
              children: [
                Reserve(
                  sigle: 'PV',
                  icone: Icons.favorite,
                  couleur: theme.colorScheme.error,
                  maximum: monstre.pvMax,
                  actuels: monstre.pvActuels,
                  auChangementMaximum: (v) => modifier(() => monstre.pvMax = v),
                  auChangementActuels: (v) =>
                      modifier(() => monstre.pvActuels = v),
                ),
                const Divider(height: 32),
                Reserve(
                  sigle: 'PM',
                  icone: Icons.auto_awesome,
                  couleur: theme.colorScheme.primary,
                  maximum: monstre.pmMax,
                  actuels: monstre.pmActuels,
                  auChangementMaximum: (v) => modifier(() => monstre.pmMax = v),
                  auChangementActuels: (v) =>
                      modifier(() => monstre.pmActuels = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. L'équipement.
          SectionFiche(
            titre: 'Équipement',
            icone: Icons.shield_outlined,
            enfant: ListeTextes(
              valeurs: monstre.equipement,
              indication: 'Ex. : Griffes acérées, Cuirasse d\'os…',
              messageVide: 'Aucun équipement porté.',
              auChangement: (v) => modifier(() => monstre.equipement = v),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Les compétences.
          SectionFiche(
            titre: 'Compétences',
            icone: Icons.auto_fix_high,
            enfant: ListeTextes(
              valeurs: monstre.competences,
              indication: 'Ex. : Souffle de givre, Morsure venimeuse…',
              messageVide: 'Aucune compétence.',
              auChangement: (v) => modifier(() => monstre.competences = v),
            ),
          ),
          const SizedBox(height: 32),

          // 5. La zone de danger, tout en bas : on n'y arrive pas par hasard.
          ZoneDeDanger(
            explication:
                'Retirer ce monstre de la partie efface sa fiche pour de bon. '
                'Les autres fiches ne sont pas touchées.',
            libelleBouton: 'Supprimer ce monstre',
            onSupprimer: () => _supprimer(context),
          ),
        ],
      ),
    );
  }
}
