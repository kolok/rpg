import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/personnage.dart';
import '../widgets/champs.dart';
import 'fiche_personnage.dart';

/// Première page de l'écran de partie : la liste des fiches de personnages.
class PageListeHeros extends StatelessWidget {
  const PageListeHeros({super.key});

  /// Ajoute une fiche vierge en fin de liste et l'ouvre aussitôt.
  void _ajouter(BuildContext context) {
    final personnage = BibliothequeScope.de(context).ajouterPersonnage();
    if (personnage == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EcranFichePersonnage(personnage: personnage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partie = BibliothequeScope.de(context).courante;
    final personnages = partie?.personnages ?? const <Personnage>[];

    // Le dernier élément de la liste est le bouton d'ajout : on crée une
    // fiche là où on s'attend à la voir apparaître, à la suite des autres.
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: personnages.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index < personnages.length) {
          return _CartePersonnage(
            personnage: personnages[index],
            numero: index + 1,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (personnages.isEmpty) ...[
              const Text(
                'Aucune fiche dans cette partie.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: () => _ajouter(context),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Ajouter un personnage'),
            ),
          ],
        );
      },
    );
  }
}

class _CartePersonnage extends StatelessWidget {
  const _CartePersonnage({required this.personnage, required this.numero});

  final Personnage personnage;
  final int numero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classes = personnage.classes
        .map((c) => c.nom.trim())
        .where((nom) => nom.isNotEmpty);

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EcranFichePersonnage(personnage: personnage),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  '$numero',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Le niveau se lit à droite du nom, sans avoir à ouvrir
                    // la fiche.
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            personnage.nom.trim().isEmpty
                                ? 'Sans nom'
                                : personnage.nom,
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
                          valeur: '${personnage.niveau}',
                          couleur: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      classes.isEmpty ? 'Aucune classe' : classes.join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Pastille(
                          libelle: 'PV',
                          valeur: '${personnage.pvActuels}/${personnage.pvMax}',
                          couleur: theme.colorScheme.error,
                        ),
                        Pastille(
                          libelle: 'PM',
                          valeur: '${personnage.pmActuels}/${personnage.pmMax}',
                          couleur: theme.colorScheme.primary,
                        ),
                        Pastille(
                          libelle: 'PI',
                          valeur: '${personnage.piActuels}/${personnage.piMax}',
                          couleur: theme.colorScheme.tertiary,
                        ),
                        Pastille(
                          libelle: 'Réussite',
                          valeur: '${personnage.pointsDeReussite}',
                          couleur: theme.colorScheme.tertiary,
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
