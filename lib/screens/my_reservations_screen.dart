import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/services/api_service.dart';

class MyReservationsScreen extends StatefulWidget {
  final VoidCallback? onGoExplore;
  const MyReservationsScreen({super.key, this.onGoExplore});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];

  // API status values mapped to each tab
  static const _statusMap = {
    'Pending': ['pending'],
    'Confirmed': ['accepted'],
    'Completed': ['completed'],
    'Cancelled': ['declined', 'cancelled'],
  };

  List<Map<String, dynamic>> _reservations = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.instance.getMyReservations();
      if (!mounted) return;
      setState(() => _reservations =
          raw.map((e) => e as Map<String, dynamic>).toList());
    } catch (_) {
      // keep empty on error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _forTab(String tab) {
    final statuses = _statusMap[tab] ?? [];
    return _reservations
        .where((r) => statuses.contains(r['status'] as String?))
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'My Reservations',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ReservationTabBar(controller: _tabController, tabs: _tabs),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: _tabs.map((tab) {
                        final items = _forTab(tab);
                        if (items.isEmpty) {
                          return _EmptyState(
                            tabLabel: tab,
                            onBrowse: widget.onGoExplore ?? () {},
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _ReservationCard(data: items[i]),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Tab bar ─────────────────────────────────────────────────────────────────

class _ReservationTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _ReservationTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: const Color(0xFF2563EB),
      indicatorWeight: 2.5,
      dividerColor: const Color(0xFFE2E8F0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      labelColor: const Color(0xFF2563EB),
      unselectedLabelColor: const Color(0xFF94A3B8),
      tabs: tabs.map((t) => Tab(text: t)).toList(),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String tabLabel;
  final VoidCallback onBrowse;

  const _EmptyState({required this.tabLabel, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _BagIllustration(),
          const SizedBox(height: 28),
          Text(
            'No reservations yet',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You haven't made any food\nreservations. Start browsing surplus\nfood from nearby restaurants.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.65,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Browse Food',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reservation card ─────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ReservationCard({required this.data});

  static const _statusColors = {
    'pending':   Color(0xFFF59E0B),
    'accepted':  Color(0xFF1A5C38),
    'completed': Color(0xFF2563EB),
    'declined':  Color(0xFFEF4444),
    'cancelled': Color(0xFF94A3B8),
  };

  static const _statusLabels = {
    'pending':   'Pending',
    'accepted':  'Confirmed',
    'completed': 'Completed',
    'declined':  'Declined',
    'cancelled': 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'pending';
    final color = _statusColors[status] ?? const Color(0xFF94A3B8);
    final label = _statusLabels[status] ?? status;
    final foodName = data['food_name'] as String?
        ?? data['listing']?['food_name'] as String?
        ?? 'Food item';
    final restaurant = data['restaurant_name'] as String?
        ?? data['listing']?['restaurant_name'] as String?
        ?? 'Restaurant';
    final qty = data['requested_quantity'] as int? ?? 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$restaurant · $qty item${qty != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shopping bag illustration ────────────────────────────────────────────────

class _BagIllustration extends StatelessWidget {
  const _BagIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            size: 50,
            color: Color(0xFF93C5FD),
          ),
        ),
      ),
    );
  }
}
