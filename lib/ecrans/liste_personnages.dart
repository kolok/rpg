import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/personnage.dart';
import 'accueil.dart';
import 'des.dart';
import 'fiche_personnage.dart';

/// Écran 2 — liste des fiches de personnages de la partie.
class EcranListePersonnages extends StatelessWidget {
  const EcranListePersonnages({super.key});

  Future<void> _renommer(BuildContext context) async {
    final bibliotheque = BibliothequeScope.de(context);
    final partie = bibliotheque.courante;
    if (partie == null) return;
    final nom = await demanderNomPartie(context, nomActuel: partie.nom);
    if (nom == null) return;
    bibliotheque.renommer(partie, nom);
  }

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

  /// Quitte la partie : elle reste enregistrée dans la bibliothèque.
  void _quitter(BuildContext context) {
    BibliothequeScope.de(context).fermer();
    // Retour à la page de garde, d'où une autre partie peut être lancée.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final bibliotheque = BibliothequeScope.de(context);
    final partie = bibliotheque.courante;
    final personnages = partie?.personnages ?? const <Personnage>[];

    return Scaffold(
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
      ),
      // Le dernier élément de la liste est le bouton d'ajout : on crée une
      // fiche là où on s'attend à la voir apparaître, à la suite des autres.
      body: ListView.separated(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const EcranDes())),
        icon: const Icon(Icons.casino),
        label: const Text('Lancer les dés'),
      ),
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
                        _Pastille(
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
                        _Pastille(
                          libelle: 'PV',
                          valeur: '${personnage.pvActuels}/${personnage.pvMax}',
                          couleur: theme.colorScheme.error,
                        ),
                        _Pastille(
                          libelle: 'PM',
                          valeur: '${personnage.pmActuels}/${personnage.pmMax}',
                          couleur: theme.colorScheme.primary,
                        ),
                        _Pastille(
                          libelle: 'PI',
                          valeur: '${personnage.piActuels}/${personnage.piMax}',
                          couleur: theme.colorScheme.tertiary,
                        ),
                        _Pastille(
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

class _Pastille extends StatelessWidget {
  const _Pastille({
    required this.libelle,
    required this.valeur,
    required this.couleur,
  });

  final String libelle;
  final String valeur;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$libelle $valeur',
        style: TextStyle(
          color: couleur,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
