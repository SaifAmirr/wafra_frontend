import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/constants/app_colors.dart';
import 'package:wafra_frontend/features/listings/domain/entities/food_listing.dart';

const _kPurple = AppColors.foodBankPurple;
const _kPurpleLight = Color(0xFFF3E8FF);

class CompactListingCard extends StatelessWidget {
  final FoodListing listing;
  final int qty;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onTap;

  const CompactListingCard({
    super.key,
    required this.listing,
    required this.qty,
    required this.onQtyChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = qty > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _kPurple : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: listing.photoUrl != null
                  ? Image.network(
                      listing.photoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _IconThumb(listing: listing),
                    )
                  : _IconThumb(listing: listing),
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
                    '${listing.restaurant} · ${listing.itemsLeft} left',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: const Color(0xFF8E8E93),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                _QtyBtn(
                  icon: Icons.remove,
                  onTap: qty > 0 ? () => onQtyChanged(qty - 1) : null,
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '$qty',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                _QtyBtn(
                  icon: Icons.add,
                  onTap: qty < listing.itemsLeft
                      ? () => onQtyChanged(qty + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconThumb extends StatelessWidget {
  final FoodListing listing;
  const _IconThumb({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      color: listing.imageBg,
      child: Icon(listing.imageIcon, color: listing.imageIconColor, size: 24),
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
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: onTap != null ? _kPurpleLight : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap != null ? _kPurple : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
