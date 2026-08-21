import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/partie.dart';
import 'liste_personnages.dart';

/// Écran 1 — page de garde : présentation, parties enregistrées et démarrage
/// d'une nouvelle partie.
class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  Future<void> _nouvellePartie(BuildContext context) async {
    final bibliotheque = BibliothequeScope.de(context);
    final reglages = await showDialog<ReglagesNouvellePartie>(
      context: context,
      builder: (_) => const _DialogueNouvellePartie(),
    );
    if (reglages == null || !context.mounted) return;

    bibliotheque.demarrer(nombreJoueurs: reglages.joueurs, nom: reglages.nom);
    _ouvrirEcranPartie(context);
  }

  void _reprendre(BuildContext context, Partie partie) {
    BibliothequeScope.de(context).ouvrir(partie);
    _ouvrirEcranPartie(context);
  }

  void _ouvrirEcranPartie(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EcranListePersonnages()));
  }

  Future<void> _renommer(BuildContext context, Partie partie) async {
    final bibliotheque = BibliothequeScope.de(context);
    final nom = await demanderNomPartie(context, nomActuel: partie.nom);
    if (nom == null) return;
    bibliotheque.renommer(partie, nom);
  }

  Future<void> _supprimer(BuildContext context, Partie partie) async {
    final bibliotheque = BibliothequeScope.de(context);
    final theme = Theme.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Supprimer « ${partie.nom} » ?'),
        content: const Text(
          'Toutes les fiches de cette partie seront définitivement effacées. '
          'Vos autres parties ne sont pas touchées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme == true) bibliotheque.supprimer(partie);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parties = BibliothequeScope.de(context).parties;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/icone.png',
                        width: 96,
                        height: 96,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'RPG',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fiches de personnages & lancer de dés',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _Explication(
                              icone: Icons.groups,
                              texte:
                                  'Nommez votre partie et choisissez le '
                                  'nombre de joueurs (de 2 à 15) : une fiche '
                                  'vierge est créée pour chacun.',
                            ),
                            SizedBox(height: 16),
                            _Explication(
                              icone: Icons.edit_note,
                              texte:
                                  'Remplissez et modifiez chaque fiche à '
                                  'tout moment pendant la partie.',
                            ),
                            SizedBox(height: 16),
                            _Explication(
                              icone: Icons.casino,
                              texte:
                                  'Lancez vos dés (d4, d6, d8, d10, d12, '
                                  'd20) directement depuis l\'application.',
                            ),
                            SizedBox(height: 16),
                            _Explication(
                              icone: Icons.save,
                              texte:
                                  'Gardez autant de parties que vous voulez '
                                  'en parallèle : tout est enregistré sur '
                                  'l\'appareil, sans connexion internet.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (parties.isNotEmpty) ...[
                      Text(
                        'Vos parties',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final partie in parties) ...[
                        _CartePartie(
                          partie: partie,
                          auClic: () => _reprendre(context, partie),
                          auRenommage: () => _renommer(context, partie),
                          auxSuppression: () => _supprimer(context, partie),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 18),
                    ],
                    FilledButton.icon(
                      onPressed: () => _nouvellePartie(context),
                      icon: const Icon(Icons.add),
                      label: Text(
                        parties.isEmpty
                            ? 'Démarrer la partie'
                            : 'Nouvelle partie',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Une partie enregistrée dans la liste de la page de garde.
class _CartePartie extends StatelessWidget {
  const _CartePartie({
    required this.partie,
    required this.auClic,
    required this.auRenommage,
    required this.auxSuppression,
  });

  final Partie partie;
  final VoidCallback auClic;
  final VoidCallback auRenommage;
  final VoidCallback auxSuppression;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: auClic,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.play_arrow,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          partie.nom,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(partie.resume),
        trailing: PopupMenuButton<String>(
          tooltip: 'Options de la partie',
          onSelected: (choix) {
            if (choix == 'renommer') auRenommage();
            if (choix == 'supprimer') auxSuppression();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'renommer',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Renommer'),
              ),
            ),
            PopupMenuItem(
              value: 'supprimer',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Supprimer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Explication extends StatelessWidget {
  const _Explication({required this.icone, required this.texte});

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(child: Text(texte, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

/// Réponse du dialogue de création : le nom de la partie et son nombre de
/// joueurs.
class ReglagesNouvellePartie {
  const ReglagesNouvellePartie({required this.nom, required this.joueurs});

  final String nom;
  final int joueurs;
}

/// Demande le nom de la partie et le nombre de joueurs, entre 2 et 15.
class _DialogueNouvellePartie extends StatefulWidget {
  const _DialogueNouvellePartie();

  @override
  State<_DialogueNouvellePartie> createState() =>
      _DialogueNouvellePartieState();
}

class _DialogueNouvellePartieState extends State<_DialogueNouvellePartie> {
  late final TextEditingController _nom = TextEditingController(
    text: Partie.nomParDefaut(DateTime.now()),
  );
  int _nombre = 4;

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  void _valider() {
    Navigator.of(
      context,
    ).pop(ReglagesNouvellePartie(nom: _nom.text, joueurs: _nombre));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Nouvelle partie'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nom,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nom de la partie',
                hintText: 'Ex. : La couronne d\'ambre',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _valider(),
            ),
            const SizedBox(height: 24),
            Text('Nombre de joueurs', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'De ${Partie.minJoueurs} à ${Partie.maxJoueurs} joueurs.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  onPressed: _nombre > Partie.minJoueurs
                      ? () => setState(() => _nombre--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_nombre',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _nombre < Partie.maxJoueurs
                      ? () => setState(() => _nombre++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Slider(
              value: _nombre.toDouble(),
              min: Partie.minJoueurs.toDouble(),
              max: Partie.maxJoueurs.toDouble(),
              divisions: Partie.maxJoueurs - Partie.minJoueurs,
              label: '$_nombre',
              onChanged: (v) => setState(() => _nombre = v.round()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _valider,
          child: const Text('Créer les fiches'),
        ),
      ],
    );
  }
}

/// Petit dialogue de saisie du nom d'une partie, réutilisé pour renommer.
/// Répond `null` si l'on annule.
Future<String?> demanderNomPartie(
  BuildContext context, {
  required String nomActuel,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _DialogueNom(nomActuel: nomActuel),
  );
}

/// Le champ vit dans un widget à état : son contrôleur n'est libéré qu'une
/// fois le dialogue réellement retiré de l'écran, pas dès sa fermeture.
class _DialogueNom extends StatefulWidget {
  const _DialogueNom({required this.nomActuel});

  final String nomActuel;

  @override
  State<_DialogueNom> createState() => _DialogueNomState();
}

class _DialogueNomState extends State<_DialogueNom> {
  late final TextEditingController _controleur = TextEditingController(
    text: widget.nomActuel,
  );

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  void _valider() => Navigator.of(context).pop(_controleur.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nom de la partie'),
      content: TextField(
        controller: _controleur,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onSubmitted: (_) => _valider(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _valider, child: const Text('Enregistrer')),
      ],
    );
  }
}
