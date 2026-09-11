import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../calls/call_services.dart';
import '../auth/webrtc_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final UserModel? receiver;
  final bool isCaller;

  const VideoCallScreen({
    super.key,
    required this.callId,
    this.receiver,
    this.isCaller = true,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Timer? _timer;

  int _seconds = 0;

  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;
  bool _ending = false;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _renderersReady = false;

  @override
  void initState() {
    super.initState();

    _startTimer();
    _initializeWebRtc();
  }

  Future<void> _initializeWebRtc() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      if (widget.isCaller) {
        await WebRTCService.instance.startAsCaller(
          callId: widget.callId,
          isVideo: true,
        );
      }

      // Automatically enable speakerphone for video calls
      await WebRTCService.instance.enableSpeakerphone(_isSpeakerOn);

      if (!widget.isCaller) {
        _localRenderer.srcObject = WebRTCService.instance.localStream;
      }

      _localRenderer.srcObject = WebRTCService.instance.localStream;
      WebRTCService.instance.setRemoteStreamHandler((stream) {
        _remoteRenderer.srcObject = stream;
        if (mounted) setState(() {});
      });

      if (mounted) {
        setState(() {
          _renderersReady = true;
        });
      }
    } catch (error) {
      debugPrint('Failed to start video call: $error');
    }
  }

  void _startTimer() {
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

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    WebRTCService.instance.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _toggleMute() async {
    final newValue = !_isMuted;
    await WebRTCService.instance.setMuted(newValue);
    if (!mounted) return;
    setState(() {
      _isMuted = newValue;
    });
  }

  Future<void> _toggleCamera() async {
    final newValue = !_isCameraOff;
    await WebRTCService.instance.setCameraEnabled(!newValue);
    if (!mounted) return;
    setState(() {
      _isCameraOff = newValue;
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

  Future<void> _switchCamera() async {
    await WebRTCService.instance.switchCamera();
    if (!mounted) return;
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  Future<void> _endCall() async {
    if (_ending) return;

    _ending = true;
    _timer?.cancel();

    try {
      await CallService.instance.endCall(widget.callId);
    } catch (e) {
      debugPrint('Failed to end call: $e');
    }

    await WebRTCService.instance.dispose();

    if (!mounted) return;

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.receiver?.name.isEmpty != false
        ? 'Unknown User'
        : widget.receiver!.name;

    final initials = _getInitials(name);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ------------------------------------------------
            // MAIN VIDEO AREA
            // ------------------------------------------------

            Positioned.fill(
              child: _isCameraOff
                  ? _buildCameraOffView(name, initials)
                  : _buildVideoPlaceholder(name, initials),
            ),

            // ------------------------------------------------
            // TOP BAR
            // ------------------------------------------------
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _RoundButton(icon: Icons.arrow_back_rounded, onTap: _endCall),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------
            // REMOTE USER INFO
            // ------------------------------------------------
            Positioned(
              left: 20,
              bottom: 145,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------
            // SELF VIDEO PREVIEW
            // ------------------------------------------------
            Positioned(
              top: 76,
              right: 16,
              child: GestureDetector(
                onTap: _switchCamera,
                child: Container(
                  width: 105,
                  height: 145,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B1B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: _isCameraOff
                      ? const Center(
                          child: Icon(
                            Icons.videocam_off_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        )
                      : _renderersReady && _localRenderer.srcObject != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: RTCVideoView(_localRenderer, mirror: _isFrontCamera),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              color: Colors.white54,
                              size: 42,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _isFrontCamera ? 'You' : 'Camera',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // ------------------------------------------------
            // BOTTOM CONTROLS
            // ------------------------------------------------
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallControlButton(
                      icon: _isMuted
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      label: _isMuted ? 'Unmute' : 'Mute',
                      active: !_isMuted,
                      onTap: _toggleMute,
                    ),

                    _CallControlButton(
                      icon: _isCameraOff
                          ? Icons.videocam_off_rounded
                          : Icons.videocam_rounded,
                      label: _isCameraOff ? 'Camera on' : 'Camera',
                      active: !_isCameraOff,
                      onTap: _toggleCamera,
                    ),

                    _CallControlButton(
                      icon: _isSpeakerOn
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      label: 'Speaker',
                      active: _isSpeakerOn,
                      onTap: _toggleSpeaker,
                    ),

                    _CallControlButton(
                      icon: Icons.cameraswitch_rounded,
                      label: 'Flip',
                      active: true,
                      onTap: _switchCamera,
                    ),

                    _CallControlButton(
                      icon: Icons.call_end_rounded,
                      label: 'End',
                      active: true,
                      destructive: true,
                      onTap: _endCall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CAMERA OFF VIEW
  // ----------------------------------------------------------

  Widget _buildCameraOffView(String name, String initials) {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Camera is off',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // VIDEO PLACEHOLDER
  // ----------------------------------------------------------

  Widget _buildVideoPlaceholder(String name, String initials) {
    if (_renderersReady && _remoteRenderer.srcObject != null) {
      return RTCVideoView(_remoteRenderer);
    }

    return Container(
      color: const Color(0xFF202020),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connecting...',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ============================================================
// ROUND BUTTON
// ============================================================

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

// ============================================================
// CALL CONTROL BUTTON
// ============================================================

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool destructive;
  final VoidCallback onTap;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = destructive
        ? const Color(0xFFE53935)
        : active
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.08);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
