import 'package:flutter/material.dart';

/// Encadré titré regroupant une section de la fiche de personnage.
class SectionFiche extends StatelessWidget {
  const SectionFiche({
    super.key,
    required this.titre,
    required this.icone,
    required this.enfant,
    this.action,
  });

  final String titre;
  final IconData icone;
  final Widget enfant;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icone, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titre.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                ?action,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: enfant,
          ),
        ],
      ),
    );
  }
}

/// Champ texte libre, enregistré à chaque frappe.
class ChampTexte extends StatefulWidget {
  const ChampTexte({
    super.key,
    required this.libelle,
    required this.valeur,
    required this.auChangement,
    this.indication,
  });

  final String libelle;
  final String valeur;
  final String? indication;
  final ValueChanged<String> auChangement;

  @override
  State<ChampTexte> createState() => _ChampTexteState();
}

class _ChampTexteState extends State<ChampTexte> {
  late final TextEditingController _controleur =
      TextEditingController(text: widget.valeur);

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controleur,
      decoration: InputDecoration(
        labelText: widget.libelle,
        hintText: widget.indication,
      ),
      textCapitalization: TextCapitalization.sentences,
      onChanged: widget.auChangement,
    );
  }
}

/// Compteur d'entier avec boutons − / + et saisie directe au clavier.
///
/// Pratique en pleine partie pour retirer des PV ou ajouter des zénits.
class CompteurEntier extends StatefulWidget {
  const CompteurEntier({
    super.key,
    required this.libelle,
    required this.valeur,
    required this.auChangement,
    this.pas = 1,
    this.minimum = 0,
    this.couleur,
    this.icone,
  });

  final String libelle;
  final int valeur;
  final ValueChanged<int> auChangement;
  final int pas;

  /// Valeur plancher, ou `null` pour autoriser les nombres négatifs
  /// (c'est le cas de l'initiative).
  final int? minimum;

  final Color? couleur;
  final IconData? icone;

  bool _tropPetit(int valeur) => minimum != null && valeur < minimum!;

  @override
  State<CompteurEntier> createState() => _CompteurEntierState();
}

class _CompteurEntierState extends State<CompteurEntier> {
  late final TextEditingController _controleur =
      TextEditingController(text: '${widget.valeur}');
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _valider();
    });
  }

  @override
  void didUpdateWidget(covariant CompteurEntier ancien) {
    super.didUpdateWidget(ancien);
    // Reflète les changements venus des boutons − / +.
    if (widget.valeur != ancien.valeur && !_focus.hasFocus) {
      _controleur.text = '${widget.valeur}';
    }
  }

  @override
  void dispose() {
    _controleur.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Enregistre la saisie au fil de la frappe, dès qu'elle est valide.
  void _saisie(String texte) {
    final valeur = int.tryParse(texte.trim());
    if (valeur == null || widget._tropPetit(valeur)) return;
    if (valeur != widget.valeur) widget.auChangement(valeur);
  }

  /// Remet le champ au propre quand on le quitte (saisie vide ou invalide).
  void _valider() {
    final saisie = int.tryParse(_controleur.text.trim());
    final valeur = saisie == null || widget._tropPetit(saisie)
        ? widget.valeur
        : saisie;
    if (_controleur.text != '$valeur') _controleur.text = '$valeur';
    if (valeur != widget.valeur) widget.auChangement(valeur);
  }

  void _decaler(int delta) {
    final nouvelle = widget.valeur + delta;
    final valeur = widget._tropPetit(nouvelle) ? widget.minimum! : nouvelle;
    _controleur.text = '$valeur';
    widget.auChangement(valeur);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleur = widget.couleur ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icone != null) ...[
              Icon(widget.icone, size: 16, color: couleur),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                widget.libelle,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              onPressed: widget._tropPetit(widget.valeur - widget.pas) &&
                      widget.valeur == widget.minimum
                  ? null
                  : () => _decaler(-widget.pas),
              icon: const Icon(Icons.remove, size: 18),
            ),
            Expanded(
              child: TextField(
                controller: _controleur,
                focusNode: _focus,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.numberWithOptions(
                  signed: widget.minimum == null,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: couleur,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _saisie,
                onSubmitted: (_) => _valider(),
              ),
            ),
            IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              onPressed: () => _decaler(widget.pas),
              icon: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

/// Une réserve du personnage : son maximum et ce qu'il en reste actuellement
/// (PV, PM, PI). La jauge montre d'un coup d'œil où en est le personnage.
class Reserve extends StatelessWidget {
  const Reserve({
    super.key,
    required this.sigle,
    required this.icone,
    required this.couleur,
    required this.maximum,
    required this.actuels,
    required this.auChangementMaximum,
    required this.auChangementActuels,
  });

  final String sigle;
  final IconData icone;
  final Color couleur;
  final int maximum;
  final int actuels;
  final ValueChanged<int> auChangementMaximum;
  final ValueChanged<int> auChangementActuels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Une réserve vidée puis un maximum à zéro ne doivent pas casser la jauge.
    final part = maximum <= 0 ? 0.0 : (actuels / maximum).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CompteurEntier(
                libelle: '$sigle max',
                icone: icone,
                couleur: couleur,
                valeur: maximum,
                auChangement: auChangementMaximum,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CompteurEntier(
                libelle: '$sigle actuels',
                icone: icone,
                couleur: couleur,
                valeur: actuels,
                auChangement: auChangementActuels,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: part,
            minHeight: 7,
            backgroundColor: couleur.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(couleur),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$actuels / $maximum',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Liste de textes libres : ajout, modification et suppression de lignes.
class ListeTextes extends StatelessWidget {
  const ListeTextes({
    super.key,
    required this.valeurs,
    required this.auChangement,
    required this.indication,
    this.messageVide = 'Aucun élément pour le moment.',
  });

  final List<String> valeurs;
  final ValueChanged<List<String>> auChangement;
  final String indication;
  final String messageVide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (valeurs.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              messageVide,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        for (var i = 0; i < valeurs.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: ChampTexte(
                    // La clé lie le champ à sa position dans la liste.
                    key: ValueKey('$i-${valeurs.length}'),
                    libelle: '${i + 1}',
                    valeur: valeurs[i],
                    indication: indication,
                    auChangement: (texte) {
                      final copie = [...valeurs];
                      copie[i] = texte;
                      auChangement(copie);
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Supprimer',
                  onPressed: () {
                    final copie = [...valeurs]..removeAt(i);
                    auChangement(copie);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => auChangement([...valeurs, '']),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ajouter'),
          ),
        ),
      ],
    );
  }
}
