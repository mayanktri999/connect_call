import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/call_model.dart';
import '../calls/call_services.dart';
import '../auth/webrtc_service.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallModel call;
  final String callerName;

  const IncomingCallScreen({
    super.key,
    required this.call,
    required this.callerName,
  });

  @override
  State<IncomingCallScreen> createState() =>
      _IncomingCallScreenState();
}

class _IncomingCallScreenState
    extends State<IncomingCallScreen> {
  bool _loading = false;

  bool get isVideo =>
      widget.call.type == CallType.video;

  Future<void> _acceptCall() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      await WebRTCService.instance.startAsReceiver(
        callId: widget.call.callId,
        isVideo: isVideo,
      );

      if (!mounted) return;

      await CallService.instance.acceptCall(
        widget.call.callId,
      );

      if (!mounted) return;

      if (isVideo) {
        context.go(
          '/video-call/${widget.call.callId}',
        );
      } else {
        context.go(
          '/audio-call/${widget.call.callId}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to accept call: $e',
          ),
        ),
      );

      setState(() {
        _loading = false;
      });

      await WebRTCService.instance.dispose();
    }
  }

  Future<void> _rejectCall() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      await CallService.instance.rejectCall(
        widget.call.callId,
      );

      await WebRTCService.instance.dispose();

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to reject call: $e',
          ),
        ),
      );
    }
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
                    radius: 58,
                    child: Icon(
                      Icons.person,
                      size: 58,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    widget.callerName,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    isVideo
                        ? 'Incoming video call'
                        : 'Incoming audio call',
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'ConnectCall',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              Column(
                children: [
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(
                        bottom: 24,
                      ),
                      child: CircularProgressIndicator(),
                    ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallButton(
                        icon: Icons.call_end,
                        label: 'Decline',
                        onPressed:
                            _loading ? null : _rejectCall,
                        backgroundColor:
                            Colors.red,
                      ),
                      _CallButton(
                        icon: isVideo
                            ? Icons.videocam
                            : Icons.call,
                        label: 'Accept',
                        onPressed:
                            _loading ? null : _acceptCall,
                        backgroundColor:
                            Colors.green,
                      ),
                    ],
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

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            heroTag: label,
            backgroundColor: backgroundColor,
            onPressed: onPressed,
            child: Icon(
              icon,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label),
      ],
    );
  }
}