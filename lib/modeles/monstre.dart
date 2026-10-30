/// Fiche d'un monstre, tenue par le meneur de jeu.
library;

/// Une fiche de monstre : une fiche de personnage réduite à ce dont le meneur
/// a besoin en pleine rencontre — le nom, le niveau, les deux réserves,
/// l'équipement et les compétences.
class Monstre {
  Monstre({
    required this.nom,
    this.niveau = 0,
    this.pvMax = 40,
    int? pvActuels,
    this.pmMax = 40,
    int? pmActuels,
    List<String>? equipement,
    List<String>? competences,
  }) : pvActuels = pvActuels ?? pvMax,
       pmActuels = pmActuels ?? pmMax,
       equipement = equipement ?? <String>[],
       competences = competences ?? <String>[];

  String nom;
  int niveau;

  /// Réserves : le maximum et ce qu'il en reste actuellement.
  int pvMax;
  int pvActuels;
  int pmMax;
  int pmActuels;

  List<String> equipement;
  List<String> competences;

  Map<String, dynamic> versJson() => {
    'nom': nom,
    'niveau': niveau,
    'pvMax': pvMax,
    'pvActuels': pvActuels,
    'pmMax': pmMax,
    'pmActuels': pmActuels,
    'equipement': equipement,
    'competences': competences,
  };

  factory Monstre.depuisJson(Map<String, dynamic> json) {
    List<String> liste(String cle) =>
        (json[cle] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

    final pvMax = json['pvMax'] as int? ?? 40;
    final pmMax = json['pmMax'] as int? ?? 40;
    return Monstre(
      nom: json['nom'] as String? ?? '',
      niveau: json['niveau'] as int? ?? 0,
      pvMax: pvMax,
      pvActuels: json['pvActuels'] as int? ?? pvMax,
      pmMax: pmMax,
      pmActuels: json['pmActuels'] as int? ?? pmMax,
      equipement: liste('equipement'),
      competences: liste('competences'),
    );
  }
}
