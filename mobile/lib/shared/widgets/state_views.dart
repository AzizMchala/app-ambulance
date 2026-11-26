import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';
import '../../l10n/app_localizations.dart';
import 'app_button.dart';

/// Vues d'état communes : chargement, vide, erreur. Mêmes visuels dans tous les modules.

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.4)),
          if (label != null) ...[
            const SizedBox(height: AppSpace.x4),
            Text(label!, style: context.text.bodyMedium, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.x8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: danger ? c.dangerTint : c.surface, shape: BoxShape.circle),
                child: Icon(icon, size: 28, color: danger ? c.onDangerTint : c.inkSoft),
              ),
              const SizedBox(height: AppSpace.x5),
              Text(title, style: context.text.headlineSmall, textAlign: TextAlign.center),
              if (body != null) ...[
                const SizedBox(height: AppSpace.x2),
                Text(body!, style: context.text.bodyMedium, textAlign: TextAlign.center),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpace.x6),
                AppButton(label: actionLabel!, onPressed: onAction, variant: AppButtonVariant.secondary, expand: false),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Erreur pleine page avec bouton « Réessayer ».
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MessageView(
      icon: PhosphorIconsLight.cloudWarning,
      title: message,
      actionLabel: AppLocalizations.of(context).commonRetry,
      onAction: onRetry,
      danger: true,
    );
  }
}
