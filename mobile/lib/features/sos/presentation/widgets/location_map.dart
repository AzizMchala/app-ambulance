import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/services/map_tiles.dart';
import '../../../../l10n/app_localizations.dart';

/// Carte d'aperçu centrée sur une position réelle, avec le cercle de précision.
/// Sans coordonnées, un encart neutre le dit : on ne centre jamais la carte sur un lieu inventé.
class LocationMap extends StatelessWidget {
  const LocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.height = 180,
    this.stale = false,
    this.interactive = false,
  });

  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final double height;

  /// Position ancienne : marqueur gris au lieu de bleu.
  final bool stale;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg);

    if (latitude == null || longitude == null) {
      return Container(
        height: height * 0.6,
        decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: radius),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsLight.mapTrifold, color: c.inkMuted, size: 28),
            const SizedBox(height: AppSpace.x2),
            Text(AppLocalizations.of(context).locationMapUnavailable, style: context.text.bodySmall),
          ],
        ),
      );
    }

    final point = LatLng(latitude!, longitude!);
    final marker = stale ? c.inkMuted : c.action;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        child: ExcludeSemantics(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 16,
              interactionOptions: InteractionOptions(
                flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(urlTemplate: MapTiles.urlTemplate, userAgentPackageName: MapTiles.userAgentPackageName),
              if (accuracyMeters != null && accuracyMeters! > 0)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: point,
                      radius: accuracyMeters!,
                      useRadiusInMeter: true,
                      color: marker.withValues(alpha: 0.12),
                      borderColor: marker.withValues(alpha: 0.4),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 26,
                    height: 26,
                    child: Container(
                      decoration: BoxDecoration(
                        color: marker,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: c.shadowCard,
                      ),
                    ),
                  ),
                ],
              ),
              SimpleAttributionWidget(
                source: Text(MapTiles.attribution),
                backgroundColor: c.surface.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
