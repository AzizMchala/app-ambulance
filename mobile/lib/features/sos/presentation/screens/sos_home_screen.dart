import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/constants/emergency_numbers.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_messages.dart';
import '../../../../core/services/dialer.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/account_menu.dart';
import '../../../auth/presentation/session_controller.dart';
import '../../domain/entities/sos_request.dart';
import '../controllers/sos_location_controller.dart';
import '../providers/sos_providers.dart';
import '../sos_paths.dart';
import '../widgets/location_status_card.dart';
import '../widgets/sos_button.dart';
import '../widgets/sos_request_tile.dart';
import '../widgets/sos_status_style.dart';

/// Écran principal du module E2 : bouton SOS, état du GPS, dernière demande, accès à l'historique.
class SosHomeScreen extends ConsumerWidget {
  const SosHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final user = ref.watch(sessionControllerProvider).value;
    final location = ref.watch(sosLocationControllerProvider);
    final locationCtrl = ref.read(sosLocationControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(latestSosProvider);
            await Future.wait([locationCtrl.refresh(), ref.read(latestSosProvider.future).catchError((_) => null)]);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.x10),
            children: [
              ContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpace.x4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user == null ? '' : l.sosHomeGreeting(user.firstName),
                            style: context.text.bodyMedium,
                          ),
                        ),
                        const AccountMenuButton(),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(l.sosHomeTitle, style: context.text.headlineLarge),
                    const SizedBox(height: AppSpace.x2),
                    Text(l.sosHomeSubtitle, style: context.text.bodyMedium),
                    const SizedBox(height: AppSpace.x4),
                    Center(child: SosButton(onPressed: () => context.push(SosPaths.review))),
                    const SizedBox(height: AppSpace.x4),
                    SectionLabel(l.locationTitle),
                    LocationStatusCard(
                      state: location,
                      onRetry: locationCtrl.refresh,
                      onAllow: () => locationCtrl.refresh(askPermission: true),
                      onOpenSettings: locationCtrl.openSettings,
                      mapHeight: 132,
                    ),
                    const SizedBox(height: AppSpace.x6),
                    SectionLabel(l.latestTitle),
                    const _LatestRequestCard(),
                    const SizedBox(height: AppSpace.x6),
                    Row(
                      children: [
                        Expanded(
                          child: _ShortcutTile(
                            icon: PhosphorIconsLight.clockCounterClockwise,
                            title: l.homeHistory,
                            subtitle: l.homeHistoryHint,
                            onTap: () => context.push(SosPaths.history),
                          ),
                        ),
                        const SizedBox(width: AppSpace.x3),
                        Expanded(
                          child: _ShortcutTile(
                            icon: PhosphorIconsLight.phoneCall,
                            title: l.homeCall(EmergencyNumbers.samu),
                            subtitle: l.homeCallHint,
                            iconColor: c.danger,
                            onTap: () => openDialer(EmergencyNumbers.samu),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestRequestCard extends ConsumerWidget {
  const _LatestRequestCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final latest = ref.watch(latestSosProvider);

    return switch (latest) {
      AsyncData<SosRequest?>(value: null) => AppCard(
        child: Row(
          children: [
            IconBadge(
              icon: PhosphorIconsLight.tray,
              background: context.colors.surfaceSunken,
              foreground: context.colors.inkMuted,
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(child: Text(l.latestEmpty, style: context.text.bodyMedium)),
          ],
        ),
      ),
      AsyncData<SosRequest?>(:final value?) => _LatestFilled(request: value),
      AsyncError(:final error) => AppCard(
        child: InlineNotice(
          tone: NoticeTone.danger,
          message: failureMessage(l, error is AppFailure ? error : UnexpectedFailure(error)),
          action: AppButton(
            label: l.commonRetry,
            compact: true,
            expand: false,
            variant: AppButtonVariant.secondary,
            onPressed: () => ref.invalidate(latestSosProvider),
          ),
        ),
      ),
      _ => const AppCard(child: SizedBox(height: 56, child: LoadingView())),
    };
  }
}

class _LatestFilled extends StatelessWidget {
  const _LatestFilled({required this.request});

  final SosRequest request;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tone = statusToneColors(context, request.status.tone);
    return AppCard(
      onTap: () => context.push(SosPaths.detail(request.id)),
      semanticLabel: '${l.latestTitle} : ${l.requestNumber(request.id)}, ${request.status.label(l)}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(icon: request.status.icon, background: tone.background, foreground: tone.foreground),
                const SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.status.headline(l), style: context.text.titleMedium),
                      Text(
                        '${l.requestNumber(request.id)} · ${Formatters.relative(l, request.createdAt)}',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusPill(label: request.status.label(l), tone: request.status.tone),
              ],
            ),
            const SizedBox(height: AppSpace.x3),
            Text(
              sosLocationSummary(request),
              style: context.text.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpace.x2),
            Text(l.commonSeeDetails, style: context.text.labelMedium!.copyWith(color: context.colors.action)),
          ],
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpace.x4),
      semanticLabel: '$title. $subtitle',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: iconColor ?? context.colors.ink),
            const SizedBox(height: AppSpace.x4),
            Text(title, style: context.text.titleSmall),
            const SizedBox(height: 2),
            Text(subtitle, style: context.text.bodySmall, maxLines: 2),
          ],
        ),
      ),
    );
  }
}
