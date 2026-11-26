import '../config/app_config.dart';

/// Fournisseur de tuiles de la carte, partagé par tous les modules (E2, E3…).
///
/// - Avec `MAPTILER_KEY` (offre gratuite MapTiler, même configuration que LammaPets) : style « streets-v2 ».
/// - Sans clé : tuiles OpenStreetMap standard, réservées au développement (politique d'usage OSM).
abstract final class MapTiles {
  static bool get usesMapTiler => AppConfig.mapTilerKey.isNotEmpty;

  static String get urlTemplate => usesMapTiler
      ? 'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}@2x.png?key=${AppConfig.mapTilerKey}'
      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// flutter_map ajoute déjà « © » devant : ne pas le répéter.
  static String get attribution => usesMapTiler ? 'MapTiler © OpenStreetMap' : 'OpenStreetMap';

  /// Identifiant envoyé aux serveurs de tuiles (exigé par OpenStreetMap).
  static const userAgentPackageName = 'com.urgencesmedicales.urgences_medicales';
}
