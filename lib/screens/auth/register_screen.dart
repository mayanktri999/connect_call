import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/password_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDesignSystem.createScreenBackground(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: AppDesignSystem.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppDesignSystem.maxContentWidth,
                      ),
                      child: Container(
                        padding: AppDesignSystem.panelPadding,
                        decoration: AppDesignSystem.authCardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.pop();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.secondaryText,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Back',
                                    style: AppTextStyles.footer.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Create your account',
                              style: AppTextStyles.authHeading,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start connecting with people around you.',
                              style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: 26),
                            CustomTextField(
                              label: 'Full Name',
                              hint: 'Your full name',
                              controller: nameController,
                            ),
                            const SizedBox(height: 18),
                            CustomTextField(
                              label: 'Email',
                              hint: 'you@example.com',
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 18),
                            PasswordField(
                              label: 'Password',
                              hint: 'At least 8 characters',
                              controller: passwordController,
                            ),
                            const SizedBox(height: 18),
                            PasswordField(
                              label: 'Confirm Password',
                              hint: 'Repeat password',
                              controller: confirmPasswordController,
                            ),
                            const SizedBox(height: 24),
                            GradientButton(
                              text: 'Create Account',
                              onPressed: () {
                                // TODO: Registration
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.footer,
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: Text('Login', style: AppTextStyles.link),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
