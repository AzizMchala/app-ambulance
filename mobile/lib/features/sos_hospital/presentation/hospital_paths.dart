/// Chemins de l'espace hôpital (rôle RESPONDER).
abstract final class HospitalPaths {
  static const home = '/hospital';

  static String detail(int id) => '/hospital/$id';
}
