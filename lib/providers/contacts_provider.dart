import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../screens/auth/presence_service.dart';
import '../screens/auth/user_service.dart';

final presenceProvider = StreamProvider.autoDispose<Map<String, bool>>((ref) {
  return PresenceService.instance.presenceStream();
});

final contactsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return Stream.value(const <UserModel>[]);
  }

  final usersStream = UserService.instance.getUsers(
    currentUserId: currentUser.uid,
  );
  final presenceStream = PresenceService.instance.presenceStream();

  return presenceStream.asyncMap((presence) async {
    final users = await usersStream.first;

    return users
        .map(
          (user) => UserModel(
            uid: user.uid,
            name: user.name,
            email: user.email,
            profileImage: user.profileImage,
            isOnline: presence[user.uid] ?? false,
            createdAt: user.createdAt,
          ),
        )
        .toList();
  });
});
