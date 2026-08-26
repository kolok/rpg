import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modele_classe.dart';
import 'monstre.dart';
import 'partie.dart';
import 'personnage.dart';

/// Toutes les parties enregistrées sur l'appareil, et celle qui est ouverte.
///
/// Chaque partie est sauvegardée automatiquement après la moindre
/// modification, et le joueur peut en enregistrer une explicitement quand il
/// le souhaite. Démarrer une nouvelle partie ne touche pas aux précédentes.
/// Aucune connexion internet n'est nécessaire.
class Bibliotheque extends ChangeNotifier {
  Bibliotheque._(this._preferences, this._parties, this._coulisses);

  static const String _cle = 'parties';

  /// Clé des classes enregistrées dans les coulisses.
  static const String _cleCoulisses = 'coulisses';

  /// Clé de l'ancienne version, qui ne gardait qu'une partie à la fois.
  static const String _cleAncienne = 'partie_en_cours';

  final SharedPreferences _preferences;
  final List<Partie> _parties;

  /// Les classes des coulisses vivent en dehors des parties : elles servent à
  /// toutes les tables.
  final List<ModeleClasse> _coulisses;

  Partie? _courante;

  /// Relit les parties enregistrées, de la plus récente à la plus ancienne.
  static Future<Bibliotheque> charger() async {
    final preferences = await SharedPreferences.getInstance();
    final parties = _lire(preferences);
    final bibliotheque = Bibliotheque._(
      preferences,
      parties,
      _lireCoulisses(preferences),
    );

    // Reprise d'une sauvegarde de l'ancienne version : elle devient la
    // première partie de la bibliothèque, rien n'est perdu.
    final ancienne = _lireAncienne(preferences);
    if (ancienne != null) {
      parties.add(ancienne);
      await bibliotheque.sauvegarder();
      await preferences.remove(_cleAncienne);
    }

    return bibliotheque;
  }

  static List<Partie> _lire(SharedPreferences preferences) {
    final brut = preferences.getString(_cle);
    if (brut == null) return <Partie>[];
    try {
      return (jsonDecode(brut) as List)
          .map((e) => Partie.depuisJson((e as Map).cast<String, dynamic>()))
          .toList();
    } on FormatException {
      // Sauvegarde illisible : on repart d'une bibliothèque vide.
      return <Partie>[];
    }
  }

  static List<ModeleClasse> _lireCoulisses(SharedPreferences preferences) {
    final brut = preferences.getString(_cleCoulisses);
    if (brut == null) return <ModeleClasse>[];
    try {
      return (jsonDecode(brut) as List)
          .map(
            (e) => ModeleClasse.depuisJson((e as Map).cast<String, dynamic>()),
          )
          .toList();
    } on FormatException {
      return <ModeleClasse>[];
    }
  }

  static Partie? _lireAncienne(SharedPreferences preferences) {
    final brut = preferences.getString(_cleAncienne);
    if (brut == null) return null;
    try {
      final partie = Partie.depuisJson({
        'nom': 'Partie reprise',
        'personnages': jsonDecode(brut),
      });
      return partie.personnages.isEmpty ? null : partie;
    } on FormatException {
      return null;
    }
  }

  /// Les parties enregistrées, la plus récemment modifiée en tête.
  List<Partie> get parties {
    final triees = [..._parties]
      ..sort((a, b) => b.modifiee.compareTo(a.modifiee));
    return List.unmodifiable(triees);
  }

  /// La partie ouverte, ou `null` si l'on est sur la page de garde.
  Partie? get courante => _courante;

  /// Démarre une nouvelle partie et l'ouvre, sans toucher aux autres.
  Partie demarrer({required int nombreJoueurs, String? nom}) {
    final partie = Partie.neuve(nombreJoueurs: nombreJoueurs, nom: nom);
    _parties.add(partie);
    _courante = partie;
    sauvegarder();
    return partie;
  }

  /// Reprend une partie déjà enregistrée.
  void ouvrir(Partie partie) {
    _courante = partie;
    notifyListeners();
  }

  /// Quitte la partie ouverte. Elle reste dans la bibliothèque.
  void fermer() {
    _courante = null;
    notifyListeners();
  }

  /// Supprime définitivement une partie.
  void supprimer(Partie partie) {
    _parties.removeWhere((p) => p.id == partie.id);
    if (_courante?.id == partie.id) _courante = null;
    sauvegarder();
  }

  /// Renomme une partie.
  void renommer(Partie partie, String nom) {
    final propre = nom.trim();
    if (propre.isEmpty) return;
    partie.nom = propre;
    modifier(() {});
  }

  /// Ajoute une fiche vierge à la fin de la partie ouverte et la renvoie.
  Personnage? ajouterPersonnage() {
    final partie = _courante;
    if (partie == null) return null;
    final personnage = Personnage(nom: partie.nomLibrePersonnage());
    modifier(() => partie.personnages.add(personnage));
    return personnage;
  }

  /// Retire définitivement une fiche de la partie ouverte.
  void supprimerPersonnage(Personnage personnage) {
    final partie = _courante;
    if (partie == null) return;
    modifier(() => partie.personnages.remove(personnage));
  }

  /// Ajoute une fiche de monstre vierge à la partie ouverte et la renvoie.
  Monstre? ajouterMonstre() {
    final partie = _courante;
    if (partie == null) return null;
    final monstre = Monstre(nom: partie.nomLibreMonstre());
    modifier(() => partie.monstres.add(monstre));
    return monstre;
  }

  /// Retire définitivement une fiche de monstre de la partie ouverte.
  void supprimerMonstre(Monstre monstre) {
    final partie = _courante;
    if (partie == null) return;
    modifier(() => partie.monstres.remove(monstre));
  }

  /// Les classes enregistrées dans les coulisses, dans l'ordre de création.
  List<ModeleClasse> get coulisses => List.unmodifiable(_coulisses);

  /// Retrouve une classe des coulisses par son identifiant.
  ModeleClasse? classeCoulisses(String? id) {
    if (id == null) return null;
    for (final classe in _coulisses) {
      if (classe.id == id) return classe;
    }
    return null;
  }

  /// Crée une page de classe vierge dans les coulisses et la renvoie.
  ModeleClasse ajouterClasseCoulisses() {
    final classe = ModeleClasse.neuve();
    _coulisses.add(classe);
    sauvegarderCoulisses();
    return classe;
  }

  /// Retire définitivement une classe des coulisses. Les fiches qui s'en
  /// inspiraient gardent ce qui y a été recopié.
  void supprimerClasseCoulisses(ModeleClasse classe) {
    _coulisses.removeWhere((c) => c.id == classe.id);
    sauvegarderCoulisses();
  }

  /// À appeler après toute modification d'une classe des coulisses : les
  /// coulisses ne dépendent d'aucune partie, rien n'est horodaté.
  void modifierCoulisses(void Function() changement) {
    changement();
    sauvegarderCoulisses();
  }

  /// Écrit les coulisses sur l'appareil.
  Future<void> sauvegarderCoulisses() async {
    notifyListeners();
    await _preferences.setString(
      _cleCoulisses,
      jsonEncode(_coulisses.map((c) => c.versJson()).toList()),
    );
  }

  /// À appeler après toute modification d'une fiche : horodate la partie,
  /// rafraîchit l'affichage et enregistre.
  void modifier(void Function() changement) {
    changement();
    _courante?.modifiee = DateTime.now();
    sauvegarder();
  }

  /// Écrit la bibliothèque sur l'appareil.
  Future<void> sauvegarder() async {
    notifyListeners();
    await _preferences.setString(
      _cle,
      jsonEncode(_parties.map((p) => p.versJson()).toList()),
    );
  }
}

/// Rend la [Bibliotheque] accessible depuis n'importe quel écran.
class BibliothequeScope extends InheritedNotifier<Bibliotheque> {
  const BibliothequeScope({
    super.key,
    required Bibliotheque bibliotheque,
    required super.child,
  }) : super(notifier: bibliotheque);

  static Bibliotheque de(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BibliothequeScope>();
    assert(scope != null, 'Aucun BibliothequeScope trouvé dans le contexte.');
    return scope!.notifier!;
  }
}
