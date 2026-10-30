import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/monstre.dart';
import '../widgets/champs.dart';
import 'fiche_monstre.dart';

/// Espace meneur de jeu : les fiches de monstres de la partie.
///
/// C'est la seconde page de l'écran de partie ; on l'atteint en balayant la
/// liste des héros de la droite vers la gauche.
class PageMeneurDeJeu extends StatelessWidget {
  const PageMeneurDeJeu({super.key});

  /// Ajoute une fiche de monstre vierge en fin de liste et l'ouvre aussitôt.
  void _ajouter(BuildContext context) {
    final monstre = BibliothequeScope.de(context).ajouterMonstre();
    if (monstre == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EcranFicheMonstre(monstre: monstre)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final partie = BibliothequeScope.de(context).courante;
    final monstres = partie?.monstres ?? const <Monstre>[];

    // Comme pour les héros, le bouton d'ajout ferme la liste : la fiche neuve
    // apparaît là où on l'attend, à la suite des autres.
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: monstres.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index < monstres.length) {
          return _CarteMonstre(monstre: monstres[index]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (monstres.isEmpty) ...[
              Icon(
                Icons.pest_control,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun monstre dans cette partie.\n'
                'Créez leurs fiches au fil des rencontres.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: () => _ajouter(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un monstre'),
            ),
          ],
        );
      },
    );
  }
}

class _CarteMonstre extends StatelessWidget {
  const _CarteMonstre({required this.monstre});

  final Monstre monstre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EcranFicheMonstre(monstre: monstre),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.errorContainer,
                child: Icon(
                  Icons.pest_control,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            monstre.nom.trim().isEmpty
                                ? 'Sans nom'
                                : monstre.nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Pastille(
                          libelle: 'Niv.',
                          valeur: '${monstre.niveau}',
                          couleur: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Pastille(
                          libelle: 'PV',
                          valeur: '${monstre.pvActuels}/${monstre.pvMax}',
                          couleur: theme.colorScheme.error,
                        ),
                        Pastille(
                          libelle: 'PM',
                          valeur: '${monstre.pmActuels}/${monstre.pmMax}',
                          couleur: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
