import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/call_model.dart';

class CallService {
  CallService._();

  static final CallService instance = CallService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _calls =>
      _firestore.collection('calls');

  // ------------------------------------------------------------
  // CREATE CALL
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // GET CALL
  // ------------------------------------------------------------

  Future<CallModel?> getCall(
    String callId,
  ) async {
    final document = await _calls.doc(callId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return CallModel.fromMap(
      document.id,
      document.data()!,
    );
  }

  // ------------------------------------------------------------
  // LISTEN TO CALL
  // ------------------------------------------------------------

  Stream<CallModel?> listenToCall(
    String callId,
  ) {
    return _calls
        .doc(callId)
        .snapshots()
        .map((document) {
      if (!document.exists ||
          document.data() == null) {
        return null;
      }

      return CallModel.fromMap(
        document.id,
        document.data()!,
      );
    });
  }

  // ------------------------------------------------------------
  // INCOMING CALLS
  // ------------------------------------------------------------

  Stream<List<CallModel>> incomingCalls(
    String userId,
  ) {
    return _calls
        .where(
          'receiverId',
          isEqualTo: userId,
        )
        .where(
          'status',
          isEqualTo: 'ringing',
        )
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

  // ------------------------------------------------------------
  // ACCEPT CALL
  // ------------------------------------------------------------

  Future<void> acceptCall(
    String callId,
  ) async {
    await _calls.doc(callId).update({
      'status': 'accepted',
      'answeredAt': Timestamp.now(),
    });
  }

  // ------------------------------------------------------------
  // REJECT CALL
  // ------------------------------------------------------------

  Future<void> rejectCall(
    String callId,
  ) async {
    await _calls.doc(callId).update({
      'status': 'rejected',
      'endedAt': Timestamp.now(),
    });
  }

  // ------------------------------------------------------------
  // END CALL
  // ------------------------------------------------------------

  Future<void> endCall(
    String callId,
  ) async {
    await _calls.doc(callId).update({
      'status': 'ended',
      'endedAt': Timestamp.now(),
    });
  }

  // ------------------------------------------------------------
  // MISSED CALL
  // ------------------------------------------------------------

  Future<void> markAsMissed(
    String callId,
  ) async {
    await _calls.doc(callId).update({
      'status': 'missed',
      'endedAt': Timestamp.now(),
    });
  }

  // ============================================================
  // WEBRTC SIGNALING
  // ============================================================

  // ------------------------------------------------------------
  // SAVE OFFER
  // ------------------------------------------------------------

  Future<void> saveOffer(
    String callId,
    Map<String, dynamic> offer,
  ) async {
    await _calls.doc(callId).update({
      'offer': offer,
    });
  }

  // ------------------------------------------------------------
  // SAVE ANSWER
  // ------------------------------------------------------------

  Future<void> saveAnswer(
    String callId,
    Map<String, dynamic> answer,
  ) async {
    await _calls.doc(callId).update({
      'answer': answer,
      'status': 'accepted',
      'answeredAt': Timestamp.now(),
    });
  }

  // ------------------------------------------------------------
  // CALLER ICE CANDIDATE
  // ------------------------------------------------------------

  Future<void> addCallerIceCandidate(
    String callId,
    Map<String, dynamic> candidate,
  ) async {
    await _calls
        .doc(callId)
        .collection('callerCandidates')
        .add(candidate);
  }

  // ------------------------------------------------------------
  // RECEIVER ICE CANDIDATE
  // ------------------------------------------------------------

  Future<void> addReceiverIceCandidate(
    String callId,
    Map<String, dynamic> candidate,
  ) async {
    await _calls
        .doc(callId)
        .collection('receiverCandidates')
        .add(candidate);
  }

  // ------------------------------------------------------------
  // LISTEN TO CALLER ICE
  // ------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>>
      listenToCallerCandidates(
    String callId,
  ) {
    return _calls
        .doc(callId)
        .collection('callerCandidates')
        .snapshots();
  }

  // ------------------------------------------------------------
  // LISTEN TO RECEIVER ICE
  // ------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>>
      listenToReceiverCandidates(
    String callId,
  ) {
    return _calls
        .doc(callId)
        .collection('receiverCandidates')
        .snapshots();
  }
}