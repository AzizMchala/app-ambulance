import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urgences_medicales/core/errors/app_failure.dart';
import 'package:urgences_medicales/core/services/location_service.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_draft.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_location.dart';
import 'package:urgences_medicales/features/sos/presentation/controllers/sos_history_controller.dart';
import 'package:urgences_medicales/features/sos/presentation/controllers/sos_location_controller.dart';
import 'package:urgences_medicales/features/sos/presentation/controllers/sos_submission_controller.dart';
import 'package:urgences_medicales/features/sos/presentation/providers/sos_providers.dart';

import '../../../support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer container({FakeSosRepository? repo, FakeLocationService? location}) {
    final c = ProviderContainer(
      overrides: [
        sosRepositoryProvider.overrideWithValue(repo ?? FakeSosRepository()),
        locationServiceProvider.overrideWithValue(location ?? FakeLocationService()),
      ],
      retry: (_, _) => null,
    );
    addTearDown(c.dispose);
    return c;
  }

  group('SosSubmissionController', () {
    const draftLocation = SosLocation(source: LocationSource.manual, address: 'Rue de Rome, Tunis');

    test('échec puis nouvel essai : même clé d\'idempotence, succès seulement après confirmation', () async {
      final repo = FakeSosRepository()..failNextCreate = const NetworkFailure();
      final c = container(repo: repo);
      final sub = c.listen(sosSubmissionControllerProvider, (_, _) {});
      final ctrl = c.read(sosSubmissionControllerProvider.notifier);
      final draft = SosDraft(clientRequestId: ctrl.clientRequestId, location: draftLocation);

      await ctrl.submit(draft);
      expect(c.read(sosSubmissionControllerProvider), isA<SubmissionFailed>());

      await ctrl.submit(draft);
      expect(c.read(sosSubmissionControllerProvider), isA<SubmissionSucceeded>());
      expect(repo.createdDrafts.map((d) => d.clientRequestId).toSet(), hasLength(1));
      sub.close();
    });
  });

  group('SosHistoryController', () {
    test('pagination et dédoublonnage', () async {
      final repo = FakeSosRepository(seed: [for (var i = 45; i >= 1; i--) sosRequest(id: i)]);
      final c = container(repo: repo);
      final sub = c.listen(sosHistoryControllerProvider, (_, _) {});

      var state = await c.read(sosHistoryControllerProvider.future);
      expect(state.items, hasLength(20));
      expect(state.hasMore, isTrue);

      // Une nouvelle demande arrive en tête : la page suivante décale d'un élément.
      repo.items.insert(0, sosRequest(id: 46));
      await c.read(sosHistoryControllerProvider.notifier).loadMore();
      state = c.read(sosHistoryControllerProvider).value!;
      // 20 + 19 : l'élément décalé n'apparaît qu'une fois, et aucun n'est perdu (45 à 7, sans trou).
      expect(state.items.map((r) => r.id).toList(), [for (var id = 45; id >= 7; id--) id]);
      sub.close();
    });

    test('actualisation en échec : la liste reste et l\'erreur est renvoyée', () async {
      final repo = FakeSosRepository(seed: [sosRequest(id: 1)]);
      final c = container(repo: repo);
      final sub = c.listen(sosHistoryControllerProvider, (_, _) {});
      await c.read(sosHistoryControllerProvider.future);

      repo.failList = const NetworkFailure();
      final failure = await c.read(sosHistoryControllerProvider.notifier).refresh();
      expect(failure, isA<NetworkFailure>());
      expect(c.read(sosHistoryControllerProvider).value!.items, hasLength(1));
      sub.close();
    });
  });

  group('SosLocationController', () {
    test('ne demande pas l\'autorisation tout seul', () async {
      final location = FakeLocationService(
        permission: LocationPermissionStatus.denied,
        permissionAfterRequest: LocationPermissionStatus.granted,
        fix: GeoFix(latitude: 36.8, longitude: 10.1, accuracyMeters: 8, capturedAt: DateTime.now()),
      );
      final c = container(location: location);
      c.read(sosLocationControllerProvider);
      await pumpEventQueue();
      expect(location.requestCount, 0);
      expect(
        c.read(sosLocationControllerProvider),
        isA<LocationUnavailable>().having((s) => s.problem, 'problem', LocationProblem.permissionNeeded),
      );

      await c.read(sosLocationControllerProvider.notifier).prepareForSending();
      expect(location.requestCount, 1);
      expect(c.read(sosLocationControllerProvider), isA<LocationReady>());
    });

    test('délai GPS sans position connue : problème « timeout »', () async {
      final c = container(location: FakeLocationService(fixError: const LocationTimeoutFailure()));
      c.read(sosLocationControllerProvider);
      await pumpEventQueue();
      expect(
        c.read(sosLocationControllerProvider),
        isA<LocationUnavailable>().having((s) => s.problem, 'problem', LocationProblem.timeout),
      );
    });
  });
}
