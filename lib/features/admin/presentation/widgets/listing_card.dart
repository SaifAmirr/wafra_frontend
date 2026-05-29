import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_chip.dart';
import 'admin_colors.dart';

class ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onDelete;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onDelete,
  });

  static const _statusColors = {
    'available': kAdminGreen,
    'reserved': Color(0xFFF59E0B),
    'completed': Color(0xFF94A3B8),
  };

  @override
  Widget build(BuildContext context) {
    final name = listing['food_name'] as String? ?? '—';
    final restaurant = listing['restaurant_name'] as String? ?? '—';
    final category = listing['category'] as String? ?? '—';
    final quantity = listing['quantity']?.toString() ?? '—';
    final status = listing['status'] as String? ?? 'available';
    final statusColor = _statusColors[status] ?? const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kAdminGreenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood_outlined,
                color: kAdminGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$restaurant · $category · $quantity left',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 6),
                AdminChip(label: status, color: statusColor),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Colors.red.shade400, size: 22),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
