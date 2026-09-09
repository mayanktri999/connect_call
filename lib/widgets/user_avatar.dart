import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final bool online;
  final double size;

  const UserAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.online = false,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: color,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * .32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (online)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * .25,
                height: size * .25,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}