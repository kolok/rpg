import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dessine la silhouette d'un dé (triangle, carré, losange, pentagone…)
/// avec une valeur au centre.
class FormeDe extends StatelessWidget {
  const FormeDe({
    super.key,
    required this.faces,
    required this.texte,
    required this.couleur,
    this.taille = 64,
    this.rempli = true,
  });

  /// Nombre de faces du dé (4, 6, 8, 10, 12 ou 20).
  final int faces;
  final String texte;
  final Color couleur;
  final double taille;
  final bool rempli;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: taille,
      height: taille,
      child: CustomPaint(
        painter: _PeintreDe(
          faces: faces,
          couleur: couleur,
          rempli: rempli,
          fond: theme.colorScheme.surface,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: faces == 4 ? taille * 0.12 : 0),
            child: FittedBox(
              child: Text(
                texte,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: taille * 0.3,
                  color: rempli ? Colors.white : couleur,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PeintreDe extends CustomPainter {
  _PeintreDe({
    required this.faces,
    required this.couleur,
    required this.rempli,
    required this.fond,
  });

  final int faces;
  final Color couleur;
  final bool rempli;
  final Color fond;

  /// Nombre de côtés et rotation de la silhouette pour chaque type de dé.
  static const Map<int, (int, double)> _silhouettes = {
    4: (3, 0),
    6: (4, math.pi / 4),
    8: (4, 0),
    10: (6, 0),
    12: (5, 0),
    20: (6, math.pi / 6),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final (cotes, rotation) = _silhouettes[faces] ?? (6, 0.0);
    final centre = Offset(size.width / 2, size.height / 2);
    final rayon = math.min(size.width, size.height) / 2 - 2;

    final chemin = Path();
    for (var i = 0; i < cotes; i++) {
      // -pi/2 place un sommet vers le haut.
      final angle = -math.pi / 2 + rotation + i * 2 * math.pi / cotes;
      final point = Offset(
        centre.dx + rayon * math.cos(angle),
        centre.dy + rayon * math.sin(angle),
      );
      i == 0
          ? chemin.moveTo(point.dx, point.dy)
          : chemin.lineTo(point.dx, point.dy);
    }
    chemin.close();

    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.fill
        ..color = rempli ? couleur : fond,
    );
    canvas.drawPath(
      chemin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = couleur,
    );
  }

  @override
  bool shouldRepaint(covariant _PeintreDe ancien) =>
      ancien.faces != faces ||
      ancien.couleur != couleur ||
      ancien.rempli != rempli ||
      ancien.fond != fond;
}
