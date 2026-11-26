import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Formats d'affichage communs (français pour cette version, prêts pour d'autres langues).
abstract final class Formatters {
  static String date(DateTime d, [String locale = 'fr']) => DateFormat('d MMM y', locale).format(d);

  static String dateLong(DateTime d, [String locale = 'fr']) => DateFormat('EEEE d MMMM y', locale).format(d);

  static String time(DateTime d, [String locale = 'fr']) => DateFormat('HH:mm', locale).format(d);

  static String monthYear(DateTime d, [String locale = 'fr']) {
    final s = DateFormat('MMMM y', locale).format(d);
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  /// Cinq décimales : environ un mètre, assez pour les secours sans fausse précision.
  static String coordinates(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  /// « à l'instant », « il y a 5 min », « il y a 2 h », puis la date.
  static String relative(AppLocalizations l, DateTime d, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(d);
    if (diff.inMinutes < 1) return l.relativeNow;
    if (diff.inMinutes < 60) return l.relativeMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l.relativeHours(diff.inHours);
    return l.relativeAt('${date(d)} · ${time(d)}');
  }
}
