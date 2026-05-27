import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/auth/presentation/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      title: "Don't waste food,\nshare it",
      subtitle:
          "Join our community to reduce food waste and help those in need by sharing surplus food.",
      buttonLabel: 'Get Started',
      imagePlaceholderAsset: 'assets/images/onboarding_1.png',
    ),
    _OnboardingData(
      title: "Restaurants post\nsurplus",
      subtitle:
          "Local restaurants can easily list their excess food at the end of the day for others to collect.",
      buttonLabel: 'Next',
      imagePlaceholderAsset: 'assets/images/onboarding_2.png',
    ),
    _OnboardingData(
      title: "Families and food\nbanks receive",
      subtitle:
          "Connect with local donors and receive fresh, high-quality food for your family or organization.",
      buttonLabel: 'Get Started',
      imagePlaceholderAsset: 'assets/images/onboarding_3.png',
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
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
      backgroundColor: const Color(0xFF1A5C38),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _OnboardingPage(
              data: _pages[i],
              currentPage: _currentPage,
              totalPages: _pages.length,
              onNext: _onNext,
            ),
          ),

          // Skip button — top right, absolute
          Positioned(
            top: size.height * 0.056,
            right: size.width * 0.061,
            child: GestureDetector(
              onTap: _navigateForward,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 24 / 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data model ──────────────────────────────────────────────────────────────

class _OnboardingData {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String imagePlaceholderAsset;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.imagePlaceholderAsset,
  });
}

// ─── Single page ─────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  const _OnboardingPage({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Proportional split: ~55% green / ~45% white card
    // Reduced from Figma's 0.601 so the white card has enough room on
    // short viewports (web browser) without overflowing.
    final topHeight = screenHeight * 0.550;

    return Column(
      children: [
        _GreenSection(
          height: topHeight,
          screenWidth: screenWidth,
          imageAsset: data.imagePlaceholderAsset,
        ),
        _WhiteCard(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          title: data.title,
          subtitle: data.subtitle,
          buttonLabel: data.buttonLabel,
          currentPage: currentPage,
          totalPages: totalPages,
          onNext: onNext,
        ),
      ],
    );
  }
}

// ─── Top green illustration section ──────────────────────────────────────────

class _GreenSection extends StatelessWidget {
  final double height;
  final double screenWidth;
  final String imageAsset;

  const _GreenSection({
    required this.height,
    required this.screenWidth,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    // Overlay card: 300/393 wide, 240/512 tall relative to top section
    final cardWidth = screenWidth * 0.763;
    final cardHeight = height * 0.469;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Frosted glass card with image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _buildImageContent(cardWidth, cardHeight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(double width, double height) {
    // Try to load the asset; show placeholder if not found yet
    return Image.asset(
      imageAsset,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: Colors.white.withValues(alpha: 0.4), size: 48),
            const SizedBox(height: 8),
            Text(
              'Image coming soon',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom white card ────────────────────────────────────────────────────────

class _WhiteCard extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  const _WhiteCard({
    required this.screenWidth,
    required this.screenHeight,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = screenWidth * 0.0814; // 32/393
    final vPadTop = screenHeight * 0.050; // reduced to avoid overflow on short viewports
    final vPadBottom = screenHeight * 0.044;

    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 40,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, vPadTop, hPad, vPadBottom),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title + subtitle
              Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth * 0.071, // 28/393
                      height: 35 / 28,
                      color: const Color(0xFF1A5C38),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.019),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.041, // 16/393
                      height: 26 / 16,
                      color: const Color(0xFF6B7A6B),
                    ),
                  ),
                ],
              ),

              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (i) {
                  final isActive = i == currentPage;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isActive ? 12 : 10,
                      height: isActive ? 12 : 10,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF1A5C38)
                            : const Color(0xFFD9D9D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),

              // Primary button
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.066, // 56/852
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C38),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.046, // 18/393
                      height: 28 / 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
