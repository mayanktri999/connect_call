import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';

class UserService {
  UserService._();
  Stream<List<UserModel>> getUsers({
  required String currentUserId,
}) {
  return _users
      .where('uid', isNotEqualTo: currentUserId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((document) {
      return UserModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  });
}
  

  static final UserService instance = UserService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    print('🔥 Creating Firestore user: ${user.uid}');

    await _users.doc(user.uid).set(user.toMap());

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

  Future<void> updateOnlineStatus(
    String uid,
    bool isOnline,
  ) async {
    await _users.doc(uid).update({
      'isOnline': isOnline,
    });
  }
}