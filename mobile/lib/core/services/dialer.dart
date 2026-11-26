import 'package:url_launcher/url_launcher.dart';

/// Ouvre le composeur avec le numéro prérempli. L'appel reste une décision du patient.
Future<bool> openDialer(String number) => launchUrl(Uri(scheme: 'tel', path: number));
