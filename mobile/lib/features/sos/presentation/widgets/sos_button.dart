import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// Le bouton SOS de l'écran principal : grand, rouge, entouré d'un halo qui respire lentement.
///
/// Un appui n'envoie rien : il ouvre l'écran de vérification, où l'envoi demande une confirmation.
/// Le halo s'arrête si le système demande de réduire les animations.
class SosButton extends StatefulWidget {
  const SosButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(vsync: this, duration: AppMotion.breathe);
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    const size = AppSize.sosButton;

    return Semantics(
      button: true,
      label: l.sosButtonSemantics,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: SizedBox(
          width: size + 72,
          height: size + 72,
          child: AnimatedBuilder(
            animation: _breath,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_breath.value);
              return Stack(
                alignment: Alignment.center,
                children: [
                  _Halo(
                    size: size + 40 + 28 * t,
                    color: c.danger.withValues(alpha: 0.07 + 0.04 * (1 - t)),
                  ),
                  _Halo(size: size + 18 + 10 * t, color: c.danger.withValues(alpha: 0.12)),
                  child!,
                ],
              );
            },
            child: AnimatedScale(
              scale: _pressed ? 0.96 : 1,
              duration: AppMotion.fast,
              curve: AppMotion.standard,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    radius: 1.1,
                    colors: [Color.lerp(c.danger, Colors.white, 0.12)!, c.danger],
                  ),
                  boxShadow: [
                    BoxShadow(color: c.danger.withValues(alpha: 0.32), blurRadius: 36, offset: const Offset(0, 16)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l.sosButtonLabel,
                      style: TextStyle(
                        fontFamily: appDisplayFamily,
                        fontSize: 60,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: c.onDanger,
                      ),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      l.sosButtonHint,
                      style: context.text.labelMedium!.copyWith(color: c.onDanger.withValues(alpha: 0.88)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
