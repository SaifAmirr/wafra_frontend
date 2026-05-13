import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/screens/restaurant_dashboard_screen.dart';

class PostSuccessScreen extends StatelessWidget {
  const PostSuccessScreen({super.key});

  void _goToDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RestaurantDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Color(0xFF1A5C38), size: 26),
          onPressed: () => _goToDashboard(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF0F172A),
              size: 26,
            ),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _Illustration(),
              const SizedBox(height: 36),
              Text(
                'Post Created!',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Your surplus food is now live. Local\nnon-profits and community\nmembers have been notified.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.65,
                  color: const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _goToDashboard(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C38),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Post',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _goToDashboard(context),
                child: Text(
                  'Go to Dashboard',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Illustration ─────────────────────────────────────────────────────────────

class _Illustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 230,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Light green circle background
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
          ),

          // Warm yellow rounded square (chef illustration placeholder)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.restaurant,
                  size: 72,
                  color: Color(0xFFF59E0B),
                ),
                Positioned(
                  top: 20,
                  right: 22,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A5C38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Star decoration — top right
          Positioned(
            top: 0,
            right: 4,
            child: const Icon(
              Icons.star_rounded,
              size: 38,
              color: Color(0xFF1A5C38),
            ),
          ),

          // Leaf decoration — bottom left
          Positioned(
            bottom: 8,
            left: 10,
            child: const Icon(
              Icons.eco_rounded,
              size: 28,
              color: Color(0xFF1A5C38),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom nav (HOME active) ─────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1A5C38).withValues(alpha: 0.10),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? const Color(0xFF1A5C38) : const Color(0xFF94A3B8),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? const Color(0xFF1A5C38) : const Color(0xFF94A3B8),
            size: 24,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x1A000000),
        elevation: 8,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2', style: GoogleFonts.inter(fontSize: 10)),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              label: Text('2', style: GoogleFonts.inter(fontSize: 10)),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Messages',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
