import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_user.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../../features/sos/presentation/sos_routes.dart';
import '../../features/sos_hospital/presentation/hospital_routes.dart';
import '../splash_screen.dart';

/// Routeur principal de l'application commune.
///
/// Chaque module expose sa liste de routes (`sosRoutes` et `hospitalRoutes` pour E2) et l'ajoute ici :
/// rien d'autre n'est à modifier pour intégrer E1, E3, E4, E5 ou E6.
final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<AsyncValue<AuthUser?>>(const AsyncLoading());
  ref.listen(sessionControllerProvider, (_, next) => session.value = next, fireImmediately: true);
  ref.onDispose(session.dispose);

  const publicPaths = {'/login', '/register'};

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    redirect: (context, state) {
      final s = session.value;
      final path = state.matchedLocation;
      // Restauration en cours, ou impossible (serveur injoignable) : l'écran d'attente le dit
      // et propose d'appeler le SAMU, sans renvoyer le patient vers la connexion.
      if (!s.hasValue) return path == '/splash' ? null : '/splash';
      final user = s.value;
      if (user == null) return publicPaths.contains(path) ? null : '/login';

      // Chaque rôle a son espace : un patient n'ouvre jamais l'espace hôpital, et inversement.
      // (Le serveur applique la même séparation : 403 sur les routes de l'autre rôle.)
      final home = user.isResponder ? HospitalPaths.home : SosPaths.home;
      if (publicPaths.contains(path) || path == '/splash' || path == '/') return home;
      if (user.isResponder && path.startsWith(SosPaths.home)) return home;
      if (!user.isResponder && path.startsWith(HospitalPaths.home)) return home;
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      ...sosRoutes,
      ...hospitalRoutes,
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
