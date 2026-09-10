import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/user_service.dart';
import '../../widgets/connect_call_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSendingReset = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                          children: [
                            const ConnectCallLogo(size: 92),

                            const SizedBox(height: 18),

                            Text(
                              'Welcome back',
                              style: AppTextStyles.authHeading,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Connect with your people, anytime.',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 26),

                            CustomTextField(
                              label: 'Email or Phone',
                              hint: 'mayank@connectcall.io',
                              controller: emailController,
                              keyboardType:
                                  TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 18),

                            PasswordField(
                              label: 'Password',
                              hint: '••••••••',
                              controller: passwordController,
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _isSendingReset
                                    ? null
                                    : _sendPasswordReset,
                                child: Text(
                                  _isSendingReset
                                      ? 'Sending...'
                                      : 'Forgot password?',
                                  style: AppTextStyles.link,
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            GradientButton(
                              text: _isLoading
                                  ? 'Logging in...'
                                  : 'Login',
                              onPressed:
                                  _isLoading ? null : _login,
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
                padding:
                    const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.footer,
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
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
      ),
    );
  }

  // ----------------------------------------------------------
  // FORGOT PASSWORD
  // ----------------------------------------------------------

  Future<void> _sendPasswordReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Enter your email first');
      return;
    }

    setState(() {
      _isSendingReset = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showMessage(
        'Password reset email sent. Check your inbox.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'invalid-email' =>
          'Please enter a valid email address.',
        'user-not-found' =>
          'No account found with this email.',
        'network-request-failed' =>
          'Network error. Check your internet connection.',
        _ =>
          error.message ?? 'Unable to send reset email.',
      };

      _showMessage(message);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong: $error',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSendingReset = false;
      });
    }
  }

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Please enter your email and password',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ------------------------------------------------------
      // SIGN IN WITH FIREBASE
      // ------------------------------------------------------

      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        _showMessage('Login failed.');
        return;
      }

      // Refresh Firebase user information.
      await user.reload();

      final refreshedUser =
          FirebaseAuth.instance.currentUser;

      // ------------------------------------------------------
      // EMAIL VERIFICATION CHECK
      // ------------------------------------------------------

      if (refreshedUser == null ||
          !refreshedUser.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        _showMessage(
          'Please verify your email before logging in.',
        );

        return;
      }

      // ------------------------------------------------------
      // SET USER ONLINE
      // ------------------------------------------------------

      await UserService.instance.updateOnlineStatus(
        refreshedUser.uid,
        true,
      );

      // ------------------------------------------------------
      // LOGIN SUCCESSFUL
      // ------------------------------------------------------

      if (!mounted) return;

      _showMessage('Login successful');

      context.go('/home');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'user-not-found' =>
          'No account found with this email.',

        'wrong-password' ||
        'invalid-credential' =>
          'Incorrect email or password.',

        'invalid-email' =>
          'Please enter a valid email address.',

        'user-disabled' =>
          'This account has been disabled.',

        'too-many-requests' =>
          'Too many attempts. Please try again later.',

        'network-request-failed' =>
          'Network error. Check your internet connection.',

        _ =>
          error.message ?? 'Login failed.',
      };

      _showMessage(message);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong: $error',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ----------------------------------------------------------
  // SNACKBAR
  // ----------------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}