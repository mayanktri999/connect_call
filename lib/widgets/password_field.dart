import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
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
        Text(
          widget.label.toUpperCase(),
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
            controller: widget.controller,
            obscureText: obscureText,
            style: AppTextStyles.input,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 32,
              ),
              border: InputBorder.none,
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
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}