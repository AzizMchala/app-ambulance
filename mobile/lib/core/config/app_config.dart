/// Configuration par environnement, injectée au build :
///
/// ```
/// flutter run --dart-define-from-file=config/dev-emulator.json \
///             --dart-define-from-file=config/secrets.local.json
/// ```
///
/// Aucun secret n'est écrit dans le code. La clé MapTiler vit dans `config/secrets.local.json`
/// (ignoré par Git) ; sans elle, la carte bascule sur les tuiles OpenStreetMap standard.
abstract final class AppConfig {
  static const String environment = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8082');

  static const String mapTilerKey = String.fromEnvironment('MAPTILER_KEY');

  static bool get isProduction => environment == 'prod';

  static const Duration connectTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
