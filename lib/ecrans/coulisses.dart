import 'package:flutter/material.dart';

import '../modeles/bibliotheque.dart';
import '../modeles/echange.dart';
import '../modeles/fichiers.dart';
import '../modeles/modele_classe.dart';
import '../widgets/export.dart';
import '../widgets/import.dart';
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

  /// Fait choisir les classes à exporter, puis les enregistre ou les
  /// partage dans un fichier JSON.
  Future<void> _exporter(BuildContext context) async {
    final classes = await showDialog<List<ModeleClasse>>(
      context: context,
      builder: (_) => _DialogueExportClasses(
        classes: BibliothequeScope.de(context).coulisses,
      ),
    );
    if (classes == null || classes.isEmpty || !context.mounted) return;

    await exporterFichier(
      context,
      nom: classes.length == 1
          ? Echange.nomDeFichier('Classe ${classes.single.nomAffiche}')
          : Echange.nomDeFichier('Classes'),
      octets: Echange.exporterClasses(classes),
      confirmation: classes.length > 1
          ? '${classes.length} classes exportées.'
          : '1 classe exportée.',
    );
  }

  /// Range dans les coulisses les classes d'un fichier JSON choisi.
  Future<void> _importer(BuildContext context) async {
    final octets = await Fichiers.actuel.ouvrir();
    if (octets == null || !context.mounted) return;
    await importerClassesDuFichier(context, octets);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classes = BibliothequeScope.de(context).coulisses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coulisses'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Options des coulisses',
            onSelected: (choix) {
              if (choix == 'exporter') _exporter(context);
              if (choix == 'importer') _importer(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'exporter',
                enabled: classes.isNotEmpty,
                child: const ListTile(
                  leading: Icon(Icons.upload_file),
                  title: Text('Exporter des classes'),
                ),
              ),
              const PopupMenuItem(
                value: 'importer',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Importer des classes'),
                ),
              ),
            ],
          ),
        ],
      ),
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

/// Choix des classes à exporter : toutes cochées au départ, avec une case
/// générale pour tout cocher ou tout décocher d'un coup.
class _DialogueExportClasses extends StatefulWidget {
  const _DialogueExportClasses({required this.classes});

  final List<ModeleClasse> classes;

  @override
  State<_DialogueExportClasses> createState() => _DialogueExportClassesState();
}

class _DialogueExportClassesState extends State<_DialogueExportClasses> {
  late final Set<String> _cochees = {for (final c in widget.classes) c.id};

  /// Cochée si tout l'est, vide si rien ne l'est, à moitié sinon.
  bool? get _toutes {
    if (_cochees.isEmpty) return false;
    if (_cochees.length == widget.classes.length) return true;
    return null;
  }

  void _basculerToutes() {
    setState(() {
      if (_toutes == true) {
        _cochees.clear();
      } else {
        _cochees.addAll(widget.classes.map((c) => c.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _cochees.length;
    return AlertDialog(
      title: const Text('Exporter des classes'),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              tristate: true,
              value: _toutes,
              onChanged: (_) => _basculerToutes(),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Toutes les classes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final classe in widget.classes)
                    CheckboxListTile(
                      value: _cochees.contains(classe.id),
                      onChanged: (coche) => setState(() {
                        if (coche == true) {
                          _cochees.add(classe.id);
                        } else {
                          _cochees.remove(classe.id);
                        }
                      }),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(classe.nomAffiche),
                      subtitle: Text(
                        classe.resume,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
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
          onPressed: nombre == 0
              ? null
              : () => Navigator.of(context).pop([
                  for (final classe in widget.classes)
                    if (_cochees.contains(classe.id)) classe,
                ]),
          child: Text('Exporter ($nombre)'),
        ),
      ],
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
