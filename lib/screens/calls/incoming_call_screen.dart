import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../calls/call_services.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final UserModel caller;
  final CallType callType;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.caller,
    required this.callType,
  });

  @override
  State<IncomingCallScreen> createState() =>
      _IncomingCallScreenState();
}

class _IncomingCallScreenState
    extends State<IncomingCallScreen> {

  bool _isProcessing = false;

  String get _callTypeText {
    return widget.callType == CallType.video
        ? 'Video call'
        : 'Audio call';
  }

  String get _initials {
    final name = widget.caller.name.trim();

    if (name.isEmpty) {
      return '?';
    }

    final parts = name.split(' ');

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _acceptCall() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await CallService.instance.acceptCall(widget.callId);

      if (!mounted) return;

      if (widget.callType == CallType.video) {
        context.go(
          '/video-call',
          extra: {
            'callId': widget.callId,
            'receiver': widget.caller,
          },
        );
      } else {
        context.go(
          '/audio-call',
          extra: {
            'callId': widget.callId,
            'receiver': widget.caller,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to accept the call'),
        ),
      );
    }
  }

  Future<void> _rejectCall() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await CallService.instance.rejectCall(widget.callId);

      if (!mounted) return;

      context.pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to reject the call'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 32,
          ),
          child: Column(
            children: [
              const SizedBox(height: 30),

              const Text(
                'Incoming call',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _callTypeText,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              CircleAvatar(
                radius: 70,
                backgroundColor: const Color(0xFFE8EEF8),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                widget.caller.name.isEmpty
                    ? 'Unknown user'
                    : widget.caller.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.caller.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallButton(
                    icon: Icons.call_end_rounded,
                    label: 'Decline',
                    backgroundColor: Colors.red,
                    onTap: _isProcessing
                        ? null
                        : _rejectCall,
                  ),
                  _CallButton(
                    icon: widget.callType == CallType.video
                        ? Icons.videocam_rounded
                        : Icons.call_rounded,
                    label: 'Accept',
                    backgroundColor: Colors.green,
                    onTap: _isProcessing
                        ? null
                        : _acceptCall,
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: onTap == null
                  ? backgroundColor.withOpacity(0.4)
                  : backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}