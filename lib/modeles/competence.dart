/// Compétences et sorts, partagés par les fiches de personnages et les pages
/// de classes des coulisses.
library;

/// Une compétence : son nom, ce qu'elle fait, et son niveau de compétence.
class Competence {
  Competence({this.nom = '', this.description = '', this.nc = 0});

  String nom;
  String description;

  /// Niveau de compétence (NC), affiché à côté du nom.
  int nc;

  /// Copie destinée à une fiche de personnage : le nom et la description
  /// viennent des coulisses, mais le NC repart de zéro — c'est le niveau du
  /// personnage, pas celui du modèle.
  Competence pourFiche() => Competence(nom: nom, description: description);

  Map<String, dynamic> versJson() => {
    'nom': nom,
    'description': description,
    'nc': nc,
  };

  factory Competence.depuisJson(Map<String, dynamic> json) => Competence(
    nom: json['nom'] as String? ?? '',
    description: json['description'] as String? ?? '',
    nc: json['nc'] as int? ?? 0,
  );

  /// Relit une compétence enregistrée, qu'elle vienne du format actuel ou de
  /// l'ancien, où une compétence n'était qu'une ligne de texte.
  static Competence depuisBrut(Object? element) => element is Map
      ? Competence.depuisJson(element.cast<String, dynamic>())
      : Competence(nom: element?.toString() ?? '');

  static List<Competence> listeDepuisJson(Object? brut) => [
    for (final element in (brut as List? ?? const []))
      Competence.depuisBrut(element),
  ];
}

/// Un sort : comme une compétence, mais sans niveau de compétence.
class Sort {
  Sort({this.nom = '', this.description = ''});

  String nom;
  String description;

  Map<String, dynamic> versJson() => {'nom': nom, 'description': description};

  factory Sort.depuisJson(Map<String, dynamic> json) => Sort(
    nom: json['nom'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );

  static List<Sort> listeDepuisJson(Object? brut) => [
    for (final element in (brut as List? ?? const []))
      if (element is Map)
        Sort.depuisJson(element.cast<String, dynamic>())
      else
        Sort(nom: element.toString()),
  ];
}
