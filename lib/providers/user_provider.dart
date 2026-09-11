import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../screens/auth/user_service.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() => _loadUser();

  Future<UserModel?> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return UserService.instance.getUser(firebaseUser.uid);
  }

  Future<void> loadUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadUser);
  }
}