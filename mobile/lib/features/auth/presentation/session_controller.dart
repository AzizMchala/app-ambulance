import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

/// Session de l'application commune : `null` = déconnecté.
/// Le routeur s'en sert pour protéger toutes les routes des modules.
class SessionController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    final sub = ref.read(sessionExpiredProvider).stream.listen((_) => _expire());
    ref.onDispose(sub.cancel);
    return ref.read(authRepositoryProvider).restore();
  }

  Future<void> login(String email, String password) async {
    final user = await ref.read(authRepositoryProvider).login(email: email, password: password);
    state = AsyncData(user);
  }

  Future<void> register(String fullName, String email, String password) async {
    final user = await ref.read(authRepositoryProvider).register(fullName: fullName, email: email, password: password);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> _expire() async {
    if (state.value == null) return;
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final sessionControllerProvider = AsyncNotifierProvider<SessionController, AuthUser?>(SessionController.new);
