import 'competence.dart';

/// Nombre de compétences d'une page de classe neuve.
const int competencesParClasse = 5;

/// Nombre maximum de sorts sur une page de classe.
const int sortsMaximum = 10;

/// Une classe enregistrée dans les coulisses, prête à être reprise sur
/// n'importe quelle fiche de personnage.
///
/// Les coulisses vivent en dehors des parties : une classe écrite une fois
/// sert à toutes les tables.
class ModeleClasse {
  ModeleClasse({
    required this.id,
    this.nom = '',
    List<String>? atouts,
    List<Competence>? competences,
    List<Sort>? sorts,
    Competence? competenceHeroique,
  }) : atouts = atouts ?? <String>[],
       competences = competences ?? <Competence>[],
       sorts = sorts ?? <Sort>[],
       competenceHeroique = competenceHeroique ?? Competence();

  /// Une page de classe vierge : cinq compétences à remplir, pas de sort.
  factory ModeleClasse.neuve() => ModeleClasse(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    competences: List.generate(competencesParClasse, (_) => Competence()),
  );

  final String id;
  String nom;

  /// Les atouts gratuits de la classe, une ligne par atout.
  List<String> atouts;

  List<Competence> competences;

  /// Les sorts sont facultatifs : seules les classes qui en ont en portent.
  List<Sort> sorts;

  /// La compétence héroïque, présentée comme une compétence ordinaire.
  Competence competenceHeroique;

  /// Nom affiché tant que la classe n'en a pas.
  String get nomAffiche => nom.trim().isEmpty ? 'Classe sans nom' : nom.trim();

  /// Ligne affichée sous le nom dans la liste des coulisses.
  String get resume {
    final nommees = competences.where((c) => c.nom.trim().isNotEmpty).length;
    final sortsNommes = sorts.where((s) => s.nom.trim().isNotEmpty).length;
    final morceaux = [
      '$nommees ${nommees > 1 ? 'compétences' : 'compétence'}',
      if (sortsNommes > 0) '$sortsNommes ${sortsNommes > 1 ? 'sorts' : 'sort'}',
      if (competenceHeroique.nom.trim().isNotEmpty) '1 compétence héroïque',
    ];
    // Les espaces insécables gardent chaque morceau d'un seul tenant : la
    // ligne ne se coupe qu'entre deux morceaux, jamais au milieu de
    // « 1 compétence héroïque ».
    return morceaux.map((m) => m.replaceAll(' ', '\u00A0')).join(' · ');
  }

  Map<String, dynamic> versJson() => {
    'id': id,
    'nom': nom,
    'atouts': atouts,
    'competences': competences.map((c) => c.versJson()).toList(),
    'sorts': sorts.map((s) => s.versJson()).toList(),
    'competenceHeroique': competenceHeroique.versJson(),
  };

  factory ModeleClasse.depuisJson(Map<String, dynamic> json) => ModeleClasse(
    id:
        json['id'] as String? ??
        DateTime.now().microsecondsSinceEpoch.toString(),
    nom: json['nom'] as String? ?? '',
    atouts:
        (json['atouts'] as List?)?.map((e) => e.toString()).toList() ??
        <String>[],
    competences: Competence.listeDepuisJson(json['competences']),
    sorts: Sort.listeDepuisJson(json['sorts']),
    competenceHeroique: Competence.depuisBrut(json['competenceHeroique']),
  );
}
