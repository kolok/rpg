import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Lecture, écriture et partage des fichiers d'import / export, à travers les
/// dialogues du système. Les tests remplacent [Fichiers.actuel] pour ne pas
/// ouvrir de vrai dialogue.
class Fichiers {
  const Fichiers();

  static Fichiers actuel = const Fichiers();

  /// Canal par lequel Android, iOS et macOS transmettent un fichier ouvert
  /// avec l'application depuis une autre (mail, messagerie, gestionnaire de
  /// fichiers…).
  static const MethodChannel _canalRecus = MethodChannel(
    'rpg/fichiers_ouverts',
  );

  /// Le partage de fichiers n'existe pas sous Linux : on n'y propose que
  /// l'enregistrement.
  bool get partageDisponible =>
      kIsWeb || defaultTargetPlatform != TargetPlatform.linux;

  /// Propose d'enregistrer [octets] sous [nom]. Renvoie `false` si l'on
  /// annule.
  Future<bool> enregistrer({
    required String nom,
    required Uint8List octets,
  }) async {
    final destination = await FilePicker.saveFile(
      fileName: nom,
      bytes: octets,
      mimeType: 'application/json',
    );
    return destination != null;
  }

  /// Ouvre la feuille de partage du système avec [octets] en pièce jointe
  /// nommée [nom]. [origine] situe la bulle de partage sur iPad et macOS.
  /// Renvoie `false` si l'on referme la feuille sans rien choisir.
  Future<bool> partager({
    required String nom,
    required Uint8List octets,
    Rect? origine,
  }) async {
    final resultat = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(octets, mimeType: 'application/json')],
        fileNameOverrides: [nom],
        sharePositionOrigin: origine,
      ),
    );
    return resultat.status != ShareResultStatus.dismissed;
  }

  /// Fait choisir un fichier JSON et renvoie son contenu, ou `null` si l'on
  /// annule.
  Future<Uint8List?> ouvrir() async {
    final fichier = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    return fichier?.readAsBytes();
  }

  /// Le fichier ouvert avec l'application et pas encore importé, ou `null`.
  /// Le système le garde de côté jusqu'à ce qu'on vienne le chercher : il
  /// peut arriver avant même que l'interface soit prête.
  Future<Uint8List?> fichierRecu() async {
    try {
      return await _canalRecus.invokeMethod<Uint8List>('fichierEnAttente');
    } on MissingPluginException {
      // Web, Windows, Linux : l'application ne reçoit pas de fichier.
      return null;
    }
  }

  /// Prévient [auxNouvelles] quand un fichier est ouvert avec l'application
  /// alors qu'elle tourne déjà ; `null` pour ne plus être prévenu.
  void ecouterFichiersRecus(VoidCallback? auxNouvelles) {
    _canalRecus.setMethodCallHandler(
      auxNouvelles == null
          ? null
          : (appel) async {
              if (appel.method == 'fichierOuvert') auxNouvelles();
            },
    );
  }
}
