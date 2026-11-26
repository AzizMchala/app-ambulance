import 'package:go_router/go_router.dart';

import 'screens/hospital_detail_screen.dart';
import 'screens/hospital_queue_screen.dart';

export 'hospital_paths.dart';

/// Routes de l'espace hôpital. Le routeur principal n'y laisse entrer que le rôle RESPONDER.
final List<RouteBase> hospitalRoutes = [
  GoRoute(
    path: '/hospital',
    builder: (context, state) => const HospitalQueueScreen(),
    routes: [
      GoRoute(
        path: ':id',
        redirect: (context, state) => int.tryParse(state.pathParameters['id'] ?? '') == null ? '/hospital' : null,
        builder: (context, state) => HospitalDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
    ],
  ),
];
