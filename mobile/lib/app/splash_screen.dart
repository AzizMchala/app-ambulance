import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/constants/emergency_numbers.dart';
import '../core/errors/app_failure.dart';
import '../core/errors/failure_messages.dart';
import '../core/services/dialer.dart';
import '../features/auth/presentation/session_controller.dart';
import '../l10n/app_localizations.dart';
import '../shared/widgets/widgets.dart';
import 'theme/app_colors.dart';
import 'theme/app_tokens.dart';

/// Affiché pendant la restauration de la session. Si le serveur est injoignable,
/// le dit et propose d'appeler le SAMU plutôt que de laisser le patient bloqué.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final error = session.hasError && !session.isLoading ? session.error : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ContentFrame(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: c.dangerTint, borderRadius: BorderRadius.circular(AppRadius.lg)),
                  child: Icon(PhosphorIconsFill.firstAidKit, color: c.danger, size: 32),
                ),
                const SizedBox(height: AppSpace.x6),
                if (error == null)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.2))
                else ...[
                  Text(
                    failureMessage(l, error is AppFailure ? error : UnexpectedFailure(error)),
                    style: context.text.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpace.x6),
                  AppButton(label: l.commonRetry, onPressed: () => ref.invalidate(sessionControllerProvider)),
                  const SizedBox(height: AppSpace.x3),
                  AppButton(
                    label: l.homeCall(EmergencyNumbers.samu),
                    icon: PhosphorIconsLight.phoneCall,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => openDialer(EmergencyNumbers.samu),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
