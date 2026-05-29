import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_row.dart';

class RequestDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const RequestDetailsSheet({super.key, required this.data});

  String _fmtPickup(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      final h = dt.hour > 12
          ? dt.hour - 12
          : dt.hour == 0
              ? 12
              : dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final ap = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day}/${dt.month}/${dt.year}  ·  $h:$m $ap';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverName = data['receiver_name'] as String? ?? 'Unknown';
    final receiverRole = data['receiver_role'] as String? ?? 'individual';
    final receiverPhone = data['receiver_phone'] as String?;
    final foodName = data['food_name'] as String? ?? '';
    final qty = data['requested_quantity'];
    final status = data['status'] as String? ?? 'pending';
    final pickup = _fmtPickup(data['pickup_time'] as String?);
    final created = _fmtPickup(data['created_at'] as String?);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFF2F2F7),
                  child: Text(
                    receiverName.isNotEmpty
                        ? receiverName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: const Color(0xFF1A5C38),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: receiverRole == 'foodbank'
                              ? const Color(0xFFF3E8FF)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          receiverRole == 'foodbank'
                              ? 'Food Bank'
                              : 'Individual',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: receiverRole == 'foodbank'
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            DetailRow(
              icon: Icons.restaurant_outlined,
              label: 'Food',
              value: '$foodName · Qty $qty',
            ),
            DetailRow(
              icon: Icons.access_time,
              label: 'Pickup window',
              value: pickup,
            ),
            DetailRow(
              icon: Icons.event_outlined,
              label: 'Requested',
              value: created,
            ),
            if (receiverPhone != null && receiverPhone.trim().isNotEmpty)
              DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: receiverPhone,
              ),
            DetailRow(
              icon: Icons.flag_outlined,
              label: 'Status',
              value: status,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
