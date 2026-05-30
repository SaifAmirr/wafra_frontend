import 'package:flutter/material.dart';
import 'package:wafra_frontend/features/auth/presentation/signup_screen.dart';

// Each onboarding asset is a *complete* design mockup (logo, photo, title,
// subtitle, dot indicators, and CTA button are all baked into the PNG).
// So the page just renders the image full-bleed and overlays invisible tap
// zones over the Skip text and the bottom CTA button.

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _images = [
    'assets/images/onboarding_1.png',
    'assets/images/onboarding_2.png',
    'assets/images/onboarding_3.png',
  ];

  void _onNext() {
    if (_currentPage < _images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateForward();
    }
  }

  void _navigateForward() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Matches the green background of every onboarding asset so any
      // letterboxed strip blends in on non-matching aspect ratios.
      backgroundColor: const Color(0xFF1A5C38),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _OnboardingPage(
              imageAsset: _images[i],
              onNext: _onNext,
            ),
          ),

          // Invisible "Skip" tap target — positioned over the baked-in
          // "Skip" label drawn in the top-right of every PNG.
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: GestureDetector(
                onTap: _navigateForward,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: size.width * 0.28,
                  height: size.height * 0.07,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single page ─────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final String imageAsset;
  final VoidCallback onNext;

  const _OnboardingPage({
    required this.imageAsset,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Full-bleed background image (logo + photo + title + subtitle +
        // dots + CTA are all part of the asset).
        // BoxFit.fill ensures every pixel of the image maps to the screen
        // so baked-in content (titles, dots, CTA) stays correctly placed
        // on all screen sizes without any clipping or scrolling.
        Positioned.fill(
          child: Image.asset(
            imageAsset,
            fit: BoxFit.fill,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF1A5C38),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),

        // Invisible CTA tap target — positioned over the baked-in
        // "Get Started" / "Next" button at the bottom of every PNG.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: GestureDetector(
                onTap: onNext,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(height: size.height * 0.085),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
