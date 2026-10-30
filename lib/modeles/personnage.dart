/// Modèle de données d'une fiche de personnage RPG.
library;

import 'competence.dart';
import 'modele_classe.dart';

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

/// Une classe du personnage, ses compétences, ses sorts et ses compétences
/// héroïques.
class Classe {
  Classe({
    this.nom = '',
    List<Competence>? competences,
    List<Sort>? sorts,
    List<Competence>? competencesHeroiques,
    this.modeleId,
  }) : competences = competences ?? <Competence>[],
       sorts = sorts ?? <Sort>[],
       competencesHeroiques = competencesHeroiques ?? <Competence>[];

  /// Classe recopiée depuis les coulisses.
  factory Classe.depuisModele(ModeleClasse modele) =>
      Classe()..reprendre(modele);

  String nom;
  List<Competence> competences;

  /// Les sorts que le personnage a appris dans cette classe.
  List<Sort> sorts;

  /// Les compétences héroïques, tenues à part des compétences ordinaires.
  List<Competence> competencesHeroiques;

  /// Identifiant de la classe des coulisses d'où celle-ci a été reprise, s'il
  /// y en a une : c'est là qu'on va chercher les compétences à proposer.
  String? modeleId;

  /// Reprend une classe des coulisses : son nom, le lien vers le modèle, et
  /// les compétences, sorts et compétences héroïques qui manquent encore —
  /// les compétences au NC zéro, puisque celui des coulisses n'est qu'un
  /// plafond. Rien de ce qui est déjà écrit n'est écrasé.
  void reprendre(ModeleClasse modele) {
    nom = modele.nom;
    modeleId = modele.id;
    _completer(
      competences,
      modele.competences,
      nomDe: (c) => c.nom,
      copier: (c) => c.pourFiche(),
    );
    _completer(
      sorts,
      modele.sorts,
      nomDe: (s) => s.nom,
      copier: (s) => Sort(nom: s.nom, description: s.description),
      maximum: sortsMaximum,
    );
    _completer(
      competencesHeroiques,
      [modele.competenceHeroique],
      nomDe: (c) => c.nom,
      copier: (c) => c.pourFiche(),
    );
  }

  /// Ajoute à [cible] une copie de chaque élément nommé de [source] qu'elle
  /// n'a pas encore (même nom, sans tenir compte de la casse), sans
  /// dépasser [maximum] s'il y en a un.
  static void _completer<T>(
    List<T> cible,
    List<T> source, {
    required String Function(T) nomDe,
    required T Function(T) copier,
    int? maximum,
  }) {
    String cle(T element) => nomDe(element).trim().toLowerCase();
    final connus = cible.map(cle).where((nom) => nom.isNotEmpty).toSet();
    for (final element in source) {
      if (maximum != null && cible.length >= maximum) break;
      final nom = cle(element);
      if (nom.isEmpty || !connus.add(nom)) continue;
      cible.add(copier(element));
    }
  }

  Map<String, dynamic> versJson() => {
    'nom': nom,
    'competences': competences.map((c) => c.versJson()).toList(),
    'sorts': sorts.map((s) => s.versJson()).toList(),
    'competencesHeroiques': competencesHeroiques
        .map((c) => c.versJson())
        .toList(),
    'modeleId': modeleId,
  };

  factory Classe.depuisJson(Map<String, dynamic> json) => Classe(
    nom: json['nom'] as String? ?? '',
    competences: Competence.listeDepuisJson(json['competences']),
    sorts: Sort.listeDepuisJson(json['sorts']),
    competencesHeroiques: Competence.listeDepuisJson(
      json['competencesHeroiques'],
    ),
    modeleId: json['modeleId'] as String?,
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
    this.niveau = 0,
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
    // Une fiche vierge n'a aucune classe : le joueur ajoute les siennes.
  }) : classes = classes ?? <Classe>[],
       equipement = equipement ?? <String>[],
       inventaire = inventaire ?? <String>[],
       // Une fiche neuve démarre avec ses réserves pleines.
       pvActuels = pvActuels ?? pvMax,
       pmActuels = pmActuels ?? pmMax,
       piActuels = piActuels ?? piMax,
       caracteristiques =
           caracteristiques ?? {for (final c in Caracteristique.values) c: 8};

  String nom;
  List<Classe> classes;
  int pointsDeReussite;
  int zenits;
  List<String> equipement;
  List<String> inventaire;

  /// Niveau du personnage, autrefois enregistré sous le nom « points
  /// d'expérience ».
  int niveau;

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
    'niveau': niveau,
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
      pointsDeReussite:
          json['pointsDeReussite'] as int? ?? json['pointsFabula'] as int? ?? 3,
      zenits: json['zenits'] as int? ?? 0,
      equipement: liste('equipement'),
      inventaire: liste('inventaire'),
      // Les sauvegardes antérieures au renommage parlaient d'« experience ».
      niveau: json['niveau'] as int? ?? json['experience'] as int? ?? 0,
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

    final anciennesCompetences = Competence.listeDepuisJson(
      json['competences'],
    );
    if (anciennesCompetences.isNotEmpty) {
      if (classes.isEmpty) classes.add(Classe());
      classes.first.competences.addAll(anciennesCompetences);
    }

    return classes;
  }
}
