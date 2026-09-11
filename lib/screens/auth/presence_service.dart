import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  PresenceService._();

  static final PresenceService instance = PresenceService._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DatabaseEvent>? _connectionSubscription;
  String? _activeUid;

  DatabaseReference get _presenceRef => _database.ref('presence');

  Future<void> setOnline() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    _activeUid = user.uid;
    final userPresenceRef = _presenceRef.child(user.uid);

    final connectedRef = _database.ref('.info/connected');

    await _connectionSubscription?.cancel();
    _connectionSubscription = connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value == true;

      if (!connected) {
        return;
      }

      try {
        await userPresenceRef.onDisconnect().set(false);
        await userPresenceRef.set(true);
      } catch (_) {
        // The next connection event will retry the presence write.
      }
    });
  }

  Future<void> setOffline() async {
    final uid = _activeUid ?? _auth.currentUser?.uid;

    if (uid == null) {
      return;
    }

    _activeUid = null;
    await _presenceRef.child(uid).set(false);

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }

  Stream<Map<String, bool>> presenceStream() {
    return _presenceRef.onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) {
        return <String, bool>{};
      }

      if (value is! Map) {
        return <String, bool>{};
      }

      final result = <String, bool>{};

      for (final entry in value.entries) {
        result[entry.key.toString()] = entry.value == true;
      }

      return result;
    });
  }
}
