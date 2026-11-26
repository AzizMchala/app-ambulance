import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/hospital_remote_data_source.dart';
import '../../data/repositories/hospital_sos_repository_impl.dart';
import '../../domain/repositories/hospital_sos_repository.dart';
import '../../domain/usecases/hospital_usecases.dart';

/// Injection de dépendances de l'espace hôpital. Surcharger [hospitalSosRepositoryProvider] en test.
final hospitalSosRepositoryProvider = Provider<HospitalSosRepository>(
  (ref) => HospitalSosRepositoryImpl(HospitalRemoteDataSource(ref.watch(dioProvider))),
);

final getHospitalQueueProvider = Provider((ref) => GetHospitalQueue(ref.watch(hospitalSosRepositoryProvider)));
final getHospitalSosDetailProvider = Provider((ref) => GetHospitalSosDetail(ref.watch(hospitalSosRepositoryProvider)));
final decideSosProvider = Provider((ref) => DecideSos(ref.watch(hospitalSosRepositoryProvider)));
