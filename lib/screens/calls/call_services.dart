import 'package:cloud_firestore/cloud_firestore.dart';

import '/models/call_model.dart';

class CallService {
  CallService._();

  static final CallService instance = CallService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _calls =>
      _firestore.collection('calls');

  // ----------------------------------------------------------
  // CREATE CALL
  // ----------------------------------------------------------

  Future<String> createCall({
    required String callerId,
    required String receiverId,
    required CallType type,
  }) async {
    final document = _calls.doc();

    final call = CallModel(
      callId: document.id,
      callerId: callerId,
      receiverId: receiverId,
      type: type,
      status: CallStatus.ringing,
      createdAt: DateTime.now(),
    );

    await document.set(call.toMap());

    return document.id;
  }

  // ----------------------------------------------------------
  // GET CALL
  // ----------------------------------------------------------

  Future<CallModel?> getCall(String callId) async {
    final document = await _calls.doc(callId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return CallModel.fromMap(
      document.id,
      document.data()!,
    );
  }

  // ----------------------------------------------------------
  // LISTEN TO A CALL
  // ----------------------------------------------------------

  Stream<CallModel?> listenToCall(String callId) {
    return _calls.doc(callId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return CallModel.fromMap(
        snapshot.id,
        snapshot.data()!,
      );
    });
  }

  // ----------------------------------------------------------
  // LISTEN FOR INCOMING CALLS
  // ----------------------------------------------------------

  Stream<List<CallModel>> incomingCalls(String userId) {
    return _calls
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return CallModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // ----------------------------------------------------------
  // ACCEPT CALL
  // ----------------------------------------------------------

  Future<void> acceptCall(String callId) async {
    await _calls.doc(callId).update({
      'status': 'accepted',
      'answeredAt': Timestamp.now(),
    });
  }

  // ----------------------------------------------------------
  // REJECT CALL
  // ----------------------------------------------------------

  Future<void> rejectCall(String callId) async {
    await _calls.doc(callId).update({
      'status': 'rejected',
      'endedAt': Timestamp.now(),
    });
  }

  // ----------------------------------------------------------
  // END CALL
  // ----------------------------------------------------------

  Future<void> endCall(String callId) async {
    await _calls.doc(callId).update({
      'status': 'ended',
      'endedAt': Timestamp.now(),
    });
  }

  // ----------------------------------------------------------
  // MARK CALL AS MISSED
  // ----------------------------------------------------------

  Future<void> markAsMissed(String callId) async {
    await _calls.doc(callId).update({
      'status': 'missed',
      'endedAt': Timestamp.now(),
    });
  }
}