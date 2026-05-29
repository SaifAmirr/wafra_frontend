import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/listings/data/listings_api_repository.dart';
import 'package:wafra_frontend/features/listings/domain/entities/food_listing.dart';
import 'package:wafra_frontend/features/listings/presentation/food_listing_detail_screen.dart';
import 'package:wafra_frontend/features/notifications/presentation/widgets/notification_bell.dart';
import 'food_card.dart';

const _kBlue = Color(0xFF2563EB);
const _categories = ['All', 'Cooked Meals', 'Bakery', 'Produce', 'Beverages'];

class ExploreTab extends StatefulWidget {
  final VoidCallback? onReservationMade;

  const ExploreTab({super.key, this.onReservationMade});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  int _selectedCategory = 0;
  List<FoodListing> _listings = [];
  bool _loadingListings = false;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadListings();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _loadListings(silent: true));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _pollTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListings({bool silent = false}) async {
    if (!silent) setState(() => _loadingListings = true);
    try {
      final category =
          _selectedCategory == 0 ? null : _categories[_selectedCategory];
      final search = _searchController.text.trim();
      final raw = await ListingsApiRepository.instance.getListings(
        category: category,
        search: search.isEmpty ? null : search,
      );
      if (!mounted) return;
      setState(() => _listings = raw
          .map((j) => FoodListing.fromJson(j as Map<String, dynamic>))
          .toList());
    } catch (_) {
    } finally {
      if (mounted && !silent) setState(() => _loadingListings = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce =
        Timer(const Duration(milliseconds: 300), _loadListings);
  }

  Future<void> _openDetail(FoodListing listing) async {
    final reserved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FoodListingDetailScreen(listing: listing),
      ),
    );
    if (!mounted) return;
    if (reserved == true) {
      widget.onReservationMade?.call();
    } else {
      _loadListings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: _kBlue,
        onRefresh: _loadListings,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Explore',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        const NotificationBell(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(Icons.search,
                                color: Color(0xFF94A3B8), size: 20),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _loadListings(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search for food near you...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFFCBD5E1),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _loadListings();
                                },
                                child: const Icon(Icons.close,
                                    color: Color(0xFF94A3B8), size: 18),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_categories.length, (i) {
                          final active = i == _selectedCategory;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: i < _categories.length - 1 ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedCategory = i);
                                _loadListings();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: active ? _kBlue : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: active
                                        ? _kBlue
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  _categories[i],
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: active
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_loadingListings)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1A5C38))),
              )
            else if (_listings.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No listings found.',
                    style: GoogleFonts.inter(
                        fontSize: 15, color: const Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _openDetail(_listings[i]),
                        child: FoodCard(
                          listing: _listings[i],
                          onReserve: () => _openDetail(_listings[i]),
                        ),
                      ),
                    ),
                    childCount: _listings.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
