import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/competence.dart';
import '../modeles/personnage.dart';
import '../widgets/champs.dart';
import 'coulisses.dart';
import 'des.dart';
import 'edition_classe.dart';

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
                'Son nom, ses compétences, ses sorts et sa compétence héroïque.',
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

          // 8. Les classes du personnage, résumées à leur nom et à leurs
          // compétences. Une fiche neuve n'en a aucune : le message dit où
          // commencer.
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
            _ResumeClasse(
              key: ValueKey('classe-$i-${personnage.classes.length}'),
              personnage: personnage,
              classe: personnage.classes[i],
              numero: i + 1,
            ),
            const SizedBox(height: 8),
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

/// Résumé d'une classe du personnage, en lecture seule et aussi serré que
/// possible : ses compétences avec leur NC, ses sorts sur une ligne, puis ses
/// compétences héroïques. Le bouton « Modifier » ouvre la page plein écran où
/// tout se change.
class _ResumeClasse extends StatelessWidget {
  const _ResumeClasse({
    super.key,
    required this.personnage,
    required this.classe,
    required this.numero,
  });

  final Personnage personnage;
  final Classe classe;
  final int numero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normal = theme.textTheme.bodyMedium;
    final discret = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontStyle: FontStyle.italic,
    );

    // Une compétence sur une ligne : son nom, puis son NC rapporté au
    // plafond des coulisses s'il y en a un.
    Widget ligneCompetence(Competence competence, {IconData? icone}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          if (icone != null) ...[
            Icon(icone, size: 14, color: theme.colorScheme.tertiary),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: competence.nom.trim().isEmpty
                ? Text('Compétence sans nom', style: discret)
                : Text(competence.nom.trim(), style: normal),
          ),
          const SizedBox(width: 8),
          Text(
            competence.ncMax > 0
                ? 'NC ${competence.nc} / ${competence.ncMax}'
                : 'NC ${competence.nc}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final sorts = [
      for (final sort in classe.sorts)
        sort.nom.trim().isEmpty ? 'Sort sans nom' : sort.nom.trim(),
    ];
    final vide =
        classe.competences.isEmpty &&
        sorts.isEmpty &&
        classe.competencesHeroiques.isEmpty;

    return SectionFiche(
      titre: classe.nom.trim().isEmpty ? 'Classe $numero' : classe.nom,
      icone: Icons.workspace_premium,
      compacte: true,
      action: TextButton.icon(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                EcranEditionClasse(personnage: personnage, classe: classe),
          ),
        ),
        icon: const Icon(Icons.edit, size: 16),
        label: const Text('Modifier'),
      ),
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vide)
            Text('Rien dans cette classe pour l\'instant.', style: discret),
          for (final competence in classe.competences)
            ligneCompetence(competence),
          if (sorts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: Text(sorts.join(' · '), style: normal)),
                ],
              ),
            ),
          for (final competence in classe.competencesHeroiques)
            ligneCompetence(competence, icone: Icons.local_fire_department),
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
