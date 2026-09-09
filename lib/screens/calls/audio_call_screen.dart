import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;

  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {
            _seconds++;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _callDuration {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            const Text(
              'Audio Call',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8CA1B7),
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE4F8FC),
                border: Border.all(
                  color: const Color(0xFF08B1D0),
                  width: 3,
                ),
              ),
              child: const Center(
                child: Text(
                  'SJ',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF08B1D0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Sarah Johnson',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _callDuration,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8CA1B7),
              ),
            ),

            const Spacer(flex: 3),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: isMuted
                      ? Icons.mic_off_rounded
                      : Icons.mic_rounded,
                  label: isMuted ? 'Unmute' : 'Mute',
                  active: isMuted,
                  onTap: () {
                    setState(() {
                      isMuted = !isMuted;
                    });
                  },
                ),

                const SizedBox(width: 28),

                _ControlButton(
                  icon: isSpeakerOn
                      ? Icons.volume_up_rounded
                      : Icons.volume_down_rounded,
                  label: 'Speaker',
                  active: isSpeakerOn,
                  onTap: () {
                    setState(() {
                      isSpeakerOn = !isSpeakerOn;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4E55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'End call',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF52657A),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ControlButton({
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF08B1D0)
                  : const Color(0xFFEAF1F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: active
                  ? Colors.white
                  : const Color(0xFF60758B),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF52657A),
          ),
        ),
      ],
    );
  }
}