import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../screens/auth/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      _user = null;
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _user = await UserService.instance.getUser(firebaseUser.uid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}