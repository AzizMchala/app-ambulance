/// Chemins du module E2, utilisables par les autres modules (ex. lien « Voir mes SOS » dans E1).
abstract final class SosPaths {
  static const home = '/sos';
  static const review = '/sos/new';
  static const history = '/sos/history';

  /// [justSent] affiche le bandeau de confirmation du serveur.
  static String detail(int id, {bool justSent = false}) => '/sos/$id${justSent ? '?sent=1' : ''}';
}
