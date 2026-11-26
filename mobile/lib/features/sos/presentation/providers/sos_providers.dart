import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/services/location_service.dart';
import '../../data/datasources/sos_remote_data_source.dart';
import '../../data/repositories/sos_repository_impl.dart';
import '../../domain/entities/sos_request.dart';
import '../../domain/repositories/sos_repository.dart';
import '../../domain/usecases/build_sos_draft.dart';
import '../../domain/usecases/get_sos_location.dart';
import '../../domain/usecases/sos_usecases.dart';

/// Injection de dépendances du module E2. Pour tester ou brancher une autre source,
/// il suffit de surcharger [sosRepositoryProvider] ou [locationServiceProvider] dans un `ProviderScope`.

final sosRepositoryProvider = Provider<SosRepository>(
  (ref) => SosRepositoryImpl(SosRemoteDataSource(ref.watch(dioProvider))),
);

final getSosLocationProvider = Provider((ref) => GetSosLocation(ref.watch(locationServiceProvider)));
final buildSosDraftProvider = Provider((ref) => const BuildSosDraft());
final sendSosProvider = Provider((ref) => SendSos(ref.watch(sosRepositoryProvider)));
final getSosPageProvider = Provider((ref) => GetSosPage(ref.watch(sosRepositoryProvider)));
final getLatestSosProvider = Provider((ref) => GetLatestSos(ref.watch(sosRepositoryProvider)));
final getSosDetailProvider = Provider((ref) => GetSosDetail(ref.watch(sosRepositoryProvider)));
final getSosStatusProvider = Provider((ref) => GetSosStatus(ref.watch(sosRepositoryProvider)));
final getSosStatusHistoryProvider = Provider((ref) => GetSosStatusHistory(ref.watch(sosRepositoryProvider)));
final cancelSosProvider = Provider((ref) => CancelSos(ref.watch(sosRepositoryProvider)));

/// Dernière demande du patient, affichée sur l'écran principal.
final latestSosProvider = FutureProvider.autoDispose<SosRequest?>((ref) => ref.watch(getLatestSosProvider)());
