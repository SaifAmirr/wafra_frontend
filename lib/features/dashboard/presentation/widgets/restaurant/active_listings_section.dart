import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/dashboard/domain/listing_model.dart';
import 'restaurant_listing_card.dart';

class ActiveListingsSection extends StatelessWidget {
  final List<RestaurantListing> listings;
  final bool loading;
  final void Function(RestaurantListing)? onTap;

  const ActiveListingsSection({
    super.key,
    required this.listings,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Listings',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Text(
                'View All',
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
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Color(0xFF1A5C38)),
            ),
          )
        else if (listings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No active listings yet.',
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF94A3B8)),
              ),
            ),
          )
        else
          CustomPaint(
            painter: _DashedBorderPainter(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (int i = 0; i < listings.length; i++) ...[
                    GestureDetector(
                      onTap: onTap != null ? () => onTap!(listings[i]) : null,
                      child: RestaurantListingCard(listing: listings[i]),
                    ),
                    if (i < listings.length - 1)
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dash = 6.0;
    const gap = 4.0;
    const radius = 14.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashed.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
