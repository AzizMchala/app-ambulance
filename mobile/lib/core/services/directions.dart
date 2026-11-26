import 'package:url_launcher/url_launcher.dart';

/// Ouvre l'itinéraire vers la position du patient dans l'application de cartes du téléphone.
/// Action volontaire de l'équipe hospitalière : rien n'est envoyé sans appui.
Future<bool> openDirections({double? latitude, double? longitude, String? address}) {
  final destination = latitude != null && longitude != null ? '$latitude,$longitude' : (address ?? '');
  final uri = Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': destination});
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
