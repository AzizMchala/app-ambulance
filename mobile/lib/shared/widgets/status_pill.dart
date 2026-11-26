import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';

/// Tonalité d'un statut. Chaque module traduit ses propres statuts vers ces tonalités.
enum StatusTone { neutral, info, warning, success, danger }

({Color background, Color foreground}) statusToneColors(BuildContext context, StatusTone tone) {
  final c = context.colors;
  return switch (tone) {
    StatusTone.neutral => (background: c.neutralTint, foreground: c.inkSoft),
    StatusTone.info => (background: c.actionTint, foreground: c.onActionTint),
    StatusTone.warning => (background: c.warningTint, foreground: c.warning),
    StatusTone.success => (background: c.successTint, foreground: c.success),
    StatusTone.danger => (background: c.dangerTint, foreground: c.onDangerTint),
  };
}

/// Pastille de statut : point coloré + libellé. La couleur n'est jamais la seule information.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone, this.large = false});

  final String label;
  final StatusTone tone;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = statusToneColors(context, tone);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? AppSpace.x4 : AppSpace.x3, vertical: large ? 8 : 5),
      decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: colors.foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: (large ? context.text.labelLarge : context.text.labelMedium)!.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
