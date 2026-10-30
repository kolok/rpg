import 'dart:convert';
import 'dart:typed_data';

import 'modele_classe.dart';
import 'partie.dart';

/// Ce que contient un fichier d'export.
enum ContenuEchange { classes, partie }

/// Format des fichiers d'export : un objet JSON qui dit ce qu'il contient,
/// pour qu'on ne puisse pas importer une partie là où l'on attend des
/// classes, ni le fichier d'une autre application.
abstract final class Echange {
  static const String _application = 'rpg';
  static const int _version = 1;

  static const String _typeClasses = 'classes';
  static const String _typePartie = 'partie';

  /// Fichier contenant les [classes] des coulisses.
  static Uint8List exporterClasses(List<ModeleClasse> classes) => _encoder(
    _typeClasses,
    {'classes': classes.map((c) => c.versJson()).toList()},
  );

  /// Fichier contenant une seule [partie], avec toutes ses fiches.
  static Uint8List exporterPartie(Partie partie) =>
      _encoder(_typePartie, {'partie': partie.versJson()});

  /// Dit si un fichier contient des classes ou une partie, pour l'importer
  /// au bon endroit quand on l'ouvre depuis une autre application. Lève une
  /// [FormatException] si ce n'est ni l'un ni l'autre.
  static ContenuEchange contenuDe(List<int> octets) {
    final json = _lireJson(octets);
    return switch (json['type']) {
      _typeClasses => ContenuEchange.classes,
      _typePartie => ContenuEchange.partie,
      _ => throw const FormatException(
        'Ce fichier ne contient rien à importer.',
      ),
    };
  }

  /// Relit un fichier de classes. Lève une [FormatException] si ce n'en est
  /// pas un.
  static List<ModeleClasse> importerClasses(List<int> octets) {
    final contenu = _decoder(octets, _typeClasses);
    final classes = contenu['classes'];
    if (classes is! List) throw const FormatException('Aucune classe.');
    return _lire(
      () => classes
          .map(
            (e) => ModeleClasse.depuisJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  /// Relit un fichier de partie. Lève une [FormatException] si ce n'en est
  /// pas un.
  static Partie importerPartie(List<int> octets) {
    final contenu = _decoder(octets, _typePartie);
    final partie = contenu['partie'];
    if (partie is! Map) throw const FormatException('Aucune partie.');
    return _lire(() => Partie.depuisJson(partie.cast<String, dynamic>()));
  }

  /// Un champ du mauvais type dans le fichier devient une [FormatException],
  /// comme tout autre fichier illisible.
  static T _lire<T>(T Function() lecture) {
    try {
      return lecture();
    } on TypeError {
      throw const FormatException('Le contenu de ce fichier est abîmé.');
    }
  }

  /// Nom de fichier proposé : sans caractères que les systèmes de fichiers
  /// refusent.
  static String nomDeFichier(String nom) {
    final propre = nom
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return '${propre.isEmpty ? 'export' : propre}.json';
  }

  static Uint8List _encoder(String type, Map<String, dynamic> contenu) {
    final json = {
      'application': _application,
      'type': type,
      'version': _version,
      ...contenu,
    };
    return utf8.encode(const JsonEncoder.withIndent('  ').convert(json));
  }

  static Map<String, dynamic> _decoder(List<int> octets, String type) {
    final json = _lireJson(octets);
    if (json['type'] != type) {
      throw FormatException(
        type == _typeClasses
            ? 'Ce fichier contient une partie, pas des classes.'
            : 'Ce fichier contient des classes, pas une partie.',
      );
    }
    return json;
  }

  /// Le JSON d'un fichier de l'application, quel qu'en soit le contenu.
  static Map<String, dynamic> _lireJson(List<int> octets) {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(octets));
    } on FormatException {
      throw const FormatException('Ce fichier n\'est pas un JSON lisible.');
    }
    if (json is! Map || json['application'] != _application) {
      throw const FormatException('Ce fichier ne vient pas de l\'application.');
    }
    return json.cast<String, dynamic>();
  }
}
