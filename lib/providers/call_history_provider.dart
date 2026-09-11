import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/call_model.dart';

final callHistoryProvider = StreamProvider.autoDispose<List<CallModel>>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return Stream.value(const <CallModel>[]);
  }

  return FirebaseFirestore.instance
      .collection('calls')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .where((document) {
              final data = document.data();
              return data['callerId'] == currentUser.uid ||
                  data['receiverId'] == currentUser.uid;
            })
            .map((document) => CallModel.fromMap(document.id, document.data()))
            .toList();
      });
});
