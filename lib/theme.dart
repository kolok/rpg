import 'package:flutter/material.dart';

/// Palette inspirée des fiches de RPG : encre bleu nuit et or.
const Color _graine = Color(0xFF2C3E7B);

ThemeData _base(Brightness brightness) {
  final schema = ColorScheme.fromSeed(
    seedColor: _graine,
    brightness: brightness,
  );
  final theme = ThemeData(
    colorScheme: schema,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: schema.primaryContainer,
      foregroundColor: schema.onPrimaryContainer,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: schema.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
  // Le texte du gros bouton part de la typographie du thème, pour garder la
  // police de la plateforme.
  return theme.copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

ThemeData themeClair() => _base(Brightness.light);
ThemeData themeSombre() => _base(Brightness.dark);
