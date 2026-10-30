import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/competence.dart';
import '../modeles/modele_classe.dart';
import '../modeles/personnage.dart';
import '../widgets/champs.dart';
import '../widgets/competences.dart';

/// Page plein écran d'une classe du personnage : son nom, ses compétences
/// avec leur description et leur NC, ses sorts et ses compétences
/// héroïques. La fiche n'en montre
/// qu'un résumé ; c'est ici qu'on modifie.
class EcranEditionClasse extends StatelessWidget {
  const EcranEditionClasse({
    super.key,
    required this.personnage,
    required this.classe,
  });

  final Personnage personnage;
  final Classe classe;

  /// Retire la classe de la fiche, après confirmation, et revient à la fiche.
  Future<void> _supprimer(BuildContext context, String nomAffiche) async {
    final bibliotheque = BibliothequeScope.de(context);
    final navigateur = Navigator.of(context);
    final confirme = await confirmerSuppression(
      context,
      titre: 'Supprimer cette classe ?',
      message:
          '« $nomAffiche » sera retirée de la fiche, avec ses compétences et '
          'ses sorts. Cette action est irréversible.',
    );
    if (!confirme) return;
    bibliotheque.modifier(() => personnage.classes.remove(classe));
    navigateur.pop();
  }

  /// Texte en retrait, pour les rubriques encore vides.
  Widget _messageVide(ThemeData theme, String texte) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      texte,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bibliotheque = BibliothequeScope.de(context);

    void modifier(void Function() changement) =>
        bibliotheque.modifier(changement);

    final numero = personnage.classes.indexOf(classe) + 1;
    final nomAffiche = classe.nom.trim().isEmpty
        ? 'Classe $numero'
        : classe.nom.trim();
    // Une classe qui ne vient pas des coulisses fixe elle-même ses plafonds.
    final vierge = classe.modeleId == null;
    // Trait discret entre deux compétences.
    final separateur = Divider(
      height: 1,
      thickness: 0.5,
      color: theme.colorScheme.outlineVariant,
    );

    return Scaffold(
      appBar: AppBar(title: Text(nomAffiche)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // 1. Le nom de la classe.
          SectionFiche(
            titre: 'Classe',
            icone: Icons.workspace_premium,
            enfant: ChampTexte(
              libelle: 'Classe $numero',
              valeur: classe.nom,
              indication: 'Ex. : Gardien, Élémentaliste…',
              auChangement: (v) => modifier(() => classe.nom = v),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Les compétences, avec leur description et leur NC.
          SectionFiche(
            titre: 'Compétences',
            icone: Icons.military_tech,
            enfant: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (classe.competences.isEmpty)
                  _messageVide(theme, 'Aucune compétence pour cette classe.'),
                for (var i = 0; i < classe.competences.length; i++) ...[
                  if (i > 0) separateur,
                  LigneCompetenceFiche(
                    // La clé lie la ligne à sa position dans la liste.
                    key: ValueKey('competence-$i-${classe.competences.length}'),
                    competence: classe.competences[i],
                    maximumModifiable: vierge,
                    libelle: 'Compétence ${i + 1}',
                    auChangement: modifier,
                    auSuppression: () =>
                        modifier(() => classe.competences.removeAt(i)),
                  ),
                ],
                TextButton.icon(
                  onPressed: () =>
                      modifier(() => classe.competences.add(Competence())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter une compétence'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Les sorts, recopiés des coulisses ou ajoutés ici.
          SectionFiche(
            titre: 'Sorts',
            icone: Icons.auto_awesome,
            enfant: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (classe.sorts.isEmpty)
                  _messageVide(theme, 'Aucun sort appris dans cette classe.'),
                for (var i = 0; i < classe.sorts.length; i++)
                  CarteSort(
                    key: ValueKey('sort-$i-${classe.sorts.length}'),
                    sort: classe.sorts[i],
                    libelle: 'Sort ${i + 1}',
                    auChangement: modifier,
                    auSuppression: () =>
                        modifier(() => classe.sorts.removeAt(i)),
                  ),
                TextButton.icon(
                  // Comme dans les coulisses, dix sorts au plus par classe.
                  onPressed: classe.sorts.length >= sortsMaximum
                      ? null
                      : () => modifier(() => classe.sorts.add(Sort())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter un sort'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Les compétences héroïques, recopiées des coulisses ou
          // ajoutées ici.
          SectionFiche(
            titre: 'Compétences héroïques',
            icone: Icons.local_fire_department,
            enfant: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (classe.competencesHeroiques.isEmpty)
                  _messageVide(
                    theme,
                    'Aucune compétence héroïque pour cette classe.',
                  ),
                for (
                  var i = 0;
                  i < classe.competencesHeroiques.length;
                  i++
                ) ...[
                  if (i > 0) separateur,
                  LigneCompetenceFiche(
                    key: ValueKey(
                      'heroique-$i-${classe.competencesHeroiques.length}',
                    ),
                    competence: classe.competencesHeroiques[i],
                    maximumModifiable: vierge,
                    libelle: 'Compétence héroïque ${i + 1}',
                    auChangement: modifier,
                    auSuppression: () =>
                        modifier(() => classe.competencesHeroiques.removeAt(i)),
                  ),
                ],
                TextButton.icon(
                  onPressed: () => modifier(
                    () => classe.competencesHeroiques.add(Competence()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter une compétence héroïque'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 5. La zone de danger, tout en bas.
          ZoneDeDanger(
            explication:
                'Retirer cette classe efface ses compétences et ses sorts de '
                'la fiche. Les coulisses ne sont pas touchées.',
            libelleBouton: 'Supprimer cette classe',
            onSupprimer: () => _supprimer(context, nomAffiche),
          ),
        ],
      ),
    );
  }
}
