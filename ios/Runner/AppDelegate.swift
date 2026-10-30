import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FichiersOuverts") {
      FichiersOuverts.register(with: registrar)
    }
  }
}

/// Transmet à Dart un fichier exporté (classes ou partie) ouvert avec
/// l'application depuis Mail, Messages, Fichiers…
class FichiersOuverts: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  private let canal: FlutterMethodChannel

  /// Fichier gardé jusqu'à ce que Dart vienne le chercher.
  private var fichierEnAttente: Data?

  init(canal: FlutterMethodChannel) {
    self.canal = canal
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let canal = FlutterMethodChannel(
      name: "rpg/fichiers_ouverts", binaryMessenger: registrar.messenger())
    let instance = FichiersOuverts(canal: canal)
    registrar.addMethodCallDelegate(instance, channel: canal)
    registrar.addSceneDelegate(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "fichierEnAttente" else {
      result(FlutterMethodNotImplemented)
      return
    }
    result(fichierEnAttente.map { FlutterStandardTypedData(bytes: $0) })
    fichierEnAttente = nil
  }

  // L'application a été lancée par l'ouverture d'un fichier.
  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    guard let url = connectionOptions?.urlContexts.first?.url else { return false }
    return garder(url)
  }

  // L'application tournait déjà : on prévient Dart.
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let url = URLContexts.first?.url, garder(url) else { return false }
    canal.invokeMethod("fichierOuvert", arguments: nil)
    return true
  }

  private func garder(_ url: URL) -> Bool {
    guard url.isFileURL else { return false }
    let acces = url.startAccessingSecurityScopedResource()
    defer { if acces { url.stopAccessingSecurityScopedResource() } }
    guard let donnees = try? Data(contentsOf: url) else { return false }
    fichierEnAttente = donnees
    return true
  }
}
