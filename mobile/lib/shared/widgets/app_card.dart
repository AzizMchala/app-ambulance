import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';

/// Carte blanche du design system. Cliquable si [onTap] est fourni.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.x5),
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl);
    final content = Padding(padding: padding, child: child);
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      container: true,
      child: Material(
        color: color ?? context.colors.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// Petit titre de section en capitales espacées.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpace.x1, bottom: AppSpace.x3),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(text.toUpperCase(), style: context.text.labelSmall)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Ligne « libellé : valeur » des fiches de détail.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.selectable = false});

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: context.text.bodyMedium)),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            flex: 3,
            child: selectable
                ? SelectableText(value, style: style, textAlign: TextAlign.end)
                : Text(value, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

/// Pastille ronde avec une icône fine, utilisée en tête de carte et de ligne.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.background, required this.foreground, this.size = 44});

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, color: foreground, size: size * 0.48),
    );
  }
}
