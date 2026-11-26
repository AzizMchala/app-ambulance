import 'package:urgences_medicales/core/errors/app_failure.dart';
import 'package:urgences_medicales/core/services/location_service.dart';
import 'package:urgences_medicales/features/auth/domain/auth_user.dart';
import 'package:urgences_medicales/features/auth/presentation/session_controller.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_draft.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_location.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_request.dart';
import 'package:urgences_medicales/features/sos/domain/entities/sos_status.dart';
import 'package:urgences_medicales/features/sos/domain/repositories/sos_repository.dart';
import 'package:urgences_medicales/shared/models/page_result.dart';

/// Doublures de test. Elles ne vivent que dans test/ : l'application n'embarque aucune donnée fictive.

final testNow = DateTime(2026, 11, 25, 14, 30);

SosRequest sosRequest({
  int id = 1,
  SosStatus status = SosStatus.pending,
  String? decisionMessage,
  SosLocation location = const SosLocation(source: LocationSource.manual, address: '12 rue de Marseille, Tunis'),
  DateTime? createdAt,
}) => SosRequest(
  id: id,
  location: location,
  status: status,
  decisionMessage: decisionMessage,
  createdAt: createdAt ?? testNow,
  updatedAt: createdAt ?? testNow,
);

class FakeLocationService implements LocationService {
  FakeLocationService({
    this.serviceEnabled = true,
    this.permission = LocationPermissionStatus.granted,
    this.permissionAfterRequest,
    this.fix,
    this.fixError,
    this.lastKnown,
  });

  bool serviceEnabled;
  LocationPermissionStatus permission;
  LocationPermissionStatus? permissionAfterRequest;
  GeoFix? fix;
  AppFailure? fixError;
  GeoFix? lastKnown;
  int requestCount = 0;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermissionStatus> checkPermission() async => permission;

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    requestCount++;
    permission = permissionAfterRequest ?? permission;
    return permission;
  }

  @override
  Future<GeoFix> currentFix({required Duration timeout}) async {
    if (fixError != null) throw fixError!;
    return fix!;
  }

  @override
  Future<GeoFix?> lastKnownFix() async => lastKnown;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}

/// Dépôt en mémoire qui imite le comportement du serveur (idempotence, demande active unique).
class FakeSosRepository implements SosRepository {
  FakeSosRepository({List<SosRequest>? seed, this.history = const []}) : items = [...?seed];

  final List<SosRequest> items;
  final List<SosHistoryEntry> history;
  AppFailure? failNextCreate;
  AppFailure? failList;
  final createdDrafts = <SosDraft>[];
  final listCalls = <int>[];

  @override
  Future<SosRequest> create(SosDraft draft) async {
    createdDrafts.add(draft);
    final failure = failNextCreate;
    if (failure != null) {
      failNextCreate = null;
      throw failure;
    }
    final created = SosRequest(
      id: items.length + 100,
      location: draft.location,
      status: SosStatus.pending,
      createdAt: testNow,
      updatedAt: testNow,
    );
    items.insert(0, created);
    return created;
  }

  @override
  Future<PageResult<SosRequest>> list({required int page, required int size}) async {
    listCalls.add(page);
    if (failList != null) throw failList!;
    final start = page * size;
    final slice = items.skip(start).take(size).toList();
    return PageResult(
      items: slice,
      page: page,
      size: size,
      totalElements: items.length,
      totalPages: (items.length / size).ceil(),
    );
  }

  @override
  Future<SosRequest> getById(int id) async =>
      items.firstWhere((r) => r.id == id, orElse: () => throw const NotFoundFailure());

  @override
  Future<SosStatusSnapshot> getStatus(int id) async {
    final r = await getById(id);
    return SosStatusSnapshot(id: r.id, status: r.status, decisionMessage: r.decisionMessage, updatedAt: r.updatedAt);
  }

  @override
  Future<List<SosHistoryEntry>> getHistory(int id) async => history;

  @override
  Future<SosRequest> cancel(int id) async {
    final i = items.indexWhere((r) => r.id == id);
    items[i] = items[i].copyWith(status: SosStatus.cancelled);
    return items[i];
  }
}

class FakeSession extends SessionController {
  @override
  Future<AuthUser?> build() async =>
      const AuthUser(id: 1, fullName: 'Aziz Mchala', email: 'aziz@test.tn', role: 'PATIENT');
}
