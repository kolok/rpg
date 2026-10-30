import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/modele_classe.dart';
import 'fiche_classe.dart';

/// Les coulisses : les classes enregistrées, disponibles pour toutes les
/// parties et toutes les fiches de personnages.
class EcranCoulisses extends StatelessWidget {
  const EcranCoulisses({super.key});

  /// Crée une page de classe vierge et l'ouvre aussitôt.
  void _ajouter(BuildContext context) {
    final classe = BibliothequeScope.de(context).ajouterClasseCoulisses();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EcranFicheClasse(classe: classe)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classes = BibliothequeScope.de(context).coulisses;

    return Scaffold(
      appBar: AppBar(title: const Text('Coulisses')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: classes.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index < classes.length) {
            return _CarteClasseCoulisses(classe: classes[index]);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (classes.isEmpty) ...[
                Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune classe enregistrée.\n'
                  'Écrivez-les une fois : elles seront ensuite à portée de '
                  'main sur toutes vos fiches de personnages.',
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
                label: const Text('Créer une classe'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CarteClasseCoulisses extends StatelessWidget {
  const _CarteClasseCoulisses({required this.classe});

  final ModeleClasse classe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.workspace_premium,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          classe.nomAffiche,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(classe.resume),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EcranFicheClasse(classe: classe)),
        ),
      ),
    );
  }
}

/// Propose les classes des coulisses et renvoie celle qui a été choisie.
Future<ModeleClasse?> choisirClasseCoulisses(BuildContext context) {
  final classes = BibliothequeScope.de(context).coulisses;
  return showDialog<ModeleClasse>(
    context: context,
    builder: (context) => _DialogueChoix(
      titre: 'Classes des coulisses',
      messageVide:
          'Les coulisses sont vides. Créez-y une classe depuis la page de '
          'garde : elle sera ensuite proposée ici.',
      lignes: [
        for (final classe in classes)
          _LigneChoix(
            titre: classe.nomAffiche,
            sousTitre: classe.resume,
            valeur: classe,
          ),
      ],
    ),
  );
}

class _LigneChoix<T> {
  const _LigneChoix({
    required this.titre,
    required this.valeur,
    this.sousTitre = '',
  });

  final String titre;
  final String sousTitre;
  final T valeur;
}

/// Liste de choix puisée dans les coulisses.
class _DialogueChoix<T> extends StatelessWidget {
  const _DialogueChoix({
    required this.titre,
    required this.messageVide,
    required this.lignes,
  });

  final String titre;
  final String messageVide;
  final List<_LigneChoix<T>> lignes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(titre),
      content: lignes.isEmpty
          ? Text(messageVide)
          : SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final ligne in lignes)
                    ListTile(
                      leading: Icon(
                        Icons.workspace_premium,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(ligne.titre),
                      subtitle: ligne.sousTitre.isEmpty
                          ? null
                          : Text(
                              ligne.sousTitre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () => Navigator.of(context).pop(ligne.valeur),
                    ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
