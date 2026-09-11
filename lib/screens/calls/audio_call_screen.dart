import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/call_model.dart';
import '../calls/call_services.dart';
import '../auth/webrtc_service.dart';
import '../auth/user_service.dart';
import '../../models/user_model.dart';

class AudioCallScreen extends StatefulWidget {
  final String callId;
  final UserModel? receiver;
  final bool isCaller;

  const AudioCallScreen({
    super.key,
    required this.callId,
    this.receiver,
    this.isCaller = true,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  StreamSubscription<CallModel?>? _callSubscription;
  Timer? _timer;

  String _callerName = 'Calling...';
  int _seconds = 0;

  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isConnected = false;
  bool _ending = false;

  @override
  void initState() {
    super.initState();

    _loadCall();
    _listenToCall();
    _startWebRtc();
  }

  Future<void> _startWebRtc() async {
    try {
      if (widget.isCaller) {
        await WebRTCService.instance.startAsCaller(
          callId: widget.callId,
          isVideo: false,
        );
      }

      // Route audio to speakerphone by default so it can be heard clearly
      await WebRTCService.instance.enableSpeakerphone(_isSpeakerOn);

      WebRTCService.instance.setRemoteStreamHandler((stream) {
        if (!mounted) return;
        if (!_isConnected) {
          _startTimer();
        }
        setState(() {
          _isConnected = true;
        });
      });

      WebRTCService.instance.setConnectionStateHandler((state) {
        if (!mounted) return;
        debugPrint('🎧 AudioCall connection state updated: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          if (!_isConnected) {
            _startTimer();
          }
          setState(() {
            _isConnected = true;
          });
        }
      });
    } catch (error) {
      debugPrint('Failed to start audio call: $error');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds++;
      });
    });
  }

  String get _formattedTime {
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadCall() async {
    try {
      final call = await CallService.instance.getCall(widget.callId);
      if (call == null) return;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final otherUserId = call.callerId == currentUser.uid
          ? call.receiverId
          : call.callerId;

      final user = await UserService.instance.getUser(otherUserId);
      if (!mounted) return;

      setState(() {
        _callerName = user?.name.isNotEmpty == true
            ? user!.name
            : user?.email ?? 'Unknown';
      });
    } catch (_) {}
  }

  void _listenToCall() {
    _callSubscription = CallService.instance.listenToCall(widget.callId).listen(
      (call) {
        if (!mounted || call == null) return;

        if (call.status == CallStatus.accepted) {
          if (!_isConnected) {
            _startTimer();
          }
          setState(() {
            _isConnected = true;
          });
          // Ensure speaker state is applied when call connects
          WebRTCService.instance.enableSpeakerphone(_isSpeakerOn);
        }

        if (call.status == CallStatus.rejected ||
            call.status == CallStatus.missed ||
            call.status == CallStatus.ended) {
          _finishCall();
        }
      },
    );
  }

  Future<void> _toggleMute() async {
    final newValue = !_isMuted;
    await WebRTCService.instance.setMuted(newValue);
    if (!mounted) return;
    setState(() {
      _isMuted = newValue;
    });
  }

  Future<void> _toggleSpeaker() async {
    final newValue = !_isSpeakerOn;
    await WebRTCService.instance.enableSpeakerphone(newValue);
    if (!mounted) return;
    setState(() {
      _isSpeakerOn = newValue;
    });
  }

  Future<void> _endCall() async {
    if (_ending) return;

    setState(() {
      _ending = true;
    });

    _timer?.cancel();

    try {
      await CallService.instance.endCall(widget.callId);
    } catch (_) {}

    await WebRTCService.instance.dispose();

    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _finishCall() async {
    if (_ending) return;
    _ending = true;

    _timer?.cancel();
    await WebRTCService.instance.dispose();

    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _callSubscription?.cancel();
    WebRTCService.instance.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials(_callerName);

    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),

              // User Info & Status
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    _callerName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isConnected
                              ? const Color(0xFF10B981)
                              : Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isConnected
                            ? 'Connected  •  $_formattedTime'
                            : 'Connecting...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (!_isConnected)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                ],
              ),

              // Controls
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallControl(
                        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        active: _isMuted,
                        onTap: _toggleMute,
                      ),
                      _CallControl(
                        icon: _isSpeakerOn
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        label: _isSpeakerOn ? 'Speaker On' : 'Earpiece',
                        active: _isSpeakerOn,
                        onTap: _toggleSpeaker,
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    width: 72,
                    height: 72,
                    child: FloatingActionButton(
                      heroTag: 'end-call',
                      backgroundColor: const Color(0xFFEF4444),
                      elevation: 4,
                      onPressed: _ending ? null : _endCall,
                      child: const Icon(Icons.call_end_rounded, size: 34, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'End call',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
