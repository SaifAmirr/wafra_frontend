import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/listings/domain/entities/food_listing.dart';

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
                        color:
                            listing.imageIconColor.withValues(alpha: 0.3),
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
                            onTap: () => setState(
                                () => _bookmarked = !_bookmarked),
                          ),
                        ],
                      ),
                    ),

                    // White rounded cap
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24)),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Content area ────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: listing.imageBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          listing.category,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: listing.imageIconColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        listing.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          height: 1.2,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Restaurant + distance
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined,
                              size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            listing.restaurant,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            '${listing.distance} miles away',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isFree
                                ? 'Free'
                                : '\$${listing.discountedPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              color: const Color(0xFF1A5C38),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isFree)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '\$${listing.originalPrice.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF94A3B8),
                                  decoration:
                                      TextDecoration.lineThrough,
                                  decorationColor:
                                      const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${listing.itemsLeft} left',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A5C38),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 16),

                      // Description
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
                          fontSize: 14,
                          height: 1.6,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dietary tags
                      if (listing.tags.isNotEmpty) ...[
                        Text(
                          'Dietary Info',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: listing.tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fixed bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5C38),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Reserve Now',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
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

// ─── Circle button ────────────────────────────────────────────────────────────

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
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
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
