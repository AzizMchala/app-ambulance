import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import 'session_controller.dart';

/// Bouton de compte (déconnexion), commun à tous les espaces : patient, hôpital, futurs modules.
class AccountMenuButton extends ConsumerWidget {
  const AccountMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<void>(
      tooltip: l.authLogout,
      icon: Icon(PhosphorIconsLight.userCircle, color: context.colors.ink, size: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      itemBuilder: (_) => [
        PopupMenuItem<void>(
          onTap: () => ref.read(sessionControllerProvider.notifier).logout(),
          child: Row(
            children: [
              const Icon(PhosphorIconsLight.signOut, size: 20),
              const SizedBox(width: AppSpace.x3),
              Text(l.authLogout),
            ],
          ),
        ),
      ],
    );
  }
}
