package com.kolok.rpg

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    /// Fichier ouvert avec l'application, gardé jusqu'à ce que Dart vienne le
    /// chercher.
    private var fichierEnAttente: ByteArray? = null
    private var canal: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        canal = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rpg/fichiers_ouverts",
        ).apply {
            setMethodCallHandler { appel, resultat ->
                if (appel.method == "fichierEnAttente") {
                    resultat.success(fichierEnAttente)
                    fichierEnAttente = null
                } else {
                    resultat.notImplemented()
                }
            }
        }
        // L'application a été lancée par l'ouverture d'un fichier.
        garder(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // L'application tournait déjà : on prévient Dart.
        if (garder(intent)) canal?.invokeMethod("fichierOuvert", null)
    }

    /// Lit le fichier porté par [intent], s'il y en a un. Une relance depuis
    /// les applications récentes rejoue l'intent d'origine : on l'ignore pour
    /// ne pas importer deux fois.
    private fun garder(intent: Intent?): Boolean {
        if (intent == null ||
            intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0
        ) {
            return false
        }
        val uri = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> fluxPartage(intent)
            else -> null
        } ?: return false
        fichierEnAttente = try {
            contentResolver.openInputStream(uri)?.use { it.readBytes() }
        } catch (e: Exception) {
            null
        }
        // L'intent est consommé : une recréation de l'activité ne le relit pas.
        setIntent(Intent(Intent.ACTION_MAIN))
        return fichierEnAttente != null
    }

    private fun fluxPartage(intent: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }
}
