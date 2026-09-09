import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_design_system.dart';
import '../core/theme/app_text_styles.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;

  const PasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: 10),
        TextField(
          controller: widget.controller,
          obscureText: obscureText,
          style: AppTextStyles.input,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldBackground,
            hintText: widget.hint,
            hintStyle: AppTextStyles.hint,
            contentPadding: AppDesignSystem.fieldPadding,
            enabledBorder: AppDesignSystem.inputBorder(),
            focusedBorder: AppDesignSystem.inputBorder(focused: true),
            border: AppDesignSystem.inputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.secondaryText,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
