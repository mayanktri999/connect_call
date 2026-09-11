import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/call_model.dart';
import '../screens/calls/call_services.dart';

final callProvider = StreamProvider.autoDispose.family<CallModel?, String>((
  ref,
  callId,
) {
  return CallService.instance.listenToCall(callId);
});

final incomingCallsProvider = StreamProvider.autoDispose<List<CallModel>>((
  ref,
) {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return Stream.value(const <CallModel>[]);
  }

  return CallService.instance.incomingCalls(currentUser.uid);
});

final callActionsProvider = Provider<CallActions>((ref) {
  return CallActions(CallService.instance);
});

class CallActions {
  const CallActions(this._service);

  final CallService _service;

  Future<String> createCall({
    required String receiverId,
    required CallType type,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw StateError('A signed-in user is required to start a call.');
    }

    return _service.createCall(
      callerId: currentUser.uid,
      receiverId: receiverId,
      type: type,
    );
  }

  Future<void> accept(String callId) => _service.acceptCall(callId);

  Future<void> reject(String callId) => _service.rejectCall(callId);

  Future<void> end(String callId) => _service.endCall(callId);

  Future<void> markAsMissed(String callId) => _service.markAsMissed(callId);
}
