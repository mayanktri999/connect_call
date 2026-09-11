import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/call_model.dart';
import '../calls/call_services.dart';
import '../auth/user_service.dart';

class IncomingCallListener {
  IncomingCallListener._();

  static final IncomingCallListener instance = IncomingCallListener._();

  StreamSubscription<List<CallModel>>? _subscription;

  bool _isShowingCall = false;

  void start(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    _subscription?.cancel();

    _subscription = CallService.instance.incomingCalls(user.uid).listen((
      calls,
    ) async {
      if (calls.isEmpty || _isShowingCall) {
        return;
      }

      final call = calls.first;

      _isShowingCall = true;

      final caller = await UserService.instance.getUser(call.callerId);

      if (caller == null) {
        _isShowingCall = false;
        return;
      }

      if (!context.mounted) {
        _isShowingCall = false;
        return;
      }

      await context.push(
        '/incoming-call',
        extra: {'callId': call.callId, 'caller': caller, 'callType': call.type},
      );

      _isShowingCall = false;
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _isShowingCall = false;
  }
}
