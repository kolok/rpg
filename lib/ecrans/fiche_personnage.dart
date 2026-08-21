import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/personnage.dart';
import '../widgets/champs.dart';
import 'des.dart';

/// Écran 3 — fiche détaillée d'un personnage, entièrement modifiable
/// pendant la partie.
class EcranFichePersonnage extends StatelessWidget {
  const EcranFichePersonnage({super.key, required this.personnage});

  final Personnage personnage;

  /// Retire la fiche de la partie, après confirmation, et revient à la liste.
  Future<void> _supprimer(BuildContext context) async {
    final bibliotheque = BibliothequeScope.de(context);
    final navigateur = Navigator.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogueSuppression(personnage: personnage),
    );
    if (confirme != true) return;
    bibliotheque.supprimerPersonnage(personnage);
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
        title: Text(
          personnage.nom.trim().isEmpty ? 'Fiche' : personnage.nom,
        ),
        actions: [
          IconButton(
            tooltip: 'Lancer les dés',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EcranDes()),
            ),
            icon: const Icon(Icons.casino),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // 1. Le nom et les points d'expérience.
          SectionFiche(
            titre: 'Identité',
            icone: Icons.badge,
            enfant: Column(
              children: [
                ChampTexte(
                  libelle: 'Nom du personnage',
                  valeur: personnage.nom,
                  indication: 'Ex. : Aria de Vesper',
                  auChangement: (v) => modifier(() => personnage.nom = v),
                ),
                const SizedBox(height: 16),
                CompteurEntier(
                  libelle: 'Points d\'expérience',
                  icone: Icons.star,
                  valeur: personnage.experience,
                  auChangement: (v) => modifier(() => personnage.experience = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Les points de réussite.
          SectionFiche(
            titre: 'Points de réussite',
            icone: Icons.auto_stories,
            enfant: CompteurEntier(
              libelle: 'Points de réussite',
              icone: Icons.auto_stories,
              couleur: theme.colorScheme.tertiary,
              valeur: personnage.pointsDeReussite,
              auChangement: (v) =>
                  modifier(() => personnage.pointsDeReussite = v),
            ),
          ),
          const SizedBox(height: 16),

          // 3, 4 et 5. Les réserves : PV, PM puis PI.
          SectionFiche(
            titre: 'Réserves',
            icone: Icons.favorite,
            enfant: Column(
              children: [
                Reserve(
                  sigle: 'PV',
                  icone: Icons.favorite,
                  couleur: theme.colorScheme.error,
                  maximum: personnage.pvMax,
                  actuels: personnage.pvActuels,
                  auChangementMaximum: (v) =>
                      modifier(() => personnage.pvMax = v),
                  auChangementActuels: (v) =>
                      modifier(() => personnage.pvActuels = v),
                ),
                const Divider(height: 32),
                Reserve(
                  sigle: 'PM',
                  icone: Icons.auto_awesome,
                  couleur: theme.colorScheme.primary,
                  maximum: personnage.pmMax,
                  actuels: personnage.pmActuels,
                  auChangementMaximum: (v) =>
                      modifier(() => personnage.pmMax = v),
                  auChangementActuels: (v) =>
                      modifier(() => personnage.pmActuels = v),
                ),
                const Divider(height: 32),
                Reserve(
                  sigle: 'PI',
                  icone: Icons.backpack,
                  couleur: theme.colorScheme.tertiary,
                  maximum: personnage.piMax,
                  actuels: personnage.piActuels,
                  auChangementMaximum: (v) =>
                      modifier(() => personnage.piMax = v),
                  auChangementActuels: (v) =>
                      modifier(() => personnage.piActuels = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 6. Défense, défense magique et initiative.
          SectionFiche(
            titre: 'Défense & initiative',
            icone: Icons.shield,
            enfant: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CompteurEntier(
                        libelle: 'Défense',
                        icone: Icons.shield,
                        valeur: personnage.defense,
                        auChangement: (v) =>
                            modifier(() => personnage.defense = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CompteurEntier(
                        libelle: 'Défense magique',
                        icone: Icons.shield_moon,
                        valeur: personnage.defenseMagique,
                        auChangement: (v) =>
                            modifier(() => personnage.defenseMagique = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CompteurEntier(
                  libelle: 'Initiative (peut être négative)',
                  icone: Icons.bolt,
                  // Pas de plancher : les malus d'armure descendent sous zéro.
                  minimum: null,
                  valeur: personnage.initiative,
                  auChangement: (v) => modifier(() => personnage.initiative = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 7. Les dés des caractéristiques.
          SectionFiche(
            titre: 'Dés',
            icone: Icons.casino_outlined,
            enfant: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisissez le dé associé à chaque caractéristique.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                for (final caracteristique in Caracteristique.values)
                  _ChoixDeCaracteristique(
                    caracteristique: caracteristique,
                    valeur: personnage.caracteristiques[caracteristique]!,
                    auChangement: (de) => modifier(
                      () => personnage.caracteristiques[caracteristique] = de,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 8, 9, 10. Chaque classe avec les compétences qui lui sont associées.
          for (var i = 0; i < personnage.classes.length; i++) ...[
            _CarteClasse(
              key: ValueKey('classe-$i-${personnage.classes.length}'),
              classe: personnage.classes[i],
              numero: i + 1,
              auChangement: modifier,
              auSuppression: () =>
                  modifier(() => personnage.classes.removeAt(i)),
            ),
            const SizedBox(height: 16),
          ],
          OutlinedButton.icon(
            onPressed: () => modifier(() => personnage.classes.add(Classe())),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une classe'),
          ),
          const SizedBox(height: 16),

          // 11. L'équipement.
          SectionFiche(
            titre: 'Équipement',
            icone: Icons.shield_outlined,
            enfant: ListeTextes(
              valeurs: personnage.equipement,
              indication: 'Ex. : Épée longue, Armure de cuir…',
              messageVide: 'Aucun équipement porté.',
              auChangement: (v) => modifier(() => personnage.equipement = v),
            ),
          ),
          const SizedBox(height: 16),

          // 12. L'inventaire, sans limite de nombre d'objets.
          SectionFiche(
            titre: 'Inventaire',
            icone: Icons.backpack,
            action: Text(
              '${personnage.inventaire.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            enfant: ListeTextes(
              valeurs: personnage.inventaire,
              indication: 'Ex. : Potion, Corde, Clé rouillée…',
              messageVide: 'Sac vide.',
              auChangement: (v) => modifier(() => personnage.inventaire = v),
            ),
          ),
          const SizedBox(height: 16),

          // 13. Les zénits.
          SectionFiche(
            titre: 'Zénits',
            icone: Icons.monetization_on,
            enfant: CompteurEntier(
              libelle: 'Zénits',
              icone: Icons.monetization_on,
              pas: 10,
              valeur: personnage.zenits,
              auChangement: (v) => modifier(() => personnage.zenits = v),
            ),
          ),
          const SizedBox(height: 32),

          // 14. La zone de danger, tout en bas : on n'y arrive pas par hasard.
          _ZoneDeDanger(onSupprimer: () => _supprimer(context)),
        ],
      ),
    );
  }
}

/// Encadré rouge de fin de fiche, isolant l'action irréversible.
class _ZoneDeDanger extends StatelessWidget {
  const _ZoneDeDanger({required this.onSupprimer});

  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 10),
                Text(
                  'ZONE DE DANGER',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Retirer ce personnage de la partie efface sa fiche pour de '
              'bon. Les autres fiches ne sont pas touchées.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onSupprimer,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer ce personnage'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmation avant de supprimer une fiche.
class _DialogueSuppression extends StatelessWidget {
  const _DialogueSuppression({required this.personnage});

  final Personnage personnage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nom = personnage.nom.trim().isEmpty
        ? 'cette fiche sans nom'
        : '« ${personnage.nom.trim()} »';
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
      title: const Text('Supprimer ce personnage ?'),
      content: Text(
        'La fiche de $nom sera définitivement effacée de la partie. '
        'Cette action est irréversible.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}

/// Une classe du personnage et les compétences qui lui sont associées.
class _CarteClasse extends StatelessWidget {
  const _CarteClasse({
    super.key,
    required this.classe,
    required this.numero,
    required this.auChangement,
    required this.auSuppression,
  });

  final Classe classe;
  final int numero;
  final void Function(void Function()) auChangement;
  final VoidCallback auSuppression;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionFiche(
      titre: classe.nom.trim().isEmpty ? 'Classe $numero' : classe.nom,
      icone: Icons.workspace_premium,
      action: IconButton(
        tooltip: 'Supprimer cette classe',
        visualDensity: VisualDensity.compact,
        onPressed: auSuppression,
        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
      ),
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChampTexte(
            libelle: 'Classe $numero',
            valeur: classe.nom,
            indication: 'Ex. : Gardien, Élémentaliste…',
            auChangement: (v) => auChangement(() => classe.nom = v),
          ),
          const SizedBox(height: 16),
          Text(
            'Compétences de cette classe',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          ListeTextes(
            valeurs: classe.competences,
            indication: 'Ex. : Frappe vigoureuse (niv. 2)…',
            messageVide: 'Aucune compétence pour cette classe.',
            auChangement: (v) => auChangement(() => classe.competences = v),
          ),
        ],
      ),
    );
  }
}

/// Sélecteur du dé associé à une caractéristique (d6 → d12).
class _ChoixDeCaracteristique extends StatelessWidget {
  const _ChoixDeCaracteristique({
    required this.caracteristique,
    required this.valeur,
    required this.auChangement,
  });

  final Caracteristique caracteristique;
  final int valeur;
  final ValueChanged<int> auChangement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              caracteristique.libelle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              segments: [
                for (final faces in desCaracteristiques)
                  ButtonSegment(value: faces, label: Text('d$faces')),
              ],
              selected: {valeur},
              onSelectionChanged: (choix) => auChangement(choix.first),
            ),
          ),
        ],
      ),
    );
  }
}
