import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  final String hintText;

  const AppSearchField({
    super.key,
    this.hintText = 'Search people...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9AAFC3),
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: Color(0xFF9AAFC3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
        ),
      ),
    );
  }
}