import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/listings/presentation/post_surplus_food_screen.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

enum _ListingStatus { active, pending }

class _Listing {
  final String name;
  final int quantity;
  final _ListingStatus status;
  final String timeDetail;
  final String listedAgo;
  final int reservationCount;

  const _Listing({
    required this.name,
    required this.quantity,
    required this.status,
    required this.timeDetail,
    required this.listedAgo,
    this.reservationCount = 0,
  });
}

const _dummyListings = [
  _Listing(
    name: 'Garden Salads',
    quantity: 8,
    status: _ListingStatus.active,
    timeDetail: 'Expires in 2 hours',
    listedAgo: '15m ago',
    reservationCount: 3,
  ),
  _Listing(
    name: 'Mixed Bakery Box',
    quantity: 5,
    status: _ListingStatus.pending,
    timeDetail: 'Driver arriving soon',
    listedAgo: '2h ago',
    reservationCount: 1,
  ),
];

// ─── Root screen ──────────────────────────────────────────────────────────────

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState
    extends State<RestaurantDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _tab,
        children: [
          const _HomeTab(),
          _empty('Orders'),
          _empty('Messages'),
          _empty('Profile'),
        ],
      ),
      floatingActionButton: _PostSurplusFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _BottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }

  Widget _empty(String label) => Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF94A3B8),
          ),
        ),
      );
}

// ─── Post Surplus Food FAB ────────────────────────────────────────────────────

class _PostSurplusFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PostSurplusFoodScreen()),
      ),
      backgroundColor: const Color(0xFF1A5C38),
      elevation: 4,
      icon: const Icon(Icons.add, color: Colors.white, size: 20),
      label: Text(
        'Post Surplus Food',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}

// ─── Bottom nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

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
            color:
                active ? const Color(0xFF1A5C38) : const Color(0xFF94A3B8),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color:
                active ? const Color(0xFF1A5C38) : const Color(0xFF94A3B8),
            size: 24,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
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

// ─── Home tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Header(),
            SizedBox(height: 28),
            _ActiveListingsSection(),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFDCFCE7),
          child: const Icon(
            Icons.storefront,
            color: Color(0xFF1A5C38),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Text(
              'Green Table Bistro',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF0F172A),
            size: 20,
          ),
        ),
      ],
    );
  }
}

// ─── Active listings section ──────────────────────────────────────────────────

class _ActiveListingsSection extends StatelessWidget {
  const _ActiveListingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Listings',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF1A5C38),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Dashed border container
        CustomPaint(
          painter: _DashedBorderPainter(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (int i = 0; i < _dummyListings.length; i++) ...[
                  _ListingCard(listing: _dummyListings[i]),
                  if (i < _dummyListings.length - 1)
                    const Divider(
                      height: 24,
                      color: Color(0xFFF1F5F9),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Listing card ─────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final _Listing listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isActive = listing.status == _ListingStatus.active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${listing.name} (${listing.quantity}x)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    isActive
                        ? Icons.access_time_rounded
                        : Icons.local_shipping_outlined,
                    size: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    listing.timeDetail,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Listed ${listing.listedAgo}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),

        // Status + indicator column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusBadge(status: listing.status),
            const SizedBox(height: 10),
            if (isActive && listing.reservationCount > 0)
              _ReservationAvatars(count: listing.reservationCount)
            else if (!isActive)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1A5C38), width: 1.5),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Color(0xFF1A5C38),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _ListingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == _ListingStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'PENDING',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.5,
          color: isActive
              ? const Color(0xFF1A5C38)
              : const Color(0xFFF59E0B),
        ),
      ),
    );
  }
}

// ─── Overlapping reservation avatars ─────────────────────────────────────────

class _ReservationAvatars extends StatelessWidget {
  final int count;

  const _ReservationAvatars({required this.count});

  @override
  Widget build(BuildContext context) {
    const avatarSize = 22.0;
    const overlap = 8.0;
    final show = count.clamp(1, 3);
    final totalWidth = avatarSize + (show - 1) * (avatarSize - overlap);

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < show; i++)
            Positioned(
              left: i * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.person,
                  size: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Dashed border painter ────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dash = 6.0;
    const gap = 4.0;
    const radius = 14.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashed.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
