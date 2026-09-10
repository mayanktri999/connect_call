import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  PresenceService._();

  static final PresenceService instance = PresenceService._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference get _presenceRef =>
      _database.ref('presence');

  Future<void> setOnline() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final userPresenceRef =
        _presenceRef.child(user.uid);

    final connectedRef =
        _database.ref('.info/connected');

    connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value == true;

      if (!connected) {
        return;
      }

      await userPresenceRef.onDisconnect().set(false);

      await userPresenceRef.set(true);
    });
  }

  Future<void> setOffline() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _presenceRef
        .child(user.uid)
        .set(false);
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
        result[entry.key.toString()] =
            entry.value == true;
      }

      return result;
    });
  }
}