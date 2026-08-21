/// Modèle de données d'une fiche de personnage RPG.
library;

/// Les quatre caractéristiques du jeu. Chacune est associée à un dé.
enum Caracteristique {
  puissance('Puissance'),
  dexterite('Dextérité'),
  volonte('Volonté'),
  intuition('Intuition');

  const Caracteristique(this.libelle);

  /// Nom affiché sur la fiche.
  final String libelle;
}

/// Dés utilisables pour les caractéristiques (échelle du jeu : d6 → d12).
const List<int> desCaracteristiques = [6, 8, 10, 12];

/// Nombre de classes créées sur une fiche vierge.
const int classesParDefaut = 3;

/// Une classe du personnage et les compétences qui lui sont associées.
class Classe {
  Classe({this.nom = '', List<String>? competences})
      : competences = competences ?? <String>[];

  String nom;
  List<String> competences;

  Map<String, dynamic> versJson() => {
        'nom': nom,
        'competences': competences,
      };

  factory Classe.depuisJson(Map<String, dynamic> json) => Classe(
        nom: json['nom'] as String? ?? '',
        competences: (json['competences'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[],
      );
}

class Personnage {
  Personnage({
    required this.nom,
    List<Classe>? classes,
    this.pointsDeReussite = 3,
    this.zenits = 0,
    List<String>? equipement,
    List<String>? inventaire,
    this.experience = 0,
    this.pvMax = 40,
    int? pvActuels,
    this.pmMax = 40,
    int? pmActuels,
    this.piMax = 6,
    int? piActuels,
    this.defense = 0,
    this.defenseMagique = 0,
    this.initiative = 0,
    Map<Caracteristique, int>? caracteristiques,
  })  : classes = classes ?? List.generate(classesParDefaut, (_) => Classe()),
        equipement = equipement ?? <String>[],
        inventaire = inventaire ?? <String>[],
        // Une fiche neuve démarre avec ses réserves pleines.
        pvActuels = pvActuels ?? pvMax,
        pmActuels = pmActuels ?? pmMax,
        piActuels = piActuels ?? piMax,
        caracteristiques = caracteristiques ??
            {for (final c in Caracteristique.values) c: 8};

  String nom;
  List<Classe> classes;
  int pointsDeReussite;
  int zenits;
  List<String> equipement;
  List<String> inventaire;
  int experience;

  /// Réserves : le maximum et ce qu'il en reste actuellement.
  int pvMax;
  int pvActuels;
  int pmMax;
  int pmActuels;
  int piMax;
  int piActuels;

  int defense;
  int defenseMagique;

  /// L'initiative peut être négative (armure lourde, malus…).
  int initiative;

  Map<Caracteristique, int> caracteristiques;

  Map<String, dynamic> versJson() => {
        'nom': nom,
        'classes': classes.map((c) => c.versJson()).toList(),
        'pointsDeReussite': pointsDeReussite,
        'zenits': zenits,
        'equipement': equipement,
        'inventaire': inventaire,
        'experience': experience,
        'pvMax': pvMax,
        'pvActuels': pvActuels,
        'pmMax': pmMax,
        'pmActuels': pmActuels,
        'piMax': piMax,
        'piActuels': piActuels,
        'defense': defense,
        'defenseMagique': defenseMagique,
        'initiative': initiative,
        'caracteristiques': {
          for (final entree in caracteristiques.entries)
            entree.key.name: entree.value,
        },
      };

  factory Personnage.depuisJson(Map<String, dynamic> json) {
    List<String> liste(String cle) =>
        (json[cle] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

    final brutCaracteristiques =
        (json['caracteristiques'] as Map?)?.cast<String, dynamic>() ?? {};

    // Les anciennes sauvegardes stockaient un seul compteur de PV et de PM,
    // les compétences hors des classes, et les points de réussite sous un
    // autre nom : on les reprend sans rien perdre.
    final pvMax = json['pvMax'] as int? ?? json['pv'] as int? ?? 40;
    final pmMax = json['pmMax'] as int? ?? json['pm'] as int? ?? 40;
    final classes = _classesDepuisJson(json);

    return Personnage(
      nom: json['nom'] as String? ?? '',
      classes: classes,
      // TODO: supprimer la référence à pointsFabula gardée ici pour la rétrocompatibilité.
      pointsDeReussite: json['pointsDeReussite'] as int? ??
          json['pointsFabula'] as int? ??
          3,
      zenits: json['zenits'] as int? ?? 0,
      equipement: liste('equipement'),
      inventaire: liste('inventaire'),
      experience: json['experience'] as int? ?? 0,
      pvMax: pvMax,
      pvActuels: json['pvActuels'] as int? ?? pvMax,
      pmMax: pmMax,
      pmActuels: json['pmActuels'] as int? ?? pmMax,
      piMax: json['piMax'] as int? ?? 6,
      piActuels: json['piActuels'] as int? ?? json['piMax'] as int? ?? 6,
      defense: json['defense'] as int? ?? 0,
      defenseMagique: json['defenseMagique'] as int? ?? 0,
      initiative: json['initiative'] as int? ?? 0,
      caracteristiques: {
        for (final c in Caracteristique.values)
          c: brutCaracteristiques[c.name] as int? ?? 8,
      },
    );
  }

  /// Relit les classes, qu'elles viennent du format actuel (nom + compétences)
  /// ou de l'ancien (simple liste de noms, compétences à part).
  static List<Classe> _classesDepuisJson(Map<String, dynamic> json) {
    final brut = json['classes'] as List? ?? const [];
    final classes = <Classe>[
      for (final element in brut)
        if (element is Map)
          Classe.depuisJson(element.cast<String, dynamic>())
        else
          Classe(nom: element.toString()),
    ];

    final anciennesCompetences =
        (json['competences'] as List?)?.map((e) => e.toString()).toList();
    if (anciennesCompetences != null && anciennesCompetences.isNotEmpty) {
      if (classes.isEmpty) classes.add(Classe());
      classes.first.competences.addAll(anciennesCompetences);
    }

    return classes.isEmpty
        ? List.generate(classesParDefaut, (_) => Classe())
        : classes;
  }
}
