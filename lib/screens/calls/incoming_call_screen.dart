import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            const Text(
              'Incoming call',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8CA1B7),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: 112,
              height: 112,
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
                    fontSize: 32,
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

            const SizedBox(height: 7),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: 15,
                  color: Color(0xFF08B1D0),
                ),
                SizedBox(width: 6),
                Text(
                  'Audio call',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8CA1B7),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 3),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallButton(
                  icon: Icons.call_end_rounded,
                  label: 'Decline',
                  backgroundColor: const Color(0xFFFFEEF0),
                  iconColor: const Color(0xFFFF4E55),
                  onTap: () {
                    context.pop();
                  },
                ),

                _CallButton(
                  icon: Icons.call_rounded,
                  label: 'Accept',
                  backgroundColor: const Color(0xFFE8FBF4),
                  iconColor: const Color(0xFF0CB47B),
                  onTap: () {
                    // Will connect to Audio Calling screen next.
                  },
                ),
              ],
            ),

            const SizedBox(height: 45),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 27,
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF52657A),
          ),
        ),
      ],
    );
  }
}