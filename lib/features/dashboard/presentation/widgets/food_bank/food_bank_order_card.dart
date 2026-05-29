import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kPurple = Color(0xFF7C3AED);

class FoodBankOrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onCancel;
  final VoidCallback? onShowCode;
  final VoidCallback? onFindAlternatives;

  const FoodBankOrderCard({
    super.key,
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
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
