import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// Fichier exporté (classes ou partie) ouvert avec l'application depuis le
  /// Finder, gardé jusqu'à ce que Dart vienne le chercher.
  private var fichierEnAttente: Data?
  private var canal: FlutterMethodChannel?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  /// Branché par la fenêtre principale dès que son moteur Flutter existe.
  func brancher(messager: FlutterBinaryMessenger) {
    let canal = FlutterMethodChannel(name: "rpg/fichiers_ouverts", binaryMessenger: messager)
    canal.setMethodCallHandler { [weak self] appel, resultat in
      guard appel.method == "fichierEnAttente" else {
        resultat(FlutterMethodNotImplemented)
        return
      }
      resultat(self?.fichierEnAttente.map { FlutterStandardTypedData(bytes: $0) })
      self?.fichierEnAttente = nil
    }
    self.canal = canal
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    super.application(application, open: urls)
    guard let url = urls.first, url.isFileURL,
      let donnees = try? Data(contentsOf: url)
    else { return }
    fichierEnAttente = donnees
    // Au lancement, Dart viendra le chercher de lui-même ; sinon on le
    // prévient.
    canal?.invokeMethod("fichierOuvert", arguments: nil)
  }
}
