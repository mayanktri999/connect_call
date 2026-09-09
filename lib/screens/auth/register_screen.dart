import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/password_field.dart';
import 'login_screen.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 42),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            color: AppColors.secondaryText,
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Back',
                            style: AppTextStyles.footer.copyWith(
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 55),

                    Text(
                      'Create your account',
                      style: AppTextStyles.authHeading.copyWith(
                        fontSize: 39,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Start connecting with people around you.',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 70),

                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Your full name',
                      controller: nameController,
                    ),

                    const SizedBox(height: 32),

                    CustomTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 32),

                    PasswordField(
                      label: 'Password',
                      hint: 'At least 8 characters',
                      controller: passwordController,
                    ),

                    const SizedBox(height: 32),

                    PasswordField(
                      label: 'Confirm Password',
                      hint: 'Repeat password',
                      controller: confirmPasswordController,
                    ),

                    const SizedBox(height: 48),

                    GradientButton(
                      text: 'Create Account',
                      onPressed: () {
                        // TODO: Registration
                      },
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 38,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFF0F2F5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.footer,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Login',
                      style: AppTextStyles.link,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}