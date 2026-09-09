import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/connect_call_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/password_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                  children: [
                    const SizedBox(height: 70),

                    const ConnectCallLogo(
                      size: 128,
                    ),

                    const SizedBox(height: 42),

                    Text(
                      'Welcome back',
                      style: AppTextStyles.authHeading,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Connect with your people, anytime.',
                      style: GoogleFonts.poppins(
                        fontSize: 23,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 70),

                    CustomTextField(
                      label: 'Email or Phone',
                      hint: 'mayank@connectcall.io',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 34),

                    PasswordField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: passwordController,
                    ),

                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Forgot password
                        },
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.link,
                        ),
                      ),
                    ),

                    const SizedBox(height: 44),

                    GradientButton(
                      text: 'Login',
                      onPressed: () {
                        // TODO: Connect authentication
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
                    "Don't have an account? ",
                    style: AppTextStyles.footer,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Create Account',
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