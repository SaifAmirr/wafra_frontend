import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/listings/domain/entities/food_listing.dart';

const _kPurple = Color(0xFF7C3AED);
const _kPurpleLight = Color(0xFFF3E8FF);

class BrowseCard extends StatelessWidget {
  final FoodListing listing;
  final int qty;
  final ValueChanged<int> onQtyChanged;

  const BrowseCard({
    super.key,
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
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: l.imageBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(l.imageIcon,
                      color: l.imageIconColor, size: 32),
                ),
                const SizedBox(width: 12),
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
          color: onTap != null ? _kPurpleLight : const Color(0xFFF1F5F9),
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
