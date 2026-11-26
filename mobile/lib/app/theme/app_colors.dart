import 'package:flutter/material.dart';

/// Palette « Carnet clair » adaptée au médical. Aucun écran n'écrit de couleur en dur.
///
/// - Le décor reste calme : fond [canvas] gris chaud, surfaces blanches, encre [ink] marine presque noire.
/// - [action] (bleu soigné) marque la navigation, la sélection et les liens.
/// - [danger] (rouge) est réservé au SOS et aux erreurs graves : l'application n'est jamais « agressive ».
/// - [success], [warning] et [info] ne servent qu'aux statuts.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.surface,
    required this.surfaceSunken,
    required this.ink,
    required this.inkSoft,
    required this.inkMuted,
    required this.line,
    required this.action,
    required this.onAction,
    required this.actionTint,
    required this.onActionTint,
    required this.danger,
    required this.onDanger,
    required this.dangerTint,
    required this.onDangerTint,
    required this.warning,
    required this.warningTint,
    required this.success,
    required this.successTint,
    required this.neutralTint,
    required this.shadow,
    required this.scrim,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceSunken;
  final Color ink;
  final Color inkSoft;
  final Color inkMuted;

  /// Filet discret : l'encre à 8 %.
  final Color line;
  final Color action;
  final Color onAction;
  final Color actionTint;
  final Color onActionTint;
  final Color danger;
  final Color onDanger;
  final Color dangerTint;

  /// Rouge lisible en petit texte sur fond clair ou teinté.
  final Color onDangerTint;
  final Color warning;
  final Color warningTint;
  final Color success;
  final Color successTint;
  final Color neutralTint;
  final Color shadow;
  final Color scrim;

  static const light = AppColors(
    canvas: Color(0xFFF3F3F0),
    surface: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE9E9E5),
    ink: Color(0xFF0B1026),
    inkSoft: Color(0xFF4E5568),
    inkMuted: Color(0xFF5A6174),
    line: Color(0x140B1026),
    action: Color(0xFF2563B0),
    onAction: Color(0xFFFFFFFF),
    actionTint: Color(0xFFDCE8F7),
    onActionTint: Color(0xFF1D4F8E),
    danger: Color(0xFFD93A40),
    onDanger: Color(0xFFFFFFFF),
    dangerTint: Color(0xFFF9E3E3),
    onDangerTint: Color(0xFFB0262C),
    warning: Color(0xFF8A5A00),
    warningTint: Color(0xFFF8EDD8),
    success: Color(0xFF14724F),
    successTint: Color(0xFFDDF0E6),
    neutralTint: Color(0xFFE7E7EC),
    shadow: Color(0xFF0B1026),
    scrim: Color(0x610B1026),
  );

  static const dark = AppColors(
    canvas: Color(0xFF0B0D14),
    surface: Color(0xFF161925),
    surfaceSunken: Color(0xFF1F2331),
    ink: Color(0xFFF3F3F0),
    inkSoft: Color(0xFFC3C8D4),
    inkMuted: Color(0xFFA2A8B8),
    line: Color(0x1FF3F3F0),
    action: Color(0xFF7DB2EE),
    onAction: Color(0xFF0B1026),
    actionTint: Color(0xFF1B2A44),
    onActionTint: Color(0xFFA9CCF4),
    danger: Color(0xFFF0777B),
    onDanger: Color(0xFF2B0507),
    dangerTint: Color(0xFF3A1A1F),
    onDangerTint: Color(0xFFF7A3A6),
    warning: Color(0xFFE9BE6C),
    warningTint: Color(0xFF2F2717),
    success: Color(0xFF5CC79A),
    successTint: Color(0xFF173126),
    neutralTint: Color(0xFF262A38),
    shadow: Color(0xFF000000),
    scrim: Color(0x99000000),
  );

  /// Les cartes blanches sur fond gris n'ont pas besoin d'ombre : seulement ce qui flotte.
  List<BoxShadow> get shadowCard => [
    BoxShadow(color: shadow.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4)),
  ];

  List<BoxShadow> get shadowFloat => [
    BoxShadow(color: shadow.withValues(alpha: 0.18), blurRadius: 32, offset: const Offset(0, 14)),
  ];

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      canvas: l(canvas, other.canvas),
      surface: l(surface, other.surface),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      ink: l(ink, other.ink),
      inkSoft: l(inkSoft, other.inkSoft),
      inkMuted: l(inkMuted, other.inkMuted),
      line: l(line, other.line),
      action: l(action, other.action),
      onAction: l(onAction, other.onAction),
      actionTint: l(actionTint, other.actionTint),
      onActionTint: l(onActionTint, other.onActionTint),
      danger: l(danger, other.danger),
      onDanger: l(onDanger, other.onDanger),
      dangerTint: l(dangerTint, other.dangerTint),
      onDangerTint: l(onDangerTint, other.onDangerTint),
      warning: l(warning, other.warning),
      warningTint: l(warningTint, other.warningTint),
      success: l(success, other.success),
      successTint: l(successTint, other.successTint),
      neutralTint: l(neutralTint, other.neutralTint),
      shadow: l(shadow, other.shadow),
      scrim: l(scrim, other.scrim),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
