import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/competence.dart';
import '../modeles/modele_classe.dart';
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

  /// Demande d'où vient la nouvelle classe : des coulisses, ou de rien.
  Future<void> _ajouterClasse(BuildContext context) async {
    final bibliotheque = BibliothequeScope.de(context);
    final depuisCoulisses = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une classe'),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text('Copier une classe des coulisses'),
              subtitle: const Text(
                'Son nom et ses compétences, chacune au NC 0.',
              ),
              onTap: () => Navigator.of(context).pop(true),
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text('Créer une classe vierge'),
              subtitle: const Text('À écrire directement sur la fiche.'),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    if (depuisCoulisses == null) return;
    if (!depuisCoulisses) {
      bibliotheque.modifier(() => personnage.classes.add(Classe()));
      return;
    }
    if (!context.mounted) return;
    final modele = await choisirClasseCoulisses(context);
    if (modele == null) return;
    bibliotheque.modifier(
      () => personnage.classes.add(Classe.depuisModele(modele)),
    );
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

          // 8. Les classes du personnage, avec leurs compétences. Une fiche
          // neuve n'en a aucune : le message dit où commencer.
          if (personnage.classes.isEmpty) ...[
            SectionFiche(
              titre: 'Classes',
              icone: Icons.workspace_premium,
              enfant: Text(
                'Aucune classe sur cette fiche. Ajoutez-en une pour lui '
                'associer des compétences.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
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
            onPressed: () => _ajouterClasse(context),
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
    // Trait discret entre deux compétences, pour qu'on les distingue d'un
    // coup d'œil sans alourdir la fiche.
    final separateur = Divider(
      height: 1,
      thickness: 0.5,
      color: theme.colorScheme.outlineVariant,
    );

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
          const SizedBox(height: 20),
          Text(
            'Compétences de cette classe',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          if (classe.competences.isEmpty)
            _messageVide(theme, 'Aucune compétence pour cette classe.'),
          for (var i = 0; i < classe.competences.length; i++) ...[
            if (i > 0) separateur,
            LigneCompetenceFiche(
              // La clé lie la ligne à sa position dans la liste.
              key: ValueKey('competence-$i-${classe.competences.length}'),
              competence: classe.competences[i],
              libelle: 'Compétence ${i + 1}',
              auChangement: auChangement,
              auSuppression: () =>
                  auChangement(() => classe.competences.removeAt(i)),
            ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  auChangement(() => classe.competences.add(Competence())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter une compétence'),
            ),
          ),
          const SizedBox(height: 20),
          // Les sorts ne suivent jamais la classe recopiée : le personnage
          // n'apprend que ceux qu'on lui ajoute ici.
          Text('Sorts de cette classe', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          if (classe.sorts.isEmpty)
            _messageVide(theme, 'Aucun sort appris dans cette classe.'),
          for (var i = 0; i < classe.sorts.length; i++)
            CarteSort(
              key: ValueKey('sort-$i-${classe.sorts.length}'),
              sort: classe.sorts[i],
              libelle: 'Sort ${i + 1}',
              auChangement: auChangement,
              auSuppression: () => auChangement(() => classe.sorts.removeAt(i)),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              // Comme dans les coulisses, dix sorts au plus par classe.
              onPressed: classe.sorts.length >= sortsMaximum
                  ? null
                  : () => auChangement(() => classe.sorts.add(Sort())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter un sort'),
            ),
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
