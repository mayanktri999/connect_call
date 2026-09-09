import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
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
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label,
        ),

        const SizedBox(height: 16),

        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.fieldBorder,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.input,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 32,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}