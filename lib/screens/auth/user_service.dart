import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ----------------------------------------------------------
  // CREATE USER
  // ----------------------------------------------------------

  Future<void> createUser(UserModel user) async {
    print('🔥 Creating Firestore user: ${user.uid}');

    await _users.doc(user.uid).set({
      ...user.toMap(),
      'uid': user.uid,
    });

    print('✅ Firestore user created successfully');
  }

  // ----------------------------------------------------------
  // GET SINGLE USER
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // GET ALL OTHER USERS
  // ----------------------------------------------------------

  Stream<List<UserModel>> getUsers({
    required String currentUserId,
  }) {
    return _users.snapshots().map((snapshot) {
      return snapshot.docs
          .where((document) => document.id != currentUserId)
          .map((document) {
        return UserModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // ----------------------------------------------------------
  // UPDATE ONLINE STATUS
  // ----------------------------------------------------------

  Future<void> updateOnlineStatus(
    String uid,
    bool isOnline,
  ) async {
    await _users.doc(uid).set(
      {
        'isOnline': isOnline,
        'uid': uid,
      },
      SetOptions(merge: true),
    );
  }
}