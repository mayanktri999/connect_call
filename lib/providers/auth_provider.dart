import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth/auth_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.instance.authStateChanges;
});

final authProvider = AsyncNotifierProvider<AuthNotifier, void>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login({required String email, required String password}) async {
    await _run(
      () => AuthService.instance.login(email: email, password: password),
    );
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _run(
      () => AuthService.instance.register(email: email, password: password),
    );
  }

  Future<void> logout() async {
    await _run(AuthService.instance.logout);
  }

  Future<void> _run(Future<Object?> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
    });
  }
}
