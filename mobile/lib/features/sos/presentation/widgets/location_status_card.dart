import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/sos_location_controller.dart';
import 'location_map.dart';

/// Carte « Votre position » : état réel du GPS, coordonnées, précision, et l'action qui débloque.
class LocationStatusCard extends StatelessWidget {
  const LocationStatusCard({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onAllow,
    required this.onOpenSettings,
    this.showMap = true,
    this.mapHeight = 150,
  });

  final SosLocationState state;
  final VoidCallback onRetry;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;
  final bool showMap;
  final double mapHeight;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpace.x4),
      child: AnimatedSize(
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        alignment: Alignment.topCenter,
        child: switch (state) {
          LocationChecking() => _Header(
            icon: PhosphorIconsLight.crosshair,
            tone: StatusTone.neutral,
            title: l.locationChecking,
            busy: true,
          ),
          LocationAcquiring() => _Header(
            icon: PhosphorIconsLight.crosshair,
            tone: StatusTone.info,
            title: l.locationAcquiring,
            busy: true,
          ),
          LocationReady(:final reading) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                icon: reading.isStale ? PhosphorIconsLight.clockCounterClockwise : PhosphorIconsLight.crosshair,
                tone: reading.isStale ? StatusTone.warning : StatusTone.success,
                title: reading.isStale ? l.locationStale : l.locationReady,
                subtitle: reading.isStale
                    ? l.locationStaleAge(reading.ageAt(DateTime.now()).inMinutes)
                    : l.locationAccuracy(reading.fix.accuracyMeters.round()),
                trailing: IconButton(
                  tooltip: l.locationActionRefresh,
                  onPressed: onRetry,
                  icon: Icon(PhosphorIconsLight.arrowClockwise, color: c.inkSoft),
                ),
              ),
              if (showMap) ...[
                const SizedBox(height: AppSpace.x3),
                LocationMap(
                  latitude: reading.fix.latitude,
                  longitude: reading.fix.longitude,
                  accuracyMeters: reading.fix.accuracyMeters,
                  stale: reading.isStale,
                  height: mapHeight,
                ),
              ],
              const SizedBox(height: AppSpace.x3),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      Formatters.coordinates(reading.fix.latitude, reading.fix.longitude),
                      style: context.text.bodyMedium!.copyWith(color: c.inkSoft),
                    ),
                  ),
                  Text(l.locationCapturedAt(Formatters.time(reading.fix.capturedAt)), style: context.text.bodySmall),
                ],
              ),
            ],
          ),
          LocationUnavailable(:final problem) => _problem(context, l, problem),
        },
      ),
    );
  }

  Widget _problem(BuildContext context, AppLocalizations l, LocationProblem problem) {
    final (title, hint, actionLabel, action, icon) = switch (problem) {
      LocationProblem.serviceDisabled => (
        l.locationServiceOff,
        l.locationServiceOffHint,
        l.locationActionEnable,
        onOpenSettings,
        PhosphorIconsLight.gpsSlash,
      ),
      LocationProblem.permissionNeeded => (
        l.locationPermissionNeeded,
        l.locationPermissionNeededHint,
        l.locationActionAllow,
        onAllow,
        PhosphorIconsLight.mapPin,
      ),
      LocationProblem.permissionDeniedForever => (
        l.locationPermissionDenied,
        l.locationPermissionDeniedForeverHint,
        // Le navigateur n'a pas d'écran de réglages ouvrable : on propose un nouvel essai.
        kIsWeb ? l.locationActionRetry : l.locationActionSettings,
        kIsWeb ? onRetry : onOpenSettings,
        PhosphorIconsLight.lockKey,
      ),
      LocationProblem.timeout => (
        l.locationTimeout,
        l.locationTimeoutHint,
        l.locationActionRetry,
        onRetry,
        PhosphorIconsLight.cellSignalSlash,
      ),
      LocationProblem.unavailable => (
        l.locationError,
        l.locationErrorHint,
        l.locationActionRetry,
        onRetry,
        PhosphorIconsLight.warningCircle,
      ),
    };
    return _Header(
      icon: icon,
      tone: problem == LocationProblem.permissionNeeded ? StatusTone.info : StatusTone.warning,
      title: title,
      subtitle: hint,
      trailing: AppButton(
        label: actionLabel,
        onPressed: action,
        variant: AppButtonVariant.secondary,
        expand: false,
        compact: true,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.tone,
    required this.title,
    this.subtitle,
    this.trailing,
    this.busy = false,
  });

  final IconData icon;
  final StatusTone tone;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = statusToneColors(context, tone);
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: busy
                ? Padding(
                    padding: const EdgeInsets.all(11),
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.foreground),
                  )
                : IconBadge(icon: icon, background: colors.background, foreground: colors.foreground),
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleMedium),
                if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: context.text.bodySmall)],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: AppSpace.x2), trailing!],
        ],
      ),
    );
  }
}
