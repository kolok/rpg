import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/competence.dart';
import '../modeles/modele_classe.dart';
import '../widgets/champs.dart';
import '../widgets/competences.dart';

/// Page d'une classe des coulisses : ce qu'on écrit une fois et qu'on reprend
/// ensuite sur n'importe quelle fiche de personnage.
class EcranFicheClasse extends StatelessWidget {
  const EcranFicheClasse({super.key, required this.classe});

  final ModeleClasse classe;

  /// Retire la classe des coulisses, après confirmation.
  Future<void> _supprimer(BuildContext context) async {
    final bibliotheque = BibliothequeScope.de(context);
    final navigateur = Navigator.of(context);
    final confirme = await confirmerSuppression(
      context,
      titre: 'Supprimer cette classe ?',
      message:
          'La page de « ${classe.nomAffiche} » sera effacée des coulisses. '
          'Les fiches de personnages qui s\'en sont inspirées gardent ce '
          'qui y a déjà été recopié.',
    );
    if (!confirme) return;
    bibliotheque.supprimerClasseCoulisses(classe);
    navigateur.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bibliotheque = BibliothequeScope.de(context);

    void modifier(void Function() changement) =>
        bibliotheque.modifierCoulisses(changement);

    return Scaffold(
      appBar: AppBar(title: Text(classe.nomAffiche)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // 1. Le nom de la classe.
          SectionFiche(
            titre: 'Nom de la classe',
            icone: Icons.workspace_premium,
            enfant: ChampTexte(
              libelle: 'Nom de la classe',
              valeur: classe.nom,
              indication: 'Ex. : Gardien, Élémentaliste…',
              auChangement: (v) => modifier(() => classe.nom = v),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Les atouts gratuits.
          SectionFiche(
            titre: 'Atouts gratuits',
            icone: Icons.card_giftcard,
            enfant: ListeTextes(
              valeurs: classe.atouts,
              indication: 'Ex. : +5 PV maximum',
              messageVide: 'Aucun atout gratuit.',
              auChangement: (v) => modifier(() => classe.atouts = v),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Les compétences, chacune avec son NC et sa description.
          SectionFiche(
            titre: 'Compétences',
            icone: Icons.auto_fix_high,
            enfant: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (classe.competences.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Aucune compétence pour cette classe.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                for (var i = 0; i < classe.competences.length; i++)
                  CarteCompetence(
                    // La clé lie la carte à sa position dans la liste.
                    key: ValueKey('competence-$i-${classe.competences.length}'),
                    competence: classe.competences[i],
                    libelle: 'Compétence ${i + 1}',
                    auChangement: modifier,
                    auSuppression: () =>
                        modifier(() => classe.competences.removeAt(i)),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        modifier(() => classe.competences.add(Competence())),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter une compétence'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Les sorts, facultatifs, jusqu'à dix.
          SectionFiche(
            titre: 'Sorts',
            icone: Icons.auto_awesome,
            action: Text(
              '${classe.sorts.length}/$sortsMaximum',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            enfant: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (classe.sorts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Les sorts sont facultatifs : seules les classes qui '
                      'en ont en portent.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                for (var i = 0; i < classe.sorts.length; i++)
                  CarteSort(
                    key: ValueKey('sort-$i-${classe.sorts.length}'),
                    sort: classe.sorts[i],
                    libelle: 'Sort ${i + 1}',
                    auChangement: modifier,
                    auSuppression: () =>
                        modifier(() => classe.sorts.removeAt(i)),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    // Au-delà de dix sorts, le bouton s'éteint.
                    onPressed: classe.sorts.length >= sortsMaximum
                        ? null
                        : () => modifier(() => classe.sorts.add(Sort())),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter un sort'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. La compétence héroïque, présentée comme une compétence normale.
          SectionFiche(
            titre: 'Compétence héroïque',
            icone: Icons.military_tech,
            enfant: CarteCompetence(
              competence: classe.competenceHeroique,
              libelle: 'Compétence héroïque',
              indicationNom: 'Ex. : Garde du rempart',
              auChangement: modifier,
            ),
          ),
          const SizedBox(height: 32),

          // 6. La zone de danger, tout en bas.
          ZoneDeDanger(
            explication:
                'Retirer cette classe des coulisses efface sa page pour de '
                'bon. Les fiches de personnages ne sont pas touchées.',
            libelleBouton: 'Supprimer cette classe',
            onSupprimer: () => _supprimer(context),
          ),
        ],
      ),
    );
  }
}
