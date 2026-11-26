import 'package:flutter/material.dart';

/// Titres et chiffres clés.
const appDisplayFamily = 'BricolageGrotesque';
const _ui = 'InstrumentSans';

/// La hiérarchie vient de la taille et de la couleur, pas de la graisse (400 à 600, jamais plus).
/// Titres en Bricolage Grotesque 500, interface en Instrument Sans. Chiffres tabulaires partout :
/// les coordonnées et les heures ne « dansent » pas.
TextTheme buildAppTextTheme({required Color ink, required Color muted}) {
  TextStyle s(double size, FontWeight weight, double height, double tracking, Color color, {bool display = false}) {
    return TextStyle(
      fontFamily: display ? appDisplayFamily : _ui,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: tracking,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  return TextTheme(
    displayLarge: s(44, FontWeight.w500, 1.02, -1.4, ink, display: true),
    displayMedium: s(34, FontWeight.w500, 1.06, -0.9, ink, display: true),
    headlineLarge: s(30, FontWeight.w500, 1.1, -0.6, ink, display: true),
    headlineMedium: s(24, FontWeight.w500, 1.15, -0.4, ink, display: true),
    headlineSmall: s(20, FontWeight.w500, 1.2, -0.2, ink, display: true),
    titleLarge: s(17, FontWeight.w600, 1.3, -0.1, ink),
    titleMedium: s(16, FontWeight.w500, 1.35, 0, ink),
    titleSmall: s(14, FontWeight.w600, 1.35, 0, ink),
    bodyLarge: s(16, FontWeight.w500, 1.5, 0, ink),
    bodyMedium: s(14, FontWeight.w500, 1.45, 0, muted),
    bodySmall: s(13, FontWeight.w500, 1.4, 0, muted),
    labelLarge: s(16, FontWeight.w600, 1.2, 0, ink),
    labelMedium: s(13, FontWeight.w500, 1.25, 0, ink),
    labelSmall: s(11.5, FontWeight.w600, 1.2, 0.6, muted),
  );
}
