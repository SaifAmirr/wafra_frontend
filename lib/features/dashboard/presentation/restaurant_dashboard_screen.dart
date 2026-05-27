import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/admin/presentation/manage_requests_screen.dart';
import 'package:wafra_frontend/features/listings/presentation/post_surplus_food_screen.dart';
import 'package:wafra_frontend/features/dashboard/presentation/profile_screen.dart';
import 'package:wafra_frontend/core/network/api_service.dart';

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

_Listing _listingFromJson(Map<String, dynamic> j) {
  final status = (j['status'] as String?) == 'active'
      ? _ListingStatus.active
      : _ListingStatus.pending;

  String timeDetail = '';
  final rawTime = j['pickup_time'] as String?;
  if (rawTime != null) {
    try {
      final dt = DateTime.parse(rawTime);
      final diff = dt.difference(DateTime.now());
      if (status == _ListingStatus.active) {
        timeDetail = diff.isNegative
            ? 'Pickup time passed'
            : 'Expires in ${diff.inHours}h ${diff.inMinutes % 60}m';
      } else {
        timeDetail = 'Driver arriving soon';
      }
    } catch (_) {}
  }

  String listedAgo = '';
  final rawCreated = j['created_at'] as String?;
  if (rawCreated != null) {
    try {
      final created = DateTime.parse(rawCreated);
      final diff = DateTime.now().difference(created);
      if (diff.inMinutes < 60) {
        listedAgo = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        listedAgo = '${diff.inHours}h ago';
      } else {
        listedAgo = '${diff.inDays}d ago';
      }
    } catch (_) {}
  }

  return _Listing(
    name: j['food_name'] as String? ?? '',
    quantity: j['quantity'] as int? ?? 0,
    status: status,
    timeDetail: timeDetail,
    listedAgo: listedAgo,
    reservationCount: j['reservation_count'] as int? ?? 0,
  );
}

// ─── Root screen ──────────────────────────────────────────────────────────────

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState
    extends State<RestaurantDashboardScreen> {
  // Nav indices: 0=Home, 1=Post(action), 2=Requests, 3=Profile
  // Stack indices: 0=Home, 1=Requests, 2=Profile
  int _navIndex = 0;

  int get _stackIndex => switch (_navIndex) {
        2 => 1,
        3 => 2,
        _ => 0,
      };

  void _onNavTap(int i) {
    if (i == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PostSurplusFoodScreen()),
      );
      return;
    }
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _stackIndex,
        children: const [
          _HomeTab(),
          ManageRequestsScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: _navIndex == 0 ? _PostSurplusFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Requests',
          ),
          NavigationDestination(
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

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<_Listing> _listings = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.instance.getMyListings();
      if (!mounted) return;
      setState(() => _listings = raw
          .map((j) => _listingFromJson(j as Map<String, dynamic>))
          .toList());
    } catch (_) {
      // keep empty on error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 24),
          const _SustainabilitySection(),
          const SizedBox(height: 24),
          _ActiveListingsSection(listings: _listings, loading: _loading),
          const SizedBox(height: 24),
          const _RecentActivitySection(),
        ],
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
  final List<_Listing> listings;
  final bool loading;

  const _ActiveListingsSection({required this.listings, this.loading = false});

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
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Color(0xFF1A5C38)),
            ),
          )
        else if (listings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No active listings yet.',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
              ),
            ),
          )
        else
          CustomPaint(
            painter: _DashedBorderPainter(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (int i = 0; i < listings.length; i++) ...[
                    _ListingCard(listing: listings[i]),
                    if (i < listings.length - 1)
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
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

// ─── Sustainability impact section ────────────────────────────────────────────

class _SustainabilitySection extends StatelessWidget {
  const _SustainabilitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sustainability Impact',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ImpactCard(
              icon: Icons.eco_rounded,
              value: '428',
              label: 'MEALS\nSAVED',
            ),
            const SizedBox(width: 10),
            _ImpactCard(
              icon: Icons.cloud_outlined,
              value: '1.2t',
              label: 'CO2\nREDUCED',
            ),
            const SizedBox(width: 10),
            _ImpactCard(
              icon: Icons.favorite_rounded,
              value: '350',
              label: 'PEOPLE\nFED',
            ),
          ],
        ),
      ],
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ImpactCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A5C38),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent activity section ──────────────────────────────────────────────────

class _ActivityItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

const _activities = [
  _ActivityItem(
    icon: Icons.volunteer_activism_rounded,
    iconBg: Color(0xFFEFF6FF),
    iconColor: Color(0xFF3B82F6),
    title: 'Donation Picked Up',
    subtitle: '12kg of surplus grains by FoodBank Local',
    time: 'Yesterday',
  ),
  _ActivityItem(
    icon: Icons.star_rounded,
    iconBg: Color(0xFFECFDF5),
    iconColor: Color(0xFF1A5C38),
    title: 'New Achievement!',
    subtitle: '"Zero Waste Hero" badge earned',
    time: '2d ago',
  ),
  _ActivityItem(
    icon: Icons.group_rounded,
    iconBg: Color(0xFFF5F3FF),
    iconColor: Color(0xFF7C3AED),
    title: '15 New Followers',
    subtitle: 'Community members tracking your listings',
    time: '1d ago',
  ),
];

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _activities.length; i++) ...[
                _ActivityRow(item: _activities[i]),
                if (i < _activities.length - 1)
                  const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 18, color: item.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.time,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
