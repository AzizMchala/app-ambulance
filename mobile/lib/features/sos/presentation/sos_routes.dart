import 'package:go_router/go_router.dart';

import 'screens/sos_detail_screen.dart';
import 'screens/sos_history_screen.dart';
import 'screens/sos_home_screen.dart';
import 'screens/sos_review_screen.dart';

export 'sos_paths.dart';

/// Routes du module E2, à enregistrer dans le routeur principal :
///
/// ```dart
/// GoRouter(routes: [...authRoutes, ...sosRoutes, ...appointmentRoutes /* E4 */]);
/// ```
///
/// Elles sont protégées par la redirection globale (session obligatoire).
final List<RouteBase> sosRoutes = [
  GoRoute(
    path: '/sos',
    builder: (context, state) => const SosHomeScreen(),
    routes: [
      GoRoute(path: 'new', builder: (context, state) => const SosReviewScreen()),
      GoRoute(path: 'history', builder: (context, state) => const SosHistoryScreen()),
      GoRoute(
        path: ':id',
        redirect: (context, state) => int.tryParse(state.pathParameters['id'] ?? '') == null ? '/sos' : null,
        builder: (context, state) => SosDetailScreen(
          id: int.parse(state.pathParameters['id']!),
          justSent: state.uri.queryParameters['sent'] == '1',
        ),
      ),
    ],
  ),
];
