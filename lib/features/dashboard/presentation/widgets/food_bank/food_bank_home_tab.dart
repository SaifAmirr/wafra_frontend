import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/constants/app_colors.dart';
import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'package:wafra_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:wafra_frontend/features/listings/domain/entities/food_listing.dart';
import 'package:wafra_frontend/features/listings/presentation/food_listing_detail_screen.dart';
import 'package:wafra_frontend/features/notifications/presentation/widgets/notification_bell.dart';
import 'compact_listing_card.dart';
import 'active_order_card.dart';

const _kPurple = Color(0xFF7C3AED);

class FoodBankHomeTab extends StatefulWidget {
  final VoidCallback? onGoBrowse;
  final VoidCallback? onGoOrders;

  const FoodBankHomeTab({super.key, this.onGoBrowse, this.onGoOrders});

  @override
  State<FoodBankHomeTab> createState() => _FoodBankHomeTabState();
}

class _FoodBankHomeTabState extends State<FoodBankHomeTab> {
  Map<String, dynamic>? _me;
  List<FoodListing> _available = [];
  List<Map<String, dynamic>> _allReservations = [];
  final Map<int, int> _quantities = {};
  bool _loading = false;
  bool _reserving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        DashboardRepository.instance.getMe(),
        DashboardRepository.instance.getListings(),
        DashboardRepository.instance.getMyReservations(),
      ]);
      if (!mounted) return;
      setState(() {
        _me = results[0] as Map<String, dynamic>;
        final raw = results[1] as List;
        _available = raw
            .cast<Map<String, dynamic>>()
            .map(FoodListing.fromJson)
            .take(5)
            .toList();
        _allReservations = (results[2] as List).cast<Map<String, dynamic>>();
        _quantities.removeWhere(
            (id, _) => !_available.any((l) => l.listingId == id));
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _activeOrders => _allReservations
      .where((r) =>
          r['status'] == 'pending' || r['status'] == 'accepted')
      .toList();

  int get _mealsCollected => _allReservations
      .where((r) => r['status'] == 'completed')
      .fold<int>(
          0, (sum, r) => sum + ((r['requested_quantity'] as int?) ?? 0));

  int get _restaurantCount => _allReservations
      .map((r) => (r['restaurant_name'] as String? ?? '').trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .length;

  int get _selectedCount => _quantities.values.where((q) => q > 0).length;

  Future<void> _reserve() async {
    final selected = _quantities.entries.where((e) => e.value > 0).toList();
    if (selected.isEmpty) return;
    setState(() => _reserving = true);
    try {
      await Future.wait(
        selected.map((e) =>
            DashboardRepository.instance.createReservation(e.key, e.value)),
      );
      if (!mounted) return;
      setState(() => _quantities.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${selected.length} reservation${selected.length == 1 ? '' : 's'} submitted!'),
          backgroundColor: _kPurple,
        ),
      );
      widget.onGoOrders?.call();
      _load();
    } on AppFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  Future<void> _openDetail(FoodListing listing) async {
    final reserved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => FoodListingDetailScreen(listing: listing, roleColor: AppColors.foodBankPurple)),
    );
    if (!mounted) return;
    if (reserved == true) {
      widget.onGoOrders?.call();
    }
    _load();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _orgName() {
    final user = _me?['user'] as Map<String, dynamic>?;
    return user?['username'] as String? ?? 'Food Bank';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
      RefreshIndicator(
      onRefresh: _load,
      color: _kPurple,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 16, 20, 20),
              decoration: const BoxDecoration(
                color: _kPurple,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()},',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _orgName(),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const NotificationBell(),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        child: const Icon(Icons.account_balance_outlined,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _HomeImpactCard(
                          label: 'Meals Collected',
                          value: '$_mealsCollected',
                          icon: Icons.kitchen_outlined),
                      const SizedBox(width: 10),
                      _HomeImpactCard(
                          label: 'Active Orders',
                          value: '${_activeOrders.length}',
                          icon: Icons.pending_actions_outlined),
                      const SizedBox(width: 10),
                      _HomeImpactCard(
                          label: 'Restaurants',
                          value: '$_restaurantCount',
                          icon: Icons.storefront_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                    child: CircularProgressIndicator(color: _kPurple)),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Available Now',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            if (_available.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Text(
                    'No listings available right now.',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF8E8E93)),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final listing = _available[i];
                    final id = listing.listingId ?? i;
                    return CompactListingCard(
                      listing: listing,
                      qty: _quantities[id] ?? 0,
                      onQtyChanged: (q) =>
                          setState(() => _quantities[id] = q),
                      onTap: () => _openDetail(listing),
                    );
                  },
                  childCount: _available.length,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Active Orders',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            if (_activeOrders.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Text(
                    'No active orders yet.',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF8E8E93)),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ActiveOrderCard(data: _activeOrders[i]),
                  childCount: _activeOrders.length,
                ),
              ),
            SliverToBoxAdapter(
                child: SizedBox(height: _selectedCount > 0 ? 90 : 24)),
          ],
        ],
      ),
      ),
      if (_selectedCount > 0)
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _reserving ? null : _reserve,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: _kPurple.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              icon: _reserving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.volunteer_activism, size: 20),
              label: Text(
                _reserving
                    ? 'Reserving...'
                    : 'Reserve Selected ($_selectedCount item${_selectedCount == 1 ? '' : 's'})',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeImpactCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HomeImpactCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
