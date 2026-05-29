import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveOrderCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ActiveOrderCard({super.key, required this.data});

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
