import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_design_system.dart';
import '../core/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.input,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldBackground,
            hintText: hint,
            hintStyle: AppTextStyles.hint,
            contentPadding: AppDesignSystem.fieldPadding,
            enabledBorder: AppDesignSystem.inputBorder(),
            focusedBorder: AppDesignSystem.inputBorder(focused: true),
            border: AppDesignSystem.inputBorder(),
          ),
        ),
      ],
    );
  }
}
