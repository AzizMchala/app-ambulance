import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';

enum AppButtonVariant {
  /// Action principale : encre sur fond clair.
  primary,

  /// Réservé à l'envoi d'une alerte et aux actions graves.
  danger,

  /// Action secondaire : surface blanche et filet.
  secondary,

  /// Lien discret.
  ghost,
}

/// Bouton du design system : hauteur 56, coins 14, état de chargement intégré.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, side) = switch (variant) {
      AppButtonVariant.primary => (c.ink, c.canvas, BorderSide.none),
      AppButtonVariant.danger => (c.danger, c.onDanger, BorderSide.none),
      AppButtonVariant.secondary => (c.surface, c.ink, BorderSide(color: c.line)),
      AppButtonVariant.ghost => (Colors.transparent, c.action, BorderSide.none),
    };
    final enabled = onPressed != null && !loading;
    final height = compact ? 44.0 : AppSize.button;

    final child = AnimatedSwitcher(
      duration: AppMotion.fast,
      child: loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: compact ? 18 : 20), const SizedBox(width: AppSpace.x2)],
                // Les liens discrets peuvent passer sur deux lignes plutôt que d'être tronqués.
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: variant == AppButtonVariant.ghost ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    // Pendant le chargement, le bouton garde sa couleur mais n'accepte plus d'appui.
    final button = FilledButton(
      onPressed: enabled ? onPressed : (loading ? () {} : null),
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: variant == AppButtonVariant.ghost ? Colors.transparent : c.surfaceSunken,
        disabledForegroundColor: c.inkMuted,
        minimumSize: Size(expand ? double.infinity : 0, height),
        padding: EdgeInsets.symmetric(horizontal: compact ? AppSpace.x4 : AppSpace.x6),
        textStyle: (compact ? context.text.labelMedium : context.text.labelLarge)!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md), side: side),
        elevation: 0,
      ),
      child: child,
    );
    if (!loading) return button;
    return Semantics(
      button: true,
      enabled: false,
      label: label,
      child: ExcludeSemantics(child: AbsorbPointer(child: button)),
    );
  }
}
