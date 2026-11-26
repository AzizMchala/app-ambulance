import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// Limite la largeur du contenu (tablette, web) et applique la marge latérale commune.
class ContentFrame extends StatelessWidget {
  const ContentFrame({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    // heightFactor 1 : prend la hauteur de son contenu (sinon il remplit tout, ex. dans une barre du bas).
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSize.contentMax),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
          child: child,
        ),
      ),
    );
  }
}
