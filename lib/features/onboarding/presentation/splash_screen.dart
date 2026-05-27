import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/onboarding/presentation/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1A5C38),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x33000000)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.063),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth * 0.60,
                  height: screenHeight * 0.24,
                  child: Image.asset(
                    'assets/images/splash_food_illustration-3e592e.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.019),
                Text(
                  'Wafra',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.092,
                    height: 40 / 36,
                    letterSpacing: -0.9,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: screenHeight * 0.009),
                Text(
                  'FOOD SHARING',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.036,
                    height: 20 / 14,
                    letterSpacing: 0.35,
                    color: const Color(0xCCFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
