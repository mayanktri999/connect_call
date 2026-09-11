import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    print('🔥 Creating Firestore user: ${user.uid}');

    await _users.doc(user.uid).set({
      ...user.toMap(),
      'uid': user.uid,
    });

    print('✅ Firestore user created successfully');
  }

  Future<UserModel?> getUser(String uid) async {
    final document = await _users.doc(uid).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return UserModel.fromMap(
      document.id,
      document.data()!,
    );
  }

  Stream<List<UserModel>> getUsers({
    required String currentUserId,
  }) {
    return _users.snapshots().map((snapshot) {
      return snapshot.docs
          .where(
            (document) => document.id != currentUserId,
          )
          .map(
            (document) => UserModel.fromMap(
              document.id,
              document.data(),
            ),
          )
          .toList();
    });
  }

  Future<void> updateOnlineStatus(
    String uid,
    bool isOnline,
  ) async {
    print(
      '🟢 Updating online status: $uid -> $isOnline',
    );

    await _users.doc(uid).set(
      {
        'uid': uid,
        'isOnline': isOnline,
      },
      SetOptions(merge: true),
    );

    print('✅ Online status updated');
  }
}