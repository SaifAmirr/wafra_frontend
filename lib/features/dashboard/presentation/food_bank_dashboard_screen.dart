import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/listings/domain/entities/food_listing.dart';
import 'package:wafra_frontend/features/listings/presentation/food_listing_detail_screen.dart';
import 'package:wafra_frontend/features/listings/presentation/pickup_ticket_screen.dart';
import 'package:wafra_frontend/features/dashboard/presentation/profile_screen.dart';
import 'package:wafra_frontend/core/network/api_service.dart';

const _kPurple = Color(0xFF7C3AED);
const _kPurpleLight = Color(0xFFF3E8FF);

// ─── Shell ────────────────────────────────────────────────────────────────────

class FoodBankDashboardScreen extends StatefulWidget {
  const FoodBankDashboardScreen({super.key});

  @override
  State<FoodBankDashboardScreen> createState() =>
      _FoodBankDashboardScreenState();
}

class _FoodBankDashboardScreenState extends State<FoodBankDashboardScreen> {
  int _tab = 0;

  void _goToBrowse() => setState(() => _tab = 1);
  void _goToOrders() => setState(() => _tab = 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(onGoBrowse: _goToBrowse, onGoOrders: _goToOrders),
          const _BrowseTab(),
          _OrdersTab(onGoBrowse: _goToBrowse),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
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
        indicatorColor: _kPurple.withValues(alpha: 0.10),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? _kPurple : const Color(0xFF94A3B8),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? _kPurple : const Color(0xFF94A3B8),
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
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.receipt_long_outlined),
                Positioned(
                  top: -2,
                  right: -3,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            selectedIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.receipt_long),
                Positioned(
                  top: -2,
                  right: -3,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Orders',
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

// ─── Tab 0: Home dashboard ────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  final VoidCallback? onGoBrowse;
  final VoidCallback? onGoOrders;

  const _HomeTab({this.onGoBrowse, this.onGoOrders});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  Map<String, dynamic>? _me;
  List<FoodListing> _available = [];
  List<Map<String, dynamic>> _allReservations = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.getMe(),
        ApiService.instance.getListings(),
        ApiService.instance.getMyReservations(),
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
      });
    } catch (_) {
      // show empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _activeOrders => _allReservations
      .where((r) => r['status'] == 'pending' || r['status'] == 'accepted')
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

  Future<void> _openDetail(FoodListing listing) async {
    final reserved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FoodListingDetailScreen(listing: listing),
      ),
    );
    if (!mounted) return;
    if (reserved == true) {
      widget.onGoOrders?.call();
      _load();
    } else {
      _load();
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _orgName() {
    final user = (_me?['user'] as Map<String, dynamic>?);
    return user?['username'] as String? ?? 'Food Bank';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: _kPurple,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              decoration: const BoxDecoration(
                color: _kPurple,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24)),
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
                  // Impact strip
                  Row(
                    children: [
                      _ImpactCard(
                          label: 'Meals Collected',
                          value: '$_mealsCollected',
                          icon: Icons.kitchen_outlined),
                      const SizedBox(width: 10),
                      _ImpactCard(
                          label: 'Active Orders',
                          value: '${_activeOrders.length}',
                          icon: Icons.pending_actions_outlined),
                      const SizedBox(width: 10),
                      _ImpactCard(
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
            // Available Now section
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
                  (_, i) => _CompactListingCard(
                    listing: _available[i],
                    onTap: () => _openDetail(_available[i]),
                  ),
                  childCount: _available.length,
                ),
              ),

            // Active Orders section
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
                  (_, i) => _OrderCard(data: _activeOrders[i]),
                  childCount: _activeOrders.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ImpactCard(
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

class _CompactListingCard extends StatelessWidget {
  final FoodListing listing;
  final VoidCallback onTap;
  const _CompactListingCard(
      {required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: listing.imageBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(listing.imageIcon, color: listing.imageIconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    listing.restaurant,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${listing.itemsLeft} left',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _kPurple,
                  ),
                ),
                Text(
                  listing.expiresIn,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OrderCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? '';
    final foodName = data['food_name'] as String? ?? '';
    final restaurantName = data['restaurant_name'] as String? ?? '';
    final qty = data['requested_quantity'];

    final isConfirmed = status == 'accepted';
    final statusColor =
        isConfirmed ? const Color(0xFF1A5C38) : const Color(0xFFF59E0B);
    final statusLabel = isConfirmed ? 'Confirmed' : 'Pending';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$restaurantName · Qty: $qty',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 1: Browse & reserve ──────────────────────────────────────────────────

class _BrowseTab extends StatefulWidget {
  const _BrowseTab();

  @override
  State<_BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<_BrowseTab> {
  List<FoodListing> _listings = [];
  Map<String, dynamic>? _me;
  final Map<int, int> _quantities = {};
  bool _loading = false;
  bool _reserving = false;
  String _search = '';
  String _category = 'All Items';

  static const _cats = [
    'All Items',
    'Cooked Meals',
    'Bakery',
    'Packaged',
    'Beverages',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.instance.getListings(
          category: _category == 'All Items' ? null : _category,
          search: _search.isEmpty ? null : _search,
        ),
        ApiService.instance.getMe(),
      ]);
      if (!mounted) return;
      setState(() {
        _listings = (results[0] as List)
            .cast<Map<String, dynamic>>()
            .map(FoodListing.fromJson)
            .toList();
        _me = results[1] as Map<String, dynamic>;
        _quantities.removeWhere(
            (id, _) => !_listings.any((l) => l.listingId == id));
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _selectedCount => _quantities.values.where((q) => q > 0).length;

  String _orgName() {
    final user = _me?['user'] as Map<String, dynamic>?;
    return user?['username'] as String? ?? 'Food Bank';
  }

  Future<void> _bulkReserve() async {
    final selected =
        _quantities.entries.where((e) => e.value > 0).toList();
    if (selected.isEmpty) return;
    setState(() => _reserving = true);
    try {
      await Future.wait(
        selected.map(
            (e) => ApiService.instance.createReservation(e.key, e.value)),
      );
      if (!mounted) return;
      setState(() => _quantities.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selected.length} reservation(s) submitted!'),
          backgroundColor: _kPurple,
        ),
      );
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _kPurpleLight,
                  child: const Icon(Icons.account_balance_outlined,
                      color: _kPurple, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food Bank Partner',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8)),
                      ),
                      Text(
                        _orgName(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      size: 20, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) {
                _search = v;
                _load();
              },
              decoration: InputDecoration(
                hintText: 'Search surplus food...',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF94A3B8), size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _kPurple, width: 1.5),
                ),
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _cats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _cats[i];
                final active = cat == _category;
                return GestureDetector(
                  onTap: () {
                    setState(() => _category = cat);
                    _load();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? _kPurple : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active
                              ? _kPurple
                              : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: active
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // "Available Listings" + selected count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text(
                  'Available Listings',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (_selectedCount > 0)
                  Text(
                    '$_selectedCount item${_selectedCount == 1 ? '' : 's'} selected',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _kPurple,
                    ),
                  ),
              ],
            ),
          ),

          // Cards list + floating bulk reserve button
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _kPurple))
                : _listings.isEmpty
                    ? Center(
                        child: Text(
                          'No listings available right now.',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF8E8E93)),
                        ),
                      )
                    : Stack(
                        children: [
                          RefreshIndicator(
                            onRefresh: _load,
                            color: _kPurple,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                  16, 0, 16, _selectedCount > 0 ? 90 : 16),
                              itemCount: _listings.length,
                              itemBuilder: (_, i) {
                                final l = _listings[i];
                                final id = l.listingId ?? i;
                                return _BrowseCard(
                                  listing: l,
                                  qty: _quantities[id] ?? 0,
                                  onQtyChanged: (q) =>
                                      setState(() => _quantities[id] = q),
                                );
                              },
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
                                  onPressed:
                                      _reserving ? null : _bulkReserve,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kPurple,
                                    foregroundColor: Colors.white,
                                    elevation: 6,
                                    shadowColor:
                                        _kPurple.withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(28)),
                                  ),
                                  icon: _reserving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(
                                          Icons.volunteer_activism,
                                          size: 20),
                                  label: Text(
                                    _reserving
                                        ? 'Reserving...'
                                        : 'Reserve Selected ($_selectedCount item${_selectedCount == 1 ? '' : 's'})',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                  ),
                                ),
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

class _BrowseCard extends StatelessWidget {
  final FoodListing listing;
  final int qty;
  final ValueChanged<int> onQtyChanged;

  const _BrowseCard({
    required this.listing,
    required this.qty,
    required this.onQtyChanged,
  });

  static String _unit(String category) {
    switch (category.toLowerCase()) {
      case 'bakery':
        return 'packs';
      case 'cooked meals':
      case 'meals':
        return 'boxes';
      case 'dairy':
        return 'units';
      case 'beverages':
        return 'bottles';
      default:
        return 'items';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final selected = qty > 0;
    final isHighDemand = l.itemsLeft <= 3 && l.itemsLeft > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? _kPurple : const Color(0xFFE2E8F0),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food icon thumbnail
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: l.imageBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(l.imageIcon, color: l.imageIconColor, size: 32),
                ),
                const SizedBox(width: 12),
                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              l.title,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isHighDemand
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isHighDemand ? 'HIGH DEMAND' : 'ACTIVE',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.5,
                                color: isHighDemand
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.restaurant,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_outlined,
                              size: 12, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            'Expires in ${l.expiresIn}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUANTITY',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.8,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l.itemsLeft} ${_unit(l.category)} available',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _QtyBtn(
                      icon: Icons.remove,
                      onTap: qty > 0 ? () => onQtyChanged(qty - 1) : null,
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    _QtyBtn(
                      icon: Icons.add,
                      onTap: qty < l.itemsLeft
                          ? () => onQtyChanged(qty + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null
              ? _kPurpleLight
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? _kPurple : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

// ─── Tab 2: Orders ────────────────────────────────────────────────────────────

class _OrdersTab extends StatefulWidget {
  final VoidCallback? onGoBrowse;
  const _OrdersTab({this.onGoBrowse});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;
  List<Map<String, dynamic>> _reservations = [];
  bool _loading = false;

  static const _statusMap = {
    0: ['pending'],
    1: ['accepted'],
    2: ['completed'],
    3: ['declined', 'cancelled'],
  };

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.instance.getMyReservations();
      if (!mounted) return;
      setState(() =>
          _reservations = raw.cast<Map<String, dynamic>>());
    } catch (_) {
      // show empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(int id) async {
    try {
      await ApiService.instance.cancelReservation(id);
      _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  List<Map<String, dynamic>> _forTab(int i) {
    final statuses = _statusMap[i] ?? [];
    return _reservations
        .where((r) => statuses.contains(r['status'] as String?))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Orders',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        bottom: TabBar(
          controller: _tc,
          labelColor: _kPurple,
          unselectedLabelColor: const Color(0xFF8E8E93),
          indicatorColor: _kPurple,
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _kPurple))
          : RefreshIndicator(
              onRefresh: _load,
              color: _kPurple,
              child: TabBarView(
                controller: _tc,
                children: List.generate(4, (i) {
                  final items = _forTab(i);
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No orders here yet.',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF8E8E93)),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, idx) {
                      final s = items[idx]['status'] as String? ?? '';
                      return _FoodBankOrderCard(
                        data: items[idx],
                        onCancel: s == 'pending'
                            ? () => _cancel(
                                items[idx]['reservation_id'] as int)
                            : null,
                        onShowCode: s == 'accepted'
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PickupTicketScreen(
                                      reservationId:
                                          items[idx]['reservation_id']
                                              as int,
                                    ),
                                  ),
                                )
                            : null,
                        onFindAlternatives:
                            (s == 'declined' || s == 'cancelled')
                                ? widget.onGoBrowse
                                : null,
                      );
                    },
                  );
                }),
              ),
            ),
    );
  }
}

class _FoodBankOrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onCancel;
  final VoidCallback? onShowCode;
  final VoidCallback? onFindAlternatives;
  const _FoodBankOrderCard({
    required this.data,
    this.onCancel,
    this.onShowCode,
    this.onFindAlternatives,
  });

  String _fmtDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? '';
    final foodName = data['food_name'] as String? ?? '';
    final restaurantName = data['restaurant_name'] as String? ?? '';
    final qty = data['requested_quantity'];
    final pickupTime = _fmtDate(data['pickup_time'] as String?);

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'accepted':
        statusColor = const Color(0xFF1A5C38);
        statusLabel = 'Confirmed';
        break;
      case 'completed':
        statusColor = const Color(0xFF0EA5E9);
        statusLabel = 'Completed';
        break;
      case 'declined':
      case 'cancelled':
        statusColor = Colors.red;
        statusLabel = status == 'declined' ? 'Declined' : 'Cancelled';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pending';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        foodName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        restaurantName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 14, color: Color(0xFF8E8E93)),
                const SizedBox(width: 4),
                Text(
                  'Qty: $qty',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF64748B)),
                ),
                if (pickupTime.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 4),
                  Text(
                    pickupTime,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                ],
              ],
            ),
            if (onShowCode != null ||
                onCancel != null ||
                onFindAlternatives != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  if (onCancel != null && onShowCode != null)
                    const SizedBox(width: 12),
                  if (onShowCode != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onShowCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Show Code',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  if (onFindAlternatives != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onFindAlternatives,
                        style: TextButton.styleFrom(
                          foregroundColor: _kPurple,
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.search, size: 16),
                        label: Text(
                          'Find alternatives',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Tab 3: Profile placeholder ───────────────────────────────────────────────

