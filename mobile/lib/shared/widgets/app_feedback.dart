import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';
import 'app_button.dart';

/// Dialogues, notifications et bandeaux du design system.
abstract final class AppFeedback {
  /// Notification courte en bas d'écran.
  static void toast(BuildContext context, String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? PhosphorIconsLight.warningCircle : PhosphorIconsLight.checkCircle,
              color: context.colors.canvas,
              size: 20,
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  /// Confirmation explicite. Renvoie `true` seulement si le patient a appuyé sur [confirmLabel].
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    required String cancelLabel,
    bool danger = false,
    Widget? content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpace.x5, vertical: AppSpace.x6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.x6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(header: true, child: Text(title, style: context.text.headlineSmall)),
                const SizedBox(height: AppSpace.x3),
                Text(body, style: context.text.bodyMedium),
                if (content != null) ...[const SizedBox(height: AppSpace.x4), content],
                const SizedBox(height: AppSpace.x6),
                // Bouton de confirmation au-dessus, pleine largeur : aucun libellé n'est tronqué sur petit écran.
                AppButton(
                  label: confirmLabel,
                  variant: danger ? AppButtonVariant.danger : AppButtonVariant.primary,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: AppSpace.x2),
                AppButton(
                  label: cancelLabel,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }
}

/// Bandeau d'information dans le flux de l'écran (succès, avertissement, erreur).
class InlineNotice extends StatelessWidget {
  const InlineNotice({super.key, required this.message, required this.tone, this.title, this.action});

  final String message;
  final String? title;
  final NoticeTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, icon) = switch (tone) {
      NoticeTone.success => (c.successTint, c.success, PhosphorIconsLight.checkCircle),
      NoticeTone.warning => (c.warningTint, c.warning, PhosphorIconsLight.warning),
      NoticeTone.danger => (c.dangerTint, c.onDangerTint, PhosphorIconsLight.warningCircle),
      NoticeTone.info => (c.actionTint, c.onActionTint, PhosphorIconsLight.info),
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.x4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(title!, style: context.text.titleSmall!.copyWith(color: fg)),
                    const SizedBox(height: 2),
                  ],
                  Text(message, style: context.text.bodyMedium!.copyWith(color: fg)),
                  if (action != null) ...[const SizedBox(height: AppSpace.x3), action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum NoticeTone { info, success, warning, danger }
