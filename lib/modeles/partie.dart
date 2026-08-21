import 'personnage.dart';

/// Une partie sauvegardée : ses fiches de personnages, son nom et la date de
/// sa dernière modification.
///
/// Plusieurs parties coexistent dans la [Bibliotheque] : en démarrer une
/// nouvelle ne remplace jamais les précédentes.
class Partie {
  /// Bornes du nombre de joueurs demandées au démarrage d'une partie.
  static const int minJoueurs = 2;
  static const int maxJoueurs = 15;

  Partie({
    required this.id,
    required this.nom,
    required this.modifiee,
    required this.personnages,
  });

  /// Crée une partie neuve avec [nombreJoueurs] fiches vierges.
  factory Partie.neuve({required int nombreJoueurs, String? nom}) {
    final maintenant = DateTime.now();
    return Partie(
      // L'horodatage suffit à distinguer deux parties : on ne peut pas en
      // créer deux dans la même microseconde.
      id: maintenant.microsecondsSinceEpoch.toString(),
      nom: nom?.trim().isNotEmpty == true
          ? nom!.trim()
          : nomParDefaut(maintenant),
      modifiee: maintenant,
      personnages: List.generate(
        nombreJoueurs,
        (i) => Personnage(nom: 'Personnage ${i + 1}'),
      ),
    );
  }

  final String id;
  String nom;
  DateTime modifiee;
  List<Personnage> personnages;

  /// Nom proposé pour une fiche ajoutée en cours de partie : le premier
  /// « Personnage n » encore libre, pour ne pas créer deux homonymes après
  /// une suppression.
  String nomLibrePersonnage() {
    final pris = personnages.map((p) => p.nom.trim()).toSet();
    var numero = personnages.length + 1;
    while (pris.contains('Personnage $numero')) {
      numero++;
    }
    return 'Personnage $numero';
  }

  /// Nom proposé quand le joueur n'en donne pas : « Partie du 21/08/2026 ».
  static String nomParDefaut(DateTime date) => 'Partie du ${dateCourte(date)}';

  /// Date au format jj/mm/aaaa.
  static String dateCourte(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    return '$jour/$mois/${date.year}';
  }

  /// Heure au format hh:mm.
  static String heureCourte(DateTime date) {
    final heures = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '${heures}h$minutes';
  }

  /// Ligne affichée sous le nom dans la liste des parties.
  String get resume {
    final joueurs = personnages.length > 1 ? 'joueurs' : 'joueur';
    return '${personnages.length} $joueurs · '
        '${dateCourte(modifiee)} à ${heureCourte(modifiee)}';
  }

  Map<String, dynamic> versJson() => {
    'id': id,
    'nom': nom,
    'modifiee': modifiee.toIso8601String(),
    'personnages': personnages.map((p) => p.versJson()).toList(),
  };

  factory Partie.depuisJson(Map<String, dynamic> json) {
    final modifiee = DateTime.tryParse(json['modifiee'] as String? ?? '');
    return Partie(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      nom: json['nom'] as String? ?? '',
      modifiee: modifiee ?? DateTime.now(),
      personnages: (json['personnages'] as List? ?? const [])
          .map((e) => Personnage.depuisJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}
