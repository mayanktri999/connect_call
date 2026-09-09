import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_design_system.dart';

class AppSearchField extends StatelessWidget {
  final String hintText;

  const AppSearchField({super.key, this.hintText = 'Search people...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: AppDesignSystem.mediumRadius,
        border: Border.all(color: AppColors.fieldBorder, width: 1.2),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.hintText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 19,
            color: AppColors.secondaryText,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}
