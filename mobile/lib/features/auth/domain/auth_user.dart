import 'package:flutter/foundation.dart';

/// Utilisateur connecté, tel que renvoyé par `/api/auth/me`.
///
/// Authentification PARTAGÉE par tous les modules : E2 ne fait que la consommer.
/// Le profil patient détaillé (E1) s'ajoutera à côté, sans second système de connexion.
@immutable
class AuthUser {
  const AuthUser({required this.id, required this.fullName, required this.email, required this.role});

  final int id;
  final String fullName;
  final String email;

  /// `PATIENT` ou `RESPONDER` (personnel des secours, utilisé par E3/E6).
  final String role;

  /// Personnel hospitalier / secours : accès à l'espace hôpital au lieu des écrans patient.
  bool get isResponder => role == 'RESPONDER';

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  factory AuthUser.fromJson(Map<String, Object?> json) => AuthUser(
    id: (json['id']! as num).toInt(),
    fullName: json['fullName']! as String,
    email: json['email']! as String,
    role: json['role']! as String,
  );
}
