import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/call_model.dart';
import '../calls/call_services.dart';
import '../auth/webrtc_service.dart';
import '../auth/user_service.dart';

class AudioCallScreen extends StatefulWidget {
  final String callId;

  const AudioCallScreen({
    super.key,
    required this.callId,
  });

  @override
  State<AudioCallScreen> createState() =>
      _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  StreamSubscription<CallModel?>? _callSubscription;

  String _callerName = 'Calling...';

  bool _isMuted = false;
  bool _isConnected = false;
  bool _ending = false;

  @override
  void initState() {
    super.initState();

    _loadCall();
    _listenToCall();
  }

  Future<void> _loadCall() async {
    try {
      final call = await CallService.instance.getCall(
        widget.callId,
      );

      if (call == null) return;

      final currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      final otherUserId =
          call.callerId == currentUser.uid
              ? call.receiverId
              : call.callerId;

      final user =
          await UserService.instance.getUser(
        otherUserId,
      );

      if (!mounted) return;

      setState(() {
        _callerName =
            user?.name.isNotEmpty == true
                ? user!.name
                : user?.email ?? 'Unknown';
      });
    } catch (_) {}
  }

  void _listenToCall() {
    _callSubscription =
        CallService.instance
            .listenToCall(widget.callId)
            .listen((call) {
      if (!mounted || call == null) return;

      if (call.status == CallStatus.accepted) {
        setState(() {
          _isConnected = true;
        });
      }

      if (call.status == CallStatus.rejected ||
          call.status == CallStatus.missed ||
          call.status == CallStatus.ended) {
        _finishCall();
      }
    });
  }

  Future<void> _toggleMute() async {
    final newValue = !_isMuted;

    await WebRTCService.instance.setMuted(
      newValue,
    );

    if (!mounted) return;

    setState(() {
      _isMuted = newValue;
    });
  }

  Future<void> _endCall() async {
    if (_ending) return;

    setState(() {
      _ending = true;
    });

    try {
      await CallService.instance.endCall(
        widget.callId,
      );
    } catch (_) {}

    await WebRTCService.instance.dispose();

    if (!mounted) return;

    context.go('/home');
  }

  Future<void> _finishCall() async {
    if (_ending) return;

    _ending = true;

    await WebRTCService.instance.dispose();

    if (!mounted) return;

    context.go('/home');
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 32,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),

              Column(
                children: [
                  const CircleAvatar(
                    radius: 64,
                    child: Icon(
                      Icons.person,
                      size: 64,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    _callerName,
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _isConnected
                        ? 'Connected'
                        : 'Calling...',
                    style:
                        theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 8),

                  if (!_isConnected)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),

              Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      _CallControl(
                        icon: _isMuted
                            ? Icons.mic_off
                            : Icons.mic,
                        label: _isMuted
                            ? 'Unmute'
                            : 'Mute',
                        active: _isMuted,
                        onTap: _toggleMute,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: 68,
                    height: 68,
                    child: FloatingActionButton(
                      heroTag: 'end-call',
                      backgroundColor: Colors.red,
                      onPressed:
                          _ending ? null : _endCall,
                      child: const Icon(
                        Icons.call_end,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text('End call'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CallControl({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            heroTag: label,
            elevation: 0,
            onPressed: onTap,
            child: Icon(icon),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}