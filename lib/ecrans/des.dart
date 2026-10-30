import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/forme_de.dart';

/// Les dés disponibles dans le jeu.
const List<int> desDisponibles = [4, 6, 8, 10, 12, 20];

/// Un dé lancé et son résultat.
class _Lancer {
  _Lancer(this.faces, this.resultat);

  final int faces;
  final int resultat;
}

/// Écran 4 — choix des dés puis lancer.
class EcranDes extends StatefulWidget {
  const EcranDes({super.key});

  @override
  State<EcranDes> createState() => _EcranDesState();
}

class _EcranDesState extends State<EcranDes> {
  final Random _hasard = Random();

  /// Nombre de dés sélectionnés pour chaque type (ex. {6: 2} = deux d6).
  final Map<int, int> _selection = {};

  List<_Lancer> _resultats = [];
  bool _enCours = false;
  Timer? _animation;

  int get _nombreDes => _selection.values.fold(0, (a, b) => a + b);
  int get _total => _resultats.fold(0, (somme, l) => somme + l.resultat);

  @override
  void dispose() {
    _animation?.cancel();
    super.dispose();
  }

  /// Modifie la sélection : l'animation en cours est interrompue et les
  /// résultats précédents effacés, pour qu'ils restent cohérents avec les dés
  /// affichés.
  void _modifierSelection(void Function() changement) {
    _animation?.cancel();
    setState(() {
      changement();
      _resultats = [];
      _enCours = false;
    });
  }

  void _ajouter(int faces) => _modifierSelection(
    () => _selection[faces] = (_selection[faces] ?? 0) + 1,
  );

  void _retirer(int faces) => _modifierSelection(() {
    final nombre = (_selection[faces] ?? 0) - 1;
    if (nombre <= 0) {
      _selection.remove(faces);
    } else {
      _selection[faces] = nombre;
    }
  });

  void _toutEffacer() => _modifierSelection(_selection.clear);

  /// Construit la liste à plat des dés sélectionnés, du plus petit au plus grand.
  List<int> get _desChoisis => [
    for (final faces in desDisponibles)
      ...List.filled(_selection[faces] ?? 0, faces),
  ];

  void _lancer() {
    if (_nombreDes == 0 || _enCours) return;
    final choisis = _desChoisis;

    setState(() => _enCours = true);

    // Petite animation : les valeurs défilent avant de se figer.
    var ticks = 0;
    _animation?.cancel();
    _animation = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      ticks++;
      setState(() {
        _resultats = [
          for (final faces in choisis)
            _Lancer(faces, _hasard.nextInt(faces) + 1),
        ];
      });
      if (ticks >= 8) {
        timer.cancel();
        setState(() => _enCours = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lancer de dés'),
        actions: [
          if (_nombreDes > 0)
            IconButton(
              tooltip: 'Tout effacer',
              onPressed: _toutEffacer,
              icon: const Icon(Icons.clear_all),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '1. Sélectionnez vos dés',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final faces in desDisponibles)
                  _BoutonSelection(
                    faces: faces,
                    nombre: _selection[faces] ?? 0,
                    auClic: () => _ajouter(faces),
                    auRetrait: () => _retirer(faces),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 24),
          Expanded(
            child: _nombreDes == 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Choisissez au moins un dé ci-dessus,\n'
                        'puis appuyez sur les dés pour les lancer.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : _ZoneLancer(
                    des: _desChoisis,
                    resultats: _resultats,
                    enCours: _enCours,
                    auLancer: _lancer,
                  ),
          ),
          if (_resultats.isNotEmpty && !_enCours)
            Container(
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'TOTAL',
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.5,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '$_total',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (_resultats.length > 1)
                    Text(
                      _resultats
                          .map((l) => 'd${l.faces}: ${l.resultat}')
                          .join('  +  '),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Bouton de sélection d'un type de dé, avec son compteur.
class _BoutonSelection extends StatelessWidget {
  const _BoutonSelection({
    required this.faces,
    required this.nombre,
    required this.auClic,
    required this.auRetrait,
  });

  final int faces;
  final int nombre;
  final VoidCallback auClic;
  final VoidCallback auRetrait;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final choisi = nombre > 0;

    // Largeur fixe : les dés forment une grille régulière quelle que soit la
    // largeur de l'écran (3 par ligne sur un téléphone).
    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: auClic,
            borderRadius: BorderRadius.circular(40),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: FormeDe(
                faces: faces,
                texte: 'd$faces',
                taille: 56,
                rempli: choisi,
                couleur: choisi
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
          ),
          SizedBox(
            height: 32,
            child: choisi
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: auRetrait,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.remove_circle_outline, size: 18),
                        ),
                      ),
                      Text(
                        '×$nombre',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Zone où l'on appuie sur les dés pour les lancer.
class _ZoneLancer extends StatelessWidget {
  const _ZoneLancer({
    required this.des,
    required this.resultats,
    required this.enCours,
    required this.auLancer,
  });

  final List<int> des;
  final List<_Lancer> resultats;
  final bool enCours;
  final VoidCallback auLancer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Les résultats ne sont affichés que s'ils correspondent aux dés montrés.
    final lance = resultats.length == des.length && resultats.isNotEmpty;

    return InkWell(
      onTap: auLancer,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              enCours
                  ? 'Les dés roulent…'
                  : lance
                  ? 'Appuyez de nouveau pour relancer'
                  : '2. Appuyez sur les dés pour les lancer',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < des.length; i++)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FormeDe(
                          faces: des[i],
                          texte: lance ? '${resultats[i].resultat}' : '?',
                          taille: 76,
                          couleur: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'd${des[i]}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
