import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/competence.dart';
import '../modeles/personnage.dart';
import '../widgets/champs.dart';
import '../widgets/competences.dart';
import 'coulisses.dart';
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
    final nom = personnage.nom.trim().isEmpty
        ? 'cette fiche sans nom'
        : '« ${personnage.nom.trim()} »';
    final confirme = await confirmerSuppression(
      context,
      titre: 'Supprimer ce personnage ?',
      message:
          'La fiche de $nom sera définitivement effacée de la partie. '
          'Cette action est irréversible.',
    );
    if (!confirme) return;
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
        title: Text(personnage.nom.trim().isEmpty ? 'Fiche' : personnage.nom),
        actions: [
          IconButton(
            tooltip: 'Lancer les dés',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EcranDes())),
            icon: const Icon(Icons.casino),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // 1. Le nom et le niveau.
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
                  libelle: 'Niveau',
                  icone: Icons.star,
                  valeur: personnage.niveau,
                  auChangement: (v) => modifier(() => personnage.niveau = v),
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
                  auChangement: (v) =>
                      modifier(() => personnage.initiative = v),
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
          ZoneDeDanger(
            explication:
                'Retirer ce personnage de la partie efface sa fiche pour de '
                'bon. Les autres fiches ne sont pas touchées.',
            libelleBouton: 'Supprimer ce personnage',
            onSupprimer: () => _supprimer(context),
          ),
        ],
      ),
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

  /// Reprend une classe des coulisses : son nom passe sur la fiche, et le
  /// lien retenu sert à proposer ensuite ses compétences.
  Future<void> _reprendreClasse(BuildContext context) async {
    final modele = await choisirClasseCoulisses(context);
    if (modele == null) return;
    auChangement(() {
      classe.nom = modele.nom;
      classe.modeleId = modele.id;
    });
  }

  /// Ajoute à la fiche une compétence puisée dans la classe des coulisses.
  Future<void> _reprendreCompetence(BuildContext context) async {
    final bibliotheque = BibliothequeScope.de(context);
    final modele = bibliotheque.classeCoulisses(classe.modeleId);
    if (modele == null) {
      // Sans classe reprise des coulisses, on ne sait pas où puiser.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisissez d\'abord la classe dans les coulisses.'),
        ),
      );
      return;
    }
    final competence = await choisirCompetenceCoulisses(context, modele);
    if (competence == null) return;
    auChangement(() => classe.competences.add(competence));
  }

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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _reprendreClasse(context),
              icon: const Icon(Icons.workspace_premium, size: 18),
              label: const Text('Reprendre une classe des coulisses'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Compétences de cette classe',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
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
              auChangement: auChangement,
              auSuppression: () =>
                  auChangement(() => classe.competences.removeAt(i)),
            ),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () =>
                    auChangement(() => classe.competences.add(Competence())),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
              ),
              TextButton.icon(
                onPressed: () => _reprendreCompetence(context),
                icon: const Icon(Icons.workspace_premium, size: 18),
                label: const Text('Depuis les coulisses'),
              ),
            ],
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
