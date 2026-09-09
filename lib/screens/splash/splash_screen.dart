import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/connect_call_logo.dart';

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

    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;

      setState(() {
        activeDot = (activeDot + 1) % 3;
      });
    });

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      context.go('/login');
    });
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, Color(0xFFEAFBFF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -size.width * 0.34,
              right: -size.width * 0.25,
              child: Container(
                width: size.width * 1.1,
                height: size.width * 1.1,
                decoration: const BoxDecoration(
                  color: AppColors.decorativeCircle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.26,
              left: -size.width * 0.28,
              child: Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 28,
                              offset: Offset(0, 18),
                            ),
                          ],
                        ),
                        child: const ConnectCallLogo(size: 146),
                      ),
                      const SizedBox(height: 28),
                      Text('ConnectCall', style: AppTextStyles.heading),
                      const SizedBox(height: 10),
                      Text(
                        'Connect with anyone, anywhere.',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: activeDot == index ? 18 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: index == activeDot
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.35),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
