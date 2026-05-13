import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/models/food_listing.dart';

class FoodListingDetailScreen extends StatefulWidget {
  final FoodListing listing;

  const FoodListingDetailScreen({super.key, required this.listing});

  @override
  State<FoodListingDetailScreen> createState() =>
      _FoodListingDetailScreenState();
}

class _FoodListingDetailScreenState extends State<FoodListingDetailScreen> {
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final topPadding = MediaQuery.of(context).padding.top;
    final isFree = listing.discountedPrice == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ──────────────────────────────────────────────
                Stack(
                  children: [
                    // Placeholder image
                    Container(
                      height: 280,
                      width: double.infinity,
                      color: listing.imageBg,
                      child: Icon(
                        listing.imageIcon,
                        size: 110,
                        color: listing.imageIconColor.withValues(alpha: 0.3),
                      ),
                    ),

                    // Top action buttons
                    Positioned(
                      top: topPadding + 12,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          _CircleButton(
                            icon: Icons.arrow_back_ios_new,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          _CircleButton(
                            icon: Icons.share_outlined,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _CircleButton(
                            icon: _bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            iconColor: _bookmarked
                                ? const Color(0xFF1A5C38)
                                : null,
                            onTap: () =>
                                setState(() => _bookmarked = !_bookmarked),
                          ),
                        ],
                      ),
                    ),

                    // White rounded cap — creates the overlap illusion
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                      ),
                    ),

                    // Expires badge
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Expires in ${listing.expiresIn}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── White content ────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + items left
                      Row(
                        children: [
                          Text(
                            listing.category.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 11 * 0.05,
                              color: const Color(0xFF1A5C38),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${listing.itemsLeft} items left',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A5C38),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        listing.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          height: 1.2,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dietary tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: listing.tags
                            .map((tag) => _TagChip(label: tag))
                            .toList(),
                      ),
                      const SizedBox(height: 20),

                      // About section
                      Text(
                        'About this listing',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.description,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.6,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Restaurant row
                      _RestaurantRow(listing: listing),
                      const SizedBox(height: 4),
                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 16),

                      // Location section
                      Row(
                        children: [
                          Text(
                            'Location',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Get Directions',
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

                      // Map placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          color: const Color(0xFFECFDF5),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Grid lines to suggest a map
                              CustomPaint(
                                size: const Size(double.infinity, 140),
                                painter: _MapGridPainter(),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A5C38),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed bottom bar ─────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ORIGINAL \$${listing.originalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        isFree
                            ? 'Free'
                            : '\$${listing.discountedPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: const Color(0xFF1A5C38),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A5C38),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Reserve Now',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating circle button (back / share / bookmark) ─────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? const Color(0xFF0F172A),
        ),
      ),
    );
  }
}

// ─── Dietary / allergen tag chip ──────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}

// ─── Restaurant info row ──────────────────────────────────────────────────────

class _RestaurantRow extends StatelessWidget {
  final FoodListing listing;

  const _RestaurantRow({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFE2E8F0),
          child: const Icon(Icons.storefront, color: Color(0xFF94A3B8), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    listing.restaurant,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified,
                    size: 14,
                    color: Color(0xFF1A5C38),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text(
                    '${listing.restaurantRating}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    ' · ${listing.distance} miles away',
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
        const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 22),
      ],
    );
  }
}

// ─── Map grid painter (decorative placeholder) ────────────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A5C38).withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
