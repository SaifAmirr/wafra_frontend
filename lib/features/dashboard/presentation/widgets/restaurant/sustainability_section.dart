import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SustainabilitySection extends StatelessWidget {
  final int mealsDonated;
  final int activeListings;
  final int pendingRequests;

  const SustainabilitySection({
    super.key,
    required this.mealsDonated,
    required this.activeListings,
    required this.pendingRequests,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sustainability Impact',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ImpactCard(
              icon: Icons.eco_rounded,
              value: '$mealsDonated',
              label: 'MEALS\nDONATED',
            ),
            const SizedBox(width: 10),
            _ImpactCard(
              icon: Icons.local_offer_outlined,
              value: '$activeListings',
              label: 'ACTIVE\nLISTINGS',
            ),
            const SizedBox(width: 10),
            _ImpactCard(
              icon: Icons.inbox_outlined,
              value: '$pendingRequests',
              label: 'PENDING\nREQUESTS',
            ),
          ],
        ),
      ],
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ImpactCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A5C38),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
