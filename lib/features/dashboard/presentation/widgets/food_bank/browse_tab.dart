import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'package:wafra_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:wafra_frontend/features/listings/domain/entities/food_listing.dart';
import 'browse_card.dart';

const _kPurple = Color(0xFF7C3AED);
const _kPurpleLight = Color(0xFFF3E8FF);

class BrowseTab extends StatefulWidget {
  final VoidCallback? onReservationMade;

  const BrowseTab({super.key, this.onReservationMade});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
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
        DashboardRepository.instance.getListings(
          category: _category == 'All Items' ? null : _category,
          search: _search.isEmpty ? null : _search,
        ),
        DashboardRepository.instance.getMe(),
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
          content: Text('${selected.length} reservation(s) submitted!'),
          backgroundColor: _kPurple,
        ),
      );
      widget.onReservationMade?.call();
      _load();
    } on AppFailure catch (e) {
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
                            fontSize: 12, color: const Color(0xFF94A3B8)),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  borderSide: const BorderSide(color: _kPurple, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _cats.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
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
                          color: active ? _kPurple : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: active ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
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
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _kPurple))
                : _listings.isEmpty
                    ? Center(
                        child: Text(
                          'No listings available right now.',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: const Color(0xFF8E8E93)),
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
                                return BrowseCard(
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
                                  onPressed: _reserving ? null : _bulkReserve,
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
                                      : const Icon(Icons.volunteer_activism,
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
