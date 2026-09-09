import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/connect_call_logo.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int activeDot = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) {
        if (!mounted) return;

        setState(() {
          activeDot = (activeDot + 1) % 3;
        });
      },
    );

    Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // Top-right decorative circle
          Positioned(
            top: -size.width * 0.42,
            right: -size.width * 0.35,
            child: Container(
              width: size.width * 1.15,
              height: size.width * 1.15,
              decoration: const BoxDecoration(
                color: AppColors.decorativeCircle,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Bottom-left decorative circle
          Positioned(
            bottom: -size.width * 0.34,
            left: -size.width * 0.38,
            child: Container(
              width: size.width * 0.88,
              height: size.width * 0.88,
              decoration: const BoxDecoration(
                color: AppColors.decorativeCircle,
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(
                  flex: 4,
                ),

                const ConnectCallLogo(
                  size: 192,
                ),

                const SizedBox(height: 48),

                Text(
                  'ConnectCall',
                  style: AppTextStyles.heading,
                ),

                const SizedBox(height: 12),

                Text(
                  'Connect with anyone, anywhere.',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),

                const Spacer(
                  flex: 5,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(
                            index == activeDot ? 1 : 0.45,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 65),
              ],
            ),
          ),
        ],
      ),
    );
  }
}