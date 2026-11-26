import 'package:flutter/animation.dart';

/// Espacements sur une grille de 4. Aucun écran n'écrit de marge en dur.
abstract final class AppSpace {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;

  /// Marge latérale de tous les écrans.
  static const double gutter = 20;
}

/// Rayons : contrôles 14, lignes 20, cartes 24, grands panneaux 32.
abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 24;
  static const double hero = 32;
  static const double full = 999;
}

abstract final class AppSize {
  /// Cible tactile minimale (accessibilité).
  static const double tapTarget = 48;
  static const double button = 56;
  static const double field = 56;

  /// Diamètre du bouton SOS de l'écran principal.
  static const double sosButton = 208;

  /// Largeur maximale du contenu sur tablette et sur le web.
  static const double contentMax = 560;
}

/// Mouvement : une courbe douce, des durées courtes, aucun rebond.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 440);

  /// Respiration lente du halo du bouton SOS.
  static const Duration breathe = Duration(milliseconds: 2400);

  static const Curve standard = Cubic(0.22, 1, 0.36, 1);
  static const Curve exit = Cubic(0.4, 0, 1, 1);
}
